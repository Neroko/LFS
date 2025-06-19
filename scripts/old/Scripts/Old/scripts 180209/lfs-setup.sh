#!/bin/bash

# Connection Settings
internetSite='8.8.8.8'
downloadSite='http://www.linuxfromscratch.org/lfs/downloads/stable/'
# Locations
lfsFolder='lfs/'
tempFolder=$lfsFolder'tmp/'
settingsFolder=$lfsFolder'config/'
# Files
downloaderScript='download.sh'
versionFile='ver'
installerScript='lfs.sh'
settingsFile='settings.cfg'
versionCheckFile='version-check.sh'
# Theme
topTitle="Linux From Scratch"
downloaderVersion="0.8.1.001"
# Theme
c1=1

function rootCheck() {																													# Root Check
	if [[ $EUID -ne 0 ]]; then																										# Check if running as root
		rootStatus="Non-Root"
		clear
		echo "Needs to be ran as Root User"
		exit 0
	else
		rootStatus="Root"
	fi
}
function titleHeader() {																												# Title Header
	maxWidth=$(tput cols)																													# Screen Width
	line=$(printf "%*s\\n" "${COLUMNS:$maxWidth}" '' | sed 's/ /\o342\o226\o221/g')
	mainTitle="$topTitle $downloaderVersion"																			# Theme
	titleWidth=$(echo -n "mainTitle" | wc -c)																			# Title Width
	((titlePosition = maxWidth / 2 - (titleWidth /2)))														# Center Title Alignment
	clear
	tput clear
	tput cup 0 0; printf "%s" "$line"
	tput cup 1 $titlePosition; tput bold; echo "$mainTitle"; tput sgr0;
	tput cup 2 0; printf "%s" "$line"
}
function connectionStatus() {																										# Connection Check
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
function downloader() {																													# File Downloader
	if [ "$siteStatus" == 1 ]; then
		if curl --output /dev/null --silent --head --fail "$2"; then
			echo "URL exists: $2"
			printf "Downloading '%s'... " "$1" && curl -o "$1" "$2" &> /dev/null && echo "Complete"
		else
			echo "URL doesnt exists: $2"
		fi
	fi
}
function updateDownloader() {																										# Update Downloader Script
	titleHeader
	printf "Checking Connection... " && connectionStatus
	downloader "$downloaderScript" "$downloadSite$downloaderScript"
	printf "%s" "$line"
	tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to Reboot Downloader"; tput sgr0
	source download.sh
}
function downloadLFS() {																												# LFS File Downloader
	titleHeader
	connectionStatus																															# Check connection status
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
	if [ -f "$settingsFolder$versionFile" ]; then
		printf "Creating Version File... "
		touch "$settingsFolder$versionFile"
		echo "Version: ""$downloaderVersion" >> "$settingsFolder$versionFile"
		installTimeStamp=$(date +%Y-%m-%d:%H:%M:%S)
}
