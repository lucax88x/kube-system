
# install Calico pod network addon
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f /vagrant/yaml/kube-system/rbac-kdd.yaml
kubectl apply -f /vagrant/yaml/kube-system/calico.yaml

# install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta5/aio/deploy/recommended.yaml
kubectl apply -f /vagrant/yaml/kube-system/dashboard-adminuser.yaml

# creates metallb
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml
kubectl apply -f /vagrant/yaml/metallb-system/metallb-system.config.yaml

# creates nfs-client
kubectl apply -f /vagrant/yaml/nfs-client/nfs-client.namespace.yaml
kubectl apply -f /vagrant/yaml/nfs-client/nfs-client.rbac.yaml
kubectl apply -f /vagrant/yaml/nfs-client/nfs-client.deployment.yaml
kubectl apply -f /vagrant/yaml/nfs-client/nfs-client.storage-class.yaml

# create nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f /vagrant/yaml/ingress-nginx/ingress-nginx.service.yaml 

# create cert-manager
kubectl create namespace cert-manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml

## install registry
kubectl apply -f /vagrant/yaml/registry/registry.namespace.yaml 
kubectl apply -f /vagrant/yaml/registry/letsencrypt.staging.issuer.yaml 
kubectl apply -f /vagrant/yaml/registry/registry.config.yaml 
kubectl apply -f /vagrant/yaml/registry/registry.secret.yaml 
kubectl apply -f /vagrant/yaml/registry/registry.deployment.yaml 
kubectl apply -f /vagrant/yaml/registry/registry.service.yaml 
kubectl apply -f /vagrant/yaml/registry/registry.ingress.yaml 


