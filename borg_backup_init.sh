#!/bin/bash

##############################################
# to be run every time a backup gets created #
##############################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# TODO: allow use without cron and SIGHUP
echo "init at $(date)"
# call script when receiving SIGHUP
# set -e exits script after trap
set +e
# ensure nextcloud containers are started
trap 'bash "/var/lib/borg_backup/borg_backup.sh" || echo "borg_backup.sh failed" && bash /var/lib/borg_backup/handle_containers.sh start' HUP

# await SIGHUP
while :; do
    sleep 10 & wait ${!}
done

