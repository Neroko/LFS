#!/bin/bash

LFS_PACKAGE_TARGET='glibc-2.25.tar.xz'        # Archive file name
LFS_PACKAGE=$LFS_SCRIPTS/glibc-2.25           # Unpacked package location
LFS_BUILD=$LFS_PACKAGE/build                  # Package build location
LOG=$LFS_LOG_PATH/5.7-glibc.log               # Log location

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

function packageBuild() { # Build package from archive
  ENTRY
  ENTRY_INSTALL
  { time {
    INFO "Making Build Folder"
    mkdir -v $LFS_BUILD
    cd $LFS_BUILD
    INFO "Building Package"
    ../configure --prefix=/tools                              \
                 --host=$LFS_TGT                              \
                 --build=$($LFS_PACKAGE/scripts/config.guess) \
                 --enable-kernel=2.6.32                       \
                 --with-headers=/tools/include                \
                 libc_cv_forced_unwind=yes                    \
                 libc_cv_c_cleanup=yes
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function packageMake() { # Make package from build
  ENTRY
  ENTRY_INSTALL
  { time {
    cd $LFS_BUILD
    INFO "Making Package"
    make $processors
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function packageInstall() { # Install package from build
  ENTRY
  ENTRY_INSTALL
  { time {
    cd $LFS_BUILD
    INFO "Installing Package"
    make install
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function installCheck() {
  ENTRY
  ENTRY_INSTALL
  {
    cd $LFS_BUILD
    echo 'int main(){}' > dummy.c
    $LFS_TGT-gcc dummy.c
    glibcCheck=$(readelf -l a.out | grep ': /tools')
    if [[ $glibcCheck = "[Requesting program interpreter: /tools/lib/ld-linux.so.2]" ]]; then
      INFO "Glibc 32 Bit Test: Pass"
      glibcCheckStatus="32"
    elif [[ $glibcCheck = "[Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]" ]]; then
      INFO "Glibc 64 Bit Test: Pass"
      glibcCheckStatus="64"
    else
      ERROR "Glibc Test: Failed"
      glibcCheckStatus="0"
    fi
    rm -v dummy.c a.out
  } 2>&1 | tee -a $LOG &> /dev/null
  EXIT
}

logMaker

SCRIPTENTRY_INSTALL
SCRIPTENTRY

cleanPackage
packageExtract
packageBuild
packageMake
packageInstall
installCheck
cleanPackage

SCRIPTEXIT
SCRIPTEXIT_INSTALL
