local screenResolution = require("lua.screen_resolution")
local appLauncher = require("lua.app_launcher")

-- create a hyper key for hotkeys
HYPER = { "cmd", "alt", "ctrl", "shift" }

-- WORKSPACES --
local AERO = "/opt/homebrew/bin/aerospace" -- adjust to your which-output

local function aero(cmd)
	hs.execute(AERO .. " " .. cmd)
end

hs.hotkey.bind(HYPER, "1", function()
	aero("workspace 1")
end)
hs.hotkey.bind(HYPER, "2", function()
	aero("workspace 2")
end)
hs.hotkey.bind(HYPER, "3", function()
	aero("workspace 3")
end)

hs.hotkey.bind(HYPER, "4", function()
	aero("workspace 4")
end)

-- APPLICATION LAUNCHER --
hs.hotkey.bind(HYPER, "space", function()
	appLauncher.toggleApp("iTerm2")
end)

hs.hotkey.bind(HYPER, "t", function()
	appLauncher.toggleApp("Todoist")
end)

hs.hotkey.bind(HYPER, "b", function()
	appLauncher.toggleApp("Brave Browser")
end)

hs.hotkey.bind(HYPER, "f", function()
	appLauncher.toggleApp("Finder")
end)

hs.hotkey.bind(HYPER, "o", function()
	appLauncher.toggleApp("Obsidian")
end)

hs.hotkey.bind(HYPER, "s", function()
	appLauncher.toggleApp("Strongbox")
end)

hs.hotkey.bind(HYPER, "w", function()
	appLauncher.toggleApp("WhatsApp")
end)

hs.hotkey.bind(HYPER, "p", function()
	appLauncher.toggleApp("Spotify")
end)

hs.hotkey.bind(HYPER, "m", function()
	appLauncher.toggleApp("Mail")
end)

hs.hotkey.bind(HYPER, "c", function()
	appLauncher.toggleApp("Calendar")
end)

hs.hotkey.bind(HYPER, "n", function()
	appLauncher.toggleApp("Notion")
end)

local HYPER = { "cmd", "alt", "ctrl", "shift" }
local AERO = "/opt/homebrew/bin/aerospace" -- adjust if needed

hs.hotkey.bind(HYPER, "r", function()
	-- Reload both AeroSpace and Hammerspoon configs
	hs.execute(AERO .. " reload-config")
	hs.alert.show("Reloading configs...")
	hs.reload()
end)
hs.alert.show("Config loaded")

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
