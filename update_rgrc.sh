REPO=rgrc-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=rgrc
ARCHITECTURES="amd64,arm64,armhf,i386"
# Suite/architecture pairs the per-suite builds never covered; one shared
# .deb per arch must not start appearing there.
export EXCLUDE="jammy:i386 noble:i386 questing:i386 resolute:i386"

find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
