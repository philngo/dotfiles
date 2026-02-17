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

-- Show workspace name in right status
wezterm.on("update-right-status", function(window)
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#89b4fa" } },
		{ Text = " " .. window:active_workspace() .. " " },
	}))
end)

-- Left half | top-right (2/3) / bottom-right split vertically (1/3)
local function dev_layout(initial_pane, cwd)
	local right = initial_pane:split({ direction = "Right", size = 0.5, cwd = cwd })
	right:send_text("claude\n")
	local bottom_right = right:split({ direction = "Bottom", size = 0.34, cwd = cwd })
	bottom_right:split({ direction = "Right", size = 0.5, cwd = cwd })
end

-- Base projects (tracked in git, available on all machines)
local base_projects = {
	{
		id = "dotfiles",
		label = "Dotfiles",
		cwd = os.getenv("HOME") .. "/dev/dotfiles",
		setup = dev_layout,
	},
	{
		id = "throwaway",
		label = "Throwaway",
		cwd = os.getenv("HOME") .. "/dev/throwaway",
		setup = dev_layout,
	},
}

-- Project selector
local function project_selector()
	local ok, local_projects = pcall(require, "projects")
	local projects = {}
	for _, p in ipairs(base_projects) do
		table.insert(projects, p)
	end
	if ok then
		for _, p in ipairs(local_projects) do
			table.insert(projects, p)
		end
	end

	local choices = {}
	for _, project in ipairs(projects) do
		table.insert(choices, {
			id = project.id,
			label = project.label,
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
}

return config
