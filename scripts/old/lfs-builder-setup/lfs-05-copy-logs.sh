#!/bin/bash 

Server_User="tj"
Client_User="lfs"

LFS="/mnt/lfs"
Server_LFS_Directory="/home/"$Server_User"/LFS"
Server_Logs_Directory=""$Server_LFS_Directory"/logs"
Client_Logs_Directory=""$LFS"/logs"

Long_Line="-------------------------------------------------------"

clear

echo "$Long_Line"
echo "<===> LFS Log Copier <===>"

## Create log directory:
if [ ! -d "$Server_Logs_Directory" ]; then
    echo "$Long_Line"
    echo "<=> Create log directory <=>"
    sudo mkdir -vp "$Server_Logs_Directory"
fi

## Return ownership to 'root' users LFS directory:
echo "$Long_Line"
echo "<=> Returning ownership of LFS directory to {"$Server_User"} users <=>"
sudo chown -v "$Server_User":"$Server_User" "$Server_Logs_Directory"

## Copy build logs to 'root' users LFS directory and return
# ownership:
echo "$Long_Line"
echo "<=> Copy logs to {"$Server_User"} users LFS directory <=>"
sudo cp -vr "$Client_Logs_Directory"/* "$Server_Logs_Directory"

echo "$Long_Line"
echo "<=> Returning ownership of logs to {"$Server_User"} users <=>"
sudo chown -v "$Server_User":"$Server_User" "$Server_Logs_Directory"/*
