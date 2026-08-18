local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Appearance
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("FiraCode Nerd Font")
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_padding = { left = 12, right = 12, top = 12, bottom = 12 }
config.scrollback_lines = 100000

-- Tab bar
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 32

-- Catppuccin Mocha palette for tab bar
config.colors = {
	tab_bar = {
		background = "#1e1e2e",
		active_tab = {
			bg_color = "#a6e3a1",
			fg_color = "#1e1e2e",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#1e1e2e",
			fg_color = "#6c7086",
		},
		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
	},
}

-- Workspace switch via file-based IPC (used by Claude Code notification click handler)
local switch_file = os.getenv("HOME") .. "/.local/state/wezterm/switch-workspace"

local function check_workspace_switch(window)
	local f = io.open(switch_file, "r")
	if not f then return end
	local target = f:read("*l")
	f:close()
	os.remove(switch_file)
	if target and target ~= "" and target ~= window:active_workspace() then
		window:perform_action(act.SwitchToWorkspace({ name = target }), window:active_pane())
	end
end

wezterm.on("window-focus-changed", function(window, pane)
	if window:is_focused() then
		check_workspace_switch(window)
	end
end)

-- Show workspace name in right status
wezterm.on("update-right-status", function(window)
	check_workspace_switch(window)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#89b4fa" } },
		{ Text = " " .. window:active_workspace() .. " " },
	}))
end)

-- Named layouts (can be referenced by string in projects.lua)
local layouts = {
	-- Left half | top-right (2/3) / bottom-right split vertically (1/3)
	dev = function(initial_pane, cwd)
		local right = initial_pane:split({ direction = "Right", size = 0.5, cwd = cwd })
		right:send_text("claude\n")
		local bottom_right = right:split({ direction = "Bottom", size = 0.34, cwd = cwd })
		bottom_right:split({ direction = "Right", size = 0.5, cwd = cwd })
	end,
}

-- Base projects (tracked in git, available on all machines)
local base_projects = {
	{
		id = "dotfiles",
		label = "Dotfiles",
		cwd = os.getenv("HOME") .. "/dev/dotfiles",
		setup = "dev",
	},
	{
		id = "throwaway",
		label = "Throwaway",
		cwd = os.getenv("HOME") .. "/dev/throwaway",
		setup = "dev",
	},
}

