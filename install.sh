#!/bin/sh
# Install this desktop into $HOME and build the suckless tools.
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

say() { printf '\033[1;35m::\033[0m %s\n' "$*"; }

say "copying configs into $HOME"
mkdir -p "$HOME/.config"
cp -a "$repo/.config/." "$HOME/.config/"
cp -a "$repo/.xinitrc" "$HOME/.xinitrc"
cp -a "$repo/.Xresources" "$HOME/.Xresources"

if [ -f "$repo/wallpapers/hellokitties.png" ]; then
	cp -a "$repo/wallpapers/hellokitties.png" "$HOME/hellokitties.png"
fi

for prog in dwm st dmenu; do
	say "building and installing $prog"
	make -C "$repo/suckless/$prog" clean all
	sudo make -C "$repo/suckless/$prog" install
done

if [ -d /etc/polkit-1/rules.d ]; then
	say "installing polkit rule for passwordless udisks2 (wheel)"
	sudo install -Dm644 \
		"$repo/system/polkit-1/rules.d/61-udisks2.rules" \
		/etc/polkit-1/rules.d/61-udisks2.rules
	sudo systemctl restart polkit
fi

say "done — run startx (or startx -- :0 vt2)"
