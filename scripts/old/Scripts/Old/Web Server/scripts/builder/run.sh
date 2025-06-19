#!/bin/bash

source settings.conf    # Load default settings
source logger.sh        # Load logger

LOG_INSTALL=$LFS_LOG_PATH/install.log

function toolClean() {
  logMakerInstall
  cd $LFS_SCRIPTS
  source $LFS_SCRIPTS/clean.sh
  INFO_INSTALL "Log Cleaned"
  INFO_INSTALL "Cleaning Tools Folder"
}

function fivePointFour() {
  INFO_INSTALL "5.4 - Binutils 2.27"
  tput cup 3 $c1; echo "5.4 - Binutils 2.27"
  cd $LFS_SCRIPTS
  fivePointFourTime="$( TIMEFORMAT='%lU'; time ( source $LFS_SCRIPTS/5.4-binutils.sh ) 2>&1 1>/dev/null )"
  tput cup 3 $c2; tput setaf 2; echo "Done"; tput sgr0
  tput cup 3 $c3; echo "$fivePointFourTime"
}

function fivePointFive() {
  INFO_INSTALL "5.5 - GCC 6.3.0"
  tput cup 4 $c1; echo "5.5 - GCC 6.3.0"
  cd $LFS_SCRIPTS
  fivePointFiveTime="$( TIMEFORMAT='%lU'; time ( source $LFS_SCRIPTS/5.5-gcc.sh ) 2>&1 1>/dev/null )"
  tput cup 4 $c2; tput setaf 2; echo "Done"; tput sgr0
  tput cup 4 $c3; echo "$fivePointFiveTime"
}

function fivePointSix() {
  INFO_INSTALL "5.6 - Linux 4.9.9 API Headers"
  tput cup 5 $c1; echo "5.6 - Linux 4.9.9 API Headers"
  cd $LFS_SCRIPTS
  fivePointSixTime="$( TIMEFORMAT='%lU'; time ( source $LFS_SCRIPTS/5.6-linux.sh ) 2>&1 1>/dev/null )"
  tput cup 5 $c2; tput setaf 2; echo "Done"; tput sgr0
  tput cup 5 $c3; echo "$fivePointSixTime"
}

function fivePointSeven() {
  INFO_INSTALL "5.7 - Glibc 2.25"
  tput cup 6 $c1; echo "5.7 - Glibc 2.25"
  cd $LFS_SCRIPTS
  fivePointSevenTime="$( TIMEFORMAT='%lU'; time ( source $LFS_SCRIPTS/5.7-glibc.sh ) 2>&1 1>/dev/null )"
  tput cup 6 $c2; tput setaf 2; echo "Done"; tput sgr0
  tput cup 6 $c3; echo "$fivePointSevenTime"
  tput cup 7 $c1; echo "Sanity Check: $glibcCheckStatus $glibcCheck"
}

function pass1() {
  titleHeader
  toolClean
  fivePointFour
  fivePointFive
  fivePointSix
  fivePointSeven
  printf $line
  tput cup 37 $anyKey; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}

function mainMenu() {
  titleHeader
	tput cup 3 $c1; tput setaf 2; echo "1: Pass 1"; tput sgr0
  tput cup 3 $c2; echo "$pass1Time"
  tput cup 4 $c1p; echo "1-0: Tools Folder Clean"
  tput cup 5 $c1p; echo "1-1: 5.4 - Binutils 2.27"
  tput cup 6 $c1p; echo "1-2: 5.5 - GCC 6.3.0"
  tput cup 7 $c1p; echo "1-3: 5.6 - Linux 4.9.9 API Headers"
  tput cup 8 $c1p; echo "1-4: 5.7 - Glibc 2.25"
	tput cup 9 $c1; tput setaf 2; echo "2: Pass 2"; tput sgr0
	tput cup 11 $c1; tput setaf 1; echo "q: Quit"; tput sgr0
	printf $line
}

readOptions(){
	local choice
	tput bold; read -p "Enter choice: " choice;	tput sgr0
	case $choice in
		1) pass1 ;;
    1-0) titleHeader && toolClean ;;
    1-1) titleHeader && fivePointFour ;;
    1-2) titleHeader && fivePointFive ;;
    1-3) titleHeader && fivePointSix ;;
    1-4) titleHeader && fivePointSeven ;;
		q) clear && exit 0 ;;
		*) echo -e "---Invalid Option---" && sleep 0.3
	esac
}

#trap '' SIGINT SIGQUIT SIGTSTP

prep

while true
do
	mainMenu
	readOptions
done
