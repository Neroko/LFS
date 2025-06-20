#!/bin/bash

clear

export LFS='/mnt/lfs'

if [ "$UID" -ne "$ROOT_UID" ]; then
	root_status="non-root"
else
	root_status="root"
fi

function partitionDrive() {
	masterRoot=$(mount | grep "/ " | awk '{print $1}')
	echo "Root Drive: "$masterRoot", don't OVERWRITE drive, working from!!"
	diskList=$(fdisk -l | grep "/dev/sd[a-z]:" | awk '{print $2 " " $3 " " $4}' | cut -d"," -f1)
	echo "Drives Found:"
	echo "$diskList"
	read -p "Select Drive: " -e -i "/dev/sd[b]" USERINPUT
	if [[ "$USERINPUT" == "/dev/sd"* ]]; then
		LFS_DRIVE=$USERINPUT
		LFS_DSIZE=$(fdisk -l $LFS_DRIVE | grep "GiB" | cut -f 3 -d ' ' | cut -f 1 -d '.')
		echo "Found $LFS_DSIZE GB hard drive at $LFS_DRIVE"
		if [ "$LFS_DSIZE" -lt "20" ]; then
			echo "Hard Drive to small"
			sleep 1.0
			partitionDrive
		fi
	else
		echo "Invalid Drive"
		sleep 1.0
	fi
}

function mountPartition() {
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
}

partitionDrive
