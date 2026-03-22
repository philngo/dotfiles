#!/usr/bin/env bash
# Idempotent install script - safe to run multiple times.
# Reads modules.conf to determine which components to install.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_FILE="$DOTFILES_DIR/modules.conf"

echo "Installing dotfiles from $DOTFILES_DIR"

# --- Load enabled modules ---

if [ ! -f "$MODULES_FILE" ]; then
    echo "No modules.conf found. Creating with 'all' modules enabled."
    echo "Edit modules.conf to customize, then re-run."
    echo "all" > "$MODULES_FILE"
fi

enabled_modules=()
all_modules=false
while IFS= read -r line; do
    line="${line%%#*}"         # strip comments
    line="$(echo "$line" | tr -d '[:space:]')"  # strip whitespace
    [ -n "$line" ] && enabled_modules+=("$line")
    [ "$line" = "all" ] && all_modules=true
done < "$MODULES_FILE"

module_enabled() {
    $all_modules && return 0
    local mod="$1"
    for m in "${enabled_modules[@]}"; do
        [ "$m" = "$mod" ] && return 0
    done
    return 1
}

if $all_modules; then
    echo "Enabled modules: all"
else
    echo "Enabled modules: ${enabled_modules[*]}"
fi

# --- Module-to-file mappings ---
# Returns the module that owns a config directory (empty = always install)
config_module() {
    case "$1" in
        bat)       echo "core" ;;
        delta)     echo "git" ;;
        jj)        echo "jj" ;;
        nvim)      echo "nvim" ;;
        wezterm)   echo "wezterm" ;;
        atuin)     echo "tools" ;;
        yazi)      echo "tools" ;;
        zsh)       echo "_skip" ;;  # handled separately
        *)         echo "" ;;
    esac
}

# Returns the module that owns a home dotfile (empty = always install)
home_module() {
    case "$1" in
        .zshrc|.zprofile) echo "core" ;;
        .gitconfig|.gitignore)           echo "git" ;;
        .aerospace.toml)                 echo "wm" ;;
        .mise.toml)                      echo "tools" ;;
        *)                               echo "" ;;
    esac
}

# --- Helper: safe symlink with backup ---
safe_link() {
    local src="$1" target="$2" label="$3"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    ln -sf "$src" "$target"
    echo "  Linked $label"
}

# --- Install Homebrew if not present ---

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# --- Install packages from per-module Brewfiles ---

