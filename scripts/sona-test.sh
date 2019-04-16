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

echo "Creating OAM network..."
OAM_NAME_TEMP=$(openstack network list | grep oam-net | awk '{print $4}')
if [ "x${OAM_NAME_TEMP}" != "xoam-net" ]; then
    openstack network create --share --provider-network-type flat --provider-physical-network oamnetwork oam-net
    openstack subnet create --network oam-net --subnet-range 172.16.200.0/24 \
        --allocation-pool start=172.16.200.10,end=172.16.200.250 oam-subnet
fi
echo "Done"

echo "Creating MANO network..."
MANO_NAME_TEMP=$(openstack network list | grep mano-net | awk '{print $4}')
if [ "x${MANO_NAME_TEMP}" != "xmano-net" ]; then
    openstack network create --share --provider-network-type flat --provider-physical-network manonetwork mano-net
    openstack subnet create --network mano-net --subnet-range 172.16.220.0/24 \
        --allocation-pool start=172.16.220.10,end=172.16.220.250 mano-subnet
fi
echo "Done"

echo "Creating image..."
IMAGE_NAME_TEMP=$(openstack image list | grep Cirros-0.4.0 | awk '{print $4}')
if [ "x${IMAGE_NAME_TEMP}" != "xCirros-0.4.0" ]; then
    openstack image create --disk-format qcow2 --container-format bare \
        --file ~/tacoplay/tests/cirros-0.4.0-x86_64-disk.img \
        --public \
        Cirros-0.4.0
    openstack image show Cirros-0.4.0
fi
echo "Done"

echo "Adding security group for ssh"
SEC_GROUPS=$(openstack security group list --project admin | grep default | awk '{print $2}')
for sec_var in $SEC_GROUPS
do
    SEC_RULE=$(openstack security group rule list $SEC_GROUPS | grep 1:65535 | awk '{print $8}')
    if [ "x${SEC_RULE}" != "x1:65535" ]; then
        openstack security group rule create --proto tcp --remote-ip 0.0.0.0/0 --dst-port 1:65535 --ingress  $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 $sec_var
        openstack security group rule create --protocol icmp --remote-ip 0.0.0.0/0 --egress $sec_var
    fi
done
echo "Done"

echo "Creating private key"
    openstack keypair create --public-key ~/.ssh/id_rsa.pub taco-key
echo "Done"

if [[ $(openstack server list | grep test) ]]; then
  echo "Removing existing test VM..."
  openstack server delete test
  echo "Done"
fi

IMAGE=$(openstack image show 'Cirros-0.4.0' | grep id | awk '{print $4}')
FLAVOR=$(openstack flavor list | grep m1.tiny | awk '{print $2}')
NETWORK=$(openstack network list | grep oam-net | awk '{print $2}')

for COMPUTE_HOST in $(openstack compute service list | grep nova-compute | awk '{ print $6 }'); do
  echo "Creating virtual machine..."
  openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test-$COMPUTE_HOST --availability-zone nova::$COMPUTE_HOST  --wait
  echo "Done"
done
