#!/bin/sh
# Install this desktop into $HOME, install the dependencies, and build the
# suckless tools. Run it as your normal user — sudo will ask for your password.
set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

say() { printf '\033[1;35m::\033[0m %s\n' "$*"; }

if [ "$(id -u)" -eq 0 ]; then
	echo "Run this as your normal user, not as root (it installs into \$HOME)." >&2
	exit 1
fi

deps="base-devel libx11 libxft libxinerama freetype2 fontconfig noto-fonts
j4-dmenu-desktop udiskie polkit feh scrot superfile
pipewire pipewire-pulse wireplumber pavucontrol alsa-utils rtkit
xorg-server xorg-xinit xorg-xsetroot xorg-xrdb xorg-xrandr"

if command -v pacman >/dev/null 2>&1; then
	say "installing dependencies (sudo will ask for your password)"
	sudo -v
	# shellcheck disable=SC2086
	sudo pacman -S --needed --noconfirm --color=auto $deps
else
	say "pacman not found — install these packages with your package manager:"
	echo $deps
fi

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

if command -v systemctl >/dev/null 2>&1; then
	say "enabling pipewire user services"
	systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null ||
		say "could not enable them here — run: systemctl --user enable --now pipewire pipewire-pulse wireplumber"
fi

say "done — run startx (or startx -- :0 vt2)"
