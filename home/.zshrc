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

# rebase current branch onto main (interactive)
grm() {
  git fetch origin main:main && git rebase -i main
}

# checkout main and pull latest
alias gcm="git checkout main && git pull"

# force push with lease (safer than --force)
alias gf="git push --force-with-lease"


# expert is in here
export PATH="$HOME/.local/bin:$PATH"
alias vim="nvim"
alias sz="source ~/.zshrc && echo \"Sourced ~/.zshrc\""

# Machine-specific overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
