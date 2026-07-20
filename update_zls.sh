REPO=zls-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PWD=$(pwd)

PACKAGE_NAME=zls
# Prefix-anchored so this never eats zls-master_* staged by update_zls_master.sh.
find deb/ -mindepth 2 -type f \( -name "zls_*" -o -name "zls-zero_*" \) -delete
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
cd ${PWD}

PACKAGE_NAME=zls-zero
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
cd ${PWD}

PACKAGE_NAME=zls
find src/ -type f -name "zls_*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
