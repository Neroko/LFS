#!/bin/bash/ 

## 5.5. Glibc-2.34
# The Glibc package contains the main C library. This library
# provides the basic routines for allocating memory, searching
# directories, opening and closing files, reading and writing
# files, string handling, pattern matching, arithmetic, and so on.
#	Approximate build time:	4.2 SBU
#	Required disk space:		744 MB

## 5.5.1. Installation of Glibc
# First, create a symbolic link for LSB compliance. Additionally, for
# x86_64, create a compatibility symbolic link required for proper
# operation of the dynamic library loader:
#	case $(uname -m) in
#		i?86) ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
#		;;
#		x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
#			ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
#		;;
#	esac

## Some of the Glibc programs use the non-FHS compliant /var/db
# directory to store their runtime data. Apply the following patch to make
# such programs store their runtime data in the FHS-compliant locations:
#	patch -Np1 -i ../glibc-2.34-fhs-1.patch

## The Glibc documentation recommends building Glibc in a dedicated build
# directory:
#	mkdir -v build
#	cd build

## Ensure that the ldconfig and sln utilites are installed into /usr/sbin:
#	echo "rootsbindir=/usr/sbin" > configparms

## Next, prepare Glibc for compilation:
#	../configure \
#		--prefix=/usr \
#		--host=$LFS_TGT \
#		--build=$(../scripts/config.guess) \
#		--enable-kernel=3.2 \
#		--with-headers=$LFS/usr/include \
#		libc_cv_slibdir=/usr/lib

##The meaning of the configure options:
# --host=$LFS_TGT, --build=$(../scripts/config.guess)
# The combined effect of these switches is that Glibc's build system
# configures itself to be cross-compiled, using the cross-linker and
# cross-compiler in $LFS/tools.

# --enable-kernel=3.2
# This tells Glibc to compile the library with support for 3.2 and later Linux
# kernels. Workarounds for older kernels are not enabled.

# --with-headers=$LFS/usr/include
# This tells Glibc to compile itself against the headers recently installed to
# the $LFS/usr/include directory, so that it knows exactly what features
# the kernel has and can optimize itself accordingly.

# libc_cv_slibdir=/usr/lib
# This ensures that the library is installed in /usr/lib instead of the default
# /lib64 on 64 bit machines.

# During this stage the following warning might appear:
#	configure: WARNING:
#	*** These auxiliary programs are missing or
#	*** incompatible versions: msgfmt
#	*** some features will be disabled.
#	*** Check the INSTALL file for required versions.

# The missing or incompatible msgfmt program is generally harmless.
# This msgfmt program is part of the Gettext package which the host
# distribution should provide.

## Note
# There have been reports that this package may fail when building as a
# "parallel make". If this occurs, rerun the make command with a "-j1" option.

## Compile the package:
#	make

## Install the package:
# Warning
# If LFS is not properly set, and despite the recommendations, you are
# building as root, the next command will install the newly built glibc to
# your host system, which most likely will render it unusable. So double
# check that the environment is correctly set, before running the following
# command.
#	make DESTDIR=$LFS install

# The meaning of the make install option:
#	DESTDIR=$LFS
# The DESTDIR make variable is used by almost all packages to define the
# location where the package should be installed. If it is not set, it defaults
# to the root (/) directory. Here we specify that the package be installed in
# $LFS, which will become the root after Section 7.4, “Entering the Chroot
# Environment”.

## Fix hardcoded path to the executable loader in ldd script:
#	sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd

## Caution
# At this point, it is imperative to stop and ensure that the basic functions
# (compiling and linking) of the new toolchain are working as expected. To
# perform a sanity check, run the following commands:
#	echo 'int main(){}' > dummy.c
#	$LFS_TGT-gcc dummy.c
#	readelf -l a.out | grep '/ld-linux'

# If everything is working correctly, there should be no errors, and the output
# of the last command will be of the form:
#	[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]

