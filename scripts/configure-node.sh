#!/bin/bash

echo 'Configuring node'

# https://github.com/kubernetes/kubeadm/issues/312
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# open ports for kubeadm
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --add-masquerade --permanent

firewall-cmd --reload
systemctl restart firewalld

# install sshpass
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
dnf -y install sshpass

sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
sh ./kubeadm_join_cmd.sh