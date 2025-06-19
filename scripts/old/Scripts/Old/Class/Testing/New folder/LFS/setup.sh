#!/bin/bash

source scripts/settings.conf    # Load default settings

function versionCheck() {
	clear
	source scripts/version-check.sh
	if [ $errorCount == 0 ]; then
		errorsFound=$(tput setaf 2; echo "Pass"; tput sgr0)
		startUp="1"
	else
		errorsFound=$(tput setaf 1; echo "$errorCount Error(s) Found"; tput sgr0)
		startUp="0"
	fi
}

function setupLFS() {
	clear
	source scripts/setupLFS.sh
}

function changeUser() {
	titleHeader
	`su - lfs`
}

function mainMenu() {
	titleHeader
	tput cup 3 $c1; echo "1: Version Check";	tput cup 3 $c2; echo "$errorsFound"
	tput cup 4 $c1; echo "2: Setup";					tput cup 4 $c2; echo "$installStatus"
	tput cup 5 $c1; echo "3: Change User";		tput cup 5 $c2; echo "$currentUser"

	tput cup 7 $c1; echo "q: Quit"
	printf $line
}

readOptions(){
	local choice
	tput cup 9 $c1; read -p "Enter choice: " choice
	case $choice in
		1) versionCheck ;;
		2) setupLFS ;;
		3) changeUser ;;
		q) clear && exit 0 ;;
		*) echo -e "---Invalid Option---" && sleep 0.3
	esac
}

#trap '' SIGINT SIGQUIT SIGTSTP

while true
do
	if [ $startUp == "0" ]; then
		versionCheck
	fi
	mainMenu
	readOptions
done
