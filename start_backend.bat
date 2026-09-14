@echo off
title Kabadiwala Connect - AI Backend & Cloudflare Tunnel
echo =======================================================
echo   Kabadiwala Connect AI Backend + Tunnel Starter
echo =======================================================
echo.

cd /d "%~dp0"

echo [1/2] Starting Python FastAPI AI Backend on port 8000...
start "AI Backend Server (Port 8000)" cmd /k "cd /d "%~dp0kabadiwala_backend" && python -m uvicorn main:app --host 0.0.0.0 --port 8000"

echo Waiting 3 seconds for server to initialize...
timeout /t 3 /nobreak >nul

echo [2/2] Starting Cloudflare Tunnel...
echo -------------------------------------------------------
echo Look for the https://*.trycloudflare.com URL below:
echo -------------------------------------------------------
echo.
"%~dp0cloudflared.exe" tunnel --url http://127.0.0.1:8000
pause
