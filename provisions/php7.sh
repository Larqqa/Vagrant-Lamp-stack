#!/bin/bash
################################
#
# Install PHP 7.x
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/php.log 2>&1
set -ex

echo "------ Installing PHP7.x ------" >&3

echo "<::: Getting PHP repo :::>" >&3
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

echo "<::: Installing PHP & modules :::>" >&3
apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap php7.4-xmlwriter

echo "<::: Enabling FPM :::>" >&3
a2enconf php7.3-fpm
systemctl restart php7.3-fpm
systemctl restart apache2

echo "<::: Enabling error reporting :::>" >&3
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/apache2/php.ini
service apache2 restart

echo "<::: Configuring FPM & PHP :::>" >&3
sed -i "s/max_execution_time = .*/max_execution_time = 6000/" /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 2G/" /etc/php/7.3/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 2G/" /etc/php/7.3/fpm/php.ini
sed -i "s/max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.3/fpm/php.ini

sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=50000/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/7.3/fpm/php.ini

sed -i "s/pm = .*/pm = static/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/pm.max_children = .*/pm.max_children = 10/" /etc/php/7.3/fpm/pool.d/www.conf

service php7.3-fpm restart

echo "------ PHP7.x install finished ------" >&3
