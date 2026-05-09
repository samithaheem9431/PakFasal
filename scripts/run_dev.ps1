#!/usr/bin/env pwsh
# Run the app in dev mode with secrets loaded from config/dev.json.
# Usage:  .\scripts\run_dev.ps1                  (defaults to debug)
#         .\scripts\run_dev.ps1 -Profile         (profile build)
#         .\scripts\run_dev.ps1 -Release         (release build)
#         .\scripts\run_dev.ps1 -Build           (just build, no run)

param(
    [switch]$Profile,
    [switch]$Release,
    [switch]$Build
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
Set-Location $repoRoot

$configFile = Join-Path $repoRoot 'config\dev.json'
if (-not (Test-Path $configFile)) {
    Write-Host "config\dev.json not found." -ForegroundColor Yellow
    Write-Host "Copy config\app_config.json to config\dev.json and fill in your keys." -ForegroundColor Yellow
    exit 1
}

$mode = 'debug'
if ($Profile) { $mode = 'profile' }
if ($Release) { $mode = 'release' }

$action = if ($Build) { 'build apk' } else { 'run' }
$flagPrefix = if ($Build) { '' } else { "--$mode " }

$cmd = "flutter $action $flagPrefix--dart-define-from-file=config/dev.json"
Write-Host "> $cmd" -ForegroundColor Cyan
Invoke-Expression $cmd
