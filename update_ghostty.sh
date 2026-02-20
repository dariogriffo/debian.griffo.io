REPO=ghostty-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=ghostty
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

./download_stable_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
