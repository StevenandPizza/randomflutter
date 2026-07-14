param(
    [string]$DeviceId = ''
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$flutterCommand = Get-Command flutter.bat -ErrorAction SilentlyContinue

if ($flutterCommand) {
    $flutterPath = $flutterCommand.Source
} else {
    $flutterPath = 'D:\Flutter stuff\flutter_windows_3.44.6-stable\flutter\bin\flutter.bat'
}

if (-not (Test-Path -LiteralPath $flutterPath)) {
    throw "Flutter SDK not found: $flutterPath"
}

$commandLine = '"' + $flutterPath + '" run --hot'
if ($DeviceId) {
    $commandLine += ' -d "' + $DeviceId + '"'
}

$startInfo = New-Object System.Diagnostics.ProcessStartInfo
$startInfo.FileName = $env:ComSpec
$startInfo.Arguments = '/d /s /c "' + $commandLine + '"'
$startInfo.WorkingDirectory = $projectRoot
$startInfo.UseShellExecute = $false
$startInfo.RedirectStandardInput = $true

$flutterProcess = New-Object System.Diagnostics.Process
$flutterProcess.StartInfo = $startInfo
[void]$flutterProcess.Start()

$libPath = Join-Path $projectRoot 'lib'
$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $libPath
$watcher.Filter = '*.dart'
$watcher.IncludeSubdirectories = $true
$watcher.NotifyFilter = [System.IO.NotifyFilters]::LastWrite

$script:lastReload = [DateTime]::MinValue
$reloadAction = {
    $now = [DateTime]::Now
    if (($now - $script:lastReload).TotalMilliseconds -lt 500) {
        return
    }
    $script:lastReload = $now
    Start-Sleep -Milliseconds 250
    if (-not $flutterProcess.HasExited) {
        $flutterProcess.StandardInput.WriteLine('r')
        $flutterProcess.StandardInput.Flush()
    }
}

$subscription = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $reloadAction
$watcher.EnableRaisingEvents = $true

try {
    Write-Host 'Flutter is running on the phone. Save a Dart file to hot reload.'
    while (-not $flutterProcess.HasExited) {
        Wait-Event -Timeout 1 | Out-Null
    }
} finally {
    Unregister-Event -SubscriptionId $subscription.Id -ErrorAction SilentlyContinue
    $watcher.Dispose()
    $flutterProcess.Dispose()
}
