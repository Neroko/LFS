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

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="coreutils-8.32.tar.xz"
Package_Directory="coreutils-8.32"

## Extract Package:
tar -vxf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/"

## Enter package directory:
cd ""$LFS_Sources"/"$Package_Directory"/"

## Create and enter build directory:
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Prepare Package for compilation:
./configure --prefix=/usr \
	--host=$LFS_TGT \
	--build=$(build-aux/config.guess) \
	--enable-install-program=hostname \
	--enable-no-install-program=kill,uptime

## Compile the package:
make

## Install the package:
make DESTDIR=$LFS install

# Move programs to their final expected locations:
mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -pv $LFS/usr/share/man/man8
mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
