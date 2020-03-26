#!/bin/bash -uex

OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')
PASSWORD="taco1130@"

echo "Installing for OS $OS"


echo "UseDNS no" | sudo tee -a /etc/ssh/sshd_config
echo "127.0.0.1 taco-aio" | sudo tee -a /etc/hosts
echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf

if [ "$OS" = "\"centos\"" ]; then
  sudo yum update -y
  sudo yum install -y openssh-server.x86_64 openssh-clients gcc make git sshpass
elif [ "$OS" = "ubuntu" ]; then
  sudo apt-get update
  sudo apt install -y openssh-server openssh-client gcc make sshpass
  sudo apt install -y python3-pip
  sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
fi
cd /home/taco

if [ -e /home/taco/.ssh/id_rsa ]; then
  echo "ssh key already exists. Re-using it..."
else
  ssh-keygen -f /home/taco/.ssh/id_rsa -t rsa -N ''
fi

cd /home/taco/tacoplay

./fetch-sub-projects.sh

echo "Installing pip packages..."
python --version
if [ "$OS" = "\"centos\"" ]; then
  sudo yum install -y epel-release
  sudo yum install -y python-pip
elif [ "$OS" = "ubuntu" ]; then
  sudo apt install -y bridge-utils
  sudo apt install -y python-pip
fi
sudo pip install --upgrade pip
if [ "$OS" = "\"centos\"" ]; then
  sudo pip install -r kubespray/requirements.txt --upgrade --ignore-installed
elif [ "$OS" = "ubuntu" ]; then
  sudo pip install -r kubespray/requirements.txt --upgrade 
fi
sudo pip install -r requirements.txt --upgrade

# Parse node file to get target nodes' public ip addresses #
cat inventory/SITE_NAME/hosts.ini | grep 'ip=' | awk '{print $2}' | awk -F= '{print $2}' | while IFS= read -r TARGET
do
  sshpass -p "$PASSWORD" ssh-copy-id -i /home/taco/.ssh/id_rsa.pub -o StrictHostKeyChecking=no taco@$TARGET
done

ansible --version
