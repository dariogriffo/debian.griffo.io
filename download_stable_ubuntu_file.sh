#!/bin/bash
# Ubuntu releases new enough for tools that can't build on jammy (GTK 4.6),
# the Ubuntu counterpart of download_stable_deb_file.sh dropping bookworm.
# Thin wrapper over download_bin.sh.
#   download_stable_ubuntu_file.sh <repo> <version> <build> <package> [archs]
exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$3" "$4" "${5:-amd64}" ubuntu \
     noble questing resolute
