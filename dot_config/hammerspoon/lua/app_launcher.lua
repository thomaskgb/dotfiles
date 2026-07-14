local M = {}

local AERO = "/opt/homebrew/bin/aerospace"

-- App to workspace mapping
-- Floating apps live on workspace "a" at rest, but are pulled to the current workspace when toggled.
local APP_CONFIG = {
	["Brave Browser"] = { workspace = "1" },
	["kitty"] = { workspace = "2" },
	["Superset"] = { workspace = "t" },
	["Obsidian"] = { workspace = "3" },
	["Notion"] = { workspace = "3" },
	["Mail"] = { workspace = "4" },
	["WhatsApp"] = { workspace = "4" },
	["Spotify"] = { floating = true },
	["Todoist"] = { floating = true },
	["Calendar"] = { floating = true },
	["Strongbox"] = { floating = true },
	["Finder"] = { floating = true },
	["1Password"] = { floating = true },
}

-- Get the best available window for an app (handles apps like Strongbox
-- where mainWindow() returns nil and only a popup is open, e.g. the unlock
-- password prompt, which reports as a non-standard panel).
local function getWindow(app)
	-- A popup (password prompt, file picker) usually holds focus, so prefer it,
	-- then the main window.
	local win = app:focusedWindow() or app:mainWindow()
	if win then
		return win
	end

	-- Fall back to any visible window, then any window at all. The last resort
	-- covers dialogs/panels that report as non-standard and non-visible.
	local windows = app:allWindows()
	for _, w in ipairs(windows) do
		if w:isVisible() then
			return w
		end
	end
	return windows[1]
end

-- Get current focused workspace
local function getCurrentWorkspace()
	local output = hs.execute(AERO .. " list-workspaces --focused")
	if output then
		return output:match("^%s*(.-)%s*$")
	end
	return "1"
end

-- Show and focus a tiled app
local function showApp(app)
	if not app then return end

	if app:isHidden() then
		app:unhide()
	end

	-- activate(true) brings ALL windows forward (incl. popups/panels),
	-- which AeroSpace's window-focus cannot do on its own.
	app:activate(true)

	hs.timer.doAfter(0.05, function()
		local win = getWindow(app)
		if win then
			win:focus()
			win:raise()
		end
	end)
end

-- Toggle a tiled app (has fixed workspace)
local function toggleTiledApp(appName, workspace)
	local app = hs.application.get(appName)

	if app and app:isFrontmost() then
		app:hide()
	elseif app then
		hs.execute(AERO .. " workspace " .. workspace)
		hs.timer.doAfter(0.1, function()
			showApp(app)
		end)
	else
		hs.execute(AERO .. " workspace " .. workspace)
		hs.timer.doAfter(0.1, function()
			hs.application.launchOrFocus(appName)
		end)
	end
end

-- Move a floating window to a workspace, then switch to it and center
local function moveFloatingToWorkspace(app, win, targetWorkspace)
	if not app or not win then return end

	win:focus()
	hs.timer.doAfter(0.15, function()
		hs.execute(AERO .. " move-node-to-workspace " .. targetWorkspace)
		hs.timer.doAfter(0.1, function()
			hs.execute(AERO .. " workspace " .. targetWorkspace)
			app:activate(true)
			win:raise()
			win:centerOnScreen()
		end)
	end)
end

-- Toggle a floating app (pulled to current workspace, sent back to "a" on hide)
local function toggleFloatingApp(appName)
	local app = hs.application.get(appName)
	local targetWorkspace = getCurrentWorkspace()

	if app and app:isFrontmost() then
		-- Move back to workspace "a" before hiding
		local win = getWindow(app)
		if win then
			win:focus()
			hs.execute(AERO .. " move-node-to-workspace a")
		end
		app:hide()
	elseif app then
		if app:isHidden() then
			app:unhide()
		end

		hs.timer.doAfter(0.1, function()
			local win = getWindow(app)
			if win then
				moveFloatingToWorkspace(app, win, targetWorkspace)
			end
		end)
	else
		hs.application.launchOrFocus(appName)
	end
end

-- Main toggle function
function M.toggleApp(appName)
	local config = APP_CONFIG[appName]

	if config and config.floating then
		toggleFloatingApp(appName)
	else
		toggleTiledApp(appName, config and config.workspace or "1")
	end
end

M.APP_CONFIG = APP_CONFIG

-- Watch for new Todoist windows (e.g. quick add) and pull them to the current workspace.
-- When Todoist creates a quick add window, macOS activates the app, which may cause
-- AeroSpace to follow focus to workspace "a" (where the main window lives). To know where
-- to pull the window, we read the last non-"a" workspace, which AeroSpace records to a file
-- on every workspace change via its exec-on-workspace-change hook (see aerospace.toml).
-- Reading a file is cheap and, unlike a global hs.window.filter watcher, does not block
-- Hammerspoon's main thread with a shell call on every window focus.
local LAST_WS_FILE = "/tmp/aerospace_last_user_workspace"

local function readLastUserWorkspace()
	local file = io.open(LAST_WS_FILE, "r")
	if not file then
		return "1"
	end
	local ws = file:read("*l")
	file:close()
	if ws and ws ~= "" then
		return ws
	end
	return "1"
end

local todoistFilter = hs.window.filter.new("Todoist")
todoistFilter:subscribe(hs.window.filter.windowCreated, function(win)
	local target = readLastUserWorkspace()
	hs.timer.doAfter(0.15, function()
		if win and win:isVisible() then
			win:focus()
			hs.execute(AERO .. " move-node-to-workspace " .. target)
			hs.execute(AERO .. " workspace " .. target)
			win:raise()
		end
	end)
end)

return M
