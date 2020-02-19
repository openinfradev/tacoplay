Install TACO with tacoplay
==================
---
**TEST environment**  
Prepare single host(either baremetal machine or virtual machine) with at least following spec.
 - RAM: 24GB
 - Root Disk: 160GB   
 - Additional disk size: 50GB * 2  
 - OS:  CentOS 7 & Ubuntu 18.04
---
#### 1. Pre-requirements
 * CentOS 7
 ```sh
 $ sudo yum install -y git selinux-policy-targeted bridge-utils epel-release
 $ sudo yum install -y python-pip
 $ sudo pip install --upgrade
 $ git clone https://github.com/openinfradev/tacoplay.git
 $ cd tacoplay/
 ```
 * Ubuntu 18.04
 ```sh
 $ sudo apt install -y python-pip
 $ sudo pip install --upgrade
 $ git clone https://github.com/openinfradev/tacoplay.git
 $ cd tacoplay/
 ```

 If firewalld in your machine is enabled, stop and disable it.
 ```sh
$ sudo systemctl stop firewalld
$ sudo systemctl disable firewalld
 ```
#### 2. Fetch sub-projects
 ```sh
 $ ./fetch-sub-projects.sh
 ```
#### 3. Edit extra-vars.yml and armada-manifest.yaml
 * Check extra disk names(not used) with "lsblk".  
  **Ex)** Extra disk names can be different by machine(vdb, vdc)
 ```sh
 $ lsblk
 NAME    MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sr0      11:0    1   458K  0 rom  
vda     252:0    0   160G  0 disk
├─vda1  252:1    0 159.9G  0 part /
├─vda14 252:14   0     4M  0 part
└─vda15 252:15   0   106M  0 part /boot/efi
 vdb     252:16   0    50G  0 disk  ##extra disk name: vdb
        253:0    0    50G  0 lvm  
 vdc     252:32   0    50G  0 disk  ##extra disk name: vdc
        253:1    0    50G  0 lvm  
 ```
 * Check the host ip with "ip a"  
  **Ex)** Check the host ip interface name and ip address cidr. In this example, interface is ens3.
 ```sh
 $ ip a
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
 2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc fq_codel state UP group default qlen 1000
    link/ether fa:??:3e:??:??:1a brd ff:ff:ff:ff:ff:ff
    inet 192.???.??.??/24 brd 192.??.??.255 scope global dynamic ens3
       valid_lft 62596sec preferred_lft 62596sec
    inet6 f??0::f??6:3??f:f??0:b??a/64 scope link
       valid_lft forever preferred_lft forever
 ```
 * Edit extra-vars.yml  
 Change the monitor_interface, public_network, cluster_network, lvm_volumes.
 Set these to your own values checked above.
   - monitor_interface: $YOUR_NETWK_INTERFACE(ens3, eth0, etc.)
   - public_network: $YOUR_IP_CIDR
   - cluster_network: $YOUR_IP_CIDR
   - lvm_volumes:  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; data: /dev/$YOUR_EXTRA_DISK1 (Eg, /dev/vdb)  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; data: /dev/$YOUR_EXTRA_DISK2  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ...

 ```sh
   ##"$YOUR_INVEN" means "aio" or "5node" inventory under "sample" folder.
   $ cd ~/tacoplay/inventory/sample/$YOUR_INVEN   
   $ vi extra-vars.yml
 ```
 * Edit armada-manifest.yaml  
 Change network setting in armada-manifest.yaml
   - neutron chart: data.values.network.interface.tunnel -> change this to $YOUR_NETWK_INTERFACE
   - nova chart: data.values.conf.hypervisor.host_interface -> same
   - nova chart: data.values.conf.libvirt.live_migration_interface  -> same
   - Change all the charts' source locations to your local directories  
    **Ex)**  
    source:  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  type: local  
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  location: /home/$YOUR_USER_NAME/tacoplay/charts/openstack-helm
 ```sh
   ##"$YOUR_INVEN" means "aio" or "5node" inventory under "sample" folder.
   $ cd ~/tacoplay/inventory/sample/$YOUR_INVEN
   $ vi armada-manifest.yaml
 ```  

#### 4. Edit OS setting("hosts")
 Add taco-aio host to your 127.0.0.1 in hosts file
 ```sh
 $ sudo vi /etc/hosts
  ## TACO ClusterInfo
  127.0.0.1 taco-aio localhost localhost.localdomain localhost4 localhost4.localdomain4
 ```

#### 5. Install Packages for tacoplay

 ```sh
 $ cd ~/tacoplay
 $ sudo pip install -r ceph-ansible/requirements.txt
 $ sudo pip install -r kubespray/requirements.txt --upgrade --ignore-installed
 $ sudo pip install -r requirements.txt --upgrade --ignore-installed
 ```
#### 6. Install TACO
 Install TACO with ansible-playbook. You can add "-vvv" option for detailed logs.
 ```sh
  ##"$YOUR_INVEN" means "aio" or "5node" inventory under "sample" folder.
 $ cd ~/tacoplay
 $ ansible-playbook -b -i inventory/sample/$YOUR_INVEN/hosts.ini -e @inventory/sample/$YOUR_INVEN/extra-vars.yml site.yml
 ```
#### 8. Check TACO installation
You can check TACO installation is successfull or not with "kubectl".
If whole pods are in status "Running" or "Completed", the installation succeed.
```sh
$ kubectl get pods -n openstack  ## check pod status
$ watch 'kubectl get pods -n openstack'  ## check pods status in real time
$ watch 'kubectl get pods -n openstack | grep -v Com'  ## check pods status except completed pods in real time
```
After installation, you can access horizon(openstack dashboard).  
  ->  http://$YOUR_IP_CIDR:31000  
  - domain : default
  - id : admin
  - pw : password   


----

##### * More details with pictures
 You can refer to more specific installation quide with test images in here. This doc contains detailed information for all-in-one installation.
 - https://taco-docs.readthedocs.io/ko/latest/intro/aio.html#tacoplay

##### * Run site-prepare task for actual package delivery
 ansible-playbook -u $USERNAME -b -i inventory/preparation/local.ini site-prepare.yml --tags download,preinstall --skip-tags upload,upgrade  
 Refer to https://stackoverflow.com/questions/40181416/calling-an-ansible-playbook-with-tag-and-parameter
