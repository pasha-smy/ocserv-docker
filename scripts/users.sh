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

# validate required variable
if [ -z "$USER_ADMIN" ]; then
  echo "USER_ADMIN not set in $ENV_FILE"
  exit 1
fi

# add user to sudoers
echo "$USER_ADMIN ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$USER_ADMIN"

# check if $SECRETS already contains both passwords
if [ -f $SECRETS ] && grep -q "^$USER_ADMIN |" $SECRETS && grep -q "^root |" $SECRETS; then
  echo "Passwords for $USER_ADMIN and root already exist in $SECRETS. Skipping user creation."
  exit 0
fi

# generate secure 12-character alphanumeric passwords (A-Za-z0-9 only)
ADMIN_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c12)
ROOT_PASS=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c12)

# create user if not exists
if ! id "$USER_ADMIN" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$USER_ADMIN"
fi

echo "$USER_ADMIN:$ADMIN_PASS" | chpasswd
echo "root:$ROOT_PASS" | chpasswd

# save to $SECRETS
{
  echo "$USER_ADMIN | $ADMIN_PASS"
  echo "root | $ROOT_PASS"
} > "$SECRETS"
chmod 644 "$SECRETS"

echo "User $USER_ADMIN created and passwords stored in $SECRETS."

# clear history to protect sensitive data
history -c && history -w