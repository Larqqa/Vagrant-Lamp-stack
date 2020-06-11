#!/bin/bash

# Get the Database name from the Vagrantfile
DB=$(sed -n '/"DB" => .*/p' Vagrantfile | sed 's/^ *"DB" => //' | tr -d '",')

# Set some vars
ACTION=false
VAGRANT=true

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -i|--import)
    ACTION="i"
    shift # past argument
    ;;
    -e|--export)
    ACTION="e"
    shift # past argument
    ;;
    -v|--vagrant)
    VAGRANT=false
    shift # past argument
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [[ $VAGRANT = true ]]
then
  # Start vagrant if it is not running
  bash vagrantstatus.sh
fi

while true; do

  # If no option, ask user for input
  if [[ $ACTION != [IiEe] ]]
  then
    read -n1 -p "Do you want to import or export the database? [i for import | e for export] " ACTION
    echo ""
  fi

  # Do action
  case $ACTION in
    [Ii]* )
      # Import the Database dump
      echo "-- Importing database dump to $DB --" 
      vagrant ssh -c "sudo mysql $DB < /var/www/db_dump.sql"
      echo "-- Finished --"
      break;;
    [Ee]* )
      # Make a Database dump to shared folder
      echo "-- Making database dump of $DB --" 
      vagrant ssh -c "sudo mysqldump $DB > /var/www/db_dump.sql"
      echo "-- Finished --"
      break;;
    * ) echo "Please answer i or e.";;
  esac
done
