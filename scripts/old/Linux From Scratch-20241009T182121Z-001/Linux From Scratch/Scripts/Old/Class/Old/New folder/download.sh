#!/bin/bash
# shellcheck disable=SC1091
# LFS Scripts and Files Downloader
# Checked code at "http://www.shellcheck.net/"

# Connection Settings
internetSite='8.8.8.8'
downloadSite='http://67.242.159.158/projects/lfs/scripts/'
# Locations
lfsFolder='lfs/'
tempFolder=$lfsFolder'tmp/'
settingsFolder=$lfsFolder'config/'
scriptsFolder=$lfsFolder'scripts/'
# Files
downloaderScript='download.sh'
installerScript='lfs.sh'
versionFile='ver'
# Theme
topTitle="Linux From Scratch"
downloaderVersion="0.8.0.001"
# Theme
c1=1
c2=40

# Title Header
function titleHeader() {
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
# Connection Check
function connectionStatus() {
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
# File Downloader
function downloader() {
  if [ "$siteStatus" == 1 ]; then
    if curl --output /dev/null --silent --head --fail "$2"; then
      echo "URL exists: $2"
      curl -sI "$2" | grep "Last-Modified" | awk '{print $5 " " $4 " " $3 " " $6 " " $7}'
      curl -o "$1" "$2"
    else
      echo "URL doesnt exists: $2"
    fi
  fi
}
# Update Downloader Script
function updateDownloader() {
  titleHeader
  connectionStatus
  downloader $downloaderScript $downloadSite$downloaderScript
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to Reboot Downloader"; tput sgr0
  source download.sh
}
# LFS file downloader
function downloadLFS() {
  titleHeader
  # Check if version file exist to check if installed in the past
  if [ -f $settingsFolder$versionFile ]; then
    return 0
  fi
  # Check if lfs folder exist. If not, make directory
  if [ ! -d $lfsFolder ]; then
    mkdir $lfsFolder
  fi
  # Check if temp folder exist. If not, make directory
	if [ ! -d $tempFolder ]; then
		mkdir $tempFolder           # Create temp location
	fi
  # Check if settings folder exist. If not, make directory
  if [ ! -d $settingsFolder ]; then
    mkdir $settingsFolder
  fi
  # Check if ver file exist. If not, create and add info
  if [ ! -f $settingsFolder$versionFile ]; then
    touch $settingsFolder$versionFile
    echo "Version: "$downloaderVersion >> $settingsFolder$versionFile
    installTimeStamp=$(date +%Y-%m-%d:%H:%M:%S)
    echo "Installed: ""$installTimeStamp" >> $settingsFolder$versionFile
    fileModifiedTime=$(date +%Y-%m-%d:%H:%M:%S -r $downloaderScript)
    echo "Last Modified: ""$fileModifiedTime" >> $settingsFolder$versionFile
    #echo "Last Update Check: "$updateDownloaderDate >> $settingsFolder$versionFile
  fi
  # Check if settings folder exist. If not, make directory
  if [ ! -d $scriptsFolder ]; then
    mkdir $scriptsFolder
  fi

  xargs -P 10 -n 1 curl -O < url.txt
  connectionStatus
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}
# Launch Installer Script
function launchInstaller() {
  titleHeader
  # shellcheck source=lfs/lfs.sh
  source $lfsFolder$installerScript
}
# Delete Files & Start Over
function downloaderCleanup() {
  titleHeader
  echo "Removing LFS Builder Files..."
  rm -rvf lfs/
  rm -rvf lfs.sh
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}
# Main Menu
function downloaderMenu() {
  downloaderMainMenu() {
    titleHeader
    tput cup 3 $c1; echo "i: Install LFS Builder"
    tput cup 4 $c1; echo "u: Update Downloader"
    tput cup 5 $c1; echo "R: Uninstall Builder"
    tput cup 7 $c1; echo "l: Launch Builder"
    tput cup 9 $c1; echo "q: Quit"
    printf "%s" "$line"
  }
  readOptions() {
    local choice
    tput cup 11 $c1; read -r -p "Enter choice: " choice
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

downloaderMenu
