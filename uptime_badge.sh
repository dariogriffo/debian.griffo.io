#!/usr/bin/env bash
# Regenerate the homepage uptime badge from the Upptime status repo.
#
# Reads history/summary.json from dariogriffo/deb-griffo-io-status and writes
# a shields-style SVG straight to the web root (NOT into git/site/ — it is
# runtime data, deploy_site.sh never deletes it). The homepage references it
# as /uptime-badge.svg, linking to https://status.deb.griffo.io/.
#
# Driven by systemd/uptime_badge.{service,timer} every 5 minutes (the unit
# runs as root; no sudo involved). For manual runs as dario, sudoers entry
# (visudo), same pattern as deploy_site.sh:
#   dario ALL=(root) NOPASSWD: /home/dario/debian.griffo.io/uptime_badge.sh
# On any fetch/parse failure the existing badge is left untouched (stale
# beats absent, same policy as the archive-version fetcher).
set -euo pipefail

URL="https://raw.githubusercontent.com/dariogriffo/deb-griffo-io-status/refs/heads/master/history/summary.json"
OUT="${OUT:-/var/www/debian.griffo.io/uptime-badge.svg}"

TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

if ! curl -fsS --max-time 30 "$URL" -o "$TMP_JSON"; then
    echo "WARN: could not fetch $URL — keeping existing badge" >&2
    exit 0
fi

python3 - "$TMP_JSON" "$OUT" <<'EOF'
import json
import os
import sys
import tempfile

src, out = sys.argv[1], sys.argv[2]
try:
    monitors = json.load(open(src, encoding="utf-8"))
    assert isinstance(monitors, list) and monitors
except Exception as e:
    print(f"WARN: bad summary.json ({e}) — keeping existing badge", file=sys.stderr)
    sys.exit(0)

# One badge for the whole service: if anything is down say so, otherwise show
# the worst all-time uptime across monitors (min is the honest number).
all_up = all(m.get("status") == "up" for m in monitors)
try:
    uptime = min(float(str(m.get("uptime", "0")).rstrip("%")) for m in monitors)
except ValueError:
    uptime = 0.0

if not all_up:
    value, color = "down", "#e05d44"
elif uptime >= 99.5:
    value, color = f"{uptime:.2f}%", "#4c1"
elif uptime >= 97.0:
    value, color = f"{uptime:.2f}%", "#dfb317"
else:
    value, color = f"{uptime:.2f}%", "#e05d44"

label = "uptime"
# shields.io flat style: ~6.5px per Verdana-11 char + 10px padding per side
label_w = round(len(label) * 6.5) + 10
value_w = round(len(value) * 6.5) + 10
total_w = label_w + value_w

svg = f"""<svg xmlns="http://www.w3.org/2000/svg" width="{total_w}" height="20" role="img" aria-label="{label}: {value}">
  <title>{label}: {value}</title>
  <linearGradient id="s" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="r"><rect width="{total_w}" height="20" rx="3" fill="#fff"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="{label_w}" height="20" fill="#555"/>
    <rect x="{label_w}" width="{value_w}" height="20" fill="{color}"/>
    <rect width="{total_w}" height="20" fill="url(#s)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" font-size="11">
    <text x="{label_w / 2}" y="14" fill="#010101" fill-opacity=".3">{label}</text>
    <text x="{label_w / 2}" y="13">{label}</text>
    <text x="{label_w + value_w / 2}" y="14" fill="#010101" fill-opacity=".3">{value}</text>
    <text x="{label_w + value_w / 2}" y="13">{value}</text>
  </g>
</svg>
"""

fd, tmp = tempfile.mkstemp(dir=os.path.dirname(out), suffix=".svg")
with os.fdopen(fd, "w", encoding="utf-8") as f:
    f.write(svg)
os.chmod(tmp, 0o644)
os.replace(tmp, out)
print(f"badge: {label} {value} -> {out}")
EOF
