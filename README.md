# LFS - Linux from Scratch - Autobuilder

Version (LFS): 12.3 <br />

LFS AutoBuilder Downloader Script: https://raw.githubusercontent.com/Neroko/LFS/refs/heads/master/scripts/download-lfs-scripts.sh <br />
LFS Download Site: https://www.linuxfromscratch.org/lfs/downloads/stable/ <br />

## Files
### Root
| Files | Desp |
| -----:|------|
| download.sh   | Test Download |
| version       | Current Build Version |
| wget-list     | Needed Packages |

### Downloads Folder
| Files | Desp |
| -----:|------|
| downloads\LFS-BOOK.pdf    | LFS Book |
| downloads\md5sums         | LFS MD5SUMS File |
| downloads\wget-list       | LFS WGET-LIST File |

## Scripts
### DebianInstaller Files
| Files | Desp |
| -----:|------|
| scripts\debianinstaller\01-debianinstaller-build.sh       | Setup Debian Builder |
| scripts\debianinstaller\02-debianinstaller-checkout.sh    | Needed for setup of Debian Builder |

### LFS Builder Scripts Files
| Files | Desp |
| -----:|------|
| scripts\lfsbuilder\5.2-Binutils-P1.sh | Section 5.2 - Binutils Builder - Pass 1 |
| scripts\lfsbuilder\5.3-GCC-P1.sh      | Section 5.3 - GCC Builder - Pass 1 |

### LFS Script Folder
| Files | Desp |
| -----:|------|
| scripts\lfsdownloader\01-version-check.sh         | System Builder Version Check |
| scripts\lfsdownloader\02-setup-system.sh          | Setup System to Build LFS |
| scripts\lfsdownloader\03-sources-setup.sh         | Setup LFS Sources |
| scripts\lfsdownloader\download-lfs-scripts.sh     | Download from Github needed files |
| scripts\lfsdownloader\test-menu.sh                | Test GUI Menu |
