REPO=atuin-ai-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=atuin-ai

find deb/ -mindepth 2 -type f -name "${PACKAGE_NAME}_*" -delete

# Built from source on Ubuntu 22.04 (glibc 2.35), so both arches go into every
# suite; the same two arches as atuin, which it depends on.
ARCHITECTURES="amd64,arm64"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
