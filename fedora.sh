#!/bin/sh

if [ $(id -u) -ne 0 ]
then
	echo needs root
	exit 1
fi

dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
dnf swap ffmpeg-free ffmpeg --allowerasing
dnf groupinstall -y Multimedia
dnf remove -y abrt vim-minimal thunar sddm rofi-wayland
dnf --setopt=install_weak_deps=False install -y neovim
dnf install -y libavcodec-freeworld power-profiles-daemon jetbrains-mono-nl-fonts wmenu

ln -s /usr/bin/nvim /usr/bin/vi
