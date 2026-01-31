#!/usr/bin/env bash
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
echo "Symlinking config dotfiles..."
mkdir -p "$HOME/.config"

# Symlink directories (e.g., nvim/)
for dir in "$DOTFILES_DIR"/config/*/; do
    [ -d "$dir" ] || continue
    dirname=$(basename "$dir")

    target="$HOME/.config/$dirname"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    ln -sf "$dir" "$target"
    echo "  Linked .config/$dirname"
done

# Symlink files (e.g., starship.toml)
for file in "$DOTFILES_DIR"/config/*; do
    [ -f "$file" ] || continue
    filename=$(basename "$file")

    target="$HOME/.config/$filename"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "  Backing up existing $target to $target.backup"
        mv "$target" "$target.backup"
    fi
    ln -sf "$file" "$target"
    echo "  Linked .config/$filename"
done

echo ""
echo "Done! You may want to:"
echo "  - Set up local configs (git email, etc.):"
echo "      cp $DOTFILES_DIR/home/.gitconfig.local.example ~/.gitconfig.local"
echo "      cp $DOTFILES_DIR/home/.zshrc.local.example ~/.zshrc.local"
echo "  - Run ./macos/defaults.sh to apply macOS settings"
echo "  - Restart your shell to pick up new configurations"
