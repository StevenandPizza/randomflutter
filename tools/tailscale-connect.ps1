param(
    [string]$PhoneIP = '',
    [string]$DebugPort = ''
)

$sdkRoot = $env:ANDROID_SDK_ROOT
if (-not $sdkRoot) { $sdkRoot = $env:ANDROID_HOME }
if (-not $sdkRoot) { $sdkRoot = 'C:\Users\Admin\AppData\Local\Android\Sdk' }

$adb = "$sdkRoot\platform-tools\adb.exe"
if (-not (Test-Path $adb)) { throw "adb not found at $adb" }

if (-not $PhoneIP) {
    $PhoneIP = Read-Host 'Enter phone Tailscale IP (e.g. 100.x.x.x)'
}

$configFile = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = "$configFile\phone-config.txt"

# Load saved port
$savedPort = ''
if (Test-Path $configFile) {
    $lines = Get-Content $configFile
    if ($lines.Count -ge 2) { $savedPort = $lines[1].Trim() }
}

$port = if ($DebugPort) { $DebugPort } else { $savedPort }
if (-not $port) {
    $port = Read-Host "Enter Wireless Debugging port (e.g. 39675)"
}

Write-Host "Connecting to ${PhoneIP}:${port} ..." -ForegroundColor Cyan

# Remove stale
& $adb disconnect "${PhoneIP}:${port}" 2>$null

& $adb connect "${PhoneIP}:${port}"
if ($LASTEXITCODE -ne 0 -or -not (& $adb devices) -match "${PhoneIP}:${port}.*device") {
    Write-Host "FAILED. Check:" -ForegroundColor Red
    Write-Host "  - Phone: Developer options > Wireless debugging ON" -ForegroundColor Yellow
    Write-Host "  - Phone Tailscale: connected, battery optimization OFF" -ForegroundColor Yellow
    Write-Host "  - Port matches the one shown in Wireless debugging" -ForegroundColor Yellow
    exit 1
}

# Save IP + port
Set-Content -Path $configFile -Value "${PhoneIP}`r`n${port}"

Write-Host "Connected OK. ${PhoneIP}:${port}" -ForegroundColor Green
