REPO=ghostty-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}

# Delete only stable ghostty artifacts. The previous glob "*ghostty*" also
# matched ghostty-tip_*.deb / libghostty-vt0-tip_*.deb / etc., clobbering the
# tip channel. The trailing underscore anchors each name so e.g.
# `libghostty-vt0_*` does NOT match `libghostty-vt0-tip_*`.
find deb/ -mindepth 2 -type f \( \
    -name "ghostty_*.deb" \
    -o -name "libghostty-vt0_*.deb" \
    -o -name "libghostty-vt-dev_*.deb" \
  \) -delete

for PKG in ghostty libghostty-vt0 libghostty-vt-dev; do
  ./download_stable_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG}
done
