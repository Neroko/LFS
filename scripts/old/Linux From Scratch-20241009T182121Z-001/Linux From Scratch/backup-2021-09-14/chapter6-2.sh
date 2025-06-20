#!/bin/bash

## 6.2. M4-1.4.19
# The M4 package contains a macro processor.
#	Approximate build time:	0.2 SBU
#	Required disk space:		32 MB

## 6.2.1. Installation of M4
## Prepare M4 for compilation:
#	./configure --prefix=/usr \
#		--host=$LFS_TGT \
#		--build=$(build-aux/config.guess)

## Compile the package:
#	make

## Install the package:
#	make DESTDIR=$LFS install

# Details on this package are located in
# Section 8.12.2, “Contents of M4.”

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="m4-1.4.19.tar.xz"
Package_Directory="m4-1.4.19"

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
	--build=$(build-aux/config.guess)

## Compile the package:
make

## Install the package:
make DESTDIR=$LFS install
