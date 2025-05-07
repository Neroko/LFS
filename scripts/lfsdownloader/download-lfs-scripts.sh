#!/bin/bash

# Linux From Scratch (LFS) Download Needed Files
#
# VERSION (LFS):
#   12.2
#
# VERSION (SCRIPT):
#   1.0.0.1
#
# DATE LAST EDITED:
#   03/14/2025
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

download_site="https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/wget-list"
download_directory="lfs_test"

# Check if files exist:
rm                               \
    --verbose                    \
    .sudo_as_admin_successful    \
    .wget-hsts                   \
    version-check.sh

# Check for file in directory
#if [ -f "$download_site" ]

# Check for directory and see if it exist:
if [ ! -d "$download_directory" ]; then
    mkdir -p "$download_directory";
fi

# Download files to directory
wget                                        \
    -N                                      \
    -O "version-check.sh"                   \
    --timestamping                          \
    --directory-prefix="$download_directory"\
    "$download_site"

# Set file permission:
chmod                               \
    --verbose                       \
    755                             \
    "version-check.sh"
