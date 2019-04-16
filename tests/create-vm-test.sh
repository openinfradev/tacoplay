#!/bin/bash

export LC_ALL="en_US.UTF-8"
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=password
export OS_AUTH_URL=http://keystone.openstack.svc.cluster.local:80/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

IMAGE=$(openstack image show 'Cirros-0.4.0' | grep id | awk '{print $4}')
FLAVOR=$(openstack flavor list | grep m1.tiny | awk '{print $2}')
NETWORK=$(openstack network list | grep public-net  | awk '{print $2}')

for COMPUTE_HOST in $(openstack compute service list | grep nova-compute | awk '{ print $6 }'); do
  echo "Creating virtual machine..."
  openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test-$COMPUTE_HOST --availability-zone nova::$COMPUTE_HOST  --wait
  echo "Done"
done
