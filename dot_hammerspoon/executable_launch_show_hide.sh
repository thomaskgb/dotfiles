#!/bin/bash

APP_NAME="$1"


# Check if the application is running
if [[ $(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true') == *"${APP_NAME}"* ]]; then
  # If the application is the frontmost window, hide it
  echo "Hiding ${APP_NAME}"
  osascript -e 'tell application "System Events" to set visible of (processes where name contains "'${APP_NAME}'") to false'
else
  # If the application is not running, launch it and show the window
  for app in $(ls /Applications | grep "${APP_NAME}"); do
    open -a "${app}"
  done
  osascript -e 'tell application "System Events" to set frontmost of process whose name contains "'${APP_NAME}'" to true'
fi