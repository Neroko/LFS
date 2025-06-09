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

display_help() {
    # Display Help
    echo "$display_title"
    echo
    echo "Syntax: $0 [OPTIONS]"
    echo "Options:"
    echo "  -h, --help                This Help Info"
    echo "  -s, --script              Output ture or false for a scprit"
    echo "  -V, --version             Script Version"
}

root_status="false"

if [[ "$EUID" -eq 0 ]]; then
    root_status="true"
    echo "Script is running as root";
    read -p "Press any key to continue..." -n1 -s;
    echo;
else
    root_status="false"
    echo "Script is not running as root";
    read -p "Press any key to continue..." -n1 -s;
    echo;
    exit 1;
fi
