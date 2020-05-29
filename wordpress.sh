#! /usr/bin/env bash

echo -e "<::::: INSTALLING WORDPRESS :::::>"

mkdir /var/www/wordpress
cd /var/www/wordpress
wp core download

wp core config --dbuser=wp_admin --dbpass=password --dbname=wordpress
wp core install --url=http://localhost/wordpress --title=Blog --admin_user=admin--admin_password=admin --admin_email=admin@admin.admin  --skip-email
wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'
wp site empty --uploads --yes
wp plugin delete --all
wp theme delete --all;

echo -e "<::::: WORDPRESS INSTALLED SUCCESFULLY :::::>"