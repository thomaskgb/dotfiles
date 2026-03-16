#!/bin/bash
statuses=$(tmux list-panes -t "$1" -F '#{@claude_status}' 2>/dev/null)
if echo "$statuses" | grep -qF '?'; then
    printf '?'
elif echo "$statuses" | grep -qF '⚡'; then
    printf '⚡'
elif echo "$statuses" | grep -qF '✅'; then
    printf '✅'
fi
