#!/usr/bin/env python3
"""Print the packaging-repo release tag the FREE lane (apt-free) should serve.

Rule: the free lane serves the newest upstream version that is at least
FREE_DAYS (default 60) days old. Patch releases within that version's
major.minor series are then promoted immediately, so security/bugfix updates
of the deployed free version reach apt-free without delay while new feature
series stay subscription-only until they age past the window.

A version's age is the FIRST publication of that upstream version; the tag
printed is its NEWEST build (e.g. ghostty 1.3.1 first shipped in March as
1.3.1+1 -> age counts from March, but we serve the 1.3.1+5 rebuild).

Prints nothing (exit 0) when the repo is too young to have a free candidate.

Usage: free_lane_tag.py <packaging-repo>     (e.g. free_lane_tag.py zed-debian)
Env:   FREE_DAYS=60
"""
import datetime
import json
import os
import re
import subprocess
import sys

repo = sys.argv[1]
DAYS = int(os.environ.get("FREE_DAYS", "60"))
# stable tags only: "1.2.3" or "1.2.3+4" — date-based tip/nightly tags excluded
TAG_RE = re.compile(r"^\d+(\.\d+)+(\+\d+)?$")

out = subprocess.check_output(
    ["gh", "api", f"repos/dariogriffo/{repo}/releases?per_page=100"], text=True)
releases = [r for r in json.loads(out)
            if not r["draft"] and not r["prerelease"] and TAG_RE.match(r["tag_name"])]

info = {}
for r in releases:
    tag = r["tag_name"]
    ver = tag.split("+")[0]
    build = int(tag.split("+")[1]) if "+" in tag else 1
    pub = datetime.datetime.fromisoformat(r["published_at"].replace("Z", "+00:00"))
    cur = info.setdefault(ver, {"first": pub, "build": build, "tag": tag})
    cur["first"] = min(cur["first"], pub)
    if build >= cur["build"]:
        cur["build"], cur["tag"] = build, tag


def vkey(v):
    return [int(x) for x in re.split(r"[^0-9]+", v) if x.isdigit()]


versions = sorted(info, key=vkey, reverse=True)
now = datetime.datetime.now(datetime.timezone.utc)

candidate = None
for v in versions:  # newest first
    if (now - info[v]["first"]).days >= DAYS:
        candidate = v
        break
if candidate is None:
    # tool younger than the window: serve the OLDEST available release (the
    # most-delayed version that exists) so newly enrolled tools are usable
    if not versions:
        sys.exit(0)
    candidate = versions[-1]

series = vkey(candidate)[:2]
for v in versions:  # newest first: first hit is the newest patch of the series
    if vkey(v)[:2] == series:
        print(info[v]["tag"])
        break
