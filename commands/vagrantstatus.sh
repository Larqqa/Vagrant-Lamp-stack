#!/bin/bash

# Check that the argument is correct
if [[ $1 != "" && $1 != '-n' ]]
then
  echo "Wrong argument $1 given, should be [-n]"
  echo "Defaulting to no flags..."
fi

echo "Checking Vagrant status"

# Check if Vagrant box is running
vagrant status | grep "running" -q && status=true || status=false

# Start it if not
if [[ $status = false ]]
then
  echo "VM not running"

  # If not run with -n flag, start the VM
  if [[ $1 != '-n' ]]
  then
    echo "Starting VM..."
    vagrant up
  fi
else
  echo "VM already running"
fi