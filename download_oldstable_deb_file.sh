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
      wget https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_VERSION}%2B${BUILD_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}+${DEBIAN_DIST}_${ARCH}.deb || true
    done
    cd ../..
done
