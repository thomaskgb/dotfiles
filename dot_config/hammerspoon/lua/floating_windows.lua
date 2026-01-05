local M = {}

local AERO = "/opt/homebrew/bin/aerospace"

-- Cache for floating app IDs (loaded once at startup)
local cachedFloatingAppIds = nil

-- Parse AeroSpace config to get floating app bundle IDs
local function parseFloatingAppIds()
	-- Get config path
	local configPath = hs.execute(AERO .. " config --config-path")
	if not configPath then
		return {}
	end
	configPath = configPath:match("^%s*(.-)%s*$") -- trim

	-- Read config file
	local file = io.open(configPath, "r")
	if not file then
		return {}
	end
	local content = file:read("*all")
	file:close()

	-- Parse floating apps
	local floatingApps = {}
	local currentAppId = nil

	for line in content:gmatch("[^\r\n]+") do
		-- Look for app-id lines
		local appId = line:match("if%.app%-id%s*=%s*['\"]([^'\"]+)['\"]")
		if appId then
			currentAppId = appId
		end

		-- Look for floating layout
		if currentAppId and line:match("run%s*=%s*['\"]layout floating['\"]") then
			table.insert(floatingApps, currentAppId)
			currentAppId = nil
		end

		-- Reset on new section
		if line:match("^%[%[") then
			currentAppId = nil
		end
	end

	return floatingApps
end

-- Get floating app IDs (cached)
function M.getFloatingAppIds()
	if not cachedFloatingAppIds then
		cachedFloatingAppIds = parseFloatingAppIds()
	end
	return cachedFloatingAppIds
end

-- Check if app is configured as floating
function M.isFloating(app)
	if not app then return false end

	local bundleId = app:bundleID()
	if not bundleId then return false end

	local floatingIds = M.getFloatingAppIds()
	for _, id in ipairs(floatingIds) do
		if id == bundleId then
			return true
		end
	end
	return false
end

-- Print all floating apps
function M.printFloatingApps()
	local apps = M.getFloatingAppIds()
	print("\n=== Floating Apps ===")
	for i, bundleId in ipairs(apps) do
		print(string.format("%d. %s", i, bundleId))
	end
	print("Total: " .. #apps)
end

return M
