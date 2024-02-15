#!/bin/bash
mkfs -t ext4 /dev/xvdf
mkdir /var/log/myapp
mount /dev/xvdf /var/log/myapp
echo '/dev/xvdf /var/log/myapp ext4 defaults,nofail 0 2' >> /etc/fstab

# Install Nginx
yum update -y
amazon-linux-extras install nginx1.12 -y

# Start Nginx
systemctl start nginx
systemctl enable nginx
