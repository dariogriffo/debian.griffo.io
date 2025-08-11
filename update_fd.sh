PACKAGE_VERSION=$1
wget https://github.com/sharkdp/fd/releases/download/v${PACKAGE_VERSION}/fd-musl_${PACKAGE_VERSION}_amd64.deb
cp fd-musl_${PACKAGE_VERSION}_amd64.deb deb/bookworm
cp fd-musl_${PACKAGE_VERSION}_amd64.deb deb/trixie
cp fd-musl_${PACKAGE_VERSION}_amd64.deb deb/forky
cp fd-musl_${PACKAGE_VERSION}_amd64.deb deb/sid
./generate_index.sh

git add .
git commit -m "Update fd to ${BUILD_VERSION}"
git push -u origin main

