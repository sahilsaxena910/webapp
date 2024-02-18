####### Not working as of now, need to come back on it

#!/bin/bash
yum update -y

mkfs -t ext4 /dev/xvdf
mkdir /var/log/myapp
mount /dev/xvdf /var/log/myapp
echo '/dev/xvdf /var/log/myapp ext4 defaults,nofail 0 2' >> /etc/fstab

# Install neccessary tools
amazon-linux-extras install epel -y
yum install ansible git docker python3 -y 
export PATH=$PATH:/usr/bin
pip3 install docker ## This particular library is needed by ansible to work with docker
# Start Docker

systemctl start docker
systemctl enable docker

mkdir /app

useradd -m -s /bin/bash siemens
echo 'siemens ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su siemens
chown siemens:siemens /app

cd /app
git clone https://github.com/sahilsaxena910/simpleapp.git
cd simpleapp

ansible-playbook -i localhost, -c local deploy_web_app.yml