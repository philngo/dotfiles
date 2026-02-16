# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What This Is

A macOS dotfiles repo managing configs for Neovim, Zsh, Wezterm, Git, Jujutsu (jj), AeroSpace, Starship, Atuin, Yazi, and more. Catppuccin Mocha is the universal colorscheme.

## Key Commands

```bash
./install.sh              # Install packages + symlink everything (idempotent)
./macos/defaults.sh       # Apply macOS system preferences
brew bundle               # Install/update Homebrew packages from Brewfile
brew bundle dump --force   # Capture currently installed packages to Brewfile
ya pkg install            # Install yazi plugins from config/yazi/package.toml
```

## Architecture

**Symlink-based, no stow.** `install.sh` symlinks `home/*` to `~/` and recursively symlinks individual files in `config/*` to `~/.config/` (not whole directories, to avoid clobbering unmanaged files).

**Layered config pattern:** Base configs are tracked in git. Machine-specific overrides go in `.local` files (git-ignored) with `.local.example` templates provided:
- `home/.gitconfig` includes `~/.gitconfig.local`
- `home/.zshrc` sources `~/.zshrc.local`
- `config/jj/conf.d/local.toml.example` for jj identity

**Adding a new dotfile:** Place it in `home/` (for `~/`) or `config/` (for `~/.config/`), then run `./install.sh`.

## Directory Layout

- `home/` — dotfiles symlinked to `~/` (zshrc, gitconfig, aerospace.toml, etc.)
- `config/` — configs symlinked to `~/.config/` (nvim, wezterm, jj, starship, atuin, yazi)
- `config/wezterm/` — Wezterm terminal config; `projects.lua` is machine-specific (git-ignored), template at `projects.lua.example`
- `config/nvim/` — Neovim config using lazy.nvim; plugins defined in `lua/plugins/init.lua`; uses native Neovim 0.11+ LSP API (no nvim-lspconfig)
- `claude/agents/` — Claude Code custom agents, symlinked to `~/.claude/agents/`
- `iterm/` — iTerm2 dynamic profiles, symlinked to `~/Library/Application Support/iTerm2/DynamicProfiles/`
- `macos/` — macOS defaults script
- `Brewfile` — Homebrew packages (CLI tools, casks, fonts)

## Conventions

- Shell is Zsh. Custom functions (`gs`, `gbd`, `grm`, `gcm`, `y`) are defined in `.zshrc`.
- Vim-style keybindings are used across tools (Wezterm, AeroSpace, Neovim) with modifier escalation: Ctrl-w (Neovim), Cmd (Wezterm), Alt (AeroSpace).
- `install.sh` backs up existing non-symlink files before overwriting.
