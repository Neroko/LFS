#!/bin/bash

## 5.3. GCC-11.2.0 - Pass 1
# The GCC package contains the GNU compiler collection, which
# includes the C and C++ compilers.
#	Approximate build time:		12 SBU
#	Required disk space:		3.4 GB

## 5.3.1. Installation of Cross GCC
# GCC requires the GMP, MPFR and MPC packages. As these packages
# may not be included in your host distribution, they will be built
# with GCC. Unpack each package into the GCC source directory and
# rename the resulting directories so the GCC build procedures will
# automatically use them:

## Note
# There are frequent misunderstandings about this chapter. The
# procedures are the same as every other chapter as explained
# earlier (Package build instructions). First extract the gcc
# tarball from the sources directory and then change to the
# directory created. Only then should you proceed with the
# instructions below.
#	tar -xf ../mpfr-4.1.0.tar.xz
#	mv -v mpfr-4.1.0 mpfr
#	tar -xf ../gmp-6.2.1.tar.xz
#	mv -v gmp-6.2.1 gmp
#	tar -xf ../mpc-1.2.1.tar.gz
#	mv -v mpc-1.2.1 mpc

# On x86_64 hosts, set the default directory name for 64-bit
# libraries to “lib”:
#	case $(uname -m) in
#		x86_64)
#			sed -e '/m64=/s/lib64/lib/' \
#				-i.orig gcc/config/i386/t-linux64
#		;;
#	esac

# The GCC documentation recommends building GCC in a dedicated
# build directory:
#	mkdir -v build
#	cd build

## Prepare GCC for compilation:
#	../configure \
#		--target=$LFS_TGT \
#		--prefix=$LFS/tools \
#		--with-glibc-version=2.11 \
#		--with-sysroot=$LFS \
#		--with-newlib \
#		--without-headers \
#		--enable-initfini-array \
#		--disable-nls \
#		--disable-shared \
#		--disable-multilib \
#		--disable-decimal-float \
#		--disable-threads \
#		--disable-libatomic \
#		--disable-libgomp \
#		--disable-libquadmath \
#		--disable-libssp \
#		--disable-libvtv \
#		--disable-libstdcxx \
#		--enable-languages=c,c++

## The meaning of the configure options:
# --with-glibc-version=2.11
# This option ensures the package will be compatible with the
# host's version of glibc. It is set to the minimum glibc
# requirement specified in the Host System Requirements.

# --with-newlib
# Since a working C library is not yet available, this ensures that
# the inhibit_libc constant is defined when building libgcc. This
# prevents the compiling of any code that requires libc support.

# --without-headers
# When creating a complete cross-compiler, GCC requires standard
# headers compatible with the target system. For our purposes these
# headers will not be needed. This switch prevents GCC from looking
# for them.

# --enable-initfini-array
# This switch forces the use of some internal data structures that
# are needed but cannot be detected when building a cross compiler.

# --disable-shared
# This switch forces GCC to link its internal libraries statically.
# We need this because the shared libraries require glibc, which is
# not yet installed on the target system.

# --disable-multilib
# On x86_64, LFS does not support a multilib configuration. This
# switch is harmless for x86.

# --disable-decimal-float, --disable-threads, --disable-libatomic, 
# --disable-libgomp, --disable-libquadmath, --disable-libssp,
# --disable-libvtv, --disable-libstdcxx
# These switches disable support for the decimal floating point
# extension, threading, libatomic, libgomp, libquadmath, libssp,
# libvtv, and the C++ standard library respectively. These features
# will fail to compile when building a cross-compiler and are not
# necessary for the task of cross-compiling the temporary libc.

# --enable-languages=c,c++
# This option ensures that only the C and C++ compilers are built.
# These are the only languages needed now.

## Compile GCC by running:
#	make

## Install the package:
#	make install

# This build of GCC has installed a couple of internal system
# headers. Normally one of them, limits.h, would in turn include
# the corresponding system limits.h header, in this case, $LFS/usr
# include/limits.h. However, at the time of this build of GCC $LFS
# usr/include/limits.h does not exist, so the internal header that
# has just been installed is a partial, self-contained file and
# does not include the extended features of the system header. This
# is adequate for building glibc, but the full internal header will
# be needed later. Create a full version of the internal header
# using a command that is identical to what the GCC build system
# does in normal circumstances:
#	cd ..
#	cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
#		`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h

