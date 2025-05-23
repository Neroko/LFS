#!/bin/bash

###################################
## -------- DO NOT EDIT -------- ##
## -----------TRY TO ----------- ##
## -- USE ONLINE VERSION ONLY -- ##
###################################

display_title="== Linux From Scratch (LFS) - Root Check =="
#
# VERSION (LFS):
current_version="12.3"
#
# VERSION (SCRIPT):
script_version="1.0.0.0"
#
# DATE LAST EDITED:
#   05/22/2025
#
# DATE CREATED:
#   05/21/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# USAGE:
#   root-check.sh
# or in a script:
#   source root-user.sh
#
# DESCRIPTION
#   Script to check if running as root user.

if [[ "$EUID" -eq 0 ]]; then
    echo "Script is running as root";
    read -p "Press any key to continue..." -n1 -s;
else
    echo "Script is not running as root";
    read -p "Press any key to continue..." -n1 -s;
    exit 1;
fi
