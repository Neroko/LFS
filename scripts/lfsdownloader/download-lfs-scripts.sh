#!/bin/bash

# Linux From Scratch (LFS) Download Needed Files
#
# VERSION (LFS):
#   12.2
#
# VERSION (SCRIPT):
#   1.0.0.0
#
# DATE LAST EDITED:
#   05/08/2025
#
# DATE CREATED:
#   03/03/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# USAGE:
#   download-lfs-scripts.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
# DESCRIPTION
#   Script to download LFS scripts and files needed files from GitHub
#
# =======================
# == SCRIPT NOT TESTED ==
# =======================

#download_site="https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/wget-list"
#download_directory="lfs_test"

export lfs="/mnt/lfs"

download_directory="~/lfs"
download_site="https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/scripts/lfsdownloader/"

# Check for directory and see if it exist:
if [ ! -d "$download_directory" ]; then
    mkdir                        \
        --verbose                \
        --parents                \
        "$download_directory";
fi

download_file(){
    rm               \
        --verbose    \
        --force      \
        --recursive  \
        "$1"
    wget                         \
        --verbose                \
        --output-document="$1"   \
        --directory-prefix="$3"  \
        ""$download_site"$2"
    
    chmod            \
        --verbose    \
        755          \
        "$1"
}

download_file "version-check.sh" "00-version-check.sh" "$download_directory"
download_file "setup-system.sh" "01-setup-system.sh" "$download_dorectpry"

# Check for file in directory
#if [ -f "$download_site" ]

# Check for directory and see if it exist:
#if [ ! -d "$download_directory" ]; then
#    mkdir -p "$download_directory";
#fi
