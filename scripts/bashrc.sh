# Matt's .bashrc
# System Requirements: color-capable terminal

if [ $EUID -eq 0 ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]\[\033[01;34m\] [\w]\[\033[00m\]\$ '
else	
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]\[\033[01;34m\] [\w]\[\033[00m\]\$ '
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias grep to egrep and configure color output and line numbers
alias grep="egrep --color=always -n"

# Colorize output from ls
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

#Configure grc to provide colorized output for system commands
GRC=`which grc`
alias colourify="$GRC -es --colour=auto"
alias netstat='colourify netstat'
alias ping='colourify ping'
alias traceroute='colourify traceroute'
alias dig='colourify dig'
alias df='colourify df'
alias mount='colourify mount'
alias ps='colourify ps'

# Alias commands for safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Create rsync-over-SSH function command, using SSH port tcp/22222.
function rsynssh() {
	rsync -r -a -v -e "ssh -p 22222" --progress $1 $2
}

# Create a function to read Markdown files in the terminal 
function rmd() {
	pandoc $1 | lynx -stdin
}

