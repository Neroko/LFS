#!/bin/bash
# Linux From Scratch (LFS) Version Checks
#
# VERSION (LFS):
#   12.3
#
# VERSION (SCRIPT):
#   1.0.0.1
#
# DATE LAST EDITED:
#   03/10/2025
#
# DATE CREATED:
#   03/03/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# DESCRIPTION
#   Script to list version numbers of critical development tools
#
# USAGE:
#   version-check.sh [options] ARG1
#
# OPTIONS:
#   -l [file], --log=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions

# Remove old log file
rm -f log.out

# Saves file descriptors so they can be restored to whatever they were before redirection or used themselves to
# output to whatever they were before the following redirect:
#exec 3>&1 4>&2

# Restore file discriptors for particular singals. Not generally necessary since they should be restored when
# the sub-shell exits.
#trap 'exec 2>&4 1>&3' 0 1 2 3

# Redirect 'stdout' to file 'log.out' then redirect 'stderr' to 'stdout'. Note that the order is important when
# you want them going to the same file. 'stdout' must be redirected before 'stderr' is redirected to 'stdout'.
#exec 1>log.out 2>&1

# Everything below will go the file 'log.out':

clear

TEXT_GREEN='\033[0;32m'     # Text Green
TEXT_YELLOW='\033[0;33m'    # Text Yellow
TEXT_RED='\033[0;31m'       # Text Red
TEXT_NC='\033[0;37m'        # Text No Color
border='==================='

press_pause() {
    read -p "Press any key to continue..." -n1 -s
    echo
}

# If you have tools installed in other directories, adjust PATH her AND
# in ~lfs/.bashrc (section 4.4) as well.
LC_ALL=C
PATH=/usr/bin:bin

bail() { echo "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort /dev/null || bail "sort does not work"

os_check() {
    cat /etc/*-release
}

ver_check() {
    if ! type -p "$2" &>/dev/null; then
        echo -e "${TEXT_RED}ERROR:${TEXT_NC}  Cannot find $2 ($1)";
        return 1;
    fi
    v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
    if printf '%s\n' "$3" "$v" | sort --version-sort --check &>/dev/null; then
 #       printf "${TEXT_GREEN}OK:${TEXT_NC}     %-9s %-6s >= $3\n" "$1" "$v";
        return 0;
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  %-os9s is TOO OLD ($3 or later required)\n" "$1";
        return 1;
    fi
}

ver_kernel() {
    kver=$(uname -r | grep -E -o '^[0-9\.]+')
    if printf '%s\n' "$1" "$kver" | sort --version-sort --check &>/dev/null; then
#        printf "${TEXT_GREEN}OK:${TEXT_NC}     Linux Kernel $kver >= $1\n";
        return 0;
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver";
    fi
}

echo $border
echo '-- Version Check --'
echo $border

# == Coreutils ==
# This package contains a number of essential programs for viewing and manipulating files and directories. These
# programs are needed for command line file management, and are necessary for the installation procedures of every
# package in LFS.
# -- NOTE --
# Check for Coreutils first because --version-sort needs Coreutils >= 7.0
ver_check Coreutils     sort        8.1 || bail "Coreutils too old, stop"

# == Bash ==
# This package satisfies an LSB core requirement to provide a Bourne Shell interface to the system. It was chosen
# over other shell packages because of its common usage and extensive capabilities.
ver_check Bash          bash        3.2

# == Binutils ==
# This package supplies a linker, an assembler, and other tools for handling object files. The programs in this
# package are needed to compile most of the packages in an LFS system.
ver_check Binutils      ld          2.13.1

# == Bison ==
# This package contains the GNU version of yacc (Yet Another Compiler Compiler) needed to build several of the LFS programs.
ver_check Bison         bison       2.7

# == Diffutils ==
# This package contains programs that show the differences between files or directories. These programs can be used
# to create patches, and are also used in many packages' build procedures.
ver_check Diffutils     diff        2.8.1

# == Findutils ==
# This package provides programs to find files in a file system. It is used in many packages' build scripts.
ver_check Findutils     find        4.2.31

# == Gawk ==
# This package supplies programs for manipulating text files. It is the GNU version of awk (Aho-WeinbergKernighan). It is used in many other packages' build scripts.
ver_check Gawk          gawk        4.0.1

# == GCC ==
# This is the Gnu Compiler Collection. It contains the C and C++ compilers as well as several others not built by LFS.
ver_check GCC           gcc         5.2
ver_check "GCC (C++)"   g++         5.2

# == Grep ==
# This package contains programs for searching through files. These programs are used by most packages' build scripts.
ver_check Grep          grep        2.5.1a

# == Gzip ==
# This package contains programs for compressing and decompressing files. It is needed to decompress many packages in LFS.
ver_check Gzip          gzip        1.3.12

# == M4 ==
# This package provides a general text macro processor useful as a build tool for other programs.
ver_check M4            m4          1.4.10

# == Make ==
# This package contains a program for directing the building of packages. It is required by almost every package in LFS.
ver_check Make          make        4.0

# == Patch ==
# This package contains a program for modifying or creating files by applying a patch file typically created by the
# diff program. It is needed by the build procedure for several LFS packages.
ver_check Patch         patch       2.5.4

# == Perl ==
# This package is an interpreter for the runtime language PERL. It is needed for the installation and test suites of several LFS packages.
ver_check Perl          perl        5.8.8

# == Python 3 ==
# This package provides an interpreted language that has a design philosophy emphasizing code readability.
ver_check Python        python3     3.4

# == Sed ==
# This package allows editing of text without opening it in a text editor. It is also needed by many LFS packages' configure scripts.
ver_check Sed           sed         4.1.5

# == Tar ==
# This package provides archiving and extraction capabilities of virtually all the packages used in LFS.
ver_check Tar           tar         1.22

# == Texinfo ==
# This package supplies programs for reading, writing, and converting info pages. It is used in the installation
# procedures of many LFS packages.
ver_check Texinfo       texi2any    5.0

# == XZ Utils ==
# This package contains programs for compressing and decompressing files. It provides the highest compression
# generally available and is useful for decompressing packages in XZ or LZMA format.
ver_check Xz            xz          5.0.0

# == Linux Kernel
# This package is the Operating System. It is the Linux in the GNU/Linux environment.
ver_kernel      5.4

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]; then
#    echo -e "${TEXT_GREEN}OK:${TEXT_NC}     Linux Kernel supports UNIX 98 PTY";
    echo
else
    echo -e "${TEXT_RED}ERROR:${TEXT_NC}    Linux Kernel does NOT support UNIX 98 PTY";
fi

press_pause

alias_check() {
    if $1 --version 2>$1 | grep -qi "$2"; then
        printf "${TEXT_GREEN}OK:${TEXT_NC}     %-4s is $2\n" "$1";
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  %-4s is NOT $2\n" "$1";
    fi
}

echo $border
echo "-- Aliases --"
echo $border

alias_check awk GNU

# -- Bison
# /usr/bin/yac should be a link to bison or a small script that executes bison
alias_check yacc Bison

# -- Bash
# /bin/sh should be a symbolic or hard link to bash
# To set sh to BASH: sudo ln -sf bash /bin/sh
# To set sh to DASH: sudo ln -sf dash /bin/sh
alias_check sh Bash

press_pause

echo $border
echo "-- Compiler Check --"
echo $border

if printf "int main(){}" | g++ -x c++ -
then
    echo -e "${TEXT_GREEN}OK:${TEXT_NC}       g++ works";
else
    echo -e "${TEXT_RED}ERROR:${TEXT_NC}    g++ does NOT work";
fi

rm -f a.out

if [ "$(nproc)" = "" ]; then
    echo -e "${TEXT_RED}ERROR:${TEXT_NC}  nproc is not available or it produes empty output"
else
    echo -e "${TEXT_GREEN}OK:${TEXT_NC}       nproc reports ${TEXT_YELLOW}$(nproc)${TEXT_NC} logical cores are available"
fi

press_pause

# Clean up
rm -f awk
rm -f sh
rm -f yacc
