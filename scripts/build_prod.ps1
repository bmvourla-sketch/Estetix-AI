# Estetix AI — production build script (PowerShell).
#
# Feeds production secrets to Flutter via --dart-define-from-file so no key
# ever lives in source control. The file `.env.production.json` is git-ignored.
#
# Setup (once):
#   Copy-Item .env.production.example.json .env.production.json
#   # ... then fill in the real values in .env.production.json
#
# Usage:
#   .\scripts\build_prod.ps1               # Android App Bundle (.aab)
#   .\scripts\build_prod.ps1 -Target apk   # Android APK
#   .\scripts\build_prod.ps1 -Target ios   # iOS (requires macOS / Xcode)
param(
  [ValidateSet('aab', 'apk', 'ios')]
  [string]$Target = 'aab'
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$defineFile = Join-Path $ProjectRoot '.env.production.json'
if (-not (Test-Path $defineFile)) {
  throw "Missing $defineFile — copy .env.production.example.json to .env.production.json and fill in real values."
}

$flutterArgs = switch ($Target) {
  'aab' { @('build', 'appbundle', '--release') }
  'apk' { @('build', 'apk', '--release') }
  'ios' { @('build', 'ios', '--release', '--no-codesign') }
}
$flutterArgs += @('--dart-define-from-file', $defineFile)

Write-Host "Running: flutter $($flutterArgs -join ' ')" -ForegroundColor Cyan
& flutter $flutterArgs
if ($LASTEXITCODE -ne 0) {
  throw "flutter build failed with exit code $LASTEXITCODE"
}
Write-Host "Production build complete: $Target" -ForegroundColor Green
