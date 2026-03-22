# History settings
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

# Shell options
setopt autocd

# Completions
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Prompt
command -v starship &>/dev/null && eval "$(starship init zsh)"

# iTerm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Environment
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export LESS="-i"  # smart case-insensitive search (lowercase pattern = case-insensitive)
command -v nvim &>/dev/null && alias vim="nvim"
command -v eza &>/dev/null && alias ls="eza" && alias ll="eza -la" && alias tree="eza --tree --ignore-glob='__pycache__|*.pyc'"
command -v bat &>/dev/null && alias cat="bat --paging=never"
alias sz="source ~/.zshrc && echo \"Sourced ~/.zshrc\""

# Personal cheatsheet viewer (compiled from per-module YAML files)
cheatsheet() {
  local dotfiles_dir
  dotfiles_dir="$(cd "$(dirname "$(readlink "$HOME/.zshrc")")" && cd .. && pwd)"
  local output
  output=$("$dotfiles_dir/bin/cheatsheet")
  if command -v glow &>/dev/null; then
    echo "$output" | glow -p -
  else
    echo "$output" | less
  fi
}
alias cs="cheatsheet"

# zsh plugins (installed via Homebrew, no plugin manager needed)
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
