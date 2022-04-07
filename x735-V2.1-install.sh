#!/bin/bash

#x735-V2.1 script installer

#Installs x735-V2.1-pwr.sh (poweroff via hardware latching switch) and/or x735-V2.1-shutdown.sh (poweroff via software).

INSTALL_SOFTWARE=false
INSTALL_HARDWARE=false
INSTALL_PATH="/usr/local/bin"
QUIET=false

usage()
{
  printf "Usage: x735-V2.1-install.sh [ -s | --software ] [ -h | --hardware ] [ -p | --path ] [ -q | --quiet ] \n"
  exit 2
}

#Read (optional) flags and parameters
tput setaf 1
ARGS=$(getopt -n x735-V2.1-install.sh -o 'shp:q' --long 'software,hardware,path:,quiet' -- "$@") 
ARGS_EXIT=$?
tput sgr0

if [ "$ARGS_EXIT" != "0" ]; then 
  usage
fi

eval "set -- $ARGS"

#Set variables according to flags
while : ; do
  case "$1" in
    -s | --software) INSTALL_SOFTWARE=true ; shift ;;
    -h | --hardware) INSTALL_HARDWARE=true ; shift ;;
    -p | --path) INSTALL_PATH=$2 ; shift 2 ;;
    -q | --quiet) QUIET=true ; shift ;;
    --) shift; break ;;
  esac
done

if ! $INSTALL_SOFTWARE  && ! $INSTALL_HARDWARE ; then
  tput setaf 3; 
  printf "No script specified. Defaulting to software only. \n"; 
  tput sgr0;
  INSTALL_SOFTWARE=true
fi 

#Promt for installation path (if not supplied)
if [ -z $INSTALL_PATH ]; then
  INSTALL_PATH="/usr/local/bin"
  tput setaf 3; 
  printf "Specify the desired script location. ENTER for default ($INSTALL_PATH):"; 
  tput sgr0;
  read INSTALL_PATH
fi 

if [ ! -d $INSTALL_PATH ]; then 
  tput setaf 1; 
  sudo mkdir $INSTALL_PATH; 
  tput sgr0;
fi

if $INSTALL_SOFTWARE; then
  tput setaf 3; 
  sudo cp $(pwd)/scripts/x735-V2.1-shutdown.sh $INSTALL_PATH; sudo chmod +x $INSTALL_PATH/x735-V2.1-shutdown.sh; 
  tput sgr0;
fi

if $INSTALL_HARDWARE; then
  tput setaf 3; 
  sudo cp $(pwd)/scripts/x735-V2.1-pwr.sh $INSTALL_PATH; sudo chmod +x $INSTALL_PATH/x735-V2.1-pwr.sh;
  tput setaf 2; 
  sudo echo "[Unit]
    Description= x735 hardware powerdown script
    [Service]
    Type=simple
    ExecStart=/bin/bash "$INSTALL_PATH"/x735-V2.1-pwr.sh
    [Install]
    WantedBy=multi-user.target" > x735-V2.1-pwr.service
  sudo cp x735-V2.1-pwr.service /etc/systemd/system; 
  sudo systemctl enable x735-V2.1-pwr; 
  printf "Done setting x735-V2.1-pwr up as a systemd service. \n";
  tput sgr0;
fi