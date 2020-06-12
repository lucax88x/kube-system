#!/bin/bash

echo 'Install master'

IS_VAGRANT=${1:-'false'}
IS_SINGLE_NODE=${2:-'false'}

if [ "$IS_VAGRANT" = 'true' ] ; then
  cd /vagrant
fi

chmod +x ./scripts/internal/*

# ./scripts/internal/install-dnf.sh
# ./scripts/internal/install-docker.sh
# ./scripts/internal/configure-kube.sh
# ./scripts/internal/create-nfs-server.sh
# ./scripts/internal/configure-master.sh $IS_VAGRANT $IS_SINGLE_NODE
./scripts/internal/install-yamls.sh $IS_VAGRANT
