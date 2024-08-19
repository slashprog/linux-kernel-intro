# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

shopt -s globstar
shopt -s dotglob
shopt -s histappend
shopt -s checkwinsize

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
HISTFILE=$HOME/.bash_history.$$
HISTTIMEFORMAT="%F %T "

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# source each bash script in ~/.shell/rc/
# The scripts are maintained in a modular way in this folder
# Files in this folder are symlinks to actual scripts in ~/.shell/script/ folder
if [ -f $HOME/.shellrc ]; then
	source $HOME/.shelrc
fi

