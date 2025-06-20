#!/bin/bash
# Filename:	lfs_builder.sh
# Title:	LFS Builder Script
# Author: 	TerryJohn M. Anscombe
# Note:		LFS Builder

ROOT_UID=0
E_NOTROOT=65
E_NOPARAMS=66
# Locations
configFile="config.cfg"															# Config File
# Theme
topTitle="Linux From Scratch Builder"
downloaderVersion="0.8.2.001"
RED='\033[0;41;30m'
GREEN='\033[0;42;30m'
YELLOW='\033[0;43;30m'
STD='\033[0;0;39m'
BOLD='\e[1m'
BLINK='\e[5m'
DIM='\e[2m'
# Other
runningUser="$1"
clock_status_disable="$2"

startupCheck() {
	local currentDirectory
	
	if [ "$UID" -ne "$ROOT_UID" ]; then											# Check if running as root
		rootStatus="non-root"
		userStatus=$(echo -e "${RED}Non-Root User${STD}")
		headerStatus="Non-Root User"
	else
		rootStatus="root-user"
		userStatus=$(echo -e "${GREEN}Root User${STD}")
		headerStatus="Root User"
	fi
	
	if [ "$runningUser" == "lfsuser" ]; then
		if [ "$rootStatus" == "root-user" ]; then
			rootStatus="root-lfs-user"
			userStatus=$(echo -e "${GREEN}Root LFS User${STD}")
			headerStatus="Root LFS User"
		else
			rootStatus="lfs-user"
			userStatus=$(echo -e "${YELLOW}LFS User${STD}")
			headerStatus="LFS User"
		fi
	else
		clear
		echo -e "${RED}${BLINK}Needs to be ran as Root User${STD}"
		echo "Options:"
		echo -e "${GREEN}'sudo bash lfs_builder.sh lfsuser'${STD} for Root LFS User"
		echo -e "${YELLOW}'lfs_builder.sh lfsuser'${STD} for Non-Root LFS User"
		exit $E_NOTROOT
	fi
	
	if [ "$clock_status_disable" == "disable_clock" ]; then
		disable_clock="1"
	else
		disable_clock="0"
	fi
	
	if [ "$disable_clock" == "0" ]; then
		trap "exit" INT TERM ERR
		trap "kill 0" EXIT
		while sleep 0.5; do															# Upper Clock
			tput sc
			tput cup 2 $(($(tput cols)-11)); echo -e "${DIM}`date +%r`${STD}"
			tput rc
		done &
	fi
	
	# Use for lfsLocation
	currentDirectory=$(echo $PWD)
	
	if [ ! -f "$configFile" ]; then
		createConfig
	fi
	
	if [ ! -f "$configFile" ]; then
		echo "Could not create Config file."
		exit 1
	else
		source "$configFile"
	fi
}

createConfig() {
	if [ "$1" == "newFile" ]; then
		rm -rf "$configFile"
	fi
	
	touch "$configFile"
	
	cat >> "$configFile" <<EOF
#!/bin/bash
# Filename:		config.cfg
# Title:	LFS Builder Config File
# Note:		User config file

# Locations
# LFS Folder
lfsLocation="~/ownCloud/Notebook/lfs/"
# LFS ownCloud Folder
lfsowncloud="~/ownCloud/Notebook/lfs/"
# LFS Books Folder
lfsBooks="books/"
# LFS Files Folder
lfsFiles="files/"
# Sites
# Google Site
internetSite='8.8.8.8'
# LFS Download Site
lfsBookSite="http://www.linuxfromscratch.org/lfs/downloads/stable/"
localSite="http://192.168.0.1"
# Version
downloaderVersion="$downloaderVersion"
EOF

}

connStatus() {																	# Connection Check
	if [ "$(ping -c 1 "$internetSite" &)" ]; then
		connectionStatus=$(echo -e "${YELLOW}Internet Online${STD}")
		headerStatus="Internet Online"
		downloadSiteTrim=$(echo "$1" | sed "s/http:\\/\\///g" | cut -d "/" -f 1)
		if [ "$(ping -c 1 "$downloadSiteTrim" &)" ]; then
			connectionStatus=$(echo -e "${GREEN}Server Online${STD}")
			headerStatus="Server Online"
		else
			connectionStatus=$(echo -e "${RED}Server Offline${STD}")
			headerStatus="Server Offline"
		fi
	else
		connectionStatus=$(echo -e "${RED}Internet Offline${STD}")
		headerStatus="Internet Offline"
	fi
}

downloadLFSBook() {
	local folderStatus
	local choice
	local downloadFiles
	local siteStatus
	
#	ping -q -c 1 -w 2 $1 &>/dev/null
#	pingStatus=$?
#	if [ $pingStatus -ne 0 ]; then
#		echo "$1 Offline"
#	else
#		echo "$1 Online"
#	fi
	
	if [ ! -d "$1" ]; then														# If folder exist check
		folderStatus="0"
	else
		folderStatus="1"
	fi
	if [ $folderStatus == "1" ]; then											# Folder exist, delete and redownload?
		read -p "Redownload (y/N)? " -r -e choice
		if echo "$choice" | grep --ignore-case --quiet "^y"; then
			downloadFiles="y"
			rm --force --recursive "$1"
		else
			downloadFiles="n"
		fi
	else
		read -p "Download (Y/n)? " -r -e choice
		if echo "$choice" | grep --ignore-case --quiet "^n"; then
			downloadFiles="n"
		else
			downloadFiles="y"
		fi
	fi
	if [ "$downloadFiles" == "y" ]; then										# Folder does not exist, download?
		if [ "$siteStatus" == "1" ]; then
			wget --directory-prefix="$1" --recursive --quiet --no-parent --no-directories --reject "index.html*" "$2"
		else
			echo "LFS Site Offline"
			exit 1
		fi
	fi

}

