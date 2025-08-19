REPO=uv-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=uv
ARCHITECTURES="amd64,arm64,armel,armhf,ppc64el,s390x,riscv64"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}
./generate_index.sh
git add .
git commit -m "Update uv to ${PACKAGE_VERSION}+${BUILD_VERSION}"
git push -u origin main