-- Auto-discover jj workspace directories (sibling dirs like project-1, project-2)
-- If a project has a `root` field (repo root differs from cwd), the suffix is
-- appended to root and the relative subdir is preserved:
--   root=~/dev/Jump, cwd=~/dev/Jump/api → discovers ~/dev/Jump-1/api
local function discover_workspaces(project_list)
	local result = {}
	for _, p in ipairs(project_list) do
		table.insert(result, p)
		local base = p.root or p.cwd
		local subdir = ""
		if p.root and p.cwd:sub(1, #p.root) == p.root then
			subdir = p.cwd:sub(#p.root + 1)
		end
		for i = 1, 9 do
			local ws_cwd = base .. "-" .. i .. subdir
			if pcall(wezterm.read_dir, ws_cwd) then
				table.insert(result, {
					id = p.id .. "_" .. i,
					label = p.label .. " (WS " .. i .. ")",
					cwd = ws_cwd,
					setup = p.setup,
				})
			end
		end
	end
	return result
end

-- Resolve jj binary path (Wezterm may not inherit shell PATH)
local jj_path = (function()
	local ok, stdout, _ = wezterm.run_child_process({ "/bin/zsh", "-lc", "which jj" })
	if ok and stdout then
		local path = stdout:gsub("%s+$", "")
		if #path > 0 then return path end
	end
	return nil
end)()

-- Run a jj log query in the given directory, return trimmed output or nil.
-- Uses cd (not -R) so jj traverses up from subdirectories to find the repo root.
local function jj_query(cwd, revset, template)
	if not jj_path then return nil end
	local cmd = string.format(
		"cd %q && %q log -r %q --no-graph --ignore-working-copy -T %q --limit 1",
		cwd, jj_path, revset, template
	)
	local ok, stdout, _ = wezterm.run_child_process({ "/bin/bash", "-c", cmd })
	if ok and stdout then
		local result = stdout:gsub("%s+$", "")
		if #result > 0 then return result end
	end
	return nil
end

-- Get VCS context for a project directory.
-- Cascade: jj bookmark → jj commit description → git branch
local function get_vcs_context(cwd)
	-- jj: bookmark on @- or @ (covers both "@ is empty" and mid-work cases)
	local ctx = jj_query(cwd, "@-", 'bookmarks.join(", ")')
		or jj_query(cwd, "@", 'bookmarks.join(", ")')
	if ctx then return ctx end

	-- jj: description of unbookmarked work
	ctx = jj_query(cwd, "@-", "description.first_line()")
		or jj_query(cwd, "@", "description.first_line()")
	if ctx then return ctx end

	-- Git fallback: current branch name
	local cmd = string.format("cd %q && git branch --show-current 2>/dev/null", cwd)
	local ok, stdout, _ = wezterm.run_child_process({ "/bin/bash", "-c", cmd })
	if ok and stdout then
		local result = stdout:gsub("%s+$", "")
		if #result > 0 then return result end
	end

	return nil
end

-- Project selector
local function project_selector()
	local ok, local_projects = pcall(require, "projects")
	local projects = discover_workspaces(base_projects)
	if ok then
		for _, p in ipairs(discover_workspaces(local_projects)) do
			table.insert(projects, p)
		end
	end
	-- Resolve string setup names to layout functions
	for _, p in ipairs(projects) do
		if type(p.setup) == "string" then
			p.setup = layouts[p.setup]
		end
	end

	-- Collect VCS context and compute max label width for alignment
	local contexts = {}
	local max_label_len = 0
	for i, project in ipairs(projects) do
		contexts[i] = get_vcs_context(project.cwd)
		if contexts[i] and #project.label > max_label_len then
			max_label_len = #project.label
		end
	end

	local choices = {}
	for i, project in ipairs(projects) do
		local label = project.label
		if contexts[i] then
			label = label .. string.rep(" ", max_label_len - #label) .. " — " .. contexts[i]
		end
		table.insert(choices, {
			id = project.id,
			label = label,
		})
	end

	return act.InputSelector({
		title = "Projects",
		choices = choices,
		action = wezterm.action_callback(function(window, pane, id, label)
			if not id then
				return
			end
			for _, project in ipairs(projects) do
				if project.id == id then
					if project.setup then
						local exists = false
						for _, name in ipairs(wezterm.mux.get_workspace_names()) do
							if name == project.id then
								exists = true
								break
							end
						end
						if not exists then
							local tab, initial_pane, _ = wezterm.mux.spawn_window({
								workspace = project.id,
								cwd = project.cwd,
							})
							window:perform_action(act.SwitchToWorkspace({ name = project.id }), pane)
							wezterm.time.call_after(0.1, function()
								project.setup(initial_pane, project.cwd)
							end)
							return
						end
						window:perform_action(act.SwitchToWorkspace({ name = project.id }), pane)
					else
						window:perform_action(
							act.SwitchToWorkspace({
								name = project.id,
								spawn = {
									cwd = project.cwd,
									args = project.args,
								},
							}),
							pane
						)
					end
					return
				end
			end
		end),
	})
end

-- Disable default keybindings, rebuild from scratch
config.disable_default_key_bindings = true

-- Ctrl+click always opens links, even when the foreground program
-- (e.g. Claude Code's TUI) has grabbed mouse reporting.
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.Nop,
	},
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = act.OpenLinkAtMouseCursor,
	},
}

config.keys = {
	-- Pane: split
	{ key = "d", mods = "CMD", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "CMD|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

	-- Pane: navigate
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },

	-- Pane: resize
	{ key = "h", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "j", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "k", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "l", mods = "CMD|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },

	-- Pane: zoom / close
	{ key = "z", mods = "CMD", action = act.TogglePaneZoomState },
	{ key = "w", mods = "CMD", action = act.CloseCurrentPane({ confirm = false }) },

	-- Tab: new / close
	{ key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "CMD|SHIFT", action = act.CloseCurrentTab({ confirm = false }) },

	-- Tab: navigate
	{ key = "]", mods = "CMD", action = act.ActivateTabRelative(1) },
	{ key = "[", mods = "CMD", action = act.ActivateTabRelative(-1) },

	-- Tab: move
	{ key = "]", mods = "CMD|SHIFT", action = act.MoveTabRelative(1) },
	{ key = "[", mods = "CMD|SHIFT", action = act.MoveTabRelative(-1) },

	-- Tab: go to 1-9
	{ key = "1", mods = "CMD", action = act.ActivateTab(0) },
	{ key = "2", mods = "CMD", action = act.ActivateTab(1) },
	{ key = "3", mods = "CMD", action = act.ActivateTab(2) },
	{ key = "4", mods = "CMD", action = act.ActivateTab(3) },
	{ key = "5", mods = "CMD", action = act.ActivateTab(4) },
	{ key = "6", mods = "CMD", action = act.ActivateTab(5) },
	{ key = "7", mods = "CMD", action = act.ActivateTab(6) },
	{ key = "8", mods = "CMD", action = act.ActivateTab(7) },
	{ key = "9", mods = "CMD", action = act.ActivateTab(8) },

	-- Project selector
	{ key = "p", mods = "CMD", action = wezterm.action_callback(function(window, pane)
		window:perform_action(project_selector(), pane)
	end) },

	-- Copy mode
	{ key = "x", mods = "CMD|SHIFT", action = act.ActivateCopyMode },

	-- Clipboard
	{ key = "c", mods = "CMD", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CMD", action = act.PasteFrom("Clipboard") },

	-- Search
	{ key = "f", mods = "CMD", action = act.Search("CurrentSelectionOrEmptyString") },

	-- Font size
	{ key = "-", mods = "CMD", action = act.DecreaseFontSize },
	{ key = "=", mods = "CMD", action = act.IncreaseFontSize },
	{ key = "0", mods = "CMD", action = act.ResetFontSize },

	-- Reload config
	{ key = "r", mods = "CMD|SHIFT", action = act.ReloadConfiguration },

	-- Window
	{ key = "n", mods = "CMD", action = act.SpawnWindow },

	-- Quit
	{ key = "q", mods = "CMD", action = act.QuitApplication },

	-- Shift+Enter: send CSI u encoded sequence so TUI apps (e.g. Claude Code) can distinguish it from plain Enter
	{ key = "Enter", mods = "SHIFT", action = act.SendString("\x1b[13;2u") },
}

return config
