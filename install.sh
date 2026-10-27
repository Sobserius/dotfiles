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
pipewire pipewire-pulse wireplumber pulsemixer alsa-utils rtkit
xorg-server xorg-xinit xorg-xsetroot xorg-xrdb xorg-xrandr
curl python"

if command -v pacman >/dev/null 2>&1; then
	say "installing dependencies (sudo will ask for your password)"
	sudo -v
	# shellcheck disable=SC2086
	sudo pacman -S --needed --noconfirm --color=auto $deps
else
	say "pacman not found — install these packages with your package manager:"
	echo $deps
fi

# Symbols Nerd Font — installed from the upstream nerd-fonts release
# (no AUR, no yay): fonts go to ~/.local/share/fonts, plus the fontconfig
# fallback so nerd glyphs render in st/dwm automatically.
if ! fc-list 2>/dev/null | grep -qi 'Symbols Nerd Font'; then
	say "installing Symbols Nerd Font from the nerd-fonts release"
	tmp=$(mktemp -d)
	if curl -fsSL -o "$tmp/symbols.zip" \
		https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip
	then
		python3 -m zipfile -e "$tmp/symbols.zip" "$tmp/out"
		mkdir -p "$HOME/.local/share/fonts" "$HOME/.config/fontconfig/conf.d"
		cp "$tmp/out/SymbolsNerdFont-Regular.ttf" \
			"$tmp/out/SymbolsNerdFontMono-Regular.ttf" \
			"$HOME/.local/share/fonts/"
		cp "$tmp/out/10-nerd-font-symbols.conf" \
			"$HOME/.config/fontconfig/conf.d/"
		fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
	else
		say "could not download it (offline?) — skipping; nerd glyphs may not render"
	fi
	rm -rf "$tmp"
fi

say "copying configs into $HOME"
mkdir -p "$HOME/.config"
cp -a "$repo/.config/." "$HOME/.config/"
cp -a "$repo/.xinitrc" "$HOME/.xinitrc"
cp -a "$repo/.Xresources" "$HOME/.Xresources"
if [ -d "$repo/.local" ]; then
	cp -a "$repo/.local/." "$HOME/.local/"
fi

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
