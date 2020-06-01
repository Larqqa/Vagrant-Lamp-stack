#!/bin/bash
################################
#
# Install Apache
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/apache.log 2>&1
set -ex

echo "------ Installing Apache ------" >&3

echo "<::: Get Apache repo :::>" >&3
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
apt update

echo "<::: Install and enable Apache :::>" >&3
apt-get install -y apache2 redis
a2enmod rewrite
systemctl restart apache2

echo "<::: Adding Fast CGI :::>" >&3
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

a2enmod actions fastcgi proxy_fcgi
systemctl restart apache2

echo "<::: Doing Apache configs :::>" >&3
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo "<::: Configuring Redis :::>" >&3
echo "maxmemory 1000mb" >>/etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >>/etc/redis/redis.conf

sed -i "s/save 900 1/#save 900 1/" /etc/redis/redis.conf
sed -i "s/save 300 10/#save 300 10/" /etc/redis/redis.conf
sed -i "s/save 60 10000/#save 60 10000/" /etc/redis/redis.conf

service redis-server restart

echo "<::: Adding Virtual Host :::>" >&3
sed -i "s/DirectoryIndex .*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf
systemctl restart apache2

touch /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf << EOL
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ServerName wordpress-dev
  ServerAlias www.wordpress-dev
  DocumentRoot /var/www/
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined

  <Directory /var/www/>
    AllowOverride All
  </Directory>

  <FilesMatch ".php$">
    SetHandler "proxy:unix:/var/run/php/php7.3-fpm.sock|fcgi://localhost/"
  </FilesMatch>
</VirtualHost>
EOL

a2ensite wordpress.conf
a2dissite 000-default.conf
systemctl restart apache2

# Add the www folder as default path to speed up SSH login
echo "cd /var/www" >> /home/vagrant/.bashrc

echo "<::: Setting permissions to www folder :::>" >&3
sudo chown -R www-data:www-data /var/www
usermod -aG www-data $USER
chmod -R g+wrx /var/www

echo "<::: Add info.php page :::>" >&3
cat <<EOF >/var/www/info.php
<?php
phpinfo();
?>
EOF

echo "------ Apache install finished ------" >&3