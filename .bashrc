# /.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias lm='ls -lhtr'

# test if the prompt var is not set and also to prevent failures
# when `$PS1` is unset and `set -u` is used 
if [ -z "${PS1:-}" ]; then
    # prompt var is not set, so this is *not* an interactive shell
    return
fi

export PS1='\[\e[32m\][\t \u@\h:\w]\$ \[\e[0m\]'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias voms="voms-proxy-init -voms atlas"
alias ls="ls --color=auto"
alias lm="ls -lhtr"
alias grep="grep -I"

export RUCIO_ACCOUNT=nicholas

builder() {
  asetup --restore
  source x*/setup.sh
}

tmuxPanes() { 
  tmux new-session -d -s temp_name
  tmux split-window -v
  tmux split-window -h
  tmux select-pane -U
  tmux split-window -h
  tmux resize-pane -D 10
  tmux select-pane -L
  tmux select-pane -D
}

tmuxSplit() { tmux split-window -v \; split-window -h \; select-pane -U \; split-window -h \; resize-pane -D 10 \; select-pane -L\; send-keys "echo 'Did it!'" C-m ; }

mySetup() {
  project=$1
  if [[ $project == "bbll" ]]; 
  then
    echo "In bbll";
    folder="/home/nluongo/bbll"
  elif [[ $project == "MasterShef" ]];
  then
    echo "In MasterShef";
    folder="/home/nluongo/MS"
  elif [[ $project == "AnaSkim" ]];
  then
    echo "In AnaSkim";
    folder="/home/nluongo/AS"
  elif [[ $project == "PAU" ]];
  then
    echo "In PyAnalysisUtils";
    folder="/home/nluongo/PAU"
  elif [[ $project == "DoubleHiggs" ]];
  then
    echo "In DoubleHiggs";
    folder="/home/nluongo/DoubleHiggs"
  elif [[ $project == "FTAGDumper" ]];
  then
    echo "In training-dataset-dumper";
    folder="/home/nluongo/FTAG/dumper"
  elif [[ $project == "FTAGupp" ]];
  then
    echo "In umami-preprocessing";
    folder="/home/nluongo/FTAG/upp"
  elif [[ $project == "salt" ]];
  then
    echo "In salt";
    folder="/home/nluongo/FTAG/salt"
  elif [ -d $project ];
  then
    echo "In $project";
    folder=$project
  else
    echo "$project is not a valid project or directory";
    return 0
  fi

  echo $folder
  cd $folder
  tmuxPanes
  tmux send "cd build" ENTER
  tmux send "asetup --restore" ENTER
  tmux send "source x*/setup.sh" ENTER
  tmux attach
  while [ $(tmux display-message -p '#S') == "temp_name" ]
  do
    echo "In while"
    tmux rename-session -t temp_name "${project}"
  done
}
complete -W 'bbll MasterShef AnaSkim PAU DoubleHiggs FTAGDumper FTAGupp salt' mySetup
complete -F _cd mySetup

scptolxplus() {
  if [ $# > 1 ]
  then
    FILE_NAME_DEST=$2
  else
    FILE_NAME_DEST=''
  fi
  scp $1 nicholas@lxplus.cern.ch:/eos/user/n/nicholas/$FILE_NAME_DEST
}

lcrc() {
  cd /lcrc/group/ATLAS/users
}

ath() {
  cd ~/athena
  asetup master,latest,Athena
  cd -
}

bbtautauSetup() {
  setupATLAS
  asetup
  source x86_64-*/setup.sh
}

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Import ssh aliases
. ~/.ssh_aliases

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/nicholas/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/nicholas/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/home/nicholas/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/nicholas/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.local/bin"

setterm -blength 0

alias python='python3'

tmuxPanes() { tmux new-session \; split-window -v \; split-window -h \; select-pane -U \; split-window -h \; resize-pane -D 10 \; select-pane -L; }

tmuxSplit() { tmux split-window -v \; split-window -h \; select-pane -U \; split-window -h \; resize-pane -D 10 \; select-pane -L; }

launchPracticeApp() {
	source ~/Code/PracticeApp/venv/bin/activate
	cd ~/Code/PracticeApp
    . run.sh    
}

devPracticeApp() {
	source ~/Code/PracticeApp/venv/bin/activate
	cd ~/Code/PracticeApp
}

doEmails() {
    cd ~/Code/EmailEvents
    source venv/bin/activate
    python get_emails.py
    deactivate
    cd ~
}

keylight() {
    echo 2 | sudo tee /sys/class/leds/asus::kbd_backlight/brightness
}

dimExternalMonitor() {
    xrandr --output HDMI-2 --brightness 0.5
}

brightenExternalMonitor() {
    xrandr --output HDMI-2 --brightness 1.0
}

rpissh() {
    ssh pi@10.0.0.239
}

rpivnc() {
    ~/Code/VNC-Viewer-6.20.529-Linux-x64
}

fixwifi() {
    sudo rmmod iwlmvm && sudo modprobe iwlmvm
}

if [ -f "/home/nicholas/lxplusnode.txt" ]; then
    node=$(cat /home/nicholas/lxplusnode.txt)
    echo "Open tmux session on lxplus$node"
fi

export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

LS_COLORS='rs=0:di=01;94:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.zst=01;31:*.tzst=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.wim=01;31:*.swm=01;31:*.dwm=01;31:*.esd=01;31:*.jpg=01;35:*.jpeg=01;35:*.mjpg=01;35:*.mjpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.webp=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.oga=00;36:*.opus=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/nicholas/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/nicholas/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

tex() {
  source /soft/hep/hep_texlive.sh
}

minitree_events() {
  root $1 -q -e "AnalysisMiniTree->GetEntries()"
}

minitree_branches() {
  root $1 -q -e "AnalysisMiniTree->Print()"
}

# CometML variables for salt training
. ~/.comet_info

export ATLAS_STORAGE=/lcrc/group/ATLAS/users/

export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
#alias setupATLAS='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh -c el9 -b -q -m lcrc'
alias setupATLAS='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh'

setupATLAS
lsetup git

echo 'Use "mySetup _" to get started';
echo 'Current options: DoubleHiggs, bbll, MasterShef, AnaSkim, PAU, FTAGDumper, FTAGupp, salt';

if tmux has-session 2>/dev/null; then
  echo "Existing tmux sessions"
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/gpfs/fs1/home/nluongo/DoubleHiggs/spark/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/gpfs/fs1/home/nluongo/DoubleHiggs/spark/conda/etc/profile.d/conda.sh" ]; then
        . "/gpfs/fs1/home/nluongo/DoubleHiggs/spark/conda/etc/profile.d/conda.sh"
    else
        export PATH="/gpfs/fs1/home/nluongo/DoubleHiggs/spark/conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
