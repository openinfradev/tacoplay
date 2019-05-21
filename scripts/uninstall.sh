#!/bin/bash

CHARTS=$(helm list --all -q --namespace openstack)
for i in "${CHARTS}"
do
  helm delete --purge $i --no-hooks
done

kubectl delete pvc --all -n openstack --force --grace-period=0
kubectl delete configmap --all -n openstack --force --grace-period=0
kubectl delete secret --all -n openstack --force --grace-period=0
kubectl delete pods --all -n openstack --force --grace-period=0
