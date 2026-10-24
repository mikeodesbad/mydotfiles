#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

fastfetch
export PATH="$HOME/.local/bin:$PATH"

# Launch brave detached from the terminal, then close the terminal
brave() {
    setsid -f /usr/bin/brave "$@" >/dev/null 2>&1
    exit
}
