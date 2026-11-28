REPO=tree-sitter-grammars-debian
RELEASE_VERSION=$1
RELEASE_BUILD=${2:-1}
ARCHITECTURES="amd64,arm64,armhf,armel,i386,ppc64el,s390x,riscv64,loong64"

# One release holds every grammar, each package at its own upstream version
# and revision: grammars.list in the release names them ("<pkg> <ver> <rev>").
# download_bin.sh skips a file already staged, so a grammar that did not move
# keeps its pool copy, and drops the other versions of a grammar that did.
set -euo pipefail
export RELEASE_VERSION RELEASE_BUILD

LIST=$(mktemp)
trap 'rm -f "$LIST"' EXIT
wget -q -O "$LIST" \
    "${RELEASE_BASE_URL:-https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_VERSION}%2B${RELEASE_BUILD}}/grammars.list"
[ -s "$LIST" ] || { echo "empty grammars.list in ${RELEASE_VERSION}+${RELEASE_BUILD}"; exit 1; }

# A grammar dropped from the set leaves the mirror with it
mkdir -p deb
find deb -mindepth 2 -maxdepth 2 \( -type f -o -type l \) -name 'libtree-sitter-*_*' -print \
    | while read -r f; do
        pkg=$(basename "$f"); pkg=${pkg%%_*}
        grep -q "^${pkg} " "$LIST" || rm -f "$f"
    done

while read -r pkg ver rev; do
    ./download_deb_file.sh "${REPO}" "${ver}" "${rev}" "${pkg}" "${ARCHITECTURES}"
    ./download_ubuntu_file.sh "${REPO}" "${ver}" "${rev}" "${pkg}" "${ARCHITECTURES}"
done < "$LIST"

# The metapackage is versioned by the release itself
./download_deb_file.sh "${REPO}" "${RELEASE_VERSION}" "${RELEASE_BUILD}" tree-sitter-grammars all
./download_ubuntu_file.sh "${REPO}" "${RELEASE_VERSION}" "${RELEASE_BUILD}" tree-sitter-grammars all
