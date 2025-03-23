#!/bin/bash

# =================================================
# =================================================
# ========   NOT TESTED   =========================
# =================================================
# =================================================

# =======================================================
# == DebianInstaller: Build =============================
#   https://wiki.debian.org/DebianInstaller/Build
# =======================================================

# This script explains how to manually build specific images. Alternative approaches are available:
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

# ===============
# == NOTE =======
# ===============
#   Don't forget to mount /proc inside chroot. mkfs.vfat is failing if you are running a chroot in sid, so it is
#   better to have a full lenny installion (could use Virtual Box or QEMU, roughly the same space as a chroot).

# If you get this wrong, build errors or non-working images are almost guaranteed! It is sometimes possiable to
# smuggle with testing and unstable, but don't expect any support from 

# This same procedure can also be followed to build the installer from testing, using udebs from testing. But
# you should be aware that there are periods during which it is very likely that builds from testing are broken,
# especially:
#   (1) the period after a new Debian stable release and before the first alpha release of D-I for that newt
#       Debian release
#   (2) when a new release of D-I is being prepared. Building the installer from testing is only really
#       advisable when there is a Release Candidate (RC) release of debian-installer in testing.

# ===============
# == IMPORTANT ==
#   If you build the installer for release purposes, make sure your build environment is "clean", i.e. that it
#   is up-to-date and that you don't have any weird (versions of) packages installed from external repositories.
#   If your system is not clean, use for example 'pbuilder' or create a chroot environment.
# ===============

# Build 'debian-installer' and download required udebs.

# == Get the source
#   Download CheckOut:
#   Link    = https://wiki.debian.org/DebianInstaller/CheckOut

# == Preparing the build system
#   -   Change to the directory 'installer/' under you TOP directory

#   -   Read 'build/README'

#   -   Install the build-dependencies on the host system (or in the chroot):
apt install build-dep debian-installer
# build-dep did not work, trying build-essential

#   -   Verify that the build dependencies are all met using 'dpkg-checkbuilddeps'. You may still see
#       something like:
dpkg-checkbuilddeps
#           dpkg-checkbuilddeps: Unmet build dependencies:
#               grep-dctrl
#                   debiandoc-sgml
#                   glibc-pic
#                   libparted1.6-13
#                   libslang2-pic
#                   libnewt-pic
#                   libdiscover1-pic
#                   libbogl-dev
#                   genext2fs (>= 1.3-7.1)
#                   mklibs (>= 0.1.15)
#                   mkisofs
#                   dosfstools
#                   syslinux (>= 2.11-0.1)
#                   tofrodos
#                   bf-utf-source
#                   upx-ucl-beta (>= 1:1.91+0.20030910cvs-2)
#       whixh means some build dependencies ar still missing. Correct this by installing the missing packages,
#       for example:
aptitude install -R grep-dctrl debiandoc-sgml [...]
#       repeat the check until 'dpkg-checkbuilddeps' no longer reports any missing dependencies.

#   -   Check that the variables 'DEBIAN_RELEASE' and 'USE_UDEBS_FROM' in the file 'build/config/common' are set
#       correctly:
#       -   if you are building the installer for development purposes (from Git HEAD), no changes should be
#           needed;
#       -   if you are building the installer for stable or oldstable, the variables should be set to the
#       -   codename of that Debian release; if not you need to change them;
#       -   if you are building the installer for testing; it is likely you will need to change at least
#           the variable 'USE_UDEBS_FROM' to the codename for testing.

# == Building an image
#   -   Change to the directory 'installer/build'.

#   -   Run 'make' to get a list of available targets.

#   -   Build an image using one of the "build" targets ('build_netboot', 'all_build', etc.)
make reallyclean
fakeroot make build_netboot

#   Because your build environment is for the same Debian release as the version of debian-installer you want to
#   build, the build system should automatically generate a correct 'sources.list.udeb' file based on your
#   'etc/apt/sources.list'. However, in some cases it may be necessary to create a 'sources.list.udeb.local'.
#   In some cases you have to explicitly provide main/debian-installer section in the sources.list file of your
#   chroot or local installation.

#   -   Look in 'dest/' for the completed images.

#   -   Look in 'dest/MANIFEST.udebs' for the udebs associated with this image.

# == Adding a udeb or files to the built image
#   The list of packages added to the netboot image is in 'installer/build/pkg-lists/netboot/yourarch.cfg', you
#   can try add the desired package there.

#   In order to just add a few files, you can create your own udeb package:
#   -   Create a 'control' file containing:
Package:    mypackage
Files: /my/file/on/my/drive /where/to/put/it/in/installer
 /my/other/file /another/place/in/installer 

#   -   run 'equivs-build control', that will create 'mypackage_1.0_all.deb' which you can rename to
#       'mypackage.udeb', and put it into 'installer/build/localudebs'. You can then add 'mypackage' in
#       'installer/build/pkg-lists/netboot/yourarch.cfg'.

# == Questions
#   -   How does one build an image which also contains a repository, like the netinst images contain?
#       A: This is normally done using 'debian-cd'; see also DebianInstaller/Modify:
#       Link: https://wiki.debian.org/DebianInstaller/Modify

#   -   If I'm not able to rebuild Debian-Installer from source, what should I do?
#       A: Persist. Most likely you are already subscribed mailinglist debian-boot where development of d-i
#       is discussed.
#           Explain in an e-mail to that ML where you are stuck.
