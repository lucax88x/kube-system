#!/bin/bash

echo 'Configuring kube single box (master / node)'

# install kubeadm

dnf install -y wget
dnf install -y net-tools

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

dnf install -y kubelet kubeadm kubectl

# kubelet requires swap off
swapoff -a

# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

IP_ADDR=`ifconfig eth1 | grep netmask | awk '{print $2}'| cut -f2 -d:`

# set node-ip
sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/sysconfig/kubelet

systemctl enable kubelet.service
# sudo systemctl restart kubelet

# Install NFS drivers
dnf -y install nfs-utils

echo 'Configured kube single box (master / node)'
