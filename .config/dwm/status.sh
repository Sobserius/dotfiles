#!/bin/sh
# update dwm's status text (read from the root window name)

# Find a system battery. On a desktop this stays empty and no battery
# segment is shown at all. Peripheral batteries (mice, keyboards, ...)
# are skipped by checking scope=System.
power_supply=${POWER_SUPPLY_DIR:-/sys/class/power_supply}
BATTERY=
for dev in "$power_supply"/*; do
	[ -r "$dev/type" ] || continue
	[ "$(cat "$dev/type")" = "Battery" ] || continue
	if [ -r "$dev/scope" ] && [ "$(cat "$dev/scope")" != "System" ]; then
		continue
	fi
	if [ -r "$dev/present" ] && [ "$(cat "$dev/present")" != "1" ]; then
		continue
	fi
	BATTERY=$dev
	break
done

battery() {
	[ -n "$BATTERY" ] || return 0
	capacity=$(cat "$BATTERY/capacity" 2>/dev/null) || return 0
	printf 'BAT %s%%' "$capacity"
}

while :; do
	# stop if the dwm process we were started for is gone
	if [ -n "$DWMPID" ] && ! kill -0 "$DWMPID" 2>/dev/null; then
		exit 0
	fi

	clock=$(date '+%a %d %b  %H:%M')
	bat=$(battery)

	if [ -n "$bat" ]; then
		xsetroot -name "$bat  $clock" || exit 0
	else
		xsetroot -name "$clock" || exit 0
	fi
	sleep 10
done
