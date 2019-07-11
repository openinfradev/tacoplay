#!/bin/bash
#set -x


#yum install -y yum-utils \
#  device-mapper-persistent-data \
#  lvm2

#yum-config-manager \
#    --add-repo \
#    https://download.docker.com/linux/centos/docker-ce.repo

#yum install docker-ce-18.09.1 docker-ce-cli-18.09.1 containerd.io -y

#systemctl start docker

MANIFESTS=$1
if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./pull-images.sh <ARMADA MANIFEST>"
  exit -1
fi

for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  docker inspect $IMAGE > /dev/null || docker pull $IMAGE
done
