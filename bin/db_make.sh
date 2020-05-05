#!/bin/bash


# source the config values
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

if [[ -z $DRPASS ]]
then
	echo "DRPASS not set"
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

if [[ -z $CVPASS ]]
then
	echo "CVPASS not set"
	exit 1
fi

if [[ -z $CVHOST ]]
then
	echo "CVHOST not set"
	exit 1
fi

echo "==============================================================="
echo "Before create..."
echo "---------------------------------------------------------------"
echo "SHOW DATABASES;" | sudo mysql
echo "---------------------------------------------------------------"
echo "SHOW GRANTS FOR '${DRUSER}'@'${DRHOST}';" | sudo mysql
echo "---------------------------------------------------------------"
echo "SHOW GRANTS FOR '${CVUSER}'@'${CVHOST}';" | sudo mysql
echo "==============================================================="
echo "Create..."
echo "---------------------------------------------------------------"
echo "CREATE DATABASE IF NOT EXISTS ${DRNAME};" | sudo mysql
echo "CREATE DATABASE IF NOT EXISTS ${CVNAME};" | sudo mysql
echo "CREATE USER IF NOT EXISTS '${DRUSER}'@'${DRHOST}' IDENTIFIED BY '${DRPASS}';" | sudo mysql
echo "CREATE USER IF NOT EXISTS '${CVUSER}'@'${CVHOST}' IDENTIFIED BY '${CVPASS}';" | sudo mysql
echo "GRANT SELECT, INSERT, UPDATE, DELETE, DROP, CREATE, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES, TRIGGER ON \`${CVNAME}\`.* TO '${CVUSER}'@'${CVHOST}';" | sudo mysql 
echo "GRANT SUPER ON *.* TO '${CVUSER}'@'${CVHOST}';" | sudo mysql
echo "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON \`${DRNAME}\`.* TO '${DRUSER}'@'${DRHOST}';" | sudo mysql
echo "GRANT SELECT ON \`${CVNAME}\`.* TO '${DRNAME}'@'${CVHOST}';" | sudo mysql
echo "FLUSH PRIVILEGES;" | sudo mysql
echo "==============================================================="
echo "After create..."
echo "---------------------------------------------------------------"
echo "SHOW DATABASES;" | sudo mysql
echo "---------------------------------------------------------------"
echo "SHOW GRANTS FOR '${DRUSER}'@'${DRHOST}';" | sudo mysql
echo "---------------------------------------------------------------"
echo "SHOW GRANTS FOR '${CVUSER}'@'${CVHOST}';" | sudo mysql
exit 0
