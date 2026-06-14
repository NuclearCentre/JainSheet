@echo off
REM ═══════════════════════════════════════════════════════
REM  JainSheet Deploy Tool
REM  Double-click OR run from PowerShell — never disappears
REM ═══════════════════════════════════════════════════════

REM Keep window open no matter what happens
if "%1"=="RELAUNCHED" goto :MAIN
start "JainSheet Deploy" /WAIT cmd /k "%~f0" RELAUNCHED
exit

:MAIN
title JainSheet Deploy Tool
color 0A

echo.
echo  ============================================================
echo   JainSheet Deploy Tool
echo   Project : D:\JainSheet
echo   GitHub  : https://github.com/NuclearCentre/JainSheet
echo  ============================================================
echo.

REM ── Force working directory ───────────────────────────────────────────────────
echo Checking project folder...
if not exist "D:\JainSheet\" (
    echo.
    echo [ERROR] D:\JainSheet folder not found!
    echo         Make sure your project is at D:\JainSheet\
    echo.
    pause
    exit /b 1
)
cd /d D:\JainSheet
echo Working directory: %CD%
echo.

REM ── Fix Git safe directory (prevents "dubious ownership" error) ───────────────
git config --global --add safe.directory "D:/JainSheet" >nul 2>&1
git config --global --add safe.directory "*" >nul 2>&1
git config --global user.name "NuclearCentre" >nul 2>&1
git config --global user.email "admin@jainsheet.com" >nul 2>&1

REM ── STEP 1: node_modules check ───────────────────────────────────────────────
echo [1/5] Checking node_modules...
if not exist "D:\JainSheet\node_modules\" (
    echo       Not found - running npm install...
    cd /d D:\JainSheet
    call npm install
    if errorlevel 1 (
        echo.
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
    echo       Done.
) else (
    echo       OK.
)

REM ── STEP 2: Syntax check ─────────────────────────────────────────────────────
echo.
echo [2/5] Checking JS syntax...
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

REM ── STEP 3: Kill running JainSheet ───────────────────────────────────────────
echo.
echo [3/5] Stopping JainSheet if running...
tasklist 2>nul | find /i "JainSheet.exe" >nul
if not errorlevel 1 (
    taskkill /IM JainSheet.exe /F >nul 2>&1
    timeout /t 2 /nobreak >nul
    echo       Stopped.
) else (
    echo       Not running.
)

REM ── STEP 4: Build ────────────────────────────────────────────────────────────
echo.
echo [4/5] Building installer...
cd /d D:\JainSheet
call npm run dist
if errorlevel 1 (
    echo.
    echo [ERROR] Build failed. See errors above.
    pause
    exit /b 1
)
echo.
echo       Build complete: D:\JainSheet\dist\JainSheet-Setup.exe

REM ── STEP 5: Git push ─────────────────────────────────────────────────────────
echo.
echo [5/5] Saving to GitHub...
cd /d D:\JainSheet

REM Check git is installed
where git >nul 2>&1
if errorlevel 1 (
    echo [WARN] git not found. Install Git from https://git-scm.com
    goto :DONE
)

REM Init repo if needed
if not exist "D:\JainSheet\.git\" (
    echo       Initialising git repo...
    cd /d D:\JainSheet
    git init
    git remote add origin https://github.com/NuclearCentre/JainSheet.git
)

REM Stage files
cd /d D:\JainSheet
git add main.js renderer.js index.html package.json jainsheet_deploy.bat
if exist ".gitignore" git add .gitignore

REM Check for changes
git diff --cached --quiet
if not errorlevel 1 (
    echo       No changes - already up to date.
    goto :DONE
)

REM Build timestamp for commit message
set DT=%DATE% %TIME%
git commit -m "JainSheet update %DT%"
if errorlevel 1 (
    echo [ERROR] git commit failed. See above.
    pause
    goto :DONE
)

REM Push
echo.
echo  ------------------------------------------------------------
echo   ENTERING GITHUB CREDENTIALS:
echo   When prompted -
echo     Username: NuclearCentre
echo     Password: paste your Personal Access Token
echo   Get token: https://github.com/settings/tokens
echo   Scope: repo (full control)
echo  ------------------------------------------------------------
echo.
git push origin main
if errorlevel 1 (
    echo.
    echo [WARN] Push failed. Try these:
    echo   1. Generate new token at https://github.com/settings/tokens
    echo   2. Make sure scope is 'repo'
    echo   3. Check internet connection
) else (
    echo.
    echo  *** Saved to GitHub successfully! ***
)

:DONE
echo.
echo  ============================================================
echo   DONE!
echo   Installer : D:\JainSheet\dist\JainSheet-Setup.exe
echo   Install it to update JainSheet on your PC.
echo  ============================================================
echo.
pause
