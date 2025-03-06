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
#   03/04/2025
#
# DATE CREATED:
#   03/03/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# DESCRIPTION
#   Script to download needed scripts and files to build LFS builder
#
# USAGE:
#   sources-setup.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
# ≠=================≠====
# == SCRIPT NOT TESTED ==
# =≠==≠≠=================

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
# In this section, we begin populating the LFS filesystem with the pieces that will
# constitute the final Linux system. The first step is to create a limited directory
# hierarchy, so that the programs compiled in Chapter 6 (as well as glibc and libstdc++
# in Chapter 5) can be installed in their final location. We do this so those temporary
# programs will be overwritten when the final versions are built in Chapter 8.

# Create the required directory layout by issuing the following commands as root:
mkdir -pv "$LFS"/{eetc,var} "$LFS"/usr/{bin,lib,sbin}

for i in bin lib sib; do
    ln -sv usr/$1 $LFS/$i
done

case $(uname -m) in
    x86_64) mkdir -pv "$LFS"/lib64 ;;
esac

# Programs in Chapter 6 will compiled with a cross-compiler (more details can be found in
# section Toolchain Technical Notes). This cross-compiler will be installed in a special
# directory, to separate it from the other programs. Still acting as root, crate that
# directory with the command:
mkdir -pv $LFS/tools

# == 4.3. Adding the LFS User ==
# When logged in as user root, making a single mistake can damage or destroy a system.
# Therefore. the packages in the next two chapters are built as an unprivileged user. You
# could use your own user name, but to make it easier to set up a clean working
# environment, we will create a new user called lfs as a member of a new group (also named
# lfs) and run commands as lfs during the installation process. As root, issue the following
# commands to add the new user:
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

# This is what the command line options mean:
# -s /bin/bash
#   This makes bash the default shell for user lfs.
# -g lfs
#   This option adds user lfs to group lfs.
# -m
#   This creates a home directory for lfs.
# -k /dev/null
#   This parameter prevents possible copying of files from a skeleton directory (the default
#   is /etc/skel) by changing the input location to the special null device.
# lfs
#   This is the name of the new user.

# If you want vto log in as lfs or switch to lfs from a non-root user (as opposed to
# switching to user lfs when logged in as root, which does not require the lfs user to have
# a password), you need to set a password for lfs. Issue the following command as the root
# user to set the password:
passwd lfs

# Grant lfs full access to all directories under $LFS by making lfs the owner:
chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
case $(uname -m) in
    x86_64) chown -v lfs $LFS/lib64 ;;
esac

# == Note ==
# In some host systems, the following su command does not complete properly and suspends the
# login for the lfs user to the background. If the prompt "lfs:~$" does not appear
# imediately, entering the fg command will fix the issue.
