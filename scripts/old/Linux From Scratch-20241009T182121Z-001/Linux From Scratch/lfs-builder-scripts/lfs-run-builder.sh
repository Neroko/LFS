#!/bin/bash

## TO-DO
# Fix that when you exit one of the scripts, it does'nt go on to the next one.
# Have this Script check exit status of each one.
# If 1, exit with error message

LFS_Directory="/home/lfs/LFS"
Script_Directory=""$LFS_Directory"/lfs-builder-scripts"

Long_Line="-------------------------------------------------------"

clear

echo "$Long_Line"
echo "<===> LFS Run Builder Script's <===>"
bash ""$Script_Directory"/lfs-chapter-5-2.sh"
bash ""$Script_Directory"/lfs-chapter-5-3.sh"
bash ""$Script_Directory"/lfs-chapter-5-4.sh"
bash ""$Script_Directory"/lfs-chapter-5-5.sh"
bash ""$Script_Directory"/lfs-chapter-5-6.sh"
bash ""$Script_Directory"/lfs-chapter-6-2.sh"
bash ""$Script_Directory"/lfs-chapter-6-3.sh"
bash ""$Script_Directory"/lfs-chapter-6-4.sh"
bash ""$Script_Directory"/lfs-chapter-6-5.sh"

exit 0
