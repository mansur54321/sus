# Oplus OTA Finder

Universal OTA firmware finder and downloader for **Realme**, **OnePlus**, and **OPPO** devices.

Powered by [realme-ota](https://github.com/R0rt1z2/realme-ota) by R0rt1z2.

## Features

- Brand filter: All / Realme / OnePlus / OPPO
- Search OTA updates by device model, region, and version
- Supports 20 regions (China, India, Europe, Russia, Turkey, etc.)
- Download link extraction with direct firmware URLs
- 65+ pre-configured devices with regional variants
- CSV logging with timestamps
- Interactive menu: change region, version, brand, or device without restart
- Termux Widget support (Android home screen shortcut)

## Quick Install (Linux/Windows)

```bash
bash <(curl -sL https://raw.githubusercontent.com/mansur54321/sus/main/install_ota_tool.sh)
```

After installation, restart your terminal and run:

```bash
ota
```

## Termux Install (Android)

```bash
bash <(curl -sL https://raw.githubusercontent.com/mansur54321/sus/main/termux/setup_termux.sh)
```

Add **Termux Widget** to your home screen, tap **Oplus_OTA** to launch.

## Supported Platforms

| Platform | Package Manager |
|----------|----------------|
| Debian/Ubuntu | apt |
| Arch Linux | pacman |
| Fedora | dnf |
| Termux (Android) | pkg |
| Windows (Git Bash) | python.org |

## Usage

1. Select brand filter (All / Realme / OnePlus / OPPO)
2. Select input mode (device list or manual entry)
3. Enter manifest + OTA version (e.g. `44F` = Europe, 2nd update)
4. Get OTA info: firmware, Android version, security patch, download URL

### OTA Version Codes

| Code | Version |
|------|---------|
| A | Launch version |
| C | First update |
| F | Second update |
| H | Third update |

### Region Examples

| Code | Region | Code | Region |
|------|--------|------|--------|
| 97 | China | 37 | Russia |
| 1B | India | 51 | Turkey |
| 44 | Europe | 82 | Hong Kong |
| A7 | ROW (Global) | 2C | Singapore |
| A4 | APC (Global) | 9A | LATAM |

## Supported Devices

### Realme
GT7 Pro, GT7, GT7T, GT Neo7, GT6/GT6T, GTNeo6/SE, GTNeo5, GT3, 13 Pro+, P3 Pro, P3 Ultra

### OnePlus
13/13R/13s/13T, Ace5/Ace5 Pro/Ace5V/Ace5 Racing, 12/12R, Ace3, Nord 4

### OPPO
Find X8 Pro/X8/X8 Ultra, Find N5, Reno 13 Pro

## Files

| File | Description |
|------|-------------|
| `ota_downloader.sh` | Main OTA finder script with brand filter |
| `install_ota_tool.sh` | One-click installer (Linux/Windows/Termux) |
| `devices.txt` | 65+ devices with regional variants |
| `termux/setup_termux.sh` | Automated Termux setup + widget shortcut |

## Credits

- [R0rt1z2/realme-ota](https://github.com/R0rt1z2/realme-ota) — Python library for OTA API
- Stano36 & SeRViP — Original OTA finder concept
