local M = {}

local AERO = "/opt/homebrew/bin/aerospace"

-- Define app configurations
-- "tiled" apps have a fixed workspace - we switch TO that workspace to show them
-- "floating" apps follow the user - we move them to current workspace
local APP_CONFIG = {
	["Brave Browser"] = { type = "tiled", workspace = "1" },
	["iTerm2"] = { type = "tiled", workspace = "2" },
	["Obsidian"] = { type = "tiled", workspace = "3" },
	["Notion"] = { type = "tiled", workspace = "3" },
	["Mail"] = { type = "tiled", workspace = "4" },
	["WhatsApp"] = { type = "tiled", workspace = "4" },
	-- Floating apps - no fixed workspace
	["Spotify"] = { type = "floating" },
	["Todoist"] = { type = "floating" },
	["Calendar"] = { type = "floating" },
	["Strongbox"] = { type = "floating" },
	["Finder"] = { type = "floating" },
}

-- Get current focused workspace
local function getCurrentWorkspace()
	local output = hs.execute(AERO .. " list-workspaces --focused")
	if output then
		return output:match("^%s*(.-)%s*$")
	end
	return "1"
end

-- Reliably show and focus an app
local function showApp(app)
	if not app then return end

	-- Unhide if hidden
	if app:isHidden() then
		app:unhide()
	end

	-- Activate the app
	app:activate()

	-- Focus main window after a tiny delay to ensure activation completed
	hs.timer.doAfter(0.05, function()
		local win = app:mainWindow()
		if win then
			win:focus()
			win:raise()
		end
	end)
end

-- Toggle a tiled app (has fixed workspace in AeroSpace)
local function toggleTiledApp(appName, workspace)
	local app = hs.application.get(appName)

	if app and app:isFrontmost() then
		-- App is focused, hide it
		app:hide()
	elseif app then
		-- App is running but not focused
		-- Switch to its workspace first, then show
		hs.execute(AERO .. " workspace " .. workspace)
		hs.timer.doAfter(0.1, function()
			showApp(app)
		end)
	else
		-- App not running, switch to workspace and launch
		hs.execute(AERO .. " workspace " .. workspace)
		hs.timer.doAfter(0.1, function()
			hs.application.launchOrFocus(appName)
		end)
	end
end

-- Track windows we've already moved to prevent repeated moves
local movedWindows = {}

-- Get window's current workspace via aerospace
local function getWindowWorkspace(windowId)
	local output = hs.execute(AERO .. " list-windows --all")
	if not output then return nil end

	for line in output:gmatch("[^\r\n]+") do
		if line:match("^%s*" .. tostring(windowId)) then
			-- Parse workspace from aerospace output
			local ws = line:match("|%s*(%d+)%s*|") or line:match("(%d+)%s*$")
			return ws
		end
	end
	return nil
end

-- Move window to workspace (only if not already there)
local function moveWindowToWorkspace(app, win, targetWorkspace)
	if not app or not win then return end

	local winId = win:id()

	-- Skip if we just moved this window
	if movedWindows[winId] then return end

	-- Mark as moved (clear after 1 second to allow future moves)
	movedWindows[winId] = true
	hs.timer.doAfter(1, function()
		movedWindows[winId] = nil
	end)

	-- Focus, move, then activate
	win:focus()
	hs.timer.doAfter(0.15, function()
		hs.execute(AERO .. " move-node-to-workspace " .. targetWorkspace)
		hs.timer.doAfter(0.1, function()
			app:activate()
			win:raise()
		end)
	end)
end

-- Wait for app to have a proper window, then move it to target workspace
local function waitForWindowAndMove(appName, targetWorkspace, attempts, lastWinId)
	attempts = attempts or 0
	if attempts > 30 then return end -- Give up after ~6 seconds

	local app = hs.application.get(appName)
	if not app then
		-- App not ready yet, keep waiting
		hs.timer.doAfter(0.2, function()
			waitForWindowAndMove(appName, targetWorkspace, attempts + 1, nil)
		end)
		return
	end

	local win = app:mainWindow()
	if win and win:isVisible() then
		local winId = win:id()

		-- Wait for window to stabilize (same window ID twice in a row)
		-- This helps skip splash screens
		if lastWinId and lastWinId == winId then
			-- Window is stable, move it
			moveWindowToWorkspace(app, win, targetWorkspace)
			return
		else
			-- Window appeared but might be splash screen, wait and check again
			hs.timer.doAfter(0.3, function()
				waitForWindowAndMove(appName, targetWorkspace, attempts + 1, winId)
			end)
			return
		end
	end

	-- Window not ready yet, try again
	hs.timer.doAfter(0.2, function()
		waitForWindowAndMove(appName, targetWorkspace, attempts + 1, lastWinId)
	end)
end

-- Toggle a floating app (follows user to current workspace)
local function toggleFloatingApp(appName)
	local app = hs.application.get(appName)

	-- Capture target workspace BEFORE any focusing happens
	local targetWorkspace = getCurrentWorkspace()

	if app and app:isFrontmost() then
		-- App is focused, hide it
		app:hide()
	elseif app then
		-- App is running but not focused
		-- First unhide if hidden
		if app:isHidden() then
			app:unhide()
		end

		-- Wait a moment for unhide to complete, then get window
		hs.timer.doAfter(0.1, function()
			local win = app:mainWindow()
			-- mainWindow() returns nil for minimized windows, find and unminimize
			if not win then
				for _, w in ipairs(app:allWindows()) do
					if w:isMinimized() then
						w:unminimize()
						-- Minimized windows: launchOrFocus + center, skip AeroSpace move
						hs.timer.doAfter(0.3, function()
							hs.application.launchOrFocus(appName)
							hs.timer.doAfter(0.1, function()
								w:centerOnScreen()
							end)
						end)
						return
					end
				end
			end
			if win then
				moveWindowToWorkspace(app, win, targetWorkspace)
			else
				-- Window might take time to appear after unhide
				-- Wait for it
				waitForWindowAndMove(appName, targetWorkspace, 0, nil)
			end
		end)
	else
		-- App not running - launch it and move to current workspace
		hs.application.launchOrFocus(appName)
		-- Wait for window to appear, then move it
		waitForWindowAndMove(appName, targetWorkspace, 0, nil)
	end
end

-- Main toggle function
function M.toggleApp(appName)
	local config = APP_CONFIG[appName]

	if config and config.type == "tiled" then
		toggleTiledApp(appName, config.workspace)
	elseif config and config.type == "floating" then
		toggleFloatingApp(appName)
	else
		-- Unknown app - treat as floating
		toggleFloatingApp(appName)
	end
end

-- Export config for other modules if needed
M.APP_CONFIG = APP_CONFIG

return M
