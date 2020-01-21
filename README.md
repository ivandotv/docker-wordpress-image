# WordPress images for development and production

These images are built from the official WordPress `PHP-fpm` images, with some added functionality (script hooks).

All images come bundled with:

- `git`
- `unzip`
- `wp-cli` (with bash completion)
- `sudo` (for operating wp-cli as `www-data` user)

Development images come with:

- `xdebug` installed
- `opcache` disabled

Images with tags that end with `-dev` are created for development purposes.
Images that end with `-prod` should be used in production. You should use the `base` image only for building other images (upstream).

## Usage

Mount `host_directory` to hold WordPress installation and be accessible from the outside.

`docker run -v host_directory:/var/www/html ivandotv/wordpress`

Mount only your theme

`docker run -v your-theme:/var/www/html/wp-content/themes/your-theme ivandotv/wordpress`

Run [wp cli info](https://developer.wordpress.org/cli/commands/cli/info/) command on already running container.

`docker exec -it ivandotv/WordPress wp cli info`

The default working directory inside the container is `/var/www/html` (WordPress installation) so this is where the call to `wp cli` is going to be executed.

## `WP_ENV` variable

In `-dev` version of images `WP_ENV` variable is set to `development`, this variable can be overwritten.
When container is running in `development` mode:

- `WP_DEBUG` is set to `true`
- `WP_DEBUG_LOG` is set to `true`
- `php` file is added to the root of the installation `var/www/html/phpinfo.php` with `phpinfo();` function

In `-prod` version of images `WP_ENV` is set to `production`.
When the container is running in `production`:

- `WP_DEBUG` is set to `false`
- `WP_DEBUG_LOG` is set to `false`
- `php` file is removed from the root of the installation

## WP-CLI

[`WP-CLI`](https://wp-cli.org/) is installed in all images (including bash completion) and it is set up to run as `www-data` user.

`docker exec -it ivandotv/WordPress wp cli info`

## Custom Script Hooks

All images can execute script **_before_** and **_after_** Wordpress installation, and **EVERY** time the container is **_started_**.

To run the scripts, you need to make them available to the container by mounting the directory with the scripts to the `/etc/wp-config` directory inside the container.

`docker run -it -v host_scripts_dir:/etc/wp-config ivandotv/wordpress`

So, in `host_scripts_dir` container will look for these scripts:

- `before_install.sh` the script is run **before installing** Wordpress if the installation is successful, this script will not be run again when the container is restarted.
- `after_install.sh` the script is run **after installing** Wordpress and only if the installation is successful, this script will not be run again when the container is restarted.

- `start.sh` script is run **every time** the container is started (created/restarted).

## Configuring and Installing WordPress

Original (upstream) image just copies WordPress files in the `/var/www/html` directory then `wp-cli` takes over and first, creates the configuration file (`wp-config.php`) then, installs WordPress.

### Creating wp-config.php file

`wp-config.php` file is created with [`wp config create`](https://developer.wordpress.org/cli/commands/config/create/) command, you can modify the parameter values that are used for the command via environment variables.

```bash
# default configuration for creating config.php

# db name
WP_CLI_DB_NAME="${WP_CLI_DB_NAME:-wordpress}"
# db user
WP_CLI_DB_USER="${WP_CLI_DB_USER:-admin}"
# db passowd
WP_CLI_DB_PASS="${WP_CLI_DB_PASS:-admin}"
# db host ( db container)
WP_CLI_DB_HOST="${WP_CLI_DB_HOST:-localhost}"
# db prefix
WP_CLI_DB_PREFIX="${WP_CLI_DB_PREFIX:-wp_}"
# db charset
WP_CLI_DB_CHARSET="${WP_CLI_DB_CHARSET:-ut8}"
# skip checking for the database connection if "true"
WP_CLI_DB_SKIP_CHECK="${WP_CLI_DB_SKIP_CHECK:-true}"
```

### Install Wordpress

Wordpress is installed via [wp core install](https://developer.wordpress.org/cli/commands/core/install/) command, you can modify the parameter values for the command via environment variables. **Please note that you will need a database connection** to install WordPress. Take a look at this [docker-compose](todo) file.

```bash
# default WordPress installation parameters

# address of the site
WP_CLI_URL="${WP_CLI_URL:-http://localhost}"
# title of the site
WP_CLI_TITLE="${WP_CLI_TITLE:-Example}"
# admin username
WP_CLI_ADMIN_USER="${WP_CLI_ADMIN_USER:-admin}"
# admin password
WP_CLI_ADMIN_PASSWORD="${WP_CLI_ADMIN_PASSWORD:-admin}"
#admin  email
WP_CLI_ADMIN_EMAIL="${WP_CLI_ADMIN_EMAIL:-admin@example.com}"
# skip sending email to admin if "true"
WP_CLI_ADMIN_SKIP_EMAIL="${WP_CLI_ADMIN_SKIP_EMAIL:-true}"

```

## Building the Images

You can build all images by running `build.sh` script.
Images are tagged by using the `tags.txt` file.

for example:

`tags/php7.4/fpm-base=php7.4-fpm-base`

The previous line of code will tag the image that is built from the docker file located in `tags/php7.4/fpm-base` with the tag `php7.4-fpm-base` (equals sign splits dir/tag)

If the line starts with the `!` that image/tag will also be tagged as `latest`

`!tags/php7.4/fpm-base=php7.4-fpm-base`

## Docker Compose Demo

Take a look at [this](todo) repository for the docker compose setup.

- link to docker-compose setup
