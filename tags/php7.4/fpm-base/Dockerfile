FROM wordpress:php7.4-fpm

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	ca-certificates \
	dirmngr \
	wget \
	git \
	less \
	gnupg \
	unzip && \
	rm -rf /var/lib/apt/lists/*

#wordpress location
ENV WORDPRESS_DIRECTORY='/var/www/html'
#user configuration files are mounted here
ENV WORDPRESS_CONFIG_DIR='/etc/wp-config'

#"https://github.com/tianon/gosu/blob/master/INSTALL.md
ENV GOSU_VERSION 1.11
ENV GOSU_GPG_KEY B42F6819007F00F88E364FD4036A9C25BF357DD4

RUN set -eux; \
	# save list of currently installed packages for later so we can clean up
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates wget; \
	if ! command -v gpg; then \
	apt-get install -y --no-install-recommends gnupg2 dirmngr; \
	fi; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
	# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	# for flaky keyservers, consider https://github.com/tianon/pgp-happy-eyeballs, ala https://github.com/docker-library/php/pull/666
	#	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	$(gpg --no-tty --keyserver keyserver.ubuntu.com --recv-keys "$GOSU_GPG_KEY" || \
	gpg --no-tty --keyserver pgp.mit.edu:80 --recv-keys "$GOSU_GPG_KEY") \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	# clean up fetch dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	chmod +x /usr/local/bin/gosu; \
	# verify that the binary works
	gosu --version; \
	gosu nobody true



# https://make.wordpress.org/cli/2018/05/31/gpg-signature-change/
# pub   rsa2048 2018-05-31 [SC]
#       63AF 7AA1 5067 C056 16FD  DD88 A3A2 E8F2 26F0 BC06
# uid           [ unknown] WP-CLI Releases <releases@wp-cli.org>
# sub   rsa2048 2018-05-31 [E]
ENV WORDPRESS_CLI_GPG_KEY 63AF7AA15067C05616FDDD88A3A2E8F226F0BC06

ENV WORDPRESS_CLI_VERSION 2.4.0

#create directory for wp-cli configuration files etc..
RUN mkdir -p /var/www/.wp-cli && chown www-data:www-data /var/www/.wp-cli

RUN set -ex; \
	curl -o /usr/bin/wp.gpg -fSL "https://github.com/wp-cli/wp-cli/releases/download/v${WORDPRESS_CLI_VERSION}/wp-cli-${WORDPRESS_CLI_VERSION}.phar.gpg"; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	$(gpg --keyserver keyserver.ubuntu.com --recv-keys "${WORDPRESS_CLI_GPG_KEY}" || \
	gpg --keyserver pgp.mit.edu --recv-keys "${WORDPRESS_CLI_GPG_KEY}" )  \
	gpg --batch --decrypt --output /usr/bin/wp /usr/bin/wp.gpg; \
	rm -r "$GNUPGHOME" /usr/bin/wp.gpg; \
	\
	chmod +x /usr/bin/wp;

# setup bash completion for wp-cli
RUN set -ex; \
	curl  -o $HOME/wp-completion.bash "https://raw.githubusercontent.com/wp-cli/wp-cli/master/utils/wp-completion.bash" && \
	echo " . ${HOME}/wp-completion.bash" >> $HOME/.bashrc

# wrapper script for wp-cli so it could be executed as www-data user
RUN set -ex;\
	echo '#!/bin/bash\ngosu www-data /usr/bin/wp "$@"' > /usr/local/bin/wp; \
	chmod +x /usr/local/bin/wp; \
	wp --version

# setup base php configuration prefix with "zz" so it loads last
COPY ./custom.ini /usr/local/etc/php/conf.d/zz-custom.ini

# setup base PHP-FPM configuration prefix with "zz" so it loads last
COPY ./custom.conf /usr/local/etc/php-fpm.d/zz-custom.conf


COPY ./custom.ini  /usr/local/etc/php/conf.d/zzz-custom.ini
COPY ./custom.conf /usr/local/etc/php-fpm.d/zzz-custom.conf


# helper functions for working with wp config
COPY ./helpers.sh /usr/local/bin/helpers.sh

# script to start pre/post setup scripts
COPY ./init.sh /usr/local/bin/

ENTRYPOINT ["init.sh"]

CMD ["php-fpm"]
