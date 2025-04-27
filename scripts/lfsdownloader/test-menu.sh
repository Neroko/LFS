#!/bin/bash

# Linux From Scratch (LFS) Test Menu
#
# VERSION (LFS):
#   12.2
#
# VERSION (SCRIPT):
#   1.0.0.1
#
# DATE LAST EDITED:
#   03/04/2025
#
# DATE CREATED:
#   03/03/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# DESCRIPTION
#   Script to test a menu screen
#
# USAGE:
#   test-menu.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions

command -v dialog >/dev/null 2>&1 || {
    echo >&2 "Require Dialog, but it's not installed. Aborting";
    exit 1;
}

back_title="Linux From Scratch (LFS)"
title="Setup"
version_check="lfs-version-check.sh"            # <<---- FIX ME

items=(
    1 "Version Check"
    2 "Setup Sources Directory"
    3 "Download Sources"
    4 "Setup Tools Directory"
    5 "Setup LFS User"
    6 "Delete Sources Directory"
    7 "Delete Tools Directory"
)

while choice=$(dialog \
                --cancel-label "Exit" \
                --title "$title" \
                --backtitle "$back_title" \
                --clear \
                --menu "" 15 40 5 "${items[@]}" \
                2>&1 >/dev/tty)
    do; case $choice in
        1)
            source "$version_check"
            read -p "Press any key to continue..." -n1 -s
            continue
        ;;
        2)
            df -h
            sleep 3
            continue
        ;;
        3) ;;
        4) ;;
    esac
done

clear   # Clear after user pressed Exit
