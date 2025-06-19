#!/bin/bash

## 6.5. Coreutils-8.32
# The Coreutils package contains utilities for showing and setting the basic
# system characteristics.
#	Approximate build time:	0.6 SBU
#	Required disk space:		151 MB

## 6.5.1. Installation of Coreutils
## Prepare Coreutils for compilation:
#	./configure --prefix=/usr \
#		--host=$LFS_TGT \
#		--build=$(build-aux/config.guess) \
#		--enable-install-program=hostname \
#		--enable-no-install-program=kill,uptime

## The meaning of the configure options:
# --enable-install-program=hostname
# This enables the hostname binary to be built and installed – it is disabled
# by default but is required by the Perl test suite.

## Compile the package:
#	make

## Install the package:
#	make DESTDIR=$LFS install

# Move programs to their final expected locations. Although this is not
# necessary in this temporary environment, we must do so because some
# programs harcode executable locations:
#	mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
#	mkdir -pv $LFS/usr/share/man/man8
#	mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
#	sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8

# Details on this package are located in
# Section 8.53.2, “Contents of Coreutils.”

LFS_Sources=""$LFS"/sources"
Package_Filename="coreutils-8.32.tar.xz"
Package_Directory="coreutils-8.32"

Log_Directory=""$LFS"/logs"
Log_Chapter_Number="6-5"
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
echo "<===> LFS Builder - 6.5. Coreutils-8.32 <===>"
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

## Create and enter build directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Create and enter build directory <=>" | tee -a "$Builder_Log"
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/" | tee -a "$Builder_Log"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

echo "$Long_Line" | tee -a "$Extraction_Log"
echo "Package extract runtime: "$timer_extract_runtime" secs" | tee -a "$Extraction_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Builder Stage"
	exit 1
fi

## Prepare Package for compilation:
echo "$Long_Line" | tee -a "$Package_Prepare_Log"
echo "<=> Prepare Package for compilation <=>" | tee -a "$Package_Prepare_Log"
read -n 1 -s -r -p "Press any key to continue"; echo

timer_prepare_start=`date +%s`

./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess) \
	--enable-install-program=hostname \
	--enable-no-install-program=kill,uptime \
	| tee -a "$Package_Prepare_Log"

timer_prepare_end=`date +%s`
timer_prepare_runtime=$((timer_prepare_end-timer_prepare_start))

echo "$Long_Line" | tee -a "$Package_Prepare_Log"
echo "Prepare Package for compilation runtime: "$timer_prepare_runtime" secs" | tee -a "$Package_Prepare_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Prepare Package for compilation"
	exit 1
fi

## Compile the package:
echo "$Long_Line" | tee -a "$Package_Compile_Log"
echo "<=> Compile the package <=>" | tee -a "$Package_Compile_Log"
read -n 1 -s -r -p "Press any key to continue"; echo

timer_compile_start=`date +%s`

make | tee -a "$Package_Compile_Log"

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

make DESTDIR=$LFS install | tee -a "$Package_Install_Log"

timer_install_end=`date +%s`
timer_install_runtime=$((timer_install_end-timer_install_start))

echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "Install Package runtime: "$timer_install_runtime" secs" | tee -a "$Package_Install_Log"
read -r -p "Continue? [Y/n]: " response
if [[ $response =~ ^[Nn]$ ]]; then
	echo "Exiting at Install package"
	exit 1
fi

# Move programs to their final expected locations:
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Install the package <=>" | tee -a "$Package_Install_Log"
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin | tee -a "$Package_Install_Log"
mkdir -vp $LFS/usr/share/man/man8 | tee -a "$Package_Install_Log"
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8 | tee -a "$Package_Install_Log"
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8 | tee -a "$Package_Install_Log"

## Cleanup old package directory:
if [ -d ""$LFS_Sources"/"$Package_Directory"" ]; then
	echo "$Long_Line" | tee -a "$Ending_Cleanup_Log"
	echo "<=> Remove old package directory <=>" | tee -a "$Ending_Cleanup_Log"
	rm -vrf ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Ending_Cleanup_Log"
fi

exit 0
