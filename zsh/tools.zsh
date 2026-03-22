# mise (tool version manager)
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# direnv (per-directory environment variables)
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# zoxide (smarter cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Atuin - enhanced shell history (replaces up-arrow/Ctrl-R history search)
# Built-in zsh history (HISTFILE) still works alongside atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh)"

# yazi file manager wrapper (cd to dir on exit)
if command -v yazi &>/dev/null; then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi
