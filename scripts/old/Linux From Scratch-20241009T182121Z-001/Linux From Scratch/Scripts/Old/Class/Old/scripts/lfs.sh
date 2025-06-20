#!/bin/bash

source settings.cfg

function bootupCheck() {
  # Bootup check, check if all files are downloaded. If not, download.
  echo "Nothing"
}

function settingsConfig() {
  titleHeader
  echo "Settings Menu Coming Soon..."
  tput setaf 1; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
}

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

function mainMenu() {
  function menu() {
    titleHeader
    tput cup 3 $c1; echo "1: Preparing Build"
    tput cup 4 $c1; echo "2: Packages and Patches"
    tput cup 5 $c1; echo "3: Final Preparations"
    tput cup 6 $c1; echo "s: Settings"
    tput cup 8 $c1; echo "d: Downloader"
    tput cup 9 $c1; echo "q: Quit"
    printf $line
  }
  
  readOptions() {
    local choice
    tput cup 11 $c1; read -p "Enter choice: " choice
    case $choice in
      1) chapter2 ;;
      2) chapter3 ;;
      3) chapter4 ;;
      s) settingsConfig ;;
      d) source download.sh ;;
      q) clear && exit 0 ;;
      *) echo -e "---Invalid Option---" && sleep 0.3
    esac
  }
  
  while true
  do
    menu
    readOptions
  done
}

function chapter2() {
  function chapter2Menu() {
    titleHeader
    tput cup 3 $cc1; echo "Preparing Build"
    tput cup 4 $c1; echo "1: (2.2) Host System Requirements Check";  tput cup 4 $c2; echo "$errorsFound"
    tput cup 5 $c1; echo "2: (2.4) Create New Partitions"
    tput cup 6 $c1; echo "3: (2.5) Create File System on Partitions"
    tput cup 7 $c1; echo "4: (2.6) Set \$LFS Variable"
    tput cup 8 $c1; echo "5: (2.7) Mount Partitions"
    tput cup 10 $c1; echo "m: Main Menu"
    tput cup 11 $c1; echo "q: Quit"
    printf $line
  }
  
  readOptions() {
    local choice
    tput cup 13 $c1; read -p "Enter choice: " choice
    case $choice in
      1) versionCheck ;;
      2) newPartition ;;
      3) fileSystem ;;
      4) lfsVariable ;;
      5) mountPartition ;;
      m) mainMenu ;;
      q) clear && exit 0 ;;
      *) echo -e "---Invalid Option---" && sleep 0.3
    esac
  }
  
  while true
  do
    chapter2Menu
    readOptions
  done
}

function chapter3() {
  function chapter3Menu() {
    titleHeader
    tput cup 3 $cc1; echo "Packages and Patches"
    tput cup 4 $c1; echo "1: (3.1) Create \$LFS/sources Directory and Download Packages"
    tput cup 6 $c1; echo "m: Main Menu"
    tput cup 7 $c1; echo "q: Quit"
    printf $line
  }
  
  readOptions() {
    local choice
    tput cup 9 $c1; read -p "Enter choice: " choice
    case $choice in
      1) sourceDirectory ;;
      m) mainMenu ;;
      q) clear && exit 0 ;;
      *) echo -e "---Invalid Option---" && sleep 0.3
    esac
  }
  
  while true
  do
    chapter3Menu
    readOptions
  done
}

function chapter4() {
  function chapter4Menu() {
    titleHeader
    tput cup 3 $cc1; echo "Final Preparations"
    tput cup 4 $c1; echo "1: (4.2) Create \$LFS/tools Directory"
    tput cup 5 $c1; echo "2: (4.3) Add LFS User"
    tput cup 6 $c1; echo "3: (4.4) Setup Environment"  
    tput cup 8 $c1; echo "m: Main Menu"
    tput cup 9 $c1; echo "q: Quit"
    printf $line
  }

  readOptions() {
    local choice
    tput cup 11 $c1; read -p "Enter choice: " choice
    case $choice in
      1) toolsDirectory ;;
      2) addUser ;;
      3) setupEnvironment ;;
      m) mainMenu ;;
      q) clear && exit 0 ;;
      *) echo -e "---Invalid Option---" && sleep 0.3
    esac
  }
  
  while true
  do
    chapter4Menu
    readOptions
  done
}

mainMenu
