#!/bin/bash

#backup bunch of directories to the first external drive
#dependencies: borg

prefix=/run/media/tokariew/Backup/borg-backups

declare -A locations=(
        [books]="$HOME/Media/books"
        [mail]="$HOME/.local/share/mail"
        [studia]="$HOME/Media/studia-mess"
        [work]="$HOME/Media/Documents/work-mess"
)

for elem in "${!locations[@]}"; do
        echo Creating backup for "$elem"
        borg create --iec -s -p -C zstd,8 $prefix/"${elem}"::"$(date --iso-8601=minutes)" "${locations[${elem}]}"
done

for elem in "${!locations[@]}"; do
        echo Pruning old backups for "$elem"
        borg prune -s -d 4 -w 2 -m 6 --keep-yearly=1 $prefix/"${elem}"
        echo Compacting data for "$elem"
        borg compact -p $prefix/"$elem"
done
