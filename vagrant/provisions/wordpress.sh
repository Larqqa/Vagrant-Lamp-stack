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

# This tends to fail a lot on curl errors, so retry if it fails
succeeded=false
for i in $(seq 1 5); do
  wp core download --locale=$LOCALE --version=$VERSION --skip-content && succeeded=true && break ||
  echo "Download failed, retrying in 5s" >&3 && sleep 5;
done

if test $succeeded != true; then
    echo "Download failed after 5 attempts, please try running the provision again."
    exit 1
fi

wp core config --dbuser=wp_admin --dbpass=password --dbname=$DB
wp db create

echo "<::: Install Wordpress :::>" >&3
wp core install --url=http://localhost/$NAME --title=Blog --admin_user=admin --admin_password=admin --admin_email=admin@admin.admin  --skip-email
wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'

# Add pretty permalinks
wp rewrite structure '/%postname%/'
wp rewrite flush

echo "<::: Add default .htaccess file :::>" >&3
touch .htaccess
cat > .htaccess << EOL
# BEGIN WordPress
# The directives (lines) between `BEGIN WordPress` and `END WordPress` are
# dynamically generated, and should only be modified via WordPress filters.
# Any changes to the directives between these markers will be overwritten.
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /$NAME/
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /$NAME/index.php [L]
</IfModule>

# END WordPress
EOL

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

echo "<::: Get latest Wordpress base theme :::>" >&3
set +e # Disregard errors
wp theme install twentytwenty --activate
set e

if test "$PURGE" = true; then
echo "<::: Clean up the Wordpress install :::>" >&3
  wp site empty --uploads --yes
  wp plugin delete --all
  set +e # Disregard errors
  wp theme delete --all
  set e
fi

if test "$MIGRATE" = true; then
echo "<::: Install migrate plugin :::>" >&3
  set +e # Disregard errors
  wp plugin install all-in-one-wp-migration --activate
  set e
fi

echo "------ Wordpress installed! ------" >&3
echo "------ Installation finished! ------" >&3
