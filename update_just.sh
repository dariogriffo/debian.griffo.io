REPO=just-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=just
PWD=$(pwd)
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

ARCHITECTURES="amd64,arm64,armel,armhf,riscv64,loong64"
# Suite/architecture pairs the per-suite builds never covered; one shared
# .deb per arch must not start appearing there.
export EXCLUDE="jammy:armel noble:armel questing:armel resolute:armel bookworm:loong64 jammy:loong64 bookworm:riscv64 jammy:riscv64"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

ARCHITECTURES="amd64,arm64,armhf,riscv64,loong64"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
