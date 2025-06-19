#!/bin/bash

## 6.3. Ncurses-6.2
# The Ncurses package contains libraries for terminal-independent handling
# of character screens.
#	Approximate build time:	0.7 SBU
#	Required disk space:		48 MB

## 6.3.1. Installation of Ncurses
# First, ensure that gawk is found first during configuration:
#	sed -i s/mawk// configure

# Then, run the following commands to build the “tic” program on the build
# host:
#	mkdir build
#	pushd build
#		../configure
#		make -C include
#		make -C progs tic
#	popd

## Prepare Ncurses for compilation:
#	./configure --prefix=/usr \
#		--host=$LFS_TGT \
#		--build=$(./config.guess) \
#		--mandir=/usr/share/man \
#		--with-manpage-format=normal \
#		--with-shared \
#		--without-debug \
#		--without-ada \
#		--without-normal \
#		--enable-widec

## The meaning of the new configure options:
# --with-manpage-format=normal
# This prevents Ncurses installing compressed manual pages, which may
# happen if the host distribution itself has compressed manual pages.

# --without-ada
# This ensures that Ncurses does not build support for the Ada compiler
# which may be present on the host but will not be available once we enter the
# chroot environment.

# --enable-widec
# This switch causes wide-character libraries (e.g., libncursesw.so.6.2) to be
# built instead of normal ones (e.g., libncurses.so.6.2). These wide-character
# libraries are usable in both multibyte and traditional 8-bit locales, while normal
# libraries work properly only in 8-bit locales. Wide-character and normal
# libraries are source-compatible, but not binary-compatible.

# --without-normal
# This switch disables building and installing most static libraries.

## Compile the package:
#	make

## Install the package:
#	make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
#	echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

##The meaning of the install options:
# TIC_PATH=$(pwd)/build/progs/tic
# We need to pass the path of the just built tic able to run on the building
# machine, so that the terminal database can be created without errors.

# echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
# The libncurses.so library is needed by a few packages we will build soon. We
# create this small linker script, as this is what is done in Chapter 8.

# Details on this package are located in
# Section 8.28.2, “Contents of Ncurses.”

LFS_Sources=""$LFS"/sources"
Package_Filename="ncurses-6.2.tar.gz"
Package_Directory="ncurses-6.2"

Log_Directory=""$LFS"/logs"
Log_Chapter_Number="6-3"
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
echo "<===> LFS Builder - 6.3. Ncurses-6.2 <===>"
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

## Ensure that gawk is found first during configuration:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Finding gawk <=>" | tee -a "$Builder_Log"
sed -i s/mawk// configure | tee -a "$Builder_Log"

## Create build directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Create build directory <=>" | tee -a "$Builder_Log"
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/" | tee -a "$Builder_Log"

## Build the “tic” program on the build host:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Build 'tic' program on build host <=>" | tee -a "$Builder_Log"
pushd build
	../configure | tee -a "$Builder_Log"
	make -C include | tee -a "$Builder_Log"
	make -C progs tic | tee -a "$Builder_Log"
popd

## Enter build directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Enter build directory <=>" | tee -a "$Builder_Log"
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
	--build=$(./config.guess) \
	--mandir=/usr/share/man \
	--with-manpage-format=normal \
	--with-shared \
	--without-debug \
	--without-ada \
	--without-normal \
	--enable-widec \
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

make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install | tee -a "$Package_Install_Log"
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so

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
