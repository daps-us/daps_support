#!/bin/bash
# this script will be used to restore a site that.

# source the site specific settings
echo $0 started at $(date)
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH

# source the site specific settings
echo 'INFO: Fetching configuration information...'
. ~/daps_support/cfg/site.cfg
if [[ $? -ne 0 ]];then
    echo "ERROR attempting to fetch site settings."
    exit 1
fi

# sanity checks
if [[ -e ${DOCROOT} ]]; then
    if [[ ! -d ${DOCROOT} ]];then
        echo "ERROR ${DOCROOT} is not a directory."
        exit 1
    fi
fi

if [[ -z ${DRUSER} ]]; then
    echo "ERROR locating DRUSER"
    exit 1
fi

if [[ -z ${DRPASS} ]]; then
    echo "ERROR locating DRPASS"
    exit 1
fi

if [[ -z ${DRNAME} ]]; then
    echo "ERROR locating DRNAME"
    exit 1
fi

if [[ -z ${DRHOST} ]]; then
    echo "ERROR locating DRHOST"
    exit 1
fi

if [[ -z ${CVUSER} ]]; then
    echo "ERROR locating CVUSER"
    exit 1
fi

if [[ -z ${CVPASS} ]]; then
    echo "ERROR locating CVPASS"
    exit 1
fi

if [[ -z ${CVNAME} ]]; then
    echo "ERROR locating CVNAME"
    exit 1
fi

if [[ -z ${CVHOST} ]]; then
    echo "ERROR locating CVHOST"
    exit 1
fi

if [[ -z ${SITEOWNER} ]]; then
    echo "ERROR locating SITEOWNER"
    exit 1
fi

if [[ -z ${SITEGROUP} ]]; then
    echo "ERROR locating SITEGROUP"
    exit 1
fi

if [[ -e ${BKUPROOT} ]]; then
    if [[ ! -d ${BKUPROOT} ]];then
        echo "ERROR ${BKUPROOT} is not a directory."
        exit 1
    fi
else
    echo "ERROR finding ${BKUPROOT}"
    exit 1
fi

# now that we have the backup directory, let us find the version to deploy
# first, check for one on the command line
if [[ -z $1 ]];then
    # nothing on the command line
    SRCDIR=$(ls -tr ${BKUPROOT} | tail -1)
    if [[ $? -ne 0 ]];then
        echo "ERROR getting current source directory from ${BKUPROOT}"
        exit 1
    fi
else
    SRCDIR=$1
fi
SRC=${BKUPROOT}/${SRCDIR}
echo "INFO: Restoring source file ${SRC}..."

if [[ ! -f ${SRC} ]];then
    echo "ERROR locating source file ${SRC}"
    exit 1
fi

TGTDIR=/home/daps/tmp/tempsite
echo "INFO: Unpacking to temporary target ${TGTDIR}..."
# first test, if the directory exists, remove it
if [[ -e ${TGTDIR} ]];then
    # the temp workspace is in use
    if [[ -d ${TGTDIR} ]];then
        # it is a previous directory
        rm -rf ${TGTDIR}
        if [[ $? -ne 0 ]];then
            echo "ERROR removing previous ${TGTDIR}"
            exit 1
        fi
    else
        # it is not a directory - unexpected
        echo "ERROR ${TGTDIR} encountered. Unexpected."
        exit 1
    fi
fi

# there is no temp workspace create it.
mkdir -p ${TGTDIR}
if [[ $? -ne 0 ]];then
    echo "ERROR creating ${TGTDIR}"
    exit 1
fi
mkdir -p ${TGTDIR}/local
if [[ $? -ne 0 ]];then
    echo "ERROR creating ${TGTDIR}/local"
    exit 1
fi

# at this point, we have our source file and our temp workspace
# unzip the package

tar -C ${TGTDIR} -xzpf ${SRC}
if [[ $? -ne 0 ]]; then
    echo "ERROR unzipping ${SRC}"
    exit 1
fi

if [[ ! -e ${TGTDIR}/daps/drupal.sql ]]; then
    echo "ERROR finding ${TGTDIR}/daps/drupal.sql"
    exit 1
fi

if [[ ! -e ${TGTDIR}/daps/civicrm.sql ]]; then
    echo "ERROR finding ${TGTDIR}/daps/civicrm.sql"
    exit 1
fi

if [[ ! -e ${TGTDIR}/daps/site.tar ]]; then
    echo "ERROR finding ${TGTDIR}/daps/site.tar"
    exit 1
fi

# at this point, we have the 3 files we need to create the site.
# drupal.sql is used to repopulate the daps_drupal database
# civicrm.sql is used to repopulate the daps_civicdrm database
# site.tar is the drupal files.

