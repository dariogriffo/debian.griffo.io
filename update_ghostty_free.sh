#!/bin/bash
# Stage the FREE-lane (apt-free) ghostty artifacts under free/.
# The free lane serves the newest version at least 2 months old, plus
# immediate patches of that series (see free_lane_tag.py). Invoked from
# update_ghostty.sh on each release and from free_refresh.sh daily — the
# window advances with time even when upstream is quiet.
set -euo pipefail
REPO=ghostty-debian

FREE_TAG="$(./free_lane_tag.py ${REPO})"
if [ -z "${FREE_TAG}" ]; then
  echo "free-lane: no candidate for ${REPO} yet (no release older than the window)"
  exit 0
fi
FREE_VERSION=${FREE_TAG%+*}
FREE_BUILD=${FREE_TAG##*+}
[ "${FREE_BUILD}" = "${FREE_TAG}" ] && FREE_BUILD=1
echo "free-lane: staging ghostty ${FREE_VERSION} build ${FREE_BUILD} into free/"

mkdir -p free
cd free
# Same name-anchored deletes as update_ghostty.sh so the tip channel of a
# future free tier is never clobbered.
find deb/ -mindepth 2 -type f \( \
    -name "ghostty_*.deb" \
    -o -name "ghostty-dbgsym_*.deb" \
    -o -name "libghostty-vt0_*.deb" \
    -o -name "libghostty-vt-dev_*.deb" \
  \) -delete 2>/dev/null || true

for PKG in ghostty ghostty-dbgsym libghostty-vt0 libghostty-vt-dev; do
  ../download_stable_deb_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ${PKG}
done

find src/ -type f -name "*ghostty*" -delete 2>/dev/null || true
../download_src_file.sh ${REPO} ${FREE_VERSION} ${FREE_BUILD} ghostty
