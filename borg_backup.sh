#!/bin/bash

###################################################
# to be run when the borg_backup container starts #
###################################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ORIGIN="/origin"
REPO="/repo"

function create_backup() {
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    if ! borg check $REPO; then
        echo "ERROR: borg backup repo invalid"
        return
    fi

    echo "creating borg backup"
    borg create -error --compression ${BORG_COMPRESSION} "${REPO}::${BORG_PREFIX}_{now}" $ORIGIN

    echo "pruning borg repo"
    borg prune --keep-last 1 --keep-monthly 1 $REPO

    echo "compacting borg repo"
    borg compact $REPO
}

echo "starting backup at $(date)"
bash /var/lib/borg_backup/handle_containers.sh stop

create_backup

bash /var/lib/borg_backup/handle_containers.sh start
echo "backup complete at $(date)"

