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
    else
        echo "borg backup repo valid"
    fi

    echo "creating borg backup"
    borg create --error --compression $BORG_COMPRESSION "${REPO}::${BORG_PREFIX}_{now}" $ORIGIN

    if [ ! -z ${PRUNE_CFG+x} ]; then
        echo "running: borg prune $PRUNE_CFG $REPO"
        borg prune $PRUNE_CFG $REPO
    else
        echo "PRUNE_CFG not defined"
    fi

    echo "compacting borg repo"
    borg compact $REPO
}

echo "starting backup at $(date)"
bash /var/lib/borg_backup/handle_containers.sh stop

create_backup

bash /var/lib/borg_backup/handle_containers.sh start
echo "backup complete at $(date)"

