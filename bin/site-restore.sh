#!/bin/sh -x
# this script will be used to restore a site that.

export DRUSH_PHP=/opt/cpanel/ea-php56/root/usr/bin/php
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH

DOCROOT=/var/www
SITENAME=html

BKUPDIR=/root/drush-backups/manual/daps
DOCDIR=${DOCROOT}/${SITENAME}
SETTINGSDIR=${DOCDIR}/sites/default

# sanity checks
if [[ ! -e ${DOCROOT} ]]; then
    echo "ERROR finding ${DOCROOT}"
    exit 1
fi

if [[ ! -e ${BKUPDIR} ]]; then
    echo "ERROR finding ${BKUPDIR}"
    exit 1
fi

if [[ ! -e ${DOCDIR} ]]; then
    echo "WARN finding ${DOCDIR}"
fi

if [[ ! -e ${BKUPDIR} ]]; then
    echo "ERROR finding ${BKUPDIR}"
    exit 1
fi

if [[ ! -e ${SETTINGSDIR} ]]; then
    echo "WARN finding ${SETTINGSDIR}"
fi

if [[ ! -e ${BKUPDIR}/drupal.sql ]]; then
    echo "ERROR finding ${BKUPDIR}/drupal.sql"
    exit 1
fi

if [[ ! -e ${BKUPDIR}/civicrm.sql ]]; then
    echo "ERROR finding ${BKUPDIR}/civicrm.sql"
    exit 1
fi

if [[ ! -e ${BKUPDIR}/site.tar ]]; then
    echo "ERROR finding ${BKUPDIR}/site.tar"
    exit 1
fi

if [[ ! -e ${SETTINGSDIR}/settings.php ]]; then
    echo "WARN finding ${SETTINGSDIR}/settings.php"
fi

if [[ ! -e ${SETTINGSDIR}/civicrm.settings.php ]]; then
    echo "WARN finding ${SETTINGSDIR}/civicrm.settings.php"
fi

# save off the local settings files
cp ${SETTINGSDIR}/settings.php ${BKUPDIR}
if [[ $? -ne 0 ]]; then
    echo "WARN unable to copy ${SETTINGSDIR}/settings.php to ${BKUPDIR}"
fi

cp ${SETTINGSDIR}/civicrm.settings.php ${BKUPDIR}
if [[ $? -ne 0 ]]; then
    echo "WARN unable to copy ${SETTINGSDIR}/civicrm.settings.php to ${BKUPDIR}"
fi

# source the db credentials
. /root/.drush/${SITENAME}.settings.txt

# remove the old - hopefully you made a backup
rm -rf ${DOCDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR removing ${DOCDIR}"
    exit 1
fi

mysqladmin -u${MYUSER} -p${MYPASS} -f drop ${DRNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR removing old drupal database."
    exit 1
fi

mysqladmin -u${MYUSER} -p${MYPASS} -f drop ${CVNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR removing old civicrm database."
    exit 1
fi

# start adding things back
mysqladmin -u${MYUSER} -p${MYPASS} create ${DRNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new drupal database."
    exit 1
fi

mysqladmin -u${MYUSER} -p${MYPASS} create ${CVNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new civicrm database."
    exit 1
fi

mysql -u${MYUSER} -p${MYPASS} ${DRNAME} < ${BKUPDIR}/drupal.sql
if [[ $? -ne 0 ]]; then
    echo "ERROR loading new drupal database."
    exit 1
fi

mysql -u${MYUSER} -p${MYPASS} ${CVNAME} < ${BKUPDIR}/civicrm.sql
if [[ $? -ne 0 ]]; then
    echo "ERROR loading new civicrm database."
    exit 1
fi

mkdir -p ${DOCDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new ${DOCDIR}"
    exit 1
fi

tar -xf ${BKUPDIR}/site.tar -C ${DOCDIR} .
if [[ $? -ne 0 ]]; then
    echo "ERROR populating ${DOCDIR}"
    exit 1
fi

# remove the settings files
rm -f ${SETTINGSDIR}/settings.php
if [[ $? -ne 0 ]]; then
    echo "ERROR removing ${SETTINGSDIR}/settings.php"
    exit 1
fi

rm -f ${SETTINGSDIR}/civicrm.settings.php
if [[ $? -ne 0 ]]; then
    echo "ERROR removing ${SETTINGSDIR}/civicrm.settings.php"
    exit 1
fi

# copy the settings files
cp ${BKUPDIR}/settings.php ${SETTINGSDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR unable to copy ${BKUPDIR}/settings.php to ${SETTINGSDIR}"
    exit 1
fi

cp ${BKUPDIR}/civicrm.settings.php ${SETTINGSDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR unable to copy ${BKUPDIR}/civicrm.settings.php to ${SETTINGSDIR}"
    exit 1
fi

# set owners and permissions
chown -R root:root ${DOCDIR}
if [[ $? -ne 0 ]]; then
    echo "ERROR setting owner on ${DOCDIR}"
    exit 1
fi

chmod -R 0777 ${DOCDIR}/sites/default/files
if [[ $? -ne 0 ]]; then
    echo "ERROR setting permissions on ${DOCDIR}/sites/default/files"
    exit 1
fi
