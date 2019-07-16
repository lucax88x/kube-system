# -*- mode: ruby -*-
# vi: set ft=ruby :

K8S_IMAGE_NAME = "ubuntu/xenial64"
REGISTRY_IMAGE_NAME = "phusion/ubuntu-14.04-amd64"

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => K8S_IMAGE_NAME,
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => K8S_IMAGE_NAME,
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.11",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => K8S_IMAGE_NAME,
        :box_version => "20180831.0.0",
        :eth1 => "192.168.205.12",
        :mem => "2048",
        :cpu => "2"
    }
]

# This script to install k8s using kubeadm will get executed after a box is provisioned
$configureBox = <<-SCRIPT

    # install docker v17.03
    # reason for not using docker provision is that it always installs latest version of the docker, but kubeadm requires 17.03 or older
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
    apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

    # run docker commands as vagrant user (sudo not required)
    usermod -aG docker vagrant

    # install kubeadm
    apt-get install -y apt-transport-https curl
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
    deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    # kubelet requires swap off
    swapoff -a

    # keep swap off after reboot
    sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

    # ip of this box
    IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`
    # set node-ip
    sudo sed -i "/^[^#]*KUBELET_EXTRA_ARGS=/c\KUBELET_EXTRA_ARGS=--node-ip=$IP_ADDR" /etc/default/kubelet
    sudo systemctl restart kubelet
SCRIPT

$configureMaster = <<-SCRIPT
    echo "This is master"
    # ip of this box
    IP_ADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:`

    # create temp folder
    mkdir -p /home/temp

    # install k8s master
    HOST_NAME=$(hostname -s)
    kubeadm init --apiserver-advertise-address=$IP_ADDR --apiserver-cert-extra-sans=$IP_ADDR  --node-name $HOST_NAME --pod-network-cidr=172.16.0.0/16

    #copying credentials to regular user - vagrant
    sudo --user=vagrant mkdir -p /home/vagrant/.kube
    cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
    chown $(id -u vagrant):$(id -g vagrant) /home/vagrant/.kube/config

    # install Calico pod network addon
    export KUBECONFIG=/etc/kubernetes/admin.conf
    kubectl apply -f https://raw.githubusercontent.com/ecomm-integration-ballerina/kubernetes-cluster/master/calico/rbac-kdd.yaml
    kubectl apply -f https://raw.githubusercontent.com/ecomm-integration-ballerina/kubernetes-cluster/master/calico/calico.yaml

    # install dashboard
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml

    # enables dashboard
    # kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
    sudo cp -v /vagrant/dashboard-adminuser.yaml /home/temp
    kubectl apply -f /home/temp/dashboard-adminuser.yaml

    kubeadm token create --print-join-command >> /etc/kubeadm_join_cmd.sh
    chmod +x /etc/kubeadm_join_cmd.sh

    # required for setting up password less ssh between guest VMs
    sudo sed -i "/^[^#]*PasswordAuthentication[[:space:]]no/c\PasswordAuthentication yes" /etc/ssh/sshd_config
    sudo service sshd restart

SCRIPT

$configureNode = <<-SCRIPT
    echo "This is worker"
    apt-get install -y sshpass
    sshpass -p "vagrant" scp -o StrictHostKeyChecking=no vagrant@192.168.205.10:/etc/kubeadm_join_cmd.sh .
    sh ./kubeadm_join_cmd.sh
SCRIPT

Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |config|

            config.vm.box = opts[:box]
            config.vm.box_version = opts[:box_version]
            config.vm.hostname = opts[:name]
            config.vm.network :private_network, ip: opts[:eth1]

            config.vm.provider "virtualbox" do |v|

                v.name = opts[:name]
                v.customize ["modifyvm", :id, "--memory", opts[:mem]]
                v.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

            end

            # we cannot use this because we can't install the docker version we want - https://github.com/hashicorp/vagrant/issues/4871
            #config.vm.provision "docker"

            config.vm.provision "shell", inline: $configureBox

            if opts[:type] == "master"
                config.vm.network "forwarded_port", guest: 8001, host: 8001
                config.vm.provision "shell", inline: $configureMaster
            else
                config.vm.provision "shell", inline: $configureNode
            end

        end

    end

    # config.vm.define "docker-registry" do |registry|
    #     registry.vm.box = REGISTRY_IMAGE_NAME
        
    #     registry.vm.hostname = "docker-registry"

    #     registry.vm.network "forwarded_port", guest: 5000, host: 5000
    #     registry.vm.network "forwarded_port", guest: 9090, host: 9090
    #     registry.vm.network "forwarded_port", guest: 2375, host: 2375
    #     registry.vm.network "private_network", ip: "84.84.87.88"


        # registry.vm.provider "virtualbox" do |v|

        #     v.name = opts[:name]
        #     v.customize ["modifyvm", :id, "--memory", "2048"]
        #     v.customize ["modifyvm", :id, "--cpus", "2"]

        # end
    #     # install docker, run registry container.
    #     registry.vm.provision "docker" do |d|
    #         # start registry
    #         d.run "registry:2",
    #         restart: "always",
    #         daemonize: true,
    #         auto_assign_name: false,
    #         args: "-p '5000:5000' --name 'registry'"
    #         # start registry UI
    #         d.run "konradkleine/docker-registry-frontend:v2",
    #         daemonize: true,
    #         restart: "always",
    #         auto_assign_name: false,
    #         args: "-p 9090:80 --name 'registry-frontend' -e ENV_DOCKER_REGISTRY_HOST=84.84.87.88 -e ENV_DOCKER_REGISTRY_PORT=5000"
    #     end

    #     # write docker service configuration
    #     config.vm.provision :shell,
    #         inline: "sudo cp -v /vagrant/docker_service /etc/default/docker \
    #         && sudo service docker restart"
    # end

end 