local appLauncher = require("lua.app_launcher")

-- create a hyper key for hotkeys
HYPER = { "cmd", "alt", "ctrl", "shift" }

-- WORKSPACES --
-- hyper-1..9 and hyper-a are bound directly in aerospace.toml, so switching a
-- workspace no longer spawns an aerospace subprocess per keypress and cannot break
-- when the CLI and the running server disagree after an upgrade.
local AERO = "/opt/homebrew/bin/aerospace" -- adjust to your which-output

-- APPLICATION LAUNCHER --
hs.hotkey.bind(HYPER, "space", function()
	appLauncher.toggleApp("Superset")
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
	appLauncher.toggleApp("Microsoft Outlook")
end)

hs.hotkey.bind(HYPER, "c", function()
	appLauncher.toggleApp("Claude")
end)

hs.hotkey.bind(HYPER, "n", function()
	appLauncher.toggleApp("Notion")
end)

hs.hotkey.bind(HYPER, "r", function()
	-- Reload AeroSpace and Hammerspoon configs
	hs.execute(AERO .. " reload-config")
	-- Reload tmux config
	hs.execute("/opt/homebrew/bin/tmux source-file ~/.config/tmux/tmux.conf")
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
