#! /bin/bash

NOMAD_SERVER_IP=$1
# default port 5656
PORT_NUMBER=$2

cd /tmp
wget https://releases.hashicorp.com/nomad/0.8.6/nomad_0.8.6_linux_arm64.zip
unzip nomad_0.8.6_linux_arm64.zip
sudo mv nomad /usr/bin/nomad
rm -f nomad_0.8.6_linux_arm64.zip
sudo mkdir /etc/nomad
sudo cat >/etc/nomad/nomad-client.hcl<<EOL
# Increase log verbosity

log_level = "DEBUG"

data_dir = "/var/lib/nomad"

client {
  enabled = true
  node_class = “node”

  servers = ["$NOMAD_SERVER_IP:4647"]
  options = {

    “docker.privileged.enabled” = “true”
    “docker.volumes.enabled” = “true”

  }

}

ports {
  http = $PORT_NUMBER
}
EOL

sudo cat >/etc/systemd/system/nomad-client.service<<EOL
[Unit]

Description=Nomad client

Wants=network-online.target
After=network-online.target

[Service]

ExecStart= /bin/sh -c “/usr/bin/nomad agent -config /etc/nomad/nomad-client.hcl -bind=$(/sbin/ifconfig wlan0 | grep ‘inet addr:’ | cut -d: -f2 | awk ‘{ print $1}’)”

Restart=always
RestartSec=10

[Install]

WantedBy=multi-user.target
EOL

sudo systemctl enable nomad-client.service
sudo systemctl start nomad-client.service
