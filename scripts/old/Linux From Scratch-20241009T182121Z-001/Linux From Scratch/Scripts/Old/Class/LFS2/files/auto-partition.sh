#!/bin/bash

function prep() {
	LFS=/mnt/lfs					# LFS drive location
	LFS_SOURCES=$LFS/sources			# LFS source files location
	LFS_TOOLS=$LFS/tools				# LFS tools files location
	BIT3264=$(uname -m) &> /dev/null		# Check if 32 or 64 bit system
	if [[ $BIT3264 == "x86_64" ]]; then
		SYSTEMID="64 Bit"
	elif [[ $BIT3264 == "i686" ]]; then
		SYSTEMID="32 Bit"
	else
		SYSTEMID="Unknown"
	fi
}

prep

function mainPage() {
  clear
  source setup.sh
}




function mainMenu() {
  block=`printf '%*s' "${COLUMNS:-1}" '' | sed 's/ /\o342\o226\o221/g'`
  line=`printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | sed 's/ /\o342\o226\o221/g'` #210 or 221
	clear
  printf $line
	echo " Linux From Scratch (Building on $SYSTEMID)"
  printf $line
	echo
	echo " 1: Start fdisk"
	echo " 2: Partition"
	echo
  echo " m: Main Menu"
	echo " q: Quit"
	echo
  lines=$(tput lines)
  columns=$(tput cols)
  echo "Lines: " $lines
  echo "Columns: " $columns
  printf $line
}

readOptions(){
	local choice
	read -p "Enter choice: " choice
	case $choice in
		1) startFdisk ;;
		2) autoPartition ;;
    m) mainPage ;;
		q) clear && exit 0;;
		*) echo -e "---Invalid Option---" && sleep 0.3
	esac
}

#trap '' SIGINT SIGQUIT SIGTSTP

while true
do

	mainMenu
	readOptions
done
