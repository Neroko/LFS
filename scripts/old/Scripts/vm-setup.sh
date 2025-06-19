#!/bin/bash
# Filename:		debian-iso-maker.sh
# Short:		Downloads ISO images and rebuilds with preseed file and creates new ISO image
# Author:		TerryJohn M. Anscombe

# Step one:		Goto web site and check 'if online', 'current version', and 'if files exist'
# Step two: 	Download Manager
# Step three:	Preseed Setup
# Step four:	Add firmware option
# Step five:	Build new ISO image
# Step six:		Test in VM Environment

# Status:		Building Stage
# Created:		08/22/18
# Edited:		10/02/18
# Version:		0.0.1.006
# Long:			
# Notes:		So much work left to do!!

top_title="Debian ISO Maker"													# Top Title Name
build_version="0.0.1.0.005"														# Build Version
# Sites
main_download_site="https://cdimage.debian.org/debian-cd/current/"
mirror_download_site="http://mirrors.kernel.org/debian-cd/current/"
unofficial_download_site="https://cdimage.debian.org/cdimage/unofficial/non-free/cd-including-firmware/current/"
# Directorys
temp_directory=".temp/"
images_directory="iso-images/"
iso_files_directory=""$temp_directory"iso-files/"
firmware_iso_files_directory=""$temp_directory"firmware-files/"
# Logs Settings
logs_directory="$temp_directory""logs/"
log_file=""$logs_directory"debian-iso-maker.log"
# User Options
user_params="$1"

###############################
##   Startup Check           ##
###############################
	startup_check() {
		clear
		
		#####################################################
		# Add if more then one params or wrong params to exit
		#####################################################
		if [ "$user_params" == "--help" ] || [ "$user_params" == "-h" ]; then		# Display help menu and exit
			printf "%s\n" "$top_title"
			printf "%s\n" "Version: "$build_version""
			printf "%s\n" ""
			printf "%s\n" "Usage {bash debian-iso-maker.sh --(option)}"
			printf "%s\n" ""
			printf "%s\n" "Option                   Function                Note"
			printf "%s\n" "Help Options:"
			printf "%s\n" "  -h, --help             startup_check           Help menu"
#			printf "%s\n" "Auto Options:"
#			printf "%s\n" "  -u, --upload           menu                    Auto Upload Site"
			printf "%s\n" "Debugging Options:"
			printf "%s\n" "  -v, --verbose          all                     Verbose Output"
			printf "%s\n" "  -c, --clean            temp                    "
#			printf "%s\n" "  -t, --skip-boot        menu                    Skip first startup test"
#			printf "%s\n" "  -e, --boot-exit        check_server_status     Exit after startup test"
#			printf "%s\n" "  -s, --boot-sleep       check_server_status     Sleep for X seconds after startup test"
#			printf "%s\n" "  -d, --disable-config   config_setup            Disable config file being used"
			printf "%s\n" ""
			exit 0
		fi
		
		if [ -d "$temp_directory" ]; then										# If temp directory doesnt exist, make new
			rm											\
				--verbose								\
				--force									\
				--recursive								\
				"$temp_directory"
		fi
		
		mkdir											\
			--verbose									\
			"$temp_directory"
		
		if [ -d "$logs_directory" ]; then										# If temp directory doesnt exist, make new
			rm											\
				--verbose								\
				--force									\
				--recursive								\
				"$logs_directory"
		fi
		
		mkdir											\
			--verbose									\
			"$logs_directory"
		
		if [ -f "$log_file" ]; then												# If logs directory doesnt exist, make new
			rm											\
				--verbose								\
				--force									\
				"$log_file"
		fi
		
		touch "$log_file"
		
		echo "================================================================================" >> $log_file
		echo -e ""$top_title" Log" >> $log_file
		echo -e "Version: "$build_version"" >> $log_file
		echo "================================================================================" >> $log_file
		
#		screen -ls	# List all existing screen sessions
#		screen 'htop'	# Create a default session
#		screen -S "ISO Builder"	# Create a session with a name. Name can be used to reattach at a later stage
	}
	show_time () {
		num=$1
		min=0
		hour=0
		day=0
		if((num>59));then
			((sec=num%60))
			((num=num/60))
			if((num>59));then
				((min=num%60))
				((num=num/60))
				if((num>23));then
					((hour=num%24))
					((day=num/24))
				else
					((hour=num))
				fi
			else
				((min=num))
			fi
		else
			((sec=num))
		fi
#   	echo "$day"d "$hour"h "$min"m "$sec"s
		converted_time=""$day"d "$hour"h "$min"m "$sec"s"
	}

###############################
##   Program Logging Setup   ##
###############################
	log_everything() {
		local time_stamp_day=$(date +%y-%m-%d)
		local time_stamp_time=$(date +%H:%M:%S)
		# Log with timestamp breackets, Ex:  [[18/04/20 04:20:00]:[ERROR]] Something fucked up, FIX IT NOW.
		echo -e "[["$time_stamp_day "$time_stamp_time""]:["$1"]] "$2"" >> "$log_file"
	}

###############################
##   Connection Status       ##
###############################
	check_connection() {
		# Ping IP address to check if online/offline
		ping_timeout="1"														# Ping timeout
		ping_count="1"															# Ping how many times
		
		log_everything "INFO" "Checking Debian Site Status:"
		
		printf "%s" "Checking connection "$1"..."
		ping_site=$(ping -c "$ping_count" -w "$ping_timeout" "$1")				# Get ping status
		ping_site=$(echo "$ping_site" | grep "packet loss" | cut -d' ' -f6 | cut -d'%' -f1 | cut -d'+' -f1)
		
		if [ "$ping_site" == "0" ]; then										# Server is online
			site_connection_status="online"
			connection_status="Online"
			printf "%s\n" " $connection_status"
		else																	# Server is offline
			site_connection_status="offline"
			connection_status="Offline"
			printf "%s\n" " $connection_status"
		fi
	} >> "$log_file" 2>&1

###############################
##   Debian Current Version  ##
###############################
	version_check() {															# Debian Current Version Check
		# Debian Version Check
		local log_timestamp=$(date +%y-%m-%d-%H-%M-%S)							# Log Time Stamp Format
		local temp_file=""$temp_directory"index.html"							# Debian main site index page
		local download_log=""$logs_directory""$log_timestamp"-debian-version.log"
		local site_version=""$main_download_site"multi-arch/iso-cd/"
		debian_current_version="0"
		
		local site_version_trim=$(echo "$main_download_site" | cut -d'/' -f3- | cut -d'/' -f1)
		check_connection "$site_version_trim"
		
		log_everything "INFO" "Checking Debian Current Version"
		
		# Download Debian Main Sites 'index.html' file:
		wget									\
			--verbose							\
			--append-output="$download_log"		\
			--continue							\
			--timeout=3							\
			--directory-prefix="$temp_directory"	\
			"$site_version"
		
		# Check file for version number:
		debian_current_version=$(				\
			cat "$temp_file" 		|			\
				grep -F "[ISO]"		|			\
				cut -d'>' -f3-		|			\
				cut -d'<' -f1		|			\
				cut -d'-' -f2-		|			\
				cut -d'-' -f1					\
		)
		
		log_everything "INFO" "Current Version: "$debian_current_version""
		
		rm										\
			--force								\
			"$temp_file"
		
		if [ "$debian_current_version" == 0 ]; then
			printf "%s\n" "Can't get Debian current version"
		fi
	} >> "$log_file" 2>&1

