#!/bin/bash

GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

OTA_DOWNLOADER_URL="https://raw.githubusercontent.com/mansur54321/sus/refs/heads/main/ota_downloader.sh"
DEVICES_FILE_URL="https://raw.githubusercontent.com/mansur54321/sus/refs/heads/main/devices.txt"
REALME_OTA_REPO="https://github.com/R0rt1z2/realme-ota.git"
REPO_URL="https://github.com/mansur54321/sus"

print_message() { echo -e "${GREEN}[INFO] $1${RESET}"; }
print_error() { echo -e "${RED}[ERROR] $1${RESET}"; }
print_warning() { echo -e "${YELLOW}[WARN] $1${RESET}"; }

install_debian() {
    print_message "Debian-based detected. Installing dependencies..."
    sudo apt update && sudo apt install python3 python3-pip python3-venv git curl -y
    PYTHON_CMD="python3"
}

install_arch() {
    print_message "Arch-based detected. Installing dependencies..."
    sudo pacman -Syu --noconfirm
    sudo pacman -S python python-pip git curl --noconfirm
    PYTHON_CMD="python"
}

install_fedora() {
    print_message "Fedora-based detected. Installing dependencies..."
    sudo dnf check-update
    sudo dnf install python3 python3-pip git curl -y
    PYTHON_CMD="python3"
}

install_termux() {
    print_message "Termux detected. Installing dependencies..."
    pkg update && pkg upgrade -y
    pkg install python python-pip git curl -y
    PYTHON_CMD="python"
}

install_windows() {
    print_message "Git Bash (Windows) detected. Checking dependencies..."
    PYTHON_CMD="python"
    if ! command -v python &> /dev/null; then
        print_error "Python not found! Install from python.org (check 'Add Python to PATH')"
        exit 1
    fi
    print_message "Python found."
    if ! command -v git &> /dev/null; then
        print_error "Git not found! Reinstall Git for Windows."
        exit 1
    fi
    print_message "Git found."
    if ! command -v curl &> /dev/null; then
        print_error "cURL not found! Reinstall Git for Windows with cURL component."
        exit 1
    fi
    print_message "cURL found."
}

OS=""
PYTHON_CMD="python3"

if [[ "$(uname -o)" == "Msys" ]]; then
    OS="windows"
elif [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    if [[ "$ID_LIKE" == *"termux"* ]]; then OS="termux"; fi
elif [ -d "/data/data/com.termux" ]; then
    OS="termux"
else
    print_error "Cannot detect OS. Exiting."
    exit 1
fi

case "$OS" in
    "debian" | "ubuntu") install_debian ;;
    "arch") install_arch ;;
    "fedora") install_fedora ;;
    "termux") install_termux ;;
    "windows") install_windows ;;
    *) print_error "Unsupported system: $OS. Exiting."; exit 1 ;;
esac

VENV_ACTIVATE_PATH="venv/bin/activate"
if [ "$OS" == "windows" ]; then
    VENV_ACTIVATE_PATH="venv/Scripts/activate"
fi

INSTALL_DIR="$HOME/oplus-ota"
if [ -d "$INSTALL_DIR" ]; then
    print_warning "Directory '$INSTALL_DIR' already exists."
    read -p "$(echo -e "${YELLOW}Update (u), reinstall (r), or skip (s)? [u/r/s]: ${RESET}")" choice
    case "$choice" in
        u|U)
            print_message "Updating..."
            cd "$INSTALL_DIR" || { print_error "Cannot cd. Exiting."; exit 1; }
            git pull || { print_error "git pull failed."; exit 1; }
            ;;
        r|R)
            print_warning "Removing '$INSTALL_DIR'..."
            rm -rf "$INSTALL_DIR" || { print_error "Cannot remove. Check permissions."; exit 1; }
            print_message "Cloning fresh..."
            git clone "$REALME_OTA_REPO" "$INSTALL_DIR" || { print_error "Clone failed. Exiting."; exit 1; }
            cd "$INSTALL_DIR" || { print_error "Cannot cd. Exiting."; exit 1; }
            ;;
        *)
            print_message "Skipping clone. Using existing directory."
            cd "$INSTALL_DIR" || { print_error "Cannot cd. Exiting."; exit 1; }
            ;;
    esac
else
    print_message "Cloning realme-ota to $INSTALL_DIR..."
    git clone "$REALME_OTA_REPO" "$INSTALL_DIR" || { print_error "Clone failed. Exiting."; exit 1; }
    cd "$INSTALL_DIR" || { print_error "Cannot cd. Exiting."; exit 1; }
fi

print_message "Setting up Python venv..."
$PYTHON_CMD -m venv venv
source "$VENV_ACTIVATE_PATH"

print_message "Installing realme-ota package..."
pip install . || {
    print_warning "Normal install failed. Trying with --break-system-packages..."
    pip install . --break-system-packages || { print_error "Package install failed. Exiting."; exit 1; }
}
deactivate

print_message "Downloading ota_downloader.sh..."
curl -L -o ota_downloader.sh "$OTA_DOWNLOADER_URL" || { print_error "Download failed. Exiting."; exit 1; }
chmod +x ota_downloader.sh

print_message "Downloading devices.txt..."
curl -L -o devices.txt "$DEVICES_FILE_URL" || { print_error "Download failed. Exiting."; exit 1; }

print_message "Setting up 'ota' alias in ~/.bashrc..."
sed -i.bak "/alias ota=/d" ~/.bashrc
echo "alias ota='cd \"$INSTALL_DIR\" && source \"$VENV_ACTIVATE_PATH\" && bash ota_downloader.sh'" >> ~/.bashrc

if [ -f ~/.zshrc ]; then
    sed -i.bak "/alias ota=/d" ~/.zshrc
    echo "alias ota='cd \"$INSTALL_DIR\" && source \"$VENV_ACTIVATE_PATH\" && bash ota_downloader.sh'" >> ~/.zshrc
fi

echo -e "\n${BLUE}Installation complete!${RESET}"
print_message "Restart your terminal or run:"
print_message "${YELLOW}source ~/.bashrc${RESET}"
print_message "Then type ${YELLOW}ota${RESET} to launch."
print_message "Repo: $REPO_URL"
