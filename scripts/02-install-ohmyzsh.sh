#!/bin/bash
# =============================================================================
# Oh My Zsh Installation Script
# =============================================================================
# Installs Oh My Zsh for enhanced terminal experience
# Reference: https://ohmyz.sh/
# =============================================================================

set -e

# Check if Oh My Zsh is already installed
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  echo "✅ Oh My Zsh is already installed"
  exit 0
fi

echo "🎨 Installing Oh My Zsh..."
echo ""

# Install Oh My Zsh in unattended mode (non-interactive)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Set zsh as default shell if it isn't already
if [[ "$SHELL" != */zsh ]]; then
  echo ""
  echo "🔧 Setting zsh as default shell..."

  # Get the path to zsh
  ZSH_PATH=$(which zsh)

  if [[ -n "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH"
    echo "✅ Default shell changed to zsh"
    echo "💡 You'll need to restart your terminal for the shell change to take effect."
  else
    echo "⚠️  Could not find zsh. Please install zsh first."
  fi
else
  echo "✅ zsh is already the default shell"
fi

echo ""
echo "✅ Oh My Zsh installation complete!"
echo ""
echo "💡 Tips:"
echo "   - Explore themes: ~/.oh-my-zsh/themes/"
echo "   - Add plugins: edit ~/.zshrc and modify plugins=()"
echo "   - Restart your terminal to see changes"
