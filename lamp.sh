#!/bin/bash
################################
#
# Install LAMP stack
#
################################

# Get repos for php and apache
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2

# Get mysql 8
# sudo wget –c https://repo.mysql.com//mysql-apt-config_0.8.14-1_all.deb
# sudo dpkg -i mysql-apt-config_0.8.14-1_all.deb

sudo apt-get update

# Install guest additions and apache
sudo apt-get install -y virtualbox-guest-x11 linux-headers-$(uname -r) apache2

apt-get update
apt-get -y upgrade

# Install essentials
apt-get install -y mysql-server git curl build-essential software-properties-common redis

# Enable mods
a2enmod rewrite
systemctl restart apache2

# Get PHP packages
apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap

# Get & install fast CGI apache module
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

# Enable fast CGI mods
a2enmod actions alias fcgid fastcgi proxy_fcgi setenvif

# Enable fast CGI conf
a2enconf php7.3-fpm

systemctl restart php7.3-fpm
systemctl restart apache2

# Install WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp