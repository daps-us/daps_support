#!/bin/bash
# this script will be used to fetch current backup of the website.
# this machine is in the central timezone, the daps server
# is on the pacific timezone. Do not run before 2 AM central time.
# Just to be safe, run at 3 AM central time
echo $0 started at $(date)

# source the site specific settings
echo 'INFO: Fetching configuration information...'
. ~/daps_support/cfg/site.cfg
if [[ $? -ne 0 ]];then
   echo 'ERROR attempting to fetch site settings.'
   exit 1
fi

#sanity checks
if [[ -z ${BKUPROOT} ]];then
   echo 'ERROR BKUPROOT is not defined.'
   exit 1
fi
if [[ ! -d ${BKUPROOT} ]];then
   echo 'ERROR ${BKUPROOT} is not a directory'
   exit 1
fi

# figure out what the timestamp will look like
if [[ -z $1 ]]; then
   timestamp=`date +"%Y%m%d"`
   if [[ $? -ne 0 ]];then
      echo "ERROR determining timestamp in $0"
      exit 1
   fi
else
   timestamp=$1
fi
echo "timestamp=$timestamp"

# fetch site directory
echo "INFO fetching backup $timestamp from website"
scp -r daps.us:${BKUPROOT}/$timestamp*/*.tar.gz ${BKUPROOT}/site
if [ $? -ne 0 ];then
    echo "ERROR fetching $timestamp from website"
    exit 1
fi
echo $0 finished at `date`
# quit and report
exit 0
