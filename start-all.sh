#!/bin/bash
# Start All Services Script for Linux/Mac
# This script starts the backend, Gemini service, and frontend

set -e

echo "========================================"
echo "Starting Flash Request Application"
echo "========================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi
echo "✅ Node.js found: $(node --version)"

# Check if Python is installed
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "❌ Python is not installed. Please install Python first."
    exit 1
fi
PYTHON_CMD=$(command -v python3 || command -v python)
echo "✅ Python found: $($PYTHON_CMD --version)"

echo ""
echo "Installing dependencies..."

# Install Python dependencies
echo "Installing Python dependencies..."
$PYTHON_CMD -m pip install -q -r requirements.txt || echo "⚠️ Warning: Failed to install Python dependencies"

# Install frontend dependencies
echo "Installing frontend dependencies..."
npm install --silent || echo "⚠️ Warning: Failed to install frontend dependencies"

# Install Gemini service dependencies
echo "Installing Gemini service dependencies..."
cd json-parsing-gemini
npm install --silent || echo "⚠️ Warning: Failed to install Gemini service dependencies"
cd ..

echo ""
echo "Starting services..."
echo ""

# Get the project root directory
PROJECT_ROOT=$(pwd)
GEMINI_DIR="$PROJECT_ROOT/json-parsing-gemini"

# Start Gemini Service (port 3001)
echo "1. Starting Gemini Parsing Service (port 3001)..."
if [ -f "$GEMINI_DIR/.env" ]; then
    cd "$GEMINI_DIR"
    npm run dev > /dev/null 2>&1 &
    GEMINI_PID=$!
    cd "$PROJECT_ROOT"
else
    # Set GEMINI_API_KEY if not in .env
    export GEMINI_API_KEY=${GEMINI_API_KEY:-"AIzaSyB-Iy3KkF7m8Iape1M5aFGMJungEzsXYNc"}
    cd "$GEMINI_DIR"
    GEMINI_API_KEY=$GEMINI_API_KEY npm run dev > /dev/null 2>&1 &
    GEMINI_PID=$!
    cd "$PROJECT_ROOT"
fi
echo "✅ Gemini service started (PID: $GEMINI_PID)"
sleep 3

# Start Backend (port 8000)
echo "2. Starting Backend API Server (port 8000)..."
$PYTHON_CMD -m uvicorn backend.app:app --reload --port 8000 > /dev/null 2>&1 &
BACKEND_PID=$!
echo "✅ Backend started (PID: $BACKEND_PID)"
sleep 3

# Start Frontend (port 5173)
echo "3. Starting Frontend Dev Server (port 5173)..."
npm run dev > /dev/null 2>&1 &
FRONTEND_PID=$!
echo "✅ Frontend started (PID: $FRONTEND_PID)"
sleep 3

echo ""
echo "========================================"
echo "All services started!"
echo "========================================"
echo ""
echo "Frontend: http://localhost:5173"
echo "Backend API: http://localhost:8000"
echo "Gemini Service: http://localhost:3001"
echo ""
echo "Open your browser and navigate to: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop all services"

# Function to cleanup on exit
cleanup() {
    echo ""
    echo "Stopping services..."
    kill $GEMINI_PID $BACKEND_PID $FRONTEND_PID 2>/dev/null || true
    echo "Services stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Wait for services
wait

