#!/usr/bin/env bash
# ==========================================================
#  🚀 Setup Oh My Posh in WSL (Ubuntu)
#  Author: Juanlu
#  Description: Installs Oh My Posh in WSL Ubuntu, copies theme,
#               and configures Bash or Zsh automatically.
# ==========================================================

set -e  # Stop on first error

echo ""
echo "🐧 Configuring Oh My Posh inside WSL Ubuntu..."
echo "-----------------------------------------------"

# 1️⃣ Install Oh My Posh binary
if ! command -v oh-my-posh &>/dev/null; then
  echo "📦 Installing Oh My Posh..."
  sudo wget -q https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
  sudo chmod +x /usr/local/bin/oh-my-posh
  echo "✅ Oh My Posh installed successfully."
else
  echo "🟢 Oh My Posh already installed."
fi

# 2️⃣ Create theme directory
echo ""
echo "📂 Creating theme directory..."
mkdir -p ~/.poshthemes

# 3️⃣ Copy theme file from Windows (adjust path if needed)
# Example: your setup folder is D:\Software\setup
if [ -f /mnt/d/Software/setup/my.omp.json ]; then
  echo "📁 Copying theme file..."
  cp /mnt/d/Software/setup/my.omp.json ~/.poshthemes/my.omp.json
else
  echo "⚠️ Could not find /mnt/d/Software/setup/my.omp.json"
  echo "👉 Please verify the Windows path and re-run this script."
  exit 1
fi

# 4️⃣ Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
echo ""
echo "🧩 Detected shell: $CURRENT_SHELL"

# 5️⃣ Configure Oh My Posh in shell config
if [ "$CURRENT_SHELL" = "zsh" ]; then
  CONFIG_FILE="$HOME/.zshrc"
  INIT_CMD='eval "$(oh-my-posh init zsh --config ~/.poshthemes/my.omp.json)"'
else
  CONFIG_FILE="$HOME/.bashrc"
  INIT_CMD='eval "$(oh-my-posh init bash --config ~/.poshthemes/my.omp.json)"'
fi

# 6️⃣ Add init command if not already present
if grep -q "oh-my-posh init" "$CONFIG_FILE"; then
  echo "🟡 Oh My Posh already configured in $CONFIG_FILE"
else
  echo "⚙️ Adding Oh My Posh init line to $CONFIG_FILE..."
  echo "" >> "$CONFIG_FILE"
  echo "# >>> Oh My Posh Configuration >>>" >> "$CONFIG_FILE"
  echo "$INIT_CMD" >> "$CONFIG_FILE"
  echo "# <<< Oh My Posh Configuration <<<" >> "$CONFIG_FILE"
  echo "✅ Configuration added to $CONFIG_FILE"
fi

# 7️⃣ Reload shell
echo ""
echo "🔁 Reloading shell..."
if [ "$CURRENT_SHELL" = "zsh" ]; then
  exec zsh
else
  exec bash
fi

echo ""
echo "🎉 Oh My Posh is now configured inside WSL Ubuntu!"
echo "--------------------------------------------------"
oh-my-posh --version
