#!/bin/bash

function prep() {
	LFS=/mnt/lfs					# LFS drive location
	LFS_SOURCES=$LFS/sources			# LFS source files location
	LFS_TOOLS=$LFS/tools				# LFS tools files location
	LFS_ARCHIVE=none				# Archive file location
	LFS_PACKAGE=none				# LFS unpacked package location
	LOG=$LFS_SOURCES/pass1/logs/cleaner.log		# Log location
	BIT3264=$(uname -m) &> /dev/null		# Check if 32 or 64 bit system
}

function logger() {
	if [ ! -f "$LOG" ]; then			# If log file doesnt exist, create it
		`touch $LOG`
	else						# Else delete old and create new
		`rm -rf $LOG`
		`touch $LOG`
	fi
}

function cleanUp() {
	if [ -d "$LFS_PACKAGE" ]; then
		`rm -rf $LFS_PACKAGE`			# Delete old package
	fi
}

function logGrab() {
	LOG_GRAB=$(grep "real" $LOG | awk '{print $2}')
}

function INFO() {
	local function_name="${FUNCNAME[1]}"
		local msg="$1"
		timeAndDate=$(date)
		echo "[$timeAndDate]  [INFO]  $msg" >> $LOG
}

function DEBUG() {
	local function_name="${FUNCNAME[1]}"
		local msg="1"
		timeAndDate=$(date)
		echo "[$timeAndDate]  [DEBUG]  $msg" >> $LOG
}

function ERROR() {
	local function_name="${FUNCNAME[1]}"
		local msg="1"
		timeAndDate=$(date)
		echo "[$timeAndDate]  [ERROR]  $msg" >> $LOG
}

function cleanDir() {					# Delete all files out of LFS tools folder
	{
		time {
			INFO "Cleaning out LFS Tools folder..."
			`rm -rf $LFS_TOOLS/* | tee -a $LOG`
			INFO "Complete"
		}
	} 2>&1 | tee -a $LOG &> /dev/null
}

prep
logger
INFO "Starting..."
INFO "System: $BIT3264"
echo "------------------------------"
echo " Emptying Tools Folder..."
cleanDir
logGrab
echo "------------------------------"
echo " Complete - $LOG_GRAB"
echo "------------------------------"
INFO "Done"
