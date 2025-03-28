#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# load variables
ENV_FILE="${1:-./deploy.env}"
if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
else
  echo "Env file not found: $ENV_FILE"
  exit 1
fi  

# check if docker is already installed
if command -v docker >/dev/null 2>&1 && command -v docker compose >/dev/null 2>&1; then
  echo "Docker and Docker Compose already installed. Skipping installation."
else
  # install required packages
  apt update
  apt install -y \
      ca-certificates \
      curl \
      gnupg \
      lsb-release

  # add Docker GPG key
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  # add Docker repository
  ARCH=$(dpkg --print-architecture)
  RELEASE=$(lsb_release -cs)
  echo \
    "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $RELEASE stable" \
    > /etc/apt/sources.list.d/docker.list

  apt update
  apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

F="./docker/docker-compose.yml"
sed -i -e "s/{{ vpn.ip }}/${VPN_IP}/g" "$F"
sed -i -e "s/{{ vpn.domain }}/${VPN_DOMAIN}/g" "$F"
sed -i -e "s/{{ vpn.subnet }}/$(echo ${VPN_SUBNET} | sed 's/\//\\\//g')/g" "$F"
sed -i -e "s/{{ vpn.dns }}/${VPN_DNS}/g" "$F"
sed -i -e "s/{{ vpn.int }}/${VPN_INT}/g" "$F"
sed -i -e "s/{{ dns.forvarder.main }}/${DNS_FORWARDERS_MAIN}/g" "$F"
sed -i -e "s/{{ dns.forvarder.alt }}/${DNS_FORWARDERS_ALT}/g" "$F"
sed -i -e "s/{{ vpn.gateway }}/${VPN_GATEWAY}/g" "$F"

# copy docker directory to /data/docker
mkdir -p /data/docker
cp -r ./docker/* /data/docker


# run docker compose
cd /data/docker || exit 1
chmod +x add_vpn_users.sh
docker compose -f docker-compose.yml up -d
