#!/bin/bash
#set -x
NEW_REGISTRY="tacorepo:5000"

#function tagandpush {
#    IMAGE=$1
#    IMAGE_NAME=$2
#    sudo docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
#    sudo docker push $NEW_REGISTRY/$IMAGE_NAME
#}

for IMAGE in $(sudo docker images | grep ago | awk '{ print $1":"$2 }'); do
    depth=$(echo $IMAGE | sed 's/[^/]//g' | awk '{print length}')
    if [ $depth -eq 2 ]; then
         IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2,3`
         echo "*** command:"  docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
    elif [ $depth -eq 1 ]; then
         IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2`
         echo "*** command:"  docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
    elif [ $depth -eq 0 ]; then
         IMAGE_NAME=`echo $IMAGE`
         echo "*** command:"  docker tag $IMAGE "$NEW_REGISTRY/$IMAGE"
    fi
    #tagandpush $IMAGE $IMAGE_NAME
    echo "*** command:" docker tag "$NEW_REGISTRY/$IMAGE_NAME"
    sudo docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
done
