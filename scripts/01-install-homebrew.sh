#!/bin/bash
# =============================================================================
# Homebrew Installation Script
# =============================================================================
# Installs Homebrew and configures shell for persistence
# Reference: https://docs.brew.sh/Installation
# =============================================================================

set -e

# Security check - do NOT run as root/sudo
if [[ $EUID -eq 0 ]]; then
  echo "❌ ERROR: Do not run this script as root/sudo"
  echo "   Homebrew does not support running as root for security reasons."
  exit 1
fi

# Check if Homebrew is already installed
if command -v brew &>/dev/null; then
  echo "✅ Homebrew is already installed"
  brew --version
  exit 0
fi

echo "🍺 Installing Homebrew..."
echo ""

# Install Homebrew (official installer)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Determine prefix based on architecture (Apple Silicon vs Intel)
if [[ -d /opt/homebrew ]]; then
  # Apple Silicon Mac
  BREW_PREFIX="/opt/homebrew"
elif [[ -d /usr/local/Homebrew ]]; then
  # Intel Mac
  BREW_PREFIX="/usr/local"
else
  echo "❌ ERROR: Could not determine Homebrew installation path"
  exit 1
fi

echo ""
echo "📍 Homebrew installed at: $BREW_PREFIX"

# Add to current session
eval "$($BREW_PREFIX/bin/brew shellenv)"

# Persist to .zshrc if not already present
ZSHRC="$HOME/.zshrc"
SHELLENV_CMD="eval \"\$($BREW_PREFIX/bin/brew shellenv)\""

if [[ -f "$ZSHRC" ]] && grep -q 'brew shellenv' "$ZSHRC" 2>/dev/null; then
  echo "✅ Homebrew already configured in ~/.zshrc"
else
  echo "" >> "$ZSHRC"
  echo "# Homebrew" >> "$ZSHRC"
  echo "$SHELLENV_CMD" >> "$ZSHRC"
  echo "✅ Added Homebrew to ~/.zshrc"
fi

# Also add to .bash_profile for bash users
BASH_PROFILE="$HOME/.bash_profile"
if [[ -f "$BASH_PROFILE" ]] && ! grep -q 'brew shellenv' "$BASH_PROFILE" 2>/dev/null; then
  echo "" >> "$BASH_PROFILE"
  echo "# Homebrew" >> "$BASH_PROFILE"
  echo "$SHELLENV_CMD" >> "$BASH_PROFILE"
  echo "✅ Added Homebrew to ~/.bash_profile"
fi

echo ""
echo "✅ Homebrew installation complete!"
echo ""
echo "💡 Restart your terminal or run:"
echo "   eval \"\$($BREW_PREFIX/bin/brew shellenv)\""
