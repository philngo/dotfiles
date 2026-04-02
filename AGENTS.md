# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What This Is

A macOS dotfiles repo managing configs for Neovim, Zsh, Wezterm, Git, Jujutsu (jj), AeroSpace, Starship, Atuin, Yazi, and more. Catppuccin Mocha is the universal colorscheme.

## Key Commands

```bash
./install.sh              # Install packages + symlink everything (idempotent, reads modules.conf)
./macos/defaults.sh       # Apply macOS system preferences
ya pkg install            # Install yazi plugins from config/yazi/package.toml
```

## Architecture

**Module-based installation.** `modules.conf` (git-ignored, copied from `modules.conf.example`) lists enabled modules. `install.sh` reads it and only installs packages and symlinks for enabled modules.

**Modules:** `core`, `git`, `jj`, `nvim`, `wezterm`, `wm`, `ai`, `tools`, `apps`, `iterm`. Each module has a Brewfile in `brew/`, optional shell config in `zsh/`, and owns specific files in `home/` and `config/`.

**Symlink-based, no stow.** `install.sh` symlinks `home/*` to `~/` and recursively symlinks individual files in `config/*` to `~/.config/` (not whole directories, to avoid clobbering unmanaged files). Files are filtered by module ownership.

**Tool-specific managed directories:** `install.sh` also symlinks Claude files from `claude/` into `~/.claude/` (including module-specific rules from `claude/rules/`), Codex guidance from `codex/AGENTS.md` into `~/.codex/AGENTS.md`, Codex skills from `codex/skills/` into `~/.codex/skills/`, and iTerm2 profiles from `iterm/` into iTerm's DynamicProfiles directory.

**Layered config pattern:** Base configs are tracked in git. Machine-specific overrides go in `.local` files (git-ignored) with `.local.example` templates provided:
- `home/.gitconfig` includes `~/.gitconfig.local`
- `home/.zshrc` sources `~/.zshrc.local`
- `config/jj/conf.d/local.toml.example` for jj identity
- `brew/local.Brewfile` for machine-specific Homebrew packages

**Adding a new dotfile:** Place it in `home/` (for `~/`) or `config/` (for `~/.config/`), update the module mapping in `install.sh` if needed, then run `./install.sh`.

## Directory Layout

- `modules.conf.example` — template listing all modules; copy to `modules.conf` to customize
- `brew/` — per-module Brewfiles (`core.Brewfile`, `git.Brewfile`, etc.) + `local.Brewfile` (git-ignored)
- `zsh/` — per-module shell configs (`core.zsh`, `git.zsh`, `jj.zsh`, `tools.zsh`) symlinked to `~/.config/zsh/`
- `cheatsheet/` — per-module YAML cheatsheet entries; compiled on demand by `bin/cheatsheet` and displayed via `cs` alias
- `bin/` — repo scripts (e.g. `cheatsheet` compiler)
- `home/` — dotfiles symlinked to `~/` (zshrc, gitconfig, aerospace.toml, etc.)
- `config/` — configs symlinked to `~/.config/` (nvim, wezterm, jj, atuin, yazi, bat, delta)
- `config/starship-git.toml` / `config/starship-jj.toml` — starship prompt variants; install.sh picks based on jj module
- `config/wezterm/` — Wezterm terminal config; `projects.lua` is machine-specific (git-ignored), template at `projects.lua.example`. Projects support an optional `root` field for monorepo subdirectories — jj workspace discovery appends `-N` to root and preserves the relative subdir (e.g. `root=~/dev/Foo`, `cwd=~/dev/Foo/api` discovers `~/dev/Foo-1/api`)
- `config/nvim/` — Neovim config using lazy.nvim; plugins defined in `lua/plugins/init.lua`; uses native Neovim 0.11+ LSP API (no nvim-lspconfig)
- `claude/CLAUDE.md` — base user-scoped Claude Code instructions, symlinked to `~/.claude/CLAUDE.md`
- `claude/rules/` — module-specific Claude rules (e.g. `jj.md`), selectively symlinked to `~/.claude/rules/`
- `claude/hooks/wezterm/` — Claude hooks that depend on wezterm module
- `claude/agents/` — Claude Code custom agents, symlinked to `~/.claude/agents/`
- `codex/AGENTS.md` — user-scoped Codex instructions, symlinked to `~/.codex/AGENTS.md`
- `codex/skills/` — Codex custom skills, symlinked as top-level entries into `~/.codex/skills/`
- `iterm/` — iTerm2 dynamic profiles, symlinked to `~/Library/Application Support/iTerm2/DynamicProfiles/`
- `macos/` — macOS defaults script

## Conventions

- Shell is Zsh. The main `.zshrc` is a thin loader that sources `~/.config/zsh/*.zsh`. Custom functions are split by module: git functions (`gs`, `gbd`, `grm`, `gcm`) in `zsh/git.zsh`, jj functions (`js`, `jjs`, `jr`, `vb`, `jw-add`, `jw-rm`, `jw-list`) in `zsh/jj.zsh`, tool integrations in `zsh/tools.zsh`.
- Vim-style keybindings are used across tools (Wezterm, AeroSpace, Neovim) with modifier escalation: Ctrl-w (Neovim), Cmd (Wezterm), Alt (AeroSpace).
- `install.sh` backs up existing non-symlink files before overwriting.

## Version Control

This repo uses **jj (Jujutsu)**, not git. Use `jj` commands for all VCS operations.

- Run `jj new` before starting work to create a fresh revision — unlike git, jj automatically tracks all changes in the working copy.
- Each revision should be atomic — one logical change per revision. If a task has distinct parts (e.g. "add X" and "remove Y"), split them into separate revisions with their own descriptions.
- Describe revisions that contain an actual logical change with `jj describe -m "..."`.
- After `jj new`, leave the new empty `@` revision undescribed until the next real change starts. Do not invent placeholder descriptions like `chore: ready for next change`.
