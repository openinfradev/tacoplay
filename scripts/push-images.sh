#!/bin/bash
#set -x
REGISTRY="tacorepo:5000"

echo "* registry:" $OLD_REGISTRY
for IMAGE in $(sudo docker images | grep $REGISTRY | awk '{ print $1":"$2 }'); do
    echo "*** command:" docker push $IMAGE
    sudo docker push $IMAGE
done
