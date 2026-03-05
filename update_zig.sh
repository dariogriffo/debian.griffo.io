REPO=zig-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}

PACKAGE_NAME=zig
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete
PACKAGE_NAME=zig-zero
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

PACKAGE_NAME=zig
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
PACKAGE_NAME=zig-zero
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
PACKAGE_NAME=zig
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
PACKAGE_NAME=zig-zero
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
