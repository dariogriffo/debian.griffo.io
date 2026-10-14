#!/bin/bash
#
# download_bin.sh — fetch one binary package from a packaging repo's GitHub
# release and stage it under deb/ for the given suites. The six
# download_*_file.sh scripts are thin wrappers that only pick the suite list.
#
#   download_bin.sh <repo> <package_version> <build_version> <package_name> \
#                   <architectures> <debian|ubuntu> <suite>...
#
# Env:
#   RELEASE_VERSION  version in the release tag when it differs from the
#                    package version (zig-oldstable); default <package_version>
#   EXCLUDE          "suite:arch" pairs to skip, e.g. "bookworm:riscv64 jammy:riscv64"
#                    for a build whose glibc floor only some suites meet
#   RELEASE_BASE_URL override the release download URL (tests only)
#
# Two release layouts are understood, newest first:
#
#  1. Dist-agnostic: <pkg>_<ver>-<build>_<arch>.deb — one file for every suite.
#     Downloaded once into deb/common/ and symlinked into deb/<suite>/ for each
#     suite given. reprepro's pool is keyed by filename+checksum, so including
#     the same file into eight suites stores it once; the links are the
#     per-suite view generate_index.sh walks.
#  2. Per-suite (legacy): <pkg>_<ver>-<build>~<suite>_<arch>[_ubu].deb saved
#     into deb/<suite>/. GitHub mangles ~ to . in asset names, so the . spelling
#     is tried next (and saved back under the ~ name); the oldest repos still
#     use +<suite>.
#
# A packaging repo switches layouts simply by releasing agnostic assets;
# nothing here keeps a list of who has migrated.
#
# Before downloading, every other version of <package_name> staged under deb/
# is removed (files and links; the "<name>_" anchor keeps ghostty_* from
# matching ghostty-tip_*), then dangling links are pruned. The update_*.sh
# scripts' own `find -type f -delete` lines don't see symlinks, so this is
# where a previous version's links go away.

REPO=$1
PACKAGE_VERSION=$2
BUILD_VERSION=$3
PACKAGE_NAME=$4
IFS=',' read -r -a ARCHS <<< "${5:-amd64}"
FLAVOUR=$6
shift 6
SUITES=("$@")

if [ -z "$REPO" ] || [ -z "$PACKAGE_VERSION" ] || [ -z "$BUILD_VERSION" ] \
   || [ -z "$PACKAGE_NAME" ] || [ ${#SUITES[@]} -eq 0 ]; then
    echo "usage: $0 <repo> <version> <build> <package> <archs> <debian|ubuntu> <suite>..." >&2
    exit 2
fi

case "$FLAVOUR" in
    debian) SUFFIX="" ;;
    ubuntu) SUFFIX="_ubu" ;;
    *) echo "$0: flavour must be debian or ubuntu, got '$FLAVOUR'" >&2; exit 2 ;;
esac

RELEASE_VERSION=${RELEASE_VERSION:-$PACKAGE_VERSION}
BASE_URL=${RELEASE_BASE_URL:-https://github.com/dariogriffo/${REPO}/releases/download/${RELEASE_VERSION}%2B${BUILD_VERSION}}
CURRENT="${PACKAGE_NAME}_${PACKAGE_VERSION}-${BUILD_VERSION}"

excluded() {
    case " ${EXCLUDE:-} " in
        *" $1:$2 "*) return 0 ;;
    esac
    return 1
}

mkdir -p deb/common
for suite in "${SUITES[@]}"; do
    mkdir -p "deb/${suite}"
done

# Other versions of this package, whatever the layout, then dangling links.
find deb -mindepth 2 -maxdepth 2 \( -type f -o -type l \) -name "${PACKAGE_NAME}_*" \
     ! -name "${CURRENT}_*" ! -name "${CURRENT}[~.+]*" -delete
find deb -mindepth 2 -maxdepth 2 -xtype l -delete

for ARCH in "${ARCHS[@]}"; do
    AGNOSTIC="${CURRENT}_${ARCH}.deb"

    # The debian and ubuntu wrappers run back to back for the same release, so
    # the second one finds the file already in common/ and only adds links.
    if [ ! -f "deb/common/${AGNOSTIC}" ]; then
        if wget -nv -O "deb/common/${AGNOSTIC}.part" "${BASE_URL}/${AGNOSTIC}" 2>/dev/null; then
            mv "deb/common/${AGNOSTIC}.part" "deb/common/${AGNOSTIC}"
        else
            rm -f "deb/common/${AGNOSTIC}.part"
        fi
    fi

    if [ -f "deb/common/${AGNOSTIC}" ]; then
        for suite in "${SUITES[@]}"; do
            excluded "$suite" "$ARCH" && continue
            ln -sfn "../common/${AGNOSTIC}" "deb/${suite}/${AGNOSTIC}"
            echo "  [LINK]   deb/${suite}/${AGNOSTIC} -> common"
        done
        continue
    fi

    # Legacy per-suite assets.
    for suite in "${SUITES[@]}"; do
        excluded "$suite" "$ARCH" && continue
        TILDE_NAME="${CURRENT}~${suite}_${ARCH}${SUFFIX}.deb"
        DOT_NAME="${CURRENT}.${suite}_${ARCH}${SUFFIX}.deb"
        PLUS_NAME="${CURRENT}+${suite}_${ARCH}${SUFFIX}.deb"
        (
            cd "deb/${suite}" || exit 1
            if wget "${BASE_URL}/${TILDE_NAME}"; then
                :
            elif wget "${BASE_URL}/${DOT_NAME}"; then
                mv "${DOT_NAME}" "${TILDE_NAME}"
            else
                wget "${BASE_URL}/${PLUS_NAME}" || true
            fi
        )
    done
done
