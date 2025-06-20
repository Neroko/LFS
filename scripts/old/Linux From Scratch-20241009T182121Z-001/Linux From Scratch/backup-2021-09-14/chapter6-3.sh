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

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="ncurses-6.2.tar.gz"
Package_Directory="ncurses-6.2"

## Extract Package:
tar -vxzf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/"

## Enter package directory:
cd ""$LFS_Sources"/"$Package_Directory"/"

# First, ensure that gawk is found first during configuration:
sed -i s/mawk// configure

# Then, run the following commands to build the “tic” program on the build
# host:
mkdir build
pushd build
	../configure
	make -C include
	make -C progs tic
popd

## Create and enter build directory:
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Prepare Package for compilation:
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(./config.guess) \
	--mandir=/usr/share/man \
	--with-manpage-format=normal \
	--with-shared \
	--without-debug \
	--without-ada \
	--without-normal \
	--enable-widec

## Compile the package:
make

## Install the package:
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
