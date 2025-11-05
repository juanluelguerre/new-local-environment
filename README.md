# ⚙️ Setup – Windows 11 + WSL Ubuntu

Automated setup for a new development environment on **Windows 11**, including:

- Windows Features, Tools, and Apps (via `winget`)
- Oh My Posh prompt setup (Windows + WSL)
- Windows Terminal configuration
- PowerShell profile initialization
- Post-install validation using Pester

---

## 🧭 Prerequisites

Before running any script, open **PowerShell as Administrator** and allow script execution:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

---

## 🚀 Setup Steps

### 1️⃣ Run Pre-check (verify environment)

```powershell
.\setup.PreCheck.ps1
```

This script checks:
- Admin privileges 🧑‍💻  
- Required setup files 🗂️  
- Winget availability 📦  
- Windows features (WSL, Virtualization, etc.) ⚙️  

If any warning appears, follow the instructions and fix them before continuing.

---

### 2️⃣ Run main setup (Windows)

```powershell
.\setup.ps1
```

This will:
- Enable required Windows features (Containers, WSL, Hyper-V, etc.)
- Install all apps from `apps.json` using **Winget**
- Install and configure **Oh My Posh** for PowerShell
- Copy custom Windows Terminal settings and background images
- Set up PowerShell profile to auto-load your prompt theme
- Prepare **WSL Ubuntu 24.04** and configure terminal profiles

---

### 3️⃣ (Optional) Post-install validation

After setup, verify everything with:

```powershell
.\setup.PostCheck.ps1
```

This will confirm that:
- All Windows features are enabled ✅  
- All apps are installed 🧩  
- Oh My Posh and Windows Terminal are configured correctly 🖥️  

---

## 🐧 Configure Oh My Posh inside WSL Ubuntu

Once Windows setup is complete, you can also configure the same **Oh My Posh theme** inside Ubuntu running in WSL.

> This step ensures your Bash or Zsh prompt inside WSL looks identical to PowerShell.

### ▶️ Run inside WSL Ubuntu

Open **Ubuntu (24.04)** from Windows Terminal and execute:

```bash
bash /mnt/d/Software/setup/setup-omp.sh
```

This script will:
- Install Oh My Posh in `/usr/local/bin`
- Copy your theme file (`my.omp.json`) from Windows to `~/.poshthemes`
- Add the correct initialization line to your `.bashrc` or `.zshrc`
- Reload your shell automatically 🎨

After completion, your prompt inside WSL will look just like PowerShell:
```
jlgue   setup   
```

---

## 🧩 Folder Structure

```
D:\Software\setup\
│
├── apps.json
├── my.omp.json
├── setup.ps1
├── setup.PreCheck.ps1
├── setup.PostCheck.ps1
├── setup-Tests.ps1
├── setup-omp.sh          ← 🐧 Run this inside WSL Ubuntu
│
├── windows-terminal.settings.json
├── WindowsTerminal-Powershellpng.png
├── WindowsTerminal-Ubuntu.png
└── README.md
```

---

## 💡 Notes

- To re-run Oh My Posh setup in Ubuntu manually:
  ```bash
  eval "$(oh-my-posh init bash --config ~/.poshthemes/my.omp.json)"
  ```

- If you add new themes or fonts later, you can simply re-run:
  ```bash
  bash /mnt/d/Software/setup/setup-omp.sh
  ```

---

## 🧱 Post-installation tasks

After completing the environment setup, perform the following steps to restore your databases, DBeaver configuration, and Docker volumes:

### 1️⃣ Export and import your DBeaver project
- **On the old laptop:**
  - Open **DBeaver** → **File → Export → General → Archive File**.
  - Select your project (connections, drivers, etc.).
  - Save the export (e.g., `DBeaverProject.zip`) to an external folder or OneDrive.
- **On the new laptop:**
  - Open **DBeaver** → **File → Import → General → Existing Projects into Workspace**.
  - Choose the `.zip` file you exported previously.
  - Verify that all database connections appear correctly.

### 2️⃣ Backup and restore SQL Server databases
- **On the old laptop:**
  - Open **SQL Server Management Studio (SSMS)**.
  - Right-click your database → **Tasks → Back Up...** → type **Full** → save as `.bak`.
  - Copy the `.bak` file to OneDrive or external storage.
- **On the new laptop:**
  - Open **SSMS** → connect to your SQL Server instance.
  - Right-click **Databases → Restore Database...** → choose **Device → Add** → select the `.bak` file.
  - Confirm restore success and validate data.

### 3️⃣ Backup and restore Docker data volumes
- **On the old laptop:**
  - Backup your Docker volumes (e.g., `docker volume ls` and `docker inspect <volume>`).
  - Use **OneDrive** or other cloud storage to save volume directories.
- **On the new laptop:**
  - Place your `docker-compose.yml` in the working directory.
  - Run:
    ```bash
    docker compose -p nc up -d
    ```
    or to start a specific service:
    ```bash
    docker compose -p nc up <service> -d
    ```
  - Verify that data and containers are replicated correctly.

---

## 🧠 Troubleshooting

| Issue | Solution |
|-------|-----------|
| `ExecutionPolicy` error | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force` |
| WSL not found | Enable features: `Microsoft-Windows-Subsystem-Linux` and `VirtualMachinePlatform` |
| Ubuntu not detected | Run `wsl --install -d Ubuntu-24.04` |
| PowerShell prompt shows `CONFIG ERROR` | Ensure `my.omp.json` exists in `Documents` and is valid JSON |
| Ubuntu prompt not themed | Re-run `setup-omp.sh` from inside WSL |

---

🎉 **Done!**  
Your PowerShell, WSL, databases, and Docker environment are now synchronized — a complete, developer-ready setup.
