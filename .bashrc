# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# emacs ftw
export EDITOR=/usr/bin/emacs

# COLORS
NONE='\e[0m'

# NORMAL
BLUE='\e[0;34m'
GREEN='\e[0;32m'
PURPLE='\e[0;35m'
RED='\e[0;31m'
TEAL='\e[0;36m'
YELLOW='\e[0;33m'

# UNDERLINED
UBLUE='\e[4;34m'
UGREEN='\e[4;32m'
UPURPLE='\e[4;35m'
URED='\e[4;31m'
UTEAL='\e[4;36m'
UYELLOW='\e[4;33m'

# BOLD
BBLUE='\e[1;34m'
BGREEN='\e[1;32m'
BPURPLE='\e[1;35m'
BRED='\e[1;31m'
BTEAL='\e[1;36m'
BYELLOW='\e[1;33m'

# allow for overrides as specified in /home/${MYUSER}/.${MYUSER}/settings
MYUSER=`whoami`
if [ -s ~/.${MYUSER}/settings ]; then
    source ~/.${MYUSER}/settings
else
    HOSTCOLOR=$RED
fi

# generate random password function
randpw() {
    pw=`dd if=/dev/urandom bs=1 count=16 2>/dev/null | base64 -w 0 | sed -e "s/=//g" | sed -e "s/[^a-zA-Z]/x/g"`
    echo $pw
    return 0
}

# need this for my PS1 prompt so it will contain the branchname if the CWD is a git checkout
git_branch() {
    ret=$(git symbolic-ref HEAD --short 2> /dev/null) || return;
    echo "<$ret>";
}

# prompt
PS1="[\[$BYELLOW\]\@ \[$YELLOW\]\u\[$NONE\]@\[$HOSTCOLOR\]\h\[$NONE\] \W\[$GREEN\]\[\$(git_branch)\]\[$NONE\]]\$ "

# mysql login function, parameter is a name of a defaults-extra-file file containing the connection info
function mlogin {
    if [ -z $1 ]; then
        echo "You need to specify a MySQL connection to use."
    else
        $(echo -e "mysql --defaults-extra-file=~/.mysql/$1 --prompt=\001\x1B[33m\002\\u\001\x1B[0m\002@\001\x1B[34m\002$1\001\x1B[0m\002:\001\x1B[32m\002\\d>\001\x1B[0m\002\ ")
    fi
}

function sshagent_findsockets {
    find /tmp -uid $(id -u) -type s -name agent.\* 2>/dev/null
}

function sshagent_testsocket {
    if [ ! -x "$(which ssh-add)" ] ; then
        echo "ssh-add is not available; agent testing aborted"
        return 1
    fi

    if [ X"$1" != X ] ; then
        export SSH_AUTH_SOCK=$1
    fi

    if [ X"$SSH_AUTH_SOCK" = X ] ; then
        return 2
    fi

    if [ -S $SSH_AUTH_SOCK ] ; then
        ssh-add -l > /dev/null
        if [ $? = 2 ] ; then
            echo "Socket $SSH_AUTH_SOCK is dead!  Deleting!"
            rm -f $SSH_AUTH_SOCK
            return 4
        else
            echo "Found ssh-agent $SSH_AUTH_SOCK"
            return 0
        fi
    else
        echo "$SSH_AUTH_SOCK is not a socket!"
        return 3
    fi
}

function sshagent_init {
    # ssh agent sockets can be attached to a ssh daemon process or an
    # ssh-agent process.

    AGENTFOUND=0

    # Attempt to find and use the ssh-agent in the current environment
    if sshagent_testsocket ; then AGENTFOUND=1 ; fi

    # If there is no agent in the environment, search /tmp for
    # possible agents to reuse before starting a fresh ssh-agent
    # process.
    if [ $AGENTFOUND = 0 ] ; then
        for agentsocket in $(sshagent_findsockets) ; do
            if [ $AGENTFOUND != 0 ] ; then break ; fi
            if sshagent_testsocket $agentsocket ; then AGENTFOUND=1 ; fi
        done
    fi

    # If at this point we still haven't located an agent, it's time to
    # start a new one
    if [ $AGENTFOUND = 0 ] ; then
        eval `ssh-agent`
    fi

    # Clean up
    unset AGENTFOUND
    unset agentsocket

    # Finally, show what keys are currently in the agent
    ssh-add -l
}

alias sagent="sshagent_init"
