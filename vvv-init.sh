#!/bin/bash

PHPREDMIN_DIR="phpredmin"
PHPREDMIN_PATH="$(pwd)/$PHPREDMIN_DIR/public"
PHPREDMIN_CONF="/etc/supervisor/conf.d/phpredmin.conf"

echo " * Setting up Redis..."
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/pkg-gearman
sudo apt-get update
sudo apt-get -y install language-pack-en-base redis-server php-redis gearman-server php-gearman supervisor
sudo service php7.1-fpm restart

if [ ! -d "$PHPREDMIN_DIR" ]; then
    echo " * Cloning PHPRedMin..."
    git clone https://github.com/sasanrose/phpredmin.git "$PHPREDMIN_DIR"
else
    echo " * Updating PHPRedMin..."
    cd "$PHPREDMIN_DIR"
    git pull origin master
fi

if [ ! -f "$PHPREDMIN_CONF" ]; then
    sudo cat >"$PHPREDMIN_CONF" <<CONF
[program:phpredmin]
directory=$PHPREDMIN_PATH
command=php index.php gearman/index
process_name=%(program_name)s
numprocs=1
stdout_logfile=/var/log/supervisor/phpredmin.log
autostart=true
autorestart=true
user=vagrant
CONF

    sudo service supervisor force-reload
fi