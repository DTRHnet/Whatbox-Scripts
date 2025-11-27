# Update Rules Script (PowerShell)
# Syncs global .cursor/rules/*.mcr to all scripts' .cursor/rules/ directories

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$GlobalRulesDir = Join-Path $RepoRoot ".cursor\rules"
$ScriptsDir = Join-Path $RepoRoot "scripts"

Write-Host "🔄 Syncing global rules to all scripts..." -ForegroundColor Cyan

# Check if global rules directory exists
if (-not (Test-Path $GlobalRulesDir)) {
    Write-Host "❌ Error: Global rules directory not found: $GlobalRulesDir" -ForegroundColor Red
    exit 1
}

# Find all script directories
Get-ChildItem -Path $ScriptsDir -Directory | Where-Object { $_.Name -ne "TEMPLATE" } | ForEach-Object {
    $ScriptName = $_.Name
    $ScriptRulesDir = Join-Path $_.FullName ".cursor\rules"
    
    # Create .cursor/rules directory if it doesn't exist
    if (-not (Test-Path $ScriptRulesDir)) {
        New-Item -ItemType Directory -Path $ScriptRulesDir -Force | Out-Null
    }
    
    Write-Host "📋 Syncing rules to: $ScriptName" -ForegroundColor Yellow
    
    # Copy all .mcr files from global rules
    $McrFiles = Get-ChildItem -Path $GlobalRulesDir -Filter "*.mcr" -ErrorAction SilentlyContinue
    if ($McrFiles) {
        Copy-Item -Path "$GlobalRulesDir\*.mcr" -Destination $ScriptRulesDir -Force
        Write-Host "✅ Rules synced to $ScriptName" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Warning: No .mcr files found in global rules directory" -ForegroundColor Yellow
    }
}

Write-Host "✨ Rule sync complete!" -ForegroundColor Green

