#!/bin/sh
# This script is used to automate the drupal and civicrm tasks 

export PATH=/home/daps/bin:/usr/local/jdk/bin:/home/daps/perl5/bin:/usr/kerberos/bin:/usr/lib/courier-imap/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin:/home/daps/bin
echo $0 started at `date`
/home/daps/bin/drush -u 1 -r /home/daps/public_html cron
rc=$?
echo drupal rc=$rc
/home/daps/bin/drush -u 1 -r /home/daps/public_html civicrm-api job.execute auth=0 -y
rc=$?
echo civicrm rc=$rc
echo $0 finished at `date`
exit 0
