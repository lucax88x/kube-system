# -*- mode: ruby -*-
# vi: set ft=ruby :

K8S_IMAGE_NAME = "ubuntu/xenial64" #16.04
REGISTRY_IMAGE_NAME = "ubuntu/bionic64" #18.04
REGISTRY_IP = "192.168.205.9"
PROXY_IP = "192.168.205.5"
PROXY_IMAGE_NAME = "ubuntu/precise32"

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

            config.vm.provision "shell", :path => "scripts/install-docker.sh"
            config.vm.provision "shell", :path => "scripts/configure-box.sh"

            if opts[:type] == "master"
                config.vm.network "forwarded_port", guest: 8001, host: 8001
                config.vm.provision "shell", :path => "scripts/configure-master.sh"
            else
                config.vm.provision "shell", :path => "scripts/configure-node.sh"
            end
        end
    end

    config.vm.define "docker-registry" do |registry|
        registry.vm.box = REGISTRY_IMAGE_NAME
        
        registry.vm.hostname = "docker-registry"

        registry.vm.network :private_network, ip: REGISTRY_IP
        registry.vm.network "forwarded_port", guest: 5000, host: 5000
        registry.vm.network "forwarded_port", guest: 2375, host: 2375


        registry.vm.provider "virtualbox" do |v|
            v.name = "docker-registry"
            v.customize ["modifyvm", :id, "--memory", "2048"]
            v.customize ["modifyvm", :id, "--cpus", "2"]
        end

        config.vm.provision "shell", :path => "scripts/install-docker.sh"
        config.vm.provision "shell", :path => "scripts/configure-registry.sh"
    end

    config.vm.define :haproxy, primary: true do |proxy|  
      proxy.vm.box = PROXY_IMAGE_NAME
  
      proxy.vm.hostname = 'haproxy'
      proxy.vm.network :forwarded_port, guest: 8080, host: 8080
      proxy.vm.network :forwarded_port, guest: 80, host: 8081
      proxy.vm.network :forwarded_port, guest: 443, host: 443
  
      proxy.vm.network :private_network, ip: PROXY_IP
      proxy.vm.provision :shell, :path => "scripts/configure-proxy.sh"
  
    end
end 