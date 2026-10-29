REPO=handy-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=handy
ARCHITECTURES="amd64,arm64"

find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

# Upstream builds its arm64 .deb on Ubuntu 24.04 (glibc 2.39); amd64 is built
# on 22.04 (glibc 2.35) and covers every suite.
export EXCLUDE="bookworm:arm64 jammy:arm64"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
