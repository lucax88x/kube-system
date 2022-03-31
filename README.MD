# Kubernetes system

took ispiration from: [link](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/)

## LOCAL Development

### requisites

you need to install vagrant CLI
you need to intsall ansible CLI
add 192.168.56.10 local.k8s to /etc/hosts


```shell
yarn ansible:install

pip3 install ipython netaddr
pip3 install kubernetes
```

### create the servers

```shell
yarn start
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

### how to add user to registry
docker run --rm marcnuri/htpasswd -Bbn desiredUser desiredPassword | base64 -w 0 | xargs -I #0 kubectl patch secret registry -n registry --patch '{"data": { "HTPASSWD": "#0"}}'
