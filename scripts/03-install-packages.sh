#!/bin/bash
# =============================================================================
# Homebrew Packages Installation Script
# =============================================================================
# Installs formulae (CLI tools) and casks (GUI applications)
# Supports --dry-run mode to preview installations
# =============================================================================

set -e

# =============================================================================
# PARSE ARGUMENTS
# =============================================================================
DRY_RUN=false
AUTO_CONFIRM=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run|-n)
      DRY_RUN=true
      shift
      ;;
    --yes|-y)
      AUTO_CONFIRM=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run, -n    Preview what would be installed without making changes"
      echo "  --yes, -y        Skip confirmation prompt (for automation)"
      echo "  --help, -h       Show this help message"
      echo ""
      echo "Note: Cask applications are macOS-only and will be skipped on Linux"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

if $DRY_RUN; then
  echo "🔍 DRY RUN MODE - No changes will be made"
  echo ""
fi

# =============================================================================
# OS DETECTION
# =============================================================================
OS_TYPE="$(uname -s)"
IS_MACOS=false
IS_LINUX=false

case "$OS_TYPE" in
  Darwin)
    IS_MACOS=true
    ;;
  Linux)
    IS_LINUX=true
    ;;
  *)
    echo "⚠️  Unknown OS: $OS_TYPE - proceeding with caution"
    ;;
esac

# =============================================================================
# SECURITY CHECK
# =============================================================================
if [[ $EUID -eq 0 ]]; then
  echo "❌ ERROR: Do not run this script as root/sudo"
  exit 1
fi

# =============================================================================
# CHECK HOMEBREW
# =============================================================================
if ! command -v brew &>/dev/null; then
  echo "❌ ERROR: Homebrew is not installed"
  echo "   Run ./scripts/01-install-homebrew.sh first"
  exit 1
fi

if ! $DRY_RUN; then
  echo "🍺 Updating Homebrew..."
  brew update
fi

# =============================================================================
# FORMULAE (Command-line tools)
# =============================================================================
formulae=(
  # Development Tools
  act                       # GitHub Actions local runner
  awscli                    # AWS CLI
  docker                    # Docker CLI
  docker-completion         # Docker shell completions
  fzf                       # Fuzzy finder
  gh                        # GitHub CLI
  git                       # Git version control
  k9s                       # Kubernetes TUI
  node                      # Node.js runtime
  pipx                      # Install Python CLI tools
  rust                      # Rust programming language
  terraform                 # Infrastructure as code
  uv                        # Fast Python package manager

  # Shell & Terminal
  glances                   # System monitoring tool
  htop                      # Process viewer
  jq                        # JSON processor
  tmux                      # Terminal multiplexer
  tree                      # Directory tree viewer
  zsh-autosuggestions       # Zsh fish-like autosuggestions
  zsh-syntax-highlighting   # Zsh syntax highlighting

  # Utilities
  curl                      # Transfer data tool
  ffmpeg                    # Media processing
  kubernetes-cli            # kubectl
  wget                      # File downloader
  yt-dlp                    # Video downloader
)

# =============================================================================
# CASK APPLICATIONS (GUI Applications)
# =============================================================================
cask_apps=(
  # Core Tools
  1password                 # Password manager
  1password-cli             # 1Password CLI
  claude                    # Claude desktop app
  claude-code               # Claude Code CLI
  github                    # GitHub Desktop
  vscodium                  # VS Code without telemetry

  # Browsers
  brave-browser             # Chrome-based browser
  chromium                  # Open-source browser
  firefox                   # Mozilla Firefox
  zen                       # Privacy-focused browser

  # Productivity
  bettertouchtool           # Keyboard/mouse customization
  iterm2                    # Terminal emulator

  # System Utilities
  appcleaner                # App uninstaller
  istat-menus               # System monitor menubar
  jordanbaird-ice@beta      # Menubar manager
  jump-desktop-connect      # Remote desktop client
  linearmouse               # Mouse customization
  little-snitch             # Network monitor
  pearcleaner               # App uninstaller (alternative)
  syncthing-app             # File sync

  # Media
  iina                      # Modern media player

  # Security
  mozilla-vpn               # VPN client
)

# =============================================================================
# CONFIRMATION PROMPT
# =============================================================================
if ! $DRY_RUN && ! $AUTO_CONFIRM; then
  # Count what will be installed
  to_install_formulae=0
  to_install_casks=0

  for formula in "${formulae[@]}"; do
    formula_name=$(echo "$formula" | awk '{print $1}')
    if ! brew list "$formula_name" &>/dev/null; then
      ((to_install_formulae++)) || true
    fi
  done

  for app in "${cask_apps[@]}"; do
    app_name=$(echo "$app" | awk '{print $1}')
    if ! brew list --cask "$app_name" &>/dev/null; then
      ((to_install_casks++)) || true
    fi
  done

  if [[ $to_install_formulae -gt 0 || $to_install_casks -gt 0 ]]; then
    echo ""
    echo "📋 Will install:"
    echo "   - $to_install_formulae formulae"
    echo "   - $to_install_casks cask applications"
    echo ""
    read -p "Proceed with installation? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "❌ Installation cancelled"
      exit 0
    fi
  else
    echo ""
    echo "✅ All packages already installed!"
    exit 0
  fi
fi

# =============================================================================
# INSTALL FORMULAE
# =============================================================================
echo ""
echo "📦 Formulae (command-line tools)..."
echo "   Total: ${#formulae[@]} packages"
echo ""

for formula in "${formulae[@]}"; do
  # Extract formula name (remove inline comments)
  formula_name=$(echo "$formula" | awk '{print $1}')

  if brew list "$formula_name" &>/dev/null; then
    echo "  ✅ $formula_name (already installed)"
  elif $DRY_RUN; then
    echo "  📋 $formula_name (would install)"
  else
    echo "  ⬇️  Installing $formula_name..."
    brew install "$formula_name"
  fi
done

# =============================================================================
# INSTALL CASK APPLICATIONS (macOS only)
# =============================================================================
if $IS_LINUX; then
  echo ""
  echo "🐧 Skipping cask applications on Linux (macOS-only feature)"
  echo "   Formulae have been installed. Consider apt/dnf/pacman for GUI apps."
else
  echo ""
  echo "🖥️  Cask applications (GUI apps)..."
  echo "   Total: ${#cask_apps[@]} applications"
  echo ""

  for app in "${cask_apps[@]}"; do
    # Extract app name (remove inline comments)
    app_name=$(echo "$app" | awk '{print $1}')

    if brew list --cask "$app_name" &>/dev/null; then
      echo "  ✅ $app_name (already installed)"
    elif $DRY_RUN; then
      echo "  📋 $app_name (would install)"
    else
      echo "  ⬇️  Installing $app_name..."
      brew install --cask "$app_name"
    fi
  done
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
if $DRY_RUN; then
  echo "🔍 DRY RUN COMPLETE"
  echo "   Run without --dry-run to install packages"
else
  echo "✅ Package installation complete!"
fi
