---
name: pr
description: Use when the user wants to create a GitHub pull request from the current jj revision. Handles pushing the bookmark, creating the PR with the repo's template, and cleaning up the working copy.
---

# Create a Pull Request

## Steps

1. **Verify the working copy.** Run `jj status` — `@` must have changes and a description. If empty or undescribed, stop and ask.

2. **Ensure a bookmark exists on `@`.** Run `jj bookmark list -r @`. If none, ask the user what to name it, then `jj bookmark create <name> -r @`. The bookmark name **must** start with `philngo/` (e.g. `philngo/fix-pagination`). If the user suggests a name without the prefix, prepend it automatically.

3. **Push the bookmark.** `jj git push --bookmark <name>`

4. **Find the repo root** (where `.git/` lives — may differ from cwd in secondary jj workspaces). Use `jj workspace root` to get the workspace root, then walk up until you find `.git/`. Fallback: `jj --config='revsets.short-prefixes=""' log -r @ --no-graph -T 'empty'` works from anywhere, but `gh` needs the `.git/` directory.

5. **Create the PR.** From the directory containing `.git/`:
   ```sh
   gh pr create \
     --base main \
     --head <bookmark> \
     --title "<jj description of @>" \
     --body-file <repo_root>/.github/pull_request_template.md
   ```

6. **Clean up.** `jj new` so the working copy is empty.

7. **Audit revisions.** Run `jj log -r 'ancestors(@-, 10) & ~ancestors(main)' --no-graph` to review all revisions in the PR. Check for:
   - **Descriptions:** Each must be a single-line conventional commit (`type: concise summary`, e.g. `fix: compute uses_count async`). Fix with `jj describe -r <rev> -m "..."`.
   - **Cohesion:** Every changed file in a revision must belong to that revision's description. If unrelated changes leaked in, split them out (`jj split -r <rev>`) or move them (`jj squash --from <src> --into <dst> -m "..."`).
   - **Unbookmarked revisions:** Any revision between `main` and the bookmark that has no bookmark of its own is suspicious — it may be leftover work that shouldn't be in this PR. Flag it.
   - **Scope:** If the PR touches unrelated concerns (e.g. a bug fix and a refactor that could ship independently), flag that it should be broken into separate PRs.
   - Re-push after any fixes.

8. **Run local lints.** Run the project's lint/compile checks locally and fix any failures. For Elixir projects:
   ```sh
   MIX_ENV=test mix compile --warnings-as-errors
   mix format --check-formatted
   mix credo
   ```
   Fix issues in-place (`jj squash` into the PR revision), re-push, and re-run until clean.

9. **Watch CI.** Monitor the PR's CI checks (`gh pr checks <number> --watch` or poll). If CI fails, read the failure, fix it, `jj squash`, re-push, and repeat until green.

10. **Code review.** Once lints and CI are green, invoke `/code-review` on the PR and report findings.

## Rules

- **Never write a custom PR body.** Always use `--body-file` with the repo's `pull_request_template.md`. Leave all placeholders empty for the user to fill in.
- **PR title** = the jj revision description verbatim.
- **`gh` must run from the `.git/` directory**, not from a secondary workspace or subdirectory without `.git/`.
- **Never add lint skip comments** (`# credo:disable-for-*`, `# nosec`, `# noinspection`, etc.) to suppress warnings. Fix the underlying issue instead.
