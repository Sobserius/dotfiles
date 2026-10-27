#!/bin/sh
# update dwm's status text (read from the root window name)
while :; do
	# stop if the dwm process we were started for is gone
	if [ -n "$DWMPID" ] && ! kill -0 "$DWMPID" 2>/dev/null; then
		exit 0
	fi
	xsetroot -name "$(date '+%a %d %b  %H:%M')" || exit 0
	sleep 10
done
