# Dotfiles

Personal macOS dotfiles. Module-based — pick what you need, skip what you don't.

Catppuccin Mocha everywhere. Vim keybindings everywhere.

## Quickstart

```bash
git clone https://github.com/philngo/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# Optional: choose your modules (defaults to all if skipped)
cp modules.conf.example modules.conf
vim modules.conf

# Install
./install.sh
```

`install.sh` is idempotent — safe to re-run anytime. It installs Homebrew (if needed), installs packages for enabled modules, and symlinks config files to the right places. If `modules.conf` doesn't exist, it defaults to `all`.

After install, follow the post-install reminders printed at the end (local config files, macOS defaults, etc.).

## Modules

| Module | What you get |
|--------|-------------|
| **core** | Zsh (history, completions, aliases), Starship prompt, bat, eza, fzf, fd, ripgrep, Nerd Font |
| **git** | Git config, delta (side-by-side diffs), lazygit, shell functions (`gs`, `gbd`, `grm`, `gcm`, `gf`) |
| **jj** | Jujutsu VCS config, jj-starship prompt, shell functions (`js`, `jjs`, `jr`, `vb`, `jw-add`, `jw-rm`, `jw-list`) |
| **nvim** | Neovim with lazy.nvim, 40+ plugins, LSP, Treesitter, Telescope |
| **wezterm** | WezTerm terminal — project workspaces, pane/tab keybindings, dev layouts |
| **wm** | AeroSpace tiling window manager + JankyBorders |
| **ai** | Claude Code + Codex — user instructions, agents, hooks, skills |
| **tools** | yazi, atuin, direnv, mise, zoxide, gh, glow, and more |
| **apps** | GUI apps — Slack, Zoom, VS Code, Spotify, Figma, Alfred, etc. |

Use `all` in `modules.conf` to enable everything (automatically picks up new modules):

```
all
```

Or list only what you need:

```
core
git
nvim
wezterm
ai
```

## Usage

### Cheatsheet

Run `cs` (or `cheatsheet`) to view keybindings for all tools in the terminal.

### Machine-specific config

Some settings vary per machine (git email, paths, etc.). These use `.local` files that aren't tracked:

```bash
cp ~/dev/dotfiles/home/.gitconfig.local.example ~/.gitconfig.local
cp ~/dev/dotfiles/home/.zshrc.local.example ~/.zshrc.local
cp ~/dev/dotfiles/config/jj/conf.d/local.toml.example ~/.config/jj/conf.d/local.toml
```

Machine-specific Homebrew packages go in `brew/local.Brewfile` (also git-ignored).

### Adding a new dotfile

1. Place it in `home/` (for `~/`) or `config/` (for `~/.config/`)
2. If it belongs to a specific module, add the mapping in `install.sh` (`home_module` or `config_module`)
3. Run `./install.sh`

### Adding a new module

1. Create `brew/<name>.Brewfile` with its packages
2. Optionally create `zsh/<name>.zsh` for shell integrations
3. Add config dirs/home files and update the mappings in `install.sh`
4. Add the module to `modules.conf.example`

Users with `all` in their `modules.conf` pick it up automatically.

### Updating packages

```bash
# Install packages for enabled modules
./install.sh

# Or manually for a specific Brewfile
brew bundle --file=brew/tools.Brewfile

# Capture currently installed packages (useful for auditing)
brew bundle dump --force
```

## Advanced

### How install.sh works

Symlink-based, no stow. `install.sh` reads `modules.conf`, then:

1. Concatenates `brew/<module>.Brewfile` for enabled modules → single `brew bundle`
2. Symlinks `home/*` → `~/`, filtered by module ownership
3. Recursively symlinks individual files in `config/*` → `~/.config/` (not whole directories, to avoid clobbering unmanaged files)
4. Symlinks `zsh/<module>.zsh` → `~/.config/zsh/` for enabled modules
5. Picks `starship-jj.toml` or `starship-git.toml` based on whether jj module is enabled
6. Symlinks Claude rules from `claude/rules/` for enabled modules (uses `~/.claude/rules/` directory)
7. Symlinks Claude hooks from `claude/hooks/<module>/` for enabled modules
8. Runs post-install steps (mise, yazi plugins, bat theme cache, etc.)

Existing non-symlink files are backed up to `*.backup` before overwriting.

### Directory layout

```
modules.conf.example        # All modules listed — copy to modules.conf
brew/                        # Per-module Brewfiles + local.Brewfile (git-ignored)
zsh/                         # Per-module shell configs → ~/.config/zsh/
  core.zsh                   #   history, completions, aliases, prompt, plugins
  git.zsh                    #   git functions (gs, gbd, grm, gcm)
  jj.zsh                     #   jj functions (js, jjs, jr, vb, jw-*)
  tools.zsh                  #   mise, direnv, zoxide, atuin, yazi
home/                        # Dotfiles → ~/
config/                      # Configs → ~/.config/
  starship-git.toml          #   prompt variant (git-only)
  starship-jj.toml           #   prompt variant (jj-starship)
  nvim/                      #   Neovim (lazy.nvim, plugins in lua/plugins/init.lua)
  wezterm/                   #   WezTerm (projects.lua is git-ignored)
  jj/                        #   Jujutsu VCS
  atuin/                     #   Shell history
  yazi/                      #   File manager
  bat/                       #   Syntax highlighting themes
  delta/                     #   Git diff pager themes
claude/
  CLAUDE.md                  # Base user instructions → ~/.claude/CLAUDE.md
  rules/jj.md               # jj workflow rules → ~/.claude/rules/ (if jj enabled)
  hooks/wezterm/             # Notification hooks (if wezterm enabled)
  agents/                    # Custom agents → ~/.claude/agents/
codex/
  AGENTS.md                  # User instructions → ~/.codex/AGENTS.md
  skills/                    # Custom skills → ~/.codex/skills/
iterm/                       # iTerm2 dynamic profiles
macos/defaults.sh            # macOS system preferences
docs/                        # Manual setup guides
```

### Claude Code notifications

When Claude Code is waiting for permission in one WezTerm workspace and you're in another, a macOS notification is sent. Clicking it switches to the right workspace.

Requires the `wezterm` module. The hooks (`claude-notify`, `wezterm-focus`) are in `claude/hooks/wezterm/` and only installed when that module is enabled.

### macOS defaults

```bash
./macos/defaults.sh
```

See `docs/manual-setup.md` for settings that can't be automated (trackpad, Touch ID, display arrangement, etc.).
