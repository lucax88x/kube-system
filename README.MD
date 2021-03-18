# Kubernetes system

took ispiration from: [link](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/)

## PROD Environment

Vagrant and stuffs like this are in order to simulate a K8s cluster locally, usually you would install master & nodes in separate servers by using the install scripts in the scripts folder

## LOCAL Development

### prerequisited

you need to install vagrant CLI
add 192.168.205.10 local.k8s to /etc/hosts

### create the servers

```shell
yarn up
```

### copy k8s-config to local

```shell
yarn local:k8s:copy-config
```

### how to see dashboard

```shell
yarn k8s:start-dashboard
```

then navigate to http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

### how to get token

[link](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)
[link](https://github.com/kubernetes/dashboard/wiki/Access-control#login-view)

```shell
yarn k8s:token
```

### how to regenerate certificates for registry

```shell
vagrant ssh docker-registry

sudo sed -i 's/\[ v3_ca \]/\[ v3_ca \]\nsubjectAltName = IP: 192.168.205.9/g' /etc/ssl/openssl.cnf

openssl req -config /etc/ssl/openssl.cnf -newkey rsa:4096 -nodes -sha256 -keyout domain.key -x509 -days 3650 -out domain.crt
```

Important: input the docker registry IP as FQDN

Then copy back the certificates from docker-registry to this repository, and recreate all the VM's or manually copy them to all hosts

If you want to try to login from your machine, remember to copy certificates.

```shell
sudo cp certs/domain.crt /etc/docker/certs.d/192.168.205.9:5000/ca.cert
sudo cp certs/domain.key /etc/docker/certs.d/192.168.205.9:5000/ca.key
```
