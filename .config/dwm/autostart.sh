#!/bin/sh
# run once when dwm starts

xsetroot -solid "#FDF2F8"
xsetroot -cursor_name left_ptr

# keyboard layouts: us + ru, Alt+Shift toggles (no LED indicator changes)
setxkbmap -option '' -layout us,ru -option grp:alt_shift_toggle

# clock / date in the bar
DWMPID=$PPID "$HOME/.config/dwm/status.sh" &

# removable drives: automount new devices (tray icon needs a systray)
if ! pgrep -x udiskie >/dev/null 2>&1; then
	udiskie -a &
fi

# wallpaper (optional: silently skip if the image isn't there)
if [ -f "$HOME/hellokitties.png" ]; then
	feh --bg-scale "$HOME/hellokitties.png" &
fi
