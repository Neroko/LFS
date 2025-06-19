#!/bin/bash

# Script to list version numbers of LFS critical development tools

export LC_ALL=C

## Bash 5.1
# Minimum/Recommended Version: 3.2
# This package satisfies an LSB core requirement to provide a Bourne Shell interface to
# the system. It was chosen over other shell packages because of its common usage and
# extensive capabilities beyond basic shell functions.
# (/bin/sh should be a symbolic or hard link to bash)
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH

## Binutils 2.36.1
# Minimum/Recommended Version: 2.25
# (Versions greater than 2.36.1 are not recommended as they have not been tested)
# This package contains a linker, an assembler, and other tools for handling object files.
# The programs in this package are needed to compile most of the packages in an LFS system
# and beyond.
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-

## Bison 3.7.5
# Minimum/Recommended Version: 2.7
# This package contains the GNU version of yacc (Yet Another Compiler Compiler) needed to
# build several other LFS programs.
bison --version | head -n1
if [ -h /usr/bin/yacc ]; then
	echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
	echo yacc is `/usr/bin/yacc --version | head -n1`
else
	echo "yacc not found" 
fi

## Bzip2
# Minimum/Recommended Version: 1.0.4
# This package contains programs for compressing and decompressing files. It is required to
# decompress many LFS packages
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-

## Coreutils
# Minimum/Recommended Version: 6.9
# This package contains a number of essential programs for viewing and manipulating files and
# directories. These programs are needed for command line file management, and are necessary
# for the installation procedures of every package in LFS.
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2

## Diffutils
# Minimum/Recommended Version: 2.8.1
# This package contains programs that show the differences between files or directories.
# These programs can be used to create patches, and are also used in many packages' build
# procedures.
diff --version | head -n1

## Findutils 4.8.0
# Minimum/Recommended Version: 4.2.31
# This package contains programs to find files in a file system. It is used in many packages'
# build scripts.
find --version | head -n1

## Gawk
# Minimum/Recommended Version: 4.0.1
# This package contains programs for manipulating text files. It is the GNU version of awk
# (Aho-Weinberg-Kernighan). It is used in many other packages' build scripts.
gawk --version | head -n1
if [ -h /usr/bin/awk ]; then
	echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
	echo awk is `/usr/bin/awk --version | head -n1`
else 
	echo "awk not found" 
fi

## GCC
# Minimum/Recommended Version: 6.2
# This package is the Gnu Compiler Collection. It contains the C and C++ compilers as well as
# several others not built by LFS.
gcc --version | head -n1
g++ --version | head -n1

##  Glibc 2.33
# This package contains the main C library. Linux programs will not run without it.
ldd --version | head -n1 | cut -d" " -f2- # glibc version

## Grep 3.6
# This package contains programs for searching through files. These programs are used by most
# packages' build scripts.
grep --version | head -n1

## Gzip
#This package contains programs for compressing and decompressing files. It is needed to
# decompress many packages in LFS and beyond.
gzip --version | head -n1

## Linux Kernel
# Minimum/Recommended Version: 3.2
cat /proc/version

## M4 1.4.10
# This package contains a general text macro processor useful as a build tool for other
# programs.
m4 --version | head -n1

## Make
# This package contains a program for directing the building of packages. It is required by
# almost every package in LFS.
make --version | head -n1

## Patch
# This package contains a program for modifying or creating files by applying a patch file
# typically created by the diff program. It is needed by the build procedure for several LFS
# packages.
patch --version | head -n1

## Perl 5.32.1
# This package is an interpreter for the runtime language PERL. It is needed for the
# installation and test suites of several LFS packages.
echo Perl `perl -V:version`

## Python 3.9.2
# This package provides an interpreted language that has a design philosophy that emphasizes
# code readability.
python3 --version

## Sed
# This package allows editing of text without opening it in a text editor. It is also needed
# by most LFS packages configure scripts.
sed --version | head -n1

## Tar 1.34
# This package provides archiving and extraction capabilities of virtually all packages used
# in LFS.
tar --version | head -n1

## Texinfo
# This package contains programs for reading, writing, and converting info pages. It is used
# in the installation procedures of many LFS packages.
makeinfo --version | head -n1 # texinfo version

## XZ Utils
# This package contains programs for compressing and decompressing files. It provides the
# highest compression generally available and is useful for decompressing packages in XZ or
# LZMA format.
xz --version | head -n1

## G++ Test
echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
	then echo "g++ compilation OK";
	else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
