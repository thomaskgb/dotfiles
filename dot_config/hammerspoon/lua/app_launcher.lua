local M = {}

local floatingWindows = require("lua.floating_windows")
local AERO = "/opt/homebrew/bin/aerospace"

-- Get current workspace
local function getCurrentWorkspace()
	local output = hs.execute(AERO .. " list-workspaces --focused")
	if output then
		return output:match("^%s*(.-)%s*$")
	end
	return nil
end

-- Get workspace where app window is located
local function getAppWorkspace(appName)
	local output = hs.execute(AERO .. " list-windows --all")
	if not output then
		return nil
	end

	-- Find window ID for this app
	local windowId = nil
	for line in output:gmatch("[^\r\n]+") do
		-- Parse line format: window-id | app-name | window-title
		local parts = {}
		for part in line:gmatch("[^|]+") do
			table.insert(parts, part:match("^%s*(.-)%s*$"))
		end
		if #parts >= 2 and parts[2] == appName then
			windowId = parts[1]
			break
		end
	end

	if not windowId then
		return nil
	end

	-- Check all workspaces to find where this window is
	local allWorkspaces = hs.execute(AERO .. " list-workspaces --all")
	if allWorkspaces then
		for ws in allWorkspaces:gmatch("[^\r\n]+") do
			ws = ws:match("^%s*(.-)%s*$")
			local wsOutput = hs.execute(AERO .. " list-windows --workspace " .. ws)
			if wsOutput and wsOutput:match(windowId) then
				return ws
			end
		end
	end

	return nil
end

-- Move floating app to current workspace
local function moveToCurrentWorkspace(app)
	local currentWorkspace = getCurrentWorkspace()
	if not currentWorkspace then
		app:activate()
		return
	end

	local mainWindow = app:mainWindow()
	if not mainWindow then
		app:activate()
		return
	end

	-- Check if window is already on current workspace
	local appWorkspace = getAppWorkspace(app:name())
	if appWorkspace == currentWorkspace then
		-- Already on current workspace, just activate (no flicker!)
		app:activate()
		return
	end

	-- Window is on different workspace, need to move it
	mainWindow:focus()
	hs.timer.doAfter(0.01, function()
		hs.execute(AERO .. " move-node-to-workspace " .. currentWorkspace)
		app:activate()
	end)
end

-- Main toggle function
function M.toggleApp(appName)
	local app = hs.application.get(appName)

	if app then
		-- App is running
		if app:isFrontmost() then
			-- App is focused, hide it
			app:hide()
		else
			-- App is running but not focused
			if floatingWindows.isFloating(app) then
				-- Floating app: move to current workspace and show
				moveToCurrentWorkspace(app)
			else
				-- Regular app: just activate
				app:activate()
			end
		end
	else
		-- App is not running, launch it
		hs.application.launchOrFocus(appName)
	end
end

return M
