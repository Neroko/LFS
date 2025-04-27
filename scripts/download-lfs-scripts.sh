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
#   03/03/2025
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

wget $download_site
