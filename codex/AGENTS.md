# User Preferences

## Bookmark Naming

Bookmark names should always start with `philn/` (5 chars, not `phil/`).

## Version Control: jj (Jujutsu)

I use `jj` instead of git. Check for a `.jj/` directory in the repo root. If present, use `jj` commands instead of `git`. jj uses bookmarks instead of branches.

### Workflow

1. Check `jj status`/`jj diff` before starting. If `@` is not empty, deal with existing changes first with `jj new` to leave them behind, or `jj squash` to fold them into the parent. jj has no staging area, so every edit is automatically part of `@`.
2. Describe before editing once the change is known. Run `jj describe -m "..."` before making changes, then verify the final diff still matches the description.
3. One logical change equals one revision. For multi-phase work, run `jj new` and `jj describe` at each phase boundary instead of accumulating unrelated edits in one revision.
4. Use conventional commit descriptions such as `feat: add dark mode toggle` or `fix: correct off-by-one in pagination`.
5. Finish with an empty working copy. Run `jj new` when done so `@` is empty for the next session, and leave that fresh empty revision undescribed until the next real change starts.
6. Always pass `-m` when squashing described revisions. Use `jj squash -m "..."` to avoid dropping into an interactive editor.
7. Do not invent placeholder descriptions for an empty revision, such as `chore: ready for next change`.
