#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
[[ "${1:-}" != --help ]] || { echo 'Usage: 03-check-status.sh PROJECT_ID'; exit 0; }
[[ $# -le 1 ]] || fail 'Usage: 03-check-status.sh PROJECT_ID'
set_project "${1:-}"
require_tools
assert_spark
"$FIREBASE_CLI" hosting:sites:get "$PROJECT_ID" --project "$PROJECT_ID" --non-interactive
node "${FIREBASE_SCRIPT_DIR}/check-http.mjs" "$SITE_URL"
