#! /bin/bash
OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')

set -ex
(
## Create taco user ##
## The password here should match the password in adminInit script ##
useradd -p $(openssl passwd -1 taco1130@) taco -m
mkdir -p /home/taco/.ssh

## Put ssh public key here for jenkins slave to connects this VM ##
cat > /home/taco/.ssh/authorized_keys <<EOF
# CHANGE_ME #
EOF

chown -R taco:taco /home/taco

## Give password-less sudo privileges to taco user ## 
echo "taco ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taco

sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd

if [ "$OS" = "ubuntu" ]; then
  /sbin/dhclient
fi

## Wait until IPs are assigned to net interfaces ##
until [ -n "$net0_stat" ] && [ -n "$net1_stat" ]
do
  sleep 3
  if [ "$OS" = "\"centos\"" ]; then
    net0_stat=$(ip a | grep eth0 | grep 10.10)
    net1_stat=$(ip a | grep eth1 | grep 20.20)
  elif [ "$OS" = "ubuntu" ]; then
    net0_stat=$(ip a | grep ens3 | grep 10.10)
    net1_stat=$(ip a | grep ens4 | grep 20.20)
  fi
done

## Set default gateway to proper one. Modify based on your actual IP subnet ##
if echo $net0_stat | grep 10.10.10
then
  gateway='10.10.10.1'
else
  echo "Something went wrong! Exiting.."
  exit 1
fi

if [ "$OS" = "\"centos\"" ]; then
  echo "GATEWAY=$gateway" >> /etc/sysconfig/network
  systemctl restart network
fi

## Set DNS nameserver ##
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

# Chanage a default python interpreter to python3.6
if [ "$OS" = "ubuntu" ]; then
  update-alternatives --install /usr/bin/python python /usr/bin/python3 1
fi

touch /tmp/.vm_ready
) 2>&1 | tee /var/log/startup.log
