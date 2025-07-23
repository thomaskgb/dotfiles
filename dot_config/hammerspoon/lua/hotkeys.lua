local screenResolution = require("lua.screen_resolution")

-- create a hyper key for hotkeys
HYPER = { "cmd", "alt", "ctrl", "shift" }

-- Terminal launcher (space and 2)
local launchTerminal = function()
	hs.execute("/Users/thomas/.config/hammerspoon/launch_show_hide.sh iTerm")
end
hs.hotkey.bind(HYPER, "space", launchTerminal)
hs.hotkey.bind(HYPER, "2", launchTerminal)

-- Application launchers
hs.hotkey.bind(HYPER, "1", function()
	hs.application.open("Brave Browser")
end)

hs.hotkey.bind(HYPER, "3", function()
	hs.application.open("Strongbox")
end)

-- Todoist launcher (5 and t)
local launchTodoist = function()
	hs.execute("/Users/thomas/.config/hammerspoon/launch_show_hide.sh Todoist")
end
hs.hotkey.bind(HYPER, "5", launchTodoist)
hs.hotkey.bind(HYPER, "t", launchTodoist)

hs.hotkey.bind(HYPER, "4", function()
	hs.execute("/Users/thomas/.config/hammerspoon/launch_show_hide.sh Obsidian")
end)

hs.hotkey.bind(HYPER, "s", function()
	screenResolution.toggleScreenResolution()
end)

-- bind f6 to applescript
hs.hotkey.bind("", "F6", function()
	hs.osascript.applescript([[
    set currentVolume to input volume of (get volume settings)
if currentVolume = 0 then
    set volume input volume 70
    display notification "Microphone unmuted" with title "Microphone Status" sound name "Frog"
else
    set volume input volume 0
    display notification "Microphone muted" with title "Microphone Status" sound name "Frog"
end if
  ]])
end)
