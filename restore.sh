#!/bin/bash

# Set some vars
FILENAME=false

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -f|--filename)
    FILENAME=$2
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

while true; do
  
  # Check if filename supplied in arguments
  if [[ $FILENAME = false ]]
  then
    # Prompt user for archive to restore
    read -p "Give archive name to restore: " FILENAME
  fi

  # Check that file exists
  if test -f "$FILENAME"; then
    echo "$FILENAME exists"
    
    while true; do
      read -n1 -p "Do you want to continue with restoring this backup? [y/N] " yn
      echo ""
      case $yn in
        [Yy]* )
          # Check if data exists
          if test -d "./data"; then
            while true; do
              read -n1 -p "/data exists, do you want to overwrite it? [y/N] " yn
              echo ""
              case $yn in
                [Yy]* )
                  rm -rf ./data
                  "C:\Program Files\7-Zip\7z.exe" x $FILENAME -o./data
                  break;;
                [Nn]* )
                  echo "Stopping extraction..."
                  break;;
                * ) echo "Please answer y or n.";;
              esac
            done
          else
            "C:\Program Files\7-Zip\7z.exe" x $FILENAME -o./data
          fi

          # If DB dump exists
          if test -f "./data/db_dump.sql"; then
            while true; do
              read -n1 -p "Restore Database from dump? [y/N] " yn
              echo ""
              case $yn in
                [Yy]* )
                  bash sql-actions.sh -i
                  break;;
                [Nn]* )
                  echo "Stopping..."
                  break;;
                * ) echo "Please answer y or n.";;
              esac
            done
          fi
          break;;
        [Nn]* )
          echo "Stopping..."
          break;;
        * ) echo "Please answer y or n.";;
      esac
    done

    break
  else
    echo "file $FILENAME was not found, please try again."

    # Reset FILENAME for new user input
    FILENAME=false
  fi
done