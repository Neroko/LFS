#!/bin/bash
# Filename:	lfs_builder.sh
# Title:	LFS Builder Script
# Author: 	TerryJohn M. Anscombe
# Note:		LFS Builder
#  Arguments:
#    disable_clock				Disable clock in title bar

ROOT_UID=0
E_NOTROOT=65
E_NOPARAMS=66
# Locations
config_file="config.cfg"														# Config File
# Theme
top_title="Linux From Scratch Builder"
lfs_builder_version="0.8.2.001"
RED='\033[0;41;30m'
GREEN='\033[0;42;30m'
YELLOW='\033[0;43;30m'
STD='\033[0;0;39m'
BOLD='\e[1m'
BLINK='\e[5m'
DIM='\e[2m'
# Other
running_user="$1"
clock_status_disable="$2"
disable_clock="1"

startup_check() {
	local current_directory
	
	if [ "$UID" -ne "$ROOT_UID" ]; then											# Check if running as root
		root_status="non-root"
		user_status=$(echo -e "${RED}Non-Root User${STD}")
		header_status="Non-Root User"
	else
		root_status="root-user"
		user_status=$(echo -e "${GREEN}Root User${STD}")
		header_status="Root User"
	fi
	
	if [ "$running_user" == "lfsuser" ]; then
		if [ "$root_status" == "root-user" ]; then
			user_status=$(echo -e "${GREEN}Root LFS User${STD}")
			header_status="Root LFS User"
		else
			root_status="lfs-user"
			user_status=$(echo -e "${YELLOW}LFS User${STD}")
			header_status="LFS User"
		fi
	else
		clear
		echo -e "${RED}${BLINK}Needs to be ran as Root or LFS User${STD}"
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
	
	# Use for lfs_location
	current_directory=$(echo $PWD)
	
	if [ ! -f "$config_file" ]; then
		config_file_option "new_file"
	fi
	
	if [ ! -f "$config_file" ]; then
		echo "Could not create Config file."
		exit 1
	else
		source "$config_file"
	fi
}

version_check() {
	export LC_ALL=C
	errorCount=0
	
	function version_minmax() {
		function version_gt() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" != "$1"; }
		function version_le() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" == "$1"; }
		function version_lt() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" != "$1"; }
		function version_ge() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" == "$1"; }
		if version_lt "$2" "$2"; then
			((errorCount=errorCount + 1))
			versionStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $2)"; tput sgr0)
		elif version_gt "$1" "$3"; then
			((errorCount=errorCount + 1))
			versionStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $3)"; tput sgr0)
		else
			versionStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	}
	
	function BASH() {
		{ bashVersion=$(bash --version | head -n1 | cut -d" " -f4); } &> /dev/null
		if [[ "$bashVersion" == "" ]]; then
			((errorCount=errorCount + 1))
			bashStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
		else
			bashVersionMin="3.2"
			if version_lt "$bashVersion" "$bashVersionMin"; then
				((errorCount=errorCount + 1))
				bashStatus=$(tput setaf 3; tput bold; echo "Version to low (Lowest $bashVersionMin)"; tput sgr0)
			else
				bashStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
			fi
		fi
	}
	
}

config_file_option() {
	if [ "$1" == "new_file" ]; then
		rm -rf "$config_file"
	fi
	
	if [ ! -f "$config_file" ]; then
		> "$config_file"
	else
		echo "Config file already exist"
		sleep 3
	fi
	
	cat >> "$config_file" << EOF
#!/bin/bash
# Filename:	config.cfg
# Title:	LFS Builder Config File
# Note:		User config file

# Locations
# LFS Builder Location
LFS="/mnt/lfs"
# LFS Folder
lfs_location="~/ownCloud/Notebook/lfs/"
# LFS ownCloud Folder
lfs_owncloud="~/ownCloud/Notebook/lfs/"
# LFS Books Folder
lfs_book="books/"
# LFS Files Folder
lfs_files="files/"
# LFS Drive
lfs_drive="/dev/sdb"
lfs_root_drive="/dev/sdb1"
lfs_swap_drive="/dev/sdb2"

# Sites
# Google Site
internet_site='8.8.8.8'
# LFS Download Site
lfs_book_site="http://www.linuxfromscratch.org/lfs/downloads/stable/"
local_site="http://192.168.0.1"

# Version
lfs_builder_version="$lfs_builder_version"
EOF
	
	if [ ! -f "$config_file" ]; then
		echo "Could not create Config file."
		exit 1
	else
		source "$config_file"
	fi
}

network_status() {																# Connection Check
	if [ "$(ping -c 1 "$internet_site" &)" ]; then
		connection_status=$(echo -e "${YELLOW}Internet Online${STD}")
		header_status="Internet Online"
		site_name_trim=$(echo "$1" | sed "s/http:\\/\\///g" | cut -d "/" -f 1)
		if [ "$(ping -c 1 "$site_name_trim" &)" ]; then
			connection_status=$(echo -e "${GREEN}Server Online${STD}")
			header_status="Server Online"
		else
			connection_status=$(echo -e "${RED}Server Offline${STD}")
			header_status="Server Offline"
		fi
	else
		connection_status=$(echo -e "${RED}Internet Offline${STD}")
		header_status="Internet Offline"
	fi
}

partitions_setup() {
	#label:dos
	#label-id: 0x9f52a493
	#device: /dev/sdb
	#unit: sectors
	#
	#/dev/sdb1 : start=        2048, size=    20971520, type=83, bootable
	#/dev/sdb2 : start=    20973568, size=     4194304, type=82
	
	if [ "$root_status" == "root-user" ]; then
		if [ "$1" == "drive_list" ]; then
			drive_list=$(fdisk -l)
			drive_size=$(df -h)
		elif [ "$1" == "full_drive_list" ]; then
			fdisk -l
		elif [ "$1" == "create_lfs_partitions" ]; then
			cfdisk "$lfs_drive"
		elif [ "$1" == "format_lfs_partitions" ]; then
			mkfs -v -t ext4 "$lfs_root_drive"
			mkswap "$lfs_swap_drive"
		elif [ "$1" == "mount_lfs_partition" ]; then
			if [ ! -d "$LFS" ]; then
				mkdir -pv "$LFS"
			fi
			
			mount -v -t ext4 "$lfs_root_drive" "$LFS"
			/sbin/swapon -v "$lfs_swap_drive"
		elif [ "$1" == "unmount_lfs_partition" ]; then
			umount -v -t ext4 "$LFS"
		fi
	else
		echo -e "    ${RED}NEED ROOT ACCESS${STD}" && sleep 3 && main_menu
	fi
}

