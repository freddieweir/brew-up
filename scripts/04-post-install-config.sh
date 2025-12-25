#!/bin/bash
# =============================================================================
# Post-Install Configuration Script
# =============================================================================
# Applies standard configurations after package installation
# Idempotent - safe to run multiple times
# =============================================================================

set -e

# Security check
if [[ $EUID -eq 0 ]]; then
  echo "ERROR: Do not run this script as root/sudo"
  exit 1
fi

echo "Applying post-install configurations..."
echo ""

# =============================================================================
# GIT CONFIGURATION
# =============================================================================
echo "--- Git Configuration ---"

if ! git config --global user.name &>/dev/null; then
  echo "  Git user.name not configured. Set with:"
  echo "    git config --global user.name 'Your Name'"
else
  echo "  user.name: $(git config --global user.name)"
fi

if ! git config --global user.email &>/dev/null; then
  echo "  Git user.email not configured. Set with:"
  echo "    git config --global user.email 'your@email.com'"
else
  echo "  user.email: $(git config --global user.email)"
fi

# =============================================================================
# 1PASSWORD SSH AGENT
# =============================================================================
echo ""
echo "--- 1Password SSH Agent ---"

SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

if [[ ! -f "$SSH_CONFIG" ]] || ! grep -q "IdentityAgent" "$SSH_CONFIG"; then
  echo "  Configuring SSH for 1Password agent..."
  cat >> "$SSH_CONFIG" << 'EOF'

# 1Password SSH Agent
Host *
    IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
EOF
  chmod 600 "$SSH_CONFIG"
  echo "  SSH configured for 1Password agent"
else
  echo "  Already configured"
fi

# =============================================================================
# GITHUB CLI
# =============================================================================
echo ""
echo "--- GitHub CLI ---"

if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    echo "  Already authenticated as: $(gh auth status 2>&1 | grep 'Logged in' | head -1 | sed 's/.*as //' | sed 's/ .*//')"
  else
    echo "  GitHub CLI not authenticated."
    read -p "  Would you like to authenticate now? [y/N] " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      gh auth login
      gh auth setup-git
      echo "  GitHub CLI configured"
    else
      echo "  Skipped. Run 'gh auth login' later to authenticate."
    fi
  fi
else
  echo "  gh not installed (will be available after brew packages install)"
fi

# =============================================================================
# ZSH PLUGINS
# =============================================================================
echo ""
echo "--- Zsh Plugins ---"

ZSHRC="$HOME/.zshrc"

if [[ ! -f "$ZSHRC" ]]; then
  echo "  No .zshrc found. Run Oh My Zsh installer first."
else
  PLUGINS_ADDED=false

  if ! grep -q "zsh-autosuggestions.zsh" "$ZSHRC" 2>/dev/null; then
    echo "" >> "$ZSHRC"
    echo "# Homebrew zsh plugins" >> "$ZSHRC"
    echo 'source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null' >> "$ZSHRC"
    PLUGINS_ADDED=true
    echo "  Added zsh-autosuggestions"
  fi

  if ! grep -q "zsh-syntax-highlighting.zsh" "$ZSHRC" 2>/dev/null; then
    if ! $PLUGINS_ADDED; then
      echo "" >> "$ZSHRC"
      echo "# Homebrew zsh plugins" >> "$ZSHRC"
    fi
    echo 'source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null' >> "$ZSHRC"
    echo "  Added zsh-syntax-highlighting"
    PLUGINS_ADDED=true
  fi

  if ! $PLUGINS_ADDED; then
    echo "  Already configured"
  fi
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo "Post-install configuration complete!"
echo ""
echo "Manual steps remaining:"
echo "  1. Enable SSH Agent in 1Password: Settings > Developer > SSH Agent"
echo "  2. Restart your terminal to apply zsh plugin changes"
