#!/bin/bash
# Debian, every suite, for a package whose version differs from the release
# tag it ships in (zig-oldstable rides the zig-stable release). Thin wrapper
# over download_bin.sh.
#   download_oldstable_deb_file.sh <repo> <package_version> <release_version> <build> <package> [archs]
RELEASE_VERSION="$3" exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$4" "$5" "${6:-amd64}" debian \
     bookworm trixie forky sid
