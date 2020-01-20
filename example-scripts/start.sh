#!/bin/bash

echo 'Running on EVERY container start (crated/restarted)'

# set wp config variables if present in the environment
if [[ -n $WP_SITEURL ]];then

    wp config set WP_SITEURL "$WP_SITEURL" --type=constant
fi

if [[ -n $WP_HOME ]];then

    wp config set WP_HOME "$WP_HOME" --type=constant
fi

if [[ -n $DOMAIN_CURRENT_SITE ]];then

    wp config set DOMAIN_CURRENT_SITE "$DOMAIN_CURRENT_SITE" --type=constant
fi


if [[ -n $PATH_CURRENT_SITE ]];then

    wp config set PATH_CURRENT_SITE "$PATH_CURRENT_SITE" --type=constant
fi

if [[ -n $SITE_ID_CURRENT_SITE ]];then

    wp config set SITE_ID_CURRENT_SITE "$SITE_ID_CURRENT_SITE" --type=constant --raw
fi


if [[ -n $BLOG_ID_CURRENT_SITE ]];then

    wp config set BLOG_ID_CURRENT_SITE "$BLOG_ID_CURRENT_SITE" --type=constant --raw
fi

if [[ -n $DISABLE_WP_CRON ]];then

    wp config set DISABLE_WP_CRON "$DISABLE_WP_CRON" --type=constant --raw
fi

if [[ -n $WP_ADD_PHP_INFO ]];then

    # add php configuration info at the root of the site.
    add_php_info $php_info_file

fi
