#!/bin/bash
# Filename:		upload-to-builder.sh
# Title:		LFS Builder Script Uploader
# Author: 		TerryJohn M. Anscombe

# Status:		Building Stage
# Created:		10/14/18
# Version:		0.0.1.001
# Long:			
# Notes:		Uploader for LFS Builder Script to Host Machine
# Links:		

# Error codes for abnormal exit.
ROOT_UID=0																		# Only users with $UID 0 have root privileges.
E_NOTROOT=87																	# Non-root exit error.
E_USAGE=67																		# Usage message, then quit.
E_NO_OPTS=68																	# No command-line args entered.
E_NO_URLS=69																	# No URLs passed to script.
E_NO_SAVEFILE=70																# No save filename passed to script.
E_USER_EXIT=71																	# User decides to quit.
# Device settings
log_file="upload.log"
config_file="config.cfg"														# Config File
vm_name="LFS"																	# Test VM Name
device_username="tj"															# Username
device_password="tester"														# Password
device_ip_address="192.168.0.144"												# IP address
device_ssh_port="60022"															# SSH port
device_ssh_key="/home/tj/.ssh/vm_lfs"											# SSH key file
device_ssh_password="tester"													# SSH password
device_site_storage="/dev/root"													# 
device_backup="/home/"$device_username"/backup/"								# 
command_arg="$1"																# 
# Theme
top_title="Upload to Builder"
build_version="0.0.1.002"
# Define the options available.
save=s																			# Save command instead of executing it.
cook=c																			# Change cookie file for this session.
help=h																			# Usage guide.
list=l																			# Pass wget the -i option and URL list.
runn=r																			# Run saved commands as an argument to the option.
inpu=i																			# Run saved commands interactively.
wopt=w																			# Allow to enter options to pass directly to wget.

	startup_check() {															# Startup Setup
		clear 
		if [ "$UID" -ne "$ROOT_UID" ]; then										# Check if running as root
			root_status="non-root"
		else
			root_status="root-user"
		fi
		
		if [ "$command_arg" == "--help" ] || [ "$command_arg" == "-h" ]; then	# Display help menu and exit
			printf "%s\n" "$top_title"
			printf "%s\n" "Version: "$build_version""
			printf "%s\n" ""
			printf "%s\n" "Help Options:"
			printf "%s\n" "  -h, --help             Help menu"
			printf "%s\n" ""
			printf "%s\n" "  -t, --skip-boot        Skip first startup test"
			printf "%s\n" "  -s, --disable-ssh      Disable using ssh keys"
			printf "%s\n" ""
			exit 0
		fi
		
		if [ "$command_arg" == "--disable-ssh" ] || [ "$command_arg" == "-s" ]; then
			ssh_disabled="1"
		else
			ssh_disabled="0"
		fi
		
			host_status_refresh_disabled="0"
	}
	
	vm_setup() {
		list_vm() {
			# List virtual machines
#			vm_list=$(VBoxManage list vms)
			
			# List running VM
#			vm_running_list=$(VBoxManage list runningvms)
			
			# List state
			vm_state=$(vboxmanage showvminfo "$vm_name" | grep "State:" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | cut -d'(' -f1)
			if [ "$vm_state" == "running" ]; then
				vm_run_status="1"
			else
				vm_run_status="0"
			fi
		}
		
		start_vm() {
			list_vm
			if [ "$vm_run_status" == "0" ]; then
				if [ "$vm_state" == "saved" ]; then
					# Start VM in headless mode
					VBoxManage startvm "$vm_name" --type headless
				fi
				
				if [ "$vm_state" == "paused" ]; then
					# Resume VM
					VBoxManage controlvm "$vm_name" resume --type headless
				fi
				
				# Reset VM
#				VBoxManage controlvm "$vm_name" reset				
			else
				printf "%s\n" "Device is already started"
				sleep 1
			fi
		}
		
		stop_vm() {
			list_vm
			if [ "$vm_run_status" == "1" ]; then
				if [ "$1" == "pause" ]; then
					# Pause VM
					VBoxManage controlvm "$vm_name" pause --type headless
				elif [ "$1" == "save" ]; then
					# Save state and stop VM
					VBoxManage controlvm "$vm_name" savestate
				elif [ "$1" == "stop" ]; then
					# Power off VM
					VBoxManage controlvm "$vm_name" poweroff --type headless
				fi
			else
				printf "%s\n" "Device is not running"
				sleep 1
			fi
		}
		
		if [ "$1" == "vm-status" ]; then
			list_vm
		elif [ "$1" == "start" ]; then
			start_vm
		elif [ "$1" == "pause" ]; then
			stop_vm "pause"
		elif [ "$1" == "save" ]; then
			stop_vm "save"
		elif [ "$1" == "stop" ]; then
			stop_vm "poweroff"
		fi
	}
	
	log_setup() {																# Logging Setup
		local time_stamp_day=$(date +%y-%m-%d)
		local time_stamp_time=$(date +%H:%M:%S)
		
		log_clean() {
			if [ -f "$log_file" ]; then
				rm						\
					--verbose			\
					"$log_file"
			fi
			
			touch "$log_file"
			
			echo -e "================================================================================" >> "$log_file"
			echo -e "$top_title" >> "$log_file"
			echo -e "Build Version "$build_version"" >> "$log_file"
			echo -e "================================================================================" >> "$log_file"
		}
		
		if [ "$1" == "clear" ]; then
			log_clean
		elif [ "$1" == "ERROR" ]; then
			echo -e "================================================================================" >> "$log_file"
			echo -e "[["$time_stamp_day" "$time_stamp_time"]:["$1"]] "$2"" >> "$log_file"
			echo -e "================================================================================" >> "$log_file"
		elif [ "$1" == "INFO" ]; then
			echo -e "[["$time_stamp_day" "$time_stamp_time"]:["$1"]] "$2"" >> "$log_file"
		else
			echo "" >> "$log_file"
			echo "$1" >> "$log_file"
			echo "" >> "$log_file"
		fi
	}
	
	ping_site() {																# Connection Check
		# Ping IP address to check if online/offline
		local ping_timeout="1"													# Ping timeout
		local ping_count="1"													# Ping how many times
		
		printf "%s" "Checking connection $device_ip_address..."
		ping_site=$(ping -c "$ping_count" -w "$ping_timeout" "$device_ip_address")	# Get ping status
		ping_site=$(echo "$ping_site" | grep "packet loss" | cut -d' ' -f6 | cut -d'%' -f1 | cut -d'+' -f1)
		
		if [ "$ping_site" == "0" ]; then										# Device is online
			connection_status=$(echo -e "${GREEN}Online${STD}")
			device_connection_status="online"
			printf "%s\n" " $connection_status"
		else																	# Device is offline
			connection_status=$(echo -e "${RED}Offline${STD}")
			device_connection_status="offline"
			printf "%s\n" " $connection_status"
		fi
	}
	
	ssh_setup() {
		if [ "$ssh_disabled" == "0" ]; then
			if [ -f "$device_ssh_key" ]; then
				check_ssh_agent_status_list() {
					ssh_agent_status=$(ssh-add -l)
				} >> "$log_file" 2>&1
				
				check_ssh_agent_status() {
					if [ -z "$ssh_agent_status" ]; then
						printf "%s\n" "Starting SSH..."
						eval $(ssh-agent -s)									# Create the process
						ssh_setup
					fi
				} >> "$log_file" 2>&1
				
				check_ssh_identities() {
					ssh_agent_no_id="The agent has no identities."
					if [ "$ssh_agent_status" == "$ssh_agent_no_id" ]; then
						printf "%s\n" "Adding Web Server SSH Key..."
						$(echo "$device_ssh_password" | ssh-add "$device_ssh_key")
						ssh_setup
					fi
				} >> "$log_file" 2>&1
				
				check_ssh_key() {
					current_ssh_key=$(echo "$ssh_agent_status" | cut -d' ' -f3 | grep "$server_ssh_key")
					if [ "$current_ssh_key" == "$device_ssh_key" ]; then
						printf "%s\n" "Refreshing... "$current_ssh_key""
						sleep 1
					else
						printf "%s\n" "Not Connected"
						sleep 1
					fi
				} &>/dev/null
				
				printf "%s" "Checking SSH Agent Status List..."
				check_ssh_agent_status_list
				printf "%s\n" " Done"
				
				printf "%s" "Checking SSH Agent Status..."
				check_ssh_agent_status
				printf "%s\n" " Done"
				
				printf "%s" "Checking SSH Identities..."
				check_ssh_identities
				printf "%s\n" " Done"
				
				printf "%s" "Checking SSH Key..."
				check_ssh_key
				printf "%s\n" " Done"
			else
				printf "%s\n" "No SSH Key File Found"
			fi
		fi
	}
	
	ssh_command() {																# SSH to device
		if [ "$device_connection_status" == "online" ]; then
			if [ -f "$device_ssh_key" ]; then
				if [ "$ssh_disabled" == "0" ]; then
					ssh -t "$device_username"@"$device_ip_address" -p "$device_ssh_port" -i "$device_ssh_key" "$1"
				elif [ "$ssh_disabled" == "1" ]; then
					ssh -t "$device_username"@"$device_ip_address" -p "$device_ssh_port" "$1"
				fi
			fi
		else
			print "%s\n" "Offline"
			sleep 3
		fi
	}
	
	scp_command() {																# Copy or send file over scp
		if [ "$1" == "upload" ]; then
			# Copy file(s) to device
			$(scp -P "$device_ssh_port" "$2" "$device_username"@"$device_ip_address":"/home/"$device_username"/")
		elif [ "$1" == "download" ]; then
			# Copy file(s) from device
			$(scp -P "$device_ssh_port" "$device_username"@"$device_ip_address":"/home/"$device_username"/"$2"" ".")
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
	
	check_device_status() {
		check_server_for_info() {
			# Check System Information
			printf "%s" "Checking System Information... "
			system_info=$(ssh_command "uname -a")
#			printf "%s\n" "$system_info"
			printf "%s\n" "Done"
			
			# Check Kernel Version
			printf "%s" "Checking Kernel Version... "
			kernel_version=$(ssh_command "uname -or")		
			printf "%s\n" "$kernel_version"
#			printf "%s\n" "Done"
			
			# Check System Uptime
			printf "%s" "Checking Server Uptime... "
			server_info_uptime=$(ssh_command "uptime -p | cut -d' ' -f2-")
			printf "%s\n" "$server_info_uptime"
#			printf "%s\n" "Done"
			
			# Processes and Other system information
			printf "%s" "Checking Processes and Other System Information... "
			processes_info=$(cat /proc/version)
#			printf "%s\n" "$processes_info"
			printf "%s\n" "Done"
			
			# Check Servers Info
			printf "%s" "Checking Server Info... "
			server_info=$(ssh_command "hostnamectl")
			
			server_info_cut() {
				echo "$server_info" | grep "$1" | cut -d':' -f2- | cut -d' ' -f2-
			}
#			printf "%s\n" ""
#			printf "%s\n" ""
			server_info_hostname=$(server_info_cut "Static hostname")
#			printf "%s\n" "Hostname: $server_info_hostname"
			server_info_icon_name=$(server_info_cut "Icon name")
#			printf "%s\n" "Icon: $server_info_icon_name"
			server_info_chassis=$(server_info_cut "Chassis")
#			printf "%s\n" "Chassis: $server_info_chassis"
			server_info_machine_id=$(server_info_cut "Machine ID")
#			printf "%s\n" "Machine: $server_info_machine_id"
			server_info_boot_id=$(server_info_cut "Boot ID")
#			printf "%s\n" "Boot: $server_info_boot_id"
			server_info_os=$(server_info_cut "Operating System")
#			printf "%s\n" "OS: $server_info_os"
			server_info_kernel=$(server_info_cut "Kernel")
#			printf "%s\n" "Kernel: $server_info_kernel"
			server_info_arch=$(server_info_cut "Architecture")
#			printf "%s\n" "Arch: $server_info_arch"
#			printf "%s\n" ""
			printf "%s\n" "Done"
			
			server_info_os_trim=$(echo "$server_info_os" | cut -d' ' -f1)
#			printf "%s\n" "OS: $server_info_os_trim"
			
			# Find Distribution Name and Release Version
#			$(ssh_command "cat /etc/redhat-release")
#			$(ssh_command "cat /etc/centos-release")
#			$(ssh_command "cat /etc/fedora-release")
#			$(ssh_command "cat /etc/debian-release")
#			$(ssh_command "cat /etc/lsb-release")
#			$(ssh_command "cat /etc/gentoo-release")
#			$(ssh_command "cat /etc/SuSE-release")
		}
		
		check_server_disk_size() {
			# Check Disk Space
			printf "%s" "Checking Disk Space..."
			server_disk_space=$(ssh_command "df -h")
			
			server_disk_space_cut() {
				echo "$server_disk_space" | grep "$server_site_storage" | cut -d' ' -f"$1"
			}
			
			server_disk_size=$(server_disk_space_cut 9)							# Size
			server_disk_used=$(server_disk_space_cut 11)						# Used
			server_disk_avail=$(server_disk_space_cut 14)						# Avail
			server_disk_percent=$(server_disk_space_cut 16)						# Use%
			printf "%s\n" " Done"
		}
		
		check_server_cpu_info() {
			printf "%s" "Checking CPU Status... "
			cpu_info=$(ssh_command "lscpu")
			
			cpu_info_trim() {
				echo "$cpu_info" | grep "$1" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
			}
			
#			echo "$cpu_info"
			
			cpu_arch=$(cpu_info_trim "Architecture:")
			cpu_byte=$(cpu_info_trim "Byte Order:")
			cpu_cores=$(cpu_info_trim "CPU(s):")
			cpu_model=$(cpu_info_trim "Model name:")
			cpu_mhz=$(cpu_info_trim "CPU MHz:")
			cpu_min=$(cpu_info_trim "CPU min MHz:")
			cpu_max=$(cpu_info_trim "CPU max MHz:")
#			printf "%s\n" "$cpu_byte $cpu_model with $cpu_cores core(s) on $cpu_arch"
#			printf "%s\n" "MHz:$cpu_mhz (Min-Max) $cpu_min-$cpu_max"
			printf "%s\n" "Done"
		}
		
		ssh_setup
		
	}
	
	backup_site() {
		$(tar -zcvf "site-backup-$(date '+%Y-%m-%d').tar.gz" "$device_backup")
	}
	
	backup_list() {
		list_status=$(ssh_command '
			if [ -d "$device_backup" ]; then
				echo "Found it!"
			else
				echo "Its not here!"
				mkdir "$device_backup"
			fi
		')
		echo $list_status
#		local does_not_exist
#		list_status=$(ssh_command "ls -la "$device_backup"")
#		does_not_exist="No such file or directory"
#		list_status=$(echo "$list_status" | grep "$does_not_exist" | cut -d' ' -f5-)
#		echo "$does_not_exist"
#		echo "$list_status"
#		if [ "$list_status" == "$does_not_exist" ]; then
#			echo "Make Directory"
#			$(ssh_command "mkdir "$device_backup"")
#		else
#			echo "Should not see me yet!"
#		fi
#		if [ -d "$device_backup" ]; then
#			$(`ls` -la "$device_backup")
#		else
#			$(mkdir "$device_backup")
#		fi
	}
	
	copy_site_to_device() {
		scp_command "upload" "lfs_builder.sh"
	}
	
	check_device_updates() {
		echo "Checking for Updates... "
		device_update_status=$(ssh_command "sudo -u "$device_username" apt update")
		echo "$device_update_status"
#		ssh_command "sudo apt-get list --upgradable"

#		test=$(sudo apt update)
#		echo "-1------"
#		echo $test
#		echo "-2------"
#		echo "$test" | grep "upgradable"
#		echo "-3------"
#		echo "$test"
	}
	
	device_processes() {	
		ssh_command ""$1" -d 0.1"
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
		local choice
		
		title_header() {														# Title Header
			RED='\033[0;41;30m'													# Red Text Color
			GREEN='\033[0;42;30m'												# Green Text Color
			YELLOW='\033[0;43;30m'												# Yellow Text Color
			STD='\033[0;0;39m'													# Standard Text Color
			BOLD='\e[1m'														# Bold Text
			BLINK='\e[5m'														# Blinking Text?
			DIM='\e[2m'															# Dim Text
			local line1 line2 line3 current_header_status
			line1="o342"
			line2="o226"
			line3="o200"
			max_width=$(tput cols)												# Screen Width
			line=$(printf "%*s\\n" "${COLUMNS:-$max_width}" '' | sed 's/ /\'$line1'\'$line2'\'$line3'/g')
			main_title="$top_title $build_version"								# Main Title
			title_width=$(echo -n "$main_title" | wc -c)						# Title Width
			((title_position = max_width / 2 - (title_width / 2)))				# Center Title Alignment
			clear																# Clear screen
			tput clear															# Title Header Layout
			tput cup 0 0				; printf "%s" "$line"					# Display line
			tput cup 1 $title_position	; echo -e "${BOLD}$main_title${STD}"	# Display title and version
			tput cup 2 0				; printf "%s" "$line"					# Display line
		}
		pause_menu() {															# Pause Option
			read -p "Press [Enter] key to continue..." fackEnterKey
		}
		yes_or_no() {															# Yes or No Option
			# Options:
			#	$1 = Quit to
			#	$2 = Question
			#	$3 = Default answer
			while true; do
				read -p "$2 " -i "$3" -e yn
				case $yn in
					[Yy]* )
						answer_is="yes"
						break
					;;
					[Nn]* )
						answer_is="no"
						break
					;;
					[Qq]* )
						"$1"
					;;
					* )
						echo "(y)es/(n)o/(q)uit "
					;;
				esac
			done
		}
		menu_line() {															# Menu Row and Column
			# Column Alignment
			c1=1																# Menu Column
			c2=34			#35													# Status Column Left
			c3=47			#50													# Status Column Right
			c4=70			#75													# Info Column Left
			c5=83			#90													# Info Column Right
						
			next_row() {														# Dont know right now but it works
				rstart=3
				rnew=0
				rstep=1
				if [ "$1" == "first" ]; then
					r1=$(( "$rstart" + "$rnew" ))
				else
					r1=$(( "$r1" + "$rstep" ))
				fi
			}
			
			next_line() {														# Dont know right now but it works
				lstart=1
				lnew=0
				lstep=1
				if [ "$1" == "first" ]; then
					l1=$(( "$lstart" + "$lnew" ))
				else
					l1=$(( "$l1" + "$lstep" ))
				fi			
			}
			
			if [ "$1" == "skip_line" ]; then									# Skip Line
				next_row
			elif [ "$1" == "new_line" ]; then									# Start new line at top
				next_row "first"
				next_line "first"
			else
				if [ "$1" == "option" ]; then									# Menu option line column setup
					tput cup "$r1" "$c1";	echo "$2";	next_row
				elif [ "$1" == "status_line" ]; then							# Status line column setup
					tput cup "$r1" "$c2";	printf "%s\n" "$2";	tput cup "$r1" "$c3";	printf "%s\n" "$3";	next_row
				elif [ "$1" == "machine_line" ]; then							# Machine info line column setup
					tput cup "$r1" "$c4";	printf "%s\n" "$2";	tput cup "$r1" "$c5";	printf "%s\n" "$3";	next_row
				fi
			fi
		}
		
		vm_settings() {
			local choice
			vm_setup "vm-status"
			
			title_header
			
			# Status
			menu_line "new_line"
			menu_line "status_line" "$(echo -e "${BOLD}-- Status --${STD}")"
			menu_line "status_line" "Status:" "$vm_state"
#			menu_line "status_line" "" ""
			
			# Menu
			menu_line "new_line"
			menu_line "option" "$(echo -e "${BOLD}-- Virtual Machine Settings --${STD}")"
			menu_line "option" "S) Start"
			menu_line "option" "P) Pause"
			menu_line "option" "A) Save"
			menu_line "option" "T) Stop"
#			menu_line "option" ""
			
			menu_line "skip_line"
			menu_line "option" "B) Back"
			menu_line "option" "Q) Quit"
			menu_line "skip_line"
			tput cup "$r1" "$c1"; read -n 1 -p ": " choice
			case $choice in
			s|S)
				title_header
				vm_setup "start"
				vm_settings
				;;
			p|P)
				title_header
				vm_setup "pause"
				vm_settings
				;;
			a|A)
				title_header
				vm_setup "save"
				vm_settings
				;;
			t|T)
				title_header
				vm_setup "stop"
				vm_settings
				;;
			b|B)
				title_header
				main_menu
				;;
			q|Q)
				quit_program
				;;
			*)
				echo -e "${RED}**Invalid option**${STD}"
				sleep 0.3
				vm_settings
				;;
		esac
		
		wait
		}
		
		# For Debugging
		if [ "$command_arg" == "--skip-refresh" ] || [ "$command_arg" == "-r" ]; then	# User asked to skip device check
			printf "%s\n" "Skipping startup test... Done"
		else
			title_header
			ping_site
		fi
		
		title_header
		
		# Status
		menu_line "new_line"
		menu_line "status_line" "$(echo -e "${BOLD}-- Status --${STD}")"
		menu_line "status_line" "Device:" ""$device_ip_address" "$connection_status""
		menu_line "status_line" "Storage:" "$device_space"
		menu_line "status_line" "Last Backup:" " "
