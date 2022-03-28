# -*- mode: ruby -*-
# vi: set ft=ruby :

K8S_MASTER_IMAGE_NAME = "rockylinux/8"
K8S_NODE_IMAGE_NAME = "rockylinux/8"
NFS_DISK_SIZE = 100 #gb

PUBLIC_DOMAIN = "local.k8s"

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => K8S_MASTER_IMAGE_NAME,
        :eth1 => "192.168.56.10",
        :mem => "4096",
        :cpu => "4"
    },
    # {
    #     :name => "k8s-node-1",
    #     :type => "node",
    #     :box => K8S_NODE_IMAGE_NAME,
    #     :eth1 => "192.168.56.11",
    #     :mem => "4096",
    #     :cpu => "4"
    # },
    # {
    #     :name => "k8s-node-2",
    #     :type => "node",
    #     :box => K8S_NODE_IMAGE_NAME,
    #     :eth1 => "192.168.56.12",
    #     :mem => "4096",
    #     :cpu => "4"
    # }
]

IS_SINGLE_NODE = servers.length() == 1 ? "true" : "false"

Vagrant.configure("2") do |config|

    config.vm.synced_folder '.', '/vagrant',
 
    type: 'rsync',
    rsync__exclude: [
      '.git', 'node_modules*',
      '*.log', '*.vdi'
    ]

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

            if opts[:type] == "master"
                box.vm.provider "virtualbox" do |vb|
                    unless File.exist?("nfs-disk-0.vdi")
                        vb.customize [ "storagectl", :id,"--name", "VboxSata", "--add", "sata" ]
                        vb.customize [ "createmedium", "--filename", "nfs-disk-0.vdi", "--size", 1024 * NFS_DISK_SIZE ]
                        vb.customize [ "storageattach", :id, "--storagectl", "VboxSata", "--port", 3, "--device", 0, "--type", "hdd", "--medium", "nfs-disk-0.vdi" ]
                    end
                end

                box.vm.network "forwarded_port", guest: 6443, host: 6443

                box.vm.provision "shell" do |s|
                    s.path = "scripts/install-master.sh"
                    s.args   = ["true", IS_SINGLE_NODE, opts[:eth1], PUBLIC_DOMAIN]
                end

            else
                box.vm.provision "shell" do |s|
                    s.path = "scripts/install-node.sh"
                    s.args   = ["true", opts[:eth1]]
                end
            end
        end
    end
end
