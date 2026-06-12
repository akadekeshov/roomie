$ErrorActionPreference = 'Stop'

$backendDir = $PSScriptRoot
$backendLog = Join-Path $backendDir 'backend-runtime.out.log'
$backendErr = Join-Path $backendDir 'backend-runtime.err.log'
$studioLog = Join-Path $backendDir 'prisma-studio.out.log'
$studioErr = Join-Path $backendDir 'prisma-studio.err.log'
$clientDir = Join-Path $backendDir 'node_modules\.prisma\client'

function Write-Step($message) {
  Write-Host ''
  Write-Host "==> $message" -ForegroundColor Cyan
}

function Stop-BackendProcesses {
  Write-Step 'Stopping Roomie backend and Prisma Studio'

  $ports = @(3001, 5555)
  foreach ($port in $ports) {
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    foreach ($conn in $connections) {
      if ($conn.OwningProcess -and (Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
      }
    }
  }

  $nodeProcesses = Get-CimInstance Win32_Process |
    Where-Object {
      $_.Name -eq 'node.exe' -and (
        $_.CommandLine -like "*$backendDir*" -or
        $_.CommandLine -like '*prisma studio*'
      )
    }

  foreach ($proc in $nodeProcesses) {
    Stop-Process -Id $proc.ProcessId -Force -ErrorAction SilentlyContinue
  }

  Start-Sleep -Seconds 2
}

function Remove-PrismaTemps {
  Write-Step 'Removing temporary Prisma engine files'

  if (Test-Path $clientDir) {
    Get-ChildItem $clientDir -Filter 'query_engine-windows.dll.node.tmp*' -ErrorAction SilentlyContinue |
      Remove-Item -Force -ErrorAction SilentlyContinue
  }
}

function Run-Command($title, $command) {
  Write-Step $title
  Push-Location $backendDir
  try {
    Invoke-Expression $command
  } finally {
    Pop-Location
  }
}

function Start-Services {
  Write-Step 'Starting backend'

  foreach ($file in @($backendLog, $backendErr, $studioLog, $studioErr)) {
    if (Test-Path $file) {
      Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
  }

  $backend = Start-Process `
    -FilePath 'node' `
    -ArgumentList 'dist/main.js' `
    -WorkingDirectory $backendDir `
    -WindowStyle Hidden `
    -RedirectStandardOutput $backendLog `
    -RedirectStandardError $backendErr `
    -PassThru

  Write-Host "Backend PID: $($backend.Id)" -ForegroundColor Green

  Write-Step 'Starting Prisma Studio'

  $studio = Start-Process `
    -FilePath 'npx.cmd' `
    -ArgumentList 'prisma', 'studio', '--browser', 'none', '--port', '5555' `
    -WorkingDirectory $backendDir `
    -WindowStyle Hidden `
    -RedirectStandardOutput $studioLog `
    -RedirectStandardError $studioErr `
    -PassThru

  Write-Host "Prisma Studio PID: $($studio.Id)" -ForegroundColor Green
}

function Test-Endpoint($url, $name) {
  Write-Step "Checking $name"
  $status = $null
  for ($i = 0; $i -lt 10; $i++) {
    try {
      $status = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5).StatusCode
      break
    } catch {
      Start-Sleep -Seconds 1
    }
  }

  if ($status -ne 200) {
    throw "$name did not return HTTP 200"
  }

  Write-Host "$name is up: $status" -ForegroundColor Green
}

Stop-BackendProcesses
Remove-PrismaTemps
Run-Command 'Generating Prisma Client' 'npx prisma generate'
Run-Command 'Building backend' 'npm run build'
Start-Services
Test-Endpoint 'http://localhost:3001/api' 'Backend API'
Test-Endpoint 'http://localhost:5555' 'Prisma Studio'

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host 'Backend: http://localhost:3001/api'
Write-Host 'Prisma Studio: http://localhost:5555'
