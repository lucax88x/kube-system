
            box.vm.provision "shell", :path => "scripts/install-dnf.sh"
            box.vm.provision "shell", :path => "scripts/install-docker.sh"
            box.vm.provision "shell", :path => "scripts/configure-kube.sh"
