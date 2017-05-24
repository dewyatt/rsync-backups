#!/bin/bash
set -u

# Call backup_differential.sh for all servers in file 'servers.txt'

thisdir="$(dirname $(readlink -f $0))"

for server in $(cat "$thisdir/servers.txt"); do
	"$thisdir/backup_differential.sh" "$server"
done

