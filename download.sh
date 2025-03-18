#!/bin/bash
# Download LFS Script Downloader

# Download links
short_link="https://tinyurl.com/lfs-downloader"
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
#       wget -O "$output_file" -nc -t "$wget_tries" -c "$short_link"

wget                                    \
    --output-file="$output_file"        \
    --no-clobber                        \
    --tries="$wget_tries"               \
    --continue                          \
    "$linux_net_link"

# Update, Download and Install xorriso and 7zip
install_package "xorriso"
install_package "7zip"

# Decompress Debian ISO
xorriso                                         \
    -osirrox on                                 \
    -indev "debian-12.10.0-amd64-netinst.iso"   \
    -extract / iso && chmod -R +w iso

# Output of which will crate iso folder into which all internals of files provided in the command.
# Main folders to focus on would be boot, casper and isolinux
#   boot - folder holds on the installer options of system that is used for installaion.
#   casper - holds in compresses filesystem called squashfs files as well as INITial Ram Disk (initrd) file for
#       loading filesystem and vmlinuz file which is essental Linux kernel.
#   isolinux - which provides configuration files for boot system among other things.

# Install disassembly tools for squashfs
install_package "squashfs-tools"
install_package "syslinux-efi"
install_package "isolinux"

# Copy filesystem.squashfs file into different file and adjust its parameters there
cp iso/casper/filesystem.squashfs .
cd ~
unsquashfs filesystem.squashfs      # ROOT NEEDED

# Note:
#   In Debian itself and in some other Debian Linux distributions, filesystem.squashfs might be located in
#   different location such as live or install. Please check adapt accordingly.

# Eventually, we will be left with new folder name filesystem-root.
# This is where learn that essentially, the architecture of live-ISO-filesystem is such of a system that
# includes squashed filesystem that is copied onto new media, simple SATA drive of sort, whether 'hda', 'sda',
# 'nvme0'. Once copying the filesystem is done, fakerooting is commencing, meaning that system automatically
# chooses how to install system, what partitions to use, how to configure network and so on.
# We will do the same, but without installing the system, but first, let me get a 'fakeroot'
install_package fakeroot

# 'fakeroot' Enables us to user chroot commands, which changes our root by posing us as a fake root user of
# GNU/Liunx system.
chroot squashfs-root/               # ROOT NEEDED
# Should display
#   [sudo] password for tj:
#   root@vm-linux:/#

# Now all is left is to configure stuff and then do the steps in reverse.

# Note:
#   Usually, due to use of chroot there is no network translation, thus nameserver needs to be configured
#   under /etc/resolv.conf.
#        echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# From here on, it is classical UNIX/Linux administration, insall, configure, adjust, append, delete and clean
# up the system. For sake of example, I'll install few tools:
install_package "htop"
install_package "vim"
install_package "atop"
install_package "cloud-init"