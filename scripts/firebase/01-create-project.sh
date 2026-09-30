#!/usr/bin/env bash
# Creates a NEW project only. Existing projects are never modified by this step.
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
[[ "${1:-}" != --help ]] || { echo 'Usage: 01-create-project.sh NEW_PROJECT_ID'; exit 0; }
[[ $# -le 1 ]] || fail 'Usage: 01-create-project.sh NEW_PROJECT_ID'
set_project "${1:-}"
require_tools
printf 'Creating a separate, unbilled project: %s\n' "$PROJECT_ID"
gcloud projects create "$PROJECT_ID" --name="Rocada Spark Hosting" --quiet
assert_spark
# No billing account, Analytics, database, Storage bucket, or App Hosting provisioned.
"$FIREBASE_CLI" projects:addfirebase "$PROJECT_ID" --project "$PROJECT_ID" --non-interactive
assert_spark
printf 'Project ready. Next: %s/02-deploy.sh %s\n' "$FIREBASE_SCRIPT_DIR" "$PROJECT_ID"
