#!/bin/sh

# merge X resources (cursor theme, dpi, font rendering)
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"

exec dwm
