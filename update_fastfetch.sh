PACKAGE_VERSION=$1
PWD=`pwd`
declare -a arr=("bookworm" "trixie" "forky" "sid")
declare -a architectures=("amd64" "aarch64" "armv6l" "armv7l" "ppc64le" "riscv64" "s390x")
for i in "${arr[@]}"
do
    DEBIAN_DIST=$i
    cd deb/${DEBIAN_DIST}
    for ARCH in ${architectures[@]}
    do  
      wget https://github.com/fastfetch-cli/fastfetch/releases/download/${PACKAGE_VERSION}/fastfetch-linux-${ARCH}.deb
    done 
    cd ../..
done
./generate_index.sh
git add .
git commit -m "Update fastfetch to ${PACKAGE_VERSION}"
git push -u origin main
