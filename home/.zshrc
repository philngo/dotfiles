# Source all enabled module configs
for f in "$HOME"/.config/zsh/*.zsh(N); do
  source "$f"
done

# Machine-specific overrides (not tracked in git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
