#!/bin/bash
# this script will be used to fetch current logs from the website.
# it is built to run once a month and fetch this months log
# this machine is in the central timezone, the daps server
# is on the pacific timezone. Do not run before 2 AM central time.
# Just to be safe, run at 3 AM central time

echo $0 starting at $(date)
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH

# figure out what month this is
month=$(date +"%b")
if [ $? -ne 0 ];then
    echo "ERROR determining this month in $0"
    exit 1
fi
echo "month=$month"

# figure out what this year is
year=$(date +"%Y")
if [ $? -ne 0 ];then
    echo "ERROR determining this year in $0"
    exit 1
fi
echo "year=$year"

# build the filename for the non-ssl logfile
# daps.us-Oct-2014.gz
nonsslfile="daps.us-${month}-${year}.gz"
echo "nonsslfile=$nonsslfile"

# build the filename for the ssl logfile
# daps.us-ssl_log-Oct-2014.gz
sslfile="daps.us-ssl_log-${month}-${year}.gz"
echo "sslfile=$sslfile"

# fetch non-ssl file
scp daps.us:/home/daps/logs/$nonsslfile /home/daps/daps_support/websitebackups/logs
if [ $? -ne 0 ];then
    echo "ERROR fetching $nonsslfile from website"
    exit 1
fi

# fetch ssl file
scp daps.us:/home/daps/logs/$sslfile /home/daps/daps_support/websitebackups/logs
if [ $? -ne 0 ];then
    echo "ERROR fetching $sslfile from website"
    exit 1
fi

# quit and report
echo $0 finished at $(date)
exit 0
