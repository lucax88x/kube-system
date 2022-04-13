# Kubernetes system

## LOCAL Development

### requisites

you need to install vagrant CLI
you need to intsall ansible CLI
--add 192.168.56.10 local.k8s to /etc/hosts


```shell
yarn ansible:install

pip3 install ipython netaddr
```

### flow

```shell
yarn up
yarn vagrant:provision
yarn provision:dev
```

### copy k8s-config to local

```shell
yarn vagrant:k8s:copy-config
```

### how to add user to registry
docker run --entrypoint htpasswd httpd:2 -Bbn desiredUser desiredPassword | openssl base64
then copy to docker registry secrety
