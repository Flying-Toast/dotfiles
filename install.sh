#!/bin/sh

fail() {
	printf "\e[31mFAIL: $1 \e[0m\n" 1>&2
	exit 1
}

cd "$(dirname "$0")" || fail "can't cd"

rm -f ~/.ash_history
mkdir -p ~/.cache

install_file() { # src dst
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

install_dir() { # srcdir dstdir
	find "$1" -type f -o -type l | while read -r item
	do
		install_file "$item" "$2/${item#*/}"
	done
}

install_dir config ~/.config
install_dir local ~/.local
install_file profile ~/.profile

# TODO: update to xdg dirs after https://bugzilla.mozilla.org/show_bug.cgi?id=259356
user_js_path="$(echo ~/.mozilla/firefox/*.default-release)"
[ -d "$user_js_path" ] || fail "run firefox to create profile"
install_file user.js "$user_js_path/user.js"

mkdir -p ~/.config/rc/runlevels/login
for usrsvc in pipewire pipewire-pulse
do
	rc-update -U add "$usrsvc" login
done
