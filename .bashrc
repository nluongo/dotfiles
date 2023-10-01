# .bashrc

if [ -z "$PS1" ]; then
  # prompt var is not set, so this is *not* an interactive shell
  # this is to prevent startup scripts running in the case of e.g. scp
  return
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

path_remove() {
  # Delete path by parts so we can never accidentally remove sub paths
  PYTHONPATH=${PYTHONPATH//":$1:"/":"} # delete any instances in the middle
  PYTHONPATH=${PYTHONPATH/#"$1:"/} # delete any instance at the beginning
  PYTHONPATH=${PYTHONPATH/%":$1"/} # delete any instance in the at the end
}

export PS1="\[\033[38;5;3m\][\u@\h \w]\\$ \[$(tput sgr0)\]"

gotoAFS() {
  cd ~
  export PS1="\[\033[38;5;3m\][\u@\h \w]\\$ \[$(tput sgr0)\]"
}

gotoEOS() {
  cd /eos/user/n/nicholas
  export PS1="\[\033[38;5;2m\][\u@\h \w]\\$ \[$(tput sgr0)\]"
}

# User specific aliases and functions
export RUCIO_ACOUNT='nicholas'
export ALRB_TutorialData=/afs/cern.ch/atlas/project/PAT/tutorial/cern-jan2018
export PYTHONDIR=/usr/bin

# Create shortcut to home in EOS
export eosHome=/eos/user/n/nicholas

# Make my custom ROOT functions available for importing in python
PYTHONPATH="$PYTHONPATH:$HOME/ROOTModules"
export PYTHONPATH

alias voms="voms-proxy-init -voms atlas"  
alias cmake_atlas="cmake -DATLAS_PACKAGE_FILTER_FILE=../package_filters.txt ../athena/Projects/WorkDir"
alias lm='ls -lhtr'

bbtautauSetup() {
  setupATLAS
  asetup
  source x86_64-*/setup.sh
}

newROOTSetup() {
  lsetup "root 6.16.00-x86_64-slc6-gcc62-opt"
}

tauBuild() {
  cd ~/NewTauSamples/build
  acmSetup
  cd ~/NewTauSamples/scripts
}

runBitwise() {
  source ../build/x*/setup.sh
  athena.py -c "doL1Sim=True" --evtMax=1 --filesInput="../mc15_13TeV/AOD.07272134._000326.pool.root.1" L1CaloFEXSim/eFEXDriverJobOptions.py 2>&1 | tee run.log
}

# This allows the creation of persistent tmux session that continually refreshes itself
ktmux(){
  if [[ -z "$1" ]]; then #if no argument passed
    k5reauth -f -i 3600 -p nicholas -k ./keytab/nicholas.keytab -- tmux new-session
  else #pass the argument as the tmux session name
    k5reauth -f -i 3600 -p nicholas -k ./keytab/nicholas.keytab -- tmux new-session -s $1
  fi
}

#ktmuxPanes() { k5reauth -f -i 3600 -p nicholas -k ~/keytab/nicholas.keytab tmux new-session \; split-window -v \; split-window -h \; select-pane -U \; split-window -h \; resize-pane -D 10 \; select-pane -L ; }
ktmuxPanes() { 
  k5reauth -f -i 3600 -- tmux new-session \; tmux split-window -v \; split-window -h \; select-pane -U \; split-window -h \; resize-pane -D 10 \; select-pane -L
}

tmuxPanes() { 
  tmux new-session -d
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
  echo $project
  if [[ $project == "bbtautauMIA" ]]; 
  then
    echo "In MIA";
    folder="/eos/user/n/nicholas/SWAN_projects/bbtautau/MIA"
  elif [[ $project == "DiTauReco" ]];
  then
    echo "In DiTauReco";
    folder="/eos/user/n/nicholas/SWAN_projects/DiTauReco"
  elif [[ $project == "Bitwise" ]];
  then
    echo "In Bitwise";
    folder="/eos/user/n/nicholas/SWAN_projects/L1CaloBitwise";
  elif [[ $project == "run3Trigger" ]];
  then
    echo "In run3Trigger";
    folder="/eos/user/n/nicholas/SWAN_projects/bbbtautau/run3Trigger";
  elif [[ $project == "Derivation" ]];
  then
    echo "In Derivation";
    folder="/eos/user/n/nicholas/SWAN_projects/Derivation";
  elif [[ $project == "MLTree" ]];
  then
    echo "In MLTree";
    folder="/eos/user/n/nicholas/SWAN_projects/MLTreeAnalysis";
  elif [[ $project == "LCStudies" ]];
  then
    echo "In LCStudies";
    folder="/eos/user/n/nicholas/SWAN_projects/LCStudies";
  else
    echo "Not valid dude";
    return;
  fi

  echo $folder
  cd $folder
  tmuxPanes
  tmux send "cd build" ENTER
  tmux send "asetup --restore" ENTER
  tmux send "source x*/setup.sh" ENTER
  tmux attach
}

export ATLAS_LOCAL_ROOT_BASE=/cvmfs/atlas.cern.ch/repo/ATLASLocalRootBase
alias setupATLAS='source ${ATLAS_LOCAL_ROOT_BASE}/user/atlasLocalSetup.sh'

setupATLAS
lsetup git
if [ $PWD == $HOME ];then
  gotoEOS
fi

# Do this so that we can access these commands in other bash scripts/functions e.g. tauBuild
# acmSetup only becomes available after running setupATLAS
export -f setupATLAS
export -f acmSetup

echo 'Use "mySetup _" to get started'
echo 'Current options: bbtautauMIA, DiTauReco, Bitwise, run3Trigger, Derivation, MLTree, LCStudies'

LS_COLORS='rs=0:di=01;94:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
source [path]/thisroot.sh
export DISPLAY=:0
