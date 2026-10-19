REPO=termusic-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=termusic
# Needs GLIBC_2.39 and libmpv2: nothing for bookworm (2.36) or jammy (2.35,
# libmpv1 only), so it goes to trixie and later and noble and later.
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete
ARCHITECTURES="amd64,arm64"

./download_stable_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_stable_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
