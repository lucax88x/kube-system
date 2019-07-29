#!/bin/bash

# copy configuration
mkdir -p certs
cp -v /vagrant/certs/domain.crt certs/domain.crt
cp -v /vagrant/certs/domain.key certs/domain.key

# create user
mkdir -p auth
docker run --entrypoint htpasswd registry:2 -Bbn admin 111999888 > auth/htpasswd

# start registry
docker run -d \
-p 5000:5000 \
--restart=always \
--name registry \
-v "$(pwd)"/auth:/auth \
-v "$(pwd)"/certs:/certs \
-e "REGISTRY_AUTH=htpasswd" \
-e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
-e "REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd" \
-e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt" \
-e "REGISTRY_HTTP_TLS_KEY=/certs/domain.key" \
registry:2

# copy configuration
sudo cp -v /vagrant/configurations/registry/docker /etc/default/docker

sudo service docker restart