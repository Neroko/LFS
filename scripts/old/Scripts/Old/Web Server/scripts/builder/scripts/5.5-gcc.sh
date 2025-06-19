#!/bin/bash

LFS_PACKAGE_TARGET='gcc-6.3.0.tar.bz2'        # Archive file name
LFS_PACKAGE=$LFS_SCRIPTS/gcc-6.3.0            # Unpacked package location
LFS_BUILD=$LFS_PACKAGE/build                  # Package build location
LOG=$LFS_LOG_PATH/5.5-gcc.log                 # Log location

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

function packageExtra() { # Extract extra packages from archive
  ENTRY
  ENTRY_INSTALL
  { time {
    cd $LFS_PACKAGE
    tar -xvf $LFS_SOURCES/mpfr-3.1.5.tar.xz -C $LFS_PACKAGE
    tar -xvf $LFS_SOURCES/gmp-6.1.2.tar.xz -C $LFS_PACKAGE
    tar -xvf $LFS_SOURCES/mpc-1.0.3.tar.gz -C $LFS_PACKAGE
    mv -v mpfr-3.1.5 $LFS_PACKAGE/mpfr
    mv -v gmp-6.1.2 $LFS_PACKAGE/gmp
    mv -v mpc-1.0.3 $LFS_PACKAGE/mpc
# I believe the lines below are giving me problems when it gets to 5.7 glibc test
    {
      for file in gcc/config/{linux,i386/linux{,64}}.h
      do
        cp -uv $file{,.orig}
        sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
            -e 's@/usr@/tools@g' $file.orig > $file
        echo '
      #undef STANDARD_STARTFILE_PREFIX_1
      #undef STANDARD_STARTFILE_PREFIX_2
      #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
      #define STANDARD_STARTFILE_PREFIX_2 ""' >> $ file
        touch $file.orig
      done
    }
  } 2>&1 | tee -a $LOG &> /dev/null; } 2>&1 | grep "real" | awk '{print $2}' | tee -a $LOG_INSTALL &> /dev/null
  EXIT
}

function package64() { # Make symlink if 64 bit system
  ENTRY
  ENTRY_INSTALL
	if [ $BIT3264="x86_64" ]; then
		{ time {
      cd $LFS_PACKAGE
      case $(uname -m) in
        x86_64)
          sed -e '/m64=/s/lib64/lib/' \
          -i.orig gcc/config/i386/t-linux64
        ;;
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
    ../configure --target=$LFS_TGT                              \
                 --prefix=/tools                                \
                 --with-glibc-version=2.11                      \
                 --with-sysroot=$LFS                            \
                 --with-newlib                                  \
                 --without-headers                              \
                 --with-local-prefix=/tools                     \
                 --with-native-system-header-dir=/tools/include \
                 --disable-nls                                  \
                 --disable-shared                               \
                 --disable-multilib                             \
                 --disable-decimal-float                        \
                 --disable-threads                              \
                 --disable-libatomic                            \
                 --disable-libgomp                              \
                 --disable-libmpx                               \
                 --disable-libquadmath                          \
                 --disable-libssp                               \
                 --disable-libvtv                               \
                 --disable-libstdcxx                            \
                 --enable-languages=c,c++
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
packageExtra
package64
packageBuild
packageMake
packageInstall
cleanPackage

SCRIPTEXIT
SCRIPTEXIT_INSTALL
