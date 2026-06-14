@echo off
REM JainSheet Deploy Tool - Build Only
REM Git push is handled by jainsheet_push.ps1
if "%1"=="RELAUNCHED" goto :MAIN
start "JainSheet Deploy" /WAIT cmd /k "%~f0" RELAUNCHED
exit

:MAIN
title JainSheet Deploy Tool
color 0A
cd /d D:\JainSheet

echo.
echo  ============================================================
echo   JainSheet Deploy Tool
echo   Project : D:\JainSheet
echo  ============================================================
echo.

REM --- Fix Git config ---
git config --global --add safe.directory "*" >nul 2>&1
git config --global user.name "NuclearCentre" >nul 2>&1
git config --global user.email "admin@jainsheet.com" >nul 2>&1

REM --- STEP 1: node_modules ---
echo [1/4] Checking node_modules...
if not exist "D:\JainSheet\node_modules\" (
    echo       Not found. Running npm install - this may take a few minutes...
    cd /d D:\JainSheet
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
) else (
    echo       OK.
)

REM --- STEP 2: Syntax check ---
echo.
echo [2/4] Checking JS files for errors...
cd /d D:\JainSheet
node --check main.js
if errorlevel 1 (
    echo [ERROR] main.js has a syntax error. Fix it first.
    pause
    exit /b 1
)
node --check renderer.js
if errorlevel 1 (
    echo [ERROR] renderer.js has a syntax error. Fix it first.
    pause
    exit /b 1
)
echo       main.js OK
echo       renderer.js OK

REM --- STEP 3: Close JainSheet ---
echo.
echo [3/4] Closing JainSheet if open...
tasklist 2>nul | find /i "JainSheet.exe" >nul
if not errorlevel 1 (
    taskkill /IM JainSheet.exe /F >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo       Closed.
) else (
    echo       Not running.
)

REM --- STEP 4: Build ---
echo.
echo [4/4] Building installer...
echo       Please wait - this takes 2 to 3 minutes...
echo.
cd /d D:\JainSheet
call npm run dist
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed. See errors above.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   BUILD COMPLETE
echo   Installer : D:\JainSheet\dist\JainSheet-Setup.exe
echo.
echo   NOW PUSH TO GITHUB - open PowerShell and run:
echo.
echo     $env:GH_TOKEN = "YOUR_TOKEN_HERE"
echo     .\jainsheet_push.ps1
echo.
echo   Get token at: https://github.com/settings/tokens
echo   Scope: repo
echo  ============================================================
echo.
pause
