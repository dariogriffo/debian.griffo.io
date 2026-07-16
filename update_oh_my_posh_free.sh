#!/bin/bash
# Stage the FREE-lane (apt-free) oh-my-posh artifacts under free/.
# Free version rule: newest release at least 2 months old (oldest available
# while the tool is younger than the window), patches of that series
# immediate — see free_lane_tag.py. Invoked from update_oh_my_posh.sh on each
# release and from free_refresh.sh daily.
set -euo pipefail
REPO=oh-my-posh-debian
PACKAGE_NAME=oh-my-posh
ARCHITECTURES="amd64,arm64,armhf"

FREE_TAG="$(./free_lane_tag.py ${REPO})"
if [ -z "${FREE_TAG}" ]; then
  echo "free-lane: no candidate for ${REPO} yet"
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
