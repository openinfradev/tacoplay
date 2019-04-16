#!/bin/bash
#set -x
MANIFESTS=$1
if [ "x$MANIFESTS" == "x" ]; then
  echo "Usage: ./load-images.sh <ARMADA MANIFEST>"
  exit -1
fi

IMAGE_PATH=${1/images_list/images}
OLD_REGISTRY=registry.cicd.stg.taco/pike/
NEW_REGISTRY=tacorepo:5000

for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  depth=$(echo $IMAGE | sed 's/[^/]//g' | awk '{print length}')
  if [ $depth -eq 2 ]; then
    IMAGE_NAME=`echo $IMAGE | cut -d'/' -f3`
  elif [ $depth -eq 1 ]; then
    IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2`
  elif [ $depth -eq 0 ]; then
    IMAGE_NAME=`echo $IMAGE`
  fi

  IMAGE_FILE=${IMAGE_NAME/$OLD_REGISTRY/}.tar
  echo $IMAGE_PATH/$IMAGE_FILE
  docker load -i $IMAGE_PATH/$IMAGE_FILE
done
