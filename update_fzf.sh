REPO=fzf-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=fzf
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

ARCHITECTURES="amd64,arm64,armel,armhf,ppc64el,s390x,riscv64,loong64"                                                                                                                                                                                                                                             
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}

