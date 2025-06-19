#!/bin/bash

export LC_ALL=C

function version_gt() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" != "$1"; }
function version_le() { test "$(echo "$@" | tr " " "\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\n" | sort -rV | head -n 1)" == "$1"; }

function BASH() {
	{ bashVersion=$(bash --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $bashVersion == "" ]]; then
		bashStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$bashVersion"
		bashVersionMin="3.2"
		if version_lt $bashVersion $bashVersionMin; then
			bashStatus=$(tput setaf 3; tput bold; echo "Version to low (Lowest $bashVersionMin)"; tput sgr0)
		else
			bashStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function BASHSYM() {
	MYSH=$(readlink -f /bin/sh)
	printf "/bin/sh -> $MYSH"
	printf $MYSH | grep -q bash && bashSymStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0) || bashSymStatus=$(tput setaf 3; tput bold; echo "/bin/sh doesnt point to bash"; tput sgr0)
	unset MYSH
}

function BINUTILS() {
	{ binutilsVersion=$(ld --version | head -n1 | cut -d" " -f7-); } &> /dev/null
	if [[ $binutilsVersion == "" ]]; then
		binutilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$binutilsVersion"
		binutilsVersionMin="2.17"
		binutilsVersionMax="2.27"
		if version_lt $binutilsVersion $binutilsVersionMin; then
			binutilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $binutilsVersionMin)"; tput sgr0)
		elif version_gt $binutilsVersion $binutilsVersionMax; then
			binutilsStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $binutilsVersionMax)"; tput sgr0)
		else
			binutilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function BISON() {
	{ bisonVersion=$(bison --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ $bisonVersion = "" ]]; then
		bisonStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$bisonVersion"
		bisonVersionMin="2.3"
		if version_lt $bisonVersion $bisonVersionMin; then
			bisonStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $bisonVersionMin)"; tput sgr0)
		else
			bisonStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function BISONLINK() {
	if [ -h /usr/bin/yacc ]; then
		echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`"
	elif [ -x /usr/bin/yacc ]; then
		echo "yacc is `/usr/bin/yacc --version | head -n1`"
	else
		bisonLinkStatus=$(tput setaf 1; tput bold; echo "Link not found"; tput sgr0)
	fi
}

function BZIP2() {
	{ bzip2Version=$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f8- | cut -d"," -f1); } &> /dev/null
	if [[ $bzip2Version == "" ]]; then
		bzip2Status=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$bzip2Version"
		bzip2VersionMin="1.0.4"
		if version_lt $bzip2Version $bzip2VersionMin; then
			bzip2Status=$(tput setaf 3; tput bold; echo "Version to low (Min $bzip2VersionMin)"; tput sgr0)
		else
			bzip2Status=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function COREUTILS() {
	{ chownVersion=$(chown --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ $chownVersion == "" ]]; then
		coreUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$chownVersion"
		coreUtilsVersionMin="6.9"
		if version_lt $coreUtilsVersion $coreUtilsVersionMin; then
			coreUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $coreUtilsVersionMin)"; tput sgr0)
		else
			coreUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function DIFFUTILS() {
	{ diffVersion=$(diff --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ $diffVersion == "" ]]; then
		diffUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$diffVersion"
		diffUtilsVersionMin="2.8.1"
		if version_lt $diffUtilsVersion $diffUtilsVersionMin; then
			diffUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $diffUtilsVersionMin)"; tput sgr0)
		else
			diffUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function FINDUTILS() {
	{ findVersion=$(find --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ $findVersion == "" ]]; then
		findUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$findVersion"
		findUtilsVersionMin="4.2.31"
		if version_lt $findUtilsVersion $findUtilsVersionMin; then
			findUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $findUtilsVersionMin)"; tput sgr0)
		else
			findUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function GAWK() {
	{ gawkVersion=$(gawk --version | head -n1 | cut -d" " -f3 | cut -d"," -f1); } &> /dev/null
	if [[ $gawkVersion == "" ]]; then
		gawkStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$gawkVersion"
		gawkVersionMin="4.0.1"
		if version_lt $gawkVersion $gawkVersionMin; then
			gawkStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gawkVersionMin)"; tput sgr0)
		else
			gawkStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function GAWKLINK() {
	if [ -h /usr/bin/awk ]; then
		echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
		gawkLinkStatus=$(tput setaf 3; tput bold; echo "/usr/bin/awk doesnt point to gawk"; tput sgr0)
	elif [ -x /usr/bin/awk ]; then
		echo awk is `/usr/bin/awk --version | head -n1`
		gawkLinkStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		gawkLinkStatus=$(tput setaf 1; tput bold; echo "Link not found"; tput sgr0)
	fi
}

function GCC() {
	{ gccVersion=$(gcc --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $gccVersion == "" ]]; then
		gccStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$gccVersion"
		gccVersionMin="4.7"
		gccVersionMax="6.3.0"
		if version_lt $gccVersion $gccVersionMin; then
			gccStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gccVersionMin)"; tput sgr0)
		elif version_gt $gccVersion $gccVersionMax; then
			gccStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $gccVersionMax)"; tput sgr0)
		else
			gccStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function GCCGPLUS() {
	{ gccgplusVersion=$(g++ --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $gccgplusVersion == "" ]]; then
		gccGplusStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$gccgplusVersion"
		gccgplusVersionMin="4.7"
		if version_lt $gccgplusVersion $gccgplusVersionMin; then
			gccgplusStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gccgplusVersionMin)"; tput sgr0)
		else
			gccGplusStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function GCCTEST() {
	echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
	if [ -x dummy ]; then
		echo "Compilation OK"
		gccTestStatus=$(tput setaf 2; tput bold; echo "Pass"; tput sgr0)
	else
		echo "Compilation failed"
		gccTestStatus=$(tput setaf 1; tput bold; echo "Failed"; tput sgr0)
	fi
	rm -f dummy.c dummy
}

function GLIBC() {
	{ glibcVersion=$(ldd --version | head -n1 | cut -d" " -f5); } &> /dev/null
	if [[ $glibcVersion == "" ]]; then
		glibcStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$glibcVersion"
		glibcStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		glibcVersionMin="2.11"
		glibcVersionMax="2.25"
		if version_lt $glibcVersion $glibcVersionMin; then
			glibcStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $glibcVersionMin)"; tput sgr0)
		elif version_gt $glibcVersion $glibcVersionMax; then
			glibcStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $glibcVersionMax)"; tput sgr0)
		else
			glibcStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}

function GREP() {
	{ grepVersion=$(grep --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $grepVersion == "" ]]; then
		grepStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$grepVersion"
		grepStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function GZIP() {
	{ gzipVersion=$(gzip --version | head -n1 | cut -d" " -f2); } &> /dev/null
	if [[ $gzipVersion == "" ]]; then
		gzipStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$gzipVersion"
		gzipStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function KERNEL() {
	{ kernelVersion=$(cat /proc/version | cut -d" " -f3 | cut -d"-" -f1); } &> /dev/null
	if [[ $kernelVersion == "" ]]; then
		kernelStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$kernelVersion"
		kernelStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function M4() {
	{ m4Version=$(m4 --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $m4Version == "" ]]; then
		m4Status=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$m4Version"
		m4Status=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function MAKE() {
	{ makeVersion=$(make --version | head -n1 | cut -d" " -f3); } &> /dev/null
	if [[ $makeVersion == "" ]]; then
		makeStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$makeVersion"
		makeStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function PATCH() {
	{ patchVersion=$(patch --version | head -n1 | cut -d" " -f3); } &> /dev/null
	if [[ $patchVersion == "" ]]; then
		patchStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$patchVersion"
		patchStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function PERL() {
	{ perlVersion=$(echo Perl `perl -V:version` | cut -d"'" -f2); } &> /dev/null
	if [[ $perlVersion == "" ]]; then
		perlStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$perlVersion"
		perlStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function SED() {
	{ sedVersion=$(sed --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $sedVersion == "" ]]; then
		sedStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$sedVersion"
		sedStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function TAR() {
	{ tarVersion=$(tar --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $tarVersion == "" ]]; then
		tarStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$tarVersion"
		tarStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function TEXINFO() {
	{ texinfoVersion=$(makeinfo --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $texinfoVersion == "" ]]; then
		texinfoStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$texinfoVersion"
		texinfoStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function XZ() {
	{ xzVersion=$(xz --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ $xzVersion == "" ]]; then
		xzStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		echo "$xzVersion"
		xzStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}

function LIBRARY() {
	if [ ! -f /usr/lib/libgmp.la ]; then
		libgmpFile="File not found"
		libgmpStatus=0
	else
		libgmpFile="File found"
		libgmpStatus=1
	fi
	if [ ! -f /usr/lib/libmpfr.la ]; then
		libmpfrFile="File not found"
		libmpfrStatus=0
	else
		libmpfrFile="File found"
		libmpfrStatus=1
	fi
	if [ ! -f /usr/lib/libmpc.la ]; then
		libmpcFile="File not found"
		libmpcStatus=0
	else
		libmpcFile="File found"
		libmpcStatus=1
	fi
	((libStatus=$libgmpStatus+$libmpfrStatus+$libmpcStatus))
	if [ "$libStatus" == 0 ] || [ "$libStatus" == 3 ]; then
		libraryStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		libraryStatus=$(tput setaf 1; tput bold; echo "Failed"; tput sgr0)
	fi
}

function displaySettings() {
	columns=$(tput cols)
	line=$(printf '%*s\n' "${COLUMNS:-$columns}" '' | sed 's/ /\o342\o226\o221/g')
	((title = columns / 2 - 10))
	((anyKey = columns / 2 - 16))
	((smallDisplay = columns / 2 - 11))
	c1=1; c2=18; c3=32; c4=65
	if [ $columns -lt "100" ]; then
		tput cup 3 $smallDisplay; tput setaf 1; tput bold; echo "Display to small"; tput sgr0
		tput cup 4 $anyKey; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
		tput clear
		source setup.sh
	fi
}

function display() {
	displaySettings
	clear
	tput clear
	printf $line
	tput cup 1 $title; tput bold; echo "Version Check";	tput sgr0
	printf $line
	tput bold
	tput cup 3 $c1; echo "Package";					tput cup 3 $c2; echo "Recommended";		tput cup 3 $c3; echo "Current";	tput cup 3 $c4; echo "Status"
	tput sgr0
	tput cup 4 $c1; echo "Bash";						tput cup 4 $c2; echo "3.2"; 					tput cup 4 $c3; BASH;					tput cup 4 $c4; echo $bashStatus;
	tput cup 5 $c1; echo "Bash Symbolic";		tput cup 5 $c2; echo "sh -> bash";		tput cup 5 $c3; BASHSYM;			tput cup 5 $c4; echo $bashSymStatus;
	tput cup 6 $c1; echo "BinUtils";				tput cup 6 $c2; echo "2.17"; 					tput cup 6 $c3; BINUTILS;			tput cup 6 $c4; echo $binutilsStatus;
	tput cup 7 $c1; echo "Bison";						tput cup 7 $c2; echo "2.3"; 					tput cup 7 $c3; BISON;				tput cup 7 $c4; echo $bisonStatus;
	tput cup 8 $c1; echo "Bison Link";			tput cup 8 $c2; echo "";							tput cup 8 $c3; BISONLINK;		tput cup 8 $c4; echo $bisonLinkStatus;
	tput cup 9 $c1; echo "BZip2";						tput cup 9 $c2; echo "1.0.4";					tput cup 9 $c3; BZIP2;				tput cup 9 $c4; echo $bzip2Status;
	tput cup 10 $c1; echo "CoreUtils";			tput cup 10 $c2; echo "6.9";					tput cup 10 $c3; COREUTILS;		tput cup 10 $c4; echo $coreUtilsStatus;
	tput cup 11 $c1; echo "DiffUtils";			tput cup 11 $c2; echo "2.8.1";				tput cup 11 $c3; DIFFUTILS;		tput cup 11 $c4; echo $diffUtilsStatus;
	tput cup 12 $c1; echo "FindUtils";			tput cup 12 $c2; echo "4.2.31";				tput cup 12 $c3; FINDUTILS;		tput cup 12 $c4; echo $findUtilsStatus;
	tput cup 13 $c1; echo "Gawk";						tput cup 13 $c2; echo "4.0.1";				tput cup 13 $c3; GAWK;				tput cup 13 $c4; echo $gawkStatus;
	tput cup 14 $c1; echo "Gawk Link";			tput cup 14 $c2; echo "awk -> gawk";	tput cup 14 $c3; GAWKLINK;		tput cup 14 $c4; echo $gawkLinkStatus;
	tput cup 15 $c1; echo "GCC";						tput cup 15 $c2; echo "4.7";					tput cup 15 $c3; GCC;					tput cup 15 $c4; echo $gccStatus;
	tput cup 16 $c1; echo "GCC G++"; 				tput cup 16 $c2; echo "4.7";					tput cup 16 $c3; GCCGPLUS;		tput cup 16 $c4; echo $gccGplusStatus;
	tput cup 17 $c1; echo "GCC Test"; 			tput cup 17 $c2; echo "";							tput cup 17 $c3; GCCTEST;			tput cup 17 $c4; echo $gccTestStatus;
	tput cup 18 $c1; echo "Glibc";					tput cup 18 $c2; echo "2.11";					tput cup 18 $c3; GLIBC;				tput cup 18 $c4; echo $glibcStatus;
	tput cup 19 $c1; echo "Grep";						tput cup 19 $c2; echo "2.5.1a";				tput cup 19 $c3; GREP;				tput cup 19 $c4; echo $grepStatus;
	tput cup 20 $c1; echo "GZip";						tput cup 20 $c2; echo "1.3.12";				tput cup 20 $c3; GZIP;				tput cup 20 $c4; echo $gzipStatus;
	tput cup 21 $c1; echo "Linux Kernel";		tput cup 21 $c2; echo "2.6.32";				tput cup 21 $c3; KERNEL;			tput cup 21 $c4; echo $kernelStatus;
	tput cup 22 $c1; echo "M4";							tput cup 22 $c2; echo "1.4.10";				tput cup 22 $c3; M4;					tput cup 22 $c4; echo $m4Status;
	tput cup 23 $c1; echo "Make";						tput cup 23 $c2; echo "3.81";					tput cup 23 $c3; MAKE;				tput cup 23 $c4; echo $makeStatus;
	tput cup 24 $c1; echo "Patch";					tput cup 24 $c2; echo "2.5.4";				tput cup 24 $c3; PATCH;				tput cup 24 $c4; echo $patchStatus;
	tput cup 25 $c1; echo "Perl";						tput cup 25 $c2; echo "5.8.8";				tput cup 25 $c3; PERL;				tput cup 25 $c4; echo $perlStatus;
	tput cup 26 $c1; echo "Sed";						tput cup 26 $c2; echo "4.1.5";				tput cup 26 $c3; SED;					tput cup 26 $c4; echo $sedStatus;
	tput cup 27 $c1; echo "Tar";						tput cup 27 $c2; echo "1.22";					tput cup 27 $c3; TAR;					tput cup 27 $c4; echo $tarStatus;
	tput cup 28 $c1; echo "TexInfo";				tput cup 28 $c2; echo "4.7";					tput cup 28 $c3; TEXINFO;			tput cup 28 $c4; echo $texinfoStatus;
	tput cup 29 $c1; echo "Xz";							tput cup 29 $c2; echo "5.0.0";				tput cup 29 $c3; XZ;					tput cup 29 $c4; echo $xzStatus;

	printf $line
	tput cup 31 $title; tput bold; echo " Library Check";	tput sgr0
	printf $line

	LIBRARY
	tput cup 33 $c1; echo "libgmp.la";				tput cup 33 $c3; echo $libgmpFile;	tput cup 33 $c4; echo $libraryStatus;
	tput cup 34 $c1; echo "libmpfr.la";				tput cup 34 $c3; echo $libmpfrFile;
	tput cup 35 $c1; echo "libmpc.la";				tput cup 35 $c3; echo $libmpcFile;

	printf $line
	tput cup 37 $anyKey; tput bold; read -n 1 -s -r -p "Press any key to continue"; tput sgr0
	tput clear
}

display
