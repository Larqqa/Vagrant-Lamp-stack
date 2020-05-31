808# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # Box settings
  config.vm.box = "ubuntu/bionic64"

  # Provider settings
  config.vm.provider "virtualbox" do |vb|

    # Use for VirtualBox GUI
    # vb.gui = true

    vb.memory = "1500"
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
  
  # run wordpress installer as user
  config.vm.provision "shell", path: "./provisions/wordpress.sh", privileged: false, env: {"NAME" => 'wordpress'}

  # Print machine ip always for easy access to server
  $script = <<-'SHELL'
  #!/bin/bash
  printf "Machine IP: "
  ip address show enp0s8 | sed -n 's/inet \([0-9.]\+\).*/\1/p'
  SHELL

  config.vm.provision "shell", inline: $script, run: 'always'

end