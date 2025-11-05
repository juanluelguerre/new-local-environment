<#
.SYNOPSIS
    💻 Juanlu One-Click Dev Setup
.DESCRIPTION
    Enables required Windows features, installs developer tools via Winget,
    configures WSL Ubuntu 25.10, Oh My Posh, and Windows Terminal.
#>

# -------------------------------
# 1️⃣ Auto-elevate to Administrator
# -------------------------------
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $IsAdmin) {
    Write-Host "👑 Requesting administrator privileges..."
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "pwsh.exe"
    $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $psi.Verb = "runas"
    try {
        [System.Diagnostics.Process]::Start($psi) | Out-Null
    } catch {
        Write-Host "❌ User declined elevation. Cannot continue." -ForegroundColor Red
    }
    exit
}

# -------------------------------
# 2️⃣ Allow temporary script execution
# -------------------------------
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force | Out-Null
Write-Host "`n🚀 Starting Juanlu Dev Environment Setup..." -ForegroundColor Cyan

# -------------------------------
# 3️⃣ Enable required Windows features
# -------------------------------
Write-Host "`n⚙️ Enabling Windows features..." -ForegroundColor Yellow

$features = @(
    "Microsoft-Hyper-V-All",
    "Microsoft-Hyper-V-Hypervisor",
    "Microsoft-Hyper-V-Services",
    "Microsoft-Hyper-V-Management-PowerShell",
    "Containers",
    "VirtualMachinePlatform",
    "Microsoft-Windows-Subsystem-Linux",
    "Microsoft-Windows-Hypervisor-Platform",
    "IIS-WebServerRole",
    "IIS-WebServer",
    "IIS-HostableWebCore",
    "TelnetClient"
)

foreach ($f in $features) {
    Write-Host "🔧 Enabling feature: $f"
    dism.exe /online /enable-feature /featurename:$f /all /norestart | Out-Null
}

Write-Host "✅ Windows features processed." -ForegroundColor Green

# -------------------------------
# 4️⃣ Install apps via Winget
# -------------------------------
Write-Host "`n📦 Installing applications from apps.json..." -ForegroundColor Yellow
if (Test-Path "$PSScriptRoot\apps.json") {
    winget import -i "$PSScriptRoot\apps.json" --accept-source-agreements --accept-package-agreements
    Write-Host "✅ Apps installation completed." -ForegroundColor Green
} else {
    Write-Host "⚠️ apps.json not found, skipping app installation." -ForegroundColor DarkYellow
}

# -------------------------------
# 5️⃣ Install and configure WSL Ubuntu 24.04
# -------------------------------
Write-Host "`n🐧 Installing WSL Ubuntu 24.04..." -ForegroundColor Yellow
try {
    wsl --install -d Ubuntu-24.04
    Write-Host "✅ Ubuntu 24.04 installation initiated." -ForegroundColor Green
} catch {
    Write-Host "⚠️ WSL or Ubuntu already installed, skipping." -ForegroundColor DarkYellow
}

# -------------------------------
# 6️⃣.1 Install CascadiaCode Nerd Font
# -------------------------------
Write-Host "`n🔤 Installing CascadiaCode Nerd Font..." -ForegroundColor Yellow

$fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip"
$fontZip = "$env:TEMP\CascadiaCode.zip"
$fontExtractPath = "$env:TEMP\CascadiaCodeFont"

try {
    # Download
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip -UseBasicParsing
    Write-Host "📥 Downloaded CascadiaCode Nerd Font package."

    # Extract
    Expand-Archive -Path $fontZip -DestinationPath $fontExtractPath -Force
    Write-Host "📦 Extracted font files."

    # Install all .ttf fonts
    $fonts = Get-ChildItem -Path $fontExtractPath -Filter "*.ttf" -Recurse
    foreach ($font in $fonts) {
        Write-Host "🪶 Installing font: $($font.Name)"
        Copy-Item $font.FullName -Destination "C:\Windows\Fonts" -Force
        # Register font in the system
        $fontRegKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontName = [System.IO.Path]::GetFileNameWithoutExtension($font.Name)
        Set-ItemProperty -Path $fontRegKey -Name $fontName -Value $font.Name -Force
    }

    Write-Host "✅ CascadiaCode Nerd Font installed successfully." -ForegroundColor Green
}
catch {
    Write-Host "⚠️ Failed to install CascadiaCode Nerd Font: $($_.Exception.Message)" -ForegroundColor DarkYellow
}
finally {
    # Cleanup
    Remove-Item $fontZip -ErrorAction SilentlyContinue
    Remove-Item $fontExtractPath -Recurse -ErrorAction SilentlyContinue
}

# -------------------------------
# 7️⃣ Copy Windows Terminal config and backgrounds
# -------------------------------
Write-Host "`n🪟 Updating Windows Terminal configuration..." -ForegroundColor Yellow
try {
    $localState = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    Copy-Item "$PSScriptRoot\windows-terminal.settings.json" "$localState\settings.json" -Force
    Copy-Item "$PSScriptRoot\WindowsTerminal-Powershellpng.png" "$env:USERPROFILE\Documents\" -Force
    Copy-Item "$PSScriptRoot\WindowsTerminal-Ubuntu.png" "$env:USERPROFILE\Documents\" -Force
    Write-Host "✅ Windows Terminal configuration updated." -ForegroundColor Green
} catch {
    Write-Host "⚠️ Could not update Windows Terminal configuration." -ForegroundColor DarkYellow
}

# -------------------------------
# 8️⃣ Configure PowerShell profile for Oh My Posh
# -------------------------------
Write-Host "`n⚙️ Configuring PowerShell profile for Oh My Posh..." -ForegroundColor Yellow

try {
    # Determine PowerShell 7+ profile path
    $profileDir = Split-Path -Parent $PROFILE
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        Write-Host "📂 Created profile directory: $profileDir"
    }

    if (-not (Test-Path $PROFILE)) {
        New-Item -ItemType File -Path $PROFILE -Force | Out-Null
        Write-Host "🧾 Created PowerShell profile file: $PROFILE"
    }

    # Define Oh My Posh initialization line
    $ompConfigPath = "$env:USERPROFILE\Documents\my.omp.json"
    $ompInit = "oh-my-posh init pwsh --config `"$ompConfigPath`" | Invoke-Expression"

    # Check if line already exists
    $profileContent = Get-Content $PROFILE -ErrorAction SilentlyContinue
    if ($profileContent -notmatch "oh-my-posh init pwsh") {
        Add-Content -Path $PROFILE -Value "`n$ompInit"
        Write-Host "✅ Added Oh My Posh initialization to PowerShell profile." -ForegroundColor Green
    }
    else {
        Write-Host "🟡 Oh My Posh line already present in profile." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "⚠️ Failed to configure PowerShell profile: $($_.Exception.Message)" -ForegroundColor DarkYellow
}

# -------------------------------
# 9 Final message
# -------------------------------
Write-Host ""
Write-Host "--------------------------------------"
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host "You can now launch your terminal and start developing!" -ForegroundColor Cyan
Write-Host "--------------------------------------"
Write-Host ""
