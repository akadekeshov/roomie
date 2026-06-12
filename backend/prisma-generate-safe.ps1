$ErrorActionPreference = 'Stop'

$backendDir = $PSScriptRoot
$clientDir = Join-Path $backendDir 'node_modules\.prisma\client'

function Write-Step($message) {
  Write-Host ''
  Write-Host "==> $message" -ForegroundColor Cyan
}

function Stop-RoomieProcesses {
  Write-Step 'Stopping backend and Prisma Studio before generate'

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

Stop-RoomieProcesses
Remove-PrismaTemps

Write-Step 'Generating Prisma Client'
Push-Location $backendDir
try {
  npx prisma generate
} finally {
  Pop-Location
}

Write-Host ''
Write-Host 'Prisma Client generated successfully.' -ForegroundColor Green
Write-Host 'You can now start backend or Prisma Studio.' -ForegroundColor Green
