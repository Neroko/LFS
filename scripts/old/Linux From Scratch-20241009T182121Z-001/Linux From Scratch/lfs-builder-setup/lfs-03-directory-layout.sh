#!/bin/bash

## 4.2. Creating a limited directory layout in LFS filesystem
# The first task performed in the LFS partition is to create a
# limited directory hierarchy so that programs compiled in
# Chapter 6 (as well as glibc and libstdc++ in Chapter 5) may be
# installed in their final location. This is needed so that those
# temporary programs be overwritten when rebuilding them in
# Chapter 8.

## Create the required directory layout by running the following as
# root:
#   mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

#   for i in bin lib sbin; do
#       ln -sv usr/$i $LFS/$i
#   done

#   case $(uname -m) in
#       x86_64) mkdir -pv $LFS/lib64 ;;
#   esac

## Note
# The above command is correct. The ln command has a few syntactic
# versions, so be sure to check info coreutils ln and ln(1) before
# reporting what you may think is an error.

## Programs in Chapter 6 will be compiled with a cross-compiler
# (more details in section Toolchain Technical Notes). In order to
# separate this cross-compiler from the other programs, it will be
# installed in a special directory. Create this directory with:
#   mkdir -pv $LFS/tools

## Grant lfs full access to all directories under $LFS by making lfs
# the directory owner:
#   chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
#   case $(uname -m) in
#       x86_64) chown -v lfs $LFS/lib64 ;;
#   esac

# If a separate working directory was created as suggested, give
# user lfs ownership of this directory:
#   chown -v lfs $LFS/sources

LFS="/mnt/lfs"
LFS_Sources_Directory=""$LFS"/sources"
LFS_Tools_Directory=""$LFS"/tools"
Log_Directory=""$LFS"/logs"

Long_Line="-------------------------------------------------------"

clear

echo "$Long_Line"
echo "<===> LFS Directory Layout Cleanup and Creator <===>"

## Remove old work directorys:
echo "$Long_Line"
echo "<=> Remove old work directorys <=>"
sudo rm -vrf $LFS/{bin,etc,lib,sbin,usr,var}

if [ -d "$LFS_Tools_Directory" ]; then
    ## Remove old tools directorys:
    echo "$Long_Line"
    echo "<=> Remove old tools directorys <=>"
    sudo rm -vrf "$LFS_Tools_Directory"
fi

if [ -d "$Log_Directory" ]; then
    echo "$Long_Line"
    echo "<=> Remove old log directorys <=>"
    ## Remove old log directorys:
    sudo rm -vrf "$Log_Directory"
fi

## Remove old source package directorys:
echo "$Long_Line"
echo "<=> Remove old source package directorys <=>"
Package_01_Directory="binutils-2.37"			# Chapter 5-2 - Binutils
Package_02_Directory="gcc-11.2.0"				# Chapter 5-3 - GCC
Package_03_Directory="linux-5.13.12"			# Chapter 5-4 - Linux
Package_04_Directory="glibc-2.34"				# Chapter 5-5 - Glibc
Package_05_Directory="m4-1.4.19"				# Chapter 6-2 - M4
Package_06_Directory="ncurses-6.2"				# Chapter 6-3 - Ncurses
Package_07_Directory="bash-5.1.8"				# Chapter 6-4 - Bash
Package_08_Directory="coreutils-8.32"			# Chapter 6-5 - Coreutils

sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_01_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_02_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_03_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_04_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_05_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_06_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_07_Directory""
sudo rm -vrf ""$LFS_Sources_Directory"/"$Package_08_Directory""

## Create work directorys:
echo "$Long_Line"
echo "<=> Create work directorys <=>"
sudo mkdir -vp $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

## Create links:
echo "$Long_Line"
echo "<=> Create links <=>"
for i in bin lib sbin; do
    sudo ln -vs usr/$i $LFS/$i
done

## 64 Bit Check:
case $(uname -m) in
    x86_64)
        echo "$Long_Line"
        echo "<=> 64 Bit Check <=>"
        sudo mkdir -vp $LFS/lib64
    ;;
esac

## Create tools directory:
echo "$Long_Line"
echo "<=> Create tools directory <=>"
sudo mkdir -vp "$LFS_Tools_Directory"

## Grant lfs full access to all directories under $LFS:
echo "$Long_Line"
echo "<=> Grant lfs full access to all directories under '$LFS' <=>"
sudo chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}

## 64 Bit Check:
case $(uname -m) in
    x86_64)
        echo "$Long_Line"
        echo "<=> 64 Bit Check <=>"
        sudo chown -v lfs $LFS/lib64
    ;;
esac

## Give user lfs ownership of this directory:
echo "$Long_Line"
echo "<=> Give user lfs ownership of this directory <=>"
sudo chown -v lfs "$LFS_Sources_Directory"

## Create log directory
if [ ! -d "$Log_Directory" ]; then
    echo "$Long_Line"
    echo "<=> Create log directory <=>"
    sudo mkdir -vp "$Log_Directory"
    sudo chown -v lfs "$Log_Directory"
fi
