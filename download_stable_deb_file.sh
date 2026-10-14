#!/bin/bash
# Debian without bookworm, for tools whose build needs newer libraries than
# oldstable has (ghostty: GTK 4.14). Thin wrapper over download_bin.sh.
#   download_stable_deb_file.sh <repo> <version> <build> <package> [archs]
exec "$(dirname "$0")/download_bin.sh" "$1" "$2" "$3" "$4" "${5:-amd64}" debian \
     trixie forky sid
