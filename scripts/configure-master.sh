#!/bin/bash

echo 'Configuring master'

IS_SINGLE_NODE=${1:-'false'}
API_SERVER_CERT_EXTRA_SANS=${2:-''}

# ip of this box
IP_ADDR=`ifconfig eth1 | grep netmask | awk '{print $2}'| cut -f2 -d:`

# install k8s master
HOST_NAME=$(hostname -s)

# open ports for kubeadm
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --add-masquerade --permanent
# only if you want NodePorts exposed on control plane IP as well
# firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --reload
systemctl restart firewalld

# https://github.com/kubernetes/kubeadm/issues/312
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$API_SERVER_CERT_EXTRA_SANS  --node-name $HOST_NAME --pod-network-cidr=172.16.0.0/16

#copying credentials to regular user - vagrant
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

if [ "$IS_SINGLE_NODE" = 'true' ] ; then
    echo 'Configuring master as single-node (waiting 1 minute before proceeding)'

    sleep 1m
    #https://medium.com/@kstaykov/kubernetes-taint-what-is-it-and-how-to-work-with-it-962ffa22eb65
    kubectl taint nodes --all node-role.kubernetes.io/master-
else
    echo 'Configuring master as multi-node'

    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh
fi

# required for setting up password less ssh between guest VMs
sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
sudo service sshd restart