#		menu_line "status_line" "" ""
		
		# Machine Type
		menu_line "new_line"
		menu_line "machine_line" "$(echo -e "${BOLD}-- Info --${STD}")"
		menu_line "machine_line" "Hostname:" "$device_info_hostname"
		menu_line "machine_line" "Type" "$device_info_icon_name"
		menu_line "machine_line" "Chassis:" "$device_info_chassis"
		menu_line "machine_line" "Machine ID:" "$device_info_machine_id"
		menu_line "machine_line" "Boot ID:" "$device_info_boot_id"
		menu_line "machine_line" "OS:" "$device_info_os"
		menu_line "machine_line" "Kernel:" "$device_info_kernel"
		menu_line "machine_line" "Architecture:" "$device_info_arch"
#		menu_line "machine_line" "" ""
		
		# Menu
		menu_line "new_line"
		menu_line "option" "$(echo -e "${BOLD}A) Auto Update${STD}")"
		menu_line "option" "R) Refresh Status"
		menu_line "option" "V) Virtual Machine Settings"
#		menu_line "option" "Z) Backup Host"
#		menu_line "option" "L) Backup List"
#		menu_line "option" "U) Upload Scripts to Device"
#		menu_line "option" "1) Check for Updates on Device"
		menu_line "option" "T) Process Viewer (top)"
		menu_line "option" "H) Process Viewer (htop)"
		menu_line "option" "C) Connect over SSH"
#		menu_line "option" ""
		
		menu_line "skip_line"
#		menu_line "option" "S) Settings"
		menu_line "option" "Q) Quit"
		menu_line "skip_line"
		tput cup "$r1" "$c1"; read -n 1 -p ": " choice
		case $choice in
			a|A)
				title_header
				main_menu
				;;
			r|R)
				title_header
				check_device_status "refresh_device_status"
				main_menu
				;;
			v|V)
				title_header
				vm_settings
				main_menu
				;;
			z|Z)
				title_header
				backup_site
				main_menu
				;;
			l|L)
				title_header
				backup_list
				pause_menu
				main_menu
				;;
			u|U)
				title_header
				copy_site_to_device
				main_menu
				;;
			1)
				title_header
				check_device_updates
				pause_menu
				main_menu
				;;
			t|T)
				title_header
				device_processes "top"
				main_menu
				;;
			h|H)
				title_header
				device_processes "htop"
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
log_setup "clear"
# For Debugging
if [ "$command_arg" == "--skip-refresh" ] || [ "$command_arg" == "-r" ]; then	# User asked to skip device check
	clear
	printf "%s\n" "Skipping startup test... Done"
else
	clear
	ping_site
	check_device_status													# Check device status
fi
main_menu

exit 0
