local M = {}

local AERO = "/opt/homebrew/bin/aerospace"

-- App to workspace mapping
-- Floating apps live on workspace "a" at rest, but are pulled to the current workspace when toggled.
local APP_CONFIG = {
	["Brave Browser"] = { workspace = "1" },
	["kitty"] = { workspace = "2" },
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
-- where mainWindow() returns nil when only the database manager is open)
local function getWindow(app)
	local win = app:mainWindow()
	if not win then
		for _, w in ipairs(app:allWindows()) do
			if w:isVisible() or w:isStandard() then
				return w
			end
		end
	end
	return win
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

	app:activate()

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
			app:activate()
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

return M
