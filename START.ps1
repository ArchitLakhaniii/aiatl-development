# Quick Start Script for Flash Request
# Run this to start all services

Write-Host "Starting Flash Request Services..." -ForegroundColor Cyan
Write-Host ""

$projectRoot = Get-Location

# Kill any existing processes on these ports (optional)
Write-Host "Checking for existing services..." -ForegroundColor Yellow
Get-NetTCPConnection -LocalPort 8000 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
Get-NetTCPConnection -LocalPort 3001 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue }
Start-Sleep -Seconds 2

# Start Gemini Service
Write-Host "1. Starting Gemini Service (port 3001)..." -ForegroundColor Yellow
$geminiDir = Join-Path $projectRoot "json-parsing-gemini"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$geminiDir'; Write-Host '=== Gemini Service (Port 3001) ===' -ForegroundColor Cyan; npm run dev"
Start-Sleep -Seconds 3

# Start Backend
Write-Host "2. Starting Backend API (port 8000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Backend API (Port 8000) ===' -ForegroundColor Cyan; Write-Host 'Health: http://localhost:8000/health' -ForegroundColor Green; Write-Host 'Docs: http://localhost:8000/docs' -ForegroundColor Green; python -m uvicorn backend.app:app --reload --port 8000"
Start-Sleep -Seconds 3

# Start Frontend
Write-Host "3. Starting Frontend (port 5173)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Frontend (Port 5173) ===' -ForegroundColor Cyan; Write-Host 'URL: http://localhost:5173' -ForegroundColor Green; npm run dev"
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "All services started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Wait 10-15 seconds for services to start, then:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Open browser: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:5173" -ForegroundColor White
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor White
Write-Host "  Gemini:   http://localhost:3001" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to exit this window..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

