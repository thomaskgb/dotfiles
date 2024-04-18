local screenResolution = require("lua.screen_resolution")

-- create a hyper key for hotkeys
HYPER = { "cmd", "alt", "ctrl", "shift" }

hs.hotkey.bind(HYPER, "space", function()
	hs.execute("/Users/thomas/.hammerspoon/launch_show_hide.sh iTerm")
end)

-- hs.hotkey.bind(HYPER, "s", function() 
--   screenResolution.toggleScreenResolution() 
-- end)
