808# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Box settings
  config.vm.box = "ubuntu/bionic64"

  # Provider settings
  config.vm.provider "virtualbox" do |vb|

    # Use for VirtualBox GUI
    # vb.gui = true

    vb.memory = "1600"
    vb.cpus = 2

    vb.customize [
      "setextradata",
      :id,
      "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root",
      "1"
    ]
  end

  # Network settings #

  # This host needs to match the wp localhost port
  # config.vm.network "forwarded_port", guest: 8080, host: 8080
  config.vm.network "forwarded_port", guest: 80, host: 80

  # Synced folder
  config.vm.synced_folder "./data", "/var/www" , :nfs => { :mount_options => ["dmode=777", "fmode=666"] }, create: true

  # Provisions #

  # Run commands as root
  config.vm.provision "shell", path: "lamp.sh"
  config.vm.provision "shell", path: "config.sh"

end