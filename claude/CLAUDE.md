# User Preferences

## Version Control: jj (Jujutsu)

I use **jj (Jujutsu)** as my primary version control system. Many of my repos are jj repos colocated with git. When you see a `.jj/` directory, use `jj` commands instead of `git`.

### Detecting jj

Check for a `.jj/` directory in the repo root. If present, use jj. If only `.git/` exists, use git.

### Workflow

1. **Describe before editing** — before making changes, run `jj describe -m "..."` to state the intended change. This anchors the scope and keeps revisions atomic. After completing the work, verify the diff matches the description.
2. **Prefer small, atomic revisions** — it's easier to squash small revisions together than to split large ones apart. When a task has distinct parts, use separate revisions.
3. **Use conventional commit descriptions** — e.g. `feat: add dark mode toggle`, `fix: correct off-by-one in pagination`. One line is usually enough; add a body only for complex changes.
4. **Finish with an empty working copy** — when done with a change, ensure `@` is empty by running either `jj new` (to start a fresh revision) or `jj squash` (to fold changes into the parent, when that makes sense). This prevents accidentally polluting a completed revision when the next edit session begins.

### Common Commands

| Task | Command |
|------|---------|
| Create new revision | `jj new` |
| Describe current revision | `jj describe -m "..."` |
| View log | `jj log` |
| View diff | `jj diff` |
| Fetch from remote | `jj git fetch` |
| Push to remote | `jj git push` |
| Rebase onto main | `jj rebase -d main` |
| Move bookmark to parent | `jj bookmark move --from trunk() --to @-` |
| Split a revision | `jj split` |
| Squash into parent | `jj squash` |

### Bookmarks (not branches)

jj uses **bookmarks** instead of git branches. To push work, create or move a bookmark and then `jj git push`.

### Key Differences from git

- No staging area — all file changes are automatically part of the current revision.
- The working copy (`@`) is always a revision. `jj new` creates an empty child revision to work in.
- `jj squash` moves changes from `@` into `@-` (the parent). This is the common "amend" pattern.
- Revisions are identified by change IDs (short letters like `kxqpmlso`), not commit hashes.
- Multiple revisions can be in-flight at once; use `jj edit <change-id>` to switch between them.
