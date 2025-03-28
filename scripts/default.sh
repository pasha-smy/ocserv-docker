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

# update package cache and install required packages
apt update
apt install -y \
    mc \
    net-tools \
    tcpdump \
    htop \
    iptables-persistent \
    util-linux \
    ethstats

# disable ipv6 via sysctl
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# make ipv6 changes persistent
cat <<EOF > /etc/sysctl.d/99-disable-ipv6.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF

# apply sysctl changes
sysctl --system

# configure pam limits
LIMITS_FILE=/etc/security/limits.d/99-custom-nofile.conf
cat <<EOF > "$LIMITS_FILE"
* soft nofile 64000
root soft nofile 64000
EOF

# set timezone (you can replace Europe/Kyiv with desired timezone)
ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "$TZ" > /etc/timezone
