#!/bin/bash

##############################################
# to be run every time a backup gets created #
##############################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO="/repo"

# TODO: allow use without cron and SIGHUP
echo "init at $(date)"

if [ -z "$(ls -A $REPO)" ]; then
   echo "$REPO is empty, creating borg repo"
   borg -r $REPO rcreate --encryption=none
else
    echo "$REPO is not empty"
fi

# call script when receiving SIGHUP
# set -e exits script after trap
set +e
# ensure containers are started
trap 'bash "/var/lib/borg_backup/borg_backup.sh" || echo "borg_backup.sh failed" && bash /var/lib/borg_backup/handle_containers.sh start' HUP

# await SIGHUP
while :; do
    sleep 2 & wait ${!}
done

