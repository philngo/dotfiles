#!/usr/bin/env bash
# Claude Code status line: renders the same starship prompt the shell uses,
# followed by the active model. Reads Claude's status JSON on stdin.
#
# Deliberately dependency-tolerant so the same file works on every machine:
# jq (tools module) and starship (core module) are each optional, and the
# directory comes from Claude rather than the process cwd. Nothing here may
# hardcode a home directory -- see claude/agents/dotfiles.md.
set -uo pipefail

input=$(cat)

dir=""
model=""
if command -v jq &>/dev/null; then
    dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty' 2>/dev/null)
    model=$(printf '%s' "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
fi
[ -n "$dir" ] || dir="$PWD"

# STARSHIP_SHELL must be cleared: the shell's starship init exports it, and a
# set value makes starship wrap colors in shell-specific prompt escapes
# (%{..%} for zsh, \[..\] for bash) that a status line renders literally.
# Unset, starship emits plain ANSI.
#
# The output is also multi-line -- a leading blank from add_newline, the module
# row, then the prompt character -- so take the first non-empty line and drop
# any trailing glyph left over from single-line configs.
line=""
if command -v starship &>/dev/null; then
    line=$(env -u STARSHIP_SHELL starship prompt \
        --path "$dir" --status 0 --cmd-duration 0 2>/dev/null \
        | awk 'NF {print; exit}')
    line=${line%❯ }
    line=${line%❯}
    line=${line%"${line##*[![:space:]]}"}
fi

# Fall back to a tilde-abbreviated path when starship is unavailable.
if [ -z "${line//[[:space:]]/}" ]; then
    line="${dir/#$HOME/~}"
fi

[ -n "$model" ] && line="$line  $model"

printf '%s' "$line"
