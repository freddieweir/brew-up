# brew-up

Automates the setup of a new macOS machine by installing Homebrew, Oh My Zsh, and a standard set of applications.

## Quick Start

```bash
git clone https://github.com/fweirvm/brew-up.git
cd brew-up
./setup.sh
```

## Configuration

To customize the packages that are installed, modify the `formulae` and `cask_apps` arrays within the `scripts/03-install-packages.sh` file.

- **Formulae**: Command-line tools.
- **Casks**: GUI applications.

```bash
# scripts/03-install-packages.sh

formulae=(
  gh
  git
  node
  # ...add more formulae here
)

cask_apps=(
  vscodium
  iterm2
  # ...add more casks here
)
```

## Usage

The primary script is `setup.sh`, which orchestrates the entire installation process.

### Full Setup

Run the main script to install everything. The script is idempotent and will skip anything that is already installed.

```bash
./setup.sh
```

### Dry Run

To preview which packages would be installed without making any changes, use the `--dry-run` or `-n` flag.

```bash
./setup.sh --dry-run
```

### Automated Setup

To run the script without the interactive confirmation prompt, use the `--yes` or `-y` flag. This is useful for automated environments.

```bash
./setup.sh --yes
```