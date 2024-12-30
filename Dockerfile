FROM "debian"

RUN apt-get update && \
    apt-get install -y curl

RUN curl -L -o /bin/borg https://github.com/borgbackup/borg/releases/download/2.0.0b14/borg-linux-glibc236 && \
    bash -c 'sha256sum -c <(echo 4c7222e5324f907f53331dee6783c5c4cd99cee1dfdff4893c839f798d2f3e2b  /bin/borg)' && \
    chmod +x /bin/borg && \
    borg --version

# copy scripts
COPY ./borg_backup_init.sh ./borg_backup.sh ./handle_containers.sh /var/lib/borg_backup/

ENTRYPOINT ["bash", "/var/lib/borg_backup/borg_backup_init.sh"]

