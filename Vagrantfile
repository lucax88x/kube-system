# -*- mode: ruby -*-
# vi: set ft=ruby :

STORAGE_IMAGE_NAME = "rockylinux/8"
K8S_MASTER_IMAGE_NAME = "rockylinux/8"
K8S_NODE_IMAGE_NAME = "rockylinux/8"

PUBLIC_DOMAIN = "local.k8s"

servers = [
    {
        :name => "k8s-master",
        :type => "master",
        :box => K8S_MASTER_IMAGE_NAME,
        :eth1 => "192.168.56.11",
        :mem => "4096",
        :cpu => "4"
    },
    {
        :name => "k8s-node-1",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :eth1 => "192.168.56.12",
        :mem => "4096",
        :cpu => "4"
    },
    {
        :name => "k8s-node-2",
        :type => "node",
        :box => K8S_NODE_IMAGE_NAME,
        :eth1 => "192.168.56.13",
        :mem => "4096",
        :cpu => "4"
    }
]

IS_SINGLE_NODE = servers.length() == 1 ? "true" : "false"

Vagrant.configure("2") do |config|
  # libvirt has network issues
  # config.vagrant.plugins = ["vagrant-libvirt"]

 #    config.vm.synced_folder '.', '/vagrant',
 # 
 #    type: 'rsync',
 #    rsync__exclude: [
 #      '.git', 'node_modules*',
 #      '*.log', '*.vdi'
 #    ]

    (1..servers.length).each do |machine_id|
        opts = servers[machine_id - 1]
        config.vm.define opts[:name] do |box|
            box.vm.box = opts[:box]

            box.vm.box_version = opts[:box_version]
            box.vm.hostname = opts[:name]
            box.vm.network :private_network, ip: opts[:eth1]
            
            # to provision raw disks for ceph
            # box.vm.disk :disk, size: "10GB", name: "osd"

            box.vm.provider "libvirt" do |libvirt|
                libvirt.memory = opts[:mem]
                libvirt.cpus = opts[:cpu]
            end

            box.vm.provider "virtualbox" do |vb|

                vb.check_guest_additions = false
                vb.functional_vboxsf     = false

                vb.name = opts[:name]
                vb.customize ["modifyvm", :id, "--memory", opts[:mem]]
                vb.customize ["modifyvm", :id, "--cpus", opts[:cpu]]
            end

            if machine_id == servers.length 
                config.vm.provision "ansible" do |ansible|
                  # ansible.verbose = "v"
                  ansible.limit = "all"
                  ansible.playbook = "playbooks/none.yml"
                  ansible.host_key_checking = false
                  ansible.extra_vars = {
                    env: "dev",
                    server_network_adapter: "eth1",
                    metallb_ip_pool: "192.168.56.50-192.168.56.51",
                  }
                end
            end
        end
    end
end
