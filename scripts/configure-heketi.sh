#!/bin/bash

echo 'Configuring heketi on single box (master / node)'

# install heketi

# CENTOS
yum-config-manager --add-repo https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
yum install -y epel-release
yum install -y centos-release-gluster

yum install -y heketi-client glusterfs-client

## UBUNTU

# TODO: INSTALL HEKETI & GLUSTERFS


modprobe dm_thin_pool