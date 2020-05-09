#!/bin/bash
# description: this script is used to pull the source from github
# and do the build of the site

function wget_resource {

    target="$1"
    source="$2"
    owner="$3"
    group="$4"
    perms="$5"

    if [[ -z $source ]]; then
        echo "ERROR source not set"
        exit 1
    fi
    if [[ -z $target ]]; then
        echo "ERROR target not set"
        exit 1
    fi

    echo "Getting ${target} from ${source}..."

    if [[ -z $owner ]]; then
        echo "ERROR owner not set"
        exit 1
    fi
    if [[ -z $group ]]; then
        echo "ERROR group not set"
        exit 1
    fi
    if [[ -z $perms ]]; then
        echo "ERROR perms not set"
        exit 1
    fi

    curl \
        -H "Authorization: token ${GITHUBTOKEN}" \
        -H 'Accept: application/vnd.github.v4.raw' \
        -o ${HOME}/init/${target} \
        -L https://api.github.com/repos/${source}
    rc=$?
    if [[ ${rc} -ne 0 ]]; then
        echo "ERROR fetching ${source}"
        exit 1
    fi
    sudo chown ${owner}:${group} ${HOME}/init/${target}
    rc=$?
    if [[ ${rc} -ne 0 ]]; then
        echo "ERROR unable to set owner:group on ${HOME}/init/${target}"
        exit 1
    fi
    sudo chmod ${perms} ${HOME}/init/${target}
    rc=$?
    if [[ ${rc} -ne 0 ]]; then
        echo "ERROR unable to set permissions on ${HOME}/init/${target}"
        exit 1
    fi
    return

}

# confirm the init and config directories exist
if [[ ! -d ${HOME}/init ]]; then
    echo "ERROR ${HOME}/init does not exist"
    exit 1
fi

# downloade site configuration only if it does not exist
if [[ ! -f ${HOME}/init/web_site.cfg ]]; then
    wget_resource web_site.cfg  ${SITE_CONFIG_URL} $(whoami) $(whoami) "0600"
fi

# source site configuration
OLD_HOME=${HOME} # envvars unsets HOME so we need to put it back
source /etc/apache2/envvars
rc=$?
if [[ ${rc} -ne 0 ]]; then
    echo "ERROR sourcing /etc/apache2/envvars"
    exit 1
fi
if [[ -z $APACHE_RUN_USER ]]; then
    echo "ERROR APACHE_RUN_USER not set"
    exit 1
fi
if [[ -z $APACHE_RUN_GROUP ]]; then
    echo "ERROR APACHE_RUN_GROUP not set"
    exit 1
fi
export HOME=${OLD_HOME}

source ${HOME}/init/web_site.cfg
rc=$?
if [[ ${rc} -ne 0 ]]; then
    echo "ERROR sourcing ${HOME}/init/web_site.cfg"
    exit 1
fi

# download file system create script
wget_resource fs_make.sh https://raw.githubusercontent.com/daps-us/daps_support/master/bin/fs_make.sh ${SITEOWNER} ${SITEGROUP} "0755"

# download database create script
wget_resource db_make.sh https://raw.githubusercontent.com/daps-us/daps_support/master/bin/db_make.sh ${SITEOWNER} ${SITEGROUP} "0755"

# download apache configuration files
wget_resource apache2.conf ${APACHE_URL} root root "0644"
wget_resource 000-default.conf ${HTTP_URL} root root "0644"
wget_resource default-ssl.conf ${HTTPS_URL} root root "0644"

# download drupal settings
wget_resource settings.php ${DR_URL} ${SITEOWNER} ${APACHE_RUN_GROUP} "0664"

# download civicrm settings
wget_resource civicrm.settings.php ${CV_URL} ${SITEOWNER} ${APACHE_RUN_GROUP} "0664"

# download tls files
wget_resource dapscert.pem ${PEM_URL} root root "0644"
wget_resource dapscert.key ${KEY_URL} root ssl-cert "0640"

# download the civi install script
wget_resource install_civicrm.sh https://raw.githubusercontent.com/daps-us/daps_support/master/bin/install_civicrm.sh ${SITEOWNER} ${APACHE_RUN_GROUP} "0755"
#
