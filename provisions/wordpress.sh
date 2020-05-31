#!/bin/bash
################################
#
# Install Wordpress
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/wordpress.log 2>&1
set -ex

echo "<::: Installing Wordpress :::>" >&3

mkdir /var/www/wordpress
cd /var/www/wordpress
wp core download

wp core config --dbuser=wp_admin --dbpass=password --dbname=wordpress
wp core install --url=http://localhost/wordpress --title=Blog --admin_user=admin--admin_password=admin --admin_email=admin@admin.admin  --skip-email
wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'
wp site empty --uploads --yes
wp plugin delete --all

# Silence errors because this always errors at active theme
set +e
wp theme delete --all
set e

# Add this to wp-config to add a dynamic machine ip as wordpress site URL
sed -i "/\/\*\* Sets up WordPress vars and included files. \*\//i\\
/* BE DYNAMIC, BE, BE DYNAMIC! */ \\
\\
// Get server ip address and folder path \\
\$currenthost = 'http://'.\$_SERVER['SERVER_ADDR']; \\
\$currentpath = preg_replace('@/+\$@','',dirname(\$_SERVER['SCRIPT_NAME'])); \\
\$currentpath = preg_replace('/\\\/wp.+/','',\$currentpath); \\
\$siteurl = \$currenthost.\$currentpath; \\
\\
// Define them to be used on wordpress \\
define('WP_HOME',\$siteurl); \\
define('WP_SITEURL',\$siteurl); \\
define('WP_CONTENT_URL',\$siteurl.'/wp-content'); \\
define('WP_PLUGIN_URL',\$siteurl.'/wp-content/plugins'); \\
define('DOMAIN_CURRENT_SITE',\$siteurl); \\
@define('ADMIN_COOKIE_PATH', './'); \\
\\
/* END BE DYNAMIC */ \\
\\
" wp-config.php

echo "<::: Wordpress installed! :::>" >&3
echo "<::: Installation finished! :::>" >&3