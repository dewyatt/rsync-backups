#!/bin/bash
set -u

# Call backup_full.sh for all servers in file 'servers.txt'

thisdir="$(dirname $(readlink -f $0))"

for server in $(cat "$thisdir/servers.txt"); do
	"$thisdir/backup_full.sh" "$server"
done
