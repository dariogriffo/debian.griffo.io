REPO=uncloud-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
ARCHITECTURES="amd64,arm64"
PACKAGE_NAME=uncloud
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete
PACKAGE_NAME=uncloudd
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

PACKAGE_NAME=uncloud
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=uncloudd
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=uncloud
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
PACKAGE_NAME=uncloudd
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*uncloud*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} uncloud
