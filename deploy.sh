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

# resolve script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# define list of scripts
SCRIPTS=(
  "$SCRIPT_DIR/scripts/default.sh"
  "$SCRIPT_DIR/scripts/users.sh"
  "$SCRIPT_DIR/scripts/ssh.sh"
  "$SCRIPT_DIR/scripts/iptables.sh"
  "$SCRIPT_DIR/scripts/docker.sh"
)

# ensure scripts are executable
chmod +x "${SCRIPTS[@]}"

# run each script in order
for SCRIPT in "${SCRIPTS[@]}"; do
  if [ -x "$SCRIPT" ]; then
    echo "--- Running $SCRIPT ---"
    "$SCRIPT" "$ENV_FILE"
  else
    echo "Script $SCRIPT not found or not executable. Skipping."
  fi
done
