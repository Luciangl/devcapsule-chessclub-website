#!/usr/bin/env bash
# ==============================================================================
# Script 03: Build and Deploy Website to Google Cloud Storage
#
# Steps:
# 1. Builds the Astro static site (output in dist/).
# 2. Synchronizes dist/ to gs://<BUCKET_NAME> using gcloud storage rsync.
# 3. Applies optimal Cache-Control headers for high performance and fast updates:
#    - Long cache (1 year) for hashed assets in _astro/ (CSS, JS, optimized chunks).
#    - Short cache (5 minutes) for HTML pages to ensure new articles/updates appear quickly.
# ==============================================================================

set -euo pipefail

BUCKET_NAME="${1:-test1-chessclubwebsite-mycodespace}"
SITE_DIR="${2:-ag-flash3.8-site}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
TARGET_DIR="${REPO_ROOT}/${SITE_DIR}"

if [ ! -d "${TARGET_DIR}" ]; then
  echo "Error: Site directory not found at ${TARGET_DIR}" >&2
  exit 1
fi

echo "==> Building static site in ${SITE_DIR}..."
cd "${TARGET_DIR}"
npm run build

echo "==> Syncing build output (${TARGET_DIR}/dist/) to gs://${BUCKET_NAME}..."
gcloud storage rsync "${TARGET_DIR}/dist" "gs://${BUCKET_NAME}" \
    --recursive \
    --delete-unmatched-destination-objects

echo "==> Setting optimal Cache-Control headers..."

# 1. Immutable hashed assets (_astro/) can be cached for 1 year
echo "    - Setting 1-year cache on hashed assets (_astro/*)..."
gcloud storage objects update "gs://${BUCKET_NAME}/_astro/**" \
    --cache-control="public, max-age=31536000, immutable" || true

# 2. HTML pages get 5-minute cache with revalidation
echo "    - Setting 5-minute cache on HTML pages..."
gcloud storage objects update "gs://${BUCKET_NAME}/**/*.html" \
    --cache-control="public, max-age=300, must-revalidate" || true

echo "==> Deployment to gs://${BUCKET_NAME} finished successfully!"
