#!/bin/bash
# LFS Builder Version Checker

source lfs/config/settings.cfg

function prep() {
	export LC_ALL=C
	errorCount=0
}

function version_gt() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" != "$1"; }
function version_le() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" == "$1"; }
function version_lt() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" != "$1"; }
function version_ge() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" == "$1"; }

#function version_minmax() {
#	function version_gt() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" != "$1"; }
#	function version_le() { test "$(echo "$@" | tr " " "\\n" | sort -V | head -n 1)" == "$1"; }
#	function version_lt() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" != "$1"; }
#	function version_ge() { test "$(echo "$@" | tr " " "\\n" | sort -rV | head -n 1)" == "$1"; }
#	if version_lt "$2" "$2"; then
#		((errorCount=errorCount + 1))
#		versionStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $2)"; tput sgr0)
#	elif version_gt "$1" "$3"; then
#		((errorCount=errorCount + 1))
#		versionStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $3)"; tput sgr0)
#	else
#		versionStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
#	fi
#}

function BASH() {
	{ bashVersion=$(bash --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$bashVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		bashStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		bashVersionMin="3.2"
		if version_lt "$bashVersion" "$bashVersionMin"; then
			((errorCount=errorCount + 1))
			bashStatus=$(tput setaf 3; tput bold; echo "Version to low (Lowest $bashVersionMin)"; tput sgr0)
		else
			bashStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function BASHSYM() {
	{ bashSymLink=$(readlink -f /bin/sh); } &> /dev/null
	bashLink="/bin/sh -> $bashSymLink"
	if [ "$bashSymLink" == "/bin/bash" ]; then
		bashSymStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		((errorCount=errorCount + 1))
		bashSymStatus=$(tput setaf 3; tput bold; echo "/bin/sh doesnt point to bash"; tput sgr0)
	fi
}
function BINUTILS() {
	{ binutilsVersion=$(ld --version | head -n1 | cut -d" " -f7-); } &> /dev/null
	if [[ "$binutilsVersion" == "" ]]; then
		binutilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		binutilsVersionMin="2.17"
		binutilsVersionMax="2.27"
		if version_lt "$binutilsVersion" "$binutilsVersionMin"; then
			((errorCount=errorCount + 1))
			binutilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $binutilsVersionMin)"; tput sgr0)
		elif version_gt "$binutilsVersion" "$binutilsVersionMax"; then
			((errorCount=errorCount + 1))
			binutilsStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $binutilsVersionMax)"; tput sgr0)
		else
			binutilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function BISON() {
	{ bisonVersion=$(bison --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ "$bisonVersion" = "" ]]; then
		((errorCount=errorCount + 1))
		bisonStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		bisonVersionMin="2.3"
		if version_lt "$bisonVersion" "$bisonVersionMin"; then
			((errorCount=errorCount + 1))
			bisonStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $bisonVersionMin)"; tput sgr0)
		else
			bisonStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function BISONLINK() {
	{ bisonSymLink=$(readlink -f /usr/bin/yacc); } &> /dev/null
	bisonLink="/usr/bin/yacc -> $bisonSymLink"
	if [ "$bisonSymLink" == "/usr/bin/bison.yacc" ]; then
		bisonSymStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		((errorCount=errorCount + 1))
		bisonSymStatus=$(tput setaf 3; tput bold; echo "/usr/bin/yacc doesnt point to bison"; tput sgr0)
	fi
}
function BZIP2() {
	{ bzip2Version=$(bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f8- | cut -d"," -f1); } &> /dev/null
	if [[ "$bzip2Version" == "" ]]; then
		((errorCount=errorCount + 1))
		bzip2Status=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		bzip2VersionMin="1.0.4"
		if version_lt "$bzip2Version" "$bzip2VersionMin"; then
			((errorCount=errorCount + 1))
			bzip2Status=$(tput setaf 3; tput bold; echo "Version to low (Min $bzip2VersionMin)"; tput sgr0)
		else
			bzip2Status=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function COREUTILS() {
	{ coreUtilsVersion=$(chown --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ "$coreUtilsVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		coreUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		coreUtilsVersionMin="6.9"
		if version_lt "$coreUtilsVersion" "$coreUtilsVersionMin"; then
			((errorCount=errorCount + 1))
			coreUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $coreUtilsVersionMin)"; tput sgr0)
		else
			coreUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function DIFFUTILS() {
	{ diffUtilsVersion=$(diff --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ "$diffUtilsVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		diffUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		diffUtilsVersionMin="2.8.1"
		if version_lt "$diffUtilsVersion" "$diffUtilsVersionMin"; then
			((errorCount=errorCount + 1))
			diffUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $diffUtilsVersionMin)"; tput sgr0)
		else
			diffUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function FINDUTILS() {
	{ findUtilsVersion=$(find --version | head -n1 | cut -d" " -f4-); } &> /dev/null
	if [[ "$findUtilsVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		findUtilsStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		findUtilsVersionMin="4.2.31"
		if version_lt "$findUtilsVersion" "$findUtilsVersionMin"; then
			((errorCount=errorCount + 1))
			findUtilsStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $findUtilsVersionMin)"; tput sgr0)
		else
			findUtilsStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function GAWK() {
	{ gawkVersion=$(gawk --version | head -n1 | cut -d" " -f3 | cut -d"," -f1); } &> /dev/null
	if [[ "$gawkVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		gawkStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		gawkVersionMin="4.0.1"
		if version_lt "$gawkVersion" "$gawkVersionMin"; then
			((errorCount=errorCount + 1))
			gawkStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gawkVersionMin)"; tput sgr0)
		else
			gawkStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function GAWKLINK() {
	{ gawkSymLink=$(readlink -f /usr/bin/awk); } &> /dev/null
	gawkLink="/usr/bin/awk -> $gawkSymLink"
	if [ "$gawkSymLink" == "/usr/bin/gawk" ]; then
		gawkSymStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		((errorCount=errorCount + 1))
		gawkSymStatus=$(tput setaf 3; tput bold; echo "/usr/bin/awk doesnt point to gawk"; tput sgr0)
	fi
}
function GCC() {
	{ gccVersion=$(gcc --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$gccVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		gccStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		gccVersionMin="4.7"
		gccVersionMax="6.3.0"
		if version_lt "$gccVersion" "$gccVersionMin"; then
			((errorCount=errorCount + 1))
			gccStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gccVersionMin)"; tput sgr0)
		elif version_gt "$gccVersion" "$gccVersionMax"; then
			((errorCount=errorCount + 1))
			gccStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $gccVersionMax)"; tput sgr0)
		else
			gccStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function GCCGPLUS() {
	{ gccgplusVersion=$(g++ --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$gccgplusVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		gccgplusStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		gccgplusVersionMin="4.7"
		if version_lt "$gccgplusVersion" "$gccgplusVersionMin"; then
			((errorCount=errorCount + 1))
			gccgplusStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $gccgplusVersionMin)"; tput sgr0)
		else
			gccgplusStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function GCCTEST() {
	echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
	if [ -x dummy ]; then
		gccTest="Compilation OK"
		gccTestStatus=$(tput setaf 2; tput bold; echo "Pass"; tput sgr0)
	else
		((errorCount=errorCount + 1))
		gccTest="Compilation failed"
		gccTestStatus=$(tput setaf 1; tput bold; echo "Failed"; tput sgr0)
	fi
	rm -f dummy.c dummy
}
function GLIBC() {
	{ glibcVersion=$(ldd --version | head -n1 | cut -d" " -f5); } &> /dev/null
	if [[ "$glibcVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		glibcStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		glibcStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		glibcVersionMin="2.11"
		glibcVersionMax="2.25"
		if version_lt "$glibcVersion" "$glibcVersionMin"; then
			((errorCount=errorCount + 1))
			glibcStatus=$(tput setaf 3; tput bold; echo "Version to low (Min $glibcVersionMin)"; tput sgr0)
		elif version_gt "$glibcVersion" "$glibcVersionMax"; then
			((errorCount=errorCount + 1))
			glibcStatus=$(tput setaf 3; tput bold; echo "Version to high (Max $glibcVersionMax)"; tput sgr0)
		else
			glibcStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
		fi
	fi
}
function GREP() {
	{ grepVersion=$(grep --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$grepVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		grepStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		grepStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function GZIP() {
	{ gzipVersion=$(gzip --version | head -n1 | cut -d" " -f2); } &> /dev/null
	if [[ "$gzipVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		gzipStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		gzipStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function KERNEL() {
#	{ kernelVersion=$(cat /proc/version | cut -d" " -f3 | cut -d"-" -f1); } &> /dev/null
	{ kernelVersion=$(< /proc/version cut -d" " -f3 | cut -d"-" -f1); } &> /dev/null
	if [[ "$kernelVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		kernelStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		kernelStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function M4() {
	{ m4Version=$(m4 --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$m4Version" == "" ]]; then
		((errorCount=errorCount + 1))
		m4Status=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		m4Status=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function MAKE() {
	{ makeVersion=$(make --version | head -n1 | cut -d" " -f3); } &> /dev/null
	if [[ "$makeVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		makeStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		makeStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function PATCH() {
	{ patchVersion=$(patch --version | head -n1 | cut -d" " -f3); } &> /dev/null
	if [[ "$patchVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		patchStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		patchStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function PERL() {
	{ perlVersion=$(echo Perl "$(perl -V:version)" | cut -d"'" -f2); } &> /dev/null
	if [[ "$perlVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		perlStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		perlStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function SED() {
	{ sedVersion=$(sed --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$sedVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		sedStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		sedStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function TAR() {
	{ tarVersion=$(tar --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$tarVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		tarStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		tarStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function TEXINFO() {
	{ texinfoVersion=$(makeinfo --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$texinfoVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		texinfoStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
		texinfoStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	fi
}
function XZ() {
	{ xzVersion=$(xz --version | head -n1 | cut -d" " -f4); } &> /dev/null
	if [[ "$xzVersion" == "" ]]; then
		((errorCount=errorCount + 1))
		xzStatus=$(tput setaf 1; tput bold; echo "Not Installed"; tput sgr0)
	else
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
	((libStatus=libgmpStatus+libmpfrStatus+libmpcStatus))
	if [ "$libStatus" == 0 ] || [ "$libStatus" == 3 ]; then
		libraryStatus=$(tput setaf 2; tput bold; echo "OK"; tput sgr0)
	else
		((errorCount=errorCount + 1))
		libraryStatus=$(tput setaf 1; tput bold; echo "Failed"; tput sgr0)
	fi
}

function slientRun() {
	{
		errorCount=0
		BASH; BASHSYM; BINUTILS; BISON; BISONLINK; BZIP2; COREUTILS; DIFFUTILS; FINDUTILS;
		GAWK; GAWKLINK; GCC; GCCGPLUS; GCCTEST; GLIBC; GREP; GZIP; KERNEL; M4; MAKE; PATCH; PERL; SED;
		TAR; TEXINFO; XZ; LIBRARY
	} &> /dev/null
}

function display() {
	versionHeader="Version Check"
	libraryHeader="Library Check"

	titleHeader
	tput cup 3 0; tput bold; echo "$versionHeader";	tput sgr0
	tput bold; tput cup 4 "$vc1"; echo "Package"; tput cup 4 "$vc2"; echo "Current"; tput cup 4 "$vc3"; echo "Status"; tput sgr0
	tput cup 5 "$vc1"; echo "Bash";						tput cup 5 "$vc2"; echo "$bashVersion";				tput cup 5 "$vc3"; echo "$bashStatus"
	tput cup 6 "$vc1"; echo "Bash Symbolic";	tput cup 6 "$vc2"; echo "$bashLink";					tput cup 6 "$vc3"; echo "$bashSymStatus"
	tput cup 7 "$vc1"; echo "BinUtils";				tput cup 7 "$vc2"; echo "$binutilsVersion";		tput cup 7 "$vc3"; echo "$binutilsStatus"
	tput cup 8 "$vc1"; echo "Bison";					tput cup 8 "$vc2"; echo "$bisonVersion";			tput cup 8 "$vc3"; echo "$bisonStatus"
	tput cup 9 "$vc1"; echo "Bison Link";			tput cup 9 "$vc2"; echo "$bisonLink";					tput cup 9 "$vc3"; echo "$bisonSymStatus"
	tput cup 10 "$vc1"; echo "BZip2";					tput cup 10 "$vc2"; echo "$bzip2Version";			tput cup 10 "$vc3"; echo "$bzip2Status"
	tput cup 11 "$vc1"; echo "CoreUtils";			tput cup 11 "$vc2"; echo "$coreUtilsVersion";	tput cup 11 "$vc3"; echo "$coreUtilsStatus"
	tput cup 12 "$vc1"; echo "DiffUtils";			tput cup 12 "$vc2"; echo "$diffUtilsVersion";	tput cup 12 "$vc3"; echo "$diffUtilsStatus"
	tput cup 13 "$vc1"; echo "FindUtils";			tput cup 13 "$vc2"; echo "$findUtilsVersion";	tput cup 13 "$vc3"; echo "$findUtilsStatus"
	tput cup 14 "$vc1"; echo "Gawk";					tput cup 14 "$vc2"; echo "$gawkVersion";			tput cup 14 "$vc3"; echo "$gawkStatus"
	tput cup 15 "$vc1"; echo "Gawk Link";			tput cup 15 "$vc2"; echo "$gawkLink";					tput cup 15 "$vc3"; echo "$gawkSymStatus"
	tput cup 16 "$vc1"; echo "GCC";						tput cup 16 "$vc2"; echo "$gccVersion";				tput cup 16 "$vc3"; echo "$gccStatus"
	tput cup 17 "$vc1"; echo "GCC G++"; 			tput cup 17 "$vc2"; echo "$gccgplusVersion";	tput cup 17 "$vc3"; echo "$gccgplusStatus"
	tput cup 18 "$vc1"; echo "GCC Test"; 			tput cup 18 "$vc2"; echo "$gccTest";					tput cup 18 "$vc3"; echo "$gccTestStatus"
	tput cup 19 "$vc1"; echo "Glibc";					tput cup 19 "$vc2"; echo "$glibcVersion";			tput cup 19 "$vc3"; echo "$glibcStatus"
	tput cup 20 "$vc1"; echo "Grep";					tput cup 20 "$vc2"; echo "$grepVersion";			tput cup 20 "$vc3"; echo "$grepStatus"
	tput cup 21 "$vc1"; echo "GZip";					tput cup 21 "$vc2"; echo "$gzipVersion";			tput cup 21 "$vc3"; echo "$gzipStatus"
	tput cup 22 "$vc1"; echo "Linux Kernel";	tput cup 22 "$vc2"; echo "$kernelVersion";		tput cup 22 "$vc3"; echo "$kernelStatus"
	tput cup 23 "$vc1"; echo "M4";						tput cup 23 "$vc2"; echo "$m4Version";				tput cup 23 "$vc3"; echo "$m4Status"
	tput cup 24 "$vc1"; echo "Make";					tput cup 24 "$vc2"; echo "$makeVersion";			tput cup 24 "$vc3"; echo "$makeStatus"
	tput cup 25 "$vc1"; echo "Patch";					tput cup 25 "$vc2"; echo "$patchVersion";			tput cup 25 "$vc3"; echo "$patchStatus"
	tput cup 26 "$vc1"; echo "Perl";					tput cup 26 "$vc2"; echo "$perlVersion";			tput cup 26 "$vc3"; echo "$perlStatus"
	tput cup 27 "$vc1"; echo "Sed";						tput cup 27 "$vc2"; echo "$sedVersion";				tput cup 27 "$vc3"; echo "$sedStatus"
	tput cup 28 "$vc1"; echo "Tar";						tput cup 28 "$vc2"; echo "$tarVersion";				tput cup 28 "$vc3"; echo "$tarStatus"
	tput cup 29 "$vc1"; echo "TexInfo";				tput cup 29 "$vc2"; echo "$texinfoVersion";		tput cup 29 "$vc3"; echo "$texinfoStatus"
	tput cup 30 "$vc1"; echo "Xz";						tput cup 30 "$vc2"; echo "$xzVersion";				tput cup 30 "$vc3"; echo "$xzStatus"

	tput cup 31 0; printf "%s" "$line"
	tput cup 32 0; tput bold; echo "$libraryHeader"; tput sgr0

	tput cup 33 "$vc1"; echo "libgmp.la";			tput cup 33 "$vc2"; echo "$libgmpFile";				tput cup 33 "$vc3"; echo "$libraryStatus"
	tput cup 34 "$vc1"; echo "libmpfr.la";		tput cup 34 "$vc2"; echo "$libmpfrFile"
	tput cup 35 "$vc1"; echo "libmpc.la";			tput cup 35 "$vc2"; echo "$libmpcFile"

	tput cup 36 0; printf "%s" "$line"
	tput cup 37 "$anyKeyHeaderPosition"; pressAnyKey
	tput clear
}

prep
slientRun
#if [ $startUp == 0 ]; then
#	startUp=1
#else
	display
#fi
