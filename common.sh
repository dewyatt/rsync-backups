thisdir="$(dirname $(readlink -f $0))"
config_file="$thisdir/config.cfg"

. "$config_file"

function debug() {
    [[ $DEBUG -eq 0 ]] && return
    echo "$@"
}

function mail_log_file() {
    [[ -z "$failure_email" ]] && return
    (echo -e "rsync backup failed for server $server. View the attached log for details"; unix2dos < "$log_file" | uuencode $(basename "$log_file")) | mail -s "rsync backup failure on server $server" "$failure_email"
}

function mail_message() {
    [[ -z "$failure_email" ]] && return
    echo -e "$@" | mail -s "rsync backup failure on server $server" "$failure_email"
}

backup_dir="$backup_root/$server"
common_exclusions="$backup_root/exclusions"
exclusions="$backup_dir/exclusions"

timestamp=$(date '+%Y_%m_%d_%H_%M')
backup_dest="$backup_dir/${timestamp}_${suffix}"
log_file="$backup_dir/${timestamp}_${suffix}.log"

last_differential="$backup_dir/last_differential"
last_full="$backup_dir/last_full"

debug "server:            $server"
debug "config_file:       $config_file"
debug "backup_dir:        $backup_dir"
debug "common_exclusions: $common_exclusions"
debug "exclusions:        $exclusions"
debug "backup_dest:       $backup_dest"
debug "log_file:          $log_file"
debug "last_differential: $last_differential"
debug "last_full:         $last_full"

if [[ -e "$backup_dest" ]]; then
    debug "Destination exists, aborting"
    exit 1
fi

ls "$backup_root" &>/dev/null

mkdir -p "$backup_dir"
mkdir -p "$backup_dest"

[[ -f "$common_exclusions" ]] || cat <<END > "$common_exclusions"
/proc
/dev/*
/sys
/tmp/*
/run
/var/run
END

touch "$exclusions"
