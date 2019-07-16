# Kubernetes system

took ispiration from: [link](https://kubernetes.io/blog/2019/03/15/kubernetes-setup-using-ansible-and-vagrant/)

## How to see dashboard

```shell
yarn ssh

# once inside master
kubectl proxy --address 0.0.0.0 --accept-hosts .*

# then navigate to http://127.0.0.1:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

## how to get token

[link](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)
[link](https://github.com/kubernetes/dashboard/wiki/Access-control#login-view)

```shell
yarn ssh

kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
```

## how to login to registry

```shell
docker login localhost:5000 --username admin --password 111999888
```
