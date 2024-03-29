#!/bin/bash
yum update -y

mkfs -t ext4 /dev/xvdf
mkdir /var/log/myapp
mount /dev/xvdf /var/log/myapp
echo '/dev/xvdf /var/log/myapp ext4 defaults,nofail 0 2' >> /etc/fstab

# Install neccessary tools
amazon-linux-extras install nginx1 epel -y
yum install ansible git  -y
# Start nginx

systemctl start nginx
systemctl enable nginx

mkdir /app

useradd -m -s /bin/bash siemens
echo 'siemens ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
su siemens
chown siemens:siemens /app

cd /app
git clone https://github.com/sahilsaxena910/simpleapp.git
cd simpleapp
ansible-playbook -i localhost, -c local config_web_app.yml