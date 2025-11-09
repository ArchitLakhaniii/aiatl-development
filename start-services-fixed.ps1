# Fixed Startup Script for Flash Request
# This script starts all services properly

$ErrorActionPreference = "Continue"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Flash Request Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Get-Location

# Start Gemini Service (port 3001)
Write-Host "1. Starting Gemini Service (port 3001)..." -ForegroundColor Yellow
$geminiDir = Join-Path $projectRoot "json-parsing-gemini"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$geminiDir'; Write-Host '=== Gemini Parsing Service ===' -ForegroundColor Cyan; Write-Host 'Port: 3001' -ForegroundColor Green; Write-Host ''; npm run dev"
Start-Sleep -Seconds 3

# Start Backend (port 8000)
Write-Host "2. Starting Backend API (port 8000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Backend API Server ===' -ForegroundColor Cyan; Write-Host 'Port: 8000' -ForegroundColor Green; Write-Host 'API: http://localhost:8000' -ForegroundColor Green; Write-Host 'Docs: http://localhost:8000/docs' -ForegroundColor Green; Write-Host ''; python -m uvicorn backend.app:app --reload --port 8000"
Start-Sleep -Seconds 3

# Start Frontend (port 5173)
Write-Host "3. Starting Frontend (port 5173)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Frontend Dev Server ===' -ForegroundColor Cyan; Write-Host 'Port: 5173' -ForegroundColor Green; Write-Host 'URL: http://localhost:5173' -ForegroundColor Green; Write-Host 'Login: http://localhost:5173/login' -ForegroundColor Green; Write-Host ''; npm run dev"
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All services started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Services:" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:5173" -ForegroundColor Green
Write-Host "  Backend:  http://localhost:8000" -ForegroundColor Green
Write-Host "  Gemini:   http://localhost:3001" -ForegroundColor Green
Write-Host ""
Write-Host "Wait 10-15 seconds for services to fully start," -ForegroundColor Yellow
Write-Host "then open: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