# Note that for 32-bit machines, the interpreter name will be /lib/ld-linux.so.2.
# If the output is not shown as above or there was no output at all, then
# something is wrong. Investigate and retrace the steps to find out where the
# problem is and correct it. This issue must be resolved before continuing on.

## Once all is well, clean up the test files:
#	rm -v dummy.c a.out

## Note
# Building packages in the next chapter will serve as an additional check that
# the toolchain has been built properly. If some package, especially
# binutils-pass2 or gcc-pass2, fails to build, it is an indication that something
# has gone wrong with the previous Binutils, GCC, or Glibc installations.

## Now that our cross-toolchain is complete, finalize the installation of the
# limits.h header. For doing so, run a utility provided by the GCC developers:
#	$LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

# Details on this package are located in
# Section 8.5.3, “Contents of Glibc.”

LFS_Sources=""$LFS"/sources"
Package_Filename="glibc-2.34.tar.xz"
Package_Directory="glibc-2.34"
Patch_Filename="glibc-2.34-fhs-1.patch"

Log_Directory=""$LFS"/logs"
Log_Chapter_Number="5-5"
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
echo "<===> LFS Builder - 5.5 Glibc-2.34 <===>"
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

## 64 Bit Check
case $(uname -m) in
	i?86)
		echo "$Long_Line" | tee -a "$Builder_Log"
		echo "<=> 32 Bit Check <=>" | tee -a "$Builder_Log"
		ln -vsf ld-linux.so.2 $LFS/lib/ld-lsb.so.3 | tee -a "$Builder_Log"
	;;
	x86_64)
		echo "$Long_Line" | tee -a "$Builder_Log"
		echo "<=> 64 Bit Check <=>" | tee -a "$Builder_Log"
		ln -vsf ../lib/ld-linux-x86-64.so.2 $LFS/lib64 | tee -a "$Builder_Log"
		ln -vsf ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3 | tee -a "$Builder_Log"
	;;
esac

## Apply Patch
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Apply Patch <=>" | tee -a "$Builder_Log"
patch -Np1 -i ""$LFS_Sources"/"$Patch_Filename"" | tee -a "$Builder_Log"

## Create and enter build directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Create and enter build directory <=>" | tee -a "$Builder_Log"
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/" | tee -a "$Builder_Log"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Ensure that the ldconfig and sln utilites are installed into /usr/sbin:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Ensure that the ldconfig and sln utilites are installed into /usr/sbin <=>" | tee -a "$Builder_Log"
echo "rootsbindir=/usr/sbin" > configparms | tee -a "$Builder_Log"

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

../configure \
	--prefix=/usr \
	--host=$LFS_TGT \
	--build=$(../scripts/config.guess) \
	--enable-kernel=3.2 \
	--with-headers=$LFS/usr/include \
	libc_cv_slibdir=/usr/lib \
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

## Fix hardcoded path to the executable loader in ldd script:
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Fix hardcoded path to the executable loader in ldd script <=>" | tee -a "$Package_Install_Log"
sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd | tee -a "$Package_Install_Log"

## Cross-Toolchain Test
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Cross-Toolchain Test <=>" | tee -a "$Package_Install_Log"
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep '/ld-linux' | tee -a "$Package_Install_Log"

## Clean up the test files:
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Clean up the test files <=>" | tee -a "$Package_Install_Log"
rm -v dummy.c a.out | tee -a "$Package_Install_Log"

## Finalize the installation of the limits.h header. Run utility
# provided by the GCC developers:
echo "$Long_Line" | tee -a "$Package_Install_Log"
echo "<=> Finalize the installation of the limits.h header <=>" | tee -a "$Package_Install_Log"
$LFS/tools/libexec/gcc/$LFS_TGT/11.2.0/install-tools/mkheaders

## Cleanup old package directory:
if [ -d ""$LFS_Sources"/"$Package_Directory"" ]; then
	echo "$Long_Line" | tee -a "$Ending_Cleanup_Log"
	echo "<=> Remove old package directory <=>" | tee -a "$Ending_Cleanup_Log"
	rm -vrf ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Ending_Cleanup_Log"
fi

exit 0
