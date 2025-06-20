#!/bin/bash

processorsCount=1
sourcesLocation="$LFS/sources"
packageName="$sourcesLocation/binutils-2.29.tar.bz2"
packageExtractLocation="$sourcesLocation/binutils-2.29"

extractPackage() {
	time {
		# Extract Tar
		#	-x --extract: Exract a tar ball.
		#	-v --verbose: Verbose output or show progress while extracting files.
		#	-f --file: Specify an archive or a tarball filename.
		#	-j --bzip2: Decompress and extract the contents of the compressed
		#		archive created by bzip2 program (tar.bz2 extension).
		#	-z --gzip: Decompress and extract the contents of the compressed
		#		archive created by gzip program (tar.gz extension).
		# To extract a tar file:
		#	tar -xvf file.tar
		#	tar -xzvf file.tar.gz
		#	tar -xjvf file.tar.bz2
		# To extract a single file from tar file:
		#	tar -x(zj)vf file.tar foo.txt
		# To extract to specify path:
		#	tar -x(zj)vf file.tar path/to/save/to
		#
		# Ex (Short):	tar -xzvf file.tar.gz /extract/location
		# Ex (Long):	tar --extract --gzip --verbose --file=file.tar.gz /extract/location

		# Extract Package
		if [ -d "$2" ]; then
			echo "Removing Old..."
			rm -rf "$2"
		else
			echo "No Old Folder Found"
		fi
		if [ ! -d "$2" ]; then
			echo "Making Folder..."
			mkdir "$2"
		else
			echo "Folder Exist"				# ERROR if this happens
		fi

		if [ -f "$1" ]; then
			echo "Extracting Files..."
			tar --extract --bzip2 --verbose --file="$1"
		fi
	}
}

preparePackage() {
	time {
		cd "$1"
		mkdir -v "$1/build"
		cd "$1/build"

		$1/configure	--prefix=/tools		\
				--with-sysroot=$LFS			\
				--with-lib-path=/tools/lib	\
				--target=$LFS_TGT			\
				--disable-nls				\
				--disable-werror

		echo "Compiling the package..."
		# Number of processors available to use and max allowed to use.
		make -j"$processorsCount"

		echo "Create symlink for 64 Bit system..."
		# If x86_64, create a symlink
		case $(uname -m) in
			x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
		esac

		echo "Install Package..."
		make install
	}
}

time {
	clear
	echo "Construct Binutils in Temporary System"
	echo "Extracting $packageName..."
	extractPackage "$packageName" "$packageExtractLocation"
	preparePackage "$packageExtractLocation"
#	extractPackage "cleanPackage"
}
