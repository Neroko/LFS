#!/bin/bash
# Download LFS Script Downloader

# Download links
linux_net_link="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
linux_dvd_link="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.10.0-amd64-DVD-1.iso"
# Output filename
output_file="lfs-downloader.sh"
# Download tries
wget_tries="3"

# ROOT NEEDED
install_package() {
    apt-get update
    apt-get         \
        install     \
            --yes   \
            "$1"
}

if [ -f $output_file ]; then
    echo "File exists"
else
    echo "File does not exist"
fi

# Download Debian ISO File
#   Short version:
#       wget -O "$output_file" -nc -t "$wget_tries" -c "$linux_net_link"

wget                                    \
    --output-file="$output_file"        \
    --no-clobber                        \
    --tries="$wget_tries"               \
    --continue                          \
    "$linux_net_link"

# Update, Download and Install xorriso and 7zip
#install_package "xorriso"
#install_package "7zip"

# Decompress Debian ISO
#xorriso                                         \
#    -osirrox on                                 \
#    -indev "debian-12.10.0-amd64-netinst.iso"   \
#    -extract / iso && chmod -R +w iso

# Output of which will crate iso folder into which all internals of files provided in the command.
# Main folders to focus on would be boot, casper and isolinux
#   boot - folder holds on the installer options of system that is used for installaion.
#   casper - holds in compresses filesystem called squashfs files as well as INITial Ram Disk (initrd) file for
#       loading filesystem and vmlinuz file which is essental Linux kernel.
#   isolinux - which provides configuration files for boot system among other things.

# Install disassembly tools for squashfs
#install_package "squashfs-tools"
#install_package "syslinux-efi"
#install_package "isolinux"

# Copy filesystem.squashfs file into different file and adjust its parameters there
#cp iso/casper/filesystem.squashfs .
#cd ~
#unsquashfs filesystem.squashfs      # ROOT NEEDED

#install_package fakeroot
