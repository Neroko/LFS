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

#   A minimal system requires a partition of around 10 gigabytes (GB). This is enough to store all the source
#   tarballs and compile the packages. However, if the LFS system is intended to be the pimary Linux system,
#   additional software will probably be installed which will require additional space. A 30 GB partition is a
#   reasonable size to provide for growth. The LFS system itself will not take up this much room. A large portion
#   of this requirement is to provide sufficient free temporary storage as well as for adding additional capabilities
#   after LFS is complete. Additionally, compiling packages can require a lot of disk space which will be reclaimed
#   after the package is installed.

#   Because there is not always enough Random Access Memory (RAM) available for compilation processes, it is a good
#   idea to use a small disk partition as 'swap' space. This is used by the kernel to store seldom-used data and
#   leave more memory available for active processes. Ths 'swap' partition for an LFS system can be the same as the
#   one used by the host system, in which case it is not necessary to create another one.

#   Start a disk partitioning program such as 'cfdisk' or 'fdisk' with a command line option naming the hard disk on
#   which the new partition will be created - for example '/dev/sda' for the primary disk drive. Create a Linux
#   native partition and a 'swap' partition, if needed. Please refer to 'cfdisk(8)' or 'fdisk(8)' if you do not yet
#   know how to use the programs.

# -- NOTE --
# For experienced users, other partitioning schemes are possible. The new LFS system can be on a software RAID array
# or an LVM logical volume. However, some of these options require an 'initramfs'. which is an advanced topic. These
# partitioning methodologies are not recommended for first time LFS users.

#   Remember the designation of the new partition (e.g., sda5). This script will refer to this as the LFS partition.
#   Also remember the designation of the 'swap' partition. These names will be needed later for the '/etc/fstab' file.

# = 2.4.1. Other Partition Issues
#   Requests for advice on system partitioning are often posted on the LFS mailing lists. This is a highly subjective
#   topic. The default for most distributions is to use the entire drive with the exception of one small swap partition.
#   This is not optimal for LFS for several reasons. It reduces flexibility, makes sharing of data across multiple
#   distributions or LFS builds more difficult, makes backups more time consuming, and can waste disk space through
#   inefficient allocation of file system structures.

# = 2.4.1.1. The Root Partition
#   A root LFS partition (not to be confused with the /root directory) of twenty gigabytes is a good compromise for
#   most systems. It provides enough space to build LFS and most of BLFS, but is small enough so that multiple
#   partitions can be easily created for experimentation.

# = 2.4.1.2. The Swap Partition
#   Most distributions automatically create a swap partition. Generally the recommended size of the swap partition is
#   about twice the amount of physical RAM, however this is rarely needed. If disk space is limited, hold the swap
#   partition to two gigabytes and monitor the amount of disk swapping. If you want to use the hibernation feature
#   (suspend-to-disk) of Linux, it writes out the contents of RAM to the swap partition before turning off the machine.
#   In this case the size of the swap partition should be at least as large as the system's installed RAM.
#   Swapping is never good. For mechanical hard drives you can generally tell if a system is swapping by just listening
#   to disk activity and observing how the system reacts to commands. With an SSD you will not be able to hear swapping,
#   but you can tell how much swap space is being used by running the top or free programs. Use of an SSD for a swap
#   partition should be avoided if possible. The first reaction to swapping should be to check for an unreasonable
#   command such as trying to edit a five gigabyte file. If swapping becomes a normal occurrence, the best solution is
#   to purchase more RAM for your system.

# = 2.4.1.3. The Grub Bios Partition
#   If the boot disk has been partitioned with a GUID Partition Table (GPT), then a small, typically 1 MB, partition
#   must be created if it does not already exist. This partition is not formatted, but must be available for GRUB to
#   use during installation of the boot loader. This partition will normally be labeled 'BIOS Boot' if using fdisk or
#   have a code of EF02 if using the gdisk command.

# -- Note --
# The Grub Bios partition must be on the drive that the BIOS uses to boot the system. This is not necessarily
# the drive that holds the LFS root partition. The disks on a system may use different partition table types. The
# necessity of the Grub Bios partition depends only on the partition table type of the boot disk.

