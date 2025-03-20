#!/bin/bash

# =================================================
# =================================================
# ========   NOT TESTED   =========================
# =================================================
# =================================================

# =======================================================
# == DebianInstaller: CheckOut ==========================
#   https://wiki.debian.org/DebianInstaller/CheckOut
# =======================================================

# DebianInstaller is a collection of many small Debian packages, that can each be checked out from its own git
# repository in the usual ways. This script explains how to check out the entire DebianInstaller source tree.
# DebianInstaller developers frequently checkout the whole tree for development.

# DebianInstaller is developed using multiple git repositories. To check out the whole tree, start with a clone
# of the base git repo. Then use the 'mr' tool, package name 'myrepos', to check out the rest of the git
# repositories.
#           mr              =   https://packages.debian.org/sid/myrepos

# With root privileges:
apt install myrepos git curl wget
# Optional:
apt install fakeroot

# == Anonymous checkout (over HTTPS)
# The 'Anonymous' here means that no named account is required. It is for those who are curious about the source
# code of d-i. Also useful for creating 'patches'.
git clone https://salsa.debian.org/installer-team/d-i.git debian-installer
cd debian-installer
scripts/git-setup
mr checkout

# == Checkout for developers (over SSH)
# With the possibility to update repositories:
git clone git@salsa.debian.org:installer-team/d-i.git debian-installer
cd debian-installer
scripts/git-setup
mr checkout

# == Simplified checkout for developers
# From an empty directory, which will become the base directory for all d-i packages:
mr bootstrap https://salsa.debian.org/installer-team/d-i/raw/master/.mrconfig debian-installer

# In order to make commits to the repositories, you'll have to request to be added to the 'installer-team'
# project on salsa. For this, send a email with an explanation to the project admins.
