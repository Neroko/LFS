#!/bin/bash
# shellcheck disable=SC1091
# LFS Scripts and Files Downloader
# Checked code at "http://www.shellcheck.net/"
#
# downloader.sh <command>
# <Commands>
#   install			Install and Run LFS Builder quietly
#	clean-install	
#	quiet-install	
#	full-install	
#	custom-install	
#	auto-install	

# Connection Settings
internetSite='8.8.8.8'
downloadSite='http://172.19.245.114/projects/lfs/'
scriptsSite=$downloadSite'scripts/'
# Locations
lfsFolder='lfs/'
tempFolder=$lfsFolder'tmp/'
settingsFolder=$lfsFolder'config/'
scriptsFolder=$lfsFolder'scripts/'
# Files
downloaderScript='downloader.sh'
versionFile='ver'
installerScript='lfs.sh'
settingsFile='settings.cfg'
versionCheckFile='version-check.sh'
# Theme
topTitle="Linux From Scratch"
downloaderVersion="1.8.1.001"
# Theme
c1=1

# Root Check
if [[ $EUID -ne 0 ]]; then			# Check if running as root
  rootStatus="Non-Root"
  clear
  echo "Needs to be ran as Root User"
  exit 0
else
  rootStatus="Root"
fi
function titleHeader() {			# Title Header
  maxWidth=$(tput cols)         # Screen Width
  line=$(printf "%*s\\n" "${COLUMNS:-$maxWidth}" '' | sed 's/ /\o342\o226\o221/g')
  mainTitle="$topTitle $downloaderVersion"              # Theme
  titleWidth=$(echo -n "$mainTitle" | wc -c)            # Title Width
  ((titlePosition = maxWidth / 2 - (titleWidth / 2)))   # Center Title Alignment
  clear
  tput clear                    # Title
  tput cup 0 0; printf "%s" "$line"
  tput cup 1 $titlePosition; tput bold; echo "$mainTitle"; tput sgr0;
  tput cup 2 0; printf "%s" "$line"
}
function connectionStatus() {		# Connection Check
  if [ "$(ping -c 1 "$internetSite")" ]; then
    internetStatus=1
    downloadSiteTrim=$(echo "$downloadSite" | sed "s/http:\\/\\///g" | cut -d "/" -f 1)
    if [ "$(ping -c 1 "$downloadSiteTrim")" ]; then
      siteStatus=1
      echo "Server Online"
    else
      siteStatus=0
      echo "Server Offline"
    fi
  else
    internetStatus=0
    echo "Internet Offline"
  fi
}
function downloader() {				# File Downloader
  if [ "$siteStatus" == 1 ]; then
    if curl --output /dev/null --silent --head --fail "$2"; then
    #if [ "$(curl --output /dev/null --silent --head --fail "$2")" ]; then
      echo "URL exists: $2"
      #curl -sI "$2" | grep "Last-Modified" | awk '{print $5 " " $4 " " $3 " " $6 " " $7}'
      printf "Downloading '%s'... " "$1" && curl -o "$1" "$2" &> /dev/null && echo "Complete"
    else
      echo "URL doesnt exists: $2"
    fi
  fi
}
function updateDownloader() {		# Update Downloader Script
  titleHeader
  printf "Checking Connection... " && connectionStatus
  downloader "$downloaderScript" "$downloadSite$downloaderScript"
  printf "%s" "$line"
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to Reboot Downloader"; tput sgr0
  source download.sh
}
function downloadLFS() {			# LFS file downloader
  titleHeader
  # Check connection status
  connectionStatus
  # If connection status is ok, continue
  if [ "$internetStatus" == 0 ] || [ "$siteStatus" == 0 ]; then
    printf "%s" "$line"
    tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
    return 0
  fi
  # If lfs folder doesnt exist, make directory
  if [ ! -d "$lfsFolder" ]; then
    printf "Making LFS Folder... "
    mkdir "$lfsFolder"
    echo "Complete"
  fi
  # If temp folder doesnt exist, make directory
	if [ ! -d "$tempFolder" ]; then
    printf "Making Temp Folder... "
		mkdir "$tempFolder"
    echo "Complete"
	fi
  # If settings folder doesnt exist, make directory
  if [ ! -d "$settingsFolder" ]; then
    printf "Making Settings Folder... "
    mkdir "$settingsFolder"
    echo "Complete"
  fi
  # If ver file doesnt exist, create and add info
  if [ ! -f "$settingsFolder$versionFile" ]; then
    printf "Creating Version File... "
    touch "$settingsFolder$versionFile"
    echo "Version: ""$downloaderVersion" >> "$settingsFolder$versionFile"
    installTimeStamp=$(date +%Y-%m-%d:%H:%M:%S)
    echo "Installed: ""$installTimeStamp" >> "$settingsFolder$versionFile"
    fileModifiedTime=$(date +%Y-%m-%d:%H:%M:%S -r "$downloaderScript")
    echo "Downloader Last Release: ""$fileModifiedTime" >> "$settingsFolder$versionFile"
    #echo "Last Update Check: ""$updateDownloaderDate" >> "$settingsFolder$versionFile"
    echo "Complete"
  # Else edit ver file and update info
  else
    printf "Updating Version File... "
    printf "Not really but we will still say -> "
    echo "Complete"
  fi
  # If settings folder doesnt exist, make directory
  if [ ! -d "$scriptsFolder" ]; then
    printf "Making Scripts Folder... "
    mkdir "$scriptsFolder"
    echo "Complete"
  fi
  downloader "$lfsFolder$installerScript" "$scriptsSite$installerScript"       # Download lfs script
  downloader "$settingsFolder$settingsFile" "$scriptsSite$settingsFile"        # Download settings file
  downloader "$scriptsFolder$versionCheckFile" "$scriptsSite$versionCheckFile" # Download version check script
  printf "%s" "$line"
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}
function launchInstaller() {		# Launch Installer Script
  titleHeader
  # shellcheck source=lfs/lfs.sh
  source "$lfsFolder$installerScript"
}
function downloaderCleanup() {		# Delete Files & Start Over
  titleHeader
  echo "Removing Builder Files..."
  rm -rvf "$lfsFolder"
  printf "%s" "$line"
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}
function downloaderMenu() {			# Main Menu
  downloaderMainMenu() {
    titleHeader
    tput cup 3 "$c1"; echo "i: Install LFS Builder"
    tput cup 4 "$c1"; echo "u: Update Downloader"
    tput cup 5 "$c1"; echo "R: Uninstall Builder"
    tput cup 7 "$c1"; echo "l: Launch Builder"
    tput cup 9 "$c1"; echo "q: Quit"
    printf "%s" "$line"
  }
  readOptions() {
    local choice
    tput cup 11 "$c1"; read -r -p "Enter choice: " choice
    case $choice in
      i) downloadLFS ;;
      u) updateDownloader ;;
      R) downloaderCleanup ;;
      l) launchInstaller ;;
      q) clear && exit 0 ;;
      *) echo -e "---Invalid Option---" && sleep 0.3
    esac
  }
  while true
  do
    downloaderMainMenu
    readOptions
  done
}

if [ "$1" == install ]; then
  updateDownloader quiet
  downloadLFS quiet
  clear
  exit 0
else
  downloaderMenu
fi
