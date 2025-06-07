# brew-up

🍺 **Comprehensive Homebrew Automation Tools** 🚀

This repository contains two powerful tools for managing Homebrew packages and analyzing your system's applications:

1. **`install_brew_apps.sh`** - Automated brew package installation script
2. **`brew_scanner.py`** - Interactive application scanner and brew equivalent finder

## Features

### 🔧 Installation Script (`install_brew_apps.sh`)

- **Cross-Platform Support**: Works on both macOS and Linux
- **Automatic Homebrew Installation**: Installs Homebrew if not present
- **Comprehensive Package Lists**: Includes formulae (CLI tools) and casks (GUI apps)
- **Error Handling**: Robust error handling with detailed logging
- **Colorful Output**: ADHD-friendly UI with emojis and colors
- **Progress Tracking**: Real-time installation progress with success/failure tracking

### 🔍 Brew Scanner (`brew_scanner.py`)

- **Interactive CLI**: Arrow key navigation with colorful, emoji-rich interface
- **Application Discovery**: Automatically finds all installed applications
- **Brew Equivalent Detection**: Identifies non-brew apps that have brew equivalents
- **Multiple View Modes**: Browse all apps, brew-managed, non-brew, or apps with equivalents
- **Export Functionality**: Export scan results to JSON for analysis
- **Cross-Platform**: Supports both macOS and Linux application discovery

## Installation & Usage

### Prerequisites

- **macOS**: Xcode Command Line Tools (`xcode-select --install`)
- **Linux**: Build essentials and curl
- **Python**: Python 3.7+ (for the scanner)

### Quick Start

#### 1. Automated Package Installation

```bash
# Make executable (if not already)
chmod +x install_brew_apps.sh

# Run the installation script
./install_brew_apps.sh
```

The script will:
- ✅ Detect your operating system
- ✅ Install Homebrew if needed
- ✅ Update Homebrew to latest version
- ✅ Install all formulae (CLI tools)
- ✅ Install all casks (GUI apps - macOS only)
- ✅ Generate detailed installation logs

#### 2. Application Scanner

```bash
# Run the interactive scanner
./brew_scanner.py
```

The scanner will:
- 🔍 Automatically set up a Python virtual environment
- 📱 Scan all installed applications
- 🍺 Identify brew-managed vs non-brew applications
- ✅ Find brew equivalents for non-brew apps
- 📊 Provide detailed analytics and export options

## What Gets Installed

### Formulae (CLI Tools)
- **Development**: `git`, `node`, `npm`, `yarn`, `docker`, `cmake`
- **System Utilities**: `htop`, `tree`, `curl`, `wget`, `jq`
- **Python**: `python@3.10`, `python@3.12`, `python@3.13`, `pyenv`
- **Media Processing**: `ffmpeg`, `libvpx`, `jpeg-turbo`, `lame`
- **Networking**: `c-ares`, `ldns`, `brotli`
- **Fun**: `lolcat`, `bpytop`

### Casks (GUI Applications - macOS)
- **Browsers**: `firefox`, `chromium`, `librewolf`
- **Development**: `vscodium`, `visual-studio-code`, `docker`, `postman`
- **Productivity**: `obsidian`, `notion`, `alt-tab`, `rectangle`
- **Security**: `1password-cli`
- **Media**: `vlc`, `spotify`
- **Communication**: `discord`, `slack`, `zoom`
- **Utilities**: `the-unarchiver`, `cleanmymac`

## Scanner Features

### Menu Options

1. **🔍 Run Application Scan** - Discover all installed applications
2. **ℹ️ View Scan Summary** - See statistics and overview
3. **📱 Browse All Applications** - View complete application list
4. **🍺 View Brew-Managed Apps** - See only brew-installed applications
5. **⚠️ View Non-Brew Apps** - See applications not managed by brew
6. **✅ View Apps with Brew Equivalents** - Find optimization opportunities
7. **⚙️ Export Results to JSON** - Save scan data for analysis

### Application Details

For each application, the scanner shows:
- 📱 **Name**: Application display name
- 📁 **Path**: Installation location
- 🍺 **Brew Status**: Whether it's brew-managed (formula/cask)
- ✅ **Brew Equivalent**: Available brew alternative (if any)
- 💡 **Suggestions**: Recommendations for optimization

## Logs and Output

### Installation Script Logs
- Detailed installation logs saved as `brew_install_YYYYMMDD_HHMMSS.log`
- Color-coded console output with success/failure indicators
- Failed installation tracking for easy troubleshooting

### Scanner Export
- JSON export with timestamp: `brew_scan_results_YYYYMMDD_HHMMSS.json`
- Includes metadata, statistics, and complete application inventory
- Structured data for further analysis or automation

## Configuration

### Customizing Package Lists

Edit the arrays in `install_brew_apps.sh`:

```bash
# Add/remove formulae
local formulae=(
    "your-package-here"
    # ... existing packages
)

# Add/remove casks (macOS only)
local casks=(
    "your-app-here"
    # ... existing apps
)
```

### Scanner Customization

The scanner automatically detects:
- **macOS**: Applications in `/Applications`, `/System/Applications`, `~/Applications`
- **Linux**: Desktop entries in `/usr/share/applications`, `~/.local/share/applications`

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure scripts are executable (`chmod +x script_name`)
2. **Homebrew Not Found**: Script automatically installs Homebrew
3. **Python Dependencies**: Scanner auto-manages virtual environment
4. **Linux Casks**: Casks are macOS-only; Linux uses formulae

### Virtual Environment

The scanner uses an isolated Python environment:
- **Location**: `~/venv/venv-brew-scanner/`
- **Auto-created**: On first run
- **Dependencies**: Automatically installed (`requests`, `psutil`, `colorama`, `keyboard`, `json5`)

## Contributing

Feel free to:
- Add more packages to the installation lists
- Enhance the scanner's app detection logic
- Improve cross-platform compatibility
- Add new analysis features

## Security Notes

- All scripts avoid hardcoded usernames (dynamically detect user)
- No sensitive information is logged or exposed
- Virtual environments ensure dependency isolation
- Installation logs can be reviewed before execution

---

**Enjoy your automated Homebrew experience!** 🍺✨