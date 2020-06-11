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


### About the scripts:

!! THE SCRIPTS RELY ON 7zip FOR ARCHIVING AND EXTRACTING THE ARCHIVES !!

archive.sh:
This packs the `data` folder into a new .zip archive with the name `data-[timestamp].zip`
Archives are saved in `backups` folder by default.

restore.sh:
can be initialized with arg `-f|--filename [filename]` to give the archive file to restore, otherwise you need to write the path when prompted
The script will ask if you want to overwrite the `data` folder and replace the current DB separately.

sql-actions.sh:
Can be initialized with args:
  * -i|--import to import a database from the dump file `db_dump.sql` inside the `data` folder
  * -e|--export to make a new dump in to file `db_dump.sql` inside the `data` folder, this overwrites old dumps in `data` folder!
  * -v|--vagrant to skip checking the VMs status
The dump file lives in the data folder for ease of use and simplicity of the script. Just be aware that exporting with this script overwrites the previous dump, so you should either rely on the archive files or move the dumps into a different folder before exporting if you need to save the backups.

vagrantstatus.sh:
A simple script to make sure the VM is running. Uses `vagrant status` to see if machine is running, and executes `vagrant up` if it is not.