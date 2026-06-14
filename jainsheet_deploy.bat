@echo off
REM JainSheet Deploy Tool
REM -------------------------------------------------------
if "%1"=="RELAUNCHED" goto :MAIN
start "JainSheet Deploy" /WAIT cmd /k "%~f0" RELAUNCHED
exit

:MAIN
title JainSheet Deploy Tool
color 0A
cd /d D:\JainSheet

echo.
echo  ============================================================
echo   JainSheet Deploy Tool v2.1
echo   Project : D:\JainSheet
echo   GitHub  : https://github.com/NuclearCentre/JainSheet
echo  ============================================================
echo.

REM Fix Git config (prevents dubious ownership + missing identity errors)
git config --global --add safe.directory "*" >nul 2>&1
git config --global user.name "NuclearCentre" >nul 2>&1
git config --global user.email "admin@jainsheet.com" >nul 2>&1

REM -------------------------------------------------------
REM STEP 1: Check node_modules
REM -------------------------------------------------------
echo [1/5] Checking dependencies...
if not exist "D:\JainSheet\node_modules\" (
    echo       node_modules not found - running npm install...
    cd /d D:\JainSheet
    call npm install
    if errorlevel 1 (
        echo [ERROR] npm install failed.
        pause
        exit /b 1
    )
    echo       Done.
) else (
    echo       OK.
)

REM -------------------------------------------------------
REM STEP 2: Syntax check JS files
REM -------------------------------------------------------
echo.
echo [2/5] Checking JS syntax...
cd /d D:\JainSheet
node --check main.js
if errorlevel 1 (
    echo [ERROR] main.js has syntax errors. Fix before building.
    pause
    exit /b 1
)
node --check renderer.js
if errorlevel 1 (
    echo [ERROR] renderer.js has syntax errors. Fix before building.
    pause
    exit /b 1
)
echo       main.js OK
echo       renderer.js OK

REM -------------------------------------------------------
REM STEP 3: Kill running JainSheet
REM -------------------------------------------------------
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

REM -------------------------------------------------------
REM STEP 4: Build installer
REM -------------------------------------------------------
echo.
echo [4/5] Building installer...
cd /d D:\JainSheet
call npm run dist
if errorlevel 1 (
    echo [ERROR] Build failed. See errors above.
    pause
    exit /b 1
)
echo       Built: D:\JainSheet\dist\JainSheet-Setup.exe

REM -------------------------------------------------------
REM STEP 5: Push to GitHub
REM -------------------------------------------------------
echo.
echo [5/5] GitHub push...
echo.
echo  Open PowerShell and run:
echo.
echo    $env:GH_TOKEN = "YOUR_TOKEN_HERE"
echo    .\jainsheet_push.ps1
echo.
echo  Get token: https://github.com/settings/tokens  (scope: repo)
echo.

REM Auto-push attempt via git credential prompt
cd /d D:\JainSheet
if not exist "D:\JainSheet\.git\" (
    echo       Initialising git repo...
    git init
    git remote add origin https://github.com/NuclearCentre/JainSheet.git
)

git -C "D:\JainSheet" add main.js renderer.js index.html package.json jainsheet_deploy.bat jainsheet_push.ps1
if exist "D:\JainSheet\.gitignore" git -C "D:\JainSheet" add .gitignore

git -C "D:\JainSheet" diff --cached --quiet
if not errorlevel 1 (
    echo       Nothing to commit - already up to date.
    goto :DONE
)

set DT=%DATE% %TIME%
git -C "D:\JainSheet" commit -m "JainSheet update %DT%"
if errorlevel 1 (
    echo [WARN] Commit failed. Use the PowerShell command above to push manually.
    goto :DONE
)

echo.
echo  Enter GitHub credentials when prompted:
echo    Username : NuclearCentre
echo    Password : paste your Personal Access Token
echo.
git -C "D:\JainSheet" push origin main
if errorlevel 1 (
    echo [WARN] Push failed. Use the PowerShell command above instead.
) else (
    echo  *** Pushed to GitHub successfully! ***
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
