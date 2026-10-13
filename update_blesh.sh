REPO=ble.sh-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=ble.sh
PWD=$(pwd)
# "*ble.sh*" also matches ble.sh-airline-themes, so this clears both packages.
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

# ble.sh is pure Bash, so a single Architecture: all package serves every
# architecture; reprepro fans it into each arch index. One source package builds
# two binaries (same split as Debian): ble.sh and ble.sh-airline-themes.
ARCHITECTURES="all"
for BINARY in ${PACKAGE_NAME} ${PACKAGE_NAME}-airline-themes
do
  ./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${BINARY} ${ARCHITECTURES}

  cd ${PWD}

  ./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${BINARY} ${ARCHITECTURES}

  cd ${PWD}
done

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