###############################
##   Debian Download Manager ##
###############################
	debian_download_manager() {													# Debian Download Manager
		wget_file() {
			local log_timestamp=$(date +%y-%m-%d-%H-%M-%S)
			local download_log=""$logs_directory""$log_timestamp"-debian-"$1"-download.log"

			log_everything "INFO" "Downloading "$1" ("$2") to image directory in backgound"
			
			wget								\
				--verbose						\
				--append-output="$download_log"	\
				--continue						\
				--directory-prefix="$images_directory"	\
				"$2" &
			
			sleep 1
		}
		md5_check() {
			if [ -f ""$images_directory"MD5SUMS" ]; then						# If MD5SUMS exist, copy to new name
				log_everything "INFO" "Rename MD5 file to "$1""
				cp									\
					--verbose						\
					""$images_directory"MD5SUMS"	\
					""$images_directory""$1""
				log_everything "INFO" "Rename MD5 complete"
			fi
			if [ -f ""$images_directory"MD5SUMS" ]; then						# If MD5SUMS exist, remove
				log_everything "INFO" "Remove old MD5 file"
				rm									\
					--verbose						\
					""$images_directory"MD5SUMS"
				log_everything "INFO" "Remove old MD5 file complete"
			fi
			
			log_everything "INFO" "Check file(s) with MD5"
			cd "$images_directory"
			md5sum								\
				--check							\
				--ignore-missing				\
				"$1"
			cd ..
			log_everything "INFO" "MD5 check complete"
			
		}
		
		if [ ! -d "$images_directory" ]; then									# If Images Directory doesnt exist
			log_everything "INFO" "Checking for Image directory"
			mkdir								\
				--verbose						\
				"$images_directory"
		fi
		if [ ! -f ""$images_directory"MD5SUMS" ]; then							# If MD5SUMS exist, remove
			rm									\
				--verbose						\
				--force							\
				""$images_directory"MD5SUMS"
		fi
		
		# ================================================
		#	Download Options
		# ================================================
		if [ "$1" == "multiarchnet" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$main_download_site"multi-arch/iso-cd/MD5SUMS"
			wget_file "$1" ""$main_download_site"multi-arch/iso-cd/debian-"$debian_current_version"-amd64-i386-netinst.iso"
			md5_check "debian-"$debian_current_version"-amd64-i386-netinst.md5"
		elif [ "$1" == "i386netinst" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$main_download_site"i386/iso-cd/MD5SUMS"
#			wget_file "$1" ""$main_download_site"i386/iso-cd/debian-"$debian_current_version"-i386-netinst.iso"
			wget_file "$1" ""$mirror_download_site"i386/iso-cd/debian-"$debian_current_version"-i386-netinst.iso"
			md5_check "debian-"$debian_current_version"-i386-netinst.md5"
		elif [ "$1" == "amd64netinst" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$main_download_site"amd64/iso-cd/MD5SUMS"
#			wget_file "$1" ""$main_download_site"amd64/iso-cd/debian-"$debian_current_version"-amd64-netinst.iso"
			wget_file "$1" ""$mirror_download_site"amd64/iso-cd/debian-"$debian_current_version"-amd64-netinst.iso"
			md5_check "debian-9.5.0-amd64-netinst.md5"
		elif [ "$1" == "i386dvds" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$main_download_site"i386/iso-dvd/MD5SUMS"
			wget_file "$1" ""$main_download_site"i386/iso-dvd/debian-"$debian_current_version"-i386-DVD-1.iso"
			wget_file "$1" ""$main_download_site"i386/iso-dvd/debian-"$debian_current_version"-i386-DVD-2.iso"
			wget_file "$1" ""$main_download_site"i386/iso-dvd/debian-"$debian_current_version"-i386-DVD-3.iso"
			md5_check "debian-"$debian_current_version"-i386-dvds.md5"
		elif [ "$1" == "amd64dvds" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$main_download_site"amd64/iso-dvd/MD5SUMS"
			wget_file "$1" ""$main_download_site"amd64/iso-dvd/debian-"$debian_current_version"-amd64-DVD-1.iso"
			wget_file "$1" ""$main_download_site"amd64/iso-dvd/debian-"$debian_current_version"-amd64-DVD-2.iso"
			wget_file "$1" ""$main_download_site"amd64/iso-dvd/debian-"$debian_current_version"-amd64-DVD-3.iso"
			md5_check "debian-"$debian_current_version"-amd64-dvds.md5"
		elif [ "$1" == "multiarchfirmnet" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$unofficial_download_site"multi-arch/iso-cd/MD5SUMS"
			wget_file "$1" ""$unofficial_download_site"multi-arch/iso-cd/firmware-"$debian_current_version"-amd64-i386-netinst.iso"
			md5_check "firmware-"$debian_current_version"-amd64-i386-netinst.md5"
		elif [ "$1" == "i386firmnet" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$unofficial_download_site"i386/iso-cd/MD5SUMS"
			wget_file "$1" ""$unofficial_download_site"i386/iso-cd/firmware-"$debian_current_version"-i386-netinst.iso"
			md5_check "firmware-"$debian_current_version"-i386-netinst.md5"
		elif [ "$1" == "amd64firmnet" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$unofficial_download_site"amd64/iso-cd/MD5SUMS"
			wget_file "$1" ""$unofficial_download_site"amd64/iso-cd/firmware-"$debian_current_version"-amd64-netinst.iso"
			md5_check "firmware-"$debian_current_version"-amd64-netinst.md5"
		elif [ "$1" == "i386firmdvd" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$unofficial_download_site"i386/iso-dvd/MD5SUMS"
			wget_file "$1" ""$unofficial_download_site"i386/iso-dvd/firmware-"$debian_current_version"-i386-DVD-1.iso"
			md5_check "firmware-"$debian_current_version"-i386-dvds.md5"
		elif [ "$1" == "amd64firmdvd" ]; then
			log_everything "INFO" "Download "$1" file"
			wget_file "$1" ""$unofficial_download_site"amd64/iso-dvd/MD5SUMS"
			wget_file "$1" ""$unofficial_download_site"amd64/iso-dvd/firmware-"$debian_current_version"-amd64-DVD-1.iso"
			md5_check "firmware-"$debian_current_version"-amd64-dvds.md5"
		fi
	} >> "$log_file" 2>&1

###############################
##   Debian Preseed Builder  ##
###############################
	preseed_builder() {															# Contents of the preconfiguration file
		local timestamp=$(date +%y-%m-%d)
		# Network Settings
		local host_ip="192.168.0.165"
		local host_name="web_server"
		# Partition and Boot Settings
		local disk_drive="/dev/sda"
		# Account Settings
		local full_username="TerryJohn Anscombe"
		local short_username="tj"
		
		log_everything "INFO" "Building Preseed File"
		
		preseed_filename="preseed.cfg"
		
		if [ -f "$preseed_filename" ]; then										# If Preseed file exist, remove
			rm							\
				--force					\
				"$preseed_filename"
		fi
		
		log_everything "INFO" "Creating Preseed File"
		touch "$preseed_filename"												# Create new Preseed file
		log_everything "INFO" "Creation Complete"
		
		build_header() {														# File Header
			cat >> "$preseed_filename" << EOF
# ============================================
# Custom Preseed File made by Debian ISO Maker
# Build Date: $timestamp
# ============================================
EOF
		}
		build_localization() {													# Localization
			log_everything "INFO" "Building Localization"
			
			# Locale sets language and country
			cat >> "$preseed_filename" << "EOF"
d-i debian-installer/locale string en_US
d-i debian-installer/language string en
d-i debian-installer/country string US
d-i debian-installer/locale string en_US.UTF-8
EOF
			
			# Keyboard selection
			# Example for a different keyboard architecture
			#d-i console-keymaps-usb/keymap select mac-usb-us
			#d-i console-tools/archs select at
			cat >> "$preseed_filename" << "EOF"
d-i console-keymaps-at/keymap select us
d-i keyboard-configuration/xkb-keymap select us
EOF
		}
		build_network() {														# Network configuration
			log_everything "INFO" "Building Network"
			
			# netcfg will choose an interface that has link if possible. This makes it
			# skip displaying a list if there is more than one interface.
			cat >> "$preseed_filename" << "EOF"
d-i netcfg/choose_interface select auto
EOF
			
			# To pick a particular interface instead:
			#d-i netcfg/choose_interface select eth1
			
			# If you have a slow dhcp server and the installer times out waiting for
			# it, this might be useful.
			#d-i netcfg/dhcp_timeout string 60
			
			# If you prefer to configure the network manually, uncomment this line and
			# the static network configuration below.
			cat >> "$preseed_filename" << "EOF"
d-i netcfg/disable_dhcp boolean true
EOF
			
			# If you want the preconfiguration file to work on systems both with and
			# without a dhcp server, uncomment these lines and the static network
			# configuration below.
			#d-i netcfg/dhcp_failed note
			#d-i netcfg/dhcp_options select Configure network manually
			
			# Static network configuration.
			cat >> "$preseed_filename" << EOF
d-i netcfg/get_nameservers string 8.8.8.8
d-i netcfg/get_ipaddress string $1
d-i netcfg/get_netmask string 255.255.255.0
d-i netcfg/get_gateway string 192.168.0.1
d-i netcfg/confirm_static boolean true
EOF
			
			# Any hostname and domain names assigned from dhcp take precedence over
			# values set here. However, setting the values still prevents the questions
			# from being shown, even if values come from dhcp.
			cat >> "$preseed_filename" << EOF
d-i netcfg/get_hostname string $2
d-i netcfg/get_hostname seen true
d-i netcfg/get_domain string $2
d-i netcfg/get_domain seen true
EOF
			
			# If you want to force a hostname, regardless of what either the DHCP
			# server returns or what the reverse DNS entry for the IP is, uncomment
			# and adjust the following line.
			cat >> "$preseed_filename" << EOF
d-i netcfg/hostname string $2
EOF
			
			# Disable that annoying WEP key dialog.
			cat >> "$preseed_filename" << "EOF"
d-i netcfg/wireless_wep string
EOF
			
			# The wacky dhcp hostname that some ISPs use as a password of sorts.
			#d-i netcfg/dhcp_hostname string radish
			
			## Mirror settings
			# If you select ftp, the mirror/country string does not need to be set.
			#d-i mirror/protocol string ftp
			cat >> "$preseed_filename" << "EOF"
d-i mirror/country string US
d-i mirror/http/hostname string http.us.debian.org
d-i mirror/http/directory string /debian
d-i mirror/suite string stretch
d-i mirror/http/proxy string
EOF
			
			# Suite to install.
			#d-i mirror/suite string testing
			# Suite to use for loading installer components (optional).
			#d-i mirror/udeb/suite string testing
	}
		build_partition() {														# Partitioning
			log_everything "INFO" "Building Partition"
			
			# If the system has free space you can choose to only partition that space.
			# Note: this must be preseeded with a localized (translated) value.
			#d-i partman-auto/init_automatically_partition \
			#      select Guided - use the largest continuous free space
			
			# Alternatively, you can specify a disk to partition. The device name
			# can be given in either devfs or traditional non-devfs format.
			# For example, to use the first disk:
			cat >> "$preseed_filename" << EOF
d-i partman-auto/disk string $1
EOF
			
			# In addition, you'll need to specify the method to use.
			# The presently available methods are: "regular", "lvm" and "crypto"
			cat >> "$preseed_filename" << EOF
d-i partman-auto/method string regular
EOF
			
			# If one of the disks that are going to be automatically partitioned
			# contains an old LVM configuration, the user will normally receive a
			# warning. This can be preseeded away...
			#d-i partman-auto/purge_lvm_from_device boolean true
			#d-i part-lvm/device_remove_lvm boolean true
			# And the same goes for the confirmation to write the lvm partitions.
			#d-i partman-lvm/confirm boolean true
			#d-i partman-lvm/confirm_nooverwrite boolean true
			
			# Keep that one set to true so we end up with a UEFI enabled
			# system. If set to false, /var/lib/partman/uefi_ignore will be touched
			#d-i partman-efi/non_efi_system boolean true
			
			# enforce usage of GPT - a must have to use EFI!
			#d-i partman-basicfilesystems/choose_label string gpt
			#d-i partman-basicfilesystems/default_label string gpt
			#d-i partman-partitioning/choose_label string gpt
			#d-i partman-partitioning/default_label string gpt
			#d-i partman/choose_label string gpt
			#d-i partman/default_label string gpt
			
			# You can choose from any of the predefined partitioning recipes.
			# Note: this must be preseeded with a localized (translated) value.
			cat >> "$preseed_filename" << "EOF"
d-i partman-auto/choose_recipe \
       select All files in one partition (recommended for new users)
EOF
			
			#d-i partman-auto/choose_recipe \
			#       select Separate /home partition
			#d-i partman-auto/choose_recipe \
			#       select Separate /home, /usr, /var, and /tmp partitions
			
			# Or provide a recipe of your own...
			# The recipe format is documented in the file devel/partman-auto-recipe.txt.
			# If you have a way to get a recipe file into the d-i environment, you can
			# just point at it.
			#d-i partman-auto/expert_recipe_file string /hd-media/recipe
			
			# If not, you can put an entire recipe into the preconfiguration file in one
			# (logical) line. This example creates a small /boot partition, suitable
			# swap, and uses the rest of the space for the root partition:
			cat >> "$preseed_filename" << "EOF"
d-i partman-auto/expert_recipe string                         \
      boot-root ::                                            \
              256 1024 512 ext2                               \
                      $primary{ } $bootable{ }                \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext2 }    \
                      mountpoint{ /boot }                     \
              .                                               \
              500 10000 1000000000 ext4                       \
                      $lvmok{ }                               \
                      method{ format } format{ }              \
                      use_filesystem{ } filesystem{ ext4 }    \
                      mountpoint{ / }                         \
              .                                               \
              64 512 300% linux-swap                          \
                      method{ swap } format{ }                \
              .
EOF
			
			# This makes partman automatically partition without confirmation.
			cat >> "$preseed_filename" << "EOF"
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition \
       select Finish partitioning and write changes to disk
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
EOF
		}
		build_clock() {															# Clock and time zone setup
			log_everything "INFO" "Building Clock"
			
			# Controls whether or not the hardware clock is set to UTC.
			cat >> "$preseed_filename" << "EOF"
d-i clock-setup/utc boolean true
EOF
			
			# You may set this to any valid setting for $TZ; see the contents of
			# /usr/share/zoneinfo/ for valid values.
			cat >> "$preseed_filename" << "EOF"
d-i time/zone string US/Eastern
EOF
			
			# Controls whether to use NTP to set the clock during the install
			cat >> "$preseed_filename" << "EOF"
d-i clock-setup/ntp boolean true
EOF
			
			# NTP server to use. The default is almost always fine here.
			cat >> "$preseed_filename" << "EOF"
d-i clock-setup/ntp-server string 0.nl.pool.ntp.org
EOF
		}
		build_apt() {															# Apt setup
			log_everything "INFO" "Building APT"
			
			# You can choose to install non-free and contrib software.
			cat >> "$preseed_filename" << "EOF"
d-i apt-setup/non-free boolean true
d-i apt-setup/contrib boolean true
EOF
			
			# Uncomment this if you don't want to use a network mirror.
			#d-i apt-setup/use_mirror boolean false
			# Uncomment this to avoid adding security sources, or
			# add a hostname to use a different server than security.debian.org.
			#d-i apt-setup/security_host string
			
			# Additional repositories, local[0-9] available
			#d-i apt-setup/local0/repository string \
			#       deb http://local.server/debian stable main
			#d-i apt-setup/local0/comment string local server
			# Enable deb-src lines

			cat >> "$preseed_filename" << "EOF"
d-i apt-setup/local0/source boolean true
EOF
			
			# URL to the public key of the local repository; you must provide a key or
			# apt will complain about the unauthenticated repository and so the
			# sources.list line will be left commented out
			#d-i apt-setup/local0/key string http://local.server/key
			
			# By default the installer requires that repositories be authenticated
			# using a known gpg key. This setting can be used to disable that
			# authentication. Warning: Insecure, not recommended.
			#d-i debian-installer/allow_unauthenticated string true
		}
		build_accounts() {														# Account setup
			log_everything "INFO" "Building Accounts"
			
			# Skip creation of a root account (normal user account will be able to
			# use sudo).
			cat >> "$preseed_filename" << "EOF"
d-i passwd/root-login boolean false
EOF
			
			# Alternatively, to skip creation of a normal user account.
			#d-i passwd/make-user boolean false
			
			# Root password, either in clear text
			#d-i passwd/root-password password r00tme
			#d-i passwd/root-password-again password r00tme
			# or encrypted using an MD5 hash.
			#d-i passwd/root-password-crypted password [MD5 hash]
			
			# To create a normal user account.
			cat >> "$preseed_filename" << EOF
d-i passwd/user-fullname string $2
d-i passwd/username string $1
EOF
			
			# Normal user's password, either in clear text
			#d-i passwd/user-password password tester
			#d-i passwd/user-password-again password tester
			# or encrypted using an MD5 hash.
			# To generate a password with MD5
			#   echo "password" | mkpasswd -s -H MD5
			cat >> "$preseed_filename" << "EOF"
d-i passwd/user-password-crypted password $1$VqVPh8rz$XlLsoNEweLOX.itNFPMtm/
EOF
		}
		build_base() {															# Base system installation
			log_everything "INFO" "Building Base System"
			
			# Select the initramfs generator used to generate the initrd for 2.6 kernels.
			#d-i base-installer/kernel/linux/initramfs-generators string yaird
			
			# Allow non-free firmware
			cat >> "$preseed_filename" << "EOF"
d-i hw-detect/load_firmware boolean true
EOF
		}
		build_boot() {															# Boot loader installation
			log_everything "INFO" "Building Boot System"
			
			# Grub is the default boot loader (for x86). If you want lilo installed
			# instead, uncomment this:
			#d-i grub-installer/skip boolean true
			
			# This is fairly safe to set, it makes grub install automatically to the MBR
			# if no other operating system is detected on the machine.
			cat >> "$preseed_filename" << EOF
d-i grub-installer/only_debian boolean true
EOF
			
			# This one makes grub-installer install to the MBR if it also finds some other
			# OS, which is less safe as it might not be able to boot that other OS.
			cat >> "$preseed_filename" << EOF
d-i grub-installer/with_other_os boolean true
EOF
			
			# Alternatively, if you want to install to a location other than the mbr,
			# uncomment and edit these lines:
			#d-i grub-installer/only_debian boolean false
			#d-i grub-installer/with_other_os boolean false
			#d-i grub-installer/bootdev  string (hd0,0)
			cat >> "$preseed_filename" << EOF
d-i grub-installer/bootdev  string $1
EOF
			
			# To install grub to multiple disks:
			#d-i grub-installer/bootdev  string (hd0,0) (hd1,0) (hd2,0)
		}
		build_packages() {														# Package selection
			log_everything "INFO" "Building Packages"
			
			# Options are:
			#   standard, desktop, gnome-desktop, kde-desktop, web-server
			#   print-server, dns-server, file-server, mail-server
			#   sql-database, laptop
			#tasksel tasksel/first multiselect standard, desktop
			#tasksel tasksel/first multiselect standard, web-server
			#tasksel tasksel/first multiselect standard, kde-desktop
			cat >> "$preseed_filename" << "EOF"
tasksel tasksel/first multiselect standard, standard
EOF
			
			# Individual additional packages to install
			#d-i pkgsel/include string openssh-server build-essential tmux htop curl wget git
			# Whether to upgrade packages after debootstrap.
			# Allowed values: none, safe-upgrade, full-upgrade
			#d-i pkgsel/upgrade select full-upgrade
			
			# Some versions of the installer can report back on what software you have
			# installed, and what software you use. The default is not to report back,
			# but sending reports helps the project determine what software is most
			# popular and include it on CDs.
			cat >> "$preseed_filename" << "EOF"
popularity-contest popularity-contest/participate boolean false
EOF
		}
		build_finishing() {														# Finishing up the first stage install
			log_everything "INFO" "Building Finish"
			
			# Avoid that last message about the install being complete.
			cat >> "$preseed_filename" << "EOF"
d-i finish-install/reboot_in_progress note
EOF
			
			# This will prevent the installer from ejecting the CD during the reboot,
			# which is useful in some situations.
			#d-i cdrom-detect/eject boolean false
			
			# This is how to make the installer shutdown when finished, but not
			# reboot into the installed system.
			#d-i debian-installer/exit/halt boolean true
			# This will power off the machine instead of just halting it.
			cat >> "$preseed_filename" << "EOF"
d-i debian-installer/exit/poweroff boolean true
EOF
		}
		build_xconf() {															# X configuration
			log_everything "INFO" "Building Display Setup"
			
			# X can detect the right driver for some cards, but if you're preseeding,
			# you override whatever it chooses. Still, vesa will work most places.
			#xserver-xorg xserver-xorg/config/device/driver select vesa
			
			# A caveat with mouse autodetection is that if it fails, X will retry it
			# over and over. So if it's preseeded to be done, there is a possibility of
			# an infinite loop if the mouse is not autodetected.
			#xserver-xorg xserver-xorg/autodetect_mouse boolean true
			
			# Monitor autodetection is recommended.
			cat >> "$preseed_filename" << "EOF"
xserver-xorg xserver-xorg/autodetect_monitor boolean true
EOF
			
			# Uncomment if you have an LCD display.
			#xserver-xorg xserver-xorg/config/monitor/lcd boolean true
			# X has three configuration paths for the monitor. Here's how to preseed
			# the "medium" path, which is always available. The "simple" path may not
			# be available, and the "advanced" path asks too many questions.
			cat >> "$preseed_filename" << "EOF"
xserver-xorg xserver-xorg/config/monitor/selection-method \
       select medium
xserver-xorg xserver-xorg/config/monitor/mode-list \
       select 1024x768 @ 60 Hz
EOF
		}
		build_other() {															# Preseeding other packages
			log_everything "INFO" "Building Others"
			
			# Depending on what software you choose to install, or if things go wrong
			# during the installation process, it's possible that other questions may
			# be asked. You can preseed those too, of course. To get a list of every
			# possible question that could be asked during an install, do an
			# installation, and then run these commands:
			#   debconf-get-selections --installer > file
			#   debconf-get-selections >> file
		}
		build_advanced() {														# Advanced options
																				# Running custom commands during the installation
			log_everything "INFO" "Building Advanced Setup"
			
			# d-i preseeding is inherently not secure. Nothing in the installer checks
			# for attempts at buffer overflows or other exploits of the values of a
			# preconfiguration file like this one. Only use preconfiguration files from
			# trusted locations! To drive that home, and because it's generally useful,
			# here's a way to run any shell command you'd like inside the installer,
			# automatically.
			
			# This first command is run as early as possible, just after
			# preseeding is read.
			#d-i preseed/early_command string anna-install some-udeb
			
			# This command is run just before the install finishes, but when there is
			# still a usable /target directory. You can chroot to /target and use it
			# directly, or use the apt-install and in-target commands to easily install
			# packages and run commands in the target system.
			#d-i preseed/late_command string apt-install zsh; in-target chsh -s /bin/zsh
			cat >> "$preseed_filename" << "EOF"
d-i preseed/late_command string				\
	rm /target/etc/motd;					\
	touch /target/etc/motd;					\
	rm /target/etc/issue;					\
	touch /target/etc/issue;				\
	echo "Linux \l" > /target/etc/issue;	\
	echo " " >> /target/etc/issue;			\
	cp /target/home/tj/.profile /target/home/tj/.profile_backup;				\
	echo ". /home/tj/.setup.sh" >> /target/home/tj/.profile;					\
	cp /cdrom/files/.setup.sh /target/home/tj/.setup.sh;						\
	cp /cdrom/files/sources.list /target/etc/apt/sources.list;
EOF
		}
		build_md5_preseed() {													# MD5 Preseed File
			log_everything "INFO" "Building MD5 Numbers"
			preseed_md5=$(md5sum "$preseed_filename" | cut -d' ' -f1-)
			printf "%s\n" "$preseed_md5"
			
#			debconf-set-selections -c "$preseed_filename"
		}
		
		build_header
		build_localization
		build_network "$host_ip" "$host_name"
		build_partition "$disk_drive"
		build_clock
		build_apt
		build_accounts "$short_username" "$full_username"
		build_base
		build_boot "$disk_drive"
		build_packages
		build_finishing
		build_xconf
		build_other
		build_advanced
		build_md5_preseed
		
		log_everything "INFO" "Preseed Build Complete"
	} >> "$log_file" 2>&1

###############################
##   Debian Image Rebuilder  ##
###############################
	build_debian_image() {
		local isoimage="debian-9.5.0-amd64-netinst.iso"
		
		clean_isofiles_directory() {											# Clean up
			echo "================================================"
			echo "-- Cleaning up isofiles directory..."
			echo "================================================"
			if [ -d "$iso_files_directory" ]; then
				chmod										\
					--verbose								\
					--recursive								\
					+w										\
					"$iso_files_directory"
				
				rm											\
					--verbose								\
					--recursive								\
					"$iso_files_directory"
			fi
			echo "================================================"
			echo "-- Clean complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		extract_iso_file() {													# Extracting the Initrd from an ISO Image
			echo "================================================"
			echo "--Extracting ISO Image..."
			echo "================================================"
			7z												\
				x											\
				-y											\
				-o"$2"										\
				"$1"
			echo "================================================"
			echo "--Extraction complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		add_preseed_file() {													# Adding a Preseed File to the Initrd
			#	local image_files_directory386=""$image_files_directory"/install.386/"
			
			echo "================================================"
			echo "--Adding a Preseed File to the Initrd"
			echo "================================================"
#			chmod										\
#				--verbose								\
#				--recursive								\
#				+w										\
#				"$image_files_directory386"
			
#			gunzip										\
#				--verbose								\
#				"$image_files_directory386"initrd.gz
			
#			echo "<preseed_file>" | cpio --verbose -H newc -o -A -F "$image_files_directory386"initrd
			
#			gzip										\
#				--verbose								\
#				"$image_files_directory386"initrd
			
#			chmod										\
#				--verbose								\
#				--recursive								\
#				-w										\
#				"$image_files_directory386"
			
			cp											\
				--verbose								\
				"config-files/preseed-386.cfg"			\
				"$image_files_directory"/preseed.cfg
			
			preseed_md5=$(md5sum "$image_files_directory"/preseed.cfg | cut -d' ' -f1)
			
			echo "================================================"
			echo "--Complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		edit_isolinux_menu() {													# Edit Boot Menu
			echo "================================================"
			echo "--Change ISOLinux Menu..."
			echo "================================================"
			local user_interface
			local initrd_interface
			
			if [ "$debian_installer_user_interface" == "yes" ]; then
				user_interface="newt"
				initrd_interface="/install.386/initrd.gz"
			elif [ "$debian_installer_user_interface" == "no" ]; then
				user_interface="text"
				initrd_interface="/install.386/initrd.gz"
			elif [ "$debian_installer_user_interface" == "full" ]; then
				user_interface="gtk"
				initrd_interface="/install.386/gtk/initrd.gz"
			fi
			
			cat > "$image_files_directory"/isolinux/isolinux.cfg << EOF
default auto
label auto
kernel /install.386/vmlinuz
append preseed/interactive=false preseed/file=/cdrom/preseed.cfg preseed/file/checksum=$preseed_md5 locale=en_US.UTF-8 keymap=us language=us country=US hostname=$vm_name domain=$vm_name DEBIAN_FRONTEND=$user_interface BOOT_DEBUG=2 auto=true priority=critical vga=788 initrd=$initrd_interface
timeout 1

EOF
			echo "================================================"
			echo "--Change complete"
			echo "================================================"
			
			echo "================================================"
			echo "--Remove unneeded files..."
			echo "================================================"
			rm													\
				--verbose										\
				--force											\
				"$image_files_directory"/isolinux/adgtk.cfg		\
				"$image_files_directory"/isolinux/adspkgtk.cfg	\
				"$image_files_directory"/isolinux/adtxt.cfg		\
				"$image_files_directory"/isolinux/exithelp.cfg	\
				"$image_files_directory"/isolinux/f1.txt		\
				"$image_files_directory"/isolinux/f2.txt		\
				"$image_files_directory"/isolinux/f3.txt		\
				"$image_files_directory"/isolinux/f4.txt		\
				"$image_files_directory"/isolinux/f5.txt		\
				"$image_files_directory"/isolinux/f6.txt		\
				"$image_files_directory"/isolinux/f7.txt		\
				"$image_files_directory"/isolinux/f8.txt		\
				"$image_files_directory"/isolinux/f9.txt		\
				"$image_files_directory"/isolinux/f10.txt		\
				"$image_files_directory"/isolinux/gtk.cfg		\
				"$image_files_directory"/isolinux/menu.cfg		\
				"$image_files_directory"/isolinux/prompt.cfg	\
				"$image_files_directory"/isolinux/rqgtk.cfg		\
				"$image_files_directory"/isolinux/rqspkgtk.cfg	\
				"$image_files_directory"/isolinux/rqtxt.cfg		\
				"$image_files_directory"/isolinux/spkgtk.cfg	\
				"$image_files_directory"/isolinux/splash.png	\
				"$image_files_directory"/isolinux/stdmenu.cfg	\
				"$image_files_directory"/isolinux/txt.cfg
			
			echo "================================================"
			echo "--Remove complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		mod_grub_files() {														# Edit Boot Loader
			# Add grub file
			echo "================================================"
			echo "--Adding GRUB config file..."
			echo "================================================"
			cp												\
				--verbose									\
				"$grub_file"								\
				"$image_files_directory"/boot/grub/grub.cfg
			echo "================================================"
			echo "--Add complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		add_firmware_files() {													# Add Firmware
			echo "================================================"
			echo "--Extracting Firmware files..."
			echo "================================================"
			tar												\
				--extract									\
				--gzip										\
				--verbose									\
				--file="$1"									\
				--directory="$firmware_image_files_directory"
			echo "================================================"
			echo "--Extraction complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		add_software() {														# Add Extra Software
			echo "================================================"
			echo "--Adding Extra Software..."
			echo "================================================"
			download_type="git"															# Download with 'git' or 'wget'
			
			owncloud_setup() {															# OwnCloud
				local owncloud_directory=""$files_download"/owncloud/"
				
				if [ ! -d "$owncloud_directory" ]; then									# Make owncloud directory
					mkdir									\
						--verbose							\
						"$owncloud_directory"
				fi
				
				if [ ! -f ""$files_download"owncloud.tar.gz" ]; then					# Download owncloud to directory
#					if [ "$download_type" == "git" ]; then
#						git										\
#							clone								\
#							https://github.com/owncloud/core.git	\
#							"$owncloud_directory"
#					elif [ "$download_type" == "wget" ]; then
					wget									\
						--continue							\
						--output-document="$files_download"owncloud.tar.bz2	\
						https://download.owncloud.org/community/owncloud-10.0.9.tar.bz2
#					fi
				fi
				
				if [ ! -f ""$files_download"owncloud.tar.gz" ]; then					# Decompress download file
					tar										\
						--extract							\
						--bzip2								\
						--verbose							\
						--directory="$files_download"		\
						--file=""$files_download"owncloud.tar.bz2"
				fi
				
				if [ ! -f ""$files_download"owncloud.tar.gz" ]; then					# Compress owncloud directory
					tar										\
						--create							\
						--gzip								\
						--verbose							\
						--file=""$files_download"owncloud.tar.gz"		\
						"$owncloud_directory"
				fi
				
				if [ ! -f ""$image_files_directory"/files/owncloud.tar.gz" ]; then		# Copy to image
					cp											\
						--verbose								\
						""$files_download"owncloud.tar.gz"		\
						""$image_files_directory"/files/"
				fi
			}
			
			phpmyadmin_setup() {														# phpMyAdmin
				local phpmyadmin_directory=""$files_download"/phpmyadmin/"
				
				if [ ! -d "$phpmyadmin_directory" ]; then								# Make phpmyadmin directory
					mkdir									\
						--verbose							\
						"$phpmyadmin_directory"
				fi
				
				if [ ! -f ""$files_download"phpmyadmin.tar.gz" ]; then					# Download phpmyadmin to directory
					if [ "$download_type" == "git" ]; then
						git									\
							clone							\
							https://github.com/phpmyadmin/phpmyadmin.git	\
							"$phpmyadmin_directory"
					elif [ "$download_type" == "wget" ]; then
						wget								\
							--continue						\
							--output-document=phpmyadmin.tar.xz	\
							https://files.phpmyadmin.net/phpMyAdmin/4.8.3/phpMyAdmin-4.8.3-english.tar.xz
					fi
				fi
				
				if [ ! -f ""$files_download"phpmyadmin.tar.gz" ]; then					# Compress phpmyadmin directory
					tar											\
						--create								\
						--gzip									\
						--verbose								\
						--file=""$files_download"phpmyadmin.tar.gz"		\
						"$phpmyadmin_directory"
				fi
				
				if [ ! -f ""$image_files_directory"/files/phpmyadmin.tar.gz" ]; then	# Copy to image
					cp											\
						--verbose								\
						""$files_download"phpmyadmin.tar.gz"	\
						""$image_files_directory"/files/"
				fi
			}
			
			virtualbox_setup() {														# VirtualBox
				if [ ! -f ""$files_download"oracle_vbox_2016.asc" ]; then
					wget										\
						--continue								\
						--output-document="downloads/oracle_vbox_2016.asc"	\
						https://www.virtualbox.org/download/oracle_vbox_2016.asc
				fi
				
				if [ ! -f ""$files_download"oracle_vbox.asc" ]; then
					wget										\
						--continue								\
						--output-document="downlads/oracle_vbox.asc"	\
						https://www.virtualbox.org/download/oracle_vbox.asc
				fi
				
				if [ ! -f ""$image_files_directory"/files/oracle_vbox_2016.asc" ]; then	# Copy to image
					cp											\
						--verbose								\
						""$files_download"oracle_vbox_2016.asc"	\
						""$image_files_directory"/files/"
				fi
				
				if [ ! -f ""$image_files_directory"/files/oracle_vbox.asc" ]; then		# Copy to image
					cp											\
						--verbose								\
						""$files_download"oracle_vbox.asc"		\
						""$image_files_directory"/files/"
				fi
			}
			
			phpvirtualbox_setup() {														# phpVirtualBox
				local phpvirtualbox_directory=""$files_download"/phpvirtualbox/"
				
				if [ ! -d "$phpvirtualbox_directory" ]; then							# Make phpvirtualbox directory
					mkdir									\
						--verbose							\
						"$phpvirtualbox_directory"
				fi
				
				if [ ! -f ""$files_download"phpvirtualbox.tar.gz" ]; then				# Download phpvirtualbox to directory
					if [ "$download_type" == "git" ]; then
						git									\
							clone							\
							https://github.com/phpvirtualbox/phpvirtualbox.git	\
							"$phpvirtualbox_directory"
					elif [ "$download_type" == "wget" ]; then
						echo "No Wget"
					fi
				fi
				
				if [ ! -f ""$files_download"phpvirtualbox.tar.gz" ]; then				# Compress phpvirtualbox directory
					tar											\
						--create								\
						--gzip									\
						--verbose								\
						--file=""$files_download"phpvirtualbox.tar.gz"	\
						"$phpvirtualbox_directory"
				fi
				
				if [ ! -f ""$image_files_directory"/files/phpvirtualbox.tar.gz" ]; then	# Copy to image
					cp											\
						--verbose								\
						""$files_download"phpvirtualbox.tar.gz"	\
						""$image_files_directory"/files/"
				fi
			}
			
			build_new_setup() {															# First Boot Setup
				touch									\
					"$temp_location"/.setup.sh
				
				cat >> "$temp_location"/.setup.sh << "EOF"
#/bin/bash

log_file="setup.log"

if [ -f "$log_file" ]; then
	rm "$log_file"
fi

touch "$log_file"

upgrade_system() {																# Update System
	sudo apt-get update
	sudo apt-get full-upgrade --yes
	sudo apt-get autoremove
	sudo apt-get autoclean
#} >> "$log_file" 2>&1
}

install_software() {															# Install Software
	sudo apt-get install apt-transport-https ca-certificates build-essential --yes
	sudo apt-get install openssh-server --yes									# SSH Server Install
	sudo sh -c "echo '' >> /etc/apt/sources.list"
	sudo sh -c "echo '# PHP 7.2' >> /etc/apt/sources.list"
	sudo sh -c "echo 'deb https://packages.sury.org/php/ stretch main' >> /etc/apt/sources.list"
	sudo cp --verbose php.gpg /etc/apt/trusted.gpg.d/php.gpg					# PHP APT GPG
	sudo apt-get update
	sudo apt-get install apache2 php mysql-server --yes							# Web Server Install
	sudo apt-get autoremove
	sudo apt-get autoclean
#	sudo service mysql stop
#	sudo touch "mysql-init"
#	sudo echo "UPDATE mysql.user SET Password=PASSWORD('testersql') WHERE User='root';" > "mysql-init"
#	sudo echo "FLUSH PRIVILEGES;" >> "mysql-init"
#	sudo mysqld_safe --init-file=mysql-init &
	
	# Add user to web group
	sudo usermod -a -G www-data tj
	
	# phpMyAdmin
	sudo apt-get install phpmyadmin --yes
	
	# VirtualBox
	sudo sh -c "echo '' >> /etc/apt/sources.list"
	sudo sh -c "echo '# virtualbox.list Oracle Virtualbox third-party repository' >> /etc/apt/sources.list"
	sudo sh -c "echo 'deb https://download.virtualbox.org/virtualbox/debian stretch contrib' >> /etc/apt/sources.list"
	sudo apt-key add oracle_vbox_2016.asc
	sudo apt-key add oracle_vbox.asc
	sudo apt-get update
	sudo apt-get install linux-headers-$(uname -r|sed 's,[^-]*-[^-]*-,,') --yes
	sudo apt-get install virtualbox virtualbox-dkms virtualbox-ext-pack --yes	# VirtualBox Install
		
	# OwnCloud
	tar --extract --verbose	--gzip --file=owncloud.tar.gz
	sudo mkdir --verbose /var/www/owncloud/
	sudo cp --verbose --recursive downloads/owncloud/* /var/www/owncloud
	sudo chown --verbose --recursive www-data:www-data /var/www/owncloud/
	# Apache Site Availabe Add
	apache2_owncloud="/etc/apache2/sites-available/owncloud.conf"
	sudo touch "$apache2_owncloud"
	sudo sh -c "echo 'Alias /owncloud '/var/www/owncloud/'' > $apache2_owncloud"
	sudo sh -c "echo '<Directory /var/www/owncloud/>' >> $apache2_owncloud"
	sudo sh -c "echo '  Options +FollowSymlinks' >> $apache2_owncloud"
	sudo sh -c "echo '  AllowOverride All' >> $apache2_owncloud"
	sudo sh -c "echo '<IfModule mod_dav.c>' >> $apache2_owncloud"
	sudo sh -c "echo '  Dav off' >> $apache2_owncloud"
	sudo sh -c "echo '</IfModule>' >> $apache2_owncloud"
	sudo sh -c "echo 'SetEnv HOME /var/www/owncloud' >> $apache2_owncloud"
	sudo sh -c "echo 'SetEnv HTTP_HOME /var/www/owncloud' >> $apache2_owncloud"
	sudo sh -c "echo '</Directory>' >> $apache2_owncloud"
	sudo ln -s "$apache2_owncloud" /etc/apache2/sites-enabled/owncloud.conf
	sudo apt-get install	\
		libapache2-mod-php	\
		php-imagick			\
		php-common			\
		php-curl			\
		php-gd				\
		php-imap			\
		php-intl			\
		php-json			\
		php-ldap			\
		php-mbstring		\
		php-mcrypt			\
		php-mysql			\
		php-pgsql			\
		php-smbclient		\
		php-ssh2			\
		php-sqlite3			\
		php-xml				\
		php-zip --yes
	sudo a2enmod rewrite
	sudo a2enmod header
	sudo a2enmod env
	sudo a2enmod dir
	sudo a2enmod mime
	
	# phpVirtualBox
	tar --extract --verbose	--gzip --file=phpvirtualbox.tar.gz
	sudo mkdir --verbose /var/www/phpvirtualbox/
	sudo cp --verbose --recursive downloads/phpvirtualbox/* /var/www/phpvirtualbox/
	sudo chown --verbose --recursive www-data:www-data /var/www/phpvirtualbox/
	# Apache Site Availabe Add
	apache2_phpvirtualbox="/etc/apache2/sites-available/phpvirtualbox.conf"
	sudo touch "$apache2_phpvirtualbox"
	sudo sh -c "echo 'Alias /phpvirtualbox '/var/www/phpvirtualbox.conf'' > $apache2_phpvirtualbox"
	sudo sh -c "echo '<Directory /var/www/phpvirtualbox/>' >> $apache2_phpvirtualbox"
	sudo sh -c "echo '  Options +FollowSymlinks' >> $apache2_phpvirtualbox"
	sudo sh -c "echo '  AllowOverride All' >> $apache2_phpvirtualbox"
	sudo sh -c "echo 'SetEnv HOME /var/www/phpvirtualbox' >> $apache2_phpvirtualbox"
	sudo sh -c "echo 'SetEnv HTTP_HOME /var/www/phpvirtualbox' >> $apache2_phpvirtualbox"
	sudo sh -c "echo '</Directory>' >> $apache2_phpvirtualbox"
	sudo ln -s "$apache2_phpvirtualbox" /etc/apache2/sites-enabled/phpvirtualbox.conf
	
	sudo apt-get update
	sudo apt-get full-upgrade --yes
	sudo apt-get autoremove
	sudo apt-get autoclean
#} >> "$log_file" 2>&1
}

reboot_system() {
	cp /home/tj/.profile_backup /home/tj/.profile
	sudo rm --force /home/tj/.profile_backup
#	sudo rm --force /home/tj/.setup.sh
	printf "%s\n" "Rebooting in 3"
	sleep 1
	printf "%s" "2"
	sleep 1
	printf "%s" "1"
	sleep 1
	sudo shutdown -r now
#} >> "$log_file" 2>&1
}

printf "%s\n" "Updating System..."
upgrade_system
printf "%s\n" "Install Software..."
install_software
printf "%s\n" "Rebooting System..."
reboot_system

EOF
				
				cp											\
					--verbose								\
					"$temp_location".setup.sh				\
					"$image_files_directory"/files/.setup.sh
				cp											\
					--verbose								\
					"downloads/php.gpg"						\
					"$image_files_directory"/files/php.gpg
			}
			
			build_new_source() {														# APT Source List
				touch									\
					"$temp_location"/sources.list
				
				cat >> "$temp_location"/sources.list << "EOF"
#-------------------------
#  Official Debian Repos
#-------------------------

## Main Repos
deb http://deb.debian.org/debian/ stretch main contrib non-free
deb http://ftp.us.debian.org/debian/ stretch main contrib non-free
deb-src http://deb.debian.org/debian/ stretch main contrib non-free
deb-src http://ftp.us.debian.org/debian/ stretch main contrib non-free

## Updates Repos
deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb http://ftp.us.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://ftp.us.debian.org/debian/ stretch-updates main contrib non-free

## Security Repos
deb http://security.debian.org/ stretch/updates main contrib non-free
deb http://security.debian.org/debian-security/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/debian-security/ stretch/updates main contrib non-free

## Backports Repos
deb http://deb.debian.org/debian/ stretch-backports main contrib non-free
deb http://ftp.debian.org/debian/ stretch-backports main contrib non-free
deb-src http://deb.debian.org/debian/ stretch-backports main contrib non-free
deb-src http://ftp.debian.org/debian/ stretch-backports main contrib non-free

EOF
				
				cp											\
					--verbose								\
					"$temp_location"sources.list			\
					"$image_files_directory"/files/sources.list
			}
			
			if [ ! -d "$image_files_directory"/files ]; then
				mkdir										\
					--verbose								\
					"$image_files_directory"/files
			fi
			
			files_download="downloads/"
			
			if [ ! -d "$files_download" ]; then
				mkdir									\
					--verbose							\
					"$files_download"
			fi
			
			build_new_setup
			build_new_source
			owncloud_setup
#			phpmyadmin_setup
			virtualbox_setup
			phpvirtualbox_setup
			
			echo "================================================"
			echo "--Add complete"
			echo "================================================"	
		} >> "$log_file" 2>&1
		removing_misc() {														# Remove Misc Files/Folders
			echo "================================================"
			echo "--Remove unneeded files..."
			echo "================================================"
			rm													\
				--verbose										\
				--recursive										\
				--force											\
				"$image_files_directory"/css/					\
				"$image_files_directory"/doc/					\
				"$image_files_directory"/pics/
			rm													\
				--verbose										\
				--force											\
				"$image_files_directory"/autorun.inf			\
				"$image_files_directory"/README.html			\
				"$image_files_directory"/README.mirrors.html	\
				"$image_files_directory"/README.mirrors.txt		\
				"$image_files_directory"/README.source			\
				"$image_files_directory"/README.txt				\
				"$image_files_directory"/setup.exe
			echo "================================================"
			echo "--Remove complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		create_new_md5sum() {													# Create new md5sum file
			echo "================================================"
			echo "--Fixing md5sum file..."
			echo "================================================"
			cd "$image_files_directory"
			md5sum `find -follow -type f` > md5sum.txt
			cd ..
			echo "================================================"
			echo "--Md5sum file fixed"
			echo "================================================"
		} >> "$log_file" 2>&1
		create_iso_image() {													# Creating Bootable ISO Image
			echo "================================================"
			echo "--Removing old Preseed Image..."
			echo "================================================"
			rm												\
				--verbose									\
				"$1"
			echo "================================================"
			echo "--Removal complete"
			echo "================================================"
			
			echo "================================================"
			echo "--Creating ISO Image..."
			echo "================================================"
			genisoimage										\
				-verbose									\
				-rational-rock								\
				-joliet										\
				-eltorito-boot isolinux/isolinux.bin		\
				-eltorito-catalog isolinux/boot.cat			\
				-no-emul-boot								\
				-boot-load-size 4							\
				-boot-info-table							\
				-input-charset utf-8						\
				-output "$1" "$image_files_directory"
			echo "================================================"
			echo "--Image complete"
			echo "================================================"
			
			echo "================================================"
			echo "--Making Image Bootable..."
			echo "================================================"
			isohybrid										\
				--verbose									\
				"$1"
			echo "================================================"
			echo "--Image complete"
			echo "================================================"
		} >> "$log_file" 2>&1
		
		clean_isofiles_directory
		extract_iso_file ""$images_directory""$isoimage"" "$iso_files_directory"
	}

###############################
##   Virtual Machine Setup   ##
###############################


###############################
##   Exit Clean Up           ##
###############################
	exit_program() {
		if [ -f ""$images_directory"MD5SUMS" ]; then							# If MD5SUMS exist, remove
			log_everything "INFO" "Remove old MD5 file"
			rm									\
				--verbose						\
				""$images_directory"MD5SUMS"
			log_everything "INFO" "Remove old MD5 file complete"
		fi

#		if [ -d "$temp_directory" ]; then										# If temp directory exist, remove
#			rm											\
#				--verbose								\
#				--force									\
#				--recursive								\
#				"$temp_directory"
#		fi
	}

###############################
##   Menus                   ##
###############################
	title_header() {															# Title Header
		RED='\033[0;41;30m'														# Red Text Color
		GREEN='\033[0;42;30m'													# Green Text Color
		YELLOW='\033[0;43;30m'													# Yellow Text Color
		STD='\033[0;0;39m'														# Standard Text Color
		BOLD='\e[1m'															# Bold Text
		BLINK='\e[5m'															# Blinking Text?
		DIM='\e[2m'																# Dim Text
		local line1 line2 line3 current_header_status
		line1="o342"
		line2="o226"
		line3="o200"
		max_width=$(tput cols)													# Screen Width
		line=$(printf "%*s\\n" "${COLUMNS:-$max_width}" '' | sed 's/ /\'$line1'\'$line2'\'$line3'/g')
		main_title="$top_title $build_version"									# Main Title
		title_width=$(echo -n "$main_title" | wc -c)							# Title Width
		((title_position = max_width / 2 - (title_width / 2)))					# Center Title Alignment
		clear																	# Clear screen
		tput clear																# Title Header Layout
		tput cup 0 0				; printf "%s" "$line"						# Display line
		tput cup 1 $title_position	; echo -e "${BOLD}$main_title${STD}"		# Display title and version
		tput cup 2 0				; printf "%s" "$line"						# Display line
	}
	pause_menu() {																# Pause Option
		read -p "Press [Enter] key to continue..." fackEnterKey
    }
	yes_or_no() {																# Yes or No Option
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
	menu_line() {
		# Column Alignment
		c1=1																	# Menu Column
		c2=42																	# Status "Left" Column
		c3=60																	# Status "Right" Column
		
		next_row() {
			rstart=3
			rnew=0
			rstep=1
			if [ "$1" == "first" ]; then
				r1=$(( "$rstart" + "$rnew"))
			else
				r1=$(( "$r1" + "$rstep"))
			fi
		}
		
		next_line() {
			lstart=1
			lnew=0
			lstep=1
			if [ "$1" == "first" ]; then
				l1=$(( "$lstart" + "$lnew"))
			else
				l1=$(( "$l1" + "$lstep"))
			fi			
		}
		
		if [ "$1" == "skip_line" ]; then
			next_row
		elif [ "$1" == "new_line" ]; then
			next_row "first"
			next_line "first"
		else
			if [ "$1" == "option" ]; then
				tput cup "$r1" "$c1";	echo "$2";	next_row
			elif [ "$1" == "status_line" ]; then
				tput cup "$r1" "$c2";	echo "$2";	tput cup "$r1" "$c3";	echo "$3";	next_row
			fi
		fi
	}
	
	image_build_menu() {
		local choice
		
		title_header
		
		menu_line "new_line"
		menu_line "option" "$(echo -e "${BOLD}Debian Build Image Options: ${STD}")"
		menu_line "option" "1) Multi Arch Net Install"
		menu_line "option" "2) Multi Arch Firmware Net Install"
		menu_line "skip_line"
		menu_line "option" "3) i386 Net Install"
		menu_line "option" "4) i386 Firmware Net Install"
		menu_line "option" "5) i386 DVDs"
		menu_line "option" "6) i386 Firmware DVD"
		menu_line "skip_line"
		menu_line "option" "7) amd64 Net Install"
		menu_line "option" "8) amd64 Firmware Net Install"
		menu_line "option" "9) amd64 DVDs"
		menu_line "option" "0) amd64 Firmware DVD"
		menu_line "skip_line"
		menu_line "option" "B) Back"
		menu_line "option" "Q) Quit"
		menu_line "skip_line"
		tput cup "$r1" "$c1"; read -n 1 -p ": " choice
		case $choice in
			1)
				title_header
				build_debian_image "multiarchnet"
				image_build_menu
			;;
			2)
				title_header
				build_debian_image "multiarchfirmnet"
				image_build_menu
			;;
			3)
				title_header
				build_debian_image "i386netinst"
				image_build_menu
			;;
			4)
				title_header
				build_debian_image "i386firmnet"
				image_build_menu
			;;
			5)
				title_header
				build_debian_image "i386dvds"
				image_build_menu
			;;
			6)
				title_header
				build_debian_image "i386firmdvd"
				image_build_menu
			;;
			7)
				title_header
				build_debian_image "amd64netinst"
				image_build_menu
			;;
			8)
				title_header
				build_debian_image "amd64firmnet"
				image_build_menu
			;;
			9)
				title_header
				build_debian_image "amd64dvds"
				image_build_menu
			;;
			0)
				title_header
				build_debian_image "amd64firmdvd"
				image_build_menu
			;;
			b|B)
				title_header
				main_menu
			;;
			q|Q)
				clear
				exit_program
				exit 0
			;;
			*)
				echo -e "${RED}**Invalid Option**${STD}"
				sleep 0.3
				image_build_menu
			;;
		esac
		wait

	}
	download_menu() {															# Download Menu
		local choice
		
		title_header
		
		menu_line "new_line"
		menu_line "status_line" "$(echo -e "${BOLD}Debian Site:${STD}")" "$(echo -e "$connection_status")"
		menu_line "status_line" "$(echo -e "${BOLD}Current Version:${STD}")" ""$debian_current_version" (R)efresh"
		
		menu_line "new_line"
		menu_line "option" "$(echo -e "${BOLD}Debian ISO Images${STD}")"
		menu_line "option" "1) Multi Arch Net Install"
		menu_line "option" "2) Multi Arch Firmware Net Install"
		menu_line "skip_line"
		menu_line "option" "3) i386 Net Install"
		menu_line "option" "4) i386 Firmware Net Install"
		menu_line "option" "5) i386 DVDs"
		menu_line "option" "6) i386 Firmware DVD"
		menu_line "skip_line"
		menu_line "option" "7) amd64 Net Install"
		menu_line "option" "8) amd64 Firmware Net Install"
		menu_line "option" "9) amd64 DVDs"
		menu_line "option" "0) amd64 Firmware DVD"
		menu_line "skip_line"
		menu_line "option" "F) Firmware Files"
		menu_line "skip_line"
		menu_line "option" "B) Back"
		menu_line "option" "Q) Quit"
		menu_line "skip_line"
		tput cup "$r1" "$c1"; read -n 1 -p ": " choice
		case $choice in
			r|R)
				title_header
				version_check
				download_menu
			;;
			1)
				title_header
				debian_download_manager "multiarchnet"
				download_menu
			;;
			2)
				title_header
				debian_download_manager "multiarchfirmnet"
				download_menu
			;;
			3)
				title_header
				debian_download_manager "i386netinst"
				download_menu
			;;
			4)
				title_header
				debian_download_manager "i386firmnet"
				download_menu
			;;
			5)
				title_header
				debian_download_manager "i386dvds"
				download_menu
			;;
			6)
				title_header
				debian_download_manager "i386firmdvd"
				download_menu
			;;
			7)
				title_header
				debian_download_manager "amd64netinst"
				download_menu
			;;
			8)
				title_header
				debian_download_manager "amd64firmnet"
				download_menu
			;;
			9)
				title_header
				debian_download_manager "amd64dvds"
				download_menu
			;;
			0)
				title_header
				debian_download_manager "amd64firmdvd"
				download_menu
			;;
			f|F)
				title_header
				debian_download_manager "firmware"
				download_menu
			;;
			b|B)
				title_header
				main_menu
			;;
			q|Q)
				clear
				exit_program
				exit 0
			;;
			*)
				echo -e "${RED}**Invalid Option**${STD}"
				sleep 0.3
				download_menu
			;;
		esac
		wait

	}
	main_menu() {																# Main Menu
		local choice
		
		title_header
		
		menu_line "new_line"
		menu_line "option" "$(echo -e "${BOLD}Options:${STD}")"
		menu_line "option" "D) Download Manager"
		menu_line "option" "P) Preseed Builder"
#		menu_line "option" "S) Setup First Boot Setup"
		menu_line "option" "I) ISO Image Builder"
#		menu_line "option" "V) Virtual Machine Tester"
		menu_line "skip_line"
		menu_line "option" "Q) Quit"
		menu_line "skip_line"
		tput cup "$r1" "$c1"; read -n 1 -p ": " choice
		case $choice in
			d|D)
				title_header
				version_check
				download_menu
				main_menu
			;;
			p|P)
				title_header
				preseed_builder
				pause_menu
				main_menu
			;;
			s|S)
				title_header
				main_menu
			;;
			i|I)
				title_header
				image_build_menu
				main_menu
			;;
			v|V)
				title_header
				main_menu
			;;
			q|Q)
				clear
				exit_program
				exit 0
			;;
			*)
				echo -e "${RED}**Invalid Option**${STD}"
				sleep 0.3
				main_menu
			;;
		esac
		wait
	}

startup_check
main_menu

exit 1
