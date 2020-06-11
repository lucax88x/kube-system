#!/bin/bash

echo 'Install master'

IS_SINGLE_NODE=${1:-'false'}
API_SERVER_CERT_EXTRA_SANS=${2:-''}

internal/install-dnf.sh
internal/install-docker.sh
internal/configure-kube.sh
internal/create-nfs-server.sh
internal/install-yamls.sh $IS_SINGLE_NODE $API_SERVER_CERT_EXTRA_SANS
