#!/bin/bash

###################################################
# to be run when the borg_backup container starts #
###################################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ORIGIN="/origin"
REPO="/repo"
BORG_EXCLUDE="/borg_exclude"

function create_backup() {
    export BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK=yes
    if ! borg -r $REPO check; then
        echo "ERROR: borg backup repo invalid"
        return
    else
        echo "borg backup repo valid"
    fi

    if [[ -f $BORG_EXCLUDE ]]; then
        echo "creating borg backup with excluded patterns:"
        cat $BORG_EXCLUDE
        borg -r $REPO create --info --exclude-from $BORG_EXCLUDE --compression $BORG_COMPRESSION "${BORG_PREFIX}_{now}" $ORIGIN
    else
        echo "creating borg backup without excluded patterns"
        borg -r $REPO create --info --compression $BORG_COMPRESSION "${BORG_PREFIX}_{now}" $ORIGIN
    fi

    if [ ! -z ${PRUNE_CFG+x} ]; then
        echo "running: borg -r $REPO prune $PRUNE_CFG"
        borg -r $REPO prune $PRUNE_CFG
    else
        echo "PRUNE_CFG not defined"
    fi

    echo "compacting borg repo"
    borg -r $REPO compact
}

echo "starting backup at $(date)"
bash /var/lib/borg_backup/handle_containers.sh stop

create_backup

bash /var/lib/borg_backup/handle_containers.sh start
echo "backup complete at $(date)"

