REPO=uv-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=uv
PWD=$(pwd)
# Matches uv_* and uvx_* alike.
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

ARCHITECTURES="amd64,arm64,armel,armhf,ppc64el,s390x,riscv64,i386"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

# uvx ships no binary of its own (it depends on uv, which installs /usr/bin/uvx),
# so it is Architecture: all -- one package per distribution, not per arch.
PACKAGE_NAME=uvx
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} all

cd ${PWD}

PACKAGE_NAME=uv
ARCHITECTURES="amd64,arm64,armhf,ppc64el,s390x,riscv64"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

PACKAGE_NAME=uvx
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} all

cd ${PWD}

PACKAGE_NAME=uv
find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
