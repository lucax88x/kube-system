IS_VAGRANT=${1:-'false'}
export NODE_IP=${2}
export PUBLIC_DOMAIN=${3}

if [ "$IS_VAGRANT" = 'true' ] ; then
  cd /vagrant
fi

if [ "$NODE_IP" = "" ]; then
  echo NODE_IP is empty
  exit
fi

if [ "$PUBLIC_DOMAIN" = "" ]; then
  echo PUBLIC_DOMAIN is empty
  exit
fi

## if you run from your pc, you can comment this one
export KUBECONFIG=/etc/kubernetes/admin.conf

echo install Calico pod network addon
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

echo creates metallb
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.5/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.5/manifests/metallb.yaml
# https://github.com/kubernetes-sigs/kind/issues/1449
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
envsubst '$NODE_IP' < ./yaml/metallb-system/metallb-system.config.yaml | kubectl apply -f - 

echo install dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
kubectl apply -f ./yaml/kube-system/dashboard-adminuser.yaml

echo creates nfs-client
kubectl apply -f ./yaml/nfs-client/nfs-client.namespace.yaml
kubectl apply -f ./yaml/nfs-client/nfs-client.rbac.yaml
envsubst '$NODE_IP' < ./yaml/nfs-client/nfs-client.deployment.yaml | kubectl apply -f - 

kubectl apply -f ./yaml/nfs-client/nfs-client.storage-class.yaml

echo create nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
kubectl patch deployment \
  ingress-nginx-controller \
  --namespace ingress-nginx \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
    /nginx-ingress-controller,
    --election-id=ingress-controller-leader,
    --ingress-class=nginx,
    --configmap=$(POD_NAMESPACE)/ingress-nginx-controller,
    --tcp-services-configmap=$(POD_NAMESPACE)/tcp-services,
    --udp-services-configmap=$(POD_NAMESPACE)/udp-services,
    --validating-webhook=:8443,
    --validating-webhook-certificate=/usr/local/certificates/cert,
    --validating-webhook-key=/usr/local/certificates/key
  ]}]'
kubectl apply -f ./yaml/ingress-nginx/ingress-nginx.config.yaml

## install registry
kubectl apply -f ./yaml/registry/registry.namespace.yaml

kubectl apply -f ./yaml/registry/registry-tls.secret.yaml
kubectl apply -f ./yaml/registry/letsencrypt.service.yaml
envsubst '$PUBLIC_DOMAIN' < ./yaml/registry/letsencrypt.job.yaml | kubectl apply -f - 

kubectl apply -f ./yaml/registry/registry.config.yaml
kubectl apply -f ./yaml/registry/registry.secret.yaml
kubectl apply -f ./yaml/registry/registry.persistent-volume.yaml
kubectl apply -f ./yaml/registry/registry.deployment.yaml
kubectl apply -f ./yaml/registry/registry.service.yaml
kubectl apply -f ./yaml/registry/registry.rbac.yaml
envsubst '$PUBLIC_DOMAIN' < ./yaml/registry/registry.ingress.yaml | kubectl apply -f - 


