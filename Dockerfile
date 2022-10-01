FROM chrisbesch/borg2

RUN apt-get update && \
    apt-get install -y docker.io

# copy scripts
COPY ./borg_backup_init.sh ./borg_backup.sh ./handle_containers.sh /var/lib/borg_backup/

ENTRYPOINT ["bash", "/var/lib/borg_backup/borg_backup_init.sh"]

