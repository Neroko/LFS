#!/bin/bash

echo "Checking for running LFS sessions..."
tmux refresh-client
status=$(tmux list-sessions | grep "LFS" | cut -d":" -f1)

if [ "$status" = "LFS" ]; then
	echo "Found session"
	tmux attach-session -t LFS
else
	echo "Starting new session..."
	tmux new-session -d -s LFS -n "Source Folder" 'nano test.txt' \; split-window \; attach
fi
