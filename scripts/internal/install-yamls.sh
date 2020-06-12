IS_VAGRANT=${1:-'false'}

if [ "$IS_VAGRANT" = 'true' ] ; then
  cd /vagrant
fi

export KUBECONFIG=/etc/kubernetes/admin.conf

# install Calico pod network addon
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# creates metallb
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
# https://github.com/kubernetes-sigs/kind/issues/1449
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

# remember to configure external IP
kubectl apply -f ./yaml/metallb-system/metallb-system.config.yaml

# install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml
kubectl apply -f ./yaml/kube-system/dashboard-adminuser.yaml

# creates nfs-client
kubectl apply -f ./yaml/nfs-client/nfs-client.namespace.yaml
kubectl apply -f ./yaml/nfs-client/nfs-client.rbac.yaml
kubectl apply -f ./yaml/nfs-client/nfs-client.deployment.yaml
kubectl apply -f ./yaml/nfs-client/nfs-client.storage-class.yaml

## install registry
kubectl apply -f ./yaml/registry/registry.namespace.yaml

kubectl apply -f ./yaml/registry/registry-tls.secret.yaml
kubectl apply -f ./yaml/registry/letsencrypt.job.yaml
kubectl apply -f ./yaml/registry/letsencrypt.service.yaml

kubectl apply -f ./yaml/registry/registry.config.yaml
kubectl apply -f ./yaml/registry/registry.secret.yaml
kubectl apply -f ./yaml/registry/registry.persistent-volume.yaml
kubectl apply -f ./yaml/registry/registry.deployment.yaml
kubectl apply -f ./yaml/registry/registry.service.yaml
kubectl apply -f ./yaml/registry/registry.ingress.yaml

# create nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/deploy.yaml
kubectl apply -f ./yaml/ingress-nginx/ingress-nginx.service.yaml
