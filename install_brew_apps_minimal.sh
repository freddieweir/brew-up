#!/bin/bash

# Minimal Brew Apps Installation Script
# A lightweight version for manual package management
# Add your desired packages to the arrays below

set -e  # Exit on any error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Emojis
SUCCESS_EMOJI="✅"
INFO_EMOJI="ℹ️"
PACKAGE_EMOJI="📦"

print_colored() {
    local color=$1
    local message=$2
    local emoji=$3
    echo -e "${emoji} ${color}${message}${NC}"
}

# Check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_colored "$YELLOW" "Installing Homebrew..." "$INFO_EMOJI"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_colored "$GREEN" "Homebrew installed!" "$SUCCESS_EMOJI"
    else
        print_colored "$GREEN" "Homebrew already installed!" "$SUCCESS_EMOJI"
    fi
}

# Essential formulae (add more as needed)
install_essential_formulae() {
    local formulae=(
        "git"
        "curl"
        "wget"
    )

    if [[ ${#formulae[@]} -eq 0 ]]; then
        print_colored "$YELLOW" "No formulae specified. Skipping..." "$INFO_EMOJI"
        return
    fi

    print_colored "$BLUE" "Installing essential formulae..." "$PACKAGE_EMOJI"
    for formula in "${formulae[@]}"; do
        if brew list "$formula" &>/dev/null; then
            print_colored "$GREEN" "$formula already installed" "$SUCCESS_EMOJI"
        else
            print_colored "$BLUE" "Installing: $formula" "$PACKAGE_EMOJI"
            brew install "$formula"
        fi
    done
}

# Essential casks (add more as needed)
install_essential_casks() {
    local casks=(
        "reminders-menubar"
    )

    if [[ ${#casks[@]} -eq 0 ]]; then
        print_colored "$YELLOW" "No casks specified. Skipping..." "$INFO_EMOJI"
        return
    fi

    print_colored "$BLUE" "Installing essential casks..." "$PACKAGE_EMOJI"
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_colored "$GREEN" "$cask already installed" "$SUCCESS_EMOJI"
        else
            print_colored "$BLUE" "Installing: $cask" "$PACKAGE_EMOJI"
            brew install --cask "$cask"
        fi
    done
}

# Main execution
main() {
    print_colored "$BLUE" "Starting minimal brew setup..." "$INFO_EMOJI"
    
    check_homebrew
    brew update
    install_essential_formulae
    install_essential_casks

    print_colored "$GREEN" "Minimal setup complete!" "$SUCCESS_EMOJI"
    echo ""
    print_colored "$YELLOW" "💡 To add more packages:" "$INFO_EMOJI"
    echo "   1. Edit this script and add packages to the arrays"
    echo "   2. Or use: brew install <package-name>"
    echo "   3. For GUI apps: brew install --cask <app-name>"
}

main "$@" 