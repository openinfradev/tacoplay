#!/bin/bash
#set -x
MANIFESTS=$1
if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./pull-images.sh <ARMADA MANIFEST>"
  exit -1
fi

REPO=registry.cicd.stg.taco
for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  echo $IMAGE
  if [[ $IMAGE = *$REPO* ]]; then
    sudo docker inspect $IMAGE > /dev/null || sudo docker pull $IMAGE
  fi
done
