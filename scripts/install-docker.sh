#!/bin/bash

echo 'Installing docker'

# install docker
dnf -y install dnf-plugins-core

dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

dnf -y install docker-ce docker-ce-cli

## Create /etc/docker directory.
mkdir -p /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

systemctl daemon-reload
systemctl start docker
systemctl enable docker.service

# run docker commands as vagrant user (sudo not required)
usermod -aG docker vagrant