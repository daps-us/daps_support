#!/bin/sh
# script name: take.backup.sh
# the purpose of this script is to back up the site, however it does not bring the site online afterward.
# this script is used right before a drush-pm update command

export DRUSH_PHP=/opt/cpanel/ea-php56/root/usr/bin/php
export PATH=/home/daps/daps_support/bin:/usr/local/jdk/bin:/home/daps/perl5/bin:/usr/kerberos/bin:/usr/lib/courier-imap/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/bin:/usr/X11R6/bin:/home/daps/bin
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH

scriptname=$(basename $0)
if [[ -z $scriptname ]]; then
    echo "ERROR determining script name in $0"
    exit 1
fi

echo "$scriptname started at $(date)"

# source the site specific pieces
echo "INFO Sourcing environment variables at $(date)"
. ~/daps_support/cfg/site.cfg

if [[ -z ${DOCROOT} ]]; then
    echo "ERROR DOCROOT not defined in $scriptname"
    exit 1
fi

if [[ -z ${BKUPROOT} ]]; then
    echo "ERROR BKUPROOT not defined in $scriptname"
    exit 1
fi

if [[ -z ${DRNAME} ]]; then
    echo "ERROR DRNAME not defined in $scriptname"
    exit 1
fi

if [[ -z ${DRUSER} ]]; then
    echo "ERROR DRUSER not defined in $scriptname"
    exit 1
fi

if [[ -z ${DRPASS} ]]; then
    echo "ERROR DRPASS not defined in $scriptname"
    exit 1
fi

if [[ -z ${DRHOST} ]]; then
    echo "ERROR DRHOST not defined in $scriptname"
    exit 1
fi

if [[ -z ${CVNAME} ]]; then
    echo "ERROR CVNAME not defined in $scriptname"
    exit 1
fi

if [[ -z ${CVUSER} ]]; then
    echo "ERROR CVUSER not defined in $scriptname"
    exit 1
fi

if [[ -z ${CVPASS} ]]; then
    echo "ERROR CVPASS not defined in $scriptname"
    exit 1
fi

if [[ -z ${CVHOST} ]]; then
    echo "ERROR CVHOST not defined in $scriptname"
    exit 1
fi

timestamp=$(date +"%Y%m%d%H%M%S")
BKUPDIR=${BKUPROOT}/${timestamp}/daps
echo "INFO Backup directory set to $BKUPDIR at $(date)"

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
echo "INFO taking the site offline at $(date)"
drush vset maintenance_mode 1 --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR taking site offline"
    exit 1
fi
echo "INFO clearing caches at $(date)"
drush cache-clear all --root=${DOCROOT} -d
if [[ $? -ne 0 ]]; then
    echo "ERROR clearing cache"
    exit 1
fi

# tar up the site
echo "INFO saving off a copy of the ${DOCROOT} at $(date)"
tar -C ${DOCROOT} -cf ${BKUPDIR}/site.tar .
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to back up contents of ${DOCROOT}"
   exit 1
fi

# dump the drupal database
echo "INFO taking database dump of ${DRNAME} at $(date)"
mysqldump --result-file ${BKUPDIR}/drupal.sql --no-autocommit --single-transaction --opt -Q --host=${DRHOST} --user=${DRUSER} --password=${DRPASS} ${DRNAME}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup drupal database"
   exit 1
fi
# dump the civicrm database
echo "INFO taking database dump of ${CVNAME} at $(date)"
mysqldump --result-file ${BKUPDIR}/civicrm.sql --no-autocommit --single-transaction --opt -Q --host=${CVHOST} --user=${CVUSER} --password=${CVPASS} ${CVNAME}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup civicrm database"
   exit 1
fi

# zip up the three files
echo "INFO creating backup file of site at $(date)"
tar --create --directory=${BKUPROOT}/${timestamp} --file=${BKUPROOT}/${timestamp}/daps.tar.gz --gzip daps
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to backup daps site"
   exit 1
fi

# remove temporary directory
echo "INFO removing temporary backup directory ${BKUPDIR} at $(date)"
rm -rf ${BKUPDIR}
if [[ $? -ne 0 ]]; then
   echo "ERROR Unable to remove temporary backup directory"
   exit 1
fi

echo "${scriptname} stopped at $(date). Proceed with updates"
exit 0
