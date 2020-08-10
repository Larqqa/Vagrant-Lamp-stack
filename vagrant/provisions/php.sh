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

echo "------ Installing PHP${PHPV} ------" >&3

echo "<::: Installing PHP & modules :::>" >&3
apt-get install -y php${PHPV} libapache2-mod-php${PHPV} php${PHPV}-common php${PHPV}-zip php${PHPV}-mysql php${PHPV}-imagick php${PHPV}-mbstring php${PHPV}-dom php${PHPV}-curl php${PHPV}-xml php${PHPV}-redis php${PHPV}-fpm php${PHPV}-gd php${PHPV}-intl php${PHPV}-opcache php${PHPV}-soap php${PHPV}-xmlwriter

echo "<::: Add FPM to server :::>" >&3

# If apache, add fpm conf and restart
if  test $SERVER = "apache"; then
  # Add new fpm version to apache configs
  sed -i "s@SetHandler \"proxy:unix:/var/run/php/php.*@SetHandler \"proxy:unix:/var/run/php/php${PHPV}-fpm.sock|fcgi://localhost/\"@" /etc/apache2/sites-available/wordpress-ssl.conf
  sed -i "s@SetHandler \"proxy:unix:/var/run/php/php.*@SetHandler \"proxy:unix:/var/run/php/php${PHPV}-fpm.sock|fcgi://localhost/\"@" /etc/apache2/sites-available/wordpress.conf

  # Enable config
  a2enconf php${PHPV}-fpm
  systemctl restart apache2
else
  # else we assume it's an nginx server, and replace the fpm directive in nginx
  sed -i "s@fastcgi_pass unix:/var/run/php/php.*@fastcgi_pass unix:/var/run/php/php${PHPV}-fpm.sock;@" /etc/nginx/sites-available/wordpress.com
  systemctl restart nginx
fi

echo "<::: Configuring FPM & PHP :::>" >&3
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/max_execution_time = .*/max_execution_time = 6000/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 5G/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 5G/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/max_input_vars = .*/max_input_vars = 5000/" /etc/php/${PHPV}/fpm/php.ini

sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=50000/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=0/" /etc/php/${PHPV}/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/${PHPV}/fpm/php.ini

sed -i "s/pm = .*/pm = static/" /etc/php/${PHPV}/fpm/pool.d/www.conf
sed -i "s/pm.max_children = .*/pm.max_children = 10/" /etc/php/${PHPV}/fpm/pool.d/www.conf

systemctl restart php${PHPV}-fpm

echo "------ PHP${PHPV} install finished ------" >&3
