#! /bin/bash
OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')

set -ex
(
useradd -p $(openssl passwd -1 taco1130@) taco -m
mkdir /home/taco/.ssh

cat > /home/taco/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgQsADPxAlHA5pH7g2ll8KwNCGzMGazEc2iSQpqmuSMNvK0jHt1yY4/tr7YGkd/0xeJ/zr2u+/OclmAzrDt7ICVoX2dR5AmwHpt0znFvBtmqdrHAFx6q9BkaBoCEUjebopYqoTRWqDDmcL+GeTGFpElZnJxrM7bLn73Df6zwUpPLRs/eNpPfLfW3ARGqFt+6k3gwLILKwu43+dwvex4/2v+dSxCJvlClSmMORMQHQJL3oEkBQECFLipVjRQ3UeHxWZAmq9gbqFDNbn7QX6AFiV3UXTEoz6YSFAu/4AhC6UuQedGz3sBMYkKffLWjNDjKtMFEAOxR99KdqN9TJHwecr root@master01.cicd.stg.taco
EOF

mkdir -p /etc/docker/certs.d/registry.cicd.stg.taco
cat > /etc/docker/certs.d/registry.cicd.stg.taco/ca.crt <<EOF
-----BEGIN CERTIFICATE-----
MIIB+DCCAZ6gAwIBAgIUA1dN6Z3t/hNh795tcQD94mvgWGIwCgYIKoZIzj0EAwIw
WjELMAkGA1UEBhMCS1IxDjAMBgNVBAgTBVNlb3VsMRAwDgYDVQQHEwdKdW5nLWd1
MQwwCgYDVQQKEwNTS1QxDjAMBgNVBAsTBU9TTGFiMQswCQYDVQQDEwJDQTAeFw0x
NzA4MjgwNzU2MDBaFw0yMjA4MjcwNzU2MDBaMFoxCzAJBgNVBAYTAktSMQ4wDAYD
VQQIEwVTZW91bDEQMA4GA1UEBxMHSnVuZy1ndTEMMAoGA1UEChMDU0tUMQ4wDAYD
VQQLEwVPU0xhYjELMAkGA1UEAxMCQ0EwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNC
AAQhT71hyWXgZ0JKgSISZXxBw4kCSVYbdwG75/UB+pdn44txbfoQwowO5krucEmN
GXr5VW+MlYKIYWheUbxkPu8Zo0IwQDAOBgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/
BAUwAwEB/zAdBgNVHQ4EFgQUB5Mph3QGdJR76x12pAnYN8EYUY4wCgYIKoZIzj0E
AwIDSAAwRQIgc8/FlbbRyw22kt1ILAtqhYKdfibC/FjTqT4bQQ+cFb4CIQCpSBxE
bAIZhGrI5HT/a4dq3GPZWo1ybJs5RliBnPUtRg==
-----END CERTIFICATE-----
EOF

mkdir -p /etc/docker/certs.d/registry-rel.cicd.stg.taco
cat > /etc/docker/certs.d/registry-rel.cicd.stg.taco/ca.crt <<EOF
-----BEGIN CERTIFICATE-----
MIIDXDCCAkQCCQDBxFFeS5IQnzANBgkqhkiG9w0BAQsFADBwMQswCQYDVQQGEwJL
TzENMAsGA1UECAwETm9uZTEOMAwGA1UEBwwFU2VvdWwxDDAKBgNVBAoMA1NLVDEP
MA0GA1UECwwGVlMgTGFiMSMwIQYDVQQDDBpyZWdpc3RyeS1yZWwuY2ljZC5zdGcu
dGFjbzAeFw0xOTA2MDMwNzQxMjVaFw0yMDA2MDIwNzQxMjVaMHAxCzAJBgNVBAYT
AktPMQ0wCwYDVQQIDAROb25lMQ4wDAYDVQQHDAVTZW91bDEMMAoGA1UECgwDU0tU
MQ8wDQYDVQQLDAZWUyBMYWIxIzAhBgNVBAMMGnJlZ2lzdHJ5LXJlbC5jaWNkLnN0
Zy50YWNvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5YZigpq2DF/e
UaC7iPyLu2MIYHYvOsNs4ktskSgUKePnwk7/olgBU/jPsNDb1WiznBdA6ml2wJ2X
YO8KylpxJq/RIVZJ6z77Gdzt0mjPe26cjpLqm2xEpKLpdsd6Vb5M4bhDZidA1Ayi
CepU7DWH3s+Xz7yNfhBqLuTuBGZBku98fFTtZUMTxaxx39ucWFdn+olyJqwVLY/i
zzjozwyRKqxdzPnWUKkB323aOb5Mm1ciCEAaGU+YACD4XiZGaPvR3aAau109bwEZ
ZwUE34rNTAn9LXq8OzvSmXU3fcxSmOYYjlyWEmzQucsBaF9PRlJ3BJezKHgraObj
AooElitV7wIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQAry44uvw9qpCu3hRz/IzKD
SBGH7o+Vm0m4JU66SDVxy/O5JyvCKEmNSq8Y03KmKX3LSYum0WXV/Q/Tw4NDPlgU
q0wBcaO9AuH9qy7duyYhTl5iuX3f6A43UWNgITlBIKLDirUH93bICoBWTSPp0Jmq
SCbyvGyMyEguBNdTo8w0juAOvjAYzIRihDhCAxX5JfIZRJOtfRWRrGBddT4CtOtt
OnlLHy529DFSTmOg2/R+szz6CC8lPJfiGfmjBhlGYUtKOw9vWxnQMJNVUUG8YZjJ
wmK7opHgY7SA9bGeuUzblNjfjVrsL3a7hO5Zeco+hOFdV2uOjPlSFcoSEVyZVmfG
-----END CERTIFICATE-----
EOF

chown -R taco:taco /home/taco/.ssh

echo "taco ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/taco
echo "192.168.54.30 registry.cicd.stg.taco registry-rel.cicd.stg.taco minio.cicd.stg.taco" >> /etc/hosts

sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd

#######################
# Set default gateway #
#######################

until [ -n "$net0_stat" ] && [ -n "$net1_stat" ] && [ -n "$net2_stat" ]
do
  sleep 3
  if [ "$OS" = "\"centos\"" ]; then
    net0_stat=$(ip a | grep eth0 | grep 172.16)
    net1_stat=$(ip a | grep eth1 | grep 172.16)
    net2_stat=$(ip a | grep eth2 | grep 172.16)
  fi
done

if echo $net0_stat | grep 172.16.10
then
  gateway='172.16.10.1'
else
  echo "Something went wrong! Exiting.."
  exit 1
fi

if [ "$OS" = "\"centos\"" ]; then
  echo "GATEWAY=$gateway" >> /etc/sysconfig/network
  systemctl restart network
fi

# set tacorepo into /etc/hosts
echo '192.168.199.11 tacorepo' >> /etc/hosts

# back up repo files
for f in /etc/yum.repos.d/*.repo; do mv -- "$f" "${f%}.bak"; done

# use private repo for offline environment
cat >> /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Local Extra Packages for Enterprise Linux 7 - \$basearch
baseurl=http://tacorepo:80/epel/7/\$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=http://tacorepo:80/epel/RPM-GPG-KEY-EPEL-7
EOF

cat >> /etc/yum.repos.d/localrepo.repo << EOF
[base]
name=Local CentOS-\$releasever - Base
baseurl=http://tacorepo:80/centos/\$releasever/os/\$basearch/
gpgcheck=1
gpgkey=http://tacorepo:80/centos/RPM-GPG-KEY-CentOS-7

[updates]
name=Local CentOS-\$releasever - Updates
baseurl=http://tacorepo:80/centos/\$releasever/updates/\$basearch/
gpgcheck=1
gpgkey=http://tacorepo:80/centos/RPM-GPG-KEY-CentOS-7

[extras]
name=Local CentOS-\$releasever - Extras
baseurl=http://tacorepo:80/centos/\$releasever/extras/\$basearch/
gpgcheck=1
gpgkey=http://tacorepo:80/centos/RPM-GPG-KEY-CentOS-7
EOF

cat >> /etc/yum.repos.d/docker.repo << EOF
[docker-ce]
name=Docker-CE Repository
baseurl=http://tacorepo:80/docker/linux/centos/7/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=http://tacorepo:80/docker/linux/centos/gpg

[docker-engine]
name=Docker-Engine Repository
baseurl=http://tacorepo:80/dockerproject/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=http://tacorepo:80/dockerproject/gpg
EOF

cat >> /etc/yum.repos.d/ceph.repo << EOF
[ceph]
name=Ceph Mimic
baseurl=http://tacorepo:80/ceph/rpm-nautilus/el7/x86_64
gpgkey=http://tacorepo:80/ceph/keys/release.asc
gpgcheck=0
EOF

cat >> /etc/pip.conf << EOF
[global]
index-url = http://tacorepo:80/pip/simple
extra-index-url = http://tacorepo:80/pip3/simple
trusted-host = tacorepo
disable_pip_version_check=1
EOF

#######################
#  Remove nameserver  #
#######################
sed -i '/8.8.8.8/d' /etc/resolv.conf

touch /tmp/.vm_ready
) 2>&1 | tee /var/log/startup.log
