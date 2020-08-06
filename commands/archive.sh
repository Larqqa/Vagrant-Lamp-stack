#!/bin/bash

# Get the time and date
# String is Hours+Minutes+Seconds-date-month-year
# This allows for making multiple backups without fear of overwriting
today=$(date +"%H%M%S-%d-%m-%Y")
currentdir=$(basename "$PWD")

# Get this scripts path for relative script pathing
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

while true; do
  read -n1 -p "Do you want to continue with archiving? [y/N] " yn
  echo ""
  case $yn in
    [Yy]* )
      # Make a dump of the database
      bash "${PARENT_PATH}/sql-actions.sh" -e

      # Make archive, excluding the node_modules
      "C:\Program Files\7-Zip\7z.exe" a -tzip ./backups/${currentdir}-${today}.zip ./data/* -mx0 '-xr!*node_modules\*'
      break;;
    [Nn]* )
      echo "Stopping..."
      exit;;
    * ) echo "Please answer i or e.";;
  esac
done