REPO=uncloud-corrosion-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
ARCHITECTURES="amd64,arm64"
PACKAGE_NAME=uncloud-corrosion
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete
PACKAGE_NAME=uncloud-corrosiond
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

PACKAGE_NAME=uncloud-corrosion
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=uncloud-corrosion
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

