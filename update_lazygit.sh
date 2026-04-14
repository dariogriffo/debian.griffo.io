REPO=lazygit-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=lazygit
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

ARCHITECTURES="amd64,arm64,i386,armel,armhf"

./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
