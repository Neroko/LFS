#!/bin/bash

## Copy builder script from 'root' user directory to 'lfs' user
# directory

LFS="/mnt/lfs"
Server_LFS_Directory="/home/tj/LFS"
Server_Script_Directory=""$Server_LFS_Directory"/lfs-builder-scripts"
Client_LFS_Directory="/home/lfs/LFS"
Client_Script_Directory=""$Client_LFS_Directory"/lfs-builder-scripts"

Long_Line="-------------------------------------------------------"

clear

echo "$Long_Line"
echo "<===> LFS Builder Script Copier to 'lfs' users LFS directory <===>"

## Remove old build scripts directory:
if [ -d "$Client_Script_Directory" ]; then
    echo "$Long_Line"
    echo "<=> Remove old build scripts directory <=>"
    sudo rm -vrf "$Client_Script_Directory"
fi

## Create new build scripts directory:
if [ ! -d "$Client_Script_Directory" ]; then
    echo "$Long_Line"
    echo "<=> Create new build scripts directory <=>"
    sudo mkdir -vp "$Client_Script_Directory"
fi

## Return ownership to 'lfs' users LFS directory:
echo "$Long_Line"
echo "<=> Returning ownership of LFS directory to 'lfs' users <=>"
sudo chown -v lfs:lfs "$Client_LFS_Directory"
echo "$Long_Line"
echo "<=> Returning ownership of build scripts directory to 'lfs' users <=>"
sudo chown -v lfs:lfs "$Client_Script_Directory"

## Copy build scripts to 'lfs' users LFS directory and return
# ownership:
echo "$Long_Line"
echo "<=> Copy build scripts to 'lfs' users LFS directory and return ownership <=>"
sudo cp -vr "$Server_Script_Directory"/* "$Client_Script_Directory"

echo "$Long_Line"
echo "<=> Copy build scripts to 'lfs' users LFS directory and return ownership <=>"
sudo chmod -v +x "$Client_Script_Directory"/*

echo "$Long_Line"
echo "<=> Returning ownership of build scripts to 'lfs' users <=>"
sudo chown -v lfs:lfs "$Client_Script_Directory"/*
