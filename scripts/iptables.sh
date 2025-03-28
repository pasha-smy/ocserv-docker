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

# check if iptables-persistent is installed
if ! dpkg -s iptables-persistent >/dev/null 2>&1; then
  echo "Installing iptables-persistent..."
  export DEBIAN_FRONTEND=noninteractive
  apt update && apt install -y iptables-persistent
fi

# create iptables rules file
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports $SSH_PORT -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
iptables -A INPUT -d 127.0.0.0/24 -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

# optional: restore the rules now
sudo iptables-save > /etc/iptables/rules.v4