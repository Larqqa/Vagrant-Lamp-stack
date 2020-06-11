#!/bin/bash

echo "Checking Vagrant status"

# Check if Vagrant box is running
vagrant status | grep "running" -q && status=true || status=false

# Start it if not
if [[ status = false ]]
then
  echo "VM not running, starting VM..."
  vagrant up
else
  echo "VM already running"
fi