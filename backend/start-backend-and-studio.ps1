$ErrorActionPreference = 'Stop'

$backendDir = $PSScriptRoot
$backendLog = Join-Path $backendDir 'backend-runtime.out.log'
$backendErr = Join-Path $backendDir 'backend-runtime.err.log'
$studioLog = Join-Path $backendDir 'prisma-studio.out.log'
$studioErr = Join-Path $backendDir 'prisma-studio.err.log'

function Write-Step($message) {
  Write-Host ''
  Write-Host "==> $message" -ForegroundColor Cyan
}

function Stop-ExistingProcesses {
  Write-Step 'Stopping old backend and Prisma Studio processes'

  $ports = @(3001, 5555)
  foreach ($port in $ports) {
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    foreach ($conn in $connections) {
      if ($conn.OwningProcess -and (Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue)) {
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
      }
    }
  }

  Start-Sleep -Seconds 2
}

function Start-Services {
  foreach ($file in @($backendLog, $backendErr, $studioLog, $studioErr)) {
    if (Test-Path $file) {
      Remove-Item $file -Force -ErrorAction SilentlyContinue
    }
  }

  Write-Step 'Starting backend'
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

Stop-ExistingProcesses
Start-Services

Write-Step 'Checking endpoints'
Test-Endpoint 'http://localhost:3001/api' 'Backend API'
Test-Endpoint 'http://localhost:5555' 'Prisma Studio'

Write-Host ''
Write-Host 'Backend: http://localhost:3001/api' -ForegroundColor Green
Write-Host 'Prisma Studio: http://localhost:5555' -ForegroundColor Green
