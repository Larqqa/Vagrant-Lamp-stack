# Bash script for making new Vagrant boxes
## Make easy LAMP stacks with empty Wordpress sites for developing new websites!

Run `bash make-box.sh` to create the files needed for making the new box

The default is:
* Ubuntu 18.04
* Apache2
* MariaDB
* PHP7.3
* New Wordpress install

Options let you set:
* the name of the VM
* the name of the wordpress folder
* PHP5.6 instead of 7.3
* MySQL instead of MariaDB
* Purging of the Wordpress
* Installing of all in one migration plugin for easy site importing


Install the box by running `vagrant up` inside of the created folder
More on [Vagrant commands](https://www.vagrantup.com/docs)

Remember to do `vagrant plugin install vagrant-vbguest` for installing the newest VirtualBox guest additions!

You can use `bash sql-dump.sh` to make a database dump into `data` folder