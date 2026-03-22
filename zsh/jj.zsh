command -v jj &>/dev/null || return 0

# fuzzy jj bookmark switcher
js() {
  local selection
  selection=$(jj bookmark list 2>/dev/null |
    grep -v '@' |
    fzf --height 40% --reverse) || return
  jj edit "${selection%%:*}"
}

# fetch main from remote, rebase all mutable revisions onto updated main
jjs() {
  jj git fetch --bookmark main
  if [[ -n $(jj log -r 'mine() ~ immutable()' --no-graph -T 'change_id' 2>/dev/null) ]]; then
    jj rebase -s 'roots(mine() ~ immutable())' -d main
  fi
}

# fetch a specific remote bookmark (for reviewing someone else's branch)
jr() { jj git fetch --bookmark "$1"; }

# open all files changed in the branch
vb() {
  local files=(${(f)"$(jj diff --from 'trunk()' --name-only)"})
  if (( ${#files} == 0 )); then
    echo "No changed files between trunk and @"
    return 1
  fi
  nvim "${files[@]}"
}

# jj workspace management
# Create a sibling workspace: ~/dev/project → ~/dev/project-<suffix>
jw-add() {
  local suffix="${1:-1}"
  jj root &>/dev/null || { echo "Not in a jj repo"; return 1; }
  local root=$(jj root)
  local ws_path="$(dirname "$root")/$(basename "$root")-${suffix}"
  if [[ -d "$ws_path" ]]; then
    echo "Already exists: $ws_path"
    return 1
  fi
  jj workspace add "$ws_path" --name "$(basename "$root")-${suffix}"
  touch ~/.config/wezterm/projects.lua 2>/dev/null
  echo "Created workspace at $ws_path"
}

# Remove a sibling workspace
jw-rm() {
  local suffix="${1:-1}"
  jj root &>/dev/null || { echo "Not in a jj repo"; return 1; }
  local root=$(jj root)
  local name="$(basename "$root")-${suffix}"
  local ws_path="$(dirname "$root")/${name}"
  jj workspace forget "$name" 2>/dev/null
  if [[ -d "$ws_path" ]]; then
    rm -rf "$ws_path"
    echo "Removed workspace: $ws_path"
  else
    echo "Forgot workspace '$name' (no directory found)"
  fi
  touch ~/.config/wezterm/projects.lua 2>/dev/null
}

# List workspaces
jw-list() { jj workspace list; }
