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
  # repository name with *.io, *:INTEGER, *.cicd.stg.taco will be replaced to NEW_REGISTRY.
  docker images --format "{{.Repository}}:{{.Tag}} {{.Repository}}:{{.Tag}}" \
	| grep "\/" \
	| sed -e "s/[a-z0-9.-]*\.co\///2" \
	| sed -e "s/[a-z0-9.-]*\.io\///2" \
	| sed -e "s/[a-z0-9.-]*:[0-9]*\///2" \
	| sed -e "s/[a-z0-9.-]*.cicd.stg.taco\///2" \
	| sed -e "s/squareup\///2" \
	| sed -e "s/jettech\///2" \
	| sed -e "s/prom\///2" \
	| sed -e "s/grafana\///2" \
	| sed -e "s/bats\///2" \
	| sed -e "s/curlimages\///2" \
	| sed -e "s/kiwigrid\///2" \
	| sed -e "s/siim\///2" \
	| sed -e "s/directxman12\///2" \
	| sed -e "s/ / $NEW_REGISTRY\//g" \
	| xargs -n2 docker tag $1 $2

  # repository name without slash means it is a docker official image.
	docker images --format "{{.Repository}}:{{.Tag}} {{.Repository}}:{{.Tag}}" \
	| grep -v "\/" \
	| sed -e "s/ / $NEW_REGISTRY\/library\//g" \
	| xargs -n2 docker tag $1 $2
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
