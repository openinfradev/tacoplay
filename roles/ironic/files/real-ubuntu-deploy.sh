#ironic node-create -d pxe_ipmitool -n node01 -u 00000000-0000-0000-0000-000000000001

ironic node-update $1 add \
driver_info/ipmi_address=$2 \
driver_info/ipmi_username=admin \
driver_info/ipmi_password=helion123! \
driver_info/deploy_kernel=file:///var/lib/ironic/ubuntu-dev-deploy/ubuntu-devuser-image.kernel \
driver_info/deploy_ramdisk=file:///var/lib/ironic/ubuntu-dev-deploy/ubuntu-devuser-image.initramfs

ironic node-set-power-state $1 off

# for master01-k2 server
#ironic port-create -a 90:e2:ba:b4:f9:38 -n 00000000-0000-0000-0000-000000000001
