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
#   06/09/2025
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

root_status="false"

check_root() {
    if [[ "$EUID" -eq 0 ]]; then
        root_status="true"
        echo "Script is running as root"
        echo "$root_status"
        read -p "Press any key to continue..." -n1 -s
        echo
    else
        root_status="false"
        echo "Script is not running as root"
        echo "$root_status"
        read -p "Press any key to continue..." -n1 -s
        echo
        exit 1
    fi
}

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

display_version() {
    # Display Version
    echo "$display_title"
    echo "Version (LFS): "$current_version""
    echo "Version (Script): "$script_version""
}

handle_options() {
    # Fuction to handle options and arguments
    while [ $# -gt 0 ]; do
        case $1 in
            -h | --help)
                display_help
                exit 0
                ;;
            -V | --version)
                display_version
                exit 0
                ;;
            *)
                echo "Invalid options: $1" >&2
                display_help
                exit 1
                ;;
        esac
        shift
    done
}

handle_options "$@"

check_root
