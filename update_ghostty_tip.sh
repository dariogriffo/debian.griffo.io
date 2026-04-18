#!/bin/bash
set -euo pipefail

# Mirror of update_ghostty.sh for the `tip` (weekly nightly) channel.
#
# Release tag in the ghostty-tip-debian repo is `tip-<BUILD_DATE>` and the
# .deb filenames embed the Debian-compatible upstream version computed by
# that repo's build_ghostty_debian.sh:
#     <pkg>_<APP-prefix>~<APP-suffix>.<BUILD_DATE>-<BUILD_VERSION>+<dist>_<arch>.deb
# e.g. ghostty-tip_1.3.2~dev.20260418-1+trixie_amd64.deb

REPO=ghostty-tip-debian
BUILD_DATE=$1                    # e.g. 20260418 (doubles as the release tag)
APP_VERSION=$2                   # upstream build.zig.zon .version, e.g. 1.3.2-dev
BUILD_VERSION=${3:-1}

# Compose Debian upstream version — same transformation as the build repo.
# Tilde sorts the tip BELOW the corresponding stable release; the date is
# monotonic so each weekly build sorts strictly newer than the previous one.
if [[ "$APP_VERSION" == *-* ]]; then
  UPSTREAM_VERSION="${APP_VERSION%%-*}~${APP_VERSION#*-}.${BUILD_DATE}"
else
  UPSTREAM_VERSION="${APP_VERSION}~tip.${BUILD_DATE}"
fi

TAG="tip-${BUILD_DATE}"
declare -a PKGS=(ghostty-tip libghostty-vt0-tip libghostty-vt-dev-tip)
declare -a DISTS=(trixie)
ARCH=amd64

# Delete only tip artifacts. The trailing underscore anchors each name so
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
