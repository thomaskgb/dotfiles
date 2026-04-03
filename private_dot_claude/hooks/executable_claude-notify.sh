#!/bin/bash
# Claude Code hook helper: updates tmux status + sends macOS notifications
# Usage: claude-notify.sh <event> where event is: running, done, attention

EVENT="${1:-}"
INPUT=$(cat)

# Project name from hook stdin
PROJECT=$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null | xargs basename 2>/dev/null || echo "claude")

set_tmux_status() {
    local icon="$1"
    if [ -n "${TMUX:-}" ]; then
        tmux set-option -w @claude_status "$icon" 2>/dev/null
    elif [ -n "${TMUX_PANE:-}" ]; then
        tmux set-option -w -t "$TMUX_PANE" @claude_status "$icon" 2>/dev/null
    fi
}

tmux_win() {
    if [ -n "${TMUX:-}" ]; then
        tmux display-message -p '#I:#W' 2>/dev/null || echo "N/A"
    elif [ -n "${TMUX_PANE:-}" ]; then
        tmux display-message -t "$TMUX_PANE" -p '#I:#W' 2>/dev/null || echo "N/A"
    else
        echo "N/A"
    fi
}

case "$EVENT" in
    running)
        set_tmux_status '⚡'
        ;;
    done)
        set_tmux_status '✅'
        WIN=$(tmux_win)
        osascript -e "display notification \"Session in $PROJECT is done\" with title \"✅ Claude finished\" subtitle \"tmux window ${WIN}\"" &
        ;;
    attention)
        set_tmux_status '❓'
        WIN=$(tmux_win)
        osascript -e "display notification \"Session in $PROJECT needs input\" with title \"❓ Claude needs you\" subtitle \"tmux window ${WIN}\"" &
        ;;
esac
