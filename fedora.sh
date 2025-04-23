#!/bin/sh

if [ $(id -u) -ne 0 ]
then
	echo needs root
	exit 1
fi

dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf swap -y ffmpeg-free ffmpeg --allowerasing
dnf update -y @multimedia

dnf swap -y sway-config-fedora sway-config-upstream
dnf remove -y abrt vim-minimal sddm Thunar xarchiver nano parted pinfo rsync tracker wget2 \
	grimshot swayidle
dnf --setopt=install_weak_deps=False install -y neovim
dnf install -y power-profiles-daemon jetbrains-mono-nl-fonts ripgrep brightnessctl wmenu \
	zathura zathura-pdf-mupdf clipman mutt isync lynx udiskie hypridle

ln -s /usr/bin/nvim /usr/bin/vi
