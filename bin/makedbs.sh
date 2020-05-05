#!/bin/bash -x

makedb() {
   set -x
   newUser=$1
   newDbPassword=$2
   newDb=$3
   host=$4

   commands="CREATE DATABASE \`${newDb}\`;CREATE USER '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';GRANT USAGE ON *.* TO '${newUser}'@'${host}' IDENTIFIED BY '${newDbPassword}';GRANT ALL privileges ON \`${newDb}\`.* TO '${newUser}'@'${host}';FLUSH PRIVILEGES;"

   echo "${commands}" | sudo /usr/bin/mysql -u root -p
}

# source the config values
. /home/daps/cfg/site.cfg

makedb $DRUSER $DRPASS $DRNAME $DRHOST
makedb $CVUSER $CVPASS $CVNAME $CVHOST
