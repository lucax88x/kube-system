
#!/bin/bash

echo 'Install master'

IS_VAGRANT=${1:-'false'}

if [ "$IS_VAGRANT" = 'true' ] ; then
  cd /vagrant
fi

chmod +x ./scripts/internal/*

./scripts/internal/install-dnf.sh
./scripts/internal/install-docker.sh
./scripts/internal/configure-kube.sh
./scripts/internal/configure-node.sh
