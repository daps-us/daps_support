#!/bin/sh -x
# simple script to drop databases
export PATH=/opt/cpanel/ea-php56/root/usr/bin:$PATH
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
