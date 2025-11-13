#!/bin/bash
# Configure Hammerspoon to use XDG config directory

defaults write org.hammerspoon.Hammerspoon MJConfigFile "$HOME/.config/hammerspoon/init.lua"
echo "Configured Hammerspoon to use ~/.config/hammerspoon/init.lua"
