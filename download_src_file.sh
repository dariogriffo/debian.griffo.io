#!/bin/bash
#
# download_src_file.sh — fetch a source package (.dsc, .debian.tar.xz, orig
# tarball) from a packaging repo's GitHub release and stage it under src/.
#
#   download_src_file.sh <repo> <version> <build> <source_package_name>
#
# Env:
#   SRC_SUITES       suites that get the dist-agnostic .dsc; default: the suites
#                    that have a binary of this package staged under deb/, or
#                    every suite when none has
#   DIST_TAG         tag after the ~ in dist-agnostic names; default griffo
#   RELEASE_BASE_URL override the release download URL (tests only)
#
# Two release layouts are understood, newest first (see download_bin.sh for
# the binary side of the same story):
#
#  1. Dist-agnostic: <pkg>_<ver>-<build>~griffo.dsc — one source package for
#     every suite (the ~ is explained in download_bin.sh; GitHub's ~ -> .
#     mangling is undone here as well, since the .dsc names its
#     .debian.tar.xz with the ~). The .dsc, its .debian.tar.xz and the orig
#     tarball are kept together in src/common/ (reprepro resolves a .dsc's
#     Files next to the .dsc), and the .dsc is symlinked into src/<suite>/ for
#     each suite.
#  2. Per-suite (legacy): <pkg>_<ver>-<build>~<suite>.dsc, saved flat in src/,
#     with GitHub's ~ -> . mangling undone on the way. The orig tarball is
#     shared and sits next to them.
REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
ORIG_PWD=`pwd`

RELEASE_TAG="${PACKAGE_VERSION}%2B${BUILD_VERSION}"
BASE_URL="${RELEASE_BASE_URL:-https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_TAG}}"

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
    # Status lines only: a "Server: SimpleHTTP/0.6" header also contains HTTP/.
    wget -q --server-response "$1" -O /dev/null 2>&1 | grep -E '^ *HTTP/[0-9]' | tail -1 | awk '{print $2}'
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

# The orig tarball's compression follows whatever upstream ships (fish, for
# instance, releases a .tar.xz), so try each in turn and stop at the one that
# exists. Prints the asset name, or nothing.
find_orig() {
    local ext
    for ext in gz xz bz2; do
        if [ "$(http_status "${BASE_URL}/${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.${ext}")" = "200" ]; then
            echo "${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.${ext}"
            return
        fi
    done
}

declare -a DEBIAN_DISTS=("bookworm" "trixie" "forky" "sid")
declare -a UBUNTU_DISTS=("jammy" "noble" "questing" "resolute")
declare -a ALL_DISTS=("${DEBIAN_DISTS[@]}" "${UBUNTU_DISTS[@]}")

# Other versions of this source package in common/ and the suite dirs (files
# and links), then dangling links. The flat legacy files are the update
# script's business, as before. The orig tarball is named <pkg>_<ver>.orig...,
# hence the [.-] after the version.
CURRENT="${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}"
DIST_TAG=${DIST_TAG:-griffo}
find . -mindepth 2 -maxdepth 2 \( -type f -o -type l \) -name "${PACKAGE_NAME}_*" \
     ! -name "${PACKAGE_NAME}_${PACKAGE_VERSION}[.-]*" -delete 2>/dev/null
find . -mindepth 2 -maxdepth 2 -xtype l -delete 2>/dev/null

AGNOSTIC="${CURRENT}~${DIST_TAG}"
AGNOSTIC_DSC="${AGNOSTIC}.dsc"
AGNOSTIC_ASSET=""
for candidate in "${AGNOSTIC}" "${CURRENT}.${DIST_TAG}"; do
    if [ "$(http_status "${BASE_URL}/${candidate}.dsc")" = "200" ]; then
        AGNOSTIC_ASSET="$candidate"
        break
    fi
done
if [ -n "$AGNOSTIC_ASSET" ]; then
    echo "Downloading dist-agnostic source package into src/common/..."
    mkdir -p common
    download_file "${BASE_URL}/${AGNOSTIC_ASSET}.dsc" "common/${AGNOSTIC_DSC}"
    download_file "${BASE_URL}/${AGNOSTIC_ASSET}.debian.tar.xz" "common/${AGNOSTIC}.debian.tar.xz"
    ORIG_FILE="$(find_orig)"
    if [ -n "$ORIG_FILE" ]; then
        download_file "${BASE_URL}/${ORIG_FILE}" "common/${ORIG_FILE}"
    else
        echo "  [SKIP]   ${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.* (not published)"
    fi

    # Which suites get this source: the ones serving a binary of it, so a
    # package kept out of bookworm (glibc floor) has no source there either.
    if [ -z "${SRC_SUITES:-}" ]; then
        for DIST in "${ALL_DISTS[@]}"; do
            if ls "../deb/${DIST}/${AGNOSTIC}_"*.deb >/dev/null 2>&1; then
                SRC_SUITES="${SRC_SUITES:+$SRC_SUITES }${DIST}"
            fi
        done
        [ -n "${SRC_SUITES:-}" ] || SRC_SUITES="${ALL_DISTS[*]}"
    fi
    echo ""
    echo "Linking into suites: ${SRC_SUITES}"
    for DIST in ${SRC_SUITES}; do
        mkdir -p "${DIST}"
        ln -sfn "../common/${AGNOSTIC_DSC}" "${DIST}/${AGNOSTIC_DSC}"
        echo "  [LINK]   src/${DIST}/${AGNOSTIC_DSC} -> common"
    done
else
    echo "Downloading orig tarball..."
    ORIG_FILE="$(find_orig)"
    if [ -n "$ORIG_FILE" ]; then
        download_file "${BASE_URL}/${ORIG_FILE}" "${ORIG_FILE}"
    else
        echo "  [SKIP]   ${PACKAGE_NAME}_${PACKAGE_VERSION}.orig.tar.* (not published)"
    fi
    echo ""

    echo "Downloading per-distribution source packages..."
    for DIST in "${ALL_DISTS[@]}"
    do
        download_src_pair "$DIST"
    done
fi

echo ""
echo "Done. Files in src/:"
ls -lh
cd ${ORIG_PWD}
