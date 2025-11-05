
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