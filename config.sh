#!/bin/bash
################################
#
# configure LAMP stack
#
################################

sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/apache2/php.ini

echo 'restarting apache'
service apache2 restart

echo "maxmemory 1000mb" >>/etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >>/etc/redis/redis.conf

sed -i "s/save 900 1/#save 900 1/" /etc/redis/redis.conf
sed -i "s/save 300 10/#save 300 10/" /etc/redis/redis.conf
sed -i "s/save 60 10000/#save 60 10000/" /etc/redis/redis.conf

echo 'restarting redis'
service redis-server restart

echo 'configuring MySQL and adding a root user'
mysql -p --execute="
  CREATE USER 'larqqa'@'%' IDENTIFIED WITH mysql_native_password BY 'admin';
  GRANT ALL ON *.* TO 'larqqa'@'%';"

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf
echo " innodb_buffer_pool_size = 200M" >>/etc/mysql/mysql.conf.d/mysqld.cnf
echo " innodb_log_file_size = 100M" >>/etc/mysql/mysql.conf.d/mysqld.cnf
echo " innodb_buffer_pool_instances = 8" >>/etc/mysql/mysql.conf.d/mysqld.cnf
echo " innodb_io_capacity = 5000" >>/etc/mysql/mysql.conf.d/mysqld.cnf
echo " max_binlog_size = 100M" >>/etc/mysql/mysql.conf.d/mysqld.cnf
echo " expire_logs_days = 3" >>/etc/mysql/mysql.conf.d/mysqld.cnf

echo 'restarting mysql'
systemctl restart mysql.service

sed -i "s/max_execution_time = .*/max_execution_time = 6000/" /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 50M/" /etc/php/7.3/fpm/php.ini
sed -i "s/max_input_vars = .*/max_input_vars = 5000/" /etc/php/7.3/fpm/php.ini

sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=50000/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=60/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/7.3/fpm/php.ini

sed -i "s/pm = .*/pm = static/" /etc/php/7.3/fpm/pool.d/www.conf
sed -i "s/pm.max_children = .*/pm.max_children = 10/" /etc/php/7.3/fpm/pool.d/www.conf

echo 'restarting fpm'
service php7.3-fpm restart

echo 'add virtual host'

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

# Add the www folder as default path to speed up SSH login
echo "cd /var/www" >> /home/vagrant/.bashrc