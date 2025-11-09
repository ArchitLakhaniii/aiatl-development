# Start All Services Script for Windows PowerShell
# This script starts the backend, Gemini service, and frontend

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Flash Request Application" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    exit 1
}

# Check if Python is installed
try {
    $pythonVersion = python --version
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python is not installed. Please install Python first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow

# Install Python dependencies
Write-Host "Installing Python dependencies..." -ForegroundColor Yellow
try {
    python -m pip install -r requirements.txt --quiet
    Write-Host "✅ Python dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Warning: Failed to install Python dependencies. You may need to install them manually." -ForegroundColor Yellow
}

# Install frontend dependencies
Write-Host "Installing frontend dependencies..." -ForegroundColor Yellow
try {
    npm install --silent
    Write-Host "✅ Frontend dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Warning: Failed to install frontend dependencies. You may need to install them manually." -ForegroundColor Yellow
}

# Install Gemini service dependencies
Write-Host "Installing Gemini service dependencies..." -ForegroundColor Yellow
try {
    Set-Location json-parsing-gemini
    npm install --silent
    Set-Location ..
    Write-Host "✅ Gemini service dependencies installed" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Warning: Failed to install Gemini service dependencies. You may need to install them manually." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Starting services..." -ForegroundColor Yellow
Write-Host ""

# Get the project root directory
$projectRoot = Get-Location

# Start Gemini Service (port 3001)
Write-Host "1. Starting Gemini Parsing Service (port 3001)..." -ForegroundColor Yellow
$geminiDir = Join-Path $projectRoot "json-parsing-gemini"
$geminiApiKey = "AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$geminiDir'; `$env:GEMINI_API_KEY='$geminiApiKey'; Write-Host '=== Gemini Parsing Service ===' -ForegroundColor Cyan; Write-Host 'Port: 3001' -ForegroundColor Green; Write-Host 'API Key: Loaded' -ForegroundColor Green; Write-Host ''; npm run dev"
Start-Sleep -Seconds 5

# Start Backend (port 8000)
Write-Host "2. Starting Backend API Server (port 8000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Backend API Server ===' -ForegroundColor Cyan; Write-Host 'Port: 8000' -ForegroundColor Green; Write-Host 'API: http://localhost:8000' -ForegroundColor Green; Write-Host 'Docs: http://localhost:8000/docs' -ForegroundColor Green; Write-Host ''; python -m uvicorn backend.app:app --reload --port 8000"
Start-Sleep -Seconds 5

# Start Frontend (port 5173)
Write-Host "3. Starting Frontend Dev Server (port 5173)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Frontend Dev Server ===' -ForegroundColor Cyan; Write-Host 'Port: 5173' -ForegroundColor Green; Write-Host 'URL: http://localhost:5173' -ForegroundColor Green; Write-Host 'Login: http://localhost:5173/login' -ForegroundColor Green; Write-Host ''; npm run dev"
Start-Sleep -Seconds 3

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All services started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frontend: http://localhost:5173" -ForegroundColor Green
Write-Host "Backend API: http://localhost:8000" -ForegroundColor Green
Write-Host "Gemini Service: http://localhost:3001" -ForegroundColor Green
Write-Host ""
Write-Host "Open your browser and navigate to: http://localhost:5173" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit this window (services will continue running)..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

