REPO=kitty-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PWD=$(pwd)

# Prefix-anchored cleanup so this only clears kitty's own staged debs. The
# trailing underscore keeps "kitty_*" from matching unrelated names and lets
# the three arch-all packages be listed explicitly.
find deb/ -mindepth 2 -type f \( \
    -name "kitty_*.deb" \
    -o -name "kitty-terminfo_*.deb" \
    -o -name "kitty-shell-integration_*.deb" \
    -o -name "kitty-doc_*.deb" \
  \) -delete

# amd64 + arm64 binary package — Debian and Ubuntu
PACKAGE_NAME=kitty
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} amd64,arm64
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} amd64,arm64

# architecture-independent packages (arch: all)
for PKG in kitty-terminfo kitty-shell-integration kitty-doc; do
  ./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} all
  ./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} all
done

PACKAGE_NAME=kitty
cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