# now let us snag the things we want from the old site, if they exist

SETTINGSDIR=${DOCROOT}/sites/default
echo "INFO: Backing up ${SETTINGSDIR}..."
if [[ ! -e ${SETTINGSDIR} ]]; then
    echo "WARN did not find ${SETTINGSDIR}"
fi

if [[ ! -e ${SETTINGSDIR}/settings.php ]]; then
    echo "WARN did not find ${SETTINGSDIR}/settings.php. Using defaults..."
    if [[ -f ${HOME}/daps_support/cfg/settings.php ]]
    then
        cp ${HOME}/daps_support/cfg/settings.php ${TGTDIR}/local
        if [[ $? -ne 0 ]]
        then
           echo "ERROR unable to copy ${HOME}/daps_support/cfg//settings.php to ${TGTDIR}/local"
           exit 1
       fi
    fi
else
    # save off the local settings files
    cp ${SETTINGSDIR}/settings.php ${TGTDIR}/local
    if [[ $? -ne 0 ]]; then
        echo "ERROR unable to copy ${SETTINGSDIR}/settings.php to ${TGTDIR}/local"
        exit 1
    fi
fi

if [[ ! -e ${SETTINGSDIR}/civicrm.settings.php ]]; then
    echo "WARN did not find ${SETTINGSDIR}/civicrm.settings.php"
    if [[ -f ${HOME}/daps_support/cfg/civicrm.settings.php ]]
    then
        cp ${HOME}/daps_support/cfg/civicrm.settings.php ${TGTDIR}/local
        if [[ $? -ne 0 ]]
        then
           echo "ERROR unable to copy ${HOME}/daps_support/cfg//settings.php to ${TGTDIR}/local"
           exit 1
       fi
    fi
else
    cp ${SETTINGSDIR}/civicrm.settings.php ${TGTDIR}/local
    if [[ $? -ne 0 ]]; then
        echo "ERROR unable to copy ${SETTINGSDIR}/civicrm.settings.php to ${TGTDIR}/local"
        exit 1
    fi
fi

# change ownership of all files on default directory (or you won't be able to remove it)
echo "INFO: Removing ${DOCROOT}..."
sudo chown -R daps:daps ${DOCROOT}
if [[ $? -ne 0 ]]
then
    echo "ERROR changing owner of ${DOCROOT}"
    exit 1
fi
# change permissions on default directory (or you won't be able to remove it)
sudo chmod -R 0775 ${DOCROOT}
if [[ $? -ne 0 ]];then
    echo "ERROR unable to set permissions on ${DOCROOT}"
    exit 1
fi

# remove the old site files - hopefully you made a backup
if [[ -d ${DOCROOT} ]];then
    rm -rf ${DOCROOT}
    if [[ $? -ne 0 ]]; then
        echo "ERROR removing ${DOCROOT}"
        exit 1
    fi
fi

