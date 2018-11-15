#!/bin/bash

CHARTS=$(helm list -q --namespace openstack)
for i in "${CHARTS}"
do
  helm delete --purge $i --no-hooks
done

PVCS=$(kubectl get pvc -n openstack -o jsonpath='{.items..metadata.name}')
for i in "${PVCS}"
do
  kubectl delete pvc $i -n openstack --ignore-not-found=true
done
