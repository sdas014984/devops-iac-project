#!/bin/bash
yum update -y

# Install Ansible
amazon-linux-extras install ansible2 -y

# Generate SSH key
ssh-keygen -t rsa -N "" -f /home/ec2-user/.ssh/id_rsa

chown ec2-user:ec2-user /home/ec2-user/.ssh/id_rsa*
