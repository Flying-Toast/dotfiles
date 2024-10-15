alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias ip="ip -c=never"

unset DEBUGINFOD_URLS

export CARGO_HOME="$HOME/.local/share/cargo"
export EDITOR="vi"
export HISTFILE="$HOME/.cache/bash/history"
export LESSHISTFILE="/dev/null"
export MANPAGER="nvim +Man!"
export LS_COLORS='di=0;34:ex=0;32:so=0;35:do=0;35:ln=0;36:cd=0;33:bd=0;33:or=0;31:'
export MIX_XDG="1"
export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
export PYTHON_HISTORY="/dev/null"
export RUSTUP_HOME="$HOME/.local/share/rustup"
export XDG_CONFIG_HOME="$HOME/.config"

PS1='\[\e[36m\]\w\[\e[32m\]\$\[\e[00m\] '
github="git@github.com:Flying-Toast"

shopt -s histappend

bind \C-k:history-search-backward
bind \C-j:history-search-forward

source /usr/share/bash-completion/bash_completion
[[ -f "$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo" ]] && source "$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo"
