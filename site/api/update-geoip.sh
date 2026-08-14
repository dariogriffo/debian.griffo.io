#!/usr/bin/env bash
# Fetch/refresh the IP->country database used by lib/currency.php.
#
# Uses DB-IP's "IP to Country Lite": free, no account or licence key, updated
# monthly, MaxMind MMDB format. Licensed CC-BY 4.0 — attribution to
# <https://db-ip.com> is REQUIRED wherever the data is used, so keep the credit
# in the page footer.
#
# The alternative is MaxMind GeoLite2, which is more accurate but needs a free
# account plus a licence key, and `geoipupdate` is not packaged in trixie.
#
# Run monthly as root:
#   0 4 1 * * /var/www/html/tools/update-geoip.sh
set -euo pipefail

DEST="${DEST:-/var/lib/GeoIP}"
TARGET="$DEST/dbip-country-lite.mmdb"

# DB-IP publishes per-month files; fall back to last month early in the month
# before the new one is cut.
for offset in 0 1; do
  MONTH=$(date -u -d "-${offset} month" +%Y-%m)
  URL="https://download.db-ip.com/free/dbip-country-lite-${MONTH}.mmdb.gz"
  if curl -fsI "$URL" >/dev/null 2>&1; then
    break
  fi
  URL=""
done

if [[ -z "${URL:-}" ]]; then
  echo "no DB-IP country-lite build found for this month or last" >&2
  exit 1
fi

install -d -m 0755 "$DEST"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "fetching $URL"
curl -fsSL "$URL" -o "$TMP/db.mmdb.gz"
gunzip -c "$TMP/db.mmdb.gz" > "$TMP/db.mmdb"

# Refuse to install a truncated download over a working database.
if [[ ! -s "$TMP/db.mmdb" ]] || [[ $(stat -c%s "$TMP/db.mmdb") -lt 1000000 ]]; then
  echo "downloaded database looks truncated, keeping the existing one" >&2
  exit 1
fi

# Atomic swap so a request mid-update never reads a half-written file.
install -m 0644 "$TMP/db.mmdb" "$TARGET.new"
mv -f "$TARGET.new" "$TARGET"
echo "installed $TARGET ($(stat -c%s "$TARGET") bytes, build $MONTH)"
