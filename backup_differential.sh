#!/bin/bash
set -u
# Daniel Wyatt

function usage() {
    echo "Usage: $(basename $0) <server>"
    exit 1
}

# we accept 1 argument
[[ $# -eq 1 ]] || usage

# common.sh uses these to setup other common variables
server="$1"
suffix="differential"

thisdir="$(dirname $(readlink -f $0))"
common="$thisdir/common.sh"
. "$common" || exit 1

if [[ ! -e "$last_full" ]]; then
    debug "Error: No full backup exists!"
    mail_message "No full backup exists for server. Missing link: $last_full"
else
    debug "Performing differential backup"
    rsync --log-file="$log_file" \
          -aHz \
          --numeric-ids \
          --exclude-from="$exclusions" \
          --exclude-from="$common_exclusions" \
          --compare-dest="$last_full" \
          "root@$server:/" \
          "$backup_dest"
    result="$?"
    ln -s "../$(basename $(readlink -f $last_full))" "$backup_dest/last_full"
fi

# ignore vanishing files warning
[[ $result -eq 24 ]] && result=0

if [[ $result -eq 0 ]]; then
    # remove empty directories that rsync pulls in
    # (this may not be desirable in certain cases...)
    find "$backup_dest" -mindepth 1 -depth -type d -empty -delete
    rm -f "$last_differential"
    ln -s "$(basename $backup_dest)" "$last_differential"
    debug "Done"
else
    debug "Failed!"
    mail_log_file
    cd "$backup_dest/.."
    mv "$backup_dest" "FAILED_$(basename $backup_dest)"
    mv "$log_file" "FAILED_$(basename $log_file)"
fi
