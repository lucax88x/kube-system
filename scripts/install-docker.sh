#!/bin/bash

echo 'Installing docker'

# install docker
dnf -y install dnf-plugins-core

dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

dnf -y install docker-ce docker-ce-cli --nobest

systemctl start docker
systemctl enable docker.service

# run docker commands as vagrant user (sudo not required)
usermod -aG docker vagrant