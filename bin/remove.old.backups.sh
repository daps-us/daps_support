#!/bin/bash
# this script will run every day
echo $0 started at $(date)
cd /home/daps/daps_support/backups
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR accessing /home/daps/daps_support/backups"
    exit 1
fi
#
echo "Removing backups older than 15 days"
find . -depth -mtime +15 -type d -ls -exec rm -rf {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing old backups from /home/daps/daps_support/backups"
    exit 1
fi
echo $0 finished at $(date)
exit 0
