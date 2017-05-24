#!/bin/bash
set -u

function usage() {
    echo "Usage: $(basename $0)"
    exit 1
}

# we accept 0 arguments
[[ $# -eq 0 ]] || usage

thisdir="$(dirname $(readlink -f $0))"
config_file="$thisdir/config.cfg"

. "$config_file"

# find full backups older than X days
find "$backup_root" -mindepth 2 -maxdepth 2 -name "*_full" -ctime "+${backup_days_max}" | while read full_backup; do
    full=$(readlink -f "$full_backup")
    # find differential backups that reference the old full backup
    find "$backup_root" -mindepth 2 -maxdepth 2 -name "*_differential" -type d | while read differential_backup; do
        diffr=$(readlink -f "$differential_backup/last_full")
        if [[ "$full" == "$diffr" ]]; then
            rm -rf "$differential_backup"
            rm -f "$differential_backup.log"
        fi
    done
    rm -rf "$full_backup"
    rm -f "$full_backup.log"
done
