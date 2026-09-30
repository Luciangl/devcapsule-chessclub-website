#!/usr/bin/env bash
# Shared by the Spark-only Hosting commands. Deliberately independent of scripts/gcs.
set -euo pipefail
FIREBASE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${FIREBASE_SCRIPT_DIR}/../.." && pwd)"
FIREBASE_CLI="${FIREBASE_SCRIPT_DIR}/node_modules/.bin/firebase"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
require_node() {
  command -v node >/dev/null || fail 'Node 22 is required.'
  [[ "$(node -p 'process.versions.node.split(".")[0]')" == 22 ]] || fail 'Use Node 22, as required by the Rocada site.'
}
set_project() {
  PROJECT_ID="${1:-${FIREBASE_PROJECT_ID:-}}"
  [[ "$PROJECT_ID" =~ ^[a-z][a-z0-9-]{4,28}[a-z0-9]$ ]] || fail 'Supply a Google project ID (6–30 lowercase letters/digits/hyphens), not an alias.'
}
set_site_url() {
  require_node
  SITE_URL="$(node "${FIREBASE_SCRIPT_DIR}/hosting.mjs" origin "${FIREBASE_SITE_URL-https://${PROJECT_ID}.web.app}")" || fail 'Invalid public site URL; no deployment performed.'
}
require_tools() {
  require_node
  if ! command -v gcloud >/dev/null; then
    for sdk in /home/devcapsule/xtras/google-cloud-sdk "${HOME}/xtras/google-cloud-sdk"; do
      if [[ -x "${sdk}/bin/gcloud" ]]; then export PATH="${sdk}/bin:${PATH}"; break; fi
    done
  fi
  command -v gcloud >/dev/null || fail 'Install Google Cloud CLI and run gcloud auth login.'
  [[ -x "$FIREBASE_CLI" ]] || fail 'Run npm ci --prefix scripts/firebase, then scripts/firebase/node_modules/.bin/firebase login.'
}
assert_spark() {
  local billing
  # API failure, missing fields, linked-but-disabled billing, and Blaze all fail closed.
  billing="$(gcloud billing projects describe "$PROJECT_ID" --format=json)" || fail 'Cannot verify billing. Check login and permission to read project billing information; nothing will be deployed.'
  printf '%s' "$billing" | node "${FIREBASE_SCRIPT_DIR}/hosting.mjs" billing "$PROJECT_ID"
}
