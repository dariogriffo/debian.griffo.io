REPO=oh-my-posh-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=oh-my-posh
PWD=$(pwd)
find deb/ -mindepth 2 -type f -name "*${PACKAGE_NAME}*" -delete

ARCHITECTURES="amd64,arm64,armhf"
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

ARCHITECTURES="amd64,arm64,armhf"
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} ${ARCHITECTURES}

cd ${PWD}

find src/ -type f -name "*${PACKAGE_NAME}*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}

# Free lane (apt-free): re-stage on every release; never block the paid publish.
./update_oh_my_posh_free.sh || echo "WARN: free-lane staging failed (paid publish unaffected)"
