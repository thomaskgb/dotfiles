
local function toggleScreenResolution()
	-- Get the primary screen
	local screen = hs.screen.primaryScreen()

	-- Define the two resolutions and refresh rates
	local resolution1 = { w = 2048, h = 1330, scale = 1, freq = 120, bpp = 8 }
	local resolution2 = { w = 1800, h = 1169, scale = 2, freq = 120, bpp = 8 }
	local resolution3 = { w = 1512, h = 982, scale = 2, freq = 120, bpp = 8 }

	-- Get the current screen mode
	local currentMode = screen:currentMode()

	-- Determine which resolution to switch to
	if currentMode.w == resolution1.w and currentMode.h == resolution1.h then
		-- Switch to resolution
		screen:setMode(resolution2.w, resolution2.h, resolution2.scale, resolution2.freq, resolution2.bpp)
		print(string.format("Switched to resolution: %dx%d @ %dHz", resolution2.w, resolution2.h, resolution2.freq))
	elseif currentMode.w == resolution2.w and currentMode.h == resolution2.h then
		-- Switch to resolution1
		screen:setMode(resolution3.w, resolution3.h, resolution3.scale, resolution3.freq, resolution3.bpp)
		print(string.format("Switched to resolution: %dx%d @ %dHz", resolution3.w, resolution3.h, resolution3.freq))
	else 
		-- Switch to resolution3
		screen:setMode(resolution1.w, resolution1.h, resolution1.scale, resolution1.freq, resolution1.bpp)
		print(string.format("Switched to resolution: %dx%d @ %dHz", resolution1.w, resolution1.h, resolution1.freq))
	end
end


-- Create a new menuar item
local menuBarItem = hs.menubar.new()

local function menuBar()
	menuBarItem:setIcon("../resources/display.png")
end

-- Set the click callback for the menubar item
menuBarItem:setClickCallback(toggleScreenResolution)

-- Initialize the menubar item title
menuBar()
