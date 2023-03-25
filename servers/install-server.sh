#!/bin/bash

useradd deploy
sudo echo deploy:Admin@123 | sudo chpasswd
groupadd train-schedule
usermod deploy -aG train-schedule
usermod deploy -aG wheel
echo "%wheel         ALL=(ALL)         NOPASSWD: ALL" >> /etc/sudoers

cat <<EOF >/etc/systemd/system/train-schedule.service
[Unit]
Description=Train Schedule
After=network.target

[Service]

Type=simple
WorkingDirectory=/opt/train-schedule
ExecStart=/usr/bin/node bin/www
StandardOutput=syslog
StandardError=syslog
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /opt/train-schedule
chown -R root:train-schedule /opt/train-schedule

sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo systemctl start docker

sudo usermod deploy -aG docker