REPO=zls-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=zls
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
PACKAGE_NAME=zls-zero
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
./generate_index.sh



