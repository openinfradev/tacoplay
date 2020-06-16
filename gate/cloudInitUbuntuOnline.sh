#! /bin/bash
OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')

set -ex
(
useradd -p $(openssl passwd -1 taco1130@) taco -m
mkdir -p /home/taco/.ssh

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
echo "192.168.54.30 registry.cicd.stg.taco registry-rel.cicd.stg.taco" >> /etc/hosts

sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
systemctl restart sshd

/sbin/dhclient

until [ -n "$net0_stat" ] && [ -n "$net1_stat" ]
do
  sleep 3
  if [ "$OS" = "ubuntu" ]; then
    net0_stat=$(ip a | grep ens3 | grep 172.16)
    net1_stat=$(ip a | grep ens4 | grep 172.16)
  fi
done

if echo $net0_stat | grep 172.16.50
then
  gateway='172.16.50.1'
else
  echo "Something went wrong! Exiting.."
  exit 1
fi

# Chanage a default python interpreter to python3.6
update-alternatives --install /usr/bin/python python /usr/bin/python3 1

touch /tmp/.vm_ready
) 2>&1 | tee /var/log/startup.log
