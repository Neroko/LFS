#!/bin/bash

function prep() {
	LFS=/mnt/lfs					# LFS drive location
	LFS_SOURCES=$LFS/sources			# LFS source files location
	LFS_TOOLS=$LFS/tools
	LFS_ARCHIVE=$LFS_SOURCES/binutils-2.27.tar.bz2	# Archive file location
	LFS_PACKAGE=$LFS_SOURCES/binutils-2.27		# LFS unpacked package location
	LOG=$LFS_SOURCES/pass1/logs/5.4-binutils.log	# Log location
	BIT3264=$(uname -m) &> /dev/null		# Check if 32 or 64 system
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
	# Add if location exist, delete
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

function extract() {					# Extracting Files from Archive
	{
		time {
			INFO "Extracting Files"
			`tar -xjf $LFS_ARCHIVE -C $LFS_SOURCES | tee -a $LOG`
			INFO "Extraction Complete"
		}
	} 2>&1 | tee -a $LOG &> /dev/null
}

prep
logger
cleanUp
INFO "Starting..."
INFO "System: $BIT3264"
echo "------------------------------"
echo " Binutils 2.27 - Pass 1"
echo "------------------------------"
echo " - Extracting Files..."
extract

logGrab
echo "------------------------------"
echo " Complete - $LOG_GRAB"
echo "------------------------------"
INFO "Done"
