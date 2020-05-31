#!/bin/bash
################################
#
# Install LAMP stack
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/lamp.log 2>&1
set -ex

echo "<::: Starting installation :::>" >&3
echo "<::: For build logs, check ./data/vm_build.log :::>" >&3

echo "<::: Insalling the LAMP stack :::>" >&3

echo "<::: Insalling updates :::>" >&3
apt update
apt upgrade -y

echo "<::: Getting Apache and PHP repos :::>" >&3
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
apt update

echo "<::: Insalling Essential Packages :::>" >&3
apt-get install -y build-essential dkms linux-headers-$(uname -r) software-properties-common

echo "<::: Insalling server stuff :::>" >&3
apt-get install -y apache2 mariadb-server git curl redis

# Enable mods
a2enmod rewrite
systemctl restart apache2

echo "<::: Insalling PHP & modules :::>" >&3
apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap php7.4-xmlwriter

echo "<::: Adding Fast CGI :::>" >&3
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

# Enable fast CGI mods
a2enmod actions fastcgi proxy_fcgi

# Enable fast CGI conf
a2enconf php7.3-fpm

systemctl restart php7.3-fpm
systemctl restart apache2

echo "<::: Insalling WP Cli :::>" >&3
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

echo "<::: LAMP stack installed! :::>" >&3