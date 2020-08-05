# Cli tool for managing Vagrant boxes
## Make, backup & restore easy LAMP stacks with empty Wordpress sites for developing new websites!

### Dependencies
This tool relies on the plugin [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) for installing and updating VirtualBox guest additions.
Run `vagrant plugin install vagrant-vbguest` to install the Vagrant plugin, or configure the guest additions yourself if they are needed.

This tool is configured to use 7zip for making and extracting the `.zip` archives. Make sure it is installed in `C:\Program Files\7-Zip\7z.exe`, or configure the files to reflect your install folder.

This tool is also used and tested on Windows 10, so expect issues on other OS:s.

You have to add this folders path to your `path` environment variable by hand, if you want to run the commands without addingg the whole path.

### Using the tool

#### Check the commands
`lrq-tool help`:
Run this to check all the commands and flags that can and should be used!

#### Creating new boxes
`lrq-tool makebox`:
Short command: `lrq-tool -mb`
Creates the vagrant files needed for creating the VM.
A new folder is created into the current working directory and the files are copied in to it from the tools master files.

The default box contains:
* Ubuntu 18.04
* Apache2
* MariaDB
* PHP7.3
* New Wordpress install

Options let you set:
* the name of the VM (default folder name is `new-box` and vm name is `new-box + timestamp`)
* the name of the Wordpress folder (default is `wordpress`)
* use PHP5.6 instead of 7.3
* use MySQL instead of MariaDB
* Purging of the default Wordpress content
* Installing of the All In One Migration plugin for quick & easy site importing

To install the box, run `vagrant up` inside of the newly created folder
More on [Vagrant commands](https://www.vagrantup.com/docs)

#### Archiving
`lrq-tool archive`:
Short command: `lrq-tool -a`
This packs the `data` folder into a new .zip archive with the name `data-[timestamp].zip`
Archives are saved in `backups` folder by default.

`lrq-tool restore [-f|--filename] [the archive files path]`:
Short command: `lrq-tool -r [-f|--filename] [the archive files path]`
can be initialized with arg `-f|--filename` and the path to the archive file to restore. Otherwise you need to write the path when prompted.
The script will ask if you want to overwrite the `data` folder and replace the current DB separately.

#### Database actions
`lrq-tool database [-i|-e] [-v]`:
Short command: `lrq-tool -db [-i|-e] [-v]`
Can be initialized with args:
  * -i|--import to import a database from the dump file `db_dump.sql` inside the `data` folder
  * -e|--export to make a new dump in to file `db_dump.sql` inside the `data` folder, this overwrites old dumps in `data` folder!
  * -v|--vagrant to skip checking the VMs status
The dump file lives in the data folder for ease of use and simplicity of the script. Just be aware that exporting with this script overwrites the previous dump, so you should either rely on the archive files or move the dumps into a different folder before exporting if you need to save the backups.

#### Checking vm status
`lrq-tool vagrantstatus [-n]`:
Short command: `lrq-tool -vs [-n]`
A simple script to make sure the VM is running. Uses `vagrant status` to see if machine is running, and executes `vagrant up` if it is not. Use flag `-n` if you only want to check the status and not run `vagrant up`.