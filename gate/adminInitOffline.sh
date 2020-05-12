#!/bin/bash -uex

OS=$(awk -F= '/^ID/{print $2}' /etc/os-release | head -1 | awk '{print tolower($0)}')
PASSWORD="taco1130@"
ARTIFACT="ARTIFACT_NAME"

python --version
if [ "$OS" = "\"centos\"" ]; then
  sudo yum update -y
  sudo yum install -y openssh-server.x86_64 openssh-clients gcc make git sshpass wget
  sudo yum install -y epel-release
  sudo yum install -y python-pip
elif [ "$OS" = "ubuntu" ]; then
  sudo apt-get update
  sudo apt install -y openssh-server openssh-client gcc make sshpass wget
  sudo apt install -y python3-pip
  sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
fi

sudo pip install --upgrade pip

#################################################
# Put all artifacts into tacoplay directory #
#################################################

wget http://tacorepo/bin/mc && chmod 0755 mc && sudo mv mc /usr/local/bin

mkdir -p /home/taco/.mc
cat > /home/taco/.mc/config.json <<EOF
{
    "version": "8",
    "hosts": {
        "cicd": {
            "url": "http://minio.cicd.stg.taco",
            "accessKey": "minio",
            "secretKey": "password",
            "api": "S3v4"
        }
    }
}
EOF

echo "Fetch tarball from minio..."
actual_file=$ARTIFACT

cd /home/taco
mc cp cicd/artifacts/$ARTIFACT .

if [[ $ARTIFACT =~ "latest" ]]
then
  actual_file=$(cat $ARTIFACT | tr -d ' ')
  mc cp cicd/artifacts/$actual_file .
fi

tar xf $actual_file
cp ./hosts.ini ./tacoplay/inventory/SITE_NAME/
cp ./extra-vars.yml ./tacoplay/inventory/SITE_NAME/
cp ./*-manifest.yaml ./tacoplay/inventory/SITE_NAME/

###################################
# Distribue ssh keys to all nodes #
###################################
if [ -e /home/taco/.ssh/id_rsa ]; then
  echo "ssh key already exists. Re-using it..."
else
  ssh-keygen -f /home/taco/.ssh/id_rsa -t rsa -N ''
fi

echo "Installing pip packages..."
cd /home/taco/tacoplay
if [ "$OS" = "\"centos\"" ]; then
  sudo pip install -r requirements.txt --upgrade --ignore-installed
  sudo pip install -r kubespray/requirements.txt --upgrade --ignore-installed
  sudo pip install -r ceph-ansible/requirements.txt --upgrade --ignore-installed
elif [ "$OS" = "ubuntu" ]; then
  sudo pip install -r requirements.txt --upgrade
  sudo pip install -r kubespray/requirements.txt --upgrade 
  sudo pip install -r ceph-ansible/requirements.txt --upgrade
fi

# Parse node file to get target nodes' public ip addresses #
cat inventory/SITE_NAME/hosts.ini | grep 'ip=' | awk '{print $2}' | awk -F= '{print $2}' | while IFS= read -r TARGET
do
  sshpass -p "$PASSWORD" ssh-copy-id -i /home/taco/.ssh/id_rsa.pub -o StrictHostKeyChecking=no taco@$TARGET
done

ansible --version


##########################################
# Launch HTTP file server for k8s binary #
##########################################
echo "Starting httpd service for k8s binaries..."
sudo mkdir /data && sudo cp -r /home/taco/tacoplay/mirrors /data

if [ "$OS" = "\"centos\"" ]; then
  sudo yum install -y httpd
  sudo setenforce 0 && sudo systemctl start httpd && sudo systemctl enable httpd
elif [ "$OS" = "ubuntu" ]; then
  sudo apt install -y apache2
  sudo service apache2 restart
fi

sudo ln -s /data/mirrors/k8s /var/www/html
