# User Preferences

## Version Control: jj (Jujutsu)

I use **jj (Jujutsu)** instead of git. Check for a `.jj/` directory in the repo root. If present, use `jj` commands instead of `git`. jj uses **bookmarks** instead of branches.

### Workflow

1. **Check `jj status`/`jj diff` before starting** — if `@` is not empty, deal with existing changes first (`jj new` to leave them behind, or `jj squash` to fold into parent). **jj has no staging area — every edit is automatically part of `@`.** Skipping this step mixes unrelated changes together under the wrong description, making review extremely difficult.
2. **Describe before editing** — run `jj describe -m "..."` before making changes. After completing work, verify the diff matches the description.
3. **One logical change = one revision** — for multi-step plans, run `jj new` + `jj describe` at each phase boundary. Do NOT accumulate multiple phases into a single revision.
4. **Use conventional commit descriptions** — e.g. `feat: add dark mode toggle`, `fix: correct off-by-one in pagination`.
5. **Finish with an empty working copy** — run `jj new` when done so `@` is empty. This prevents polluting a completed revision in the next session.
