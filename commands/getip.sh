#!/bin/bash

# Get this scripts path for relative script pathing
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Check that the argument is correct
if [[ $1 != "" && $1 != '-s' ]]
then
  echo "Wrong argument $1 given, should be [-s]"
  echo "Defaulting to no flags..."
fi

# Check vagrant status
if [[ $1 == '-s' ]]
then
  bash "${PARENT_PATH}/vagrantstatus.sh"
fi

MACHINEIP=$(
  vagrant ssh -c "
    printf 'Machine IP: '
    ip address show enp0s8 |
    sed -n 's/inet \([0-9.]\+\).*/\1/p' |
    tr -d '[:space:]'
  " 2> /dev/null
)

echo $MACHINEIP