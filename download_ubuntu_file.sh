REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
ARCHITECTURES=${5:-"amd64"}
PWD=`pwd`
declare -a arr=("jammy" "noble" "questing" "resolute")
declare -a architectures=(${ARCHITECTURES//,/ })
for i in "${arr[@]}"
do
    UBUNTU_DIST=$i
    mkdir -p deb/${UBUNTU_DIST}
    cd deb/${UBUNTU_DIST}
    for ARCH in ${architectures[@]}
    do
      BASE_URL=https://github.com/dariogriffo/${REPO}/releases/download/${PACKAGE_VERSION}%2B${BUILD_VERSION}
      # Newer repos use ~dist in the package version; GitHub mangles ~ to . in
      # release asset names, so try ~, then the mangled . name (saved back under
      # the ~ name), then fall back to the legacy +dist name.
      TILDE_NAME=${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${UBUNTU_DIST}_${ARCH}_ubu.deb
      DOT_NAME=${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}.${UBUNTU_DIST}_${ARCH}_ubu.deb
      if wget ${BASE_URL}/${TILDE_NAME}; then
        :
      elif wget ${BASE_URL}/${DOT_NAME}; then
        mv ${DOT_NAME} ${TILDE_NAME}
      else
        wget ${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}+${UBUNTU_DIST}_${ARCH}_ubu.deb || true
      fi
    done
    cd ../..
done
