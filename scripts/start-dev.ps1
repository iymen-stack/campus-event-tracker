# Windows local development helper. Run from the repository with:
#   .\scripts\start-dev.ps1
# This script does not create, reset, or modify MySQL tables.
param(
    [string]$Database = "augsburg_events",
    [string]$DbUser = "campus_reader",
    [int]$Port = 8080
)

$ErrorActionPreference = "Stop"
$repository = Split-Path -Parent $PSScriptRoot
$backend = Join-Path $repository "backend"
$frontend = Join-Path $repository "frontend"

if (-not (Test-Path (Join-Path $backend "mvnw.cmd"))) {
    throw "Cannot find backend/mvnw.cmd. Run this script from a full repository checkout."
}
if (-not (Test-Path (Join-Path $frontend "index.html"))) {
    throw "Cannot find frontend/index.html."
}

# Check rather than stop someone else's server.
$listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($listener) {
    $ownerProcess = Get-Process -Id $listener.OwningProcess -ErrorAction SilentlyContinue
    $ownerName = if ($ownerProcess) { $ownerProcess.ProcessName } else { "unknown" }
    throw "Port $Port is in use by PID $($listener.OwningProcess) ($ownerName). Stop that process if it is yours, or rerun with -Port 8081."
}

$mysqlService = Get-Service -Name "MySQL84" -ErrorAction SilentlyContinue
if ($mysqlService -and $mysqlService.Status -ne "Running") {
    Write-Warning "MySQL84 is stopped. Start it separately (an elevated terminal may be needed)."
}

# Spring Boot recognizes these environment variable names as configuration keys.
# They apply to Maven and the Java process started by this PowerShell session.
$env:SPRING_DATASOURCE_URL = "jdbc:mysql://localhost:3306/$Database"
$env:SPRING_DATASOURCE_USERNAME = $DbUser
$env:SERVER_PORT = "$Port"

# Serve the existing frontend directory from Spring during local development.
# Run Maven from backend/ so ../frontend/ resolves correctly.
$env:SPRING_WEB_RESOURCES_STATIC_LOCATIONS = "file:../frontend/,classpath:/static/"

$securePassword = Read-Host "MySQL password for $DbUser" -AsSecureString
$env:SPRING_DATASOURCE_PASSWORD = [System.Net.NetworkCredential]::new("", $securePassword).Password

Push-Location $backend
try {
    Write-Host "Starting Campus Event Tracker at http://localhost:$Port/"
    Write-Host "Press Ctrl+C to stop the application."
    & .\mvnw.cmd spring-boot:run
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Spring Boot exited with code $LASTEXITCODE. Read the earlier APPLICATION FAILED TO START / Caused by lines."
    }
}
finally {
    Pop-Location
    # Do not retain a plaintext database password in this terminal after shutdown.
    Remove-Item Env:SPRING_DATASOURCE_PASSWORD -ErrorAction SilentlyContinue
    $securePassword = $null
}
