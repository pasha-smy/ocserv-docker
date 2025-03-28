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

# validate required variables
if [ -z "$SSH_PORT" ] || [ -z "$SSH_PUBKEY" ] || [ -z "$USER_HOME" ] || [ -z "$USER_ADMIN" ]; then
  echo "Required variables SSH_PORT, SSH_PUBKEY, USER_HOME or USER_ADMIN not set in $ENV_FILE"
  exit 1
fi

# create SSH configuration
cat <<EOF > /etc/ssh/sshd_config.d/50-cloud-init.conf
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
EOF

# ensure .ssh directory exists for the admin user
mkdir -p "$USER_HOME/.ssh"
echo "$SSH_PUBKEY" > "$USER_HOME/.ssh/authorized_keys"
chmod 600 "$USER_HOME/.ssh/authorized_keys"
chmod 700 "$USER_HOME/.ssh"
chown -R "$USER_ADMIN:$USER_ADMIN" "$USER_HOME/.ssh"

# restart ssh service
systemctl restart ssh

echo "SSH has been configured on port $SSH_PORT with key authentication for user $USER_ADMIN."
