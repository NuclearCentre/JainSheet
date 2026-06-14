# JainSheet GitHub Push Script
# -------------------------------------------------------
# Usage:
#   $env:GH_TOKEN = "YOUR_TOKEN_HERE"
#   .\jainsheet_push.ps1
#
# Get token: https://github.com/settings/tokens
# Scope needed: repo (full control)
# Delete token after use - never save it anywhere.
# -------------------------------------------------------

$ErrorActionPreference = "Stop"
$ProjectPath = "D:\JainSheet"
$RepoOwner   = "NuclearCentre"
$RepoName    = "JainSheet"

# Check token is set
if (-not $env:GH_TOKEN -or $env:GH_TOKEN -eq "YOUR_TOKEN_HERE") {
    Write-Host ""
    Write-Host " ERROR: GH_TOKEN is not set." -ForegroundColor Red
    Write-Host ""
    Write-Host " Run this first:" -ForegroundColor Yellow
    Write-Host '   $env:GH_TOKEN = "YOUR_TOKEN_HERE"' -ForegroundColor Cyan
    Write-Host '   .\jainsheet_push.ps1' -ForegroundColor Cyan
    Write-Host ""
    Write-Host " Get token: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host " Scope needed: repo (full control)" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# Move to project folder
Set-Location $ProjectPath
Write-Host ""
Write-Host " JainSheet GitHub Push" -ForegroundColor Green
Write-Host " Project : $ProjectPath"
Write-Host " Repo    : https://github.com/$RepoOwner/$RepoName"
Write-Host ""

# Fix Git config
git config --global --add safe.directory "*" 2>$null
git config --global user.name $RepoOwner 2>$null
git config --global user.email "admin@jainsheet.com" 2>$null

# Init repo if needed
if (-not (Test-Path "$ProjectPath\.git")) {
    Write-Host " Initialising Git repo..." -ForegroundColor Yellow
    git init
    git remote add origin "https://github.com/$RepoOwner/$RepoName.git"
}

# Set remote URL with token
$RemoteUrl = "https://$RepoOwner`:$env:GH_TOKEN@github.com/$RepoOwner/$RepoName.git"
git remote set-url origin $RemoteUrl

# Stage files
Write-Host " Staging files..."
$FilesToAdd = @("main.js","renderer.js","index.html","package.json","jainsheet_deploy.bat","jainsheet_push.ps1")
foreach ($f in $FilesToAdd) {
    if (Test-Path "$ProjectPath\$f") { git add $f }
}
if (Test-Path "$ProjectPath\.gitignore") { git add .gitignore }

# Check if anything to commit
$staged = git diff --cached --name-only
if (-not $staged) {
    Write-Host ""
    Write-Host " Nothing to commit - already up to date." -ForegroundColor Green
} else {
    Write-Host " Files staged:"
    $staged | ForEach-Object { Write-Host "   + $_" -ForegroundColor Cyan }

    # Commit
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
    $commitMsg = "JainSheet update $timestamp"
    Write-Host ""
    Write-Host " Committing: $commitMsg"
    git commit -m $commitMsg

    # Push
    Write-Host ""
    Write-Host " Pushing to GitHub..."
    git push origin main

    Write-Host ""
    Write-Host " *** Saved to GitHub successfully! ***" -ForegroundColor Green
    Write-Host "     https://github.com/$RepoOwner/$RepoName" -ForegroundColor Cyan
}

# Clear token from memory
$env:GH_TOKEN = ""
Write-Host ""
Write-Host " Token cleared from memory." -ForegroundColor Gray
Write-Host ""
