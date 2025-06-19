#!/bin/bash

## 6.4. Bash-5.1.8
# The Bash package contains the Bourne-Again SHell.
#	Approximate build time:	0.4 SBU
#	Required disk space:		64 MB

##6.4.1. Installation of Bash
# Prepare Bash for compilation:
#	./configure --prefix=/usr \
#		--build=$(support/config.guess) \
#		--host=$LFS_TGT \
#		--without-bash-malloc

##The meaning of the configure options:
# --without-bash-malloc
# This option turns off the use of Bash's memory allocation (malloc) function
# which is known to cause segmentation faults. By turning this option off, Bash
# will use the malloc functions from Glibc which are more stable.

# Compile the package:
#	make

# Install the package:
#	make DESTDIR=$LFS install

# Make a link for the programs that use sh for a shell:
#	ln -sv bash $LFS/bin/sh

# Details on this package are located in
# Section 8.34.2, “Contents of Bash.”

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="bash-5.1.8.tar.gz"
Package_Directory="bash-5.1.8"

## Extract Package:
tar -vxf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/"

## Enter package directory:
cd ""$LFS_Sources"/"$Package_Directory"/"

## Create and enter build directory:
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Prepare Package for compilation:
./configure --prefix=/usr \
	--build=$(support/config.guess) \
	--host=$LFS_TGT \
	--without-bash-malloc

## Compile the package:
make

## Install the package:
make DESTDIR=$LFS install

## Make a link for the programs that use sh for a shell:
ln -sv bash $LFS/bin/sh
