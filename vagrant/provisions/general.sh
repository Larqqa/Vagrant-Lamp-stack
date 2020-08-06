#!/bin/bash
################################
#
# Install Apache
#
################################

# mkdir for installer logs
mkdir /var/www/logs
mkdir /var/www/logs/server-logs

# Grab log output to file, use >&3 to echo to console
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/var/www/logs/general.log 2>&1
set -ex

echo "------ Installing generic stuff ------" >&3

echo "<::: Installing updates :::>" >&3
apt update
apt upgrade -y

echo "<::: Installing Essential Packages :::>" >&3
apt-get install -y build-essential dkms linux-headers-$(uname -r) software-properties-common git curl

echo "<::: Installing WP Cli :::>" >&3
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

echo "------ Generics finished ------" >&3