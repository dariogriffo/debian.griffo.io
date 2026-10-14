#!/bin/bash
# Ubuntu counterpart of download_oldstable_deb_file.sh (package version differs
# from the release tag). No resolute: the zig-oldstable release predates it.
# Thin wrapper over download_bin.sh.
#   download_oldstable_ubuntu_file.sh <repo> <package_version> <release_version> <build> <package> [archs]
RELEASE_VERSION="$3" exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$4" "$5" "${6:-amd64}" ubuntu \
     jammy noble questing
