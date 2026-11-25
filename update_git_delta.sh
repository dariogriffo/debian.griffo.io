REPO=git-delta-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=git-delta

find deb/ -mindepth 2 -type f -name "${PACKAGE_NAME}_*" -delete

# Upstream builds its i386 .deb against glibc 2.39, so not bookworm (2.36);
# amd64, arm64 and armhf cover every suite. No Ubuntu i386, as for the other
# i386 packages here.
ARCHITECTURES="amd64,arm64,armhf,i386"
export EXCLUDE="bookworm:i386"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

ARCHITECTURES="amd64,arm64,armhf"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