echo "Installing Homebrew packages..."
tmpfile=$(mktemp)
if $all_modules; then
    for bf in "$DOTFILES_DIR"/brew/*.Brewfile; do
        [ -f "$bf" ] || continue
        cat "$bf" >> "$tmpfile"
        echo "" >> "$tmpfile"
    done
else
    for mod in "${enabled_modules[@]}"; do
        bf="$DOTFILES_DIR/brew/${mod}.Brewfile"
        if [ -f "$bf" ]; then
            cat "$bf" >> "$tmpfile"
            echo "" >> "$tmpfile"
        fi
    done
fi
# Include machine-specific local Brewfile if present
if [ -f "$DOTFILES_DIR/brew/local.Brewfile" ]; then
    cat "$DOTFILES_DIR/brew/local.Brewfile" >> "$tmpfile"
fi
if [ -s "$tmpfile" ]; then
    brew bundle --file="$tmpfile"
fi
rm -f "$tmpfile"

# --- Symlink home directory dotfiles (module-filtered) ---

echo "Symlinking home dotfiles..."
for file in "$DOTFILES_DIR"/home/.*; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")
    [ "$filename" = "." ] || [ "$filename" = ".." ] && continue

    # Skip .local.example files (they're templates, not actual dotfiles)
    [[ "$filename" == *.local.example ]] && continue

    mod=$(home_module "$filename")
    if [ -n "$mod" ] && ! module_enabled "$mod"; then
        echo "  Skipping $filename (module '$mod' not enabled)"
        continue
    fi

    safe_link "$file" "$HOME/$filename" "$filename"
done

# --- Symlink config directory items (module-filtered) ---
# Note: We symlink individual files (not directories) so we don't clobber
# user files that aren't managed by dotfiles.

echo "Symlinking config dotfiles..."
mkdir -p "$HOME/.config"

symlink_recursively() {
    local src_dir="$1"
    local dest_dir="$2"
    local prefix="$3"

    for item in "$src_dir"/*; do
        [ -e "$item" ] || continue
        local name=$(basename "$item")
        local target="$dest_dir/$name"

        if [ -d "$item" ]; then
            mkdir -p "$target"
            symlink_recursively "$item" "$target" "$prefix/$name"
        else
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                echo "  Backing up existing $target to $target.backup"
                mv "$target" "$target.backup"
            fi
            ln -sf "$item" "$target"
            echo "  Linked $prefix/$name"
        fi
    done
}

for item in "$DOTFILES_DIR"/config/*; do
    [ -e "$item" ] || continue
    name=$(basename "$item")

    # Skip zsh dir (handled separately below)
    [ "$name" = "zsh" ] && continue

    # Skip starship variants (handled separately below)
    [[ "$name" == starship-*.toml ]] && continue

    mod=$(config_module "$name")
    if [ "$mod" = "_skip" ]; then
        continue
    elif [ -n "$mod" ] && ! module_enabled "$mod"; then
        echo "  Skipping config/$name (module '$mod' not enabled)"
        continue
    fi

    if [ -d "$item" ]; then
        symlink_recursively "$item" "$HOME/.config/$name" ".config/$name"
    else
        safe_link "$item" "$HOME/.config/$name" ".config/$name"
    fi
done

# --- Starship config (variant selection) ---

echo "Symlinking starship config..."
if module_enabled "jj"; then
    safe_link "$DOTFILES_DIR/config/starship-jj.toml" "$HOME/.config/starship.toml" ".config/starship.toml (jj variant)"
else
    safe_link "$DOTFILES_DIR/config/starship-git.toml" "$HOME/.config/starship.toml" ".config/starship.toml (git variant)"
fi

# --- Zsh module files ---

echo "Symlinking zsh modules..."
mkdir -p "$HOME/.config/zsh"

# Clean stale zsh module symlinks (from previously-enabled modules)
for existing in "$HOME"/.config/zsh/*.zsh; do
    [ -L "$existing" ] || continue
    link_target=$(readlink "$existing")
    if [[ "$link_target" == "$DOTFILES_DIR/zsh/"* ]]; then
        rm "$existing"
    fi
done

# Install enabled module zsh files
if $all_modules; then
    for src in "$DOTFILES_DIR"/zsh/*.zsh; do
        [ -f "$src" ] || continue
        name=$(basename "$src")
        safe_link "$src" "$HOME/.config/zsh/$name" ".config/zsh/$name"
    done
else
    for mod in "${enabled_modules[@]}"; do
        src="$DOTFILES_DIR/zsh/${mod}.zsh"
        [ -f "$src" ] || continue
        safe_link "$src" "$HOME/.config/zsh/${mod}.zsh" ".config/zsh/${mod}.zsh"
    done
fi

# --- Claude Code config (module-aware) ---

if module_enabled "ai"; then
    echo "Symlinking Claude config..."
    mkdir -p "$HOME/.claude"

    # Symlink base CLAUDE.md
    safe_link "$DOTFILES_DIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md" ".claude/CLAUDE.md"

    # Symlink module-specific Claude rules
    if [ -d "$DOTFILES_DIR/claude/rules" ]; then
        mkdir -p "$HOME/.claude/rules"

        # Clean stale rule symlinks
        for existing in "$HOME"/.claude/rules/*; do
            [ -L "$existing" ] || continue
            link_target=$(readlink "$existing")
            if [[ "$link_target" == "$DOTFILES_DIR/claude/rules/"* ]]; then
                rm "$existing"
            fi
        done

        for rule in "$DOTFILES_DIR"/claude/rules/*; do
            [ -f "$rule" ] || continue
            rule_name=$(basename "$rule" .md)

            # Only install rule if its module is enabled
            if module_enabled "$rule_name"; then
                safe_link "$rule" "$HOME/.claude/rules/$rule_name.md" ".claude/rules/$rule_name.md"
            else
                echo "  Skipping .claude/rules/$rule_name.md (module '$rule_name' not enabled)"
            fi
        done
    fi

    # Symlink non-generated files (keybindings.json, settings.json, etc.)
    for file in "$DOTFILES_DIR"/claude/*.json; do
        [ -e "$file" ] || continue
        filename=$(basename "$file")
        safe_link "$file" "$HOME/.claude/$filename" ".claude/$filename"
    done

    # Symlink Claude agents
    if [ -d "$DOTFILES_DIR/claude/agents" ]; then
        mkdir -p "$HOME/.claude/agents"
        for file in "$DOTFILES_DIR"/claude/agents/*; do
            [ -e "$file" ] || continue
            filename=$(basename "$file")
            safe_link "$file" "$HOME/.claude/agents/$filename" ".claude/agents/$filename"
        done
    fi

    # Symlink Claude hooks (module-filtered)
    mkdir -p "$HOME/.claude/hooks"
    # Module-specific hooks (in subdirectories named after modules)
    for hookdir in "$DOTFILES_DIR"/claude/hooks/*/; do
        [ -d "$hookdir" ] || continue
        mod=$(basename "$hookdir")
        if ! module_enabled "$mod"; then
            echo "  Skipping claude hooks/$mod/ (module '$mod' not enabled)"
            continue
        fi
        for file in "$hookdir"*; do
            [ -f "$file" ] || continue
            filename=$(basename "$file")
            safe_link "$file" "$HOME/.claude/hooks/$filename" ".claude/hooks/$filename (from $mod)"
            chmod +x "$file"
        done
    done
