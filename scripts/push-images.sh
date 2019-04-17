#!/bin/bash
#set -x
REGISTRY="tacorepo:5000"
if [ $# == 0 ]; then
  for IMAGE in $(docker images | grep $REGISTRY | awk '{ print $1":"$2 }'); do
      echo "*** command:" docker push $IMAGE
      docker push $IMAGE
  done
fi

if [ $# == 1 ]; then
  OLD_REGISTRY="registry.cicd.stg.taco"
  MANIFESTS=$1

  for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
  IMAGE=${IMAGE/$OLD_REGISTRY/$REGISTRY}
      echo "*** command:" docker push $IMAGE
      docker push $IMAGE
  done
fi
