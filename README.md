# docker_borg_backup
Schedule [Borg Backup](https://www.borgbackup.org) with Docker-Compose and [docker_cron](https://github.com/christopher-besch/docker_cron).

## Example Usage
```yaml
version: "3.7"

services:
    DockerBorgBackup:
        image: chrisbesch/docker_borg_backup
        volumes:
            # what to create a backup of
            - "./origin:/origin:r"
            # where to store backup (needs to be initialized with `borg init --encryption=none ./borg_repo`)
            - "./borg_repo:/repo"
            # optional: borg patterns that should be excluded
            - "./borg_exclude:/borg_exclude"
            # required when stopping containers before backup
            # - "/var/run/docker.sock:/var/run/docker.sock:rw"
        environment:
            # perform backup every day at 03:00
            - "CRON_TIME=0 3 * * *"

            # see https://borgbackup.readthedocs.io/en/stable/internals/data-structures.html?highlight=compression#compression
            - BORG_COMPRESSION=zstd,22

            # backup name is "${BORG_PREFIX}_{now}"
            - BORG_PREFIX=my_prefix

            # see: https://borgbackup.readthedocs.io/en/stable/usage/prune.html
            # leave empty to not prune
            - "PRUNE_CFG=--keep-last 3"

            # can be used to stop containers before and start again after backup (multiple seperated with spaces)
            # - "CONTAINERS=MyContainer1Name MyContainer2Name"
      
    # required to wake up BorgBackup container
    DockerCron:
        image: chrisbesch/docker_cron
        volumes:
            - "/var/run/docker.sock:/var/run/docker.sock:rw"
        environment:
            - TZ=Europe/Berlin
```
