#!/bin/bash
# download-lfs-stable.sh
#  Downloads LFS Stable from Site
#
#  Author: TerryJohn M. Anscombe

defaultDirectory="/home/tj/LFS"
installDirectory="$defaultDirectory/stable"
toolsDirectory="$installDirectory/tools"
sourcesDirectory="$installDirectory/sources"
lfsSite="http://www.linuxfromscratch.org/lfs/downloads/stable/"
wgetList="$installDirectory/wget-list"
md5File="$installDirectory/md5sums"
NOW=$(date "+%Y-%m-%d")
logDirectory="$defaultDirectory/logs"
logFile="$logDirectory/$NOW.log"
title="LFS Downloader"
RED='\033[0;41;30m'
STD='\033[0;0;39m'

logCleanup() {
  if [ "$1" == "setup" ]; then
    if [ -d "$2" ]; then
      echo "Removing old logs.."
      rm --verbose --recursive --force "$2"
    fi
    
    if  [ ! -d "$2" ]; then
      echo "Making log directory..."
      mkdir --verbose "$2"
    fi
  elif [ "$1" == "complete" ]; then
    echo "Cleaning up logs..."
  fi
}

downloadFiles() {
  echo "Downloading "$2"..."
  {
    if [ -d "$2" ]; then
      echo "Removing "$2" folder..."
      rm --verbose --recursive --force "$2"
    fi
    
    if [ ! -d "$2" ]; then
      echo "Making "$2" directory..."
      mkdir --verbose "$2"
    fi
    
    if [ "$3" == "book" ]; then
      cd $2
      echo "Downloading files..."
      wget --verbose --recursive --no-host-directories --cut-dirs=4 --no-parent --reject "index.html*" "$1"
    elif [ "$3" == "sources" ]; then
      cd $2
      echo "Downloading LFS sources..."
      wget --content-disposition --trust-server-names --input-file "$1"
      md5sum --check $4
    fi
  } 2>> $logFile &>> $logFile
  echo "Complete"
}

autoInstall() {
  clear
  logCleanup "setup" $logDirectory
  downloadFiles $lfsSite $installDirectory "book"
  downloadFiles $wgetList $sourcesDirectory "sources" $md5File
  #logCleanup "complete"
  pause
  menu
}

menu() {
  pause() {
    read -p "Press [Enter] key to continue..." fackEnterKey
  }
  
  manualInstallMenu() {
    clear
    echo "================"
    echo "$title"
    echo "================"
    echo "1) Download LFS Book"
    echo "2) Download LFS Sources"
    echo "3) Check LFS Sources"
    echo
    echo "B) Back"
    echo "Q) Quit"
    echo "================"
    read -n 1 -p ": " choice
    
    case $choice in
     1) downloadFiles $lfsSite $installDirectory "book";;
     2) downloadFiles $wgetList $sourcesDirectory "sources" $md5File;;
     3) ;;
     b|B) menu;;
     q|Q) clear; exit;;
     *) echo -e " ${RED}**Invalid option**${STD}" && sleep 1; manualInstallMenu
    esac
  }
  
  settingsMenu() {
    clear
    echo "================"
    echo "$title"
    echo "================"
    echo "1) Change LFS URL Download Site (Current: $lfsSite)"
    echo "2) Change Default LFS Directory (Current: $defaultDirectory)"
    echo
    echo "L) Log Files"
    echo
    echo "B) Back"
    echo "Q) Quit"
    echo "================"
    read -n 1 -p ": " choice
    
    case $choice in
     1) echo "Site";;
     2) echo "Default";;
     l|L) echo "Logs";;
     b|B) menu;;
     q|Q) clear; exit;;
     *) echo -e " ${RED}**Invalid option**${STD}" && sleep 1; settingsMenu
    esac
  }
  
  local choice
  clear
  echo "================"
  echo "$title"
  echo "================"
  echo "A) Auto"
  echo "M) Manual"
  echo "S) Settings"
  echo
  echo "Q) Quit"
  echo "================"
  read -n 1 -p ": " choice
  
  case $choice in
    a|A) autoInstall;;
    m|M) manualInstallMenu;;
    s|S) settingsMenu;;
    q|Q) clear; exit;;
    *) echo -e " ${RED}**Invalid option**${STD}" && sleep 1; menu
  esac
}

menu
