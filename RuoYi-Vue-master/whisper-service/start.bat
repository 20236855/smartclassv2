@echo off
echo ========================================
echo Whisper Service Startup Script
echo ========================================
echo.

REM Check Python
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found. Please install Python 3.8+
    echo Download: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [1/4] Checking Python...
python --version

echo.
echo [2/4] Installing dependencies...
echo This may take a few minutes on first run...
pip install -q openai-whisper flask flask-cors

echo.
echo [3/4] Checking ffmpeg...
ffmpeg -version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] ffmpeg not found
    echo Download: https://ffmpeg.org/download.html
    echo Add ffmpeg.exe to system PATH
    echo.
    pause
)

echo.
echo [4/4] Starting Whisper service...
echo Service URL: http://localhost:8002
echo Health check: http://localhost:8002/health
echo.
echo Press Ctrl+C to stop
echo ========================================
echo.

python whisper_server.py

pause

