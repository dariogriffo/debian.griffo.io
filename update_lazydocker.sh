REPO=lazydocker-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PACKAGE_NAME=lazydocker
./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
./generate_index.sh
git add .
git commit -m "Update lazydocker to ${BUILD_VERSION}"
git push -u origin main