packages_setup() {
	if [ "$root_status" == "root-user" ]; then
		if [ "$1" == "create_sources_directory" ]; then							# Create Sources Directory
			if [ ! -d "$LFS/sources" ]; then
				mkdir -v "$LFS/sources"
			fi
			chmod -v a+wt "$LFS/sources"
			
		elif [ "$1" == "download_package_sources" ]; then						# Download packages to source directory
			if [ ! -f "wget-list" ]; then
				wget "http://www.linuxfromscratch.org/lfs/downloads/stable/wget-list"
			fi
		
			if [ -f "wget-list" ]; then
				wget --input-file="wget-list" --continue --directory-prefix="$LFS/sources"
			fi
			
		elif [ "$1" == "check_package_sources" ]; then							# Check packages in source directory
			wget "http://www.linuxfromscratch.org/lfs/downloads/stable/md5sums"
			cp -v "md5sums" "$LFS/sources"
			pushd "$LFS/sources"
			md5sum -c "md5sums"
			popd
			
		elif [ "$1" == "create_tools_directory" ]; then							# Create Tools Directory
			if [ ! -d "$LFS/tools" ]; then
				mkdir -v "$LFS/tools"
			fi
			ln -sv "$LFS/tools" "/"
			
		elif [ "$1" == "add_lfs_user" ]; then									# Create LFS User
			groupadd lfs
			useradd -s /bin/bash -g lfs -m -k /dev/null lfs
			passwd lfs
			
			# Set directory permission for LFS User
			chown -v lfs "$LFS/tools"
			chown -v lfs "$LFS/sources"
			
			# Setup Environment
			> "/home/lfs/.bash_profile"
			cat >> "/home/lfs/.bash_profile" << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
			chown -v lfs "/home/lfs/.bash_profile"
			
			> "/home/lfs/.bashrc"
			cat >> "/home/lfs/.bashrc" << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF
			chown -v lfs "/home/lfs/.bashrc"
			
		elif [ "$1" == "upload_scripts" ]; then
			echo "Copy builder scripts"
			pause
			
		elif [ "$1" == "login_lfs_user" ]; then
			su - lfs
			
		elif [ "$1" == "builder_start_over" ]; then								# !! BUILDER START OVER NOT DONE !!
			printf "Cleaning tools directory... "
			if [ -d "$LFStools" ]; then												# Check for tools directory.
				toolsDirectoryStatus=$(shopt -s nullglob dotglob; echo $LFStools"*")	# Check if directory contains files.
				if (( ${#toolsDirectoryStatus} )); then									# If contains old files,
					rm --recursive --force $LFStools*									#  delete all.
				fi
			fi
			echo "Complete"
			
			sourceClean() {
				printf "Cleaning ""$1"" directory... "
				if [ -d "$LFSsources""$1" ]; then
					rm --recursive --force "$LFSsources""$1"
				fi
				echo "Complete"
			}
			
			sourceClean "binutils"
			sourceClean "gcc"
			sourceClean "linux"
			sourceClean "glibc"
			
		fi
	else
		echo -e "    ${RED}NEED ROOT ACCESS${STD}" && sleep 3 && main_menu
	fi

}

download_lfs_book() {
	local folder_status
	local choice
	local download_files
	local site_status
	
#	ping -q -c 1 -w 2 $1 &>/dev/null
#	pingStatus=$?
#	if [ $pingStatus -ne 0 ]; then
#		echo "$1 Offline"
#	else
#		echo "$1 Online"
#	fi
	
	if [ ! -d "$1" ]; then														# If folder exist check
		folder_status="0"
	else
		folder_status="1"
	fi
	if [ $folder_status == "1" ]; then											# Folder exist, delete and redownload?
		read -p "Redownload (y/N)? " -r -e choice
		if echo "$choice" | grep --ignore-case --quiet "^y"; then
			download_files="y"
			rm --force --recursive "$1"
		else
			download_files="n"
		fi
	else
		read -p "Download (Y/n)? " -r -e choice
		if echo "$choice" | grep --ignore-case --quiet "^n"; then
			download_files="n"
		else
			download_files="y"
		fi
	fi
	if [ "$download_files" == "y" ]; then										# Folder does not exist, download?
		if [ "$site_status" == "1" ]; then
			wget --directory-prefix="$1" --recursive --quiet --no-parent --no-directories --reject "index.html*" "$2"
		else
			echo "LFS Site Offline"
			exit 1
		fi
	fi

}

main_menu() {
	# Theme
	c1=1
	c2=34
	c3=47
	c4=70
	c5=83
	
	title_header() {															# Title Header
		local line1 line2 line3 current_header_status
		line1="o342"
		line2="o226"
		line3="o200"
		max_width=$(tput cols)													# Screen Width
		line=$(printf "%*s\\n" "${COLUMNS:-$max_width}" '' | sed 's/ /\'$line1'\'$line2'\'$line3'/g')
		main_title="$top_title $lfs_builder_version"							# Main Title
		title_width=$(echo -n "$main_title" | wc -c)							# Title Width
		((title_position = max_width / 2 - (title_width / 2)))					# Center Title Alignment
		current_header_status="Status: ""$header_status"						# Current Status
		status_width=$(echo -n "$current_header_status" | wc -c)					# Status Width
		((status_position = max_width / 2 - (status_width / 2)))					# Center Status Alignment
		clear
		tput clear																# Title Header Layout
		tput cup 0 0				; printf "%s" "$line"
		tput cup 1 $title_position	; echo -e "${BOLD}$main_title${STD}"
		tput cup 2 $status_position	; echo -e "${DIM}$current_header_status${STD}"
		tput cup 3 0				; printf "%s" "$line"
	}
	
	pause() {																	# Pause Option
		read -p "Press [Enter] key to continue..." fackEnterKey
	}
	
	manual_install_menu() {
		partitions_setup "drive_list"
		
		local choice
		title_header
		# Status
		tput cup 21 0; echo -e "${GREEN}Available Drives:${STD}"
		tput cup 22 0; echo "$drive_list" | grep "/dev/sd"
		tput cup 29 0; echo -e "${GREEN}Drive Space:${STD}"
		tput cup 30 0; echo "$drive_size" | grep "/dev/sd"
		# Menu
		tput cup 4 "$c1"; echo "V) Version Check"
		tput cup 4 "$c1"; echo "R) Refresh Drive List"
		tput cup 5 "$c1"; echo "D) Drive List"
		tput cup 6 "$c1"; echo "P) Create Partitions"
		tput cup 7 "$c1"; echo "F) Format Partitions"
		tput cup 8 "$c1"; echo "M) Mount Partitions"
		tput cup 9 "$c1"; echo "U) Unmount Partitions"
		tput cup 10 "$c1"; echo "S) Setup Sources and Tools Directories"
		tput cup 11 "$c1"; echo "O) Restart Sources and Tools Directories"
		tput cup 12 "$c1"; echo "L) Setup LFS User"
		tput cup 13 "$c1"; echo "C) Upload Scripts"
		tput cup 14 "$c1"; echo "A) Login to LFS User"
		tput cup 16 "$c1"; echo "B) Back"
		tput cup 17 "$c1"; echo "Q) Quit"
		tput cup 19 "$c1"; read -n 1 -p ": " choice
		case $choice in
			v|V)
				title_header
				version_check
				manual_install_menu
				;;
			r|R)
				title_header
				partitions_setup "drive_list"
				manual_install_menu
				;;
			d|D)
				title_header
				partitions_setup "full_drive_list"
				pause
				manual_install_menu
				;;
			p|P)
				title_header
				partitions_setup "create_lfs_partitions"
				manual_install_menu
				;;
			f|F)
				title_header
				partitions_setup "format_lfs_partitions"
				pause
				manual_install_menu
				;;
			m|M)
				title_header
				partitions_setup "mount_lfs_partition"
				manual_install_menu
				;;
			u|U)
				title_header
				partitions_setup "unmount_lfs_partition"
				manual_install_menu
				;;
			s|S)
				title_header
				packages_setup "create_sources_directory"
				packages_setup "download_package_sources"
				packages_setup "check_package_sources"
				packages_setup "create_tools_directory"
				pause
				manual_install_menu
				;;
			o|O)
				title_header
				pause
				manual_install_menu
				;;
			l|L)
				title_header
				packages_setup "add_lfs_user"
				pause
				manual_install_menu
				;;
			c|C)
				title_header
				packages_setup "upload_scripts"
				pause
				manual_install_menu
				;;
			a|A)
				title_header
				packages_setup "login_lfs_user"
				manual_install_menu
				;;
			b|B)
				main_menu
				;;
			q|Q)
				clear; exit 0
				;;
			*)
				echo -e " ${RED}**Invalid option**${STD}" && sleep 0.3 && manual_install_menu
		esac
	}
	
	settings_menu() {
		local choice
		
		change_lfs_url() {
			local choice
			local new_url
			
			new_book_url() {
				local search="lfs_location"
				local replace="test"
				sed 's/^$search.*//g; /^$/d' $config_file
				pause
			}
			
			title_header
			# Options
			tput cup 4 "$c1"; echo "D) Default"
			tput cup 5 "$c1"; echo "Current: $lfs_book_site"
			tput cup 7 "$c1"; echo "B) Back"
			tput cup 8 "$c1"; echo "Q) Quit"
			tput cup 10 "$c1"; read -p ": " choice
			case $choice in
				d|D)
					defaultBookUrl
					;;
				b|B)
					settings_menu
					;;
				q|Q)
					clear; exit 0
					;;
				*)
					new_url=$choice && new_book_url && settings_menu
			esac
		}
		
		title_header
		# Status
		tput cup 4 40; echo "Current: $lfs_book_site"
		tput cup 5 40; echo "Current: $LFS"
		tput cup 6 40; echo "Current: $lfs_owncloud"
		# Menu
		tput cup 4 "$c1"; echo "1) Change LFS URL Download Site"
		tput cup 5 "$c1"; echo "2) Change Default LFS Directory"
		tput cup 6 "$c1"; echo "3) Change ownCloud Directory"
		tput cup 8 "$c1"; echo "L) Log Files"
		tput cup 9 "$c1"; echo "N) New Config File"
		tput cup 11 "$c1"; echo "B) Back"
		tput cup 12 "$c1"; echo "Q) Quit"
		tput cup 14 "$c1"; read -n 1 -p ": " choice
		case $choice in
			1)
				change_lfs_url
				settings_menu
				;;
			2)
				title_header
				echo "Default"
				pause
				settings_menu
				;;
			l|L)
				title_header
				echo "Logs (None)"
				pause
				settings_menu
				;;
			n|N)
				title_header
				config_file_option "new_file"
				settings_menu
				;;
			b|B)
				main_menu
				;;
			q|Q)
				clear; exit 0
				;;
			*)
				echo -e " ${RED}**Invalid option**${STD}" && sleep 0.3 && settings_menu
		esac
	}
	
	network_status "$lfs_book_site"
	
	local choice
	title_header
	# Status
	tput cup 4 "$c2"; echo "--Status--"
	tput cup 5 "$c2"; echo "User:"			; tput cup 5 "$c3"; echo "$user_status"
	tput cup 6 "$c2"; echo "Connection:"	; tput cup 6 "$c3"; echo "$connection_status"
	tput cup 7 "$c2"; echo "Builder:"		; tput cup 7 "$c3"; echo "Ready?"
	# Menu
	tput cup 4 "$c1"; echo -e "${BOLD}A) Auto Setup${STD}"
	tput cup 5 "$c1"; echo "M) Manual Setup"
	tput cup 6 "$c1"; echo "C) Login to LFS User"
	tput cup 7 "$c1"; echo "S) Settings"
	tput cup 9 "$c1"; echo "Q) Quit"
	tput cup 11 "$c1"; read -n 1 -p ": " choice
	case $choice in
		a|A)
			main_menu
			;;
		m|M)
			manual_install_menu
			;;
		c|C)
			title_header
			packages_setup "login_lfs_user"
			main_menu
			;;
		s|S)
			settings_menu
			;;
		q|Q)
			clear; exit 0
			;;
		*)
			echo -e "${RED}**Invalid option**${STD}" && sleep 0.3 && main_menu
	esac
	
	wait
}

startup_check
main_menu
