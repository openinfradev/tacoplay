#!/bin/bash
#set -x
MANIFESTS=$1

if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./pull-images.sh <ARMADA MANIFEST>"
  exit -1
fi
#for armada-manifest
for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  echo 'docker inspect $IMAGE > /dev/null 2>&1 || docker pull $IMAGE'
  docker inspect $IMAGE > /dev/null 2>&1 || docker pull $IMAGE
done

#for helm release
for IMAGE in $(cat $MANIFESTS | yq '.spec.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  echo 'docker inspect $IMAGE > /dev/null 2>&1 || docker pull $IMAGE'
  docker inspect $IMAGE > /dev/null 2>&1 || docker pull $IMAGE
done
