#!/bin/bash
################################
#
# Install a web server
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/server.log 2>&1
set -ex

echo "------ Installing the web server ------" >&3

# Check which server config to use
if  test $SERVER = "nginx"; then

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

  # yeet
  client_max_body_size 1G;

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
  error_log /home/vagrant/logs/error.log;
  access_log /home/vagrant/logs/access.log;

  # Locations to look for
  location / {
    # try_files \$uri \$uri/ =404;
    try_files \$uri \$uri/ /index.php?q=\$uri&\$args;
    autoindex on;
  }

  # Add wordpress folder
  location /${NAME}/ {
    # try_files \$uri \$uri/ =404;
    try_files \$uri \$uri/ /${NAME}/index.php?q=\$uri&\$args;
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
    fastcgi_pass unix:/var/run/php/php${PHPV}-fpm.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
  }
}
EOL

echo "<::: Adding new block to enabled sites :::>" >&3
ln -s /etc/nginx/sites-available/wordpress.com /etc/nginx/sites-enabled/
unlink /etc/nginx/sites-enabled/default

systemctl reload nginx

echo "------ Nginx install finished ------" >&3

else

echo "------ Installing Apache ------" >&3

echo "<::: Get Apache repo :::>" >&3
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
apt update

echo "<::: Install and enable Apache :::>" >&3
apt-get install -y apache2
a2enmod rewrite
systemctl restart apache2

echo "<::: Adding Fast CGI :::>" >&3
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f

a2enmod actions fastcgi proxy_fcgi
systemctl restart apache2

echo "<::: Doing Apache configs :::>" >&3
sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Disable redis install for now
# echo "<::: Install & configuring Redis :::>" >&3
# apt-get install -y redis
# echo "maxmemory 1000mb" >>/etc/redis/redis.conf
# echo "maxmemory-policy allkeys-lru" >>/etc/redis/redis.conf

# sed -i "s/save 900 1/#save 900 1/" /etc/redis/redis.conf
# sed -i "s/save 300 10/#save 300 10/" /etc/redis/redis.conf
# sed -i "s/save 60 10000/#save 60 10000/" /etc/redis/redis.conf

# service redis-server restart

echo "<::: Adding self signed SSL cert :::>" >&3
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj '/C=FI/ST=Hämeenlinna/L=Hämeenlinna/CN=localhost'

echo "<::: Adding Diffie-Hellman group :::>" >&3
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

echo "<::: Adding SSL mods & config and configuring DirectoryIndex :::>" >&3
touch /etc/apache2/conf-available/ssl-params.conf
cat > /etc/apache2/conf-available/ssl-params.conf << EOL
# from https://cipherli.st/
# and https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html

SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3
SSLHonorCipherOrder On
# Disable preloading HSTS for now.  You can use the commented out header line that includes
# the "preload" directive if you understand the implications.
#Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains; preload"
Header always set Strict-Transport-Security "max-age=63072000; includeSubdomains"
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
# Requires Apache >= 2.4
SSLCompression off
SSLSessionTickets Off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"

SSLOpenSSLConfCmd DHParameters "/etc/ssl/certs/dhparam.pem"
EOL

sed -i "s/DirectoryIndex .*/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/" /etc/apache2/mods-enabled/dir.conf
a2enmod ssl
a2enmod headers
a2enconf ssl-params
systemctl restart apache2

echo "<::: Adding Virtual Host with no SSL :::>" >&3
touch /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf << EOL
<VirtualHost *:80>
  ServerAdmin webmaster@localhost
  ServerName wordpress-dev
  ServerAlias www.wordpress-dev
  DocumentRoot /var/www/
  #ErrorLog \${APACHE_LOG_DIR}/error.log
  #CustomLog \${APACHE_LOG_DIR}/access.log combined

  ErrorLog /home/vagrant/logs/error.log
  CustomLog /home/vagrant/logs/access.log combined

  <Directory /var/www/>
    AllowOverride All
  </Directory>

  <FilesMatch ".php$">
    SetHandler "proxy:unix:/var/run/php/php${PHPV}-fpm.sock|fcgi://localhost/"
  </FilesMatch>
</VirtualHost>
EOL

echo "<::: Adding Virtual Host with SSL :::>" >&3
touch /etc/apache2/sites-available/wordpress-ssl.conf
cat > /etc/apache2/sites-available/wordpress-ssl.conf << EOL
<IfModule mod_ssl.c>
  <VirtualHost _default_:443>
    ServerAdmin webmaster@localhost
    ServerName wordpress-dev
    ServerAlias www.wordpress-dev
    DocumentRoot /var/www/

    #ErrorLog \${APACHE_LOG_DIR}/error.log
    #CustomLog \${APACHE_LOG_DIR}/access.log combined

    ErrorLog /var/www/logs/server-logs/error.log
    CustomLog /var/www/logs/server-logs/access.log combined

    SSLEngine on
    SSLCertificateFile    /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key

    <FilesMatch "\.(cgi|shtml|phtml|php)$">
      SSLOptions +StdEnvVars
      SetHandler "proxy:unix:/var/run/php/php${PHPV}-fpm.sock|fcgi://localhost/"
    </FilesMatch>

    <Directory /usr/lib/cgi-bin>
      SSLOptions +StdEnvVars
    </Directory>

    BrowserMatch "MSIE [2-6]" \\
                  nokeepalive ssl-unclean-shutdown \\
                  downgrade-1.0 force-response-1.0

  </VirtualHost>
</IfModule>
EOL

echo "<::: Enabling vitual hosts :::>" >&3
a2ensite wordpress.conf
a2ensite wordpress-ssl.conf
a2dissite 000-default.conf
systemctl restart apache2

echo "------ Apache install finished ------" >&3

fi # End of server select

echo "<::: Setting permissions to www folder :::>" >&3
sudo chown -R www-data:www-data /var/www
usermod -aG www-data $USER
chmod -R g+wrx /var/www

# Add the www folder as default path to speed up SSH login
echo "cd /var/www" >> /home/vagrant/.bashrc

echo "<::: Add info.php page :::>" >&3
cat <<EOF >/var/www/info.php
<?php
phpinfo();
?>
EOF

echo "------ Server install finished ------" >&3