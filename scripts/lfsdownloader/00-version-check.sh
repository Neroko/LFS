#!/bin/bash

display_title="== Linux From Scratch (LFS) Versions Checks =="
#
# VERSION (LFS):
current_version="12.3"
#
# VERSION (SCRIPT):
script_version="1.0.0.2"
#
# DATE LAST EDITED:
#   05/05/2025
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
#   -h, --help                  Display this help
#   -v, --verbose               Enable Verbose Mode
#   -V, --version               Display versions
#   -l, --log                   Set log file
#   -l [file], --log=[file]     Set log file

# === Chapter 2. Preparing the Host System ===
# == 2.1. Introduction
#   In this chapter, the host tolls needed for building LFS are checked and, if necessary, installed. Then a
#   partition which will host the LFS system is prepared. We will create the partition itself, create a file
#   system on it, and mount it.

# == 2.2. Host System Requirements
# = 2.2.1. Hardware
#   The LFS editors recommend that the system CPU have at least four cores and that the system have at least
#   8 GB of memory. Older systems that do not meet these requirements will still work, but the time to build
#   packages will be significantly longer than documented.

log_to_file=false
verbose_mode=false
output_file="lfs.log"

clear

display_help() {
    # Display Help
    echo "$display_title"
    echo
    echo "Syntax: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help                          This Help Info"
    echo "  -v, --verbose                       Enable Verbose Mode"
    echo "  -V, --version                       Script Version"
    echo "  -l, --log                           Log to File"
#    echo "  -l [filename], --log=[filename]     Log to File"
}

has_argument() {
    [[ ("$1" == *=* && -n ${1#*=}) || ( ! -z "$2" && "$2" != -*) ]];
}

extract_argument() {
    echo "$2:-${1#*=}}"
}

display_version() {
    # Display Version
    echo "$display_title"
    echo "Version (LFS): "$current_version""
    echo "Version (Script): "$script_version""
}

# Fuction to handle options and arguments
handle_options() {
    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                display_help
                exit 0
                ;;
            -l | --log)
                log_to_file=true
                ;;
            -V | --version)
                display_version
                exit 0
                ;;
            -v | --verbose)
                verbose_mode=true
                ;;
            *)
                echo "Invalid options: $1" >&2
                display_help
                exit 1
                ;;
#            -f | --file*)
#                if ! has_argument $@; then
#                    echo "File not specified." >&2
#                    display_help
#                    exit 1
#                fi
#
#                output_file=$(extract_argument $@)
#
#                shift
#                ;;
        esac
        shift
    done
}

# Main script execution
handle_options "$@"

# Perform the desired actions based on the provided flags and arguments
if [ "$verbose_mode" = true ]; then
    echo "Verbose mode enabled."
fi

#if [ -n "$output_file" ]; then
#    echo "Outout file specified: $output_file"
#fi

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

ask_install="0"

ver_check() {
    if ! type -p "$2" &>/dev/null; then
        echo -e "${TEXT_RED}ERROR:${TEXT_NC}  Cannot find $2 ($1)";
        ask_install="1"
        return 1;
    fi
    v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
    if printf '%s\n' "$3" "$v" | sort --version-sort --check &>/dev/null; then
        printf "${TEXT_GREEN}OK:${TEXT_NC}     %-9s %-6s >= $3\n" "$1" "$v";
        return 0;
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  %-os9s is TOO OLD ($3 or later required)\n" "$1";
        ask_install="1"
        return 1;
    fi
}

install_necessary() {
#    install_answer="no"
    if [ $ask_install == "1" ]; then
        while true; do
            read -p "Update\Upgrade\Install Needed Packages (y/n)?" yn
            case $yn in
                [Yy]* ) install_answer="yes";
                    break;;
                [Nn]* ) install_answer="no";
                    break;;
                * ) echo "Y or N" ;;
            esac
        done
    fi

    if [[ $install_answer == "yes" ]]; then
        sudo apt-get update
        sudo apt-get upgrade
        # Normally on a Debian VM, 100+- packages will need to be installed, work on making this a varable list
        sudo apt-get --yes install coreutils bash binutils bison diffutils findutils gawk gcc g++ grep gzip m4 make patch perl python3 sed tar texinfo xz-utils
#        sudo reboot
#        exit
        install_necessary
#    elif [[ $install_answer == "no" ]]; then
#        exit
    fi
}

ver_kernel() {
    kver=$(uname -r | grep -E -o '^[0-9\.]+')
    if printf '%s\n' "$1" "$kver" | sort --version-sort --check &>/dev/null; then
        printf "${TEXT_GREEN}OK:${TEXT_NC}     Linux Kernel $kver >= $1\n";
        return 0;
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver";
    fi
}

# = 2.2.2. Software
#   Your host system should have the following software with the minimum versions indicated. This should not be
#   an issue for most modern Linux distributions. Also note that many distributions will place software headers
#   into separate packages, often in the form of <package-name>-devel or <package-name>-dev. Be sure to install
#   those if your distribution provides them.

#   Earlier versions of the listed software packages may work, but have not been tested.
software_check() {
    echo $border
    echo '-- Version Check --'
    echo $border

    # == Coreutils ==
    # This package contains a number of essential programs for viewing and manipulating files and directories. These
    # programs are needed for command line file management, and are necessary for the installation procedures of every
    # package in LFS.
    # -- NOTE --
    # Check for Coreutils first because --version-sort needs Coreutils >= 7.0
    ver_check   "Coreutils"     "sort"      "8.1 || bail "Coreutils too old, stop""

    # == Bash ==
    # This package satisfies an LSB core requirement to provide a Bourne Shell interface to the system. It was chosen
    # over other shell packages because of its common usage and extensive capabilities.
    #   (/bin/sh should be a symbolic or hard link to bash)
    ver_check   "Bash"          "bash"      "3.2"

    # == Binutils ==
    # This package supplies a linker, an assembler, and other tools for handling object files. The programs in this
    # package are needed to compile most of the packages in an LFS system.
    ver_check   "Binutils"      "ld"        "2.13.1"

    # == Bison ==
    # This package contains the GNU version of yacc (Yet Another Compiler Compiler) needed to build several of the LFS programs.
    #   (/usr/bin/yacc should be a link to bison or a small script that executes bison)
    ver_check   "Bison"         "bison"     "2.7"

    # == Diffutils ==
    # This package contains programs that show the differences between files or directories. These programs can be used
    # to create patches, and are also used in many packages' build procedures.
    ver_check   "Diffutils"     "diff"      "2.8.1"

    # == Findutils ==
    # This package provides programs to find files in a file system. It is used in many packages' build scripts.
    ver_check   "Findutils"     "find"      "4.2.31"

    # == Gawk ==
    # This package supplies programs for manipulating text files. It is the GNU version of awk (Aho-WeinbergKernighan). It is used in many other packages' build scripts.
    #   (/usr/bin/awk should be a link to gawk)
    ver_check   "Gawk"          "gawk"      "4.0.1"

    # == GCC ==
    # This is the Gnu Compiler Collection. It contains the C and C++ compilers as well as several others not built by LFS.
    # GCC-5.2 inlcuding the C++ compiler, g++ (Version greater than 14.2.0 are not recommended as they have not been
    # tested). C and C++ standard libraries (with headers) must also be present so the C++ compiler can build hosted
    # programs.
    ver_check   "GCC"           "gcc"       "5.2"
    ver_check   "GCC (C++)"     "g++"       "5.2"

    # == Grep ==
    # This package contains programs for searching through files. These programs are used by most packages' build scripts.
    ver_check   "Grep"          "grep"      "2.5.1a"

    # == Gzip ==
    # This package contains programs for compressing and decompressing files. It is needed to decompress many packages in LFS.
    ver_check   "Gzip"          "gzip"      "1.3.12"

    # == M4 ==
    # This package provides a general text macro processor useful as a build tool for other programs.
    ver_check   "M4"            "m4"        "1.4.10"

    # == Make ==
    # This package contains a program for directing the building of packages. It is required by almost every package in LFS.
    ver_check   "Make"          "make"      "4.0"

    # == Patch ==
    # This package contains a program for modifying or creating files by applying a patch file typically created by the
    # diff program. It is needed by the build procedure for several LFS packages.
    ver_check   "Patch"         "patch"     "2.5.4"

    # == Perl ==
    # This package is an interpreter for the runtime language PERL. It is needed for the installation and test suites of several LFS packages.
    ver_check   "Perl"          "perl"      "5.8.8"

    # == Python 3 ==
    # This package provides an interpreted language that has a design philosophy emphasizing code readability.
    ver_check   "Python"        "python3"   "3.4"

    # == Sed ==
    # This package allows editing of text without opening it in a text editor. It is also needed by many LFS packages' configure scripts.
    ver_check   "Sed"           "sed"       "4.1.5"

    # == Tar ==
    # This package provides archiving and extraction capabilities of virtually all the packages used in LFS.
    ver_check   "Tar"           "tar"       "1.22"

    # == Texinfo ==
    # This package supplies programs for reading, writing, and converting info pages. It is used in the installation
    # procedures of many LFS packages.
    ver_check   "Texinfo"       "texi2any"  "5.0"

    # == XZ Utils ==
    # This package contains programs for compressing and decompressing files. It provides the highest compression
    # generally available and is useful for decompressing packages in XZ or LZMA format.
    ver_check   "Xz"            "xz"        "5.0.0"
}

