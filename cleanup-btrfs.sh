#!/bin/sh

# simple script to remove snapshots created by snapper on btrfs file system
# used it couple of times, when I forgot to enable cleanup.timer

disk="$1"

g="$(sudo btrfs subvolume list "$disk" | grep snapshot | awk '{print $9}')"

for line in $g; do
	sudo btrfs subvolume delete "$disk"/"$line"
done
