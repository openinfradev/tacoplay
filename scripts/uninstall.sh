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

for qemu in $(ps aux | grep qemu-system | grep -v grep | awk '{print $2}'); do kill $qemu; done
if [ -e /etc/ceph/ceph.conf ]
then
  for pool in $(sudo rados lspools)
  do
    for vol in $(sudo rbd ls -p $pool)
    do
      if [ "$pool" == "images" ]
      then
        sudo rbd snap unprotect -p images $vol@snap
        sudo rbd snap purge -p images $vol
      fi
      sudo rbd rm -p $pool $vol
    done
  done
fi

cd /var/lib
rm -rf nova neutron libvirt openstack-helm
cd ~/
