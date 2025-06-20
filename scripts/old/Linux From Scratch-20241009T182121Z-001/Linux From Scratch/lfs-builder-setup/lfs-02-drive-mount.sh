#!/bin/bash

export LFS=/mnt/lfs

sudo mkdir -pv $LFS
sudo mount -v -t ext4 /dev/sda3 $LFS

