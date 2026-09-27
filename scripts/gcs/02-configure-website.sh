#!/usr/bin/env bash
# ==============================================================================
# Script 02: Configure GCS Bucket for Static Website Serving & Public Access
#
# Configures:
# 1. Web main page suffix (index.html) and error page (404.html).
# 2. Ensures Public Access Prevention is turned off if enabled earlier.
# 3. Grants allUsers the roles/storage.objectViewer role (public read).
# ==============================================================================

set -euo pipefail

BUCKET_NAME="${1:-test1-chessclubwebsite-mycodespace}"

echo "==> Configuring website index and error pages for gs://${BUCKET_NAME}..."
gcloud storage buckets update "gs://${BUCKET_NAME}" \
    --web-main-page-suffix="index.html" \
    --web-error-page="404.html"

echo "==> Ensuring Public Access Prevention is disabled..."
# If PAP was enabled during creation, this unblocks allUsers access:
gcloud storage buckets update "gs://${BUCKET_NAME}" \
    --no-public-access-prevention

echo "==> Granting public read permissions (allUsers -> roles/storage.objectViewer)..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
    --member="allUsers" \
    --role="roles/storage.objectViewer"

echo "==> Bucket configuration complete."
echo "==> Next step: Run ./03-deploy-site.sh ${BUCKET_NAME}"
