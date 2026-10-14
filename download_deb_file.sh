#!/bin/bash
# Debian, every suite. Thin wrapper over download_bin.sh (layouts, cleanup and
# the dist-agnostic/legacy switch are documented there).
#   download_deb_file.sh <repo> <version> <build> <package> [archs]
exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$3" "$4" "${5:-amd64}" debian \
     bookworm trixie forky sid
