#!/bin/sh

cd "$(dirname "$0")"

function fail {
	echo $1 1>&2
	exit 1
}

for xdgdir in Downloads Templates Public Documents Music Pictures Videos
do
	[ -d ~/"$xdgdir" ] && rmdir ~/"$xdgdir"
done
xdg-user-dirs-update

mkdir -p "$HOME/.cache/bash"

function install_file { # src dst
	[ -f "$1" ] || fail "source \"$1\" not a file"

	if [ -e "$2" ]
	then
		[ -f "$2" ] || fail "destination \"$2\" not a file"
		backup_path="old/$1"
		mkdir -p "$(dirname "$backup_path")"
		mv "$2" "$backup_path"
	else
		mkdir -p "$(dirname "$2")"
	fi

	echo "$1 -> $2"
	cp "$1" "$2"
}

function install_dir { # srcdir dstdir
	find "$1" -type f | while read item
	do
		install_file "$item" "$2/${item#*/}"
	done
}

install_dir config ~/.config
install_dir local ~/.local
# TODO: make bash use xdg dirs
install_file bashrc ~/.bashrc
# TODO: update to xdg dirs after https://bugzilla.mozilla.org/show_bug.cgi?id=259356
install_file user.js ~/.mozilla/firefox/*.default-release/user.js
