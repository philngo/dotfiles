# History settings
export HISTSIZE=1000000000
export SAVEHIST=$HISTSIZE
setopt EXTENDED_HISTORY

# Shell options
setopt autocd

# Completions
autoload -U compinit; compinit

# mise (tool version manager)
eval "$(mise activate zsh)"

# Prompt
eval "$(starship init zsh)"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# This binds:
# - Up arrow (^[[A): Search backward through history for commands starting with your current input
# - Down arrow (^[[B): Search forward through matching commands
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

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


# expert is in here
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
alias vim="nvim"
alias sz="source ~/.zshrc && echo \"Sourced ~/.zshrc\""

# Personal cheatsheet viewer
cheatsheet() {
  less -R ~/.cheatsheet
}
alias cs="cheatsheet"

# Machine-specific overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
