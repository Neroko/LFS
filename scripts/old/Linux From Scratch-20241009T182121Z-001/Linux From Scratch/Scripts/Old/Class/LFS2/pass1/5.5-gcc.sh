#!/bin/bash

LFS_SOURCES=$LFS/sources
LFS_PACKAGE=$LFS_SOURCES/pass1/gcc-6.3.0
LFS_BUILD=$LFS_PACKAGE/build
BIT3264=grep | uname -m &> /dev/null

rm -rf $LFS_PACKAGE

time {
echo "------------------------------"
echo "GCC 6.3.0 - Pass 1"
echo "------------------------------"

echo "-Extracting Files..."
tar -xjf $LFS_SOURCES/gcc-6.3.0.tar.bz2

function packagesetup() {
	cd $LFS_PACKAGE
	tar -xf $LFS_SOURCES/mpfr-3.1.5.tar.xz
	mv mpfr-3.1.5 $LFS_PACKAGE/mpfr
	tar -xf $LFS_SOURCES/gmp-6.1.2.tar.xz
	mv gmp-6.1.2 $LFS_PACKAGE/gmp
	tar -xf $LFS_SOURCES/mpc-1.0.3.tar.gz
	mv mpc-1.0.3 $LFS_PACKAGE/mpc

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
function package64() {
	cd $LFS_PACKAGE
	if [ $BIT3264="x86_64" ]; then
		echo "-Making 64 Bit symlink..."
		{
		case $(uname -m) in
			x86_64)
				sed -e '/m64=/s/lib64/lib/' \
				    -i.orig gcc/config/i386/t-linux64
			 ;;
		esac
		} &> /dev/null
	fi
}
function packagebuild() {
	mkdir $LFS_BUILD
	cd $LFS_BUILD
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
}
function packagemake() {
	cd $LFS_BUILD
	make -j8
}
function packageinstall() {
	cd $LFS_BUILD
	make install
}

echo "-Setting up GCC..."
packagesetup &> /dev/null
echo "-Checking system..."
package64
echo "-Compilation of GCC..."
packagebuild &> /dev/null

time {
echo "-Compilation of package..."
packagemake #&> /dev/null

echo "-Installing package..."
#packageinstall #&> /dev/null

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
