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

echo "Create provider network..."
PUBLIC_NAME_TEMP=$(openstack network list | grep provider-net | awk '{print $4}')
if [ "x${PUBLIC_NAME_TEMP}" != "xprovider-net" ]; then
    openstack network create --provider-network-type flat --provider-physical-network provider provider-net
    openstack subnet create --network provider-net --subnet-range 172.27.126.0/23 \
        --allocation-pool start=172.27.126.11,end=172.27.126.200 --dns-nameserver 203.236.1.12 provider-subnet
fi
echo "Done"

echo "Create image..."
IMAGE_NAME_TEMP=$(openstack image list | grep cirros-0.4.0 | awk '{print $4}')
if [ "x${IMAGE_NAME_TEMP}" != "xcirros-0.4.0" ]; then
    openstack image create --disk-format qcow2 --container-format bare \
        --file ~/taco-deploy/tests/cirros-0.4.0-x86_64-disk.img \
        cirros-0.4.0
    openstack image show cirros-0.4.0
fi
echo "Done"

echo "Add security group for ssh"
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

echo "Create private key"
    openstack keypair create --public-key ~/.ssh/id_rsa.pub taco-key
echo "Done"

IMAGE=$(openstack image show 'cirros-0.4.0' | grep id | awk '{print $4}')
FLAVOR=$(openstack flavor list | grep m1.tiny | awk '{print $2}')
NETWORK=$(openstack network list | grep provider-net | awk '{print $2}')

echo "Create virtual machine..."
openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test --wait
echo "Done"

sleep 10
openstack server list
echo "Done"
