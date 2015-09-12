#!/bin/bash
# this script will run every day
echo $0 started at `date`
cd /home/daps/daps_support/logs
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR accessing /home/daps/daps_support/logs"
    exit 1
fi
#
echo "Removing dapsscript logs older than 1 hour"
find . -type f -name "dapsscript.*.log" -mmin +60 -ls -exec rm -f {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing /home/daps/daps_support/logs/dapsscript.*.log"
    exit 1
fi
#
echo "Removing dapscron logs older than 30 days"
find . -type f -name "dapscron.*.log" -mtime +30 -ls -exec rm -f {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing /home/daps/daps_support/logs/dapscron.*.log"
    exit 1
fi
#
echo "Removing site-backup cron logs older than 30 days"
find . -type f -name "site-backup.*.cron.log" -mtime +30 -ls -exec rm -f {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing /home/daps/daps_support/logs/site-backup.*.cron.log"
    exit 1
fi
#
echo "Cleaning up after myself"
find . -type f -name "remove.old.logs.*.log" -mtime +30 -ls -exec rm -f {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing /home/daps/daps_support/logs/remove.old.logs.*.log"
    exit 1
fi
find . -type f -name "remove.old.logs.*.cron.log" -mtime +30 -ls -exec rm -f {} \;
if [[ $? -ne 0 ]];then
    echo "DAPS ERROR removing /home/daps/daps_support/logs/remove.old.logs.*.cron.log"
    exit 1
fi
echo $0 finished at `date`
exit 0
