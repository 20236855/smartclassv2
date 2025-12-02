@echo off
echo ========================================
echo Step 1: Installing Python packages...
echo ========================================
echo.

pip install openai-whisper flask flask-cors

echo.
echo ========================================
echo Step 2: Starting Whisper service...
echo ========================================
echo.
echo Service will run at: http://localhost:8002
echo Health check: http://localhost:8002/health
echo.
echo Keep this window open!
echo Press Ctrl+C to stop the service
echo.
echo ========================================
echo.

python whisper_server.py

pause

