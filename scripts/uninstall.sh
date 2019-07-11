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

rbd -p images snap unprotect --image 201084fc-c276-4744-8504-cb974dbb3610 --snap snap
rbd snap purge 201084fc-c276-4744-8504-cb974dbb3610 -p images
rbd -p images rm 201084fc-c276-4744-8504-cb974dbb3610

cd /var/lib
rm -rf nova neutron libvirt openstack-helm
cd ~/
