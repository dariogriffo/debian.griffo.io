REPO=$1
PACKAGE_VERSION=$2
RELEASE_VERSION=$3
BUILD_VERSION=$4
PACKAGE_NAME=$5
ARCHITECTURES=${6:-"amd64"}
PWD=`pwd`
declare -a arr=("bookworm" "trixie" "forky" "sid")
declare -a architectures=(${ARCHITECTURES//,/ })
for i in "${arr[@]}"
do
    DEBIAN_DIST=$i
    mkdir -p deb/${DEBIAN_DIST}
    cd deb/${DEBIAN_DIST}
    for ARCH in ${architectures[@]}
    do
      BASE_URL=https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_VERSION}%2B${BUILD_VERSION}
      # Newer repos use ~dist in the package version; GitHub mangles ~ to . in
      # release asset names, so try ~, then the mangled . name (saved back under
      # the ~ name), then fall back to the legacy +dist name.
      TILDE_NAME=${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${DEBIAN_DIST}_${ARCH}.deb
      DOT_NAME=${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}.${DEBIAN_DIST}_${ARCH}.deb
      if wget ${BASE_URL}/${TILDE_NAME}; then
        :
      elif wget ${BASE_URL}/${DOT_NAME}; then
        mv ${DOT_NAME} ${TILDE_NAME}
      else
        wget ${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}+${DEBIAN_DIST}_${ARCH}.deb || true
      fi
    done
    cd ../..
done
