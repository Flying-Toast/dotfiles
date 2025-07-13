#!/bin/sh

fail() {
	printf "\e[31mFAIL: $1 \e[0m\n" 1>&2
	exit 1
}

[ "$(id -u)" -eq  0 ] || fail "needs root"

apk add \
	brightnessctl \
	clipman \
	dbus \
	docs \
	file \
	font-jetbrains-mono-nl \
	imv \
	less \
	man-pages-posix \
	mandoc-apropos \
	mesa-dri-gallium \
	mesa-va-gallium \
	mpv \
	neovim \
	openssh-client \
	pipewire \
	pipewire-alsa \
	pipewire-pulse \
	playerctl \
	slurp \
	sof-firmware \
	wireplumber \
	wlsunset \
	zathura \
	zathura-pdf-mupdf

setup-desktop sway

case "$(awk '$1=="vendor_id"{print $3; exit}' /proc/cpuinfo)" in
	AuthenticAMD)
		apk add amd-ucode
		;;
	GenuineIntel)
		apk add intel-ucode
		;;
esac
