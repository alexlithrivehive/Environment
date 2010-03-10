################################ set shell opts ################################
#
#
## export HOME=/localtmp/jvinding
umask 002
export EDITOR=vi
if [ $BASH ]
then
    set -o vi
    shopt -s checkwinsize
else
    export ENV=~/.bashrc
fi

export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL=ignoredups
#
#
############################## end set shell opts ##############################

####################### source server specific settings  #######################
#
#
HOSTNAME=`uname -n`
HOSTNAME=${HOSTNAME%%.*}
[ -f ~/Environment/$HOSTNAME ]          && . ~/Environment/$HOSTNAME
[ -f ~/.bashscripts/$HOSTNAME ]         && . ~/.bashscripts/$HOSTNAME
[ -f ~jvinding/.bashscripts/$HOSTNAME ] && . ~jvinding/.bashscripts/$HOSTNAME
#
#
##################### end source server specific settings  #####################

##################################### PATH #####################################
#
# let's setup the PATH so it works across many different machines
# but doesn't get cluttered up w/ non-existant dirs
#

#
# ~/bin and ~jvinding/bin for when i do su - <whoever>
#
for p in  $SERVERPATH ~/bin /usr/local/bin
do
    if [ -d "$p" ] && ! echo $PATH | egrep "(^|:)$p($|:)" > /dev/null
    then
        PATH=$p:$PATH
    fi
done
export PATH
#
#
################################### end PATH ###################################

############################### LD_LIBRARY_PATH  ###############################
#
# read comment for PATH above
#
for p in /usr/local/lib /data/advantage/perl-5.8.0/lib/5.8.0 $SERVERLDPATH
do
    if [ -d $p ] && ! echo $LD_LIBRARY_PATH | egrep "(^|:)$p($|:)" > /dev/null
    then
        LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$p
    fi
