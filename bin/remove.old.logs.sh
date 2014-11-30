#!/bin/bash
# this script will run every day
echo $0 started at `date`

/usr/sbin/logrotate --state /home/daps/daps_support/cfg/logrotate/status.tmp --force /home/daps/daps_support/cfg/logrotate.cfg
if [[ $? -ne 0 ]];then
    echo "ERROR executing logrotate in $0"
    exit 1
fi

echo $0 finished at `date`
exit 0
