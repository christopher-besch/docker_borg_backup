#!/bin/bash

#####################################
# used to start and stop containers #
#####################################
set -euo pipefail
IFS=$' \n\t'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [ ! -z ${CONTAINERS+x} ]; then
    echo "running: docker $@ $CONTAINERS"
    docker $@ $CONTAINERS
else
    echo "no containers to stop/start"
fi

