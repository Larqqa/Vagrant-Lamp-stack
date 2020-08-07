#!/bin/bash
################################
#
# Install a Database
#
################################

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/database.log 2>&1
set -ex

echo "------ Installing ${TYPE} ------" >&3

echo "<::: Installing ${TYPE} :::>" >&3

if  test $TYPE = "mariadb"; then
  # mariadb
  DBPATH=/etc/mysql/mariadb.conf.d/50-server.cnf
  apt-get install -y mariadb-server
else
  # mysql
  DBPATH=/etc/mysql/mysql.conf.d/mysqld.cnf
  apt-get install -y mysql-server
fi

echo "<::: Configuring ${TYPE} :::>" >&3
mysql -p --execute="
  CREATE USER 'larqqa'@'%' IDENTIFIED BY 'password';
  GRANT ALL ON *.* TO 'larqqa'@'%';
  CREATE USER 'wp_admin'@'localhost' IDENTIFIED BY 'password';
  GRANT ALL ON *.* TO 'wp_admin'@'localhost';"

sed -i "s/bind-address.*/bind-address = 0.0.0.0/" $DBPATH
sed -i "s/max_binlog_size.*/max_binlog_size = 100M/" $DBPATH
sed -i "s/expire_logs_days.*/expire_logs_days =  3/" $DBPATH
sed -i "/* InnoDB/a innodb_buffer_pool_size = 200M" $DBPATH
sed -i "/* InnoDB/a innodb_log_file_size = 100M" $DBPATH
sed -i "/* InnoDB/a innodb_buffer_pool_instances = 8" $DBPATH
sed -i "/* InnoDB/a innodb_io_capacity = 5000" $DBPATH

systemctl restart mysql.service

echo "------ ${TYPE} install finished ------" >&3