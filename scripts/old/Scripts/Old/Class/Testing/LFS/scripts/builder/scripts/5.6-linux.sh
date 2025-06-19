#!/bin/bash

LFS_PACKAGE_TARGET='linux-4.9.9.tar.xz'    # Archive file name
LFS_PACKAGE=$LFS_SCRIPTS/linux-4.9.9       # Unpacked package location
LOG=$LFS_LOG_PATH/5.6-linux.log            # Log location

function cleanPackage() { # Delete old package
  ENTRY
  ENTRY_INSTALL
  { time {
    if [ -d "$LFS_PACKAGE" ]; then
      INFO "Removing Old Package"
      rm -rf $LFS_PACKAGE
    fi
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function packageExtract() { # Extract package from archive
  ENTRY
  ENTRY_INSTALL
  { time {
    INFO "Extracting $LFS_PACKAGE_TARGET"
    tar -xvf $LFS_SOURCES/$LFS_PACKAGE_TARGET
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function packageMake() { # Make package from build
  ENTRY
  ENTRY_INSTALL
  { time {
    cd $LFS_PACKAGE
    INFO "Making Package"
    make mrproper
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function packageInstall() { # Install package from build
  ENTRY
  ENTRY_INSTALL
  { time {
    cd $LFS_PACKAGE
    INFO "Installing Package"
    make INSTALL_HDR_PATH=dest headers_install
    cp -rv dest/include/* /tools/include
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

logMaker

SCRIPTENTRY_INSTALL
SCRIPTENTRY

cleanPackage
packageExtract
packageMake
packageInstall
cleanPackage

SCRIPTEXIT
SCRIPTEXIT_INSTALL
