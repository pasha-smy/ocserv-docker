#!/bin/bash

# define container name
CONTAINER_NAME="ocserver"

# check if arguments are provided
if [ "$#" -ne 2 ]; then
  # prompt for username and password if not provided as arguments
  read -p "enter username: " USER
  read -s -p "enter password: " PASS
  echo
else
  # get arguments
  USER="$1"
  PASS="$2"
fi

# run ocpasswd inside the container to add user
docker exec -i "$CONTAINER_NAME" bash -c "echo '$PASS' | ocpasswd -c /etc/ocserv/users $USER"