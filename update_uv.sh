REPO=uv-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=uv
PWD=$(pwd)

ARCHITECTURES="amd64,arm64,armel,armhf,ppc64el,s390x,riscv64,i386"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

ARCHITECTURES="amd64,arm64,armhf,ppc64el,s390x,riscv64"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
