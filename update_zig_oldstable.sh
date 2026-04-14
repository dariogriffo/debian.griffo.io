REPO=zig-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
ARCHITECTURES="amd64,arm64,armel,ppc64el,s390x,riscv64,i386,loong64"

PACKAGE_NAME=zig-oldstable
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
