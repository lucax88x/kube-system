# https://vitux.com/install-nfs-server-and-client-on-ubuntu/

FOLDER=/srv/node/sdb

# Install NFS Kernel Server
dnf -y install nfs-utils

systemctl enable nfs-server.service
systemctl start nfs-server.service

# Create the Export Directory
mkdir -p ${FOLDER}
chown nobody:nobody ${FOLDER}
chmod 755 ${FOLDER}

# Assign server access to client(s) through NFS export file
echo '/srv/node/sdb 192.168.205.0/24(rw,sync,no_subtree_check)' | tee -a /etc/exports

# Export the shared directory
exportfs -a

systemctl restart nfs-server.service

systemctl start firewalld.service
systemctl enable firewalld.service

# # Open firewall for the client (s)
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --reload