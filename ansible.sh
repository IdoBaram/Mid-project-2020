#!/usr/bin/env bash
apt update -y
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible -y
apt install ansible -y
git clone https://github.com/IdoBaram/midleman.git
chmod 600 /home/ubuntu/mid_project_key.pem
