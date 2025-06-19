#!/bin/bash
# Filename:	uploader.sh
# Title:	LFS Builder Script Uploader
# Author: 	TerryJohn M. Anscombe
# Note:		Uploader for LFS Builder Script to Host Machine
#  Arguments:
#    -s, disable_ssh				Disable using ssh keys
#    -r, disable_refresh			Disable refresh of host status
#    -b, disable_ssh_and_refresh	Disable Both

# Error codes for abnormal exit.
ROOT_UID=0																		# Only users with $UID 0 have root privileges.
E_NOTROOT=87																	# Non-root exit error.
E_USAGE=67																		# Usage message, then quit.
E_NO_OPTS=68																	# No command-line args entered.
E_NO_URLS=69																	# No URLs passed to script.
E_NO_SAVEFILE=70																# No save filename passed to script.
E_USER_EXIT=71																	# User decides to quit.
# Server settings
config_file="config.cfg"														# Config File
server_username="tj"															# Username
server_password=""																# Password
server_ip_address="192.168.0.70"												# IP address
server_ssh_port="22"															# SSH port
server_ssh_key=""																# SSH key file
server_ssh_password=""															# SSH password
server_site_storage="/dev/root"													# 
server_backup="/home/"$server_username"/backup/"								# 
command_arg="$1"																# 
# Theme
top_title="Uploader"
build_version="0.0.1.001"
RED='\033[0;41;30m'
GREEN='\033[0;42;30m'
YELLOW='\033[0;43;30m'
STD='\033[0;0;39m'
BOLD='\e[1m'
BLINK='\e[5m'
DIM='\e[2m'
# Define the options available.
save=s																			# Save command instead of executing it.
cook=c																			# Change cookie file for this session.
help=h																			# Usage guide.
list=l																			# Pass wget the -i option and URL list.
runn=r																			# Run saved commands as an argument to the option.
inpu=i																			# Run saved commands interactively.
wopt=w																			# Allow to enter options to pass directly to wget.


	startup_check() {
		clear 
		if [ "$UID" -ne "$ROOT_UID" ]; then										# Check if running as root
			root_status="non-root"
		else
			root_status="root-user"
		fi
		
		if [ "$command_arg" == "disable_ssh" ]; then
			ssh_disabled="1"
		else
			ssh_disabled="0"
		fi
		
		if [ "$command_arg" == "disable_ssh_and_refresh" ]; then
			ssh_disabled="1"
			host_status_refresh_disabled="1"
		else
			ssh_disabled="0"
			host_status_refresh_disabled="0"
		fi
		
		if [ "$command_arg" == "disable_refresh" ]; then
			host_status_refresh_disabled="1"
		else
			host_status_refresh_disabled="0"
		fi
	}
		
	ping_site() {																# Connection Check
		local ping_the_site
		ping_the_site=$(ping -c 1 "$server_ip_address" | grep "packet loss" | cut -d' ' -f6 | cut -d'%' -f1 | cut -d'+' -f1)
		if [ "$ping_the_site" == "0" ]; then
			connection_status=$(echo -e "${GREEN}Online${STD}")
			server_status="online"
		else
			connection_status=$(echo -e "${RED}Offline${STD}")
			server_status="offline"
		fi
	}
	
	ssh_command() {																# SSH to server
		if [ "$ssh_disabled" == "0" ]; then
			ssh -t "$server_username"@"$server_ip_address" -p "$server_ssh_port" -i "$server_ssh_key" "$1"
		elif [ "$ssh_disabled" == "1" ]; then
			ssh -t "$server_username"@"$server_ip_address" -p "$server_ssh_port" "$1"
		fi
	}
	
	scp_command() {																# Copy or send file over scp
		if [ "$1" == "upload" ]; then
			# Copy file(s) to server
			$(scp -P "$server_ssh_port" "$2" "$server_username"@"$server_ip_address":"/home/"$server_username"/")
		elif [ "$1" == "download" ]; then
			# Copy file(s) from server
			$(scp -P "$server_ssh_port" "$server_username"@"$server_ip_address":"/home/"$server_username"/"$2"" ".")
		fi
	}
	
	rsync_command() {
		echo "Nothing Yet"
		# Copy/Sync a File on a Local Computer
		$(rsync -zvh example.tar /tmp/backups/)
		
		# Copy/Sync a Directory on Local Computer
		$(rsync -avzh /root/rpmpkgs /tmp/backups)
		
		# Copy a Directory from Local Server to a Remote Server
		$(rsync -avz rpmpkgs/ root@192.168.0.101:/home/)
		
		# Copy/Sync a Remote Directory to a Local Machine
		$(rsync -avzh root@192.168.0.100:/home/user/rpmpkgs /tmp/myrpms)
		
		# Copy a File from a Remote Server to a Local Server with SSH
		$(rsync -avzhe ssh root@192.168.0.100:/root/install.log /tmp/)
		
		# Copy a File from a Local Server to a Remote Server with SSH
		$(rsync -avzhe ssh backup.tar root@192.168.0.100:/backups/)
		
		# Show Progress While Transferring Data with rsync
		$(rsync -avzhe ssh -progress /home/rpmpkgs root@192.168.0.100:/root/rpmpkgs)
		
		# Use of -include and -exclude Options
		$(rsync -avze ssh --include 'R*' --exclude '*' root@192.168.0.101:/var/lib/rpm/ /root/rpm)
		
		# Use of -delete Option
		$(touch test.txt)
		$(rsync -avz --delete root@192.168.0.100:/var/lib/rpm/ .)
		
		# Set the Max Size of Files to be Transferred
		$(rsync -avzhe ssh --max-size='200k' /var/lib/rpm/ root@192.168.0.100:/root/tmprpm)
		
		# Automatically Delete source Files afte successful Transfer
		$(rsync --remove-source-files -zvh backup.tar /tmp/backups/backup.tar)
		
		# Do a Dry Run with rsync
		$(rsync --dry-run --remove-source-files -zvh backup.tar /tmp/backups/backup.tar)
		
		# Set Bandwidth Limit and Transfer File
		$(rsync --bwlimit=100 -avzhe ssh  /var/lib/rpm/  root@192.168.0.100:/root/tmprpm/)
		
		$(rsync -zvhW backup.tar /tmp/backups/backup.tar)
		
		
		# Syncing Files Locally Using Rsync
		$(rsync -av Documents/* /tmp/documents)
		
		# Test run to see what files will be copied
		$(rsync -aunv Documents/* /tmp/documents)
		
		# Skip files that are still new in the destination directory
		$(rsync -auv Documents/* /tmp/documents)
		
		# Syncing files from local to remote
		$(rsync -av --ignore-existing Documents/* root@192.168.0.101:~/all/)
		
		# Sync only updated or modified files on the reote machine that have changed on the local machine
		$(rsync -av --dry-run --update Documents/* root@192.168.0.101:~/all/)
		$(rsync -av --update Documents/* root@192.168.0.101:~/all/)
	}
	
	md5_checksum() {
		# Generate Hash Value
		$(md5sum "test.file")
		
		# Redirect generated hash values into text file
		$(md5sum "test1.file test2.file test3.file > test-files.md5")
		
		# Check MD5
		$(md5sum -c "test-files.md5")
		
		# String Example
		$(echo -n "Test 123" | md5sum -)
		$(echo -n "Test 456" | md5sum -)
		$(echo -n "Test 120" | md5sum -)
		$(echo -n "Test 012" | md5sum -)
		$(echo -n "Test 12" | md5sum -)
		
	}
	
	check_server_status() {
		if [ "$ssh_disabled" == "0" ]; then
			check_ssh_agent_status() {
				ssh_agent_status=$(ssh-add -l)
			} &>/dev/null
			
			check_ssh_agent_status
			if [ -z "$ssh_agent_status" ]; then
				printf "Starting SSH "
				eval $(ssh-agent -s)													# Create the process
			fi
			
			check_ssh_agent_status
			ssh_agent_no_id="The agent has no identities."
			if [ "$ssh_agent_status" == "$ssh_agent_no_id" ]; then
				echo "Adding Web Server SSH Key"
				$(ssh-add "$server_ssh_key") &>/dev/null
			fi
			
			check_ssh_agent_status
			current_ssh_key=$(echo "$ssh_agent_status" | cut -d' ' -f3 | grep "$server_ssh_key")
			if [ "$current_ssh_key" == "$server_ssh_key" ]; then
				echo "Refreshing... ""$current_ssh_key"
			else
				echo "Not Connected"
				sleep 1
			fi
		fi
		
		if [ "$host_status_refresh_disabled" == "1" ]; then
			# Check System Information
			system_info=$(ssh_command "uname -a")
			
			# Check Kernel Version
			kernel_version=$(ssh_command "uname -or")		
			
			# Processes and Other system information
			processes_info=$(cat /proc/version)
			
			# Check Disk Space
			server_disk_space=$(ssh_command "df -h")
			
			server_disk_space_cut() {
				echo "$server_disk_space" | grep "$server_site_storage" | cut -d' ' -f"$1"
			}
			server_disk_size=$(server_disk_space_cut 9)									# Size
			server_disk_used=$(server_disk_space_cut 11)								# Used
			server_disk_avail=$(server_disk_space_cut 13)								# Avail
			server_disk_percent=$(server_disk_space_cut 15)								# Use%
			
			server_space=$(echo "Used:"$server_disk_percent" Avail:"$server_disk_avail"")
			
			# Check Servers Info
			server_info=$(ssh_command "hostnamectl")
			
			server_info_cut() {
				echo "$server_info" | grep "$1" | cut -d':' -f2-
			}	
			server_info_hostname=$(server_info_cut "Static hostname")
			server_info_icon_name=$(server_info_cut "Icon name")
			server_info_chassis=$(server_info_cut "Chassis")
			server_info_machine_id=$(server_info_cut "Machine ID")
			server_info_boot_id=$(server_info_cut "Boot ID")
			server_info_os=$(server_info_cut "Operating System")
			server_info_kernel=$(server_info_cut "Kernel")
			server_info_arch=$(server_info_cut "Architecture")
		fi
			
		if [ "$1" == "refresh_server_status" ]; then
			main_menu
		fi
		
		# Find Distribution Name and Release Version
#		$(ssh_command "cat /etc/redhat-release")
#		$(ssh_command "cat /etc/centos-release")
#		$(ssh_command "cat /etc/fedora-release")
#		$(ssh_command "cat /etc/debian-release")
#		$(ssh_command "cat /etc/lsb-release")
#		$(ssh_command "cat /etc/gentoo-release")
#		$(ssh_command "cat /etc/SuSE-release")
	}
	
	backup_site() {
		$(tar -zcvf "site-backup-$(date '+%Y-%m-%d').tar.gz" "$server_backup")
	}
	
	backup_list() {
		list_status=$(ssh_command '
			if [ -d "$server_backup" ]; then
				echo "Found it!"
			else
				echo "Its not here!"
				mkdir "$server_backup"
			fi
		')
		echo $list_status
#		local does_not_exist
#		list_status=$(ssh_command "ls -la "$server_backup"")
#		does_not_exist="No such file or directory"
#		list_status=$(echo "$list_status" | grep "$does_not_exist" | cut -d' ' -f5-)
#		echo "$does_not_exist"
#		echo "$list_status"
#		if [ "$list_status" == "$does_not_exist" ]; then
#			echo "Make Directory"
#			$(ssh_command "mkdir "$server_backup"")
#		else
#			echo "Should not see me yet!"
#		fi
#		if [ -d "$server_backup" ]; then
#			$(`ls` -la "$server_backup")
#		else
#			$(mkdir "$server_backup")
#		fi
	}
	
	copy_site_to_server() {
		scp_command "upload" "lfs_builder.sh"
	}
	
	check_server_updates() {
		echo "Checking for Updates... "
		server_update_status=$(ssh_command "sudo -u "$server_username" apt update")
		echo "$server_update_status"
#		ssh_command "sudo apt-get list --upgradable"

#		test=$(sudo apt update)
#		echo "-1------"
#		echo $test
#		echo "-2------"
#		echo "$test" | grep "upgradable"
#		echo "-3------"
#		echo "$test"
	}
	
	server_processes() {
		ssh_command "$1" "-d 0.1"
	}
	
	quit_program() {
		clear
		if [ "$ssh_disabled" == "0" ]; then
			# Shutdown ssh agent
			echo "Killing SSH Agent"
			eval $(ssh-agent -k) &>/dev/null
		fi
		
		exit 0
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
			main_title="$top_title $build_version"									# Main Title
			title_width=$(echo -n "$main_title" | wc -c)							# Title Width
			((title_position = max_width / 2 - (title_width / 2)))					# Center Title Alignment
			clear
			tput clear																# Title Header Layout
			tput cup 0 0				; printf "%s" "$line"
			tput cup 1 $title_position	; echo -e "${BOLD}$main_title${STD}"
			tput cup 2 0				; printf "%s" "$line"
		}
	
		pause_menu() {																# Pause Option
			read -p "Press [Enter] key to continue..." fackEnterKey
			main_menu
		}
		
		title_header
		ping_site
		check_server_status
		
		local choice
		title_header
		# Status
		tput cup 3 "$c2"; echo "Server:"		; tput cup 3 "$c3"; echo ""$server_ip_address" "$connection_status""
		tput cup 4 "$c2"; echo "Storage:"		; tput cup 4 "$c3"; echo ""$server_space""
		tput cup 5 "$c2"; echo "Last Backup:"	; tput cup 5 "$c3"; echo ""
		tput cup 6 "$c2"; echo ":"				; tput cup 6 "$c3"; echo ""
		# Machine Type
		tput cup 3 "$c4"; echo "Hostname:"		; tput cup 3 "$c5"; echo "$server_info_hostname"
		tput cup 4 "$c4"; echo "Type"			; tput cup 4 "$c5"; echo "$server_info_icon_name"
		tput cup 5 "$c4"; echo "Chassis:"		; tput cup 5 "$c5"; echo "$server_info_chassis"
		tput cup 6 "$c4"; echo "Machine ID:"	; tput cup 6 "$c5"; echo "$server_info_machine_id"
		tput cup 7 "$c4"; echo "Boot ID:"		; tput cup 7 "$c5"; echo "$server_info_boot_id"
		tput cup 8 "$c4"; echo "OS:"			; tput cup 8 "$c5"; echo "$server_info_os"
		tput cup 9 "$c4"; echo "Kernel:"		; tput cup 9 "$c5"; echo "$server_info_kernel"
		tput cup 10 "$c4"; echo "Architecture:"	; tput cup 10 "$c5"; echo "$server_info_arch"
		
		# Menu
		tput cup 3 "$c1"; echo -e "${BOLD}A) Auto Update${STD}"
		tput cup 4 "$c1"; echo "R) Refresh Status"
		tput cup 5 "$c1"; echo "Z) Backup Host"
		tput cup 6 "$c1"; echo "L) Backup List"
		tput cup 7 "$c1"; echo "U) Upload Scripts to Host"
		tput cup 8 "$c1"; echo "1) Check for Updates on Host"
		tput cup 9 "$c1"; echo "T) Process Viewer (top)"
		tput cup 10 "$c1"; echo "H) Process Viewer (htop)"
		tput cup 11 "$c1"; echo "C) Connect over SSH"
		tput cup 12 "$c1"; echo "S) Settings"
		tput cup 13 "$c1"; echo "Q) Quit"
		tput cup 15 "$c1"; read -n 1 -p ": " choice
		case $choice in
			a|A)
				main_menu
				;;
			r|R)
				title_header
				check_server_status "refresh_server_status"
				main_menu
				;;
			z|Z)
				backup_site
				main_menu
				;;
			l|L)
				backup_list
				pause_menu
				main_menu
				;;
			u|U)
				title_header
				copy_site_to_server
				main_menu
				;;
			1)
				title_header
				check_server_updates
				pause_menu
				main_menu
				;;
			t|T)
				title_header
				server_processes "top"
				main_menu
				;;
			h|H)
				title_header
				server_processes "htop"
				main_menu
				;;
			c|C)
				title_header
				ssh_command
				main_menu
				;;
			s|S)
				title_header
				settings_page
				main_menu
				;;
			q|Q)
				quit_program
				;;
			*)
				echo -e "${RED}**Invalid option**${STD}"
				sleep 0.3
				main_menu
				;;
		esac
		
		wait
	}

startup_check
main_menu

exit 0
