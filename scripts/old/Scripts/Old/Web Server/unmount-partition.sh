#!/bin/bash

rootPartition="/mnt/lfs"
bootPartition="$rootPartition/boot"
homePartition="$rootPartition/home"

clear
df -h
echo "--------------------"
umount -R $homePartition
umount -R $bootPartition
umount -R $rootPartition
echo "--------------------"
df -h
echo "--------------------"
