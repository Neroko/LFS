#!/bin/bash


# =================================================
# =================================================
# ========   NOT TESTED  ==========================
# =================================================
# =================================================


# Download LFS Script Downloader

# Info used from
#   Debian-Installer: Building the installer yourself
#   https://wiki.debian.org/DebianInstaller/Build

# This script will explain how to manually build specific images. Alternative approaches are available:
#   1.  The installer can be built like any other package (using for example 'dpkg-buildpackage' or 'debuild')
#       although this is probably not what you want, as doing this will generate images you won't need for
#       testing changes, and thus takes much longer.
#   2.  Take advantage of the fact that udeb repositories on 'salsa' should be configured to use 'branch2repo',
#       which means that if you fork such a repository and make modifications. The CI pipeline will include a
#       mini-ISO job, that creates a mini-ISO for you that incorporates your changes. This allows you to test
#       that your changes before you create an MR. It is also to launch automated tests using 'openQA'.
#       Links:
#           salsa           =   https://salsa.debian.org/
#           branch2repo     =   https://salsa.debian.org/installer-team/branch2repo
#           openQA          =   https://openqa.debian.net/

# First of all, debian-installer images should only be build in an environment that matches the version of the
# installer you want to build, so"
#   -   if you want to build the installer for development purposes, your system needs to be running unstable,
#       or you need to create a chroot environment that has unstable.
#   -   if you want to build D-I for a specific Debian release, e.g. for the current stable release, your
#       system needs to either be running the current Debian stable release, or you need to create a chroot that
#       has the stable release.

# Note
#   Don't forget to mount /proc inside chroot. mkfs.vfat is failing if you are running a chroot in sid, so it is
#   better to have a full lenny installion (could use Virtual Box or QEMU, roughly the same space as a chroot).

# If you get this wrong, build errors or non-working images are almost guaranteed! It is sometimes possiable to
# smuggle with testing and unstable, but don't expect any support from 






