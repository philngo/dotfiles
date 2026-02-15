# History settings
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

# Shell options
setopt autocd

# Completions
autoload -U compinit; compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# mise (tool version manager)
eval "$(mise activate zsh)"

# direnv (per-directory environment variables)
eval "$(direnv hook zsh)"

# zoxide (smarter cd)
eval "$(zoxide init zsh)"

# Prompt
eval "$(starship init zsh)"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# This binds:
# - Up arrow (^[[A): Search backward through history for commands matching your current input up to the cursor
# - Down arrow (^[[B): Search forward through matching commands
autoload -U history-beginning-search-backward history-beginning-search-forward
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# fuzzy git branch switcher
gs() {
  git branch --sort=-committerdate | fzf --height 40% --reverse | xargs git switch
}

# fuzzy git branch deletion, with multiselect
gbd() {
  git branch --sort=-committerdate |
    grep -v "^\*" |
    grep -Ev "^\s*(main|master)$" |
    fzf --height 40% --reverse --multi \
        --header "Tab to select multiple, Enter to delete" |
    xargs -r git branch -d
}

# helper: determine the main branch (main or master)
get_main_branch() {
  local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')

  # Fallback if origin/HEAD is not set
  if [ -z "$main_branch" ]; then
    if git show-ref --verify --quiet refs/remotes/origin/main; then
      main_branch="main"
    else
      main_branch="master"
    fi
  fi

  echo "$main_branch"
}

# rebase current branch onto main/master (interactive)
grm() {
  local main_branch=$(get_main_branch)
  git fetch origin $main_branch:$main_branch && git rebase -i $main_branch
}

# checkout main/master and pull latest
gcm() {
  local main_branch=$(get_main_branch)
  git checkout $main_branch && git pull
}

# force push with lease (safer than --force)
alias gf="git push --force-with-lease"

# Environment
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
alias vim="nvim"
alias ls="eza"
alias ll="eza -la"
alias tree="eza --tree"
alias cat="bat --paging=never"
alias sz="source ~/.zshrc && echo \"Sourced ~/.zshrc\""

# Personal cheatsheet viewer
cheatsheet() {
  less -R ~/.cheatsheet
}
alias cs="cheatsheet"

# zsh plugins (installed via Homebrew, no plugin manager needed)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Machine-specific overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
