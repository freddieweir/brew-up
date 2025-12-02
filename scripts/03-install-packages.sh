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

while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run|-n)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run, -n    Preview what would be installed without making changes"
      echo "  --help, -h       Show this help message"
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
  zen-browser               # Privacy-focused browser

  # Productivity
  iterm2                    # Terminal emulator

  # System Utilities
  appcleaner                # App uninstaller
  istat-menus               # System monitor menubar
  jordanbaird-ice           # Menubar manager
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
# INSTALL CASK APPLICATIONS
# =============================================================================
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
