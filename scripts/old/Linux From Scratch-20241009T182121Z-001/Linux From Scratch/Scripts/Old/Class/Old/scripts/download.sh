#!/bin/bash

# LFS Scripts and File Downloader
#   Step 1:
#   Step 2:

# Settings
downloadSite='http://67.242.159.158/'
projectsFolder=$downloadSite'projects/lfs/scripts/'
downloaderScript='download.sh'
lfsFolder='lfs/'
tempFolder=$lfsFolder'tmp/'
installerScript='lfs.sh'
settingsFolder=$lfsFolder'config/'
settingsFilename='settings.cfg'
settingsFile=$settingsFolder$settingsFilename
versionFile='ver'
downloadList='wget-list'
scriptsFolder=$lfsFolder'scripts/'
topTitle="Linux From Scratch"
downloaderVersion="0.01"

# Theme
maxWidth=$(tput cols)           # Screen Width
line=$(printf '%*s\n' "${COLUMNS:-$maxWidth}" '' | sed 's/ /\o342\o226\o221/g')
((titleP = maxWidth / 2 - 10))  # Title Alignment
c1=1

function titleHeader() {        # Title Header
  clear
  tput clear
  tput cup 0 0; printf $line
  tput cup 1 $titleP; tput bold; echo $topTitle; tput sgr0;
  tput cup 2 0; printf $line
}

function firstRun() {
  if [ ! -d $lfsFolder ]; then
    mkdir $lfsFolder
  fi

  if [ ! -d $settingsFolder ]; then
    mkdir $settingsFolder
  fi

  if [ ! -f $settingsFolder$versionFile ]; then
    touch $settingsFolder$versionFile
    echo "Version: "$downloaderVersion >> $settingsFolder$versionFile
    installTimeStamp=$(date +%Y-%m-%d:%H:%M:%S)
    echo "Installed: "$installTimeStamp >> $settingsFolder$versionFile
    fileModifiedTime=$(date +%Y-%m-%d:%H:%M:%S -r $downloaderScript)
    echo "Last Modified: "$fileModifiedTime >> $settingsFolder$versionFile
    #echo "Last Update Check: "$updateDownloaderDate >> $settingsFolder$versionFile
  fi

  #while read -r fileLine
  #do
  #  name="$fileLine"
  #  echo "$name"
  #done < "$versionFile"

  if [ ! -d $scriptsFolder ]; then
    mkdir $scriptsFolder
  fi

	if [ ! -d $tempFolder ]; then
		mkdir $tempFolder           # Create temp location
	fi
}

function downloader() {         # File Downloader
  if [[ `wget -S --spider $2 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then  # Check if file exist on server
  #  lastModified=$(wget -S --spider $2 2>&1 | grep 'Last-Modified:' | awk '{printf $3 " " $4 " " $5 " " $6 " " $7}' )
  #  lastModified2=$(wget -S --spider $2 2>&1 | grep 'Last-Modified:')
  #  echo $lastModified
  #  echo $lastModified2
    if [ -f $1 ]; then
      rm -rf $1                     # If file exist on server and on remote drive, delete old from remote
    fi
    `wget -O $1 $2`                       # Download file from server to remote drive
  fi
}

function downloaderCleanup() {
  titleHeader
  rm -rvf lfs/
  rm -rvf lfs.sh
  rm -rvf settings.cfg
  rm -rvf wget-list
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}

function downloadLFS() {        # LFS file downloader
  titleHeader
  downloader $lfsFolder$installerScript $projectsFolder$installerScript
  downloader $settingsFolder$settingsFilename $projectsFolder$settingsFilename
  downloader $settingsFolder$downloadList $projectsFolder$downloadList
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}

function updateDownloader() {   # Update Downloader Script
  titleHeader
  downloader $downloaderScript $projectsFolder$downloaderScript
  updateDownloaderDate=$(date +%Y-%m-%d:%H:%M:%S)
  #echo "Last Updated Check: "$updateDownloaderDate >> $versionFile
  #sed -i -e 's/abc/XYZ/g' < /tmp/file.txt > /tmp/file.txt.t
  #while read a
  #do
  #  echo ${a//abc/XYZ}
  #done < /tmp/file.txt > /tmp/file.txt.t
  #mv /tmp/file.txt{.t,}
  if [ ! -f $versionFile ]; then
    rm -rf $versionFile
  fi
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to Reboot Downloader"; tput sgr0
  source download.sh
}

function launchInstaller() {    # Launch Installer Script
  titleHeader
  source $lfsFolder$installerScript
}

function downloaderMenu() {     # Main Menu
  titleHeader
  tput cup 3 $c1; echo "1: Download Installer"
  tput cup 4 $c1; echo "2: Update Downloader"
  tput cup 5 $c1; echo "3: LFS Cleaner"
  tput cup 6 $c1; echo "4: Launch Installer"
  tput cup 8 $c1; echo "q: Quit"
  printf $line
}

readOptions() {
  local choice
  tput cup 10 $c1; read -p "Enter choice: " choice
  case $choice in
    1) downloadLFS ;;
    2) updateDownloader ;;
    3) downloaderCleanup ;;
    4) launchInstaller ;;
    s) settingsConfig ;;
    q) clear && exit 0 ;;
    *) echo -e "---Invalid Option---" && sleep 0.3
  esac
}

if [ ! -f $settingsFolder$versionFile ]; then
  firstRun
fi

while true
do
  downloaderMenu
  readOptions
done
