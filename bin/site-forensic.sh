#!/bin/sh -x
# script name: backup-site.sh
# the purpose of this script is to back up the site
if [[ -f /opt/php56/bin/php ]]; then
    export DRUSH_PHP=/opt/php56/bin/php
fi
export PATH=/bin:/usr/bin:/home/daps/bin

echo "site-backup.sh started at `date`"

DOCROOT=/home/daps/public_html
BKUPROOT=/home/daps/drush-backups/manual
BKUPDIR=${BKUPROOT}/daps

# source the database credentials
. /home/daps/.drush/site.settings.txt
# drupal
# DRNAME
# DRUSER
# DRPASS
# DRHOST
# civicrm
# CVNAME
# CVUSER
# CVPASS
# CFHOST

if [[ -e ${BKUPDIR} ]]; then
    rm -rf ${BKUPDIR}
    if [[ $? -ne 0 ]]; then
        echo "ERROR removing previous backup"
        exit 1
    fi
fi

mkdir --p ${BKUPDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating ${BKUPDIR}"
    exit 1
fi

# take the site offline
drush vset maintenance_mode 1 --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR taking site offline"
    exit 1
fi
drush cache-clear all --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR clearing cache"
    exit 1
fi

# tar up the site
tar -C ${DOCROOT} -cf ${BKUPDIR}/forensicsite.tar .
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to back up contents of ${DOCROOT}"
   exit 1
fi

# dump the drupal database
mysqldump --result-file ${BKUPDIR}/forensicdrupal.sql --no-autocommit --single-transaction --opt -Q --host=${DRHOST} --user=${DRUSER} --password=${DRPASS} ${DRNAME}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup drupal database"
   exit 1
fi
# dump the civicrm database
mysqldump --result-file ${BKUPDIR}/forensiccivicrm.sql --no-autocommit --single-transaction --opt -Q --host=${CVHOST} --user=${CVUSER} --password=${CVPASS} ${CVNAME}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup civicrm database"
   exit 1
fi

# take the site online
drush vset maintenance_mode 0 --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR taking site online"
    exit 1
fi
drush cache-clear all --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR clearing cache"
    exit 1
fi

# zip up the three files
tar --create --directory=${BKUPROOT} --file=${BKUPROOT}/forensicdaps.tar.gz --gzip daps
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup daps site"
   exit 1
fi

# remove temporary directory
rm -rf ${BKUPDIR}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to remove temporary backup directory"
   exit 1
fi

echo "site-backup.sh stopped at `date`"
exit 0
