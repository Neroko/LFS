#!/bin/bash

## 5.6. Libstdc++ from GCC-11.2.0, Pass 1
# Libstdc++ is the standard C++ library. It is needed to compile C++ code
# (part of GCC is written in C++), but we had to defer its installation when
# we built gcc-pass1 because it depends on glibc, which was not yet
# available in the target directory.
#	Approximate build time:	0.4 SBU
#	Required disk space:		1.0 GB

## 5.6.1. Installation of Target Libstdc++
## Note
# Libstdc++ is part of the GCC sources. You should first unpack the GCC
# tarball and change to the gcc-11.2.0 directory.

## Create a separate build directory for libstdc++ and enter it:
#	mkdir -v build
#	cd build

## Prepare libstdc++ for compilation:
#	../libstdc++-v3/configure \
#		--host=$LFS_TGT \
#		--build=$(../config.guess) \
#		--prefix=/usr \
#		--disable-multilib \
#		--disable-nls \
#		--disable-libstdcxx-pch \
#		--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

## The meaning of the configure options:
# --host=...
# Specifies that the cross compiler we have just built should be used
# instead of the one in /usr/bin.

# --disable-libstdcxx-pch
# This switch prevents the installation of precompiled include files, which
# are not needed at this stage.

# --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0
# This is the location where the C++ compiler should search for the
# standard include files. In a normal build, this information is automatically
# passed to the libstdc++ configure options from the top level directory. In
# our case, this information must be explicitly given.

## Compile libstdc++ by running:
#	make

## Install the library:
#	make DESTDIR=$LFS install

# Details on this package are located in
# Section 8.26.2, “Contents of GCC.”

#tar -vxzf ""$LFS_Sources"/filename.tar.gz"
#tar -vxf ""$LFS_Sources"/filename.tar.xz"

LFS="/mnt/lfs"
LFS_Sources=""$LFS"/sources"
Package_Filename="gcc-11.2.0.tar.xz"
Package_Directory="gcc-11.2.0"

## Extract Package:
tar -vxf ""$LFS_Sources"/"$Package_Filename"" -C ""$LFS_Sources"/"

## Enter package directory:
cd ""$LFS_Sources"/"$Package_Directory"/"

## Create and enter build directory:
mkdir -v ""$LFS_Sources"/"$Package_Directory"/build/"
cd ""$LFS_Sources"/"$Package_Directory"/build/"

## Prepare Package for compilation:
../libstdc++-v3/configure \
	--host=$LFS_TGT \
	--build=$(../config.guess) \
	--prefix=/usr \
	--disable-multilib \
	--disable-nls \
	--disable-libstdcxx-pch \
	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/11.2.0

## Compile the package:
make

## Install the package:
make DESTDIR=$LFS install
