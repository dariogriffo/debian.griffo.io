REPO=$1
PACKAGE_VERSION=$2
RELEASE_VERSION=$3
BUILD_VERSION=$4
PACKAGE_NAME=$5
ARCHITECTURES=${6:-"amd64"}
PWD=`pwd`
declare -a arr=("jammy" "noble" "questing")
declare -a architectures=(${ARCHITECTURES//,/ })
for i in "${arr[@]}"
do
    UBUNTU_DIST=$i
    mkdir -p deb/${UBUNTU_DIST}
    cd deb/${UBUNTU_DIST}
    for ARCH in ${architectures[@]}
    do
      wget https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_VERSION}%2B${BUILD_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}+${UBUNTU_DIST}_${ARCH}_ubu.deb || true
    done
    cd ../..
done
