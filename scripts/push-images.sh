#!/bin/bash
#set -x
REGISTRY="tacorepo.cicd:5000"

echo "* registry:" $OLD_REGISTRY
for IMAGE in $(docker images | grep $REGISTRY | awk '{ print $1":"$2 }'); do
    echo "*** command:" docker push $IMAGE
    docker push $IMAGE
done
