#!/bin/bash

# Comprehensive Brew Apps Installation Script
# Supports macOS and Linux environments
# Author: Automated Setup Script
# Date: $(date +%Y-%m-%d)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis for better UX
SUCCESS_EMOJI="✅"
ERROR_EMOJI="❌"
WARNING_EMOJI="⚠️"
INFO_EMOJI="ℹ️"
ROCKET_EMOJI="🚀"
PACKAGE_EMOJI="📦"
COMPUTER_EMOJI="💻"

# Logging
LOG_FILE="brew_install_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

print_colored() {
    local color=$1
    local message=$2
    local emoji=$3
    echo -e "${emoji} ${color}${message}${NC}"
    log "$emoji $message"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_colored "$YELLOW" "Homebrew not found. Installing Homebrew..." "$WARNING_EMOJI"
        if [[ "$OS" == "macos" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        elif [[ "$OS" == "linux" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add to PATH for Linux
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        print_colored "$GREEN" "Homebrew installed successfully!" "$SUCCESS_EMOJI"
    else
        print_colored "$GREEN" "Homebrew is already installed!" "$SUCCESS_EMOJI"
    fi
}

# Update Homebrew
update_homebrew() {
    print_colored "$BLUE" "Updating Homebrew..." "$INFO_EMOJI"
    brew update
    print_colored "$GREEN" "Homebrew updated successfully!" "$SUCCESS_EMOJI"
}

# Install formulae (CLI tools)
install_formulae() {
    local formulae=(
        "aom"
        "aribb24"
        "autoconf"
        "bpytop"
        "brotli"
        "c-ares"
        "ca-certificates"
        "cairo"
        "certifi"
        "cffi"
        "cjson"
        "cmake"
        "icu4c@77"
        "imath"
        "jpeg-turbo"
        "jpeg-xl"
        "lame"
        "ldns"
        "leptonica"
        "libarchive"
        "libass"
        "libb2"
        "libbluray"
        "libcbor"
        "libvpx"
        "libx11"
        "libxau"
        "libxcb"
        "libxdmcp"
        "libxext"
        "libxrender"
        "little-cms2"
        "lolcat"
        "lz4"
        "lzo"
        "pyenv"
        "pyenv-virtualenv"
        "python-tk@3.13"
        "python@3.10"
        "python@3.12"
        "python@3.13"
        "rav1e"
        "readline"
        "rubberband"
        "sdl2"
        "snappy"
        "speex"
        "git"
        "curl"
        "wget"
        "tree"
        "htop"
        "jq"
        "node"
        "npm"
        "yarn"
        "docker"
        "docker-compose"
    )

    print_colored "$PURPLE" "Installing Homebrew formulae (CLI tools)..." "$PACKAGE_EMOJI"
    
    local failed_installs=()
    for formula in "${formulae[@]}"; do
        print_colored "$CYAN" "Installing: $formula" "$PACKAGE_EMOJI"
        if brew install "$formula" 2>>"$LOG_FILE"; then
            print_colored "$GREEN" "Successfully installed: $formula" "$SUCCESS_EMOJI"
        else
            print_colored "$RED" "Failed to install: $formula" "$ERROR_EMOJI"
            failed_installs+=("$formula")
        fi
    done

    if [[ ${#failed_installs[@]} -gt 0 ]]; then
        print_colored "$YELLOW" "Failed formulae installations:" "$WARNING_EMOJI"
        printf '%s\n' "${failed_installs[@]}"
    fi
}

# Install casks (GUI applications) - macOS only
install_casks() {
    if [[ "$OS" != "macos" ]]; then
        print_colored "$YELLOW" "Casks are only available on macOS. Skipping..." "$WARNING_EMOJI"
        return
    fi

    local casks=(
        "1password-cli"
        "alt-tab"
        "chromium"
        "firefox"
        "jordanbaird-ice"
        "librewolf"
        "miniconda"
        "reminders-menubar"
        "vscodium"
        "visual-studio-code"
        "discord"
        "slack"
        "zoom"
        "docker"
        "rectangle"
        "cleanmymac"
        "the-unarchiver"
        "vlc"
        "spotify"
        "obsidian"
        "notion"
        "figma"
        "postman"
        "insomnia"
    )

    print_colored "$PURPLE" "Installing Homebrew casks (GUI applications)..." "$COMPUTER_EMOJI"
    
    local failed_installs=()
    for cask in "${casks[@]}"; do
        print_colored "$CYAN" "Installing: $cask" "$COMPUTER_EMOJI"
        if brew install --cask "$cask" 2>>"$LOG_FILE"; then
            print_colored "$GREEN" "Successfully installed: $cask" "$SUCCESS_EMOJI"
        else
            print_colored "$RED" "Failed to install: $cask" "$ERROR_EMOJI"
            failed_installs+=("$cask")
        fi
    done

    if [[ ${#failed_installs[@]} -gt 0 ]]; then
        print_colored "$YELLOW" "Failed cask installations:" "$WARNING_EMOJI"
        printf '%s\n' "${failed_installs[@]}"
    fi
}

# Main execution
main() {
    print_colored "$BLUE" "Starting Brew Apps Installation Script..." "$ROCKET_EMOJI"
    
    OS=$(detect_os)
    print_colored "$CYAN" "Detected OS: $OS" "$COMPUTER_EMOJI"
    
    if [[ "$OS" == "unknown" ]]; then
        print_colored "$RED" "Unsupported operating system!" "$ERROR_EMOJI"
        exit 1
    fi

    check_homebrew
    update_homebrew
    install_formulae
    install_casks

    print_colored "$GREEN" "Installation complete! Check $LOG_FILE for detailed logs." "$SUCCESS_EMOJI"
    print_colored "$BLUE" "You may need to restart your terminal for some changes to take effect." "$INFO_EMOJI"
}

# Run the script
main "$@" 