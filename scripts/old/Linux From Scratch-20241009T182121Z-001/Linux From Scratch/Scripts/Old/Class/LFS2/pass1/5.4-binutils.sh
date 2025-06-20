#!/bin/bash

LFS_SOURCES=$LFS/sources
LFS_PACKAGE=$LFS_SOURCES/pass1/binutils-2.27
LFS_BUILD=$LFS_PACKAGE/build
BIT3264=grep | uname -m &> /dev/null

rm -rf $LFS_PACKAGE
rm -rf $LFS_SOURCES/pass1/5.4-binutils.log

time {
echo "------------------------------"
echo "Binutils 2.27 - Pass 1"
echo "------------------------------"

echo "-Extracting Files..."
tar -xjf $LFS_SOURCES/binutils-2.27.tar.bz2

function packagebuild() {
	mkdir $LFS_BUILD
	cd $LFS_BUILD
	../configure --prefix=/tools            \
                     --with-sysroot=$LFS        \
                     --with-lib-path=/tools/lib \
                     --target=$LFS_TGT          \
                     --disable-nls              \
                     --disable-werror
	
}
function packagemake() {
	cd $LFS_BUILD
	make -j8 3>&1 1>/dev/null 2>&3- | tee $LFS_SOURCES/pass1/5.4-binutils.log
}
function package64() {
	cd $LFS_BUILD
	if [ $BIT3264="x86_64" ]; then
		echo "-Making 64 Bit symlink..."
		{
		case $(uname -m) in
			x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
		esac
		} &> /dev/null
	fi
}
function packageinstall() {
	cd $LFS_BUILD
	make install
}

echo "-Compilation of Binutils..."
packagebuild &> /dev/null
time {
echo "-Compilation of package..."
packagemake &> /dev/null
echo "-Checking system..."
package64
echo "-Installing package..."
packageinstall &> /dev/null
echo "------------------------------"
}
echo "------------------------------"
echo "-Removing temp files..."
rm -rf $LFS_PACKAGE
echo "------------------------------"
}
echo "------------------------------"
echo "          Complete            "
echo "------------------------------"
