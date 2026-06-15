REPO=zig-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
ARCHITECTURES="amd64,arm64,armel,ppc64el,s390x,riscv64,i386,loong64"

PACKAGE_NAME=zig-stable
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

PACKAGE_NAME=zig
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}_*" -delete

PACKAGE_NAME=zig
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=zig-stable
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=zig
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=zig-stable
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

PACKAGE_NAME=zig-stable
find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
