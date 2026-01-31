# Dotfiles

Personal dotfiles and system configuration for macOS.

## New Machine Setup

```bash
# 1. Clone the repo
git clone https://github.com/philngo/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# 2. Install packages and symlink dotfiles
./install.sh

# 3. Apply macOS system preferences
./macos/defaults.sh

# 4. Follow manual setup guide
open docs/manual-setup.md
```

## Structure

```
├── home/                       # Symlinked to ~/
│   ├── .zshrc
│   ├── .zshrc.local.example    # Template for machine-specific config
│   ├── .zprofile
│   ├── .gitconfig
│   ├── .gitconfig.local.example
│   └── .aerospace.toml
├── config/                     # Symlinked to ~/.config/
│   ├── nvim/                   # Neovim config
│   └── starship.toml           # Prompt config
├── macos/
│   └── defaults.sh             # System preferences script
├── docs/                       # Manual setup guides
│   ├── manual-setup.md
│   ├── firefox.md
│   └── iterm.md
├── Brewfile                    # Homebrew packages
└── install.sh                  # Bootstrap script
```

## Usage

### Keeping dotfiles updated

Files are symlinked, so edits anywhere are reflected in the repo:

```bash
# Edit directly (both point to same file)
vim ~/.zshrc
vim ~/dev/dotfiles/home/.zshrc

# Commit changes
cd ~/dev/dotfiles
git add -A && git commit -m "Update zshrc"
git push
```

### Machine-specific config

Some settings vary per machine (git email, paths, etc.). These use `.local` files that aren't tracked:

```bash
# Set up local overrides (copy from examples)
cp ~/dev/dotfiles/home/.gitconfig.local.example ~/.gitconfig.local
cp ~/dev/dotfiles/home/.zshrc.local.example ~/.zshrc.local

# Edit with your machine-specific values
vim ~/.gitconfig.local
```

### Adding a new dotfile

1. Move the file into `home/` or `config/` as appropriate
2. Run `./install.sh` to create the symlink
3. Commit the changes

### Updating packages

```bash
# Add new packages to Brewfile, then:
brew bundle

# Or dump currently installed packages:
brew bundle dump --force
```

### macOS defaults

System preferences are stored in `macos/defaults.sh`. Run it to apply settings:

```bash
./macos/defaults.sh
```

## Manual Setup

See `docs/` for configuration that can't be automated:

- [manual-setup.md](docs/manual-setup.md) - System preferences, app settings, SSH keys
- [firefox.md](docs/firefox.md) - Firefox configuration
- [iterm.md](docs/iterm.md) - iTerm2 configuration
