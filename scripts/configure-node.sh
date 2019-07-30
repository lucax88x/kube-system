#!/bin/bash

echo "This is worker"

# CENTOS
# https://github.com/kubernetes/kubeadm/issues/312
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# install sshpass
## UBUNTU
#apt-get install -y sshpass

# CENTOS
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
yum -y install sshpass

sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
sh ./kubeadm_join_cmd.sh