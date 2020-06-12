#!/bin/bash
################################
#
# Install PHP 5.6
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
apt-get install -y php5.6 libapache2-mod-php5.6 php5.6-common php5.6-zip php5.6-mysql php5.6-imagick php5.6-mbstring php5.6-dom php5.6-curl php5.6-xml php5.6-redis php5.6-fpm php5.6-gd php5.6-intl php5.6-opcache php5.6-soap php7.4-xmlwriter

echo "<::: Enabling FPM :::>" >&3
a2enconf php5.6-fpm
systemctl restart php5.6-fpm
systemctl restart apache2

echo "<::: Enabling error reporting :::>" >&3
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/apache2/php.ini
service apache2 restart

echo "<::: Configuring FPM & PHP :::>" >&3
sed -i "s/max_execution_time = .*/max_execution_time = 6000/" /etc/php/5.6/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 2G/" /etc/php/5.6/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 2G/" /etc/php/5.6/fpm/php.ini
sed -i "s/max_input_vars = .*/max_input_vars = 5000/" /etc/php/5.6/fpm/php.ini

sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/5.6/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/5.6/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=50000/" /etc/php/5.6/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/5.6/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/5.6/fpm/php.ini

sed -i "s/pm = .*/pm = static/" /etc/php/5.6/fpm/pool.d/www.conf
sed -i "s/pm.max_children = .*/pm.max_children = 10/" /etc/php/5.6/fpm/pool.d/www.conf

service php5.6-fpm restart

echo "------ PHP5.6 install finished ------" >&3
