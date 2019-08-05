# -*- mode: ruby -*-
# vi: set ft=ruby :

K8S_MASTER_IMAGE_NAME = "centos/7"
K8S_MASTER_IMAGE_URL = "https://app.vagrantup.com/centos/7"
K8S_NODE_IMAGE_NAME = "centos/7"
K8S_NODE_IMAGE_URL = "https://app.vagrantup.com/centos/7"

REGISTRY_IMAGE_NAME = "centos/7"
REGISTRY_IMAGE_URL = "https://app.vagrantup.com/centos/7"
REGISTRY_IP = "192.168.205.9"

PROXY_IP = "192.168.205.5"
PROXY_IMAGE_NAME = "ubuntu/precise32"

GLUSTER_DISKS = 3

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => K8S_MASTER_IMAGE_NAME,
        :box_url => K8S_MASTER_IMAGE_URL,
        :eth1 => "192.168.205.10",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :index => "0",
        :name => "k8s-node-1",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :box_url => K8S_NODE_IMAGE_URL,
        :eth1 => "192.168.205.11",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :index => "1",
        :name => "k8s-node-2",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :box_url => K8S_NODE_IMAGE_URL,
        :eth1 => "192.168.205.12",
        :mem => "2048",
        :cpu => "2"
    },
    {
        :index => "2",
        :name => "k8s-node-3",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :box_url => K8S_NODE_IMAGE_URL,
        :eth1 => "192.168.205.13",
        :mem => "2048",
        :cpu => "2"
    }
]

Vagrant.configure("2") do |config|

    servers.each do |opts|
        config.vm.define opts[:name] do |box|

            box.vm.box = opts[:box]
            box.vm.box_version = opts[:box_version]
            box.vm.hostname = opts[:name]
            box.vm.network :private_network, ip: opts[:eth1]

            box.vm.provider "virtualbox" do |vb|

                vb.name = opts[:name]
                vb.customize ["modifyvm", :id, "--memory", opts[:mem]]
                vb.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

            end

            box.vm.provision "shell", :path => "scripts/install-docker.sh"
            box.vm.provision "shell", :path => "scripts/configure-heketi.sh"
            box.vm.provision "shell", :path => "scripts/configure-kube.sh"

            if opts[:type] == "master"
                box.vm.network "forwarded_port", guest: 8001, host: 8001
                box.vm.provision "shell", :path => "scripts/configure-master.sh"
            else
                # create Gluster disks
                box.vm.provider :virtualbox do |vb|
                    unless File.exist?("disk-#{opts[:index]}-0.vdi")
                        vb.customize ["storagectl", :id,"--name", "VboxSata", "--add", "sata"]
                    end

                    (0..GLUSTER_DISKS-1).each do |d|
                        unless File.exist?("disk-#{opts[:index]}-#{d}.vdi")
                            vb.customize [ "createmedium", "--filename", "disk-#{opts[:index]}-#{d}.vdi", "--size", 1024*1024 ]
                        end
                        vb.customize [ "storageattach", :id, "--storagectl", "VboxSata", "--port", 3+d, "--device", 0, "--type", "hdd", "--medium", "disk-#{opts[:index]}-#{d}.vdi" ]
                    end
                end

                box.vm.provision "shell", :path => "scripts/configure-node.sh"
            end
        end
    end

    config.vm.define "docker-registry" do |registry|
        registry.vm.box = REGISTRY_IMAGE_NAME
        registry.vm.box_url = REGISTRY_IMAGE_URL
        
        registry.vm.hostname = "docker-registry"

        registry.vm.network :private_network, ip: REGISTRY_IP
        registry.vm.network "forwarded_port", guest: 5000, host: 5000
        registry.vm.network "forwarded_port", guest: 2375, host: 2375


        registry.vm.provider "virtualbox" do |v|
            v.name = "docker-registry"
            v.customize ["modifyvm", :id, "--memory", "2048"]
            v.customize ["modifyvm", :id, "--cpus", "2"]
        end

        registry.vm.provision "shell", :path => "scripts/install-docker.sh"
        registry.vm.provision "shell", :path => "scripts/configure-registry.sh"
    end

config.vm.post_up_message = <<-HEREDOC
    ------------------------------------------------------
    Once your cluster is up, remember to run the following command on k8s-master
    cd /vagrant/configurations/gluster && bash gk-deploy.sh -gy /vagrant/configurations/gluster/topology.json
    ------------------------------------------------------
HEREDOC

    # config.vm.define :haproxy, primary: true do |proxy|  
    #   proxy.vm.box = PROXY_IMAGE_NAME
  
    #   proxy.vm.hostname = 'haproxy'
    #   proxy.vm.network :forwarded_port, guest: 8080, host: 8080
    #   proxy.vm.network :forwarded_port, guest: 80, host: 8081
    #   proxy.vm.network :forwarded_port, guest: 443, host: 443
  
    #   proxy.vm.network :private_network, ip: PROXY_IP
    #   proxy.vm.provision :shell, :path => "scripts/configure-proxy.sh"
    # end

    # config.trigger.after :up do |trigger|
    #     trigger.only_on = 'k8s-master'
    #     trigger.info = "Configuring GlusterFS After all machines have been created"
    #     trigger.run_remote = {path: "configurations/gluster/gk-deploy.sh", args:  ["-gy", "/vagrant/configurations/gluster/topology.json"]}
    # end
end 