#!/bin/bash

## 5.4. Linux-5.13.12 API Headers
# The Linux API Headers (in linux-5.13.12.tar.xz) expose the
# kernel's API for use by Glibc.
#	Approximate build time:		0.1 SBU
#	Required disk space:		1.2 GB

## 5.4.1. Installation of Linux API Headers
# The Linux kernel needs to expose an Application Programming
# Interface (API) for the system's C library (Glibc in LFS) to use.
# This is done by way of sanitizing various C header files that are
# shipped in the Linux kernel source tarball.

## Make sure there are no stale files embedded in the package:
#	make mrproper

## Now extract the user-visible kernel headers from the source. The
# recommended make target “headers_install” cannot be used, because
# it requires rsync, which may not be available. The headers are
# first placed in ./usr, then copied to the needed location.
#	make headers
#	find usr/include -name '.*' -delete
#	rm usr/include/Makefile
#	cp -rv usr/include $LFS/usr

## 5.4.2. Contents of Linux API Headers
# Installed headers:
#	/usr/include/asm/*.h, /usr/include/asm-generic/*.h,
#	/usr/include/drm/*.h, /usr/include/, linux/*.h, /usr/include
#	misc/*.h, /usr/include/mtd/*.h, /usr/include/rdma/*.h, /usr/,
#	include/scsi/*.h, /usr/include/sound/*.h, /usr/include/video
#	*.h, and /usr/include/xen/*.h
# Installed directories:
#	/usr/include/asm, /usr/include/asm-generic, /usr/include/drm,
#	/usr/include/linux, /usr/, include/misc, /usr/include/mtd,
#	/usr/include/rdma, /usr/include/scsi, /usr/include/sound, /
#	usr/include/video, and /usr/include/xen

## Short Descriptions
#	/usr/include/asm/*.h		 The Linux API ASM Headers
#	/usr/include/asm-generic/*.h The Linux API ASM Generic Headers
#	/usr/include/drm/*.h		 The Linux API DRM Headers
#	/usr/include/linux/*.h		 The Linux API Linux Headers
#	/usr/include/misc/*.h		 The Linux API Miscellaneous Headers
#	/usr/include/mtd/*.h		 The Linux API MTD Headers
#	/usr/include/rdma/*.h		 The Linux API RDMA Headers
#	/usr/include/scsi/*.h		 The Linux API SCSI Headers
#	/usr/include/sound/*.h		 The Linux API Sound Headers
#	/usr/include/video/*.h		 The Linux API Video Headers
#	/usr/include/xen/*.h		 The Linux API Xen Headers

LFS_Sources=""$LFS"/sources"
Package_Filename="linux-5.13.12.tar.xz"
Package_Directory="linux-5.13.12"

Log_Directory=""$LFS"/logs"
Log_Chapter_Number="5-4"
Startup_Cleanup_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log0-startup-cleanup.log"
Extraction_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log1-extraction.log"
Builder_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log2-builder.log"
Package_Prepare_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log3-package-prepare.log"
Package_Compile_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log4-package-compile.log"
Package_Install_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log5-package-install.log"
Ending_Cleanup_Log=""$Log_Directory"/lfs-chapter-"$Log_Chapter_Number"-log6-ending-cleanup.log"

## Clean old logs:
rm -v \
	"$Startup_Cleanup_Log" \
	"$Extraction_Log" \
	"$Builder_Log" \
	"$Package_Prepare_Log" \
	"$Package_Compile_Log" \
	"$Package_Install_Log" \
	"$Ending_Cleanup_Log"

Long_Line="-------------------------------------------------------"

clear

echo "$Long_Line"
echo "<===> LFS Builder - 5.4 Linux-5.13.12 API Headers <===>"
echo "$Long_Line"
read -n 1 -s -r -p "Press any key to continue"; echo

## Cleanup old package directory:
if [ -d ""$LFS_Sources"/"$Package_Directory"" ]; then
	echo "$Long_Line" | tee -a "$Startup_Cleanup_Log"
	echo "<=> Remove old package directory <=>" | tee -a "$Startup_Cleanup_Log"
	rm -vrf ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Startup_Cleanup_Log"
fi

timer_extract_start=`date +%s`

## Extract Package:
if [[ ""$LFS_Sources"/"$Package_Filename"" == *.gz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxzf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/" | tee -a "$Extraction_Log"
elif [[ ""$LFS_Sources"/"$Package_Filename"" == *.xz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/" | tee -a "$Extraction_Log"
fi

timer_extract_end=`date +%s`
timer_extract_runtime=$((timer_extract_end-timer_extract_start))

## Enter package directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Enter package directory <=>" | tee -a "$Builder_Log"
cd ""$LFS_Sources"/"$Package_Directory"/"

echo "$Long_Line" | tee -a "$Extraction_Log"
echo "Package extract runtime: "$timer_extract_runtime" secs" | tee -a "$Extraction_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Builder Stage"
	exit 1
fi

## Compile the package:
echo "$Long_Line" | tee -a "$Package_Compile_Log"
echo "<=> Compile the package <=>" | tee -a "$Package_Compile_Log"
read -n 1 -s -r -p "Press any key to continue"; echo

timer_compile_start=`date +%s`

make mrproper | tee -a "$Package_Compile_Log"

timer_compile_end=`date +%s`
timer_compile_runtime=$((timer_compile_end-timer_compile_start))

echo "$Long_Line" | tee -a "$Package_Compile_Log"
echo "Compile Package runtime: "$timer_compile_runtime" secs" | tee -a "$Package_Compile_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Compile package"
	exit 1
fi

## Install the package:
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Install the package <=>" | tee -a "$Package_Install_Log"
read -n 1 -s -r -p "Press any key to continue"; echo

timer_install_start=`date +%s`

make headers | tee -a "$Package_Install_Log"
find usr/include -name '.*' -delete
rm -v usr/include/Makefile | tee -a "$Package_Install_Log"
cp -rv usr/include $LFS/usr | tee -a "$Package_Install_Log"

timer_install_end=`date +%s`
timer_install_runtime=$((timer_install_end-timer_install_start))

echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "Install Package runtime: "$timer_install_runtime" secs" | tee -a "$Package_Install_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Install package"
	exit 1
fi

## Cleanup old package directory:
if [ -d ""$LFS_Sources"/"$Package_Directory"" ]; then
	echo "$Long_Line" | tee -a "$Ending_Cleanup_Log"
	echo "<=> Remove old package directory <=>" | tee -a "$Ending_Cleanup_Log"
	rm -vrf ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Ending_Cleanup_Log"
fi

exit 0
