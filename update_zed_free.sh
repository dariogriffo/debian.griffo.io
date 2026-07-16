#!/bin/bash
# Stage the FREE-lane (apt-free) zed artifacts under free/.
# The free lane serves the newest version at least 2 months old, plus
# immediate patches of that series (see free_lane_tag.py). Invoked from
# update_zed.sh on each release and from free_refresh.sh daily — the
# window advances with time even when upstream is quiet.
set -euo pipefail
REPO=zed-debian
PACKAGE_NAME=zed
ARCHITECTURES="amd64,arm64"

FREE_TAG="$(./free_lane_tag.py ${REPO})"
if [ -z "${FREE_TAG}" ]; then
  echo "free-lane: no candidate for ${REPO} yet (no release older than the window)"
  exit 0
fi
FREE_VERSION=${FREE_TAG%+*}
FREE_BUILD=${FREE_TAG##*+}
[ "${FREE_BUILD}" = "${FREE_TAG}" ] && FREE_BUILD=1
echo "free-lane: staging ${PACKAGE_NAME} ${FREE_VERSION} build ${FREE_BUILD} into free/"

mkdir -p free
cd free
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true

../download_deb_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}
../download_ubuntu_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
../download_src_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME}