done
LD_LIBRARY_PATH=${LD_LIBRARY_PATH#:}
export LD_LIBRARY_PATH
#
#
############################### LD_LIBRARY_PATH  ###############################

################################## other vars ##################################
#
#
export DISPLAY=${SSH_CLIENT%% *}:0
if [ $BASH ]
then
    export HISTIGNORE='l:l[sa]:lsd'
fi
#
#
################################ end other vars ################################

##################################### misc #####################################
#
# this is here instead of at the end, because on some machines
# a PROMPT_COMMAND is getting set in /etc/bashrc
#
[ $BASH ] && [ -f ~/.bashrc ] && . ~/.bashrc
#
#
################################### end misc ###################################

#################################### prompt ####################################
#
#
#Black       0;30     Dark Gray     1;30
#Blue        0;34     Light Blue    1;34
#Green       0;32     Light Green   1;32
#Cyan        0;36     Light Cyan    1;36
#Red         0;31     Light Red     1;31
#Purple      0;35     Light Purple  1;35
#Brown       0;33     Yellow        1;33
#Light Gray  0;37     White         1;37
BLACK="\[\033[0;30m\]"  # black
BLUE="\[\033[0;34m\]"   # blue
GREEN="\[\033[0;32m\]"  # green
CYAN="\[\033[0;36m\]"   # cyan
RED="\[\033[0;31m\]"    # red
PURPLE="\[\033[0;35m\]" # purple
BROWN="\[\033[0;33m\]"  # brown
GREY="\[\033[1;30m\]"   # grey
# enhanced
eGREY="\[\033[0;37m\]"   # light gray
eBLUE="\[\033[1;34m\]"   # light blue
eGREEN="\[\033[1;32m\]"  # light green
eCYAN="\[\033[1;36m\]"   # light cyan
eRED="\[\033[1;31m\]"    # light red
ePURPLE="\[\033[1;35m\]" # light purple
eYELLOW="\[\033[1;33m\]" # yellow
eWHITE="\[\033[1;37m\]"  # white
# reset to teminal default
NORMAL="\[\033[0;0m\]"  # normal term color


if [ $BASH ]
then
    #
    # these are various ways of shortening the path for display
    #
    function chop_to_length {
        local pwd_length=50
        _TMP_PWD=${PWD/$HOME/~}
        if [ ${#_TMP_PWD} -gt $pwd_length ]
        then
            _TMP_PWD="...${_TMP_PWD:$(( ${#_TMP_PWD} - $pwd_length )):$pwd_length}"
        fi
    }
    function chop_middle_dirs {
        local pwd_length=50
        _TMP_PWD=${PWD/$HOME/~}
        if [ ${#_TMP_PWD} -gt $pwd_length ]
        then
            _TMP_PWD=$(echo -n ${_TMP_PWD#/} | perl -e'
                $_ = <>;
                @d=split m!/!; $l = @d - 2;
                print qq!/$d[0]/...$l.../$d[-1]!')
        fi
    }
    function chop_front_dirs_to_fit {
        local pwd_length=50
        _TMP_PWD=${PWD/$HOME/~}
        _TMP_PWD=$(echo -n "${_TMP_PWD#/} $pwd_length" | perl -e'
            my $arg = <>;
            ($dir, $len) = $arg =~ /(\S*(?:\s\S*)*)\s(\S+)/;
            @d = split m!/!, $dir;
            $p = "/\033[0;32m" . pop @d;
            while (length $p < $len && @d) {
                $p = "/" . pop (@d) . "$p" if ((length $p + length $d[-1]) < $len);
            }
            $p = "..." . scalar @d . "...$p" if @d;
            print $p;')
    }
    function prompt_command {
        chop_front_dirs_to_fit
        if [ "$TERM" = "xterm" ]
        then
            echo -e "\033]0;${USER}@${HOSTNAME}:$_TMP_PWD\007"
        fi
        if [ -d .git ]
        then
            _TMP_SCM=$(git branch | grep ^\* | cut -c3-)
        elif [ -d .svn ]
        then
            _TMP_SCM=$(svn info | grep ^URL | sed -e's!.*/\([^/]*\)!\1!')
        else
            _TMP_SCM="N/A"
        fi
    }
    export PROMPT_COMMAND=prompt_command
    PROMPT_SCM="$BLUE-=($GREEN\$_TMP_SCM$BLUE)=-"
    PROMPT_PWD="$BLUE-=($RED\$_TMP_PWD$BLUE)=-"
    PROMPT_RETURN="$BLUE-=($RED\$?$BLUE)=-"
    PROMPT_HISTORY="$BLUE-=($RED\!$BLUE)=-"
    PROMPT_JOBS="$BLUE-=($RED\j$BLUE)=-"
    PROMPT_USER="$BLUE-=($RED\\u"
    PROMPT_HOST="@\\h$BLUE)=-"
    PROMPT_PROMPT="$CYAN \\$ $NORMAL"
    PROMPT_LINE_1="$PROMPT_PWD"
    PROMPT_LINE_2="$PROMPT_SCM$PROMPT_RETURN$PROMPT_HISTORY$PROMPT_JOBS"
    PROMPT_LINE_3="$PROMPT_USER$PROMPT_HOST$PROMPT_PROMPT"
    export PS1="$GREEN/$PROMPT_LINE_1\n$GREEN>$PROMPT_LINE_2\n$GREEN\\\\$PROMPT_LINE_3"
##  export PS1='\[\033]0;\u@\h:$_TMP_PWD\007\]($?) [\u@\h] \$ '
else
    if [ "$TERM" = "xterm" ] || [ "$TERM" = "cygwin" ]
    then
        export PS1=']0;$USER@$HOSTNAME:$PWD($?) [$USER@$HOSTNAME] \$ '
    else
        export PS1='($?) [$USER@$HOSTNAME] \$ '
    fi
fi
#
#
################################## end prompt ##################################
