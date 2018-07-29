#!/bin/bash

# Ensures the instance is launched completely
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 1
done



# Install packages
sudo yum install lsof -y
sudo yum install  bzip2  -y

