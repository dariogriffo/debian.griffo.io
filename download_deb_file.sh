REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
PWD=`pwd`
declare -a arr=("bookworm" "trixie" "sid")
for i in "${arr[@]}"
do
    DEBIAN_DIST=$i
    cd deb/${DEBIAN_DIST}
    wget https://github.com/dariogriffo/${REPO}/releases/download/${PACKAGE_VERSION}%2B${BUILD_VERSION}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}+${DEBIAN_DIST}_amd64.deb
    cd ../..
done
