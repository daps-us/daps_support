#!/bin/bash

. ${HOME}/init/site.cfg

if [[ -z $DRNAME ]]
then
	echo "DRNAME not set"
	exit 1
fi

if [[ -z $DRUSER ]]
then
	echo "DRUSER not set"
	exit 1
fi

if [[ -z $DRHOST ]]
then
	echo "DRHOST not set"
	exit 1
fi

if [[ -z $CVNAME ]]
then
	echo "CVNAME not set"
	exit 1
fi

if [[ -z $CVUSER ]]
then
	echo "CVUSER not set"
	exit 1
fi

if [[ -z $CVHOST ]]
then
	echo "CVHOST not set"
	exit 1
fi

echo "DROP DATABASE IF EXISTS ${DRNAME};" | sudo mysql
echo "DROP DATABASE IF EXISTS ${CVNAME};" | sudo mysql
echo "DROP USER IF EXISTS '${DRUSER}'@'${DRHOST}';" | sudo mysql
echo "DROP USER IF EXISTS '${CVUSER}'@'${CVHOST}';" | sudo mysql

exit 0
