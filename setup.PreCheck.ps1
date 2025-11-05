<#
.SYNOPSIS
    Pre-check before running setup.ps1
.DESCRIPTION
    Ensures admin privileges, allows temporary script execution,
    and validates prerequisites before installation.
#>

# -------------------------------
# 1ï¸âƒ£ Auto-elevate to Administrator
# -------------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Host "Requesting administrator privileges..."
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "pwsh.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Host "User declined elevation. Cannot continue." -ForegroundColor Red
    }
    exit
}

# -------------------------------
# 2ï¸âƒ£ Allow temporary script execution
# -------------------------------
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null

Write-Host ""
Write-Host "Running pre-install checks..." -ForegroundColor Cyan
$errors = 0

# -------------------------------
# 3ï¸âƒ£ Check required files
# -------------------------------
Write-Host ""
Write-Host "Checking required files..."
$requiredFiles = @(
    "setup.ps1",
    "apps.json",
    "my.omp.json",
    "windows-terminal.settings.json",
    "WindowsTerminal-Powershellpng.png",
    "WindowsTerminal-Ubuntu.png"
)
foreach ($file in $requiredFiles) {
    $path = Join-Path $PSScriptRoot $file
    if (Test-Path $path) {
        Write-Host "  [+] Found $file"
    } else {
        Write-Host "  [!] Missing $file" -ForegroundColor Yellow
        $errors++
    }
}

# -------------------------------
# 4ï¸âƒ£ Winget
# -------------------------------
Write-Host ""
Write-Host "Checking Winget..."
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "  [+] Winget is installed."
} else {
    Write-Host "  [x] Winget not found. Please install 'App Installer' from Microsoft Store." -ForegroundColor Red
    $errors++
}

# -------------------------------
# 5️⃣ 🐧 WSL
# -------------------------------
Write-Host ""
Write-Host "Checking Windows Subsystem for Linux (WSL)..."

if (Get-Command wsl.exe -ErrorAction SilentlyContinue) {
    try {
        $wslStatus = wsl --status 2>$null
        if ($wslStatus -match "Default Version") {
            Write-Host "  [+] WSL is installed and working."
        } else {
            Write-Host "  [!] WSL command found, but no distributions registered." -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  [!] WSL is installed but could not retrieve status." -ForegroundColor Yellow
        $errors++
    }
} else {
    Write-Host "  [x] WSL not found or feature disabled." -ForegroundColor Red
    $errors++
}

# -------------------------------
# 6ï¸âƒ£ Windows Features
# -------------------------------
Write-Host ""
Write-Host "Checking key Windows features..."
$features = @("VirtualMachinePlatform", "Microsoft-Windows-Subsystem-Linux")
foreach ($f in $features) {
    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $f -ErrorAction Stop
        if ($feature.State -eq "Enabled") {
            Write-Host "  [+] Feature '$f' enabled."
        } else {
            Write-Host "  [!] Feature '$f' disabled." -ForegroundColor Yellow
            $errors++
        }
    } catch {
        Write-Host "  [!] Unable to check feature '$f' (requires admin)." -ForegroundColor Yellow
        $errors++
    }
}

# -------------------------------
# 7ï¸âƒ£ Admin privileges confirmation
# -------------------------------
Write-Host ""
Write-Host "Checking admin privileges..."
if ($IsAdmin) {
    Write-Host "  [+] Running as Administrator." -ForegroundColor Green
} else {
    Write-Host "  [x] Not running as Administrator." -ForegroundColor Red
    $errors++
}

# -------------------------------
# 8ï¸âƒ£ Summary
# -------------------------------
Write-Host ""
Write-Host "--------------------------------------"
if ($errors -eq 0) {
    Write-Host "All checks passed. You can safely run setup.ps1." -ForegroundColor Green
} else {
    Write-Host ("Found {0} issue(s). Please fix them before running setup.ps1." -f $errors) -ForegroundColor Yellow
}
Write-Host "--------------------------------------"
Write-Host ""
