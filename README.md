# server-rsync-backups
Simple scripts to manage full &amp; differential backups of linux servers via plain rsync.

Uses hard links to save space between differential backups.

Note: In many cases I would choose to use a more complete backup solution, like Bacula.
These scripts are meant to be a quick solution for simple backup needs.

## What it Looks Like

```
[daniel@daniel-pc rsync_backups]$ tree -FL 2 /rsync_backups/
/rsync_backups/
├── exclusions
├── hslave1/
│   ├── 2016_07_11_18_12_full/
│   ├── 2016_07_11_18_12_full.log
│   ├── 2016_07_11_18_19_differential/
│   ├── 2016_07_11_18_19_differential.log
│   ├── exclusions
│   ├── last_differential -> 2016_07_11_18_19_differential/
│   └── last_full -> 2016_07_11_18_12_full/
└── hslave2/
    ├── 2016_07_11_18_16_full/
    ├── 2016_07_11_18_16_full.log
    ├── 2016_07_11_18_19_differential/
    ├── 2016_07_11_18_19_differential.log
    ├── exclusions
    ├── last_differential -> 2016_07_11_18_19_differential/
    └── last_full -> 2016_07_11_18_16_full/

10 directories, 7 files
[daniel@daniel-pc rsync_backups]$ 
```

## Requirements
* SSH public-key auth for root user on target servers
* Required commands:
  * uuencode
  * unix2dos
  * mail
  * sendmail

## Setup
1. Setup public-key SSH auth between your backup server and backup targets.
2. On your backup server, clone the repo with: `git clone https://github.com/dewyatt/rsync-backups.git`
3. Edit the file servers.txt so that it contains the names of the servers to back up (one per line, no comments).
4. Edit config.cfg (which is 'sourced' as a shell script)
  * Set a destination for backups
  * Set email address(es) for failure notifications
  * Set maximum days to keep backups around (see remove_old_backups.sh for what that really means)
5. (Optional) Use `your_backup_root/exclusions` to list, line by line, paths to exclude from all backups. Example:

  ```/proc
  /dev/*
  /sys
  /tmp/*
  /run
  /var/run
  ```

6. (Optional) Use `your_backup_root/server_name/exclusions` to list, line by line, paths to exclude from a sepcific server's backups.

## Usage
* `backup_full.sh <server>` - Runs a full backup of the target server.
* `backup_differential.sh <server>` - Runs a differential backup of the target server.
  * Full backup must exist first.
* `backup_all_full.sh` - Calls backup_full.sh for all servers in servers.txt.
  * Intended to be used in a cron job.
* `backup_all_differential.sh` - Calls backup_differential.sh for all servers in servers.txt.
  * Full backups must exist first.
  * Intended to be used in a cron job.
* `remove_old_backups.sh` - Removes old backups.
  * Intended to be used in a cron job.
