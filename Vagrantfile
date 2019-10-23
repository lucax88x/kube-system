# -*- mode: ruby -*-
# vi: set ft=ruby :

K8S_MASTER_IMAGE_NAME = "generic/centos7"
K8S_NODE_IMAGE_NAME = "generic/centos7"

NFS_SERVER_IMAGE_NAME = "generic/centos7"
NFS_SERVER_IP = "192.168.205.8"
NFS_DISK_SIZE = 20 #GB

K8S_API_SERVER_SANS = "192.168.205.10,62.2.176.66"

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => K8S_MASTER_IMAGE_NAME,
        :eth1 => "192.168.205.10",
        :mem => "4096",
        :cpu => "4"
    },
    {
        :index => "0",
        :name => "k8s-node-1",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :eth1 => "192.168.205.11",
        :mem => "4096",
        :cpu => "4"
    },
    # {
    #     :index => "1",
    #     :name => "k8s-node-2",
    #     :type => "node",
    #     :box => K8S_NODE_IMAGE_NAME,
    #     :eth1 => "192.168.205.12",
    #     :mem => "3072",
    #     :cpu => "2"
    # }
]

Vagrant.configure("2") do |config|

    config.vm.synced_folder '.', '/vagrant',
    type: 'rsync',
    rsync__exclude: [
      '.git', 'node_modules*',
      '*.log', '*.vdi'
    ]

    config.vm.define "nfs-server" do |nfsServer|
        nfsServer.vm.box = NFS_SERVER_IMAGE_NAME

        nfsServer.vm.hostname = "nfs-server"

        nfsServer.vm.network :private_network, ip: NFS_SERVER_IP

        nfsServer.vm.provider "virtualbox" do |vb|
            vb.check_guest_additions = false
            vb.functional_vboxsf     = false
            vb.name = "nfs-server"
            vb.customize ["modifyvm", :id, "--memory", "2048"]
            vb.customize ["modifyvm", :id, "--cpus", "2"]

            
            unless File.exist?("nfs-disk-0.vdi")
                vb.customize ["storagectl", :id,"--name", "VboxSata", "--add", "sata"]
                vb.customize [ "createmedium", "--filename", "nfs-disk-0.vdi", "--size", 1024 * NFS_DISK_SIZE ]
                vb.customize [ "storageattach", :id, "--storagectl", "VboxSata", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "nfs-disk-0.vdi" ]
            end
        end

        nfsServer.vm.provision "shell", :path => "scripts/install-dnf.sh"
        nfsServer.vm.provision "shell", :path => "scripts/create-nfs-server.sh"
    end

    servers.each do |opts|
        config.vm.define opts[:name] do |box|
            box.vm.box = opts[:box]

            box.vm.box_version = opts[:box_version]
            box.vm.hostname = opts[:name]
            box.vm.network :private_network, ip: opts[:eth1]

            box.vm.provider "virtualbox" do |vb|

                vb.check_guest_additions = false
                vb.functional_vboxsf     = false
                
                vb.name = opts[:name]
                vb.customize ["modifyvm", :id, "--memory", opts[:mem]]
                vb.customize ["modifyvm", :id, "--cpus", opts[:cpu]]

            end

            
            box.vm.provision "shell", :path => "scripts/install-dnf.sh"
            box.vm.provision "shell", :path => "scripts/install-docker.sh"
            box.vm.provision "shell", :path => "scripts/configure-kube.sh"

            if opts[:type] == "master"
                box.vm.network "forwarded_port", guest: 6443, host: 6443
                box.vm.provision "shell" do |s|
                    s.path = "scripts/configure-master.sh"
                    s.args   = [K8S_API_SERVER_SANS]
                end
                box.vm.provision "install-yamls", type: "shell", :path => "scripts/install-yamls.sh"
            else
                box.vm.provision "shell", :path => "scripts/configure-node.sh"
            end
        end
    end
end 