software_check

install_necessary

# == Important ==
#   Note that the symlinks mentioned above are required to build an LFS system using the instructions contained
#   within this script. Symlinks that point to other software (such as dash, mawk, etc) maky work, but are not
#   tested or supported by the LFS development team. and may require either deviation from the instructions or
#   additional patches to some packages.

# == Linux Kernel
# This package is the Operating System. It is the Linux in the GNU/Linux environment.
# The reason for the kernel version requirement is that we specify that version when building glibc in Chapter 5
# and Chapter 8, so the workarounds for older kernels are not enabled and the compiled glibc is slightly faster
# and smaller. As at Dec 2024, 5.4 is the oldest kernel release still supported by the kernel developers. Some
# kernel releases older than 5.4 may be still supported by third-party teams, but they are not considered
# official upstream kernel releases; read https://kernel.org/category/releases.html for the details.

# If the host kernel is earlier than 5.4 you will need to replace the kernel with a more up-to-date version.
# There are two ways you can go about this. First, see if your Linux vendor provides a 5.4 or later kernel
#package. If so, you may wish to install it. If your vendor doesn't offer an acceptable kernel package, or you
# would prefer not to install it, you can compile a kernel yourself. Instructions for compiling the kernel and
# configuring the boot loader (assuming the host uses GRUB) are located in Chapter 10.

# We require the host kernel to support UNIX 98 pseudo terminal (PTY). It should be enabled on all desktop or
# server distros shipping Linux 5.4 or a newer kernel. If you are building a custom host kernel, ensure
# CONFIG_UNIX98_PTYS is set to y in the kernel configuration.

ver_kernel      5.4

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]; then
    echo -e "${TEXT_GREEN}OK:${TEXT_NC}     Linux Kernel supports UNIX 98 PTY";
else
    echo -e "${TEXT_RED}ERROR:${TEXT_NC}    Linux Kernel does NOT support UNIX 98 PTY";
fi

press_pause

alias_check() {
    if $1 --version 2>$1 | grep -qi "$2"; then
        printf "${TEXT_GREEN}OK:${TEXT_NC}     %-4s is $2\n" "$1";
    else
        printf "${TEXT_RED}ERROR:${TEXT_NC}  %-4s is NOT $2\n" "$1";
        alias_error="1"
    fi
}

echo $border
echo "-- Aliases --"
echo $border

alias_check "awk" "GNU"

# -- Bison
# /usr/bin/yac should be a link to bison or a small script that executes bison
alias_check "yacc" "Bison"

# -- Bash
# /bin/sh should be a symbolic or hard link to bash
# To set sh to BASH: sudo ln -sf bash /bin/sh
# To set sh to DASH: sudo ln -sf dash /bin/sh
alias_check "sh" "Bash"
if [[ $alias_error == "1" ]]; then
    while true; do
        read -p "Set SH to BASH (y/n)?" yn
            case $yn in
                [Yy]* ) set_sh="yes";
                    sudo ln -sf bash /bin/sh;
                    break;;
                [Nn]* ) set_sh="no";
                    break;;
                * ) echo "Y or N";;
            esac
    done
fi

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
rm --verbose --force "awk"
rm --verbose --force "sh"
rm --verbose --force "yacc"
