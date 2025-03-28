# DEFAULT
USER_ADMIN=admin
USER_HOME=/home/$USER_ADMIN
SSH_PUBKEY="ssh-rsa AAAA*************U="
SSH_PORT=22
TZ="Europe/Kyiv"
SECRETS="${SECRETS:-$(dirname "$ENV_FILE")/secrets.env}"

# OCSERV and DNS
VPN_DOMAIN="ocs.example.com"
VPN_IP=$(hostname -I | awk '{print $1}')
VPN_PORT=443
VPN_SUBNET=10.255.254.0/24
VPN_INT=$(ip route get 8.8.8.8 | awk '{for(i=1;i<=NF;i++) if ($i=="dev") print $(i+1)}')
VPN_GATEWAY=$(echo "$VPN_SUBNET" | sed -E 's|([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/.*|\1.1|')
VPN_DNS="$VPN_GATEWAY"
DNS_FORWARDERS_MAIN="8.8.8.8"
DNS_FORWARDERS_ALT="1.1.1.1"