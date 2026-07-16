#!/bin/bash
#
# free_refresh.sh — daily free-lane sweep.
#
# The apt-free window ("newest version at least 2 months old, patches of that
# series immediate") advances with TIME, not only with releases: a version
# becomes free-eligible just by aging past the window, with no new upstream
# release to trigger auto_publish.sh. This sweep re-computes the free tag for
# every enrolled tool (any update_*_free.sh), stages changes, and publishes
# once — sharing auto_publish.sh's lock so reprepro/GPG/sync never run
# concurrently.
#
# Usage:
#   ./free_refresh.sh             # sweep, stage, index, sync
#   ./free_refresh.sh --dry-run   # report only
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKERS="${SCRIPT_DIR}/.versions-free"
LOCK_FILE="/tmp/auto_publish.lock"   # same lock as auto_publish.sh, on purpose
SYNC_CMD=(sudo "${SCRIPT_DIR}/sync_apt.sh")

DRY_RUN=0
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

log() { printf '%s %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$*"; }

exec 9>"$LOCK_FILE"
if ! flock -w 600 9; then
  log "Could not acquire publish lock within 10 minutes; exiting."
  exit 1
fi

cd "$SCRIPT_DIR"
mkdir -p "$MARKERS"

declare -a PENDING_NAME=()
declare -a PENDING_TAG=()
CHANGED=0
FAILURES=0

for script in update_*_free.sh; do
  [[ -f "$script" ]] || continue
  name="${script#update_}"; name="${name%_free.sh}"

  repo="$(grep -m1 -E '^REPO=' "$script" | cut -d= -f2- | tr -d '"'"'"' \r')"
  if [[ -z "$repo" ]]; then
    log "WARN  ${name}: no REPO= found in ${script}; skipping"; continue
  fi

  tag="$(./free_lane_tag.py "$repo" || true)"
  if [[ -z "$tag" ]]; then
    log "SKIP  ${name}: no free-lane candidate yet"; continue
  fi

  current="$(cat "${MARKERS}/${name}" 2>/dev/null || true)"
  if [[ "$tag" == "$current" ]]; then
    log "OK    ${name}: free lane up to date (${tag})"
    continue
  fi

  log "NEW   ${name}: free lane ${current:-<none>} -> ${tag}"
  [[ "$DRY_RUN" -eq 1 ]] && continue

  if ( set -e; "./${script}" ); then
    PENDING_NAME+=("$name")
    PENDING_TAG+=("$tag")
    CHANGED=1
  else
    log "FAIL  ${name}: ${script} exited non-zero; marker not advanced, will retry"
    FAILURES=$((FAILURES + 1))
  fi
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "DRY-RUN complete; no changes made."
  exit 0
fi

if [[ "$CHANGED" -eq 0 ]]; then
  log "Free lane unchanged; skipping index + sync."
  [[ "$FAILURES" -gt 0 ]] && exit 1
  exit 0
fi

log "Regenerating index (reprepro + sign, paid + free)..."
./generate_index.sh

log "Publishing (atomic A/B swap)..."
"${SYNC_CMD[@]}"

for i in "${!PENDING_NAME[@]}"; do
  printf '%s\n' "${PENDING_TAG[$i]}" > "${MARKERS}/${PENDING_NAME[$i]}"
done

log "Free lane published: ${PENDING_NAME[*]}"
[[ "$FAILURES" -gt 0 ]] && { log "Completed with ${FAILURES} failure(s)."; exit 1; }
log "Done."
