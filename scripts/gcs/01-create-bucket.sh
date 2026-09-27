#!/usr/bin/env bash
# ==============================================================================
# Script 01: Create Google Cloud Storage Bucket for Static Website
#
# Lessons Learned Incorporated:
# 1. Project parameterization: explicitly pass --project to ensure creation
#    in the target resource project (default: mycodespace3p).
# 2. Regional storage in Finland: defaults to europe-north1 (Hamina, Finland)
#    for optimal latency and low cost for Romanian and European visitors.
# 3. Automatic API enablement: enables storage.googleapis.com non-interactively.
# 4. Global namespace collision handling: detects if bucket name (e.g. test2)
#    is already claimed globally and offers clean alternatives.
# 5. Public Access Prevention: explicitly disabled (--no-public-access-prevention)
#    to permit public static web traffic.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

# Parameters (CLI arguments take precedence over config.env)
BUCKET_NAME="${1:-${BUCKET_NAME:-test2-smartgalati-mycodespace}}"
LOCATION="${2:-${LOCATION:-europe-north1}}"
STORAGE_CLASS="${3:-${STORAGE_CLASS:-STANDARD}}"
PROJECT_ID="${4:-${PROJECT_ID:-mycodespace3p}}"

log_info "Configuration for GCS Bucket Creation:"
echo "    - Bucket Name:    gs://${BUCKET_NAME}"
echo "    - Target Project: ${PROJECT_ID}"
echo "    - Region:         ${LOCATION} (Finland)"
echo "    - Storage Class:  ${STORAGE_CLASS}"
echo "    - Uniform Bucket: Enabled"
echo "    - Public Access:  Prevention Disabled (required for public static hosting)"

# Ensure storage API is active in target project
ensure_api_enabled "${PROJECT_ID}" "storage.googleapis.com"

# Check if bucket already exists
if gcloud storage buckets describe "gs://${BUCKET_NAME}" --project="${PROJECT_ID}" &>/dev/null; then
  log_success "Bucket gs://${BUCKET_NAME} already exists in project [${PROJECT_ID}]. Ready for configuration."
  echo "==> Next step: Run ./scripts/gcs/02-configure-website.sh ${BUCKET_NAME} ${PROJECT_ID}"
  exit 0
fi

log_info "Creating bucket gs://${BUCKET_NAME} in project [${PROJECT_ID}]..."
if ! gcloud storage buckets create "gs://${BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --default-storage-class="${STORAGE_CLASS}" \
    --location="${LOCATION}" \
    --uniform-bucket-level-access \
    --no-public-access-prevention; then
  log_error "Failed to create bucket gs://${BUCKET_NAME}."
  echo ""
  log_warn "NOTE: Google Cloud Storage bucket names are globally unique across all Google Cloud accounts worldwide."
  log_warn "If 'test2' is already reserved by someone else, please re-run with a unique name, e.g.:"
  log_warn "    ./scripts/gcs/01-create-bucket.sh ${BUCKET_NAME}-${PROJECT_ID} ${LOCATION} ${STORAGE_CLASS} ${PROJECT_ID}"
  exit 1
fi

log_success "Bucket gs://${BUCKET_NAME} created successfully in [${PROJECT_ID}] (Region: ${LOCATION})."
echo "==> Next step: Run ./scripts/gcs/02-configure-website.sh ${BUCKET_NAME} ${PROJECT_ID}"
