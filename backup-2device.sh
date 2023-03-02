#!/bin/bash

#backup bunch of directories to the second external drive
#dependencies: borg

prefix=/run/media/tokariew/Backup2/borg-backups

declare -A locations=(
        [home]="$HOME"
        [mgr]="$HOME/Media/mgr"
        [pictures]="$HOME/Media/Documents/Pictures"
)

for elem in "${!locations[@]}"; do
        echo Creating backup for "$elem"
        borg create --iec -s -p --exclude-if-present .nobackup -C zstd,8 $prefix/"${elem}"::"$(date --iso-8601=minutes)" "${locations[${elem}]}"
done
