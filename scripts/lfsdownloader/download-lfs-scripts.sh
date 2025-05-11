#!/bin/bash

display_title="== Linux From Scratch (LFS) Download Needed Files =="
#
# VERSION (LFS):
current_version="12.3"
#
# VERSION (SCRIPT):
script_version="1.0.0.1"
#
# DATE LAST EDITED:
#   05/11/2025
#
# DATE CREATED:
#   03/03/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# USAGE:
#   download-lfs-scripts.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
# DESCRIPTION
#   Script to download LFS scripts and files needed files from GitHub

#download_site="https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/wget-list"

export lfs="/mnt/lfs"

user_directory=$(getent passwd "$USER" | cut -d: -f6)
download_directory=""$user_directory"/lfs/"
download_site="https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/scripts/lfsdownloader/"

# Check for directory and see if it exist:
if [ ! -d "$download_directory" ]; then
	mkdir						\
 		--verbose				\
		--parents				\
		"$download_directory";
fi

download_file(){
	rm						\
 		--verbose				\
		--force					\
		--recursive				\
		"$1"
	wget						\
		--verbose				\
		--output-document="$1"			\
		""$download_site"$2"
	chmod						\
		--verbose				\
		755					\
		"$1"
}

download_file	""$download_directory"version-check.sh"		"00-version-check.sh"
download_file	""$download_directory"setup-system.sh"		"01-setup-system.sh"
download_file	""$download_directory"sources-setup.sh"		"02-sources-setup.sh"
