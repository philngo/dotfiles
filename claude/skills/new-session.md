---
name: new-session
description: Prepare the dev environment for a new work session — fetch main, run migrations, create a fresh jj revision. Trigger on "/new-session" or "new session memory".
---

## Context

This is a **jj (Jujutsu)** repository. The primary repo root is `~/dev/Jump/`. Parallel workspaces like `~/dev/Jump-1/`, `~/dev/Jump-2/`, etc. are connected jj workspaces of the same repo — they can compile and run code but do NOT host the dev server.

Determine which workspace you're in from the working directory path. If it's `~/dev/Jump/` or `~/dev/Jump/api/`, you're in the default workspace. If it's `~/dev/Jump-N/` or `~/dev/Jump-N/api/`, you're in a parallel workspace — note this to the user.

## Steps

1. **Orient** — tell the user which jj workspace they're in (default vs parallel) and what that means (parallel = can compile/test but not run the dev server).

2. **Fetch latest main** — run `jj git fetch` from the repo root to get the latest remote state.

3. **Create a fresh revision off main** — run `jj new main` to start a new empty revision based on main. No need to describe it or create a bookmark yet.

4. **Run `mix setup` in the background** — from the `api/` subdirectory, run `mix setup` (which includes deps, compile, and migrations). Run this in the background so the conversation can continue immediately.

5. **Report status** — once `mix setup` completes, tell the user concisely:
   - "Ready to work" if everything succeeded, OR
   - The specific error if something failed (migration conflict, dep issue, etc.)

Keep all output concise. No need for headers or ceremony — just orient, prep, and report.
