# Start Services Script
# Run each service in a separate PowerShell window

$projectRoot = "C:\Users\romee\OneDrive\Desktop\College Work\Code\aiatlwinningproject-feat-json-parsing-sys-wdata"
$geminiDir = Join-Path $projectRoot "json-parsing-gemini"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting All Services" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Start Gemini Service
Write-Host "1. Starting Gemini Parsing Service (port 3001)..." -ForegroundColor Yellow
$geminiApiKey = "AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$geminiDir'; `$env:GEMINI_API_KEY='$geminiApiKey'; Write-Host '=== Gemini Parsing Service ===' -ForegroundColor Cyan; Write-Host 'Port: 3001' -ForegroundColor Green; Write-Host 'API Key: Loaded from .env' -ForegroundColor Green; Write-Host ''; npm run dev"

Start-Sleep -Seconds 2

# Start Frontend
Write-Host "2. Starting Frontend Dev Server (port 5173)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Frontend Dev Server ===' -ForegroundColor Cyan; Write-Host 'Port: 5173' -ForegroundColor Green; Write-Host 'URL: http://localhost:5173' -ForegroundColor Green; Write-Host ''; npm run dev"

Start-Sleep -Seconds 2

# Start Backend
Write-Host "3. Starting Backend API Server (port 8000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot'; Write-Host '=== Backend API Server ===' -ForegroundColor Cyan; Write-Host 'Port: 8000' -ForegroundColor Green; Write-Host 'API: http://localhost:8000' -ForegroundColor Green; Write-Host ''; npm run dev:backend"

Start-Sleep -Seconds 5

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Services Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Three PowerShell windows should now be open with:" -ForegroundColor White
Write-Host "  • Gemini Service (port 3001)" -ForegroundColor Gray
Write-Host "  • Frontend Dev Server (port 5173)" -ForegroundColor Gray
Write-Host "  • Backend API Server (port 8000)" -ForegroundColor Gray
Write-Host ""
Write-Host "Opening browser to http://localhost:5173..." -ForegroundColor Yellow
Start-Sleep -Seconds 3
Start-Process "http://localhost:5173"
Write-Host ""
Write-Host "To run services manually in THIS terminal, use:" -ForegroundColor Yellow
Write-Host "  Terminal 1: cd json-parsing-gemini && npm run dev" -ForegroundColor Gray
Write-Host "  Terminal 2: npm run dev" -ForegroundColor Gray
Write-Host "  Terminal 3: npm run dev:backend" -ForegroundColor Gray
Write-Host ""

