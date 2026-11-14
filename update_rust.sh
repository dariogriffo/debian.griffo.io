REPO=rust-stable-debian
PACKAGE_VERSION=$1
BUILD_VERSION=${2:-1}
PWD=$(pwd)

# Prefix-anchored cleanup so this only clears rust-stable's own staged debs.
# The trailing underscore keeps "rust-stable_*" from matching other packages,
# and since it does not match "rust-stable-src_*" etc. every binary package
# is listed explicitly.
find deb/ -mindepth 2 -type f \( \
    -name "rust-stable_*.deb" \
    -o -name "rust-stable-std-musl_*.deb" \
    -o -name "rust-stable-src_*.deb" \
    -o -name "rust-stable-doc_*.deb" \
    -o -name "rust-stable-std-wasm32-unknown-unknown_*.deb" \
    -o -name "rust-stable-std-wasm32-wasip1_*.deb" \
    -o -name "rust-stable-std-wasm32-wasip2_*.deb" \
  \) -delete

# amd64 + arm64 binary packages — Debian and Ubuntu
for PKG in rust-stable rust-stable-std-musl; do
  ./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} amd64,arm64
  ./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} amd64,arm64
done

# architecture-independent packages (arch: all)
for PKG in rust-stable-src rust-stable-doc rust-stable-std-wasm32-unknown-unknown rust-stable-std-wasm32-wasip1 rust-stable-std-wasm32-wasip2; do
  ./download_deb_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} all
  ./download_ubuntu_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PKG} all
done

PACKAGE_NAME=rust-stable
cd ${PWD}

find src/ -type f -name "${PACKAGE_NAME}_*" -delete 2>/dev/null || true
./download_src_file.sh ${REPO} ${PACKAGE_VERSION} ${BUILD_VERSION} ${PACKAGE_NAME}
