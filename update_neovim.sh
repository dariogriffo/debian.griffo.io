REPO=neovim-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=neovim-latest
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

# amd64 binary packages
PACKAGE_NAME=neovim-latest
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
PACKAGE_NAME=neovim-latest-unstripped
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}

# architecture-independent runtime (arch: all)
PACKAGE_NAME=neovim-latest-runtime
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} all

PACKAGE_NAME=neovim-latest
cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
