#!/bin/bash
# Download LFS Script Downloader

linux_net_link="https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.10.0-amd64-netinst.iso"
linux_dvd_link="https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.10.0-amd64-DVD-1.iso"
output_file="lfs-downloader.sh"
wget_tries="3"

wget -O "$output_file" -nc -t "$wget_tries" -c "$linux_net_link"

wget                                    \
    --output-file="$output_file"        \
    --no-clobber                        \
    --tries="$wget_tries"               \
    --continue                          \
    "$linux_net_link"
