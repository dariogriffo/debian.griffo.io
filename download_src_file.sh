REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
PWD=`pwd`

RELEASE_TAG="${PACKAGE_VERSION}%2B${BUILD_VERSION}"
BASE_URL="https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_TAG}"

mkdir -p src

cd src

# .orig.tar.gz is shared across all distributions — download once
wget -q "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.gz" || true

declare -a DEBIAN_DISTS=("bookworm" "trixie" "forky" "sid")
declare -a UBUNTU_DISTS=("jammy" "noble" "questing" "resolute")
declare -a ALL_DISTS=("${DEBIAN_DISTS[@]}" "${UBUNTU_DISTS[@]}")

for DIST in "${ALL_DISTS[@]}"
do
    wget -q "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${DIST}.dsc" || true
    wget -q "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${DIST}.debian.tar.xz" || true
done

cd ${PWD}
