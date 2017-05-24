#!/bin/bash
set -u

function usage() {
    echo "Usage: $(basename $0) <server>"
    exit 1
}

# we accept 1 argument
[[ $# -eq 1 ]] || usage

# common.sh uses these to setup other common variables
server="$1"
suffix="full"

thisdir="$(dirname $(readlink -f $0))"
common="$thisdir/common.sh"
. "$common" || exit 1

# if we have a previous full backup, use hard links to save time/space
if [[ -L "$last_full" ]]; then
    debug "Using previous full backup as base"
    rsync --log-file="$log_file" \
          -aHz \
          --delete \
          --link-dest="$last_full" \
          --numeric-ids \
          --exclude-from="$exclusions" \
          --exclude-from="$common_exclusions" \
          "root@$server:/" \
          "$backup_dest"
    result="$?"

# otherwise, do a full rsync
else
    debug "Performing full rsync"
    rsync --log-file="$log_file" \
          -aHz \
          --numeric-ids \
          --exclude-from="$exclusions" \
          --exclude-from="$common_exclusions" \
          "root@$server:/" \
          "$backup_dest"
    result="$?"
fi

# ignore vanishing files warning
[[ $result -eq 24 ]] && result=0

if [[ $result -eq 0 ]]; then
    rm -f "$last_full"
    ln -s "$(basename $backup_dest)" "$last_full"
    debug "Done"
else
    debug "Failed!"
    mail_log_file
    cd "$backup_dest/.."
    mv "$backup_dest" "FAILED_$(basename $backup_dest)"
    mv "$log_file" "FAILED_$(basename $log_file)"
fi

