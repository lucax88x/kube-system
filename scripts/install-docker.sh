#!/bin/bash

echo 'Installing docker'

# install docker

# CENTOS
yum -y install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io

# # UBUNTU
# apt install apt-transport-https ca-certificates curl software-properties-common
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
# apt update
# apt install docker-ce -y

systemctl start docker
systemctl enable docker.service

# run docker commands as vagrant user (sudo not required)
usermod -aG docker vagrant