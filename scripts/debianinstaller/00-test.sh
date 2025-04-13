#!/bin/bash

# =================================================
# =================================================
# ========   NOT TESTED   =========================
# =================================================
# =================================================

# =======================================================
# == Create Custom Debian Based ISO =====================
#   https://dev.to/vaiolabs_io/how-to-create-custom-debian-based-iso-4g37
# =======================================================

# - Get Debian ISO
download_link="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.10.0-amd64-DVD-1.iso"
# - Decompress the ISO file
# - Decompress builtin filesystem and connect to it
# - Make required changes
# - Disconnect from filesystem
# - Compress filesystem back as it was
# - Compress ISO file with all changes

#
# Download ISO and installing initial tools for decompressing the file, which by the way is another of
# compression format for archiving our data. Standard used for CD/DVD's is usually ISO 9660 which you
# can read about in the link provided. Download ISO file:
apt update
apt full-upgrade
apt install \
    curl \
    wget
curl -X GET -OL "$download_link"

# Once its done, it is good practice to have initial tool named 'xorriso' which is the tool that creates, loads,
# manipulates and writes ISO 9660 filesystem images.

# ===============
# == NOTE =======
# ===============
#   Can also use '7z' or '7zip', a tool for compressing and decompressing files and images for this task.
# Execute Install:
apt install \
    xorriso

# ===============
# == NOTE =======
# ===============
#   Alternative option is use 7zip, but for some reson, the version used, was failing to open ISO file.

# Decompress File:
xorriso -osirrox on -indev "$download_link" -extract / iso && chmod -R +w iso

# Output will crate 'iso' folder into which all internals of files provided in the command.

# ls -l
#   total 68
#   drwxrwxr-x. 3 aschapelle aschapelle  4096 Feb 23 11:26 boot
#   drwxrwxr-x. 3 aschapelle aschapelle  4096 Feb 23 11:26 casper
#   drwxrwxr-x. 3 aschapelle aschapelle  4096 Feb 23 11:26 dists
#   drwxrwxr-x. 3 aschapelle aschapelle  4096 Feb 23 11:26 EFI
#   drwxrwxr-x. 2 aschapelle aschapelle  4096 Feb 23 11:26 install
#   drwxrwxr-x. 2 aschapelle aschapelle 12288 Feb 23 11:26 isolinux
#   -rw-rw-r--. 1 aschapelle aschapelle 27389 Feb 23 11:26 md5sum.txt
#   drwxrwxr-x. 3 aschapelle aschapelle  4096 Feb 23 11:26 pool
#   drwxrwxr-x. 2 aschapelle aschapelle  4096 Feb 23 11:26 preseed
#   lrwxrwxrwx. 1 aschapelle aschapelle     1 Apr 23 16:14 ubuntu -> .

# main folders to focus on are boot, casper and isolinux.
# - 'boot' folder holds on the installer options of live system that is used for installion
# - 'casper' holds in compresses filesystem called squashfs files as well as INITial Ram Disk (initrd) file
#   file for loading filesystem and vmlinuz file which is essential Linux kernal.
# - 'isolinux' which provides configuration files for boot system among other things

# Diassemble, one of the filesystems in casper folder, edit it, configure it and customize it while later, patch
# it back for further use.

# ===============
# == NOTE =======
# ===============
#   I'll be publishing other tutories where these details can  be in regards to use cases of different ISO
#   implementations.

# Disassembly tool for squashfs:
apt install \
    squashfs-tools \
    syslinux \
    syslinux-efi \
    isolinux

# Copy the 'filesystem.squashfs' file into different file and adjust its parameters there
cp iso/casper/filesystem.squashfs .
cd ~
unsquashfs filesystem.squashfs

# Output:
