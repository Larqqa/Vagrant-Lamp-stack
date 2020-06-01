#!/bin/bash
################################
#
# Add Wordpress Box to Vagrant
#
################################
wp_banner()
{
  clear

  BOLD=$(tput bold)
  GREEN=$(tput setaf 2)
  WHITE=$(tput setaf 7)
  BLUE=$(tput setaf 6)
  RESET=$(tput sgr0)

  echo "${BLUE}
                    wwwwwwwwwwwwwwwwwwwwww
                wwwwwwwww            wwwwwwwww
              wwwwww   wwwwwwwwwwwwwwwwww   wwwwww
            wwww   wwwwwwwwwwwwwwwwwwwwwwwwww   wwww
          wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww  wwww
        wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww   wwww
      wwww  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww        wwww
    www  wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww           www
    www          wwwwwwwwww         wwwwwwwww            www
  www  w       wwwwwwwwwwww       wwwwwwwwwww        ww  www
  ww  www       wwwwwwwwwwww       wwwwwwwwwwww      www  ww
  www  www       wwwwwwwwwwwww       wwwwwwwwwwww     www  www
  ww  wwwww       wwwwwwwwwwww       wwwwwwwwwwww     wwww  ww
  ww  wwwwww       wwwwwwwwwwww       wwwwwwwwwwww   wwwww  ww
  ww  wwwwwww      wwwwwwwwwwwww       wwwwwwwwwww  wwwwww  ww
  ww  wwwwwww       wwwwwwwwwww        wwwwwwwwwww  wwwwww  ww
  ww  wwwwwwww       wwwwwwwww  w       wwwwwwwww  wwwwwww  ww
  ww  wwwwwwwww      wwwwwwwww www       wwwwwwww wwwwwwww  ww
  www  wwwwwwww       wwwwwww wwwww      wwwwwww  wwwwwww  www
  ww  wwwwwwwww       wwwww  wwwwww      wwwww  wwwwwwww  ww
  www  wwwwwwwww      wwwww wwwwwww       wwww wwwwwwww  www
    www  wwwwwwwww      www wwwwwwwww      www  wwwwwww  www
    www  wwwwwwww       w wwwwwwwwwww      ww wwwwwww  www
      wwww  wwwwwww        wwwwwwwwwww        wwwwww  wwww
        wwww  wwwwww      wwwwwwwwwwwww      wwwww  wwww
          wwww  wwwww    wwwwwwwwwwwwwww     www  wwww
            wwww   ww    wwwwwwwwwwwwwwww       wwww
              wwwwww    wwwwwwwwwwwwwwwww   wwwwww
                wwwwwwwww            wwwwwwwww
                    wwwwwwwwwwwwwwwwwwwwww
  ${RESET}"
  echo "${BOLD}${GREEN}
                Development WordPress Installer
  ${RESET}"
}

wp_banner # Show banner

default_folder="wordpress"
default_dbname="wp_db"

echo "Give the machine a name! (if empty, use autogenerated name)"
read name
if test -n "$name"; then
  echo ""
else
  name=false
fi

echo "What folder should the Wordpress be installed to? (default: $default_folder)"
read folder
if test -n "$folder"; then
  echo ""
else
  folder=$default_folder
fi

echo "Give the database name. (default: $default_dbname)"
read dbname
if test -n "$dbname"; then
  echo ""
else
  dbname=$default_dbname
fi

php=7.3
while true; do
read -p "Should this box use php5.6 instead of php7.3? [y/N] " yn
  case $yn in
    [Yy]* )
      php=5.6
      break;;
    [Nn]* )
      break;;
    * ) echo "Please answer y or n.";;
  esac
done

db="mysql"
while true; do
read -p "Should this box use MySQL isntead of MariaDB? [y/N] " yn
  case $yn in
    [Yy]* )
      db="mariadb"
      break;;
    [Nn]* )
      break;;
    * ) echo "Please answer y or n.";;
  esac
done

purge=false
while true; do
read -p "Do you want to purge WordPress? [y/N] " yn
  case $yn in
    [Yy]* )
      purge=true
      break;;
    [Nn]* )
      break;;
    * ) echo "Please answer y or n.";;
  esac
done

while true; do
read -p "
Is this correct?
Name:        $name
Folder:      $folder
DB name:     $dbname
PHP version: $php
Database:    $db
Purge WP:    $purge
Proceed to install? [y/N]
" yn
  case $yn in
    [Yy]* ) break;;
    [Nn]* ) exit;;
    * ) echo "Please answer y or n.";;
  esac
done

# Make new box's folder & copy files to it
if test $name = false; then
mkdir new-box
cp Vagrantfile new-box
cp -r ./provisions new-box
cd new-box
else
mkdir $name
cp Vagrantfile $name
cp -r ./provisions $name
cd $name
fi

# Change the VM name
if test $name != false; then
sed -i "s/vb.name.*/vb.name = \"$name\"/" ./Vagrantfile
else
sed -i 's/vb.name.*/# &/' ./Vagrantfile
fi

# Set ENV vars for Wordpress
sed -i "s/\"NAME\" =>.*/\"NAME\" => \"$folder\",/" ./Vagrantfile
sed -i "s/\"DB\" =>.*/\"DB\" => \"$dbname\",/" ./Vagrantfile
sed -i "s/\"PURGE\" =>.*/\"PURGE\" => $purge/" ./Vagrantfile

# Change PHP Version
if test $php != 7.3; then
sed -i "s/php7/php5/" ./Vagrantfile
sed -i "s/php7.3/php5.6" ./provisions/apache.sh
fi

# Change database version
if test $db != "mysql" ; then
sed -i "s/mariadb/mysql/" ./Vagrantfile
fi