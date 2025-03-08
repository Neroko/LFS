#!/bin/bash
# Linux From Scratch (LFS) 5.2. Binutils-2.43.1 - Pass 1
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
#   5.2-Binutils-P1.sh [options] ARG1
#
# OPTIONS:
#   -o [file], --output=[file]      Set log file
#   -h, --help                      Display this help
#   -v, --version                   Display versions
#
# DESCRIPTION
#   The Binutils package contains a linker, an assembler, and other tools for handling
#   object files.
#       Approximate build time:     1 SBU
#       Required disk space:        677 MB
#
# =======================
# == SCRIPT NOT TESTED ==
# =======================

# 5.2.1. Installation of Cross Binutils

# -- Note --
#   Go back and re-read the notes in the section titled General Compilation Instructions.
#   Understanding the notes labeled important can save you a lot of problems later.

# It is important that Binutils be the first package compiled because bot Glib and GCC
# proform various tests on the available linker and assembler to determine which of their
# own features to enable.


# -------------------------------------------
# -------------------------------------------
# Add unzipping of package to directory
# -------------------------------------------
# -------------------------------------------


# The Binutils documentation remmends building Binutils in a dedicated build directory:
mkdir -v build
cd build

# -- Note --
#   In order for the SBU values listed in the rest of the book to be of any use, measure the
#   time it takes to build this package from the configuration, up to and including the
#   first install. To achieve this easily, wrap the commands in a time command like this:
#       time { ../configure ... && make && make install; }.

# Now prepare Binutils for compilation:
../configure            \
    --prefix=$LFS/tools \
    --with-sysroot=$LFS \
    --target=$LFS_TGT   \
    --disable-nls       \
    --enable-gprofng=no \
    --disable-werror    \
    --enable-new-dtags  \
    --enable-default-hash-style=gnu

# The meaning of the configure options:
#   --prefix=$LFS/tools
#       This tells the configure script to prepare to install the Binutils programs in the
#       $LFS/tools directory.
#   --with-sysroot=$LFS
#       For cross compilation, this tells the build system to look in $LFS for the target
#       system libraries as needed.
#   --target=$LFS_TGT
#       Bacause the machine description in the LFS_TGT variable is slightly different than
#       the value returned by the config.guess script, this switch will tell the
#       configure script to adjust binutil's build system for building a cross linker.
#   --disable-nls
#       This disables internationalization as i18n is not needed for the temporary tools.
#   --enable-gprofng=no
#       This disables building gprofng which is not needed for the temporary tools.
#   --disable-werror
#       This prevents the build from stopping in the event that there are warnings from
#       the host's compiler.
#   --enable-new-tags
#       This makes the linker use the "runpath" tag for embedding library search paths into
#       executables and shared libraries, instead of the traditional "rpath" tag. It makes
#       debugging dyamically linked executables easier and works around potential issues in
#       the test suite of some packages.
#   --enable-default-hash-style=gnu
#       By default, the linker would generate both GNU-style hash table and the classic ELF
#       hash table for shared libraries and dynamically linked executables. The hash tables
#       are only intended for a dynamic linker to perform symbol lookup. On LFS the
#       dynamic linker (provided by the Glibc package) will always use the GNU-style hash
#       table which is faster to query. So the classic ELF hash table is completely useless.
#       This makes the linker only generate the GNU-style hash table by default, so we can
#       avoid wasting time to generate the classic ELF hash table when we build the packages,
#       or wasting disk space to store it.

# Continue with compiling the package:
make

# Install the package:
make install

# Details on this package are located in Section 8.20.2, "Contents of Binutils."
