# Migrate projects.lua (2026-04-02)

The wezterm workspace auto-discovery now supports an optional `root` field for
monorepo subdirectories. This replaces the need for custom `agent_setup`
functions that exported per-workspace env vars.

## What to do

Replace your `~/.config/wezterm/projects.lua` with a simplified version. The
old `agent_setup` function and explicit `jump-ws-*` entries are no longer needed
— workspaces created via `jw-add` are auto-discovered using the `root` field.

### Before

```lua
local function agent_setup(n)
    -- ... complex env var export + 4-pane layout
end

return {
    { id = "jump-api", ..., setup = "dev" },
    { id = "jump-ws-1", ..., setup = agent_setup(1) },
    { id = "jump-ws-2", ..., setup = agent_setup(2) },
    { id = "infrastructure", ..., setup = "dev" },
}
```

### After

```lua
return {
    {
        id = "jump-api",
        label = "Jump API",
        root = os.getenv("HOME") .. "/dev/Jump",
        cwd = os.getenv("HOME") .. "/dev/Jump/api",
        setup = "dev",
    },
    {
        id = "infrastructure",
        label = "Infrastructure",
        cwd = os.getenv("HOME") .. "/dev/infrastructure",
        setup = "dev",
    },
}
```

The `root` field tells auto-discovery to append `-N` to the repo root (not the
cwd), preserving the subdirectory. So `root=~/dev/Jump`, `cwd=~/dev/Jump/api`
discovers `~/dev/Jump-1/api`, `~/dev/Jump-2/api`, etc.

## Cleanup

The old manually-created `~/dev/jump-ws-1` and `~/dev/jump-ws-2` directories
can be removed if they aren't jj workspaces created via `jw-add`. If they are,
they won't be auto-discovered (the convention is `Jump-1`, `Jump-2` — matching
what `jw-add` creates from `~/dev/Jump`).

## Delete this file

Once all machines are migrated, delete this file.
