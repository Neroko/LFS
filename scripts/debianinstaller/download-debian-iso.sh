#!/bin/bash

debian_version_number_link='https://www.debian.org/CD/'
debian_version_number='12.11.0'

debian_download_link='https://cdimage.debian.org/debian-cd/'

debian_netinst_link=""$debian_download_link"current/amd64/iso-cd/"
debian_netinst_filename="debian-"$debian_version_number"-amd64-netinst.iso"

debian_dvd_link=""$debian_download_link"current/amd64/iso-dvd/"
debian_dvd_filename="debian-"$debian_version_number"-amd64-DVD-1.iso"

debian_live_link=""$debian_download_link"current-live/amd64/iso-hybrid/"

debian_live_checksum_filename="SHA512SUMS"
debian_live_standard_filename="debian-live-"$debian_version_number"-amd64-standard.iso"
debian_live_kde_filename="debian-live-"$debian_version_number"-amd64-kde.iso"
debian_live_gnome_filename="debian-live-"$debian_version_number"-amd64-gnome.iso"

