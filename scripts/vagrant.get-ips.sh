#!/bin/bash

# wget https://download.virtualbox.org/virtualbox/6.0.8/Oracle_VM_VirtualBox_Extension_Pack-6.0.8.vbox-extpack
# VBoxManage extpack install ./Oracle_VM_VirtualBox_Extension_Pack-6.0.8.vbox-extpack

for f in $(VBoxManage list runningvms | awk -F\" '{print $2}'); do
    echo "$f:"
    VBoxManage guestproperty enumerate "$f" | grep IP
done