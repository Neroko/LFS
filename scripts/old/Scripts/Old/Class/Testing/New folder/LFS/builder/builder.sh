#!/bin/bash

# Root Check
if [[ $EUID -ne 0 ]]; then		          # Check if running as root
  rootStatus="0"
else
  rootStatus="1"
  clear
  echo "Not to be ran as Root"
  exit
fi

# Formats
DATE=$(date +%Y-%m-%d)

# Locations
builderDownloads='downloads/'
builderScripts='scripts/'
builderLogPath='logs/'
builderLog='builder-'$DATE'.log'
packagesArchive='lfs-packages-8.0.tar'    # LFS source package archive
packagesDownload='http://67.242.159.158/projects/lfs/files/lfs-packages-8.0.tar'

# Theme
columns=$(tput cols)
line=$(printf '%*s\n' "${COLUMNS:-$columns}" '' | sed 's/ /\o342\o226\o221/g')
((title = columns / 2 - 10))

# Site Connect Settings
siteChecks='3'
internetCheckSite='8.8.8.8'
siteCheckSite='67.242.159.158'

# Logger
function logMaker() {
  if [ ! -d "$builderLogPath" ]; then
    mkdir -v $builderLogPath
  fi
  if [ ! -f "$builderLogPath$builderLog" ]; then  # If log file doesnt exist, create it
    touch $builderLogPath$builderLog
  elif [ -f "$builderLogPath$builderLog" ]; then  # Else delete old and create new
    rm -rf $builderLogPath$builderLog
    touch $builderLogPath$builderLog
  fi
}
function SCRIPTENTRY_BUILDER() {
  timeAndDate=`date`
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  > $script_name $FUNCNAME" >> $builderLogPath$builderLog
}
function SCRIPTEXIT_BUILDER() {
  script_name=`basename "$0"`
  script_name="${script_name%.*}"
  echo "[$timeAndDate] [DEBUG]  < $script_name $FUNCNAME" >> $builderLogPath$builderLog
}
function ENTRY_BUILDER() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  > $cfn $FUNCNAME" >> $builderLogPath$builderLog
}
function EXIT_BUILDER() {
  local cfn="${FUNCNAME[1]}"
  timeAndDate=`date`
  echo "[$timeAndDate] [DEBUG]  < $cfn $FUNCNAME" >> $builderLogPath$builderLog
}
function INFO_BUILDER() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [INFO]  $msg" >> $builderLogPath$builderLog
}
function DEBUG_BUILDER() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [DEBUG]  $msg" >> $builderLogPath$builderLog
}
function ERROR_BUILDER() {
  local function_name="${FUNCNAME[1]}"
    local msg="$1"
    timeAndDate=`date`
    echo "[$timeAndDate] [ERROR]  $msg" >> $builderLogPath$builderLog
}

# Options
function updateBuilder() {
  {
    ENTRY_BUILDER
    function makeFolder() {         # Make Folder Function
      if [ ! -d "$1" ]; then
        INFO_BUILDER "Creating folder ($1)"
        mkdir -v $1
      fi
    }
    function setupDirectories() {   # Make Builder Directories
      ENTRY_BUILDER
      makeFolder "$builderDownloads"
      makeFolder "$builderScripts"
      EXIT_BUILDER
    }
    function fileExist() {          # Check if file exist
  		if [ ! -e "$1" ]; then
        INFO_BUILDER "No existing Archive Package"
        archiveFileExist=0
  		else
        INFO_BUILDER "Existing Archive Package"
  			archiveFileExist=1
  		fi
  	}
    function siteCheck() {          # Internet Check
      if [[ "$(ping -c $1 $2 | grep '100% packet loss')" != "" ]]; then
        ERROR_BUILDER "Internet Offline"
        internetStatus=0
      else
        INFO_BUILDER "Internet Online"
        internetStatus=1
      fi

      if [[ "$(ping -c $1 $3 | grep '100% packet loss')" != "" ]]; then
        ERROR_BUILDER "Site Offline"
        siteStatus=0
      else
        INFO_BUILDER "Site Online"
        siteStatus=1
      fi
      if [[ "$internetStatus" == 1 && "$siteStatus" == 1 ]]; then
        INFO_BUILDER "Connected"
        connectionStatus=1
      else
        ERROR_BUILDER "No Connection"
        connectionStatus=0
    }
  	function downloadArchive() {    # Download Files
      ENTRY_BUILDER
      siteCheck $siteChecks $internetCheckSite $siteCheckSite
  		if [[ "$internetStatus" == 1 && "$siteStatus" == 1 ]]; then
  			fileExist "$builderDownloads$packagesArchive"
  			if [[ "$archiveFileExist" == 1 ]]; then
          DEBUG_BUILDER "Deleting old Archive Package"
  				rm -rf $builderDownloads$packagesArchive
  			fi
        INFO_BUILDER "Downloading Archive Package"
  			wget --output-document=$builderDownloads$packagesArchive $packagesDownload
  		fi
      EXIT_BUILDER
  	}

    setupDirectories
    downloadArchive
    EXIT_BUILDER
  } 2>&1 | tee -a $builderLogPath$builderLog &> /dev/null
  pressAnyKey
}
function setupBuilder() {
  INFO "Empty"
}
function runBuilder() {
  INFO "Empty"
}

# Main Menu
function titleHeader() {
  clear
  tput clear
  tput cup 0 0; printf $line
  tput cup 1 $title; tput bold; printf "Linux From Scratch"; tput sgr0
  tput cup 2 0; printf $line
}
function mainMenu() {
  titleHeader
  tput cup 3 1; echo "1: Update"
  tput cup 4 1; echo "2: Setup"
  tput cup 5 1; echo "3: Run"
  tput cup 7 1; echo "q: Quit"
  tput cup 8 0; printf $line
}
function pressAnyKey() {
  local dummy
  tput bold; read -s -r -p "Press any key to continue" -n 1 dummy; tput sgr0
}
spinner() {
	local pid=$1
	local delay=0.25
	local spinstr='|/-\'
	while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
		local temp=${spinstr#?}
		printf " [%c]  " "$spinstr"
		local spinstr=$temp${spinstr%"$temp"}
		sleep $delay
		printf "\b\b\b\b\b\b"
	done
	printf "    \b\b\b\b"
}
readOptions() {
  local choice
  tput cup 9 0; tput bold; read -p "Enter choice: " choice; tput sgr0
  case $choice in
    1) updateBuilder ;;
    2) setupBuilder ;;
    3) runBuilder ;;
    q) clear && SCRIPTEXIT_BUILDER && exit ;;
    *) echo -e "---Invalid Option---" && sleep 0.3
  esac
}

logMaker
SCRIPTENTRY_BUILDER
while true
do
  mainMenu
  readOptions
done
