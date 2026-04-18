#!/bin/bash
set -euo pipefail

# Mirror of update_ghostty.sh for the weekly nightly channel. Release layout:
#   repo        : dariogriffo/ghostty-weekly-debian
#   tag name    : <UPSTREAM_VERSION>-<BUILD_VERSION>
#                 e.g. 1.3.2.dev.20260418-1
#   asset files : <pkg>_<UPSTREAM_VERSION>-<BUILD_VERSION>+<dist>_<arch>.deb
#                 e.g. ghostty-tip_1.3.2.dev.20260418-1+forky_amd64.deb
#
# UPSTREAM_VERSION is composed as `<APP_BASE>.<APP_PRE>.<BUILD_DATE>` — dots
# throughout, no tilde — matching what the upstream build pipeline uploads.

REPO=ghostty-weekly-debian
BUILD_DATE=$1                    # YYYYMMDD, e.g. 20260418
APP_VERSION=$2                   # upstream build.zig.zon .version, e.g. 1.3.2-dev
BUILD_VERSION=${3:-1}

# Translate SemVer "X.Y.Z-dev" into the dotted form used in the release tag and
# asset filenames: "X.Y.Z.dev.YYYYMMDD". If upstream ever ships without a
# prerelease suffix, fall back to "X.Y.Z.tip.YYYYMMDD".
if [[ "$APP_VERSION" == *-* ]]; then
  UPSTREAM_VERSION="${APP_VERSION%%-*}.${APP_VERSION#*-}.${BUILD_DATE}"
else
  UPSTREAM_VERSION="${APP_VERSION}.tip.${BUILD_DATE}"
fi

TAG="${UPSTREAM_VERSION}-${BUILD_VERSION}"
declare -a PKGS=(ghostty-tip libghostty-vt0-tip libghostty-vt-dev-tip)
declare -a DISTS=(trixie forky sid)
ARCH=amd64

# Delete only tip artifacts. Trailing underscore anchors each name so
# e.g. `ghostty-tip_*` does NOT match `ghostty_*` (stable).
find deb/ -mindepth 2 -type f \( \
    -name "ghostty-tip_*.deb" \
    -o -name "libghostty-vt0-tip_*.deb" \
    -o -name "libghostty-vt-dev-tip_*.deb" \
  \) -delete

for DIST in "${DISTS[@]}"; do
  mkdir -p "deb/${DIST}"
  (
    cd "deb/${DIST}"
    for PKG in "${PKGS[@]}"; do
      FILE="${PKG}_${UPSTREAM_VERSION}-${BUILD_VERSION}+${DIST}_${ARCH}.deb"
      URL="https://github.com/dariogriffo/${REPO}/releases/download/${TAG}/${FILE}"
      wget "${URL}" || true
    done
  )
done
