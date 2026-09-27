#!/usr/bin/env bash
# ==============================================================================
# Script 02: Configure GCS Bucket for Static Website Serving & Public Access
#
# Lessons Learned Incorporated:
# 1. Project parameterization: pass --project explicitly for all bucket operations.
# 2. Domain-Restricted Sharing (Org Policy 412 error):
#    Detects if constraints/iam.allowedPolicyMemberDomains blocks allUsers.
#    Automatically applies or assists with project-level policy override.
# 3. IAM Propagation Delay:
#    Includes retry logic to account for GCP eventual consistency after policy updates.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

BUCKET_NAME="${1:-${BUCKET_NAME:-test2}}"
PROJECT_ID="${2:-${PROJECT_ID:-mycodespace3p}}"

log_info "Configuring website index (index.html) and error page (404.html) for gs://${BUCKET_NAME}..."
gcloud storage buckets update "gs://${BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --web-main-page-suffix="index.html" \
    --web-error-page="404.html"

log_info "Ensuring Public Access Prevention is disabled..."
gcloud storage buckets update "gs://${BUCKET_NAME}" \
    --project="${PROJECT_ID}" \
    --no-public-access-prevention

log_info "Granting public read permissions (allUsers -> roles/storage.objectViewer)..."

bind_iam_policy() {
  gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
      --project="${PROJECT_ID}" \
      --member="allUsers" \
      --role="roles/storage.objectViewer"
}

set +e
BIND_OUTPUT=$(bind_iam_policy 2>&1)
BIND_STATUS=$?
set -e

if [ ${BIND_STATUS} -ne 0 ]; then
  if echo "${BIND_OUTPUT}" | grep -qE "412|permitted customer|allowedPolicyMemberDomains"; then
    log_warn "Encountered Organization Policy restriction: Domain-Restricted Sharing (HTTP 412)."
    log_info "Attempting to apply project-level override for project [${PROJECT_ID}]..."
    
    if override_domain_restricted_sharing "${PROJECT_ID}"; then
      log_info "Retrying IAM policy binding with propagation buffer..."
      RETRIES=3
      SUCCESS=false
      for ((i=1; i<=RETRIES; i++)); do
        log_info "Attempt ${i}/${RETRIES}..."
        if bind_iam_policy; then
          SUCCESS=true
          break
        fi
        sleep 10
      done
      
      if [ "${SUCCESS}" = "false" ]; then
        log_error "IAM binding still pending propagation. Please re-run ./02-configure-website.sh in 30 seconds."
        exit 1
      fi
    else
      log_error "Please override 'Domain restricted sharing' in GCP Console before continuing:"
      echo "  1. Open: https://console.cloud.google.com/iam-admin/orgpolicies/iam.allowedPolicyMemberDomains?project=${PROJECT_ID}"
      echo "  2. Click 'Manage Policy' -> 'Override parent's policy' -> Rules: 'Allow all'."
      echo "  3. Click Save, then re-run this script."
      exit 1
    fi
  else
    log_error "Failed to add IAM policy binding: ${BIND_OUTPUT}"
    exit 1
  fi
fi

log_success "Bucket gs://${BUCKET_NAME} is fully configured for public web hosting in project [${PROJECT_ID}]."
echo "==> Next step: Run ./scripts/gcs/03-deploy-site.sh ${BUCKET_NAME} ${SITE_DIR} ${PROJECT_ID}"
