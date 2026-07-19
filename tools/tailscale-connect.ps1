param(
    [string]$PhoneIP = ''
)

$sdkRoot = $env:ANDROID_SDK_ROOT
if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_HOME }
if (-not $sdkRoot) { $sdkRoot = 'C:\Users\Admin\AppData\Local\Android\Sdk' }

$adb = "$sdkRoot\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { throw "adb not found at $adb" }

if (-not $PhoneIP) {
    $PhoneIP = Read-Host 'Enter phone Tailscale IP (e.g. 100.x.x.x)'
}

# Remove stale connection first
& $adb disconnect $PhoneIP
Start-Sleep -Seconds 1

# Connect via Tailscale
Write-Host "Connecting to $PhoneIP`:5555 ..." -ForegroundColor Cyan
& $adb connect "${PhoneIP}:5555"

$devices = & $adb devices
if ($devices -match "${PhoneIP}:5555.*device") {
    Write-Host "Connected OK. Device: ${PhoneIP}:5555" -ForegroundColor Green
} else {
    Write-Host "FAILED. Make sure:" -ForegroundColor Red
    Write-Host "  1. Phone is on Tailscale (same tailnet)" -ForegroundColor Yellow
    Write-Host "  2. Phone has ADB TCP enabled (adb tcpip 5555)" -ForegroundColor Yellow
    Write-Host "  3. Phone battery optimization is OFF for Tailscale" -ForegroundColor Yellow
    exit 1
}
