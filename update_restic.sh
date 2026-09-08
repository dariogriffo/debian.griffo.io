REPO=restic-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=restic
PWD=$(pwd)
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

# Upstream publishes linux/386, and Debian still has i386 as a release
# architecture, so the Debian lane carries it. armel is skipped: upstream's
# linux/arm build is GOARM=6 and needs a hardware FPU, which Debian's
# soft-float armel does not have; the same binary is fine on armhf.
ARCHITECTURES="amd64,arm64,armhf,ppc64el,s390x,riscv64,i386"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

# Ubuntu dropped i386 as a release architecture, so that build is not offered.
ARCHITECTURES="amd64,arm64,armhf,ppc64el,s390x,riscv64"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
