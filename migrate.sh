#!/usr/bin/env bash
#
# deb.griffo.io — migrate to the current repository.
#
# Deletes every griffo.io APT file (sources, keys, credentials, cached
# indexes) whatever it is named, then adds deb.griffo.io.
#
#   sudo ./migrate.sh <login-email> <password>

set -euo pipefail

HOST=deb.griffo.io
KEY=EA0F721D231FDD3A0A17B9AC7808B4DD62C41256
KEYRING=/etc/apt/keyrings/$HOST.gpg

[ "$(id -u)" -eq 0 ] || { echo "Please run with sudo." >&2; exit 1; }

LOGIN=${1:-}
PASSWORD=${2:-}
[ -n "$LOGIN" ] && [ -n "$PASSWORD" ] || {
  echo "Usage: sudo $0 <login-email> <password>" >&2; exit 1; }

SUITE=$(. /etc/os-release && echo "${VERSION_CODENAME:-}")
[ -n "$SUITE" ] || { echo "Could not detect your Debian version." >&2; exit 1; }

# 1. remove every griffo.io file, old or new
echo "Removing old repository..."
find /etc/apt /var/lib/apt/lists /usr/share/keyrings \
     -name '*griffo*' -print -delete 2>/dev/null || true

# 2. add the new one
echo "Adding $HOST ($SUITE)..."
apt-get update -qq || true
apt-get install -y -qq curl gnupg ca-certificates

install -d -m 0755 /etc/apt/keyrings
curl -fsSL "https://$HOST/$KEY.asc" | gpg --dearmor --yes -o "$KEYRING"
chmod 0644 "$KEYRING"

echo "deb [signed-by=$KEYRING] https://$HOST/apt $SUITE main" \
  > /etc/apt/sources.list.d/$HOST.list
chmod 0644 /etc/apt/sources.list.d/$HOST.list

install -m 600 /dev/null /etc/apt/auth.conf.d/$HOST.conf
printf 'machine %s\nlogin %s\npassword %s\n' "$HOST" "$LOGIN" "$PASSWORD" \
  > /etc/apt/auth.conf.d/$HOST.conf

apt-get update
echo "Done."
