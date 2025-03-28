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

# go to script directory
cd "$(dirname "$0")" || exit 1

# define list of scripts
SCRIPTS=(
  ./scripts/default.sh
  ./scripts/users.sh
  ./scripts/ssh.sh
  ./scripts/iptables.sh
  ./scripts/docker.sh
)

# run each script in order
for SCRIPT in "${SCRIPTS[@]}"; do
  if [ -x "$SCRIPT" ]; then
    echo "--- Running $SCRIPT ---"
    bash "./$SCRIPT" "$ENV_FILE"
  else
    echo "Script $SCRIPT not found or not executable. Skipping."
  fi
done
