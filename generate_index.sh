#!/bin/bash
set -e

current=$(pwd)
reprepro_dir="$current/reprepro"
GPG_KEY="EA0F721D231FDD3A0A17B9AC7808B4DD62C41256"

DISTS=("bookworm" "trixie" "forky" "sid" "jammy" "noble" "questing" "resolute")

# One rejected include must not stall the whole mirror.
#
# reprepro refuses a source package whose .orig.tar.gz differs byte-for-byte
# from the copy already in the pool (a pool holds one orig tarball per upstream
# version, shared by every suite and revision). Under a bare `set -e` that one
# refusal aborted this script, so auto_publish.sh never reached sync_apt.sh, no
# package went live, no marker advanced — and the next run failed identically
# 30 minutes later. Failures are collected and reported instead, so everything
# that CAN be published still is.
FAILURES_FILE="$current/.index-failures"
: > "$FAILURES_FILE"

try_include_in() {
    # try_include_in <reprepro-dir> <lane> <what> <dist> <file...>
    local rdir=$1 lane=$2 what=$3 dist=$4; shift 4
    if reprepro --dbdir "$rdir/db" --confdir "$rdir/conf" \
                -C main "$what" "$dist" "$@"; then
        return 0
    fi
    echo "  !! FAILED ${lane} ${what} ${dist}: $*" | tee -a "$FAILURES_FILE"
    return 0
}

try_include() { try_include_in "$reprepro_dir" main "$@"; }
try_include_free() { try_include_in "$reprepro_free_dir" free "$@"; }

cd apt

for dist in "${DISTS[@]}"; do
    echo "Processing distribution: $dist"

    if ls "$current/deb/$dist/"*deb >/dev/null 2>&1; then
        for deb in "$current/deb/$dist/"*deb; do
            try_include includedeb "$dist" "$deb"
        done
    else
        echo "  No .deb files for $dist, skipping."
    fi

    if ls "$current/src/"*~${dist}.dsc >/dev/null 2>&1; then
        for dsc in "$current/src/"*~${dist}.dsc; do
            try_include includedsc "$dist" "$dsc"
        done
    else
        echo "  No .dsc files for $dist, skipping."
    fi

    cd "dists/$dist"
    cat Release | gpg -s --default-key "$GPG_KEY" -abs > Release.gpg
    cd - > /dev/null
done

cd "$current"

# --- Free lane: staged under free/, indexed into apt-free (own reprepro db) ---
reprepro_free_dir="$current/reprepro-free"
if ls "$current/free/deb/"*/*deb >/dev/null 2>&1 || ls "$current/free/src/"*.dsc >/dev/null 2>&1; then
    mkdir -p "$reprepro_free_dir/db" "$current/apt-free"
    cd "$current/apt-free"

    for dist in "${DISTS[@]}"; do
        echo "Processing free-lane distribution: $dist"

        if ls "$current/free/deb/$dist/"*deb >/dev/null 2>&1; then
            for deb in "$current/free/deb/$dist/"*deb; do
                try_include_free includedeb "$dist" "$deb"
            done
        else
            echo "  No free-lane .deb files for $dist, skipping."
        fi

        if ls "$current/free/src/"*~${dist}.dsc >/dev/null 2>&1; then
            for dsc in "$current/free/src/"*~${dist}.dsc; do
                try_include_free includedsc "$dist" "$dsc"
            done
        else
            echo "  No free-lane .dsc files for $dist, skipping."
        fi

        if [ -f "dists/$dist/Release" ]; then
            cd "dists/$dist"
            cat Release | gpg -s --default-key "$GPG_KEY" -abs > Release.gpg
            cd - > /dev/null
        fi
    done

    cd "$current"
fi

if [ -s "$FAILURES_FILE" ]; then
    echo ""
    echo "=============================================================="
    echo "INDEXED WITH FAILURES — the following includes were rejected:"
    cat "$FAILURES_FILE"
    echo ""
    echo "Everything else was indexed and will be published. The usual"
    echo "cause is an .orig.tar.gz that differs from the copy already in"
    echo "the pool for that upstream version; see the repack note in the"
    echo "packaging repo's build_src.sh. To replace a stale source:"
    echo "  reprepro --dbdir reprepro/db --confdir reprepro/conf \\"
    echo "           removesrc <suite> <source-name> <version>"
    echo "=============================================================="
    echo "Done (with failures)."
    # Non-zero so systemd marks the unit failed and OnFailure= notifies.
    # auto_publish.sh still publishes everything that indexed cleanly.
    exit 1
fi

echo "Done."
