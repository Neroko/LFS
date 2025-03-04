#!/bin/bash
# Linux From Scratch (LFS) Sources Directory Setup
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
# DESCRIPTION
#   Script to list version numbers of critical development tools
#
# USAGE:
#   sources-setup.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions

# Directorys
LFS="/mnt/lfs"
sources_directory=""$LFS"/sources"
wget_list_link="https://www.linuxfromscratch.org/lfs/downloads/stable/wget-list"
md5sums_link="https://www.linuxfromscratch.org/lfs/downloads/stable/md5sums"

# Check for sudo
#current_user="whoami"
#groups "$current_user" | grep -o 'sudo'
groups "#(id -un)" | grep -q ' sudo ' && echo "In sudo group" || echo "Not in sudo group"

# == Chapter 3. Packages and Patches ==
# == 3.1. Introduction
# Create the directory, execute the following command, as user root, before starting the
# download session:
mkdir -v "$sources_directory"

# Make this directory writable and sticky. "Sticky" means that even if multiple users have
# write permission on a directory, only the owner of a file can delete the file within a
# sticky directory. The following command will enable the write and sticky modes:
chmod -v a+wt "$sources_directory"

# There are seveeral ways to obtain all the necessary packages and patches to build LFS:
# - The files can be downloaded individually as described in the next two sections.
# - For stable versions of the book, a tarball of all the needed files can be downloaded
#   from one of the mirror sites listed at:
#       "https://www.linuxfromsratch.org/mirrors.html#files"
# - The files can be downloaded using wget and a wget-list as described below.

# To download all of the packages and patches by using wget-list as an input to the wget
# command, use:
wget "$wget_list_link"
wget "$md5sums_link"

wget                            \
    --input-file="wget-list"    \
    --continue                  \
    --directory-prefix="$sources_directory"

# Additionally, starting with LFS, there is a separate file, md5sums, which can be used to
# verify that all the correct packages are available before proceeding. Pkace that file in
# $LFS/sources and run:
pushd "$sources_directory"
    md5sums -c md5sums
popd
# This check can be used after retrieving the needed files with any of the methods above.

# If the packages and patches are downloaded as a non-root user, these files will be owned
# by the user. The file system records the owner by its UID, and the UID of a normal user
# in the host distro is not assigned in LFS. So the files will be left owned by an unnamed
# UID in the final LFS system. If you won't assign the same UID for your user in the LFS
# system, change the owners of these files to root now to avoid this issue:
chown root:root ""$sources_directory"/*"

# == Chapter 4. Final Preparations ==
# == 4.2. Creating a Limited Directory Layout in the LFS Filesystem












