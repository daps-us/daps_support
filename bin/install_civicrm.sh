#!/bin/bash
# description: script to install civicrm and drupal on a server using
# the roundearth project

function install_composer {
    cd ${HOME}/init
    EXPECTED_CHECKSUM="$(wget -q -O - https://composer.github.io/installer.sig)"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
    then
        >&2 echo 'ERROR: Invalid installer checksum'
        exit 1
    fi
    sudo php composer-setup.php --quiet --install-dir=/usr/local/bin --filename=composer;rc=$?
    if [[ $rc -ne 0 ]]
    then
        echo "ERROR installing composer"
        exit $rc
    sudo chown -R ${iam}:${iam} ${HOME}/.composer;rc=$?
    fi
    if [[ $rc -ne 0 ]]
    then
        echo "ERROR setting owner on ${HOME}/.composer"
        exit $rc
    fi
    rm ${HOME}/init/composer-setup.php;rc=$?
    if [[ $rc -ne 0 ]]
    then
        echo "ERROR removing ${HOME}/init/composer-setup.php"
        exit $rc
    fi
    echo "composer-setup rc=$rc"
    return
}

function create_dir {
    newpath="$1"
    if [[ -z ${newpath} ]]
    then
        return
    fi
    if [[ ! -d ${newpath} ]]
    then
        echo "Creating ${newpath}..."
        sudo mkdir -p ${newpath};rc=$?
        if [[ $rc -ne 0 ]]
        then
            echo "ERROR creating ${newpath}"
            exit 1
        fi
        sudo chown ${iam}:${iam} ${newpath};rc=$?
        if [[ $rc -ne 0 ]]
        then
            echo "ERROR setting owner for ${newpath}"
            exit 1
        fi
        sudo chmod 0775 ${newpath};rc=$?
        if [[ $rc -ne 0 ]]
        then
            echo "ERROR setting permissions on ${newpath}"
            exit 1
        fi
    fi
    return
}

source ${HOME}/init/web_site.cfg

iam=$(whoami)
echo running $(basename $0) as ${iam}...

cd ${HOME};rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR getting to ${HOME}"
    exit $rc
fi
echo PWD="$PWD"

create_dir /opt/www/html

echo "Installing Composer..."
install_composer

echo "Fixing ${iam}..."
sudo chown -R ${iam}:${iam} ${HOME};rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR fixing ${HOME}"
    exit 1
fi

echo "Setting GitHubToken..."
composer config -g github-oauth.github.com ${GITHUBTOKEN};rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR setting GitHubToken"
    exit $rc
fi

echo "Installing civi..."
composer create-project roundearth/drupal-civicrm-project:8.x-dev /opt/www/html --no-interaction;rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR installing civi"
    exit $rc
fi

echo "Removing auth.json..."
rm ${HOME}/.composer/auth.json;rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR removing auth.json"
    exit $rc
fi

create_dir /opt/www/html/config/sync
create_dir /opt/www/html/web/sites/default/files

if [[ ! -f /opt/www/html/web/sites/default/default.settings.php ]]
then
    echo "ERROR default.settings.php not found"
    exit 1
fi

if [[ ! -f /opt/www/html/web/sites/default/settings.php ]]
then
    echo "Creating settings.php..."
    sudo cp /opt/www/html/web/sites/default/default.settings.php /opt/www/html/web/sites/default/settings.php;rc=$?
    if [[ $rc -ne 0 ]]
    then
        exit $rc
        echo "ERROR creating /opt/www/html/web/sites/default/settings.php"
    fi

    sudo chmod 0664 /opt/www/html/web/sites/default/settings.php;rc=$?
    if [[ $rc -ne 0 ]]
    then
        echo "ERROR setting permissions on /opt/www/html/sites/default/settings.php"
        exit $rc
    fi
fi

sudo chgrp -R www-data /opt/www/html;rc=$?
if [[ $rc -ne 0 ]]
then
    echo "ERROR setting owner for /opt/www/html"
    exit $rc
fi

exit 0