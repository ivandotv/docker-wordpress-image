#!/bin/bash

set -euo pipefail

#if first parameter passed to entry point is "wp" run wp cli directly and exit
if [[ $1 == "wp" ]]; then
    cd /var/www/html
    shift
    wp "$@"
    exit
fi

# load helper functions
source /usr/local/bin/helpers.sh
# default user id for wordpress files
export USER_ID=${USER_ID:-1000}

custom_config_dir=$WORDPRESS_CONFIG_DIR
php_info_file="/var/www/html/info.php"



if [[ -d "$custom_config_dir" ]];then

    chown ${USER_ID}:www-data -R "$custom_config_dir"

fi


#add custom php config file if present.
if [[ -f "${custom_config_dir}/custom.ini" ]]; then
    # prefix the file with "zzzz" so it get's loaded last
    cp  "${custom_config_dir}/custom.ini"    /usr/local/etc/php/conf.d/zzzz-custom.ini

fi

#add custom PHP FPM config file if present.
if [[ -f "${custom_config_dir}/custom.conf" ]]; then

    # prefix the file with "zzzz" so it get's loaded last
    cp  "${custom_config_dir}/custom.conf"   /usr/local/etc/php-fpm.d/zzzz-custom.conf

fi

# call upstream entrypoint ( wordpress setup )
# mute CMD from official wordpress image
sed -i -e 's/^exec "$@"/#exec "$@"/g' /usr/local/bin/docker-entrypoint.sh
docker-entrypoint.sh "$@"




# default wordpress installation parameters
WP_CLI_URL="${WP_CLI_URL:-http://localhost}"
WP_CLI_TITLE="${WP_CLI_TITLE:-Example}"
WP_CLI_ADMIN_USER="${WP_CLI_ADMIN_USER:-admin}"
WP_CLI_ADMIN_PASSWORD="${WP_CLI_ADMIN_PASSWORD:-admin}"
WP_CLI_ADMIN_EMAIL="${WP_CLI_ADMIN_EMAIL:-admin@example.com}"
WP_CLI_ADMIN_SKIP_EMAIL="${WP_CLI_ADMIN_SKIP_EMAIL:-true}"

# default configuration for creating config.php file
WP_CLI_DB_NAME="${WP_CLI_DB_NAME:-wordpress}"
WP_CLI_DB_USER="${WP_CLI_DB_USER:-admin}"
WP_CLI_DB_PASS="${WP_CLI_DB_PASS:-admin}"
WP_CLI_DB_HOST="${WP_CLI_DB_HOST:-localhost}"
WP_CLI_DB_PREFIX="${WP_CLI_DB_PREFIX:-wp_}"
WP_CLI_DB_CHARSET="${WP_CLI_DB_CHARSET:-ut8}"
WP_CLI_DB_SKIP_CHECK="${WP_CLI_DB_SKIP_CHECK:-true}"


# check if wp is NOT installed
if ! $(wp core is-installed); then

    skip_db_check=''
    if [[ $WP_CLI_DB_SKIP_CHECK == true ]];then
        echo  'skipping database check '
        skip_db_check='--skip-check'
    fi

    # create configuration file
    echo 'creating configuration file'
    wp config create \
    --dbname="${WP_CLI_DB_NAME}" \
    --dbuser="${WP_CLI_DB_USER}" \
    --dbpass="${WP_CLI_DB_PASS}" \
    --dbhost="${WP_CLI_DB_HOST}" \
    --dbprefix="${WP_CLI_DB_PREFIX}" \
    --dbcharset="${WP_CLI_DB_CHARSET}" \
    "${skip_db_check}"

    # run custom script before installation
    if [[ -f ${custom_config_dir}/before-install.sh ]]; then

        echo "running before-install.sh script"
        chmod +x ${custom_config_dir}/before-install.sh
        ${custom_config_dir}/before-install.sh
    fi

    skip_admin_email=''
    if [[ $WP_CLI_DB_SKIP_CHECK == true ]];then
        echo  'skipping sending email to admin '
        skip_admin_email='--skip-email'
    fi

    # Install WP (we need db connection for this)
    echo "installing wordPress"
    wp core install \
    --url="${WP_CLI_URL}" \
    --title="${WP_CLI_TITLE}" \
    --admin_user="${WP_CLI_ADMIN_USER}" \
    --admin_password="${WP_CLI_ADMIN_PASSWORD}" \
    --admin_email="${WP_CLI_ADMIN_EMAIL}" \
    "${skip_admin_email}"

    # run custom script after the installation
    if [[ -f ${custom_config_dir}/after-install.sh ]]; then

        echo "running after-install.sh" script
        chmod +x ${custom_config_dir}/after-install.sh
        ${custom_config_dir}/after-install.sh
    fi

fi

# check if Wordpress is installed properly
if ! $(wp core is-installed); then
    echo "Error installing WordPress"
    exit 1
fi


#Wordpress files are available after this point
# sometimes wp-config has root ownership
chown :www-data /var/www/html/wp-config.php

# force direct file access method, since we are running in the container.
wp config set FS_METHOD direct --type=constant

# development environment
if [[ "$WP_ENV" == "development"  ]]; then

    wp config set WP_DEBUG true --raw --type=constant
    wp config set WP_DEBUG_LOG true --raw --type=constant

    # add php configuration info at the root of the site.
    add_php_info $php_info_file

else
    #consider it a  production environment
    wp config set WP_DEBUG false --raw --type=constant
    wp config set WP_DEBUG_LOG false --raw --type=constant

    # remove php configuration file
    remove_file $php_info_file

fi


#runs every time the container is STARTED
if [[ -f ${custom_config_dir}/start.sh ]]; then

    echo "runnin start.sh script"
    chmod +x ${custom_config_dir}/start.sh
    ${custom_config_dir}/start.sh
fi


# change ownership on the files
change_ownership $USER_ID
# change permissions
change_permissions;

exec "$@"
