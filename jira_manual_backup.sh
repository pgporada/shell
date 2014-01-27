#!/usr/bin/env bash

# Ticket: CNT-20131202.603276
USR=$(whoami)
EMAIL="guyfrom@website.com"
LOG="/home/$USR/backups/backup.log"
DOMAIN="website.com"
AVAILABLE_DISK_SIZE="$(df -h | awk 'NR==3 {print $4}' | sed 's/%//')"
DATADIR_FILE="/home/$USR/backups/jira.datadir-nightly.tar.gz"
MYSQL_FILE="/var/lib/mysql-backups/daily/j2ee-jira-nightly.dmp.gz"

echo >> ${LOG}
echo "[+] $(basename ${0}) is starting: $(date)" >> ${LOG}
echo "[+] Jira data directory backup begin: $(date)" >> ${LOG}
echo "[+] Pre backup disk usage: ${AVAILABLE_DISK_SIZE}%" >> ${LOG}


# VERY basic check to make sure we have space enough to gzip the data dir since it's ~30GB and probably WON't be shrinking
if [ ${AVAILABLE_DISK_SIZE} -gt "30" ]; then
   # Just incase there's any hidden files, we'll want to bring those along for the ride
   shopt -s dotglob
   # Since the current/ dir is a symlink you need to append the * and use the P flag
   /bin/tar czPf "${DATADIR_FILE}" /opt/j2ee/domains/$DOMAIN/jira/webapps/atlassian-jira/data/current/*
   shopt -u dotglob
   echo "[+] Post backup disk usage: $(df -h | awk 'NR==3 {print $4}')" >> ${LOG}
   echo "[+] Jira data directory backup end: $(date)" >> ${LOG}
else
   echo "[-] Jira data directory backup did not run: ${date}" >> ${LOG}
   echo "[-] Disk usage on server: ${AVAILABLE_DISK_SIZE}%" >> ${LOG}
   /bin/mail -s "Jira Backup Error on $(hostname)" ${EMAIL} < /home/$USR/backups/backup.log
fi

echo "[+] MySQL nightly dump copy begin: $(date)" >> ${LOG}
cp -f "${MYSQL_FILE}" /home/$USR/backups/. && chown -R $USR.$USR /home/$USR/backups && chmod -R 750 /home/$USR/backups
echo "[+] MySQL nightly dump copy end: $(date)" >> ${LOG}

echo "[+] $(basename ${0}) has completed: $(date)" >> ${LOG}
echo >> ${LOG}

