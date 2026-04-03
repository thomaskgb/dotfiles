#!/bin/bash
# Aggregate claude status across panes, ignoring stale statuses from shell panes.
# Claude Code shows its version as the pane command (e.g. "2.1.76"), while
# regular shells show "zsh", "bash", etc. Only count status from non-shell panes.
statuses=$(tmux list-panes -t "$1" -F '#{pane_current_command}|#{@claude_status}' 2>/dev/null)

active=""
while IFS= read -r line; do
    cmd="${line%%|*}"
    status="${line#*|}"
    [ -z "$status" ] && continue
    # Skip stale statuses from shell panes
    case "$cmd" in
        zsh|bash|fish|sh) continue ;;
    esac
    active="$active$status
"
done <<< "$statuses"

[ -z "$active" ] && exit 0

if echo "$active" | grep -qF '?'; then
    printf '?'
elif echo "$active" | grep -qF '⚡'; then
    printf '⚡'
elif echo "$active" | grep -qF '✅'; then
    printf '✅'
fi
