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

echo "Create private network..."
PRIVATE_NAME_TEMP=$(openstack network list | grep private-net | awk '{print $4}')
if [ "x${PRIVATE_NAME_TEMP}" != "xprivate-net" ]; then
    openstack network create private-net
    openstack subnet create --network private-net --subnet-range 10.10.10.0/24 \
        --dns-nameserver 8.8.8.8 private-subnet
fi
echo "Done"

echo "Create external network..."
PUBLIC_NAME_TEMP=$(openstack network list | grep public-net | awk '{print $4}')
if [ "x${PUBLIC_NAME_TEMP}" != "xpublic-net" ]; then
    openstack network create --external --share --provider-network-type flat --provider-physical-network external public-net
    openstack subnet create --network public-net --subnet-range 192.168.98.0/24 \
        --allocation-pool start=192.168.98.200,end=192.168.98.225 --dns-nameserver 8.8.8.8 public-subnet
fi
echo "Done"

echo "Create router..."
ADMIN_ROUTER_TEMP=$(openstack router list | grep admin-router | awk '{print $4}')
if [ "x${ADMIN_ROUTER_TEMP}" != "xadmin-router" ]; then
    openstack router create admin-router
    openstack router add subnet admin-router private-subnet
    openstack router set --external-gateway public-net admin-router
    openstack router show admin-router
fi
echo "Done"

echo "Create image..."
IMAGE_NAME_TEMP=$(openstack image list | grep Cirros-0.4.0 | awk '{print $4}')
if [ "x${IMAGE_NAME_TEMP}" != "xCirros-0.4.0" ]; then
    openstack image create --disk-format qcow2 --container-format bare \
        --file ~/taco-deploy/tests/cirros-0.4.0-x86_64-disk.img \
        --id 201084fc-c276-4744-8504-cb974dbb3610 --public \
        Cirros-0.4.0
    openstack image show Cirros-0.4.0
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

IMAGE=$(openstack image show 'Cirros-0.4.0' | grep id | awk '{print $4}')
FLAVOR=$(openstack flavor list | grep m1.tiny | awk '{print $2}')
NETWORK=$(openstack network list | grep private-net | awk '{print $2}')

echo "Create virtual machine..."
openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test --wait
echo "Done"

echo "Add external ip to vm..."
openstack floating ip create public-net
FLOATING_IP=$(openstack floating ip list | grep 192 | awk '{print $4}')
SERVER=$(openstack server list | grep test | awk '{print $2}')

sleep 10

openstack server add floating ip $SERVER $FLOATING_IP
openstack server list
echo "Done"
