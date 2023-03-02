#!/bin/sh

#backup home folder to nfs share
#dependencies: borg

borg create -s --iec -p --exclude-if-present .nobackup -C zstd,8 /media/nfs/Backups/BackupHome::"$(date --iso-8601=minutes)" ~/
