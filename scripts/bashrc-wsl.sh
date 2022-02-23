# Windows Services for Linux (WSL) .bashrc Script
# App Dependencies: grc, rsync, pandoc, lynx
# System Requirements: color-capable terminal
# Remove/modify lines 66-70 if ssh-agent is not desired
# v1.0 - Matt Pogue <matt@thesoloadmin.com>

# Get the disto name in lowercase from the "ID=" field in /etc/os-release - 09/10/2021
distro_name=`grep ^ID\= /etc/os-release | awk -F '=' '{print $2}'`

if [ $EUID -eq 0 ]; then
	PS1='\[\033[01;31m\](${distro_name}\033[01;31m)\033[01;31m \u@\h\[\033[00m\]\[\033[01;34m\] [\w]\[\033[00m\]\$ '
else	
	PS1='\[\033[01;32m\](${distro_name}\033[01;32m)\033[01;32m \u@\h\[\033[00m\]\[\033[01;34m\] [\w]\[\033[00m\]\$ '
fi

# Alias grep to egrep and configure color output
alias grep="egrep --color=always"

# Colorize output from ls
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -alh'
alias l='ls $LS_OPTIONS -lA'

#Configure grc to provide colorized output for system commands
GRC=`which grc`
alias colorify="$GRC -es --colour=auto"
alias netstat='colorify netstat'
alias ping='colorify ping'
alias traceroute='colorify traceroute'
alias dig='colorify dig'
alias df='colorify df'
alias mount='colorify mount'
alias ps='colorify ps'

# Alias commands for safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Create rsync-over-SSH function command
function rsynssh() {
	rsync -r -a -v -e "ssh" --progress $1 $2
}

# Create a function to read Markdown files in the terminal 
function rmd() {
	pandoc $1 | lynx -stdin
}

# Add ssh-agent to session startup
if [ -z "$SSH_AUTH_SOCK" ] ; then
        eval `ssh-agent`
        ssh-add ~/.ssh/personal-2022
fi
