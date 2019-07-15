#!/bin/bash
#set -x
MANIFESTS=$1
if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./pull-images.sh <ARMADA MANIFEST>"
  exit -1
fi

MANIFEST_REPO=$(grep "nova_compute:" $MANIFESTS | head -1 | awk '{print $2}' | awk -F "/" '/1/ {print $1}')
CICD_REPO=registry-rel.cicd.stg.taco
for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
	NEW_IMAGE=$(sed "s/$MANIFEST_REPO/$CICD_REPO/g" <<< $IMAGE)
	echo $NEW_IMAGE
  docker inspect $NEW_IMAGE > /dev/null 2>&1 || docker pull $NEW_IMAGE
done
