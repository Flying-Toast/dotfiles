[[ $- != *i* ]] && return

alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias o="xdg-open"

unset DEBUGINFOD_URLS

export RUSTUP_HOME="$HOME/.local/share/rustup"
export CARGO_HOME="$HOME/.local/share/cargo"
export PATH="$HOME/.local/bin:$PATH:$CARGO_HOME/bin"
export LS_COLORS='di=0;34:ex=0;32:so=0;35:do=0;35:ln=0;36:cd=0;33:bd=0;33:or=0;31:'
export github="git@github.com:Flying-Toast"
export EDITOR="vi"
export MANPAGER="nvim +Man!"
export HISTFILE="$HOME/.cache/bash/history"
export LESSHISTFILE="/dev/null"
export PYTHON_HISTORY="/dev/null"

function _prompt_cmd {
	NJOBS="$(jobs | wc -l)"
	[ $NJOBS -gt 0 ] && JOBPART=" $(tput setaf 1)$NJOBS "
	PS1="$(tput setaf 6)\w$JOBPART$(tput setaf 2)\$$(tput sgr0) "
	unset NJOBS JOBPART
}
PROMPT_COMMAND=_prompt_cmd

shopt -s histappend

bind "\C-k":history-search-backward
bind "\C-j":history-search-forward

source /usr/share/bash-completion/bash_completion
[[ -f "$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo" ]] && source "$RUSTUP_HOME/toolchains/stable-x86_64-unknown-linux-gnu/etc/bash_completion.d/cargo"
