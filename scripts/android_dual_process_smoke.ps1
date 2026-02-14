param(
    [string]$PackageName = "com.follow.clash.dev",
    [int]$WaitSeconds = 3
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Run-Adb([string]$Cmd) {
    Write-Host "adb $Cmd"
    & adb $Cmd
}

function Get-Pid([string]$ProcessName) {
    $procPid = (& adb shell pidof $ProcessName 2>$null)
    if ([string]::IsNullOrWhiteSpace($procPid)) { return "" }
    return $procPid.Trim()
}

Write-Host "== Dual-process smoke test =="
Write-Host "Package: $PackageName"
Write-Host ""

Write-Host "[1] Check device connectivity"
Run-Adb "devices"

Write-Host "[2] Process snapshot before kill"
$uiPidBefore = Get-Pid $PackageName
$corePidBefore = Get-Pid "$PackageName`:core"
Write-Host "UI pid   : $uiPidBefore"
Write-Host "Core pid : $corePidBefore"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($corePidBefore)) {
    Write-Host "Core process is not running. Start VPN/proxy in app first, then rerun." -ForegroundColor Yellow
    exit 1
}

Write-Host "[3] Kill UI process only"
Run-Adb "shell am kill $PackageName"
Start-Sleep -Seconds $WaitSeconds

Write-Host "[4] Process snapshot after UI kill"
$uiPidAfter = Get-Pid $PackageName
$corePidAfter = Get-Pid "$PackageName`:core"
Write-Host "UI pid   : $uiPidAfter"
Write-Host "Core pid : $corePidAfter"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($corePidAfter)) {
    Write-Host "FAIL: core process died after UI kill." -ForegroundColor Red
    exit 2
}

Write-Host "[5] Verify service record"
Run-Adb "shell dumpsys activity services $PackageName | findstr /I /C:VpnService /C:CommonService /C:CoreServiceHost"

Write-Host ""
Write-Host "PASS: core process survived UI kill (pid $corePidAfter)." -ForegroundColor Green
Write-Host "Next: relaunch app manually and verify node switching/status callbacks."
