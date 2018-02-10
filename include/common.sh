#!/bin/bash

# output process message
# $1 message
message () {
  echo "====> $1"
}

# download file
# $1 saved file name
# $2 url url location
download () {
  message "downloading $1"
  wget $2 -O $1
}
