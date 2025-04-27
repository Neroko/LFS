#!/bin/bash

# =================================================
# =================================================
# ========   NOT FULLY TESTED   ===================
# =================================================
# =================================================

# =======================================================
# == Create Custom Debian Based ISO =====================
#   https://dev.to/vaiolabs_io/how-to-create-custom-debian-based-iso-4g37
# =======================================================

# - Get Debian ISO
download_link="https://cdimage.debian.org/debian-cd/current-live/amd64/iso-hybrid/"
download_link_version="debian-live-12.10.0-amd64-standard.iso"
# - Decompress the ISO file
# - Decompress builtin filesystem and connect to it
# - Make required changes
# - Disconnect from filesystem
# - Compress filesystem back as it was
# - Compress ISO file with all changes

install_package() {
    PACKAGE="$1"
    apt update
    apt full-upgrade
    apt install "$PACKAGE"
}

# Install needed packages:
install_package "curl"
install_package "wget"
install_package "htop"
install_package "mc"
install_package "xorriso"
install_package "squashfs-tools"
install_package "syslinux"
install_package "syslinux-efi"
install_package "isolinux"
install_package "fakeroot"
install_package "vim"
install_package "atop"
install_package "cloud-init"

# Download ISO and installing initial tools for decompressing the file, which by the way is another of
# compression format for archiving our data. Standard used for CD/DVD's is usually ISO 9660 which you
# can read about in the link provided. Download ISO file:
curl \
    --request GET \
    -OL ""$download_link""$download_link_version""

# Once its done, it is good practice to have initial tool named 'xorriso' which is the tool that creates, loads,
# manipulates and writes ISO 9660 filesystem images.

# ===============
# == NOTE =======
# ===============
#   Can also use '7z' or '7zip', a tool for compressing and decompressing files and images for this task.
# Execute Install, Decompress File:
xorriso \
    -osirrox on \
    -indev "$download_link_version" \
    -extract / iso && chmod -R +w iso

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
#apt install \
#    squashfs-tools \
#    syslinux \
#    syslinux-efi \
#    isolinux

# ===============
# == NOTE =======
# ===============
# no iso/casper director found!

# Copy the 'filesystem.squashfs' file into different file and adjust its parameters there
#cp iso/casper/filesystem.squashfs .
cp iso/debian/live/filesystem.squashfs .
cd ~
unsquashfs filesystem.squashfs

# Output:
#   Parallel unsquashfs: Using 4 porcessors
#   33457 inodes (38383 blocks) to write
#   [===============================================|] 38383/38383 100%
#   created 29764 files
#   created 3675 directories
#   created 3572 symlinks
#   created 9 devices
#   created 0 fifos

# ===============
# == NOTE =======
# ===============
#   In Debian itself and in some other Debian Linux distributions, 'filesystem.squashfs' might be located in
#   differnt location such as 'live' or 'install'. Check adapt accordingly.

# Eventually, we will be left with new folder name filesystem-root.
# This is where learn that essentially, the architecture of live-ISO-filesystem is such of a system that
# includes squashed filesystem that is copied onto new media, simple SATA drive of sort, whether 'hda', 'sda',
# or 'nvme0'. Once copying the filesystem is done, 'fakerooting' is commencing, meaning that system
# automatically chooses how to install system, what partitions to use, how to configure network and so on.

# We ill do the same, but without installing the system, first, make 'fakeroot':
#apt install \
#    fakeroot

# 'fakeroot' Enables us to user chroot commands, which changes our root by posing us as a fake root user of
# GNU/Linux system.
chroot squashfs-root/
# [sudo] password for username:
# root@username:/#

# Now, configure stuff and then do the steps in reverse.

# ===============
# == NOTE =======
# ===============
#   Usually, due to use of chroot there is no network translation, thus nameserver needs to be configured
#   under /etc/resolv.conf:
echo 'nameserver 8.8.8.8' > /etc/resolv.conf

# From here on, it is classical UNIX/Linux administration, install, configure, adjust, append, delete and clean
# up the system. For sake of example, I'll install few tool:
#apt install \
#    vim \
#    atop \
#    cloud-init

# Essentially you can ch what ever you within the chrooted filesystem. including copy-pasting external files,
# saving git repositories and so on.
# Before you exit the chrooted environment it would be good to clean up our work, by cleaning saved repositories
# files, history and storage, which in our case is translated to:
echo ' ' > /etc/resolv.conf
apt clean
history -c
exit

# After exiting from chroot environment, we need to squash back the file system, which can be attained as
# follows:
mksquashfs \
    squashfs-root/ \
    filesystem.squashfs \
    -comp xz \
    -b 1M \
    -noappend

# =================================================
# =================================================
# ========   TESTED TO HERE   =====================
# =================================================
# =================================================

# ===============
# == NOTE =======
# ===============
#   The process will use most of CPU cores, and it will take some time, depending on how many changes we did.

# After filesystem.squashfs file is created, we copy it to casper folder, change md5 signature and from there
# create new ISO file:
cp filesystem.squashfs ./iso/casper/
md5sum iso/.disk/info > iso/md5sum.txt
sed -i 's|iso/|./|g' iso/md5sum.txt
xorris \
    -as mkisofs \
    -r \
    -V "Debian Custom amd64" \
    -o debian-custom-amd64.iso \
    -J \
    -l \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -e boot/grub/efi.img \
    -no-emul-boot \
    -isohybrid-gpt-basdat \
    -isohybrid-apm-hfsplus \
    -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin iso/boot iso

# Once the process ends, we'll have new ISO file name debian-custom-amd64.iso which we can burn to usb and test
# it out.
