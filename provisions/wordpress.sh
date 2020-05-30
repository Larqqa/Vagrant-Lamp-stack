#! /usr/bin/env bash
################################
#
# Install Wordpress
#
################################

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

# Add this to wp-config to add a dynamic machine ip as wordpress site URL
sed -i "/\/\*\* Sets up WordPress vars and included files. \*\//i\\
/* BE DYNAMIC, BE, BE DYNAMIC! */ \
\
// Get server ip address and folder path \
\$currenthost = 'http://'.\$_SERVER['SERVER_ADDR']; \
\$currentpath = preg_replace('@/+\$@','',dirname(\$_SERVER['SCRIPT_NAME'])); \
\$currentpath = preg_replace('/\\/wp.+/','',\$currentpath); \
\$siteurl = \$currenthost.\$currentpath; \
\
// Define them to be used on wordpress \
define('WP_HOME',\$siteurl); \
define('WP_SITEURL',\$siteurl); \
define('WP_CONTENT_URL',\$siteurl.'/wp-content'); \
define('WP_PLUGIN_URL',\$siteurl.'/wp-content/plugins'); \
define('DOMAIN_CURRENT_SITE',\$siteurl); \
@define('ADMIN_COOKIE_PATH', './'); \
\
/* END BE DYNAMIC */ \
\
" wp-config.php

echo -e "<::::: WORDPRESS INSTALLED SUCCESFULLY :::::>"