#!/bin/bash
#set -x
MANIFESTS=$1
CICD_REGISTRY=$2
orig_registry_parsed=false

if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./pull-images.sh <ARMADA MANIFEST>"
  exit -1
fi

for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  if (!orig_registry_parsed)
    ORIG_REGISTRY=$((awk '{print $2}' | awk -F "/" '/1/ {print $1}') <<< $IMAGE)
    orig_registry_parsed=true
  fi

	NEW_IMAGE=$(sed "s/$ORIG_REGISTRY/$CICD_REGISTRY/g" <<< $IMAGE)
	echo $NEW_IMAGE
  docker inspect $NEW_IMAGE > /dev/null 2>&1 || docker pull $NEW_IMAGE
done
