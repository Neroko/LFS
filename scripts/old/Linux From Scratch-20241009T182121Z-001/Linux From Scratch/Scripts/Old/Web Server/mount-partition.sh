#!/bin/bash

rootPartition="/mnt/lfs"
bootPartition="$rootPartition/boot"
homePartition="$rootPartition/home"

function mountPartition() {
	if [ ! -d "$2" ]; then
		mkdir -v $2
	fi
	mount -v -t ext4 $1 $2
}

clear
df -h
echo "--------------------"
mountPartition /dev/sdb3 $rootPartition
mountPartition /dev/sdb1 $bootPartition
mountPartition /dev/sdb5 $homePartition

/sbin/swapon -v /dev/sdb2
echo "--------------------"
df -h
echo "--------------------"
