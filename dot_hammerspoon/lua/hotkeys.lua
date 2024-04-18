local screenResolution = require("lua.screen_resolution")

-- create a hyper key for hotkeys
HYPER = { "cmd", "alt", "ctrl", "shift" }

hs.hotkey.bind(HYPER, "space", function()
	hs.execute("/Users/thomas/.hammerspoon/launch_show_hide.sh iTerm")
end)

hs.hotkey.bind(HYPER, "b", function()
  hs.application.open("Brave Browser") 
end)

hs.hotkey.bind(HYPER, "o", function()
  hs.execute("/Users/thomas/.hammerspoon/launch_show_hide.sh Obsidian")
end)

hs.hotkey.bind(HYPER, "t", function()
  hs.execute("/Users/thomas/.hammerspoon/launch_show_hide.sh Todoist")
end)

hs.hotkey.bind(HYPER, "s", function() 
  screenResolution.toggleScreenResolution()
end)
