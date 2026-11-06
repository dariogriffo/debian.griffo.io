#!/bin/bash
# Stage the FREE-lane (apt-free) forgejo-runner artifacts under free/.
# The free lane serves the newest version at least 2 months old, plus
# immediate patches of that series (see free_lane_tag.py). Invoked from
# update_forgejo_runner.sh on each release and from free_refresh.sh daily — the
# window advances with time even when upstream is quiet.
set -euo pipefail
REPO=forgejo-runner-debian
PACKAGE_NAME=forgejo-runner
# Same list as update_forgejo_runner.sh, so both lanes serve the same set. The
# releases only carry amd64/arm64; the rest 404 and are skipped.
ARCHITECTURES="amd64,arm64,armel,armhf,ppc64el,s390x,riscv64,i386,loong64"

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
# Anchored on "<name>_", as in update_uncloud_free.sh: the catalogue also has
# forgejo, and a glob matching both would let one tool's cleanup delete the
# other's staged debs once both are enrolled.
find deb/ -mindepth 2 -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true

../download_deb_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}
../download_ubuntu_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME} ${ARCHITECTURES}

find src/ -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true
../download_src_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PACKAGE_NAME}
