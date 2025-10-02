REPO=xltui-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=xltui
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
./generate_index.sh



