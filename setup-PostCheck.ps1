<#
.SYNOPSIS
    🧩 Juanlu Post-Install Validation
.DESCRIPTION
    Ensures Pester is up to date, auto-fixes missing items,
    and runs final environment validation tests.
#>

# =========================================================
# 1️⃣  Ensure Pester is installed and up to date
# =========================================================
Write-Host "`n🧪 Checking Pester module..." -ForegroundColor Yellow
try {
    $pesterModule = Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1
    if (-not $pesterModule -or [version]$pesterModule.Version -lt [version]"5.0.0") {
        Write-Host "⚙️ Installing or updating Pester to latest version..." -ForegroundColor Yellow
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null
        Install-Module -Name Pester -Force -SkipPublisherCheck -AllowClobber
        $pesterModule = Get-Module -ListAvailable Pester | Sort-Object Version -Descending | Select-Object -First 1
        Write-Host "✅ Installed Pester v$($pesterModule.Version)" -ForegroundColor Green
    }
    else {
        Write-Host "✅ Pester v$($pesterModule.Version) already installed." -ForegroundColor Green
    }
}
catch {
    Write-Host "⚠️ Could not install or update Pester: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# =========================================================
# 2️⃣  Auto-fix missing WSL distro and terminal assets
# =========================================================
Write-Host "`n🐧 Checking Ubuntu distro..." -ForegroundColor Yellow
$distros = wsl --list --quiet 2>$null
if (-not ($distros -match "Ubuntu")) {
    Write-Host "↻ Installing Ubuntu-24.04 LTS..." -ForegroundColor Yellow
    try {
        wsl --install -d Ubuntu-24.04
        Write-Host "✅ Ubuntu-24.04 LTS installed." -ForegroundColor Green
    } catch {
        Write-Host "⚠️ Could not install Ubuntu automatically: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "✅ Ubuntu distro already present." -ForegroundColor Green
}

Write-Host "`n🖼️ Checking Windows Terminal background images..." -ForegroundColor Yellow
$docs = [Environment]::GetFolderPath("MyDocuments")
$requiredImages = @(
    "WindowsTerminal-Powershellpng.png",
    "WindowsTerminal-Ubuntu.png"
)
foreach ($img in $requiredImages) {
    $src = Join-Path $PSScriptRoot $img
    $dst = Join-Path $docs $img
    if (-not (Test-Path $dst)) {
        if (Test-Path $src) {
            Copy-Item $src $dst -Force
            Write-Host "✅ Copied $img to Documents." -ForegroundColor Green
        } else {
            Write-Host "⚠️ Missing source image: $img" -ForegroundColor DarkYellow
        }
    } else {
        Write-Host "🖼️ $img already exists." -ForegroundColor Green
    }
}

# =========================================================
# 3️⃣  Run final validation tests with Pester
# =========================================================
Write-Host "`n🚦 Running post-installation validation tests..." -ForegroundColor Cyan

$testScript = Join-Path $PSScriptRoot "setup.PreCheck.ps1"
if (Test-Path $testScript) {
    try {
        Import-Module Pester -ErrorAction Stop
        Invoke-Pester -Path $testScript -Output Detailed
    } catch {
        Write-Host "⚠️ Failed to run Pester tests: $($_.Exception.Message)" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "⚠️ Test script not found: setup.PreCheck.ps1" -ForegroundColor DarkYellow
}

# =========================================================
# 4️⃣  Final summary
# =========================================================
Write-Host ""
Write-Host "--------------------------------------"
Write-Host "🎉 Post-installation validation complete!" -ForegroundColor Green
Write-Host "Review the Pester report above for details." -ForegroundColor Cyan
Write-Host "--------------------------------------"
Write-Host ""
