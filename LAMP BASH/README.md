# LAMP installation
The steps for a simple LAMP stack installation on Ubuntu 18.04

## Specs
* Ubuntu server 18.04
* PHP 7.3
* MySQL 8.14
* Node 10.x

## Good resources
* https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-18-04#prerequisites
* https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-lamp-on-ubuntu-18-04#prerequisites
* https://askubuntu.com/questions/22743/how-do-i-install-guest-additions-in-a-virtualbox-vm
* https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-18-04
* https://www.wpbeginner.com/wp-tutorials/how-to-fix-the-error-establishing-a-database-connection-in-wordpress/
* https://askubuntu.com/questions/53822/how-do-you-run-ubuntu-server-with-a-gui


The installation is made for VirtualBox with a shared folder

## Update & Upgrade Ubuntu
```
sudo apt-get update
sudo apt-get -y upgrade
```

## Get PHP
```
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
sudo LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/apache2
```

## Get MySQL 8
### Update to the newest version when installing
### Check the MySQL [repos](https://repo.mysql.com/)
```
sudo wget –c https://repo.mysql.com//mysql-apt-config_0.8.14-1_all.deb
sudo dpkg –i mysql-apt-config_0.8.14-1_all.deb
```

## Update packages
```
sudo apt-get update
```

## MYSQL, Apache, PHP & other packages
### Some [notes](https://www.wpintense.com/2018/10/20/installing-the-fastest-wordpress-stack-ubuntu-18-mysql-8/) on optimizing php and mysql
### Also after installing Apache, enable mods
```
sudo apt-get install -y mysql-server apache2 git curl build-essential software-properties-common redis

sudo a2enmod rewrite
sudo systemctl restart apache2

sudo apt-get install -y php7.3 libapache2-mod-php7.3 php7.3-common php7.3-zip php7.3-mysql
sudo apt-get install -y php7.3-imagick php7.3-mbstring php7.3-dom php7.3-curl php7.3-xml
sudo apt-get install -y php7.3-redis php7.3-fpm php7.3-gd php7.3-intl php7.3-opcache php7.3-soap
```

## Get & install fast CGI apache module
```
wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb; sudo apt install -f
```

## Enable fast CGI
```
a2enmod actions fastcgi proxy_fastcgi
```

## Restart Apache
```
sudo systemctl restart apache2
```

## Allow override to all & turn on PHP errors
```
sudo sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/apache2/php.ini
sudo service apache2 restart
```

## Add shared folder functions
```
sudo apt-get install -y virtualbox-guest-x11 linux-headers-$(uname -r)
```

## Add www-data to vboxsf group
```
sudo usermod -aG vboxsf www-data
```

## Mount shared folder to apache2 htaccess
### "shared" is the name of the folder and the file path is where to mount
### Default uid and gid in ubuntu is 33
```
mount -t vboxsf -o rw,uid=33,gid=33 shared /var/www
```

## Add auto mounting on restart
```
sudo nano /etc/fstab
write to file with tabs in between: shared /var/www   vboxsf  rw,uid=33,gid=33    0   0
```

## Configuiring Redis
```
sudo nano /etc/redis/redis.conf
```
### Add lines:
```
# mb depends on RAM
maxmemory 1000mb
# mb depends on RAM
maxmemory-policy allkeys-lru
```
### Find and comment out:
```
#save 900 1
#save 300 10
#save 60 10000
```
## Save the file and reset redis
```
service redis-server restart
```

## Optimzing MySQL
```
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf
```
### Add to End of file
```
innodb_buffer_pool_size = 200M
innodb_log_file_size = 100M
innodb_buffer_pool_instances = 8
innodb_io_capacity = 5000
max_binlog_size = 100M
expire_logs_days = 3
```
### Restart
```
sudo systemctl restart mysql.service
```
## Secure MySQL
### Choose y for everything EXCEPT recommended authentication plugin & enter a secure root password
```
mysql_secure_installation
```

## Add MySQL user and database
### When Adding new mysql users, need to use format:
```
CREATE USER 'admin'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';
CREATE DATABASE wordpress_database DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```

### WordPress specific priviliges
#### ALTER, DROP & GRANT  are used by auto
```
GRANT SELECT, INSERT, DELETE, CREATE, UPDATE, ALTER, DROP ON wordpress_database.* TO 'admin'@'localhost';
```

## Optimizing PHP
```
sudo nano /etc/php/7.3/fpm/php.ini
```
### Change these lines to:
### Remember to uncomment if commented
```
max_execution_time = 6000
memory_limit = 512M
upload_max_filesize = 50M
max_input_vars = 5000

opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=50000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable=1
```

### Next in this file
```
sudo nano /etc/php/7.3/fpm/pool.d/www.conf
```
### Change these to
```
pm = static
pm.max_children = 10
```

## Restart
```
sudo service php7.3-fpm restart
```

## Change index.php to first in index check
```
sudo nano /etc/apache2/mods-enabled/dir.conf 
<IfModule mod_dir.c>
    DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm
</IfModule>
```
### Restart apache
```
sudo systemctl restart apache2
```

# Set up Virtual Host

## Make directory & give permissions
```
sudo mkdir /var/www/wordpress
sudo chown -R $USER:$USER /var/www/wordpress
```

## Add .conf
### FilesMatch is used to run FPM in this site
```
sudo nano /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName wordpress-dev
    ServerAlias www.wordpress-dev
    DocumentRoot /var/www/your_domain
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined

    <Directory /var/www/wordpress/>
      AllowOverride All
    </Directory>
    <FilesMatch ".php$">
      SetHandler "proxy:unix:/var/run/php/php7.3-fpm.sock|fcgi://localhost/"
    </FilesMatch>
</VirtualHost>
```

### Enable our site, disable default
```
sudo a2ensite wordpress.conf
sudo a2dissite 000-default.conf
sudo systemctl restart apache2
```
## Use WP-Cli to install WordPress

### Download wp-cli
```
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
```
### Make WP-Cli work by writing wp 
```
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
```
### Download WordPress 
```
wp core download --path=/var/www/wordpress/
cd /var/www/wordpress/
wp config create --dbname=wordpress_database --dbuser=root --prompt=dbpass
wp core install --url=localhost --title="WordPress site" --admin_user=admin --admin_password=admin --admin_email=admin@admin.admin
```
### If you didn't create the database in MySQL, run this before wp core install
```
wp db create
```
### Add debug
```
wp config set WP_DEBUG true
wp config set FS_METHOD 'direct'
```
### Add permissions
```
sudo chown -R www-data:www-data /var/www/wordpress
sudo find /var/www/wordpress/ -type d -exec chmod 750 {} \;
sudo find /var/www/wordpress/ -type f -exec chmod 640 {} \;
```
### Remove dummy data & default themes
```
wp site empty
```
### Get plugins, default theme & remove the rest
```
wp plugin install advanced-custom-fields wp-smushit polylang
wp plugin activate --all
git clone https://github.com/teemu-nurmi/WordPress-default-theme.git /var/www/wordpress/[directory name]/wp-content/themes/[theme name]
wp theme activate [theme name]
```

## ---- Optional -----
### Give rights to var/www/your_dir
```
find /var/www/[dir]/ -type d -exec chmod 755 {} \;
find /var/www/[dir]/ -type f -exec chmod 644 {} \;
```
## GET Node & NPM
```
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -y nodejs
```