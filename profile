export CARGO_HOME="$HOME/.local/share/cargo"
export EDITOR="vi"
export HISTFILE="$HOME/.cache/sh_history"
export LESSHISTFILE="-"
export MANPAGER="nvim +Man!"
export MIX_XDG="1"
export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
export PYTHON_HISTORY="/dev/null"
export RUSTUP_HOME="$HOME/.local/share/rustup"

export ENV="$HOME/.config/sh/rc"
. "$ENV"

openrc --user login
