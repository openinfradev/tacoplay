#!/bin/bash
#set -x
NEW_REGISTRY="tacorepo:5000"

#function tagandpush {
#    IMAGE=$1
#    IMAGE_NAME=$2
#    sudo docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
#    sudo docker push $NEW_REGISTRY/$IMAGE_NAME
#}

if [ $# == 0 ]; then
  for IMAGE in $(docker images | grep ago | awk '{ print $1":"$2 }'); do
    IMAGE_NS=`echo $IMAGE | cut -d'/' -f1`
    if [ "$IMAGE_NS" == "calico" ] \
      || [ "$IMAGE_NS" == "cilium" ] \
      || [ "$IMAGE_NS" == "cloudnativelabs" ] \
      || [ "$IMAGE_NS" == "contiv" ] \
      || [ "$IMAGE_NS" == "coredns" ] \
      || [ "$IMAGE_NS" == "ferest" ] \
      || [ "$IMAGE_NS" == "lachlanevenson" ] \
      || [ "$IMAGE_NS" == "library" ] \
      || [ "$IMAGE_NS" == "nfvpe" ] \
      || [ "$IMAGE_NS" == "rancher" ] \
      || [ "$IMAGE_NS" == "weaveworks" ] \
      || [ "$IMAGE_NS" == "xueshanf" ]; then
      echo "preserving image name as it is."
      IMAGE_NAME=`echo $IMAGE`
    else
      depth=$(echo $IMAGE | sed 's/[^/]//g' | awk '{print length}')
      if [ $depth -eq 2 ]; then
         IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2,3`
      elif [ $depth -eq 1 ]; then
         IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2`
      elif [ $depth -eq 0 ]; then
         IMAGE_NAME=`echo $IMAGE`
      fi
    fi
    echo "*** command:" docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
    docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
  done
fi

if [ $# == 1 ]; then
  MANIFESTS=$1
  for IMAGE in $(cat $MANIFESTS | yq '.data.values.images.tags | map(.) | join(" ")' | tr -d '"'); do
    depth=$(echo $IMAGE | sed 's/[^/]//g' | awk '{print length}')
    if [ $depth -eq 2 ]; then
      IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2,3`
    elif [ $depth -eq 1 ]; then
      IMAGE_NAME=`echo $IMAGE | cut -d'/' -f2`
    elif [ $depth -eq 0 ]; then
      IMAGE_NAME=`echo $IMAGE`
    fi
    echo "*** command:" docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
    docker tag $IMAGE "$NEW_REGISTRY/$IMAGE_NAME"
  done
fi
