REPO=fastpotify-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=fastpotify
# Upstream publishes x86_64 and aarch64 Linux builds only. They need
# GLIBC_2.39, so there is nothing for bookworm or jammy; the generic
# downloaders just find no asset for those suites.
ARCHITECTURES="amd64,arm64"

find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
