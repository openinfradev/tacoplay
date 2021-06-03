#!/bin/bash

set -x

if [[ $# -ne 8 ]]; then
	echo "Usage: $0 --helm-repo <helm-repo hostname or IP address> --inventory <Inventory directory has *-manifest.yaml> --decapod_flow_dir <decapod flow dir>"
	exit 1
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --helm-repo) helm_repo="$2"; shift ;;
	--image-registry) image_registry="$2"; shift ;;
        --inventory) target_inventory="$2"; shift ;;
        --decapod_flow_dir) decapod_flow_dir="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

for file in $(ls $target_inventory/*-manifest.yaml); do
	NAME=$(echo $file | sed -E 's/.*\/(.*)-manifest.yaml/\1/')

	sed -i "s/LOCAL_HELM_REPO/http:\/\/${helm_repo}:8879\/charts/g" $file
	sed -i "s/LOCAL_REGISTRY/${image_registry}:5000/g" $file
	echo "========== Updating argo/$NAME configmap from $file"
	kubectl create configmap -n argo "$NAME" --from-file=$file --dry-run=client -oyaml | kubectl apply -f-
done


for file in $(ls $decapod_flow_dir/templates/helm-operator/*-wftpl.yaml); do
	sed -i "s/LOCAL_REGISTRY/${image_registry}:5000/g" $file
done
