### Usage : ./centos-user-image-update.sh {node-name}

MD5=`md5sum /var/lib/tftpboot/ironic_images/user-centos7.qcow2 | awk '{print $1}'`

ironic node-update $1 add \
instance_info/image_source=file:///var/lib/tftpboot/ironic_images/user-centos7.qcow2  \
instance_info/kernel=file:///var/lib/tftpboot/ironic_images/user-centos7.kernel  \
instance_info/ramdisk=file:///var/lib/tftpboot/ironic_images/user-centos7.initramfs \
instance_info/image_checksum=$MD5 \
instance_info/root_gb=10
