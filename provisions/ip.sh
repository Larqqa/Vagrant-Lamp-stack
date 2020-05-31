#!/bin/bash

echo "Machine IP:"
ip address show enp0s8 | sed -n 's/inet \([0-9.]\+\).*/\1/p'
