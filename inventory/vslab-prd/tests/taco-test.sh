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

echo "Creating public network..."
PUBLIC_NAME_TEMP=$(openstack network list | grep public-net | awk '{print $4}')
if [ "x${PUBLIC_NAME_TEMP}" != "xpublic-net" ]; then
    openstack network create --share --provider-physical-network provider-97 --provider-network-type flat public-net
    SEGMENT=$(openstack network segment list --network public-net | grep flat | awk '{print $2}')
    openstack network segment set --name segment-97 $SEGMENT
    openstack subnet create --network public-net --network-segment segment-97 \
      --subnet-range 192.168.97.0/24 --allocation-pool start=192.168.97.10,end=192.168.97.250 \
      --dns-nameserver 8.8.8.8 public-segment-97

    openstack network segment create --physical-network provider-98 --network-type flat --network public-net segment-98
    openstack subnet create --network public-net --network-segment segment-98 \
      --subnet-range 192.168.98.0/24 --allocation-pool start=192.168.98.10,end=192.168.98.250 \
      --dns-nameserver 8.8.8.8 public-segment-98
fi
echo "Done"

echo "Creating private network..."
PRIVATE_NAME_TEMP=$(openstack network list | grep closed-net | awk '{print $4}')
if [ "x${PRIVATE_NAME_TEMP}" != "xclosed-net" ]; then
    openstack network create --share --provider-physical-network provider-197 --provider-network-type flat closed-net
    SEGMENT=$(openstack network segment list --network closed-net | grep flat | awk '{print $2}')
    openstack network segment set --name segment-197 $SEGMENT
    openstack subnet create --network closed-net --network-segment segment-197 \
      --subnet-range 192.168.197.0/24 --allocation-pool start=192.168.197.10,end=192.168.197.250 \
      --host-route destination=192.168.198.0/24,gateway=192.168.197.1 closed-segment-197
    neutron subnet-update closed-segment-197 --no-gateway

    openstack network segment create --physical-network provider-198 --network-type flat --network closed-net segment-198
    openstack subnet create --network closed-net --network-segment segment-198 \
      --subnet-range 192.168.198.0/24 --allocation-pool start=192.168.198.10,end=192.168.198.250 \
      --host-route destination=192.168.197.0/24,gateway=192.168.198.1 closed-segment-198
    neutron subnet-update closed-segment-198 --no-gateway
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
NETWORK=$(openstack network list | grep public-net | awk '{print $2}')

echo "Creating virtual machine..."
openstack server create --image $IMAGE --flavor $FLAVOR --nic net-id=$NETWORK --key-name taco-key test --wait
echo "Done"

openstack server list

if [[ $(openstack volume list | grep test_bfv) ]]; then
  echo "Removing existing test volume.."
  openstack volume delete test_bfv
  echo "Done"
fi

openstack volume create --size 55 --image $IMAGE test_bfv
VOLUME=$(openstack volume list | grep test_bfv | awk '{print $2}')
echo "Attaching volume to vm..."
openstack server add volume $SERVER $VOLUME
echo "Done"
