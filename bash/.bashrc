#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Funções
openfile() {
    for file in "$@"; do
	   command xdg-open "$file" >/dev/null 2>&1 &
    done
}

# Atalhos de Diretórios e Ferramentas
alias 6_SEM="cd ~/Documents/FACOM/6_SEM"
alias catutils="cat ~/Documents/FACOM/utils"
alias dot="stow --dir=$HOME/Reps/dotfiles --target=$HOME"
