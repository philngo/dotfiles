#!/usr/bin/env bash
# Idempotent install script - safe to run multiple times.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing dotfiles from $DOTFILES_DIR"

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install packages from Brewfile
if [ -f "$DOTFILES_DIR/Brewfile" ]; then
    echo "Installing Homebrew packages..."
    brew bundle --file="$DOTFILES_DIR/Brewfile"
fi

# Symlink home directory dotfiles
echo "Symlinking home dotfiles..."
for file in "$DOTFILES_DIR"/home/.*; do
    [ -e "$file" ] || continue
    filename=$(basename "$file")
    [ "$filename" = "." ] || [ "$filename" = ".." ] && continue

    # Skip .local.example files (they're templates, not actual dotfiles)
    [[ "$filename" == *.local.example ]] && continue

    target="$HOME/$filename"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    ln -sf "$file" "$target"
    echo "  Linked $filename"
done

# Symlink config directory items
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

symlink_recursively "$DOTFILES_DIR/config" "$HOME/.config" ".config"

# Symlink Claude Code agents
if [ -d "$DOTFILES_DIR/claude/agents" ]; then
    echo "Symlinking Claude agents..."
    mkdir -p "$HOME/.claude/agents"
    for file in "$DOTFILES_DIR"/claude/agents/*; do
        [ -e "$file" ] || continue
        filename=$(basename "$file")
        target="$HOME/.claude/agents/$filename"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  Backing up existing $target to $target.backup"
            mv "$target" "$target.backup"
        fi
        ln -sf "$file" "$target"
        echo "  Linked .claude/agents/$filename"
    done
fi

# Install mise-managed tools (node, etc.)
if command -v mise &> /dev/null; then
    echo "Installing mise tools..."
    mise install --yes
fi

echo ""
echo "Done!"

# Collect pending post-install tasks
todos=()
if [ ! -f "$HOME/.gitconfig.local" ]; then
    todos+=("  cp $DOTFILES_DIR/home/.gitconfig.local.example ~/.gitconfig.local")
fi
if [ ! -f "$HOME/.zshrc.local" ]; then
    todos+=("  cp $DOTFILES_DIR/home/.zshrc.local.example ~/.zshrc.local")
fi
if [ ! -f "$HOME/.config/jj/conf.d/local.toml" ] && [ -f "$DOTFILES_DIR/config/jj/conf.d/local.toml.example" ]; then
    todos+=("  cp $DOTFILES_DIR/config/jj/conf.d/local.toml.example ~/.config/jj/conf.d/local.toml")
fi

if [ ${#todos[@]} -gt 0 ]; then
    echo ""
    echo "You may want to set up local configs (git email, etc.):"
    for todo in "${todos[@]}"; do
        echo "$todo"
    done
fi
echo ""
echo "Restart your shell to pick up new configurations."
