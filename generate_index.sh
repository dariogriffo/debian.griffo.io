#!/bin/bash
set -e

current=$(pwd)
reprepro_dir="$current/reprepro"
GPG_KEY="EA0F721D231FDD3A0A17B9AC7808B4DD62C41256"

DISTS=("bookworm" "trixie" "forky" "sid" "jammy" "noble" "questing" "resolute")

cd apt

for dist in "${DISTS[@]}"; do
    echo "Processing distribution: $dist"

    if ls "$current/deb/$dist/"*deb >/dev/null 2>&1; then
        reprepro --dbdir "$reprepro_dir/db" --confdir "$reprepro_dir/conf" -C main includedeb "$dist" "$current/deb/$dist/"*deb
    else
        echo "  No .deb files for $dist, skipping."
    fi

    if ls "$current/src/"*~${dist}.dsc >/dev/null 2>&1; then
        for dsc in "$current/src/"*~${dist}.dsc; do
            reprepro --dbdir "$reprepro_dir/db" --confdir "$reprepro_dir/conf" -C main includedsc "$dist" "$dsc"
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
            reprepro --dbdir "$reprepro_free_dir/db" --confdir "$reprepro_free_dir/conf" -C main includedeb "$dist" "$current/free/deb/$dist/"*deb
        else
            echo "  No free-lane .deb files for $dist, skipping."
        fi

        if ls "$current/free/src/"*~${dist}.dsc >/dev/null 2>&1; then
            for dsc in "$current/free/src/"*~${dist}.dsc; do
                reprepro --dbdir "$reprepro_free_dir/db" --confdir "$reprepro_free_dir/conf" -C main includedsc "$dist" "$dsc"
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

echo "Done."
