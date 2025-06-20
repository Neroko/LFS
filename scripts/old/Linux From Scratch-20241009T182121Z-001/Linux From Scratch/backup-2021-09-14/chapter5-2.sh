#!/bin/bash

## 5.2. Binutils - Pass 1
# The Binutils package contains a linker, an assembler, and other tools for
# handling object files.
# Approximate build time:	1 SBU
# Required disk space:		602 MB

## 5.2.1. Installation of Cross Binutils
# It is important that Binutils be the first package compiled because both
# Glibc and GCC perform various tests on the available linker and assembler
# to determine which of their own features to enable.

# The Binutils documentation recommends building Binutils in a dedicated
# build directory:
#	mkdir -v build
#	cd build

## Note
# In order for the SBU values listed in the rest of the book to be of any
# use, measure the time it takes to build this package from the
# configuration, up to and including the first install. To achieve this
# easily, wrap the commands in a time command like this:
#	time { ../configure ... && make && make install; }.

# Now prepare Binutils for compilation:
#	..configure \
#		--prefix=$LFS/tools \
#		--with-sysroot=$LFS \
#		--target=$LFS_TGT \
#		--disable-nls \
#		--disable-werror

## The meaning of the configure options:
# --prefix=$LFS/tools
# This tells the configure script to prepare to install the binutils
# programs in the $LFS/tools directory.

# --with-sysroot=$LFS
# For cross compilation, this tells the build system to look in $LFS for
# the target system libraries as needed.

# --tartget=$LFS_TGT
# Because the machine description in the LFS_TGT variable is slightly
# different than the value returned by the config.guess script, this
# switch will tell the configure script to adjust binutil's build system
# for building a cross linker.

# --disable-nls
# This disables internationalization as i18n is not needed for the
# temporary tools.

# --disable-werror
# This pervents the build from stopping in the event that there are
# warnings from the host's compiler.

## Continue with compiling the package:
#	make

## Install the package:
#	make install -j1

## The meaning of the make parameter:
# -j1
# An issue in the building system may cause the installation to fail
# with -j N in MAKEFLAGES. Override it to workaround this issue.

# Details on this package are located in:
# Section 8.18.2, "Contents of Binutils"

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

# ((Addon))
#	if [ filename == *.tar.gz ]; then
#		tar -vxzf "xxx" -C "yyy"
#	elif [ filename == *.tar.xz ]; then
#		tar -vxf "xxx" -C "yyy"
#	fi

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="binutils-2.37.tar.xz"
Package_Directory="binutils-2.37"

## Extract Package:
tar -vxf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/"

## Enter package directory:
cd ""$LFS_Sources"/"$Package_Directory"/"

## Create and enter build directory:
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Prepare Package for compilation:
../configure \
	--prefix=$LFS/tools \
	--with-sysroot=$LFS \
	--target=$LFS_TGT \
	--disable-nls \
	--disable-werror

## Compile the package:
make

## Install the package:
make install -j1