manualBuild() {
	titleHeader
	echo "Nothing here yet"
	pause
}

autoBuild() {
	titleHeader
	echo "Nothing here yet"
	pause
}

mainMenu() {
	# Theme
	c1=1
	c2=34
	c3=47
	c4=70
	c5=83
	
	titleHeader() {																# Title Header
		local line1 line2 line3 currentHeaderStatus
		line1="o342"
		line2="o226"
		line3="o200"
		maxWidth=$(tput cols)													# Screen Width
		line=$(printf "%*s\\n" "${COLUMNS:-$maxWidth}" '' | sed 's/ /\'$line1'\'$line2'\'$line3'/g')
		mainTitle="$topTitle $downloaderVersion"								# Main Title
		titleWidth=$(echo -n "$mainTitle" | wc -c)								# Title Width
		((titlePosition = maxWidth / 2 - (titleWidth / 2)))						# Center Title Alignment
		currentHeaderStatus="Status: ""$headerStatus"							# Current Status
		statusWidth=$(echo -n "$currentHeaderStatus" | wc -c)					# Status Width
		((statusPosition = maxWidth / 2 - (statusWidth / 2)))					# Center Status Alignment
		clear
		tput clear																# Title Header Layout
		tput cup 0 0				; printf "%s" "$line"
		tput cup 1 $titlePosition	; echo -e "${BOLD}$mainTitle${STD}"
		tput cup 2 $statusPosition	; echo -e "${DIM}$currentHeaderStatus${STD}"
		tput cup 3 0				; printf "%s" "$line"
	}
	
	pause() {																	# Pause Option
		read -p "Press [Enter] key to continue..." fackEnterKey
	}
	
	manualInstallMenu() {
		local choice
		titleHeader
		tput cup 5 "$c1"; echo "1) Download LFS Sources"
		tput cup 6 "$c1"; echo "2) Check LFS Sources"
		tput cup 8 "$c1"; echo "B) Back"
		tput cup 9 "$c1"; echo "Q) Quit"
		tput cup 11 "$c1"; read -n 1 -p ": " choice
		case $choice in
			1)
				downloadFiles $wgetList $sourcesDirectory "sources" $md5File
				;;
			2)
				echo "Check LFS Sources"
				;;
			b|B)
				mainMenu
				;;
			q|Q)
				clear; exit 0
				;;
			*) echo -e " ${RED}**Invalid option**${STD}" && sleep 0.3 && manualInstallMenu
		esac
	}
	
	settingsMenu() {
		local choice
		
		changeLFSUrl() {
			local choice
			local newURL
			
			newBookUrl() {
				local search="lfsLocation"
				local replace="test"
				sed 's/^$search.*//g; /^$/d' $configFile
				pause
			}
			
			titleHeader
			# Options
			tput cup 4 "$c1"; echo "D) Default"
			tput cup 5 "$c1"; echo "Current: $lfsBookSite"
			tput cup 7 "$c1"; echo "B) Back"
			tput cup 8 "$c1"; echo "Q) Quit"
			tput cup 10 "$c1"; read -p ": " choice
			case $choice in
				d|D) defaultBookUrl ;;
				b|B) settingsMenu ;;
				q|Q) clear; exit 0;;
				*) newURL=$choice && newBookUrl && settingsMenu
			esac
		}
		
		titleHeader
		# Status
		tput cup 4 40; echo "Current: $lfsBookSite"
		tput cup 5 40; echo "Current: $lfsowncloud"
		tput cup 6 40; echo "Current: $lfsowncloud"
		# Menu
		tput cup 4 "$c1"; echo "1) Change LFS URL Download Site"
		tput cup 5 "$c1"; echo "2) Change Default LFS Directory"
		tput cup 6 "$c1"; echo "3) Change ownCloud Directory"
		tput cup 8 "$c1"; echo "L) Log Files"
		tput cup 9 "$c1"; echo "N) New Config File"
		tput cup 10 "$c1"; echo "B) Back"
		tput cup 11 "$c1"; echo "Q) Quit"
		tput cup 13 "$c1"; read -n 1 -p ": " choice
		case $choice in
			1) changeLFSUrl ;;
			2) echo "Default" ;;
			l|L) echo "Logs" ;;
			n|N) createConfig "newFile" ;;
			b|B) mainMenu ;;
			q|Q) clear; exit 0 ;;
			*) echo -e " ${RED}**Invalid option**${STD}" && sleep 0.3 && settingsMenu
		esac
	}
	
	connStatus "$lfsBookSite"
	
	local choice
	titleHeader
	# Status
	tput cup 4 "$c2"; echo "--Status--"
	tput cup 5 "$c2"; echo "User:"			; tput cup 5 "$c3"; echo "$userStatus"
	tput cup 6 "$c2"; echo "Connection:"	; tput cup 6 "$c3"; echo "$connectionStatus"
	tput cup 7 "$c2"; echo "Builder:"		; tput cup 7 "$c3"; echo "Ready"
	# Menu
	tput cup 4 "$c1"; echo -e "${BOLD}A) Auto${STD}"
	tput cup 5 "$c1"; echo "M) Manual"
	tput cup 6 "$c1"; echo "S) Settings"
	tput cup 8 "$c1"; echo "Q) Quit"
	tput cup 10 "$c1"; read -n 1 -p ": " choice
	case $choice in
		a|A) mainMenu ;;
		m|M) manualInstallMenu ;;
		s|S) settingsMenu ;;
		q|Q) clear; exit 0 ;;
		*) echo -e "${RED}**Invalid option**${STD}" && sleep 0.3 && mainMenu
	esac
	
	wait
}

startupCheck
mainMenu
