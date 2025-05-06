#!/bin/bash

display_title="== Linux From Scratch (LFS) Setup System =="
#
# VERSION (LFS):
current_version="12.3"
#
# VERSION (SCRIPT):
script_version="1.0.0.0"
#
# DATE LAST EDITED:
#   05/06/2025
#
# DATE CREATED:
#   05/06/2025
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

# == 2.3. Building LFS in Stages
#   LFS is designed to be build in one session. That is, the instructions assume that the system will not be shut down
#   during the process. This does not mean that the system has to build in one sitting. The issue is that certain
#   procedures must be repeated after a reboot when resuming LFS at different points.

# = 2.3.1. Chapters 1-4
#   These chapters run commands on the host system. When restarting, be certaub of one thing:
#   - Procedures performed as the 'root' user after Section 2.4 must have the LFS environment variable set FOR THE
#     ROOT USER.

# = 2.3.2. Chapters 5-6
#   - The /mnt/lfs partition must be mounted.
#   - These two chapters must be done as user 'lfs'. A 'su - lfs' command must be issued before performing any task in
#     these chapters. If you don't do that, you are at risk of installing packages to the host, and potentially
#     rendering it unusable.
#   - The procedures in General Compilation Instructions are critical. If there is any doubt a package has been
#     installed correctly, ensure the previously expanded tarball has been removed, then re-extract the package, and
#     complete all the instructions in that section.

# = 2.3.3. Chapters 7-10
#   - The /mnt/lfs partition must be mounted.
#   - A few operations, from "Preparing Virtual Kernel File Systems" to "Entering the Chroot Environment," must be
#     done as the 'root' user, with the LFS environment variable set for the 'root' user.
#   - When entering chroot, the LFS environment variable must be set for 'root'. The LFS variable is not used after
#     the chroot environment has been entered.
#   - The virtual file systems must be mounted. This can be done before or after entering chroot by changing to a
#     host virtual terminal and, as 'root', running the commands in Section 7.3.1, "Mounting and Populating /dev"
#     and Section 7.3.2, "Mounting Virtual Kernel File Systems."

# == 2.4. Creating a New Partition 
#   Like most other operating systems, LFS is usually installed on a dedicated partition. The recommended approach
#   to building an LFS system is to use an available empty partition or, if you have enough unpartitioned space, to
#   create one.









