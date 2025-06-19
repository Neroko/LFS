#!/bin/bash

function prep() {
	source files/settings.cfg
	startUp=0											# If 0, run version check
	if [[ $EUID -ne 0 ]]; then		# Check if running as root
		rootStatus="Non-Root"
	else
		rootStatus="Root"
	fi
	BIT3264=$(uname -m) &> /dev/null		# Check if 32 or 64 bit system
	if [[ $BIT3264 == "x86_64" ]]; then
		SYSTEMID="64 Bit"
	elif [[ $BIT3264 == "i686" ]]; then
		SYSTEMID="32 Bit"
	else
		SYSTEMID="Unknown"
	fi
}

function versionCheck() {
	clear
	source files/version-check.sh
	if [ $errorCount == 0 ]; then
		errorsFound="Pass"
	else
		errorsFound="$errorCount Errors Found"
	fi
}

function autoPartition() {
	clear
	source files/auto-partition.sh
}

function displaySettings() {
	if [ $columns -lt $minScreenSize ]; then
		clear
		tput clear
		tput cup 3 $smallDisplay; tput setaf 1; tput bold; echo "Display to small"; tput sgr0
		tput cup 4 $anyKey; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
		tput clear
	fi
}

function mainMenu() {
	displaySettings
	clear
  printf $line
	echo " Linux From Scratch (Building on $SYSTEMID & $rootStatus)"
	printf $line
	echo
	echo " 1: Version Check	$errorsFound"
	echo " 2: Partition"
	echo
	echo " q: Quit"
	echo
	printf $line
}

readOptions(){
	local choice
	read -p "Enter choice: " choice
	case $choice in
		1) versionCheck ;;
		2) autoPartition ;;
		q) clear && exit 0 ;;
		*) echo -e "---Invalid Option---" && sleep 0.3
	esac
}

#trap '' SIGINT SIGQUIT SIGTSTP

prep

while true
do
	if [ $startUp == 0 ]; then
		versionCheck
	fi
	mainMenu
	readOptions
done