# Details on this package are located in 
# Section 8.26.2, “Contents of GCC.”

LFS_Sources=""$LFS"/sources"
Package_Filename="gcc-11.2.0.tar.xz"
Package_Directory="gcc-11.2.0"
Package1_Filename="mpfr-4.1.0.tar.xz"
Package1_Directory="mpfr-4.1.0"
Package2_Filename="gmp-6.2.1.tar.xz"
Package2_Directory="gmp-6.2.1"
Package3_Filename="mpc-1.2.1.tar.gz"
Package3_Directory="mpc-1.2.1"

Log_Directory=""$LFS"/logs"
Log_Chapter_Number="5-3"
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
echo "<===> LFS Builder - 5.3 GCC-11.2.0 - Pass 1 <===>"
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

## Extract Package Addons:
if [[ ""$LFS_Sources"/"$Package1_Filename"" == *.gz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package1_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxzf ""$LFS_Sources"/"$Package1_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
elif [[ ""$LFS_Sources"/"$Package1_Filename"" == *.xz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package1_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxf ""$LFS_Sources"/"$Package1_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
fi
mv -v ""$LFS_Sources"/"$Package_Directory"/"$Package1_Directory"" ""$LFS_Sources"/"$Package_Directory"/mpfr" | tee -a "$Extraction_Log"

if [[ ""$LFS_Sources"/"$Package2_Filename"" == *.gz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package2_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxzf ""$LFS_Sources"/"$Package2_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
elif [[ ""$LFS_Sources"/"$Package2_Filename"" == *.xz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package2_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxf ""$LFS_Sources"/"$Package2_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
fi
mv -v ""$LFS_Sources"/"$Package_Directory"/"$Package2_Directory"" ""$LFS_Sources"/"$Package_Directory"/gmp" | tee -a "$Extraction_Log"

if [[ ""$LFS_Sources"/"$Package3_Filename"" == *.gz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package3_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxzf ""$LFS_Sources"/"$Package3_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
elif [[ ""$LFS_Sources"/"$Package3_Filename"" == *.xz ]]; then
	echo "$Long_Line" | tee -a "$Extraction_Log"
	echo "<=> Extract package {"$Package3_Filename"} <=>" | tee -a "$Extraction_Log"
	tar -vxf ""$LFS_Sources"/"$Package3_Filename"" -C ""$LFS_Sources"/"$Package_Directory"" | tee -a "$Extraction_Log"
fi
mv -v ""$LFS_Sources"/"$Package_Directory"/"$Package3_Directory"" ""$LFS_Sources"/"$Package_Directory"/mpc" | tee -a "$Extraction_Log"

timer_extract_end=`date +%s`
timer_extract_runtime=$((timer_extract_end-timer_extract_start))

## Enter package directory:
echo "$Long_Line" | tee -a "$Builder_Log"
echo "<=> Enter package directory <=>" | tee -a "$Builder_Log"
cd ""$LFS_Sources"/"$Package_Directory"/"

## 64 Bit Check
case $(uname -m) in
	x86_64)
		echo "$Long_Line" | tee -a "$Builder_Log"
		echo "<=> 64 Bit Check <=>" | tee -a "$Builder_Log"
		sed -e '/m64=/s/lib64/lib/' \
			-i.orig gcc/config/i386/t-linux64 \
			| tee -a "$Builder_Log"
	;;
esac

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

../configure \
	--target=$LFS_TGT \
	--prefix=$LFS/tools \
	--with-glibc-version=2.11 \
	--with-sysroot=$LFS \
	--with-newlib \
	--without-headers \
	--enable-initfini-array \
	--disable-nls \
	--disable-shared \
	--disable-multilib \
	--disable-decimal-float \
	--disable-threads \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libvtv \
	--disable-libstdcxx \
	--enable-languages=c,c++ \
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

make install | tee -a "$Package_Install_Log"

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
