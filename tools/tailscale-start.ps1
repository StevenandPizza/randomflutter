param(
    [string]$PhoneIP = '',
    [string]$DebugPort = '',
    [switch]$Pair
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$configFile = "$PSScriptRoot\phone-config.txt"

# --- Pairing step (one-time or when port changes) ---
if ($Pair) {
    $pairIP = $PhoneIP
    if (-not $pairIP) { $pairIP = Read-Host 'Phone Tailscale IP' }

    $pairPort = Read-Host 'Pairing port (from "Pair device with pairing code")'
    $pairCode = Read-Host 'Six-digit pairing code'

    $sdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_HOME }
    if (-not $sdkRoot) { $sdkRoot = 'C:\Users\Admin\AppData\Local\Android\Sdk' }
    $adb = "$sdkRoot\platform-tools\adb.exe"

    Write-Host "Pairing with ${pairIP}:${pairPort} ..." -ForegroundColor Cyan
    & $adb pair "${pairIP}:${pairPort}" $pairCode
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Pairing failed. Keep Wireless debugging open and check the code." -ForegroundColor Red
        exit 1
    }

    $debugPort = Read-Host "Enter the debugging port shown after paired (e.g. 39675)"
    Set-Content -Path $configFile -Value "${pairIP}`r`n${debugPort}"
    Write-Host "Paired and saved. Debug port: ${debugPort}" -ForegroundColor Green
    exit 0
}

# --- Connect ---
& "$PSScriptRoot\tailscale-connect.ps1" -PhoneIP $PhoneIP -DebugPort $DebugPort
if ($LASTEXITCODE -ne 0) { exit 1 }

# Reload config (connect script may have updated it)
if (Test-Path $configFile) {
    $lines = Get-Content $configFile
    $PhoneIP = $lines[0].Trim()
    $DebugPort = $lines[1].Trim()
}

# Find flutter
$flutter = Get-Command flutter.bat -ErrorAction SilentlyContinue
if (-not $flutter) {
    $d = 'D:\Flutter stuff\flutter_windows_3.44.6-stable\flutter\bin\flutter.bat'
    if (Test-Path $d) { $flutter = $d }
    else { throw 'flutter.bat not found. Set PATH or update this script.' }
}

# Launch flutter run
$title = "Flutter on $PhoneIP"

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-NoProfile",
    "-Command `"& '$flutter' run -d ${PhoneIP}:${DebugPort} --hot`"",
    "-WorkingDirectory `"$projectRoot`""
) -WindowStyle Normal

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter running on $PhoneIP":$DebugPort    -ForegroundColor Green
Write-Host "  Save a Dart file -> auto Hot Reload"       -ForegroundColor Green
Write-Host "  Type 'r' in the new window for manual"     -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
