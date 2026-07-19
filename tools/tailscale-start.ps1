param(
    [string]$PhoneIP = '',
    [switch]$NoHotReload
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$configFile = "$PSScriptRoot\phone-config.txt"

# Load saved IP
if (-not $PhoneIP -and (Test-Path $configFile)) {
    $PhoneIP = Get-Content $configFile -Raw | ForEach-Object { $_.Trim() }
}

if (-not $PhoneIP) {
    $PhoneIP = Read-Host 'Enter phone Tailscale IP (e.g. 100.x.x.x)'
    $save = Read-Host "Save this IP for next time? (y/n)"
    if ($save -eq 'y') { Set-Content -Path $configFile -Value $PhoneIP }
}

# Connect ADB
& "$PSScriptRoot\tailscale-connect.ps1" -PhoneIP $PhoneIP
if ($LASTEXITCODE -ne 0) {
    Write-Host "ADB connection failed. Exiting." -ForegroundColor Red
    exit 1
}

# Find flutter
$flutter = Get-Command flutter.bat -ErrorAction SilentlyContinue
if (-not $flutter) {
    $flutter = 'D:\Flutter stuff\flutter_windows_3.44.6-stable\flutter\bin\flutter.bat'
}

# Launch flutter run with hot reload
$hotFlag = if ($NoHotReload) { '' } else { '--hot' }
$title = "Flutter on $PhoneIP"

Start-Process powershell.exe -ArgumentList @(
    "-NoExit",
    "-NoProfile",
    "-Command `"& '$flutter' run -d ${PhoneIP}:5555 $hotFlag`"",
    "-WorkingDirectory `"$projectRoot`""
) -WindowStyle Normal -WindowStyle Maximized

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Flutter running on $PhoneIP"              -ForegroundColor Green
Write-Host "  Save a Dart file -> auto Hot Reload"       -ForegroundColor Green
Write-Host "  Type 'r' in the new window for manual"     -ForegroundColor Gray
Write-Host "  Close the window to stop"                  -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan
