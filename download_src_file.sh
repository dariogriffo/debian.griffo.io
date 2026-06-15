REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
ORIG_PWD=`pwd`

RELEASE_TAG="${PACKAGE_VERSION}%2B${BUILD_VERSION}"
BASE_URL="https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_TAG}"

echo "=== download_src_file ==="
echo "  repo:    ${REPO}"
echo "  package: ${PACKAGE_NAME}"
echo "  version: ${PACKAGE_VERSION}"
echo "  build:   ${BUILD_VERSION}"
echo "  base url: ${BASE_URL}"
echo ""

mkdir -p src
cd src

download_file() {
    local url=$1
    local filename=$(basename "$url")
    if wget -q --server-response "$url" 2>&1 | grep -q "HTTP/.*200"; then
        wget -q "$url" -O "$filename"
        echo "  [OK]     $filename"
    else
        local status=$(wget -q --server-response "$url" -O /dev/null 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}')
        echo "  [SKIP]   $filename (HTTP ${status:-error})"
    fi
}

# .orig.tar.gz is shared across all distributions — download once
ORIG_FILE="${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.gz"
echo "Downloading orig tarball..."
download_file "${BASE_URL}/${ORIG_FILE}"
echo ""

declare -a DEBIAN_DISTS=("bookworm" "trixie" "forky" "sid")
declare -a UBUNTU_DISTS=("jammy" "noble" "questing" "resolute")
declare -a ALL_DISTS=("${DEBIAN_DISTS[@]}" "${UBUNTU_DISTS[@]}")

echo "Downloading per-distribution source packages..."
for DIST in "${ALL_DISTS[@]}"
do
    download_file "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${DIST}.dsc"
    download_file "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${DIST}.debian.tar.xz"
done

echo ""
echo "Done. Files in src/:"
ls -lh
cd ${ORIG_PWD}
