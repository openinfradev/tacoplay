
### USAGE : ./01-node-enrollment.sh {node-name} {ipmi_address}

# comment out if you want to create node
#NODE_UUID=$(ironic node-create -n $1 -d pxe_ipmitool | grep -v chassis | grep uuid | awk '{print $4}')

ironic node-update $1 add \
driver_info/ipmi_address=$2 \
driver_info/ipmi_username=admin \
driver_info/ipmi_password=admin \
driver_info/deploy_kernel=file:///var/lib/tftpboot/ironic_images/ubuntu-deploy.kernel \
driver_info/deploy_ramdisk=file:///var/lib/tftpboot/ironic_images/ubuntu-deploy.initramfs

ironic node-set-provision-state $1 manage
ironic node-set-provision-state $1 provide

# comment out if you want to create port with this script
#ironic port-create -a 90:e2:ba:b4:f9:38 -n $NODE_UUID
