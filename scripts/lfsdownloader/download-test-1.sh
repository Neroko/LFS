#!/bin/bash


# =================================================
# =================================================
# ========  NOT FULLY TESTED  =====================
# =================================================
# =================================================


# Download LFS Script and Depress/Compress ISO Debian Image

# Info used from
#   How to Create Custom Debian Based ISO
#   https://dev.to/vaiolabs_io/how-to-create-custom-debian-based-iso-4g37

# - Get the ISO from link
# - Decompress the ISO file
# - Decompress builtin filesystem and connecto to it
# - Make required changes
# - Disconnect from filesystem
# - Compress filesystem back as it was
# - Compress ISO file with all the changes

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

# Start by downloading the ISO and installing initial tools for decompressing the file, which by the way is
# another of compression format for archiving our data. Standard used for CD/DVD's is usually ISO 9660 which
# you can read about in the link provided. Let's begin by downloading the ISO file:
#   Link: https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso

# Download Debian ISO File
#   Short version:
#       wget -O "$output_file" -nc -t "$wget_tries" -c "$short_link"

wget                                    \
    --output-file="$output_file"        \
    --no-clobber                        \
    --tries="$wget_tries"               \
    --continue                          \
    "$linux_net_link"

# Once that will be done, it is good practice to have initial tool named xorriso which is the tool that creates,
# loads, manipulates and writes ISO 9660 filesystem images.

# Note:
#   We can also have used 7z or 7zip, a tool for compressing and decompressing files and images for this tasks,
#   yet, it turns out, on RedHat systems it is not isable, due to corrupted version that is kept at their
#   package repositories.

# Update, Download and Install xorriso and 7zip
install_package "xorriso"
install_package "7zip"

# and once it finish the installation. Alternative option is to use 7zip, but for some reason, the version used,
# was failing to open ISO file. We'll be able to decompress the debian file we downloaded before with this:

# Decompress Debian ISO
xorriso                                         \
    -osirrox on                                 \
    -indev "debian-12.10.0-amd64-netinst.iso"   \
    -extract / iso && chmod -R +w iso

# Output of which will crate iso folder into which all internals of files provided in the command.
# Main folders to focus on would be boot, casper and isolinux

#   root@vm-linux~/iso[]$ ls -l
#   total 68
#   drwxrwxr-x. 3   root root   4096    boot
#   drwxrwxr-x. 3   root root   4096    casper
#   drwxrwxr-x. 3   root root   4096    dists
#   drwxrwxr-x. 3   root root   4096    EFI
#   drwxrwxr-x. 2   root root   4096    install
#   drwxrwxr-x. 2   root root   12288   isolinux
#   -rw-rw-r--. 1   root root   27389   mdsums.txt
#   drwxrwxr-x. 3   root root   4096    pool
#   drwxrwxr-x. 2   root root   4096    pressed
#   lrwxrwxrwx. 1   root root   1       debian -> .

# Main folders for boot, casper and isolinux

#   boot - folder holds on the installer options of system that is used for installaion.
#   casper - holds in compresses filesystem called squashfs files as well as INITial Ram Disk (initrd) file for
#       loading filesystem and vmlinuz file which is essental Linux kernel.
#   isolinux - which provides configuration files for boot system among other things.


# =================================================
# =================================================
# ==  EXIT  =======================================
# ==  NO CASPER FOLDER FOUND IN ISO FOLDER ========
# =================================================
# =================================================


# Install disassembly tools for squashfs
install_package "squashfs-tools"
install_package "syslinux-efi"
install_package "isolinux"


# =================================================
# =================================================
# ========  TESTED TO HERE  =======================
# =================================================
# =================================================


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

# Essentially you can ch what ever you within the chrooted filesystem, including copy-pasting external files,
# saving git repositories and so in.
# Before you exit the chrooted environment, it would be good to clean up our work. By cleaning saved
# repositories files, history and storage, which in our case is translated to:
echo ' ' > /etc/resolv.conf
apt-get clean
history -c
exit

# After exiting from chroot environment, we need to squash back the file system, which can be attained as
# follows:
mksquashfs              \
    squashfs-root/      \
    filesystem.squashfs \
    -comp xz            \
    -b 1M               \
    -noappend

# Note:
#   The process will use most of CPU cores, and it will take some time, depending on how many changes we did.

# After filesystem.squashfs.squashfs file is created, we copy it to casper folder, change md5 signature and
# from there create new ISO file:
cp                      \
    filesystem.squashfs \
    ./iso/casper/

md5sum                  \
    iso/.disk/info > iso/md5sum.txt

sed                     \
    -i 's|iso/|./|g'    \
    iso/md5sum.txt

xorriso                         \
    -as mkisofs                 \
    -r                          \
    -V "Debian"                 \
    -o "debian.iso              \
    -J                          \
    -l                          \
    -b isolinux/isolinux.bin    \
    -c isolinux/boot.cat        \
    -no-emul-boot               \
    -boot-load size 4           \
    -boot-info-table            \
    -eltorito-alt-boot          \
    -e boot/grub/efi.img        \
    -no-emul-boot               \
    -isohybrid-gpt-basdat       \
    -isohybrid-apm-hfsplus      \
    -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin  \
    iso/boot                    \
    iso

# Once the process ends, we'll have new ISO file name "debian.iso" which we can burn to usb and test.
