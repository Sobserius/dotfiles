#!/bin/sh

# merge X resources (cursor theme, dpi, font rendering)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

# make flatpak apps visible to the app launcher (j4-dmenu-desktop scans $XDG_DATA_DIRS)
if [ -f /etc/profile.d/flatpak.sh ]; then
	. /etc/profile.d/flatpak.sh
fi

exec dwm
