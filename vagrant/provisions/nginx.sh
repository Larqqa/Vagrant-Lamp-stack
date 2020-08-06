#!/bin/bash
################################
#
# Install Apache
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/nginx.log 2>&1
set -ex

echo "------ Installing Nginx ------" >&3
apt-get install -y nginx
ufw allow 'Nginx Full'

echo "<::: Adding self signed SSL cert :::>" >&3
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj '/C=FI/ST=Hämeenlinna/L=Hämeenlinna/CN=localhost'

echo "<::: Adding Diffie-Hellman group :::>" >&3
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo "<::: Adding SSL :::>" >&3
touch /etc/nginx/snippets/self-signed.conf
cat > /etc/nginx/snippets/self-signed.conf << EOL
ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
EOL
touch /etc/nginx/snippets/ssl-params.conf
cat > /etc/nginx/snippets/ssl-params.conf << EOL
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;
ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
ssl_ecdh_curve secp384r1;
ssl_session_cache shared:SSL:10m;
ssl_session_tickets off;
ssl_stapling on;
ssl_stapling_verify on;
resolver 8.8.8.8 8.8.4.4 valid=300s;
resolver_timeout 5s;
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
add_header X-Frame-Options DENY;
add_header X-Content-Type-Options nosniff;

ssl_dhparam /etc/ssl/certs/dhparam.pem;
EOL

echo "<::: Adding block configuration with no SSL :::>" >&3
touch /etc/nginx/sites-available/wordpress.com
cat > /etc/nginx/sites-available/wordpress.com << EOL
server {

  # Listen to normal HTTP traffic
  listen 80;
  listen [::]:80 ipv6only=on;

  # Enable SSL and listen to HTTPS traffic
  listen 443 ssl;
  listen [::]:443 ssl;
  include snippets/self-signed.conf;
  include snippets/ssl-params.conf;

  # Set root folder and file priority
  root /var/www;
  index index.php index.html index.htm;

  # Server name
  server_name wordpress-dev.com;

  # Set custom error log dir
  error_log /var/www/logs/server-logs/error.log;
  access_log /var/www/logs/server-logs/access.log;

  # Locations to look for
  location / {
    # try_files \$uri \$uri/ =404;
    try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
    autoindex on;
  }

  # Set error page templates
  error_page 404 /404.html;

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
    root /usr/share/nginx/html;
  }

  # Setup PHP listening and FPM
  location ~ \.php$ {
    try_files \$uri /index.php =404;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
  }
}
EOL

echo "<::: Adding new block to enabled sites :::>" >&3
ln -s /etc/nginx/sites-available/wordpress.com /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

systemctl reload nginx

# Add the www folder as default path to speed up SSH login
echo "cd /var/www" >> /home/vagrant/.bashrc

echo "<::: Setting permissions to www folder :::>" >&3
sudo chown -R www-data:www-data /var/www
usermod -aG www-data $USER
chmod -R g+wrx /var/www

echo "<::: Add info.php page :::>" >&3
cat <<EOF >/var/www/html/index.php
<?php
phpinfo();
?>
EOF

echo "------ Nginx install finished ------" >&3