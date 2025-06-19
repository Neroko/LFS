#!/bin/bash

LFS_PACKAGE_TARGET='binutils-2.27.tar.bz2'    # Archive file name
LFS_PACKAGE=$LFS_SCRIPTS/binutils-2.27        # Unpacked package location
LFS_BUILD=$LFS_PACKAGE/build                  # Package build location
LOG=$LFS_LOG_PATH/5.4-binutils.log            # Log location

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
    tar -xjvf $LFS_SOURCES/$LFS_PACKAGE_TARGET -C $LFS_SCRIPTS
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function package64() { # Make symlink if 64 bit system
  ENTRY
  ENTRY_INSTALL
	if [ $BIT3264="x86_64" ]; then
		{ time {
      cd $LFS_BUILD
      case $(uname -m) in
        x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
      esac
    } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
	fi
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
    ../configure --prefix=/tools              \
                  --with-sysroot=$LFS         \
                  --with-lib-path=/tools/lib  \
                  --target=$LFS_TGT           \
                  --disable-nls               \
                  --disable-werror
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

logMaker

SCRIPTENTRY_INSTALL
SCRIPTENTRY

cleanPackage
packageExtract
packageBuild
packageMake
package64
packageInstall
cleanPackage

SCRIPTEXIT
SCRIPTEXIT_INSTALL
