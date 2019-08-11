#!/bin/bash
# this script will be used to restore a site that.

export DRUSH_PHP=/opt/cpanel/ea-php56/root/usr/bin/php
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH

echo $0 started at $(date)

# source the site specific settings
. /home/daps/daps_support/cfg/site.cfg
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

# go to docroot
cd ${DOCROOT}
if [[ $? -ne 0 ]]
then
   echo "ERROR Unable to access ${DOCROOT}"
   exit 1
fi

drush vset maintenance_mode 0
if [[ $? -ne 0 ]]
then
   echo "ERROR taking site out of maintenance mode"
   exit 1
fi
echo $0 finished at $(date)
exit 0
