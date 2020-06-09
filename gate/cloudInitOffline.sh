#! /bin/bash
OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')

set -ex
(
useradd -p $(openssl passwd -1 taco1130@) taco -m
mkdir /home/taco/.ssh

cat > /home/taco/.ssh/authorized_keys <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiIN5IhdzN0FJQGDK9lBnG2ob/BNDueaYemadn2UjDvBp4swvoYQVVqxGVRwgzvHyxWNtVNYJ5cOJUFw4B3q8vnJSFxb4WoQJ2jgz2jGai8i1+3w4GO1f1PAaYpcdQLXNiapzzLT1v1P2j8kp6wOqhND0sc4xLVY1zz36EqDVQ8EWfxR96cKlnIhPkirqQEXo6p4vPciIgEy9H+mJHnve3Bn8vFPeVzUc/yoo2ddPFxE8LWPOk3DzTx9rxsCE0nGNf0ubEZlI46Rx5XggdRTPL6tezdWLuyLumn00TtpvsvwgcTh6N00WPHUi35m4MDn9GH0Qw9HdSzFzUVHROJ2XP Generated-by-Nova
EOF

chown -R taco:taco /home/taco/.ssh

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
MIIDXDCCAkQCCQCqBDb4C40PUDANBgkqhkiG9w0BAQUFADBvMQswCQYDVQQGEwJL
UjEOMAwGA1UEBwwFU2VvdWwxEzARBgNVBAoMClNLIFRlbGVjb20xFjAUBgNVBAsM
DTVHWCBDbG91ZCBMYWIxIzAhBgNVBAMMGnJlZ2lzdHJ5LXJlbC5jaWNkLnN0Zy50
YWNvMCAXDTIwMDYwMzAyNDA0MVoYDzIxMjAwNTEwMDI0MDQxWjBvMQswCQYDVQQG
EwJLUjEOMAwGA1UEBwwFU2VvdWwxEzARBgNVBAoMClNLIFRlbGVjb20xFjAUBgNV
BAsMDTVHWCBDbG91ZCBMYWIxIzAhBgNVBAMMGnJlZ2lzdHJ5LXJlbC5jaWNkLnN0
Zy50YWNvMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArnu7xw6wthun
dQR5wZSSngh0d9B3GaoojFcyIA03s6s38gtjrMBMaS7IQ9Fxr1uCqoQImhUaHAwy
N2SUppWHReNx7SP8c1qJvJPb4AkuhNpwcI69h6CXogfAInBTQSN0fII48c61LBgH
jN44ukDwEupr/CYA+CPMCT8WzJUW3GRQlTw1vurdp+Efo287mJT5Ll8i4vBspMAy
sKkRlS8MzD3yu8uKE/MYxMrBkZ5fSWFE4w5b0eqyNEUHij40QTW0pulCViwiI7xo
Kwh6e3scfitHNAv4/QJFyZZ0VNMS+XHrUeVIK/dzJJL5IPsw1IHI0TAiu9M44RLY
dKmVwoZpNwIDAQABMA0GCSqGSIb3DQEBBQUAA4IBAQAr9RJgtx5X7vWYcNPv0uRQ
cLRAf3W7bok3axCQ3u/SPueP6T5Rxrjg+nz2NVhnJXB2f5PbTpIxkSb0rnekzskr
/GjJL8TWKWRJBXxcWjgmC8h08id/7ilG2e3YnhNi5c+jVH8QS91mUQfBonWUJqAK
ZKs/7IdZjl7bOcLf9QljCgnJvk/rExvQhJ/nKiDVOWc+WoXJTVuT6uRBQ0S24nvy
lJ9wF224j33UigFifWHJnrNhSgdClIkXLGESAhpO2weUte8s0oFRf3sSbj+m+Q6C
/HINIYcornk5460QnncbwybfOUqvwNUqdgumPgyMzjY3ypEJpWbibYPXAjyKQG43
-----END CERTIFICATE-----
EOF

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