fi

# --- Codex config ---

if module_enabled "ai"; then
    echo "Symlinking Codex guidance..."
    mkdir -p "$HOME/.codex"

    # Symlink AGENTS.md (single file, jj instructions self-guard with .jj/ check)
    if [ -f "$DOTFILES_DIR/codex/AGENTS.md" ]; then
        safe_link "$DOTFILES_DIR/codex/AGENTS.md" "$HOME/.codex/AGENTS.md" ".codex/AGENTS.md"
    fi

    # Symlink skills
    if [ -d "$DOTFILES_DIR/codex/skills" ]; then
        echo "Symlinking Codex skills..."
        mkdir -p "$HOME/.codex/skills"
        for skill in "$DOTFILES_DIR"/codex/skills/*; do
            [ -e "$skill" ] || continue
            skill_name=$(basename "$skill")
            target="$HOME/.codex/skills/$skill_name"
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                echo "  Backing up existing $target to $target.backup"
                mv "$target" "$target.backup"
            fi
            ln -sfn "$skill" "$target"
            echo "  Linked .codex/skills/$skill_name"
        done
    fi
fi

# --- iTerm2 dynamic profiles ---

if module_enabled "iterm" && [ -d "$DOTFILES_DIR/iterm" ]; then
    echo "Symlinking iTerm2 dynamic profiles..."
    mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    for file in "$DOTFILES_DIR"/iterm/*.json; do
        [ -e "$file" ] || continue
        filename=$(basename "$file")
        safe_link "$file" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/$filename" "iTerm2/DynamicProfiles/$filename"
    done
fi

# --- Post-install: runtime tools ---

if module_enabled "tools" && command -v mise &> /dev/null; then
    echo "Installing mise tools..."
    mise install --yes
fi

if module_enabled "tools" && command -v ya &> /dev/null; then
    echo "Installing yazi packages..."
    ya pkg install
fi

if module_enabled "core" && command -v bat &> /dev/null; then
    echo "Rebuilding bat theme cache..."
    bat cache --build
fi

if module_enabled "ai" && ! command -v claude &> /dev/null; then
    echo "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
fi

if module_enabled "tools" && command -v atuin &> /dev/null; then
    echo "Importing shell history into atuin..."
    atuin import auto
fi

# Ensure WezTerm IPC state directory exists
if module_enabled "wezterm"; then
    mkdir -p "$HOME/.local/state/wezterm"
fi

echo ""
echo "Done!"

# --- Post-install reminders ---

todos=()
if module_enabled "git" && [ ! -f "$HOME/.gitconfig.local" ]; then
    todos+=("  cp $DOTFILES_DIR/home/.gitconfig.local.example ~/.gitconfig.local")
fi
if [ ! -f "$HOME/.zshrc.local" ]; then
    todos+=("  cp $DOTFILES_DIR/home/.zshrc.local.example ~/.zshrc.local")
fi
if module_enabled "jj" && [ ! -f "$HOME/.config/jj/conf.d/local.toml" ] && [ -f "$DOTFILES_DIR/config/jj/conf.d/local.toml.example" ]; then
    todos+=("  cp $DOTFILES_DIR/config/jj/conf.d/local.toml.example ~/.config/jj/conf.d/local.toml")
fi
if module_enabled "wezterm" && [ ! -f "$HOME/.config/wezterm/projects.lua" ]; then
    todos+=("  cp $DOTFILES_DIR/config/wezterm/projects.lua.example ~/.config/wezterm/projects.lua")
fi

if [ ${#todos[@]} -gt 0 ]; then
    echo ""
    echo "Post-install reminders:"
    for todo in "${todos[@]}"; do
        echo "$todo"
    done
fi
echo ""
echo "Restart your shell to pick up new configurations."
