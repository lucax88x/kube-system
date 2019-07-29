#!/bin/bash

apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

apt update
apt install docker-ce -y

# run docker commands as vagrant user (sudo not required)
usermod -aG docker vagrant