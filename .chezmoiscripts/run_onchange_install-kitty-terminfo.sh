#!/bin/sh
# Make sure this machine has a terminfo entry for the terminal we connect from.
#
# kitty sets TERM=xterm-kitty. On a host with no entry of that name, zsh gets an
# empty $terminfo array: the line editor cannot redraw correctly (text jumps
# around while typing) and zsh-autocomplete aborts with
# "terminfo[kcbt]: parameter not set".
#
# Debian/Ubuntu split this. ncurses-term ships the entry under the bare name
# "kitty"; the "xterm-kitty" name that kitty actually sets lives in the separate
# kitty-terminfo package. Rather than depend on that package being available and
# on having sudo, recompile whatever entry is here under both names into the
# per-user database at ~/.terminfo, which ncurses searches before the system one.

set -eu

# macOS running kitty already resolves xterm-kitty from kitty's bundled
# terminfo, so this exits here on the client side.
if infocmp xterm-kitty >/dev/null 2>&1; then
    exit 0
fi

if ! command -v infocmp >/dev/null 2>&1 || ! command -v tic >/dev/null 2>&1; then
    echo "kitty terminfo: no infocmp/tic on this host, skipping" >&2
    exit 0
fi

if ! infocmp kitty >/dev/null 2>&1; then
    echo "kitty terminfo: no source entry to copy, skipping (install ncurses-term or kitty-terminfo)" >&2
    exit 0
fi

echo "Installing xterm-kitty terminfo into ~/.terminfo..."
# Line 1 of infocmp output is a comment and every capability line is indented,
# so the names line is the only one that can match at the start of a line.
infocmp -x kitty \
    | sed 's/^kitty|/xterm-kitty|kitty|/' \
    | tic -x -o "$HOME/.terminfo" -
