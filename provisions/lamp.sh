#! /usr/bin/env bash
################################
#
# Install LAMP stack
#
################################

apt update
apt upgrade -y

# Get repos for php and apache
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
apt update

# Get essential packages
apt-get install -y build-essential dkms linux-headers-$(uname -r) software-properties-common virtualbox-guest-x11 virtualbox-guest-dkms virtualbox-guest-utils

# Install essentials
apt-get install -y apache2 mariadb-server git curl redis

# Enable mods
a2enmod rewrite
systemctl restart apache2

# Get PHP packages
apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap php7.4-xmlwriter

# Get & install fast CGI apache module
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

# Enable fast CGI mods
a2enmod actions fastcgi proxy_fcgi

# Enable fast CGI conf
a2enconf php7.3-fpm

systemctl restart php7.3-fpm
systemctl restart apache2

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp