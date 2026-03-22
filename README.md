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
│   ├── .gitignore              # Global git ignore
│   ├── .mise.toml              # Tool versions (node, etc.)
│   ├── .cheatsheet             # Personal keybinding reference
│   └── .aerospace.toml         # Window manager config
├── config/                     # Symlinked to ~/.config/
│   ├── nvim/                   # Neovim config (lazy.nvim)
│   ├── jj/                     # Jujutsu VCS config
│   └── starship.toml           # Prompt config
├── codex/
│   ├── AGENTS.md               # User-scoped Codex instructions, symlinked to ~/.codex/AGENTS.md
│   └── skills/                 # Codex custom skills, symlinked to ~/.codex/skills/
├── claude/
│   ├── agents/                 # Claude Code custom agents
│   └── hooks/                  # Claude Code hook scripts (notification → WezTerm focus)
├── iterm/
│   └── profiles.json           # iTerm2 dynamic profile (Catppuccin Mocha)
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

### Managing Codex skills

Repo-managed Codex skills live in `codex/skills/`. `./install.sh` symlinks each top-level skill directory into `~/.codex/skills/`, which keeps Codex-managed entries like `~/.codex/skills/.system/` intact.

### Managing Codex guidance

Repo-managed Codex user guidance lives in `codex/AGENTS.md`. `./install.sh` symlinks it to `~/.codex/AGENTS.md`, which Codex loads as global personal guidance.

### Claude Code notifications

When Claude Code is waiting for permission approval in one WezTerm workspace and you're working in another, a macOS notification is sent automatically. Clicking it brings you to the correct workspace.

**How it works:**

1. Claude Code fires a `Notification` hook on `permission_prompt` events
2. `claude/hooks/claude-notify` detects the WezTerm workspace via `$WEZTERM_PANE` and sends a notification via `terminal-notifier`
3. Clicking the notification runs `claude/hooks/wezterm-focus`, which writes the workspace name to `~/.local/state/wezterm/switch-workspace` and activates WezTerm
4. WezTerm's `window-focus-changed` event reads the file and switches to the target workspace

**Requirements:** `terminal-notifier` (installed via Brewfile), `jq`, `wezterm`.

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
