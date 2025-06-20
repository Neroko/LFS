#!/bin/bash

function autoSetup() {
	titleHeader
	echo Empty
	pressAnyKey
}

function partitionDrive() {
	titleHeader
	masterRoot=$(mount | grep "/ " | awk '{print $1}')
	diskList=$(fdisk -l | grep "/dev/sd[a-z]:" | awk '{print $2 " " $3 " " $4}' | cut -d"," -f1)
	echo "Drives Found:"
	echo "$diskList"
	printf $line
	read -p "Select Drive: " -e -i "/dev/sdb" USERINPUT
	if [[ "$USERINPUT" == "/dev/sd"* ]]; then
		LFS_DRIVE=$USERINPUT
		{ LFS_DSIZE=$(fdisk -l $LFS_DRIVE | grep "GiB" | cut -f 3 -d ' ' | cut -f 1 -d '.'); } &> /dev/null
		echo "Found $LFS_DSIZE GB hard drive at $LFS_DRIVE"
		if [ "$LFS_DSIZE" -lt "20" ]; then
			echo "Hard Drive to small"
			pressAnyKey
			partitionDrive
		fi
		pressAnyKey
	else
		echo
		tput bold; echo "Invalid Drive"; tput sgr0
		sleep 1.0
	fi
}

function mountPartition() {
	titleHeader

	if [ ! -d "$LFS" ]; then
		mkdir -pv $LFS											# Create LFS Mount Location
		echo "LFS Location Created"
	fi

	mount -v -t ext4 /dev/sdb2 $LFS				# Mount Root Partition
	echo "LFS Location Mounted"

	if [ ! -d "$LFS/boot" ]; then
		mkdir -pv $LFS/boot									# Create LFS Boot Mount Location
		echo "LFS Boot Location Created"
	fi

	mount -v -t ext4 /dev/sdb1 $LFS/boot	# Mount Boot Partition
	echo "LFS Boot Location Mounted"

	/sbin/swapon -v /dev/sdb3							# Enable Swap Partition
	echo "LFS Swap Location Mounted"

	pressAnyKey
}

function setupDirectorys() {
	if [ ! -d "$LFS_SOURCES" ]; then
		mkdir -v $LFS_SOURCES								# Create LFS Source Directory
	fi
	chmod -v a+wt $LFS_SOURCES
	if [ ! -d "$LFS_TOOLS" ]; then
		mkdir -v $LFS_TOOLS									# Create LFS Tools Directory
	fi
	ln -sv $LFS_TOOLS /

	pressAnyKey
}

function installPackages() {
	titleHeader

	function siteCheck() {
		if [[ "$(ping -c $siteChecks $internetCheckSite | grep '100% packet loss')" != "" ]]; then
			internetStatus=0
		else
			internetStatus=1
		fi

		if [[ "$(ping -c $siteChecks $siteCheckSite | grep '100% packet loss')" != "" ]]; then
			siteStatus=0
		else
			siteStatus=1
		fi
	}

	function fileExist() {
		if [ ! -e "$packagesArchive" ]; then
			archiveFileExist=0
		else
			archiveFileExist=1
		fi
	}

	function downloadArchive() {
		if [[ "$internetStatus" == 1 && "$siteStatus" == 1 ]]; then
			echo "Connected"
			# { packageStatus=$(wget --spider $packagesDownload | head -n1 | grep 'Length'); } &> /dev/null
			#echo "$packageStatus"
			#echo "Test 2"
			#wget --spider $packagesDownload | grep 'Length'
			fileExist
			if [[ "$archiveFileExist" == 1 ]]; then
				rm -rf $packagesArchive
			fi
			printf "Downloading"
			(wget $packagesDownload -P downloads) &> /dev/null &
			spinner $!
			chown tj:tj $packagesArchive
		fi
	}

	pressAnyKey
}

function newUser() {
	# Add LFS User
	groupadd lfs
	useradd -s /bin/bash -g lfs -m -k /dev/null lfs

	pressAnyKey
}

function mainPage() {
  clear
	source setup.sh
}

function mainMenu() {
	titleHeader
	tput cup 3 $c1; echo "1: Auto Setup"
	tput cup 4 $c1; echo "2: Partition Drive(s)";	tput cup 4 $c2; echo "$partitionStatus"
	tput cup 5 $c1; echo "3: Mount Drive(s)";			tput cup 5 $c2; echo "$mountStatus"
	tput cup 6 $c1; echo "4: Create Directories";	tput cup 6 $c2; echo "$directoryStatus"
	tput cup 7 $c1; echo "5: Install Packages";		tput cup 7 $c2; echo "$archiveStatus"
	tput cup 8 $c1; echo "6: Add New User";				tput cup 8 $c2; echo "$userStatus"

  tput cup 10 $c1; echo "m: Main Menu"
	tput cup 11 $c1; echo "q: Quit"
  printf $line
}

readOptions(){
	local choice
	tput cup 13 $c1; read -p "Enter choice: " choice
	case $choice in
		1) autoSetup ;;
		2) partitionDrive ;;
		3) mountPartition ;;
		4) setupDirectorys ;;
		5) installPackages ;;
		6) newUser ;;
    m) mainPage ;;
		q) clear && exit 0 ;;
		*) echo -e "---Invalid Option---" && sleep 0.3
	esac
}

while true
do
	mainMenu
	readOptions
done
