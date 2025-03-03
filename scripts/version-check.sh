#!/bin/bash
# Linux From Scratch (LFS)
#
# VERSION:
#   12.2
#
# DESCRIPTION
#   Script to list version numbers of critical development tools
#
# USAGE:
#   version-check.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
#
# If you have tools installed in other directories, adjust PATH her AND
# in ~lfs/.bashrc (section 4.4) as well.

clear

border='==================='

LC_ALL=C
PATH=/usr/bin:bin

bail() { echo "FATAL: $1"; exit 1; }
grep --version > /dev/null 2> /dev/null || bail "grep does not work"
sed '' /dev/null || bail "sed does not work"
sort /dev/null || bail "sort does not work"

ver_check() {
    if ! type -p $2 &>/dev/null; then
        echo "ERROR:    Cannot find $2 ($1)";
        return 1;
    fi
    v=$($2 --version 2>&1 | grep -E -o '[0-9]+\.[0-9\.]+[a-z]*' | head -n1)
    if printf '%s\n' $3 $v | sort --version-sort --check &>/dev/null; then
        printf "OK:     %-9s %-6s >= $3\n" "$1" "$v";
        return 0;
    else
        printf "ERROR:  %-9s is TOO OLD ($3 or later required)\n" "$1";
        return 1;
    fi
}

ver_kernel() {
    kver=$(uname -r | grep -E -o '^[0-9\.]+')
    if printf '%s\n' $1 $kver | sort --version-sort --check &>/dev/null; then
        printf "OK:     Linux Kernel $kver >= $1\n";
        return 0;
    else
        printf "ERROR:  Linux Kernel ($kver) is TOO OLD ($1 or later required)\n" "$kver";
    fi
}

# Coreutils first because --version-sort needs Coreutils >= 7.0
echo $border
echo '-- Version Check --'
echo $border

ver_check Coreutils     sort        8.1 || bail "Coreutils too old, stop"
ver_check Bash          bash        3.2
ver_check Binutils      ld          2.13.1
ver_check Bison         bison       2.7
ver_check Diffutils     diff        2.8.1
ver_check Findutils     find        4.2.31
ver_check Gawk          gawk        4.0.1
ver_check GCC           gcc         5.2
ver_check "GCC (C++)"   g++         5.2
ver_check Grep          grep        2.5.1a
ver_check Gzip          gzip        1.3.12
ver_check M4            m4          1.4.10
ver_check Make          make        4.0
ver_check Patch         patch       2.5.4
ver_check Perl          perl        5.8.8
ver_check Python        python3     3.4
ver_check Sed           sed         4.1.5
ver_check Tar           tar         1.22
ver_check Texinfo       texi2any    5.0
ver_check Xz            xz          5.0.0
ver_kernel      4.19

if mount | grep -q 'devpts on /dev/pts' && [ -e /dev/ptmx ]; then
    echo "OK:       Linux Kernel supports UNIX 98 PTY";
else
    echo "ERROR:    Linux Kernel does NOT support UNIX 98 PTY";
fi

read -p "Press any key to continue..." -n1 -s
echo

alias_check() {
    if $1 --version 2>$1 | grep -qi $2; then
        printf "OK:     %-4s is $2\n" "$1";
    else
        printf "ERROR:  %-4s is NOT $2\n" "$1";
    fi
}

echo $border
echo "-- Aliases --"
echo $border

alias_check awk GNU
alias_check yacc Bison
# To set sh to BASH: sudo ln -sf bash /bin/sh
# To set sh to DASH: sudo ln -sf dash /bin/sh
alias_check sh Bash

read -p "Press any key to continue..." -n1 -s
echo

echo $border
echo "-- Compiler Check --"
echo $border

if printf "int main(){}" | g++ -x c++ -; then
    echo "OK:       g++ works";
else
    echo "ERROR:    g++ does NOT work";
fi

rm -f a.out

if [ "$(nproc)" = "" ]; then
    echo "ERROR:    nproc is not available or it produes empty output"
else
    echo "OK:       nproc reports $(nproc) logical cores are available"
fi

echo $border
