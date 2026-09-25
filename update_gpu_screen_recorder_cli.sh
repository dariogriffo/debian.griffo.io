REPO=gpu-screen-recorder-debian-cli
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PWD=$(pwd)
# Built from source, amd64 only. No jammy: its ffmpeg is too old, so that
# download is skipped.

# Covers both gpu-screen-recorder-cli and the transitional gpu-screen-recorder.
find deb/ -mindepth 2 -type f -name "gpu-screen-recorder*" -delete

# The recorder, named after Debian's own binary package
PACKAGE_NAME=gpu-screen-recorder-cli
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} amd64
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} amd64

# Transitional package (arch: all) that moves installs of the old name to -cli
PACKAGE_NAME=gpu-screen-recorder
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} all
./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME} all

cd ${PWD}

# The source package keeps Debian's source name, gpu-screen-recorder.
find src/ -type f -name "gpu-screen-recorder_*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
