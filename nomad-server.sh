#! /bin/bash

cd /tmp
wget https://releases.hashicorp.com/nomad/0.8.6/nomad_0.8.6_linux_arm64.zip
unzip nomad_0.8.6_linux_arm64.zip
sudo mv nomad /usr/bin/nomad
rm -f nomad_0.8.6_linux_arm64.zip
sudo mkdir /etc/nomad
sudo cat >/etc/nomad/nomad-server.hcl<<EOL
# Increase log verbosity

log_level = “DEBUG”

# Setup data dir

data_dir = “/var/lib/nomad”

server {

  enabled = true
  bootstrap_expect = 1

}
EOL

sudo cat >/etc/systemd/system/nomad-server.service<<EOL
  [Unit]
  Description=Nomad server

  Wants=network-online.target
  After=network-online.target

  [Service]

  ExecStart= /bin/sh -c “/usr/bin/nomad agent -config=/etc/nomad/nomad.hcl -bind=$(/sbin/ifconfig enp3s0 | grep ‘inet addr:’ | cut -d: -f2 | awk ‘{ print $1}’)”

  Restart=always
  RestartSec=10

  [Install]

  WantedBy=multi-user.target
EOL

sudo systemctl enable nomad-server.service
sudo systemctl start nomad-server.service
