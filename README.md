# brew-up

Automated setup scripts for new macOS VMs. Installs Homebrew, Oh My Zsh, and essential packages.

## Quick Start

```bash
# Clone the repo
git clone git@github.com:freddieweir/brew-up.git
cd brew-up

# Run full setup
./setup.sh

# Or preview what would be installed first
./setup.sh --dry-run
```

## Usage

### Full Setup (Recommended for New VMs)

```bash
./setup.sh
```

This runs all setup scripts in order:
1. Installs Homebrew (if not present)
2. Installs Oh My Zsh (if not present)
3. Installs all formulae and casks

### Dry Run Mode

Preview what would be installed without making changes:

```bash
./setup.sh --dry-run
# or
./setup.sh -n
```

### Individual Scripts

Run specific setup steps:

```bash
# Install Homebrew only
./scripts/01-install-homebrew.sh

# Install Oh My Zsh only
./scripts/02-install-ohmyzsh.sh

# Install packages only (supports --dry-run)
./scripts/03-install-packages.sh
./scripts/03-install-packages.sh --dry-run
```

## What Gets Installed

### Formulae (CLI Tools)

| Package | Description |
|---------|-------------|
| act | GitHub Actions local runner |
| awscli | AWS CLI |
| docker | Docker CLI |
| docker-completion | Docker shell completions |
| fzf | Fuzzy finder |
| gh | GitHub CLI |
| git | Git version control |
| glances | System monitoring tool |
| htop | Process viewer |
| jq | JSON processor |
| k9s | Kubernetes TUI |
| kubernetes-cli | kubectl |
| node | Node.js runtime |
| pipx | Install Python CLI tools |
| rust | Rust programming language |
| terraform | Infrastructure as code |
| tmux | Terminal multiplexer |
| tree | Directory tree viewer |
| uv | Fast Python package manager |
| wget | File downloader |
| yt-dlp | Video downloader |
| zsh-autosuggestions | Zsh fish-like autosuggestions |
| zsh-syntax-highlighting | Zsh syntax highlighting |

### Cask Applications (GUI Apps)

| Package | Description |
|---------|-------------|
| 1password | Password manager |
| 1password-cli | 1Password CLI |
| appcleaner | App uninstaller |
| brave-browser | Chrome-based browser |
| chromium | Open-source browser |
| claude | Claude desktop app |
| claude-code | Claude Code CLI |
| firefox | Mozilla Firefox |
| github | GitHub Desktop |
| iina | Modern media player |
| istat-menus | System monitor menubar |
| iterm2 | Terminal emulator |
| jordanbaird-ice | Menubar manager |
| jump-desktop-connect | Remote desktop client |
| linearmouse | Mouse customization |
| little-snitch | Network monitor |
| mozilla-vpn | VPN client |
| pearcleaner | App uninstaller (alternative) |
| syncthing-app | File sync |
| vscodium | VS Code without telemetry |
| zen-browser | Privacy-focused browser |

## Customizing

To add or remove packages, edit `scripts/03-install-packages.sh`:

- Add formulae to the `formulae=()` array
- Add casks to the `cask_apps=()` array

## Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Admin privileges (for some cask installations)

## Notes

- All scripts are idempotent (safe to run multiple times)
- Scripts will skip already-installed packages
- Do NOT run with `sudo` - Homebrew doesn't support root installation
