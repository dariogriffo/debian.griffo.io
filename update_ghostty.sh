REPO=ghostty-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}

# Delete only stable ghostty artifacts. The previous glob "*ghostty*" also
# matched ghostty-tip_*.deb / libghostty-vt0-tip_*.deb / etc., clobbering the
# tip channel. The trailing underscore anchors each name so e.g.
# `libghostty-vt0_*` does NOT match `libghostty-vt0-tip_*`.
find deb/ -mindepth 2 -type f \( \
    -name "ghostty_*.deb" \
    -o -name "ghostty-dbgsym_*.deb" \
    -o -name "libghostty-vt0_*.deb" \
    -o -name "libghostty-vt-dev_*.deb" \
  \) -delete

# From 1.4.0 on ghostty needs GTK 4.18 and libadwaita 1.7, which noble lacks,
# and is released as one ~griffo .deb per architecture that download_bin.sh
# would otherwise link into every suite given, noble included.
if dpkg --compare-versions "${PACKAGE_VERSION}" ge 1.4.0; then
  export EXCLUDE="noble:amd64 noble:arm64"
fi

for PKG in ghostty ghostty-dbgsym libghostty-vt0 libghostty-vt-dev; do
  ./download_stable_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} amd64,arm64
  ./download_stable_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} amd64,arm64
done

cd ${PWD}

find src/ -type f -name "*ghostty*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ghostty

# Free lane (apt-free): re-stage on every release; never block the paid publish.
./update_ghostty_free.sh || echo "WARN: free-lane staging failed (paid publish unaffected)"
