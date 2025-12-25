#!/bin/bash
# =============================================================================
# VM Setup Orchestrator
# =============================================================================
# Main script that runs all setup scripts in order:
# 1. Install Homebrew (if not present)
# 2. Install Oh My Zsh (if not present)
# 3. Install formulae and casks
# 4. Apply post-install configurations (SSH, zsh plugins)
#
# Usage:
#   ./setup.sh              # Full setup
#   ./setup.sh --dry-run    # Preview package installations
#   ./setup.sh -n           # Short form of --dry-run
#   ./setup.sh --yes        # Skip confirmation prompt
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=""
AUTO_CONFIRM=""

# =============================================================================
# PARSE ARGUMENTS
# =============================================================================
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run|-n)
      DRY_RUN="--dry-run"
      shift
      ;;
    --yes|-y)
      AUTO_CONFIRM="--yes"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "VM Setup Orchestrator - installs Homebrew, Oh My Zsh, and packages"
      echo ""
      echo "Options:"
      echo "  --dry-run, -n    Preview package installations without making changes"
      echo "  --yes, -y        Skip confirmation prompt (for automation)"
      echo "  --help, -h       Show this help message"
      echo ""
      echo "Individual scripts:"
      echo "  ./scripts/01-install-homebrew.sh     Install Homebrew only"
      echo "  ./scripts/02-install-ohmyzsh.sh      Install Oh My Zsh only"
      echo "  ./scripts/03-install-packages.sh     Install packages only (supports --dry-run, --yes)"
      echo "  ./scripts/04-post-install-config.sh  Apply post-install configurations"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# =============================================================================
# SECURITY CHECK
# =============================================================================
if [[ $EUID -eq 0 ]]; then
  echo "❌ ERROR: Do not run this script as root/sudo"
  exit 1
fi

# =============================================================================
# RUN SETUP
# =============================================================================
echo "🚀 Starting VM Setup..."
echo "========================================"
echo ""

# Step 1: Install Homebrew
echo "Step 1/4: Homebrew"
echo "----------------------------------------"
"$SCRIPT_DIR/scripts/01-install-homebrew.sh"
echo ""

# Ensure brew is available in current session after installation
if [[ -d /opt/homebrew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -d /usr/local/Homebrew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Step 2: Install Oh My Zsh
echo "Step 2/4: Oh My Zsh"
echo "----------------------------------------"
"$SCRIPT_DIR/scripts/02-install-ohmyzsh.sh"
echo ""

# Step 3: Install Packages
echo "Step 3/4: Packages"
echo "----------------------------------------"
"$SCRIPT_DIR/scripts/03-install-packages.sh" $DRY_RUN $AUTO_CONFIRM
echo ""

# Step 4: Post-install Configuration
if [[ -z "$DRY_RUN" ]]; then
  echo "Step 4/4: Post-install Configuration"
  echo "----------------------------------------"
  "$SCRIPT_DIR/scripts/04-post-install-config.sh"
  echo ""
else
  echo "Step 4/4: Post-install Configuration (skipped in dry-run)"
  echo ""
fi

# =============================================================================
# COMPLETE
# =============================================================================
echo "========================================"
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal for all changes to take effect"
echo "  2. Enable SSH Agent in 1Password: Settings > Developer > SSH Agent"
echo "  3. Configure your apps as needed"
echo ""
if [[ -n "$DRY_RUN" ]]; then
  echo "📋 Note: Packages were previewed only (--dry-run mode)"
  echo "   Run './setup.sh' without --dry-run to install"
fi
