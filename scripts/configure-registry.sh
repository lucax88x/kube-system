#!/bin/bash

echo 'Configuring registry'

# copy configuration
mkdir -p certs

# domains contains both certificates in one!
cp -v /vagrant/configuration/certs/domains.crt certs/domains.crt
cp -v /vagrant/configuration/certs/domains.key certs/domains.key

# create user
mkdir -p auth
# TODO: strong password
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
-e "REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domains.crt" \
-e "REGISTRY_HTTP_TLS_KEY=/certs/domains.key" \
registry:2

service docker restart