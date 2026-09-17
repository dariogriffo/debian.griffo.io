#!/bin/bash
# Stage the FREE-lane (apt-free) uncloud artifacts under free/.
# The free lane serves the newest version at least 2 months old, plus
# immediate patches of that series (see free_lane_tag.py). Invoked from
# update_uncloud.sh on each release and from free_refresh.sh daily — the
# window advances with time even when upstream is quiet.
set -euo pipefail
REPO=uncloud-debian
# Two binary packages from one source package, the same split the paid lane
# ships: uncloud is the CLI, uncloudd the machine daemon. Enrolling only one of
# them would put a package in the free mirror whose counterpart apt cannot
# resolve, so both are staged or neither is.
PACKAGE_NAME=uncloud
DAEMON_NAME=uncloudd
# Same list as update_uncloud.sh, so both lanes serve the same set.
ARCHITECTURES="amd64,arm64"

FREE_TAG="$(./free_lane_tag.py ${REPO})"
if [ -z "${FREE_TAG}" ]; then
  echo "free-lane: no candidate for ${REPO} yet (no release older than the window)"
  exit 0
fi
FREE_VERSION=${FREE_TAG%+*}
FREE_BUILD=${FREE_TAG##*+}
[ "${FREE_BUILD}" = "${FREE_TAG}" ] && FREE_BUILD=1
echo "free-lane: staging ${PACKAGE_NAME}/${DAEMON_NAME} ${FREE_VERSION} build ${FREE_BUILD} into free/"

mkdir -p free
cd free
# Anchored on "<name>_", not "*uncloud*": the catalogue also has
# uncloud-corrosion, and a glob that matches it would delete its staged debs
# the moment it is enrolled here too — leaving the free mirror serving a
# version of it that nothing re-downloads.
find deb/ -mindepth 2 -type f \
     \( -name "${PACKAGE_NAME}_*" -o -name "${DAEMON_NAME}_*" \) -delete 2>/dev/null || true

../download_deb_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}
../download_deb_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${DAEMON_NAME} ${ARCHITECTURES}
../download_ubuntu_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}
../download_ubuntu_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${DAEMON_NAME} ${ARCHITECTURES}

# One source package builds both binaries, so it is fetched once under the
# source name.
find src/ -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true
../download_src_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME}
