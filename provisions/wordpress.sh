#!/bin/bash
################################
#
# Install Wordpress
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/wordpress.log 2>&1
set -ex

echo "------ Installing $NAME ------" >&3

echo "<::: Make folder for the install :::>" >&3
set +e # Disregard errors
mkdir /var/www/$NAME
set e

cd /var/www/$NAME

echo "<::: Download & setup Wordpress :::>" >&3
wp core download
wp core config --dbuser=wp_admin --dbpass=password --dbname=$DB
wp db create

echo "<::: Install Wordpress :::>" >&3
wp core install --url=http://localhost/$NAME --title=Blog --admin_user=admin --admin_password=admin --admin_email=admin@admin.admin  --skip-email
wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'

# Add pretty permalinks
wp rewrite structure '/%postname%/'
wp rewrite flush

echo "<::: Add dynamic server URL to wp-config.php :::>" >&3
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

if test "$PURGE" = true; then
echo "<::: Clean up the Wordpress install :::>" >&3
  wp site empty --uploads --yes
  wp plugin delete --all
  set +e # Disregard errors
  wp theme delete --all
  set e
fi

echo "------ Wordpress installed! ------" >&3
echo "------ Installation finished! ------" >&3