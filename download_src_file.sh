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

http_status() {
    wget -q --server-response "$1" -O /dev/null 2>&1 | grep "HTTP/" | tail -1 | awk '{print $2}'
}

download_file() {
    local url=$1
    local dest=$2  # local filename to save as (may differ from url basename)
    local status=$(http_status "$url")
    if [ "$status" = "200" ]; then
        wget -q "$url" -O "$dest"
        echo "  [OK]     $dest"
    else
        echo "  [SKIP]   $(basename "$url") (HTTP ${status:-error})"
    fi
}

# Try a URL with the tilde name; fall back to dot name (GitHub Actions mangles ~ to . in artifacts).
# Either way, save the file under the tilde name so reprepro can match it to the .dsc checksums.
download_src_pair() {
    local dist=$1
    for ext in dsc "debian.tar.xz"; do
        local tilde_name="${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}~${dist}.${ext}"
        local dot_name="${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}.${dist}.${ext}"
        local tilde_status=$(http_status "${BASE_URL}/${tilde_name}")
        if [ "$tilde_status" = "200" ]; then
            wget -q "${BASE_URL}/${tilde_name}" -O "$tilde_name"
            echo "  [OK]     $tilde_name"
        else
            local dot_status=$(http_status "${BASE_URL}/${dot_name}")
            if [ "$dot_status" = "200" ]; then
                wget -q "${BASE_URL}/${dot_name}" -O "$tilde_name"
                echo "  [OK]     $dot_name -> renamed to $tilde_name"
            else
                echo "  [SKIP]   $tilde_name (tried ~ HTTP ${tilde_status:-error}, tried . HTTP ${dot_status:-error})"
            fi
        fi
    done
}

# .orig.tar.gz is shared across all distributions — download once
ORIG_FILE="${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.gz"
echo "Downloading orig tarball..."
download_file "${BASE_URL}/${ORIG_FILE}" "${ORIG_FILE}"
echo ""

declare -a DEBIAN_DISTS=("bookworm" "trixie" "forky" "sid")
declare -a UBUNTU_DISTS=("jammy" "noble" "questing" "resolute")
declare -a ALL_DISTS=("${DEBIAN_DISTS[@]}" "${UBUNTU_DISTS[@]}")

echo "Downloading per-distribution source packages..."
for DIST in "${ALL_DISTS[@]}"
do
    download_src_pair "$DIST"
done

echo ""
echo "Done. Files in src/:"
ls -lh
cd ${ORIG_PWD}
