#!/bin/bash 
debug="set -x"
$debug
timestamp=$(date +"%Y%m%d%H%M%S")
backuplog=/home/daps/daps_support/logs/site-backup.$timestamp.cron.log

copyToBackup()
{
    $debug
    sourcefile=$1
    if [[ ! -e $sourcefile ]]
    then
        echo "ERROR looking for $myline"
        exit 1
    fi
    targetfile=/home/daps/daps_support/cfg/drupal
    cp --preserve --parents $sourcefile $targetfile
    if [[ $? -ne 0 ]]
    then
        echo "ERROR copying $sourcefile to $targetfile"
        exit 1
    fi
    defaultdir=/home/daps/daps_support/cfg/drupal/home/daps/public_html/sites/default
    if [[ -e $defaultdir && ! -w $defaultdir ]]
    then
        chmod u+w /home/daps/daps_support/cfg/drupal/home/daps/public_html/sites/default
        if [[ $? -ne 0 ]]
        then
            echo "ERROR allowing writes on /home/daps/daps_support/cfg/drupal/home/daps/public_html/sites/default"
            exit 1
        fi
    fi
}

rm -rf /home/daps/daps_support/cfg/drupal/home
if [[ $? -ne 0 ]]
then
    echo "ERROR removing previous version"
fi

#/home/daps/daps_support/bin/dapsscript.sh site-backup.sh >> $backuplog 2>&1

find /home/daps/public_html -name .htaccess > /home/daps/daps_support/cfg/site.config.files.txt
if [[ $? -ne 0 ]]
then
    echo "ERROR fetching .htaccess file list"
    exit 1
fi

find /home/daps/public_html -name robots.txt >> /home/daps/daps_support/cfg/site.config.files.txt
if [[ $? -ne 0 ]]
then
    echo "ERROR fetching robots.txt file list"
    exit 1
fi

find /home/daps/public_html -name settings.php >> /home/daps/daps_support/cfg/site.config.files.txt
if [[ $? -ne 0 ]]
then
    echo "ERROR fetching settings.php file list"
    exit 1
fi

find /home/daps/public_html -name civicrm.settings.php >> /home/daps/daps_support/cfg/site.config.files.txt
if [[ $? -ne 0 ]]
then
    echo "ERROR fetching civicrm.settings.php file list"
    exit 1
fi

while read line
do
   echo processing $line
   copyToBackup $line
done</home/daps/daps_support/cfg/site.config.files.txt

