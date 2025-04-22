#!/bin/bash

# ========================1=========================
# =================================================
# ========   NOT FULLY TESTED   ===================
# =================================================
# =================================================

# =======================================================
# == Create custom bootable Debian Live iso =============
#   https://www.linuxquestions.org/questions/debian-26/tutorial-creating-a-custom-bootable-debian-live-iso-4175705804/
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

sudo apt-get update
sudo apt-get --yes upgrade

install_package() {
    PACKAGE="$1"
    sudo apt-get --yes install "$PACKAGE"
}

# Install needed packages:
install_package "tmux"
install_package "curl"
install_package "wget"
install_package "htop"
install_package "atop"
install_package "mc"
install_package "xorriso"
install_package "rsync"
install_package "squashfs-tools"
#install_package "syslinux"
#install_package "syslinux-efi"
#install_package "isolinux"
#install_package "fakeroot"
#install_package "vim"
#install_package "cloud-init"

# Download ISO and installing initial tools for decompressing the file, which by the way is another of
# compression format for archiving our data. Standard used for CD/DVD's is usually ISO 9660 which you
# can read about in the link provided. Download ISO file:
wget \
    --verbose \
    --continue \
    --output-document="$download_link_version" \
    ""$download_link""$download_link_version""

#curl \
#    --verbose \
#    --request GET \
#    -OL ""$download_link""$download_link_version""

# Create working directory, put iso there and cd into:
#mkdir \
#    --verbose \
#    liveusb/

#cp \
#    --verbose \
#    "$download_link_version" liveusb/

#cd \
#    liveusb/

# ===============
# == NOTE =======
# ===============
#   Idea from: https://wiki.debian.org/DebianInstaller/Modify/CD)

# Extract isohdpfx.bin:
#dd \
#    if="$download_link_version" \
#    bs=1 \
#    count=432 \
#    of=isohdpfx.bin

# ===============
# == NOTE =======
# ===============
#   Idea from: https://www.915tx.com/remaster

# Create mnt directory for mounting iso as a loop device and isoextract to hold the extracted contents
# of the iso:

#mkdir \
#    --verbose \
#    isoextract \
#    mnt

#sudo mount \
#    --verbose \
#    --options loop "$download_link_version" \
#    mnt

#sudo rsync \
#    --verbose \
#    --exclude=/live/filesystem.squashfs \
#    --archive mnt/ \
#    isoextract

# Create a new directory named squashfs-root that is the "/" directory and sub-directories from the iso:
#sudo unsquashfs \
#    mnt/live/filesystem.squashfs

# Add or delete files in squashfs-root if needed:
#sudo cp \
#    --verbose \
#    /etc/resolv.conf \
#    squashfs-root/etc/

# =================================================
# ========   NOT TESTED   =========================
# =================================================
# So that the nameservers I am currently using will be in place. I also rsynced my entire home directory 
# to /etc/skel:

#rsync -a /home/user squashfs-root/etc/skel

# This copies everything from the home directory to the iso so that all my current files and settings for
# XFCE and settings for applications will be carried over. Note that I should not have copied .mozilla
# over because firefox refused to use my old settings and demanded a new profile. You could be more
# selective with skel and just rsync the .config, .local, .themes, and .icons directories.

#You can also move debs over that are not included in Debian. I added Chrome and Zoom:

#cp /home/user/Downloads/google-chrome-stable_current_amd64 squashfs-root/opt/
#cp /home/user/Downloads/zoom_amd64.deb squashfs-root/opt/

#I also added a custom desktop wallpaper image to remove Debian branding from the desktop.

# =================================================
# =================================================
# =================================================

# Mount everything and chroot over to make changes using apt and dpkg:
#sudo mount \
#    --bind /dev/ \
#    squashfs-root/dev

#sudo chroot \
#    squashfs-root

#mount \
#    --types proc none /proc
#mount \
#    --types sysfs none /sys
#mount \
#    --types devpts none /dev/pts

#export HOME=/root
#export LC_ALL=C

# Using apt and dpkg to add or remove whatever packages you want from the iso.
#apt-get update
#apt-get full-upgrade
#apt-get install ssh
#apt-get install tmux
#apt-get install htop
#apt-get install atop
#apt-get install wget
#apt-get install curl

# After finishing up chroot environment:
#apt-get clean
#apt-get autoremove

#rm \
#    --recursive \
#    --force \
#    /tmp/* \
#    ~/.bash_history

#umount /proc
#umount /sys
#umount /dev/pts
#exit
#sudo umount squashfs-root/dev
#sudo umount mnt

# =================================================
# ========   NOT TESTED   =========================
# =================================================

# To replace grub splash image, need 640x480 resolution png image:
#cp new_splash.png ~/liveusb/isoextract/isolinux/splash.png

# To edit grub menu:
#nano ~/liveusb/isoextract/isolinux/menu.cfg

# =================================================
# =================================================
# =================================================

# Re-squash:
#mksquashfs \
#    squashfs-root \
#    isoextract/live/filesystem.squashfs

# Make new ISO
#xorriso \
#    -outdev test.iso \
#    -volid PYLIVE \
#    -padding 0 \
#    -compliance no_emul_toc \
#    -map isoextract/ / \
#    -chmod 0755 / \
#    -- \
#    -boot_image isolinux dir=/isolinux \
#    -boot_image isolinux system_area=isohdpfx.bin \
#    -boot_image any next \
#    -boot_image any efi_path=boot/grub/efi.img \
#    -boot_image isolinux partition_entry=gpt_basdat
