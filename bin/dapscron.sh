#!/bin/bash
# This script is used to automate the drupal and civicrm tasks 

export PATH=/home/daps/bin:/usr/local/jdk/bin:/home/daps/perl5/bin:/usr/kerberos/bin:/usr/lib/courier-imap/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin
echo $0 started at `date`
/home/daps/bin/drush -u 1 -r /home/daps/public_html cron
rc=$?
if [[ $rc -eq 0 ]];then
   echo "DAPS INFO Drupal cron successful. rc=$rc"
else
   echo "DAPS ERROR Drupal cron failed. rc=$rc"
fi
/home/daps/drush -u 1 -r /home/daps/public_html civicrm-api job.execute auth=0 -y
rc=$?
if [[ $rc -eq 0 ]];then
   echo "DAPS INFO Civicrm cron successful. rc=$rc"
else
   echo "DAPS ERROR Civicrm cron failed. rc=$rc"
fi
echo $0 finished at `date`
exit 0
