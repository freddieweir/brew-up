#!/bin/bash

# =============================================================================
# Homebrew Installation Script
# =============================================================================
# This script installs Homebrew (if not present) and then installs:
# 1. Formulae - Command-line tools and libraries
# 2. Cask Applications - GUI applications
# 
# To add new items:
# - Add formulae to the 'formulae' array below
# - Add cask apps to the 'cask_apps' array below
# =============================================================================

# =============================================================================
# SECURITY CHECK - Do NOT run as root/sudo
# =============================================================================
if [[ $EUID -eq 0 ]]; then
   echo "❌ ERROR: This script should NOT be run with sudo or as root!"
   echo ""
   echo "🔒 Homebrew does not support running as root for security reasons."
   echo "🔧 Run this script as a regular user: ./brew.sh"
   echo ""
   echo "💡 Note: Some installed tools (like htop) may require sudo when you USE them,"
   echo "   but the installation itself should be done as a regular user."
   echo ""
   exit 1
fi

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
  echo "🍺 Homebrew not found. Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # After installation, add Homebrew to PATH for the current session
  if [[ -d /opt/homebrew/bin ]]; then
    # Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -d /usr/local/bin ]]; then
    # Intel macOS
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "🍺 Homebrew is already installed. Updating Homebrew..."
  brew update
fi

# =============================================================================
# FORMULAE (Command-line tools and libraries)
# =============================================================================
# Add new command-line tools to this array
formulae=(
  gh                    # GitHub CLI
  git                   # Git version control
  jq                    # JSON processor
  wget                  # File downloader
  curl                  # Transfer data tool
  tree                  # Directory tree viewer
  htop                  # Process viewer (use 'sudo htop' for full processes)
)

# =============================================================================
# CASK APPLICATIONS (GUI Applications)
# =============================================================================
# Add new GUI applications to this array
cask_apps=(
  1password             # Password manager
  1password-cli         # 1Password CLI
  cursor                # AI-powered code editor
  iterm2                # Terminal emulator
  mozilla-vpn           # VPN client
  obsidian              # Note-taking app
  yubico-authenticator  # YubiKey authenticator
  zen-browser           # Privacy-focused browser
  chromium              # Open-source browser
)

# =============================================================================
# INSTALL FORMULAE
# =============================================================================
echo ""
echo "📦 Installing formulae (command-line tools)..."
for formula in "${formulae[@]}"; do
  # Remove inline comments for processing
  formula_name=$(echo "$formula" | awk '{print $1}')
  
  if brew list "$formula_name" >/dev/null 2>&1; then
    echo "✅ $formula_name is already installed."
  else
    echo "⬇️  Installing $formula_name..."
    brew install "$formula_name"
  fi
done

# =============================================================================
# INSTALL CASK APPLICATIONS
# =============================================================================
echo ""
echo "🖥️  Installing cask applications (GUI apps)..."
for app in "${cask_apps[@]}"; do
  # Remove inline comments for processing
  app_name=$(echo "$app" | awk '{print $1}')
  
  if brew list --cask "$app_name" >/dev/null 2>&1; then
    echo "✅ $app_name is already installed."
  else
    echo "⬇️  Installing $app_name..."
    brew install --cask "$app_name"
  fi
done

# =============================================================================
# OH MY ZSH INSTALLATION
# =============================================================================
echo ""
echo "🎨 Installing Oh My Zsh (enhanced terminal experience)..."

# Check if Oh My Zsh is already installed
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "✅ Oh My Zsh is already installed."
else
  echo "⬇️  Installing Oh My Zsh..."
  # Install Oh My Zsh in unattended mode (non-interactive)
  sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  
  # Set zsh as default shell if it isn't already
  if [[ "$SHELL" != */zsh ]]; then
    echo "🔧 Setting zsh as default shell..."
    chsh -s $(which zsh)
    echo "💡 You'll need to restart your terminal/session for the shell change to take effect."
  fi
fi

echo ""
echo "🎉 Installation complete!"
echo ""
echo "📝 To add more items:"
echo "   - Add formulae (CLI tools) to the 'formulae' array"
echo "   - Add cask apps (GUI apps) to the 'cask_apps' array"
echo ""
echo "💡 Usage notes:"
echo "   - Some tools like htop require sudo when USING them: 'sudo htop'"
echo "   - Never run this installation script with sudo"
echo "   - Oh My Zsh provides themes and plugins - explore ~/.oh-my-zsh/"
echo "   - Restart your terminal to fully activate Oh My Zsh"
