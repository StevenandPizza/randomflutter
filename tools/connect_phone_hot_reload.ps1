param(
    [string]$PairingAddress = '',
    [string]$PairingCode = '',
    [string]$DeviceAddress = ''
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$sdkRoot = $env:ANDROID_SDK_ROOT
if (-not $sdkRoot) {
    $sdkRoot = $env:ANDROID_HOME
}
if (-not $sdkRoot) {
    $sdkRoot = 'C:\Users\Admin\AppData\Local\Android\Sdk'
}

$adbPath = Join-Path $sdkRoot 'platform-tools\adb.exe'
if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "adb not found: $adbPath"
}

if (-not $PairingAddress) {
    $PairingAddress = Read-Host 'Enter the pairing IP:port shown on the phone'
}
if (-not $PairingCode) {
    $PairingCode = Read-Host 'Enter the six-digit pairing code'
}
if (-not $DeviceAddress) {
    $DeviceAddress = Read-Host 'Enter the Wireless debugging IP:port'
}

Write-Host "Pairing with $PairingAddress..."
& $adbPath pair $PairingAddress $PairingCode
if ($LASTEXITCODE -ne 0) {
    throw 'adb pairing failed. Keep Wireless debugging open and check the address/code.'
}

Write-Host "Connecting to $DeviceAddress..."
& $adbPath connect $DeviceAddress
if ($LASTEXITCODE -ne 0) {
    throw 'adb connection failed. Check that the phone and PC use the same Wi-Fi.'
}

$hotReloadScript = Join-Path $PSScriptRoot 'run_phone_hot_reload.ps1'
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $hotReloadScript -DeviceId $DeviceAddress
