808# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Box settings
  config.vm.box = "ubuntu/bionic64"

  # Provider settings
  config.vm.provider "virtualbox" do |vb|

    # Use for VirtualBox GUI
    # vb.gui = true

    vb.memory = "3000"
    vb.cpus = 2

  end

  # Network settings
  config.vm.network "public_network"
  config.vm.network "forwarded_port", guest: 80, host: 80

  # Synced folder
  config.vm.synced_folder "./data", "/var/www" , :nfs => { :mount_options => ["dmode=777", "fmode=666"] }, create: true

  # Provisions
  config.vm.provision "shell", path: "./provisions/lamp.sh"
  config.vm.provision "shell", path: "./provisions/config.sh"
  config.vm.provision "shell", path: "./provisions/wordpress.sh", privileged: false # run as user

end