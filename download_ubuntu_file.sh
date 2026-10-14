#!/bin/bash
# Ubuntu, every suite. Thin wrapper over download_bin.sh (layouts, cleanup and
# the dist-agnostic/legacy switch are documented there).
#   download_ubuntu_file.sh <repo> <version> <build> <package> [archs]
exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$3" "$4" "${5:-amd64}" ubuntu \
     jammy noble questing resolute
