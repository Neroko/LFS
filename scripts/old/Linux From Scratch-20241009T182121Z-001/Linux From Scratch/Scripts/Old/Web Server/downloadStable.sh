#!/bin/bash

if [ ! -d "stable/" ]; then
	mkdir stable
fi
wget --directory-prefix=stable/ -r -np -nH --cut-dirs=3 -R index.html* www.linuxfromscratch.org/lfs/downloads/stable/
if [ ! -d "stable-systemd/" ]; then
	mkdir stable-systemd
fi
wget --directory-prefix=stable-systemd/ -r -np -nH --cut-dirs=3 -R index.html* www.linuxfromscratch/lfs/downloads/stable-systemd/
