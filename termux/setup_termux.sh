#!/bin/bash

GITHUB_RAW_URL_OTA="https://raw.githubusercontent.com/mansur54321/oplus_ota/refs/heads/main/ota_downloader.sh"
GITHUB_RAW_URL_DEVICES="https://raw.githubusercontent.com/mansur54321/oplus_ota/refs/heads/main/devices.txt"
REALME_OTA_REPO="https://github.com/R0rt1z2/realme-ota.git"

LOG="$HOME/termux_setup.log"
exec > >(tee -a "$LOG") 2>&1

echo -e "\n=== [ $(date) ] Starting automated Termux setup ==="

function check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Installing '$1'..."
        pkg install -y "$1" || { echo "Failed to install $1. Aborting."; exit 1; }
    fi
}

check_command curl
check_command termux-api

echo -e "\nRequesting storage permissions..."
termux-setup-storage
sleep 2

OTA_DIR="$HOME/oplus-ota"
if [ -d "$OTA_DIR" ]; then
    echo "Directory '$OTA_DIR' already exists. Updating..."
    cd "$OTA_DIR" || { echo "Cannot cd. Aborting."; exit 1; }
    git pull 2>/dev/null || true
else
    echo -e "\nCloning realme-ota..."
    git clone "$REALME_OTA_REPO" "$OTA_DIR" || { echo "Clone failed. Aborting."; exit 1; }
    cd "$OTA_DIR" || { echo "Cannot cd. Aborting."; exit 1; }
fi

echo -e "\nSetting up Python venv..."
pkg install python python-pip -y 2>/dev/null
python -m venv venv
source venv/bin/activate
pip install . 2>/dev/null || pip install . --break-system-packages
deactivate

echo -e "\nDownloading ota_downloader.sh..."
curl -fsSL "$GITHUB_RAW_URL_OTA" -o "$OTA_DIR/ota_downloader.sh" || { echo "Download failed."; exit 1; }
chmod +x "$OTA_DIR/ota_downloader.sh"

echo -e "\nDownloading devices.txt..."
curl -fsSL "$GITHUB_RAW_URL_DEVICES" -o "$OTA_DIR/devices.txt" || { echo "Download failed."; exit 1; }

SHORTCUTS_DIR="$HOME/.shortcuts"
echo -e "\nCreating .shortcuts directory..."
mkdir -p "$SHORTCUTS_DIR"
chmod 700 -R "$SHORTCUTS_DIR"

cat > "$SHORTCUTS_DIR/Oplus_OTA" << 'SHORTCUT'
#!/bin/bash
cd "$HOME/oplus-ota" || exit 1
source venv/bin/activate
bash ota_downloader.sh
SHORTCUT
chmod +x "$SHORTCUTS_DIR/Oplus_OTA"

echo -e "\nSetup completed!"
echo "Add Termux Widget to your home screen and tap 'Oplus_OTA' to launch."
echo "Or run: cd ~/oplus-ota && source venv/bin/activate && bash ota_downloader.sh"
echo "Log: $LOG"
