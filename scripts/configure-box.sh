#!/bin/bash

# install kubeadm

# CENTOS
yum install -y wget
yum install -y net-tools

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install -y kubelet kubeadm kubectl

## UBUNTU
# apt-get install -y apt-transport-https curl
# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
# cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
# deb http://apt.kubernetes.io/ kubernetes-xenial main
# EOF

# apt-get update
# apt-get install -y kubelet kubeadm kubectl
# apt-mark hold kubelet kubeadm kubectl

# kubelet requires swap off
swapoff -a

# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# ip of this box
## UBUNTU
#IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`
# CENTOS
IP_ADDR=`ifconfig eth1 | grep netmask | awk '{print $2}'| cut -f2 -d:`

# set node-ip

## UBUNTU
# sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet

# CENTOS
sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/sysconfig/kubelet

systemctl enable kubelet.service
# sudo systemctl restart kubelet

# Copy registry certificates
sudo mkdir -p /etc/docker/certs.d/192.168.205.9:5000/
sudo cp -v /vagrant/certs/domain.crt /etc/docker/certs.d/192.168.205.9:5000/ca.crt