# drop the old databases
echo "INFO: Removing databases..."
mysqladmin -u${DRUSER} -p${DRPASS} -f drop ${DRNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR removing old drupal database."
    exit 1
fi

mysqladmin -u${CVUSER} -p${CVPASS} -f drop ${CVNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR removing old civicrm database."
    exit 1
fi

# start adding things back
echo "INFO: Restoring databases..."
mysqladmin -u${DRUSER} -p${DRPASS} create ${DRNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new drupal database."
    exit 1
fi

mysqladmin -u${CVUSER} -p${CVPASS} create ${CVNAME}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new civicrm database."
    exit 1
fi

mysql -u${DRUSER} -p${DRPASS} ${DRNAME} < ${TGTDIR}/daps/drupal.sql
if [[ $? -ne 0 ]]; then
    echo "ERROR loading new drupal database."
    exit 1
fi

mysql -u${DRUSER} -p${DRPASS} ${DRNAME} < ${HOME}/daps_support/bin/clear_drupal_caches.sql
if [[ $? -ne 0 ]]; then
    echo "ERROR clearing caches of drupal database."
    exit 1
fi

mysql -u${CVUSER} -p${CVPASS} ${CVNAME} < ${TGTDIR}/daps/civicrm.sql
if [[ $? -ne 0 ]]; then
    echo "ERROR loading new civicrm database."
    exit 1
fi

echo "INFO: Restoring ${DOCROOT}..."
mkdir -p ${DOCROOT}
if [[ $? -ne 0 ]]; then
    echo "ERROR creating new ${DOCROOT}"
    exit 1
fi

tar -xf ${TGTDIR}/daps/site.tar -C ${DOCROOT} .
if [[ $? -ne 0 ]]; then
    echo "ERROR populating ${DOCROOT}"
    exit 1
fi

# set owners and permissions
chown -R ${SITEOWNER}:${SITEGROUP} ${DOCROOT}
if [[ $? -ne 0 ]]; then
    echo "ERROR setting owner on ${DOCROOT}"
    exit 1
fi

chmod -R 0777 ${DOCROOT}/sites/default/files
if [[ $? -ne 0 ]]; then
    echo "ERROR setting permissions on ${DOCROOT}/sites/default/files"
    exit 1
fi

# change permissions on default directory - new one just got installed
chmod 0775 ${DOCROOT}/sites/default
if [[ $? -ne 0 ]];then
    echo "ERROR unable to set permissions on ${DOCROOT}/sites/default"
    exit 1
fi

# if we have a backup settings.php
if [[ -f ${TGTDIR}/local/settings.php ]];then
    # make the current one writable
    chmod 0644 ${SETTINGSDIR}/settings.php
    if [[ $? -ne 0 ]];then
        echo "ERROR setting permissions on ${SETTINGSDIR}/settings.php."
        exit 1
    fi
    # remove the settings.php file
    rm -f ${SETTINGSDIR}/settings.php
    if [[ $? -ne 0 ]]; then
        echo "ERROR removing ${SETTINGSDIR}/settings.php"
        exit 1
    fi
    # copy the backup settings.php file
    cp ${TGTDIR}/local/settings.php ${SETTINGSDIR}
    if [[ $? -ne 0 ]]; then
        echo "ERROR unable to copy ${TGTDIR}/local/settings.php to ${SETTINGSDIR}"
        exit 1
    fi
    # make the new one read-only
    chmod 0444 ${SETTINGSDIR}/settings.php
    if [[ $? -ne 0 ]];then
        echo "ERROR setting permissions on ${SETTINGSDIR}/settings.php."
        exit 1
    fi
fi

# if we have a backup civicrm.settings.php
if [[ -f ${TGTDIR}/local/civicrm.settings.php ]];then
    # make the current one writable
    chmod 0644 ${SETTINGSDIR}/civicrm.settings.php
    if [[ $? -ne 0 ]];then
        echo "ERROR setting permissions on ${SETTINGSDIR}/civicrm.settings.php."
        exit 1
    fi
    # remove the civicrm.settings.php file
    rm -f ${SETTINGSDIR}/civicrm.settings.php
    if [[ $? -ne 0 ]]; then
        echo "ERROR removing ${SETTINGSDIR}/civicrm.settings.php"
        exit 1
    fi
    # copy the backup civicrm.settings.php file
    cp ${TGTDIR}/local/civicrm.settings.php ${SETTINGSDIR}
    if [[ $? -ne 0 ]]; then
        echo "ERROR unable to copy ${TGTDIR}/local/civicrm.settings.php to ${SETTINGSDIR}"
        exit 1
    fi
    # make the new one read-only
    chmod 0444 ${SETTINGSDIR}/civicrm.settings.php
    if [[ $? -ne 0 ]];then
        echo "ERROR setting permissions on ${SETTINGSDIR}/settings.php."
        exit 1
    fi
fi

# copy in the htaccess file for the test site
if [[ -f ${HOME}/daps_support/cfg/htaccess.test ]]
then
	cp ${HOME}/daps_support/cfg/htaccess.test ${DOCROOT}/.htaccess
fi

# reset permissions on default directory
chmod 0555 ${DOCROOT}/sites/default
if [[ $? -ne 0 ]];then
    echo "ERROR unable to reset permissions on ${DOCROOT}/sites/default"
    exit 1
fi

sudo chcon -R -t httpd_sys_content_t /home/daps/public_html
if [[ $? -ne 0 ]];then
    echo "ERROR unable to reset http context on ${DOCROOT}"
    exit 1
fi
sudo semanage fcontext -a -t httpd_sys_rw_content_t /home/daps/public_html/sites/default/files/civicrm/templates_c/en_US
if [[ $? -ne 0 ]];then
    echo "ERROR unable to set http rw context on ${DOCROOT}/sites/default/files/civicrm/templates_c/en_US"
    exit 1
fi
sudo restorecon -v /home/daps/public_html/sites/default/files/civicrm/templates_c/en_US
if [[ $? -ne 0 ]];then
    echo "ERROR unable to restore context on ${DOCROOT}/sites/default/files/civicrm/templates_c/en_US"
    exit 1
fi


if [[ -d ${TGTDIR} ]];then
    rm -rf ${TGTDIR}
    if [[ $? -ne 0 ]];then
        echo "ERROR removing ${TGTDIR}"
        exit 1
    fi
fi

echo $0 finished at $(date)
exit 0

