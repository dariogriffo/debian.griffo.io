#!/bin/bash
#
# notify_failure.sh — OnFailure= handler for auto_publish.service.
#
# Everything here is automated and runs unattended every 30 minutes, including
# at 03:00. Without this, a failed publish is completely silent: the timer keeps
# firing, keeps failing, and the mirror quietly goes stale until someone reads
# the journal. This turns that into a push.
#
# Usage (from a unit):  OnFailure=notify-failure@%n.service
#
# Configuration lives OUTSIDE the repo so no endpoint or token is ever
# committed. Create ~/.config/deb-griffo/notify.env with any of:
#   NTFY_URL="https://ntfy.sh/<your-secret-topic>"   # or a self-hosted ntfy
#   MAIL_TO="dariogriffo@gmail.com"                  # needs a working sendmail
# If neither is set this still logs the failure to the journal and exits 0, so
# a missing config never masks the original error.
set -uo pipefail

UNIT="${1:-auto_publish.service}"
CONF="${HOME}/.config/deb-griffo/notify.env"
[[ -r "$CONF" ]] && . "$CONF"

CONTEXT="$(journalctl -u "$UNIT" -n 40 --no-pager -o cat 2>/dev/null)"
HOST="$(hostname -f 2>/dev/null || hostname)"
SUBJECT="[${HOST}] ${UNIT} FAILED"

# The most useful single line: which include reprepro rejected, if any.
FAILURES_FILE="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.index-failures"
DETAIL=""
[[ -s "$FAILURES_FILE" ]] && DETAIL="$(cat "$FAILURES_FILE")"

BODY="${DETAIL:+Rejected includes:
${DETAIL}

}Last 40 journal lines:
${CONTEXT}"

echo "$SUBJECT"
echo "$BODY"

if [[ -n "${NTFY_URL:-}" ]]; then
    curl -fsS --max-time 20 \
         -H "Title: ${SUBJECT}" \
         -H "Priority: high" \
         -H "Tags: rotating_light" \
         -d "${DETAIL:-$(echo "$CONTEXT" | tail -12)}" \
         "$NTFY_URL" >/dev/null || echo "notify: ntfy push failed"
fi

if [[ -n "${MAIL_TO:-}" ]] && command -v sendmail >/dev/null 2>&1; then
    printf 'From: %s\nTo: %s\nSubject: %s\nContent-Type: text/plain; charset=UTF-8\n\n%s\n' \
        "${MAIL_FROM:-$MAIL_TO}" "$MAIL_TO" "$SUBJECT" "$BODY" \
        | sendmail -t || echo "notify: mail failed"
fi

exit 0
