#!/bin/bash
# Linux From Scratch (LFS) 5.3. GCC-14.2.0 - Pass 1
#
# VERSION (LFS):
#   12.2
#
# VERSION (SCRIPT):
#   1.0.0.1
#
# DATE LAST EDITED:
#   03/05/2025
#
# DATE CREATED:
#   03/05/2025
#
# AUTHOR:
#   TerryJohn Anscombe
#
# USAGE:
#   5.3-GCC-P1.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
# DESCRIPTION
#   The GCC package contains the GNU compiler collection, which includes the C and C++
#   compilers.
#       Approximate build time:     3.2 SBU
#       Required disk space:        4.9 GB
#
# =======================
# == SCRIPT NOT TESTED ==
# =======================

# 5.3.1. Installation of Cross GCC
#   GCC requires the GMP, MPFR and MPC packages. As these packages may not be includded in
#   your host distribution, they will be built with GCC. Unpack each package into the GCC
#   source directory and rename the resulting directories so the GCC build procedures will
#   automatically use them:


# -------------------------------------------
# -------------------------------------------
# Add unzipping of package to directory
# -------------------------------------------
# -------------------------------------------


# -- Note --
#   There are frequent misunderstandings about this chapter. The procedures are the same as
#   every other chapter, as explained earlier (Package build instructions). First, extract
#   the gcc-14.2.0 tarball from the sources directory, and then changes to the directory
#   created. Only then should you proceed with the instructions below.

tar -xf ../mpfr-4.2.1.tar.xz
mv -v mpfr-4.2.1 mpft
tar -xf ../gmp-6.3.0.tar.xz
mv -v gmp-6.3.0 gmp
tar -xf ../mpc-1.3.1.tar.gz
mv -v mpc-1.3.1 mpc

# On x86_64 hosts, set the default directory name for 64-bit libraries to "lib":
case $(uname -m) in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
    ;;
esac

# The GCC documentation recommends building GCC in a dedicated build directory:
mkdir -v build
cd build

# Prepare GCC for compilation:
../configure                    \
    --target=$LFS_TGT           \
    --prefix=$LFS/tools         \
    --with-glibc-version=2.40   \
    --with-sysroot=$LFS         \
    --with-newlib               \
    --without-headers           \
    --enable-default-pie        \
    --enable-default-ssp        \
    --disable-nls               \
    --disable-shared            \
    --disable-multilib          \
    --disable-threads           \
    --disable-libatomic         \
    --disable-libgomp           \
    --disable-libquadmath       \
    --disable-libssp            \
    --disable-libvtv            \
    --disable-libstdcxx         \
    --enable-languages=c,c++

# The meaning of the configure options:
#   --with-glibc-version=2.40
#       This option specifies the version of Glibc which will be used on the target. It is
#       not relevant to the libc of the host distro because everything compiled by pass1 GCC
#       will run in the chroot environment, which is isolated from libc of the host distro.
#   --with-newlib
#       Since a working C library is not yet available, this ensures that the inhibit libc
#       constant is defined when building libgcc. This prevents the compiling of any code
#       that requires libc support.
#   --without-headers
#       When creating a complete cross-compiler, GCC requires standard headers compatible
#       with the target system. For our purposes these headers will not be needed. This
#       switch prevents GCC from looking for them.
#   --enable-default-pie and --enable-default-ssp
#       Those switches allow GCC to compile programs with some hardening security features
#       (more information on those in the note on PIE and SSP in chapter 8) by default. They
#       are not strictly needed at this stage, since the compiler will only produce
#       temporary packages be as close as possible to the final ones.
#   --disable-shared
#       This switch forces GCC to link its internal libaries staticlly. We need this because
#       the shared libraries require Glibc, which is not yet installed on the target system.
#   --disable-multilib
#       On x86_64, LFS does not support a multilib configuration. This switch is harmless
#       for x86.
#   --disable-threads, --disable-libatomic, --disable-libgomp, --disable-libquadmath,
#       --disable-libssp, --disable-libvtv, --disable-libstdcxx
#       This switches disable support for threading, libatomic, libgomp, libquadmath,
#       libssp, libvtv, and the C++ standard library respectively. These features may fail
#       to compile when building a cross-compiler and are not necessary for the task of
#       cross-compilining the temporary libc.
#   --enable-languages=c,c++
#       This option ensures that only the C and C++ compilers are built. These are the only
#       languages needed now.

# Compile GCC by running:
make

# Install the package:
make install

# This build of GCC has installed a couple of internal system headers. Normally one of them,
# limits.h, would in turn include the corresponding system limits.h header, in this case,
# $LFS/usr/include/limits.h. However, at the time of this build of GCC
# $LFS/usr/include/limits.h does not exist, so the internal header that has just been
# installed is a partial, self-contained file and does not include the extended features
# of the system header. This is adequate for building Glibc, but the full internal header
# will be needed later. Create a full version of the internal header using a command that
# is identical to what the GCC build system does in normal circumstances:

# -- NOTE --
#   The command below shoes an example of nested command substitution using two methods:
#       backquotes and a $construct
#   It could be rewritten using the same method for both substitutions, but is shown this
#   way to demonstrate how they can be mixed. Generally the $() method is preferred.

cd ..
cat gcc/limitx.h gcc/limits.h gcc/limity.h> \
    `dirname $($LFS_TGT-gcc -print-libgcc-file-name) `/include/limits.h

# Details on this package are located in Section 8.29.2, "Content of GCC."
