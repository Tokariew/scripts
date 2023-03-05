#!/bin/sh

#backup home folder to nfs share
#dependencies: borg

borg create -s --iec -p --exclude-if-present .nobackup -C zstd,8 /media/nfs/Backups/BackupHome::"$(date --iso-8601=minutes)" ~/
borg prune -s -d 4 -w 2 -m 6 --keep-yearly=1 /media/nfs/Backups/BackupHome
borg compact -p /media/nfs/Backups/BackupHome
