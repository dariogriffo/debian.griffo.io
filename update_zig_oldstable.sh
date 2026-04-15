REPO=zig-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${3:-1}
RELEASE_VERSION=$2
ARCHITECTURES="amd64,arm64,armel,ppc64el,s390x,riscv64,i386,loong64"

PACKAGE_NAME=zig-oldstable
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

./download_oldstable_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${RELEASE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_oldstable_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${RELEASE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
