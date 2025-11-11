# Fix-WakeIssues.ps1
# Run this script as Administrator on Windows 11

Write-Output "=== Disabling devices that are allowed to wake the system ==="

# List of devices we identified:
$devices = @(
    "USB4 Root Router (1.0)",
    "USB4 Root Router (1.0) (001)",
    "Realtek USB GbE Family Controller"
)

foreach ($d in $devices) {
    Write-Output "Disabling wake permission for device: $d"
    Try {
        powercfg /devicedisablewake "`"$d`"" | Out-Null
        Write-Output "OK: $d"
    }
    Catch {
        Write-Output "Error disabling $d : $_"
    }
}

Write-Output "=== Checking that no devices remain armed to wake ==="
powercfg /devicequery wake_armed

Write-Output "=== Checking active wake timers ==="
powercfg /waketimers

Write-Output "=== Generating a quick energy report (60 seconds) ==="
powercfg /energy /output ".\energyReport.html" /duration 60

Write-Output "=== Generating a SleepStudy report (3 days) ==="
powercfg /sleepstudy /output ".\sleepStudyReport.html" /duration 3

Write-Output "=== Done. Please review the reports in the current directory. ==="
Pause