# = 2.4.1.4. Convenience Partitions
#   There are several other partitions that are not required, but should be considered when designing a disk layout.
#   The following list is not comprehensive, but is meant as a guide.
#   • /boot – Highly recommended. Use this partition to store kernels and other booting information. To minimize
#     potential boot problems with larger disks, make this the first physical partition on your first disk drive. A
#     partition size of 200 megabytes is adequate.
#   • /boot/efi – The EFI System Partition, which is needed for booting the system with UEFI. Read the BLFS page for
#     details.
#   • /home – Highly recommended. Share your home directory and user customization across multiple distributions or
#     LFS builds. The size is generally fairly large and depends on available disk space.
#   • /usr – In LFS, /bin, /lib, and /sbin are symlinks to their counterparts in /usr. So /usr contains all the
#     binaries needed for the system to run. For LFS a separate partition for /usr is normally not needed. If you
#     create it anyway, you should make a partition large enough to fit all the programs and libraries in the system.
#     The root partition can be very small (maybe just one gigabyte) in this configuration, so it's suitable for a
#     thin client or diskless workstation (where /usr is mounted from a remote server). However, you should be aware
#     that an initramfs (not covered by LFS) will be needed to boot a system with a separate /usr partition.
#   • /opt – This directory is most useful for BLFS, where multiple large packages like KDE or Texlive can be installed
#     without embedding the files in the /usr hierarchy. If used, 5 to 10 gigabytes is generally adequate.
#   • /tmp – A separate /tmp partition is rare, but useful if configuring a thin client. This partition, if used, will
#     usually not need to exceed a couple of gigabytes. If you have enough RAM, you can mount a tmpfs on /tmp to make
#     access to temporary files faster.
#   • /usr/src – This partition is very useful for providing a location to store BLFS source files and share them across
#     LFS builds. It can also be used as a location for building BLFS packages. A reasonably large partition of 30-50
#     gigabytes provides plenty of room.

#   Any separate partition that you want automatically mounted when the system starts must be specified in the /etc/fstab
#   file. Details about how to specify partitions will be discussed in Section 10.2, “Creating the /etc/fstab File”.

# == 2.5. Creating a File System on the Partition
#     A partition is just a range of sectors on a disk drive, delimited by boundaries set in a partition table. Before the
#     operating system can use a partition to store any files, the partition must be formatted to contain a file system,
#     typically consisting of a label, directory blocks, data blocks, and an indexing scheme to locate a particular file
#     on demand. The file system also helps the OS keep track of free space on the partition, reserve the needed sectors
#     when a new file is created or an existing file is extended, and recycle the free data segments created when files
#     are deleted. It may also provide support for data redundancy, and for error recovery. 

#     LFS can use any file system recognized by the Linux kernel, but the most common types are ext3 and ext4. The choice
#     of the right file system can be complex; it depends on the characteristics of the files and the size of the partition.
#     For example:

#       ext2
#         is suitable for small partitions that are updated infrequently such as /boot.
#       ext3
#         is an upgrade to ext2 that includes a journal to help recover the partition's status in the case of an unclean shutdown.
#         It is commonly used as a general purpose file system.
#       ext4
#         is the latest version of the ext family of file systems. It provides several new capabilities including nano-second
#         timestamps, creation and use of very large files (up to 16 TB), and speed improvements.
#     Other file systems, including FAT32, NTFS, JFS, and XFS are useful for specialized purposes. More information about
#     these file systems, and many others, can be found at https://en.wikipedia.org/wiki/Comparison_of_file_systems.

#     LFS assumes that the root file system (/) is of type ext4. To create an ext4 file system on the LFS partition, issue the
#     following command:
#mkfs -v -t ext4 /dev/<xxx>

#     Replace <xxx> with the name of the LFS partition.
#     If you are using an existing swap partition, there is no need to format it. If a new swap partition was created, it will
#     need to be initialized with this command:
#mkswap /dev/<yyy>
#   Replace <yyy> with the name of the swap partition.

























