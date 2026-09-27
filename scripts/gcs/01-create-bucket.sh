#!/usr/bin/env bash
# ==============================================================================
# Script 01: Create Google Cloud Storage Bucket for Static Website
#
# REVIEW OF USER COMMAND:
# Original command:
#   gcloud storage buckets create gs://test1-chessclubwebsite-mycodespace \
#       --default-storage-class=STANDARD \
#       --location=EUROPE-NORTH1 \
#       --enable-hierarchical-namespace \
#       --uniform-bucket-level-access \
#       --public-access-prevention
#
# IMPORTANT FINDINGS & RECOMMENDATIONS:
# 1. --public-access-prevention (PAP):
#    CRITICAL: Enforcing PAP blocks all public access (disallows allUsers).
#    Anonymous web visitors will receive HTTP 403 Forbidden.
#    For a public static website, omit --public-access-prevention or use
#    --no-public-access-prevention.
#
# 2. --enable-hierarchical-namespace (HNS):
#    CAUTION: HNS is designed for analytics (BigQuery/Dataproc) folder semantics.
#    Once enabled, it cannot be disabled. It charges Class A operations for
#    directory objects and has feature constraints. A standard flat namespace
#    bucket is the recommended standard for static web hosting.
#
# 3. Bucket Name:
#    gs://test1-chessclubwebsite-mycodespace is valid. However, if you plan to
#    use direct CNAME (c.storage.googleapis.com) without a Load Balancer, the
#    bucket name MUST match the exact domain (e.g. gs://smartgalati-test.mycodespace.ai).
#    If using an HTTPS Cloud Load Balancer (recommended), any bucket name works!
# ==============================================================================

set -euo pipefail

BUCKET_NAME="${1:-test1-chessclubwebsite-mycodespace}"
LOCATION="${2:-EUROPE-NORTH1}"
STORAGE_CLASS="${3:-STANDARD}"

echo "==> Creating GCS bucket: gs://${BUCKET_NAME}"
echo "    Location: ${LOCATION}"
echo "    Storage Class: ${STORAGE_CLASS}"
echo "    Uniform Bucket-Level Access: Enabled"
echo "    Public Access Prevention: Disabled (required for public static web hosting)"

# Standard recommended creation command for public static web hosting:
gcloud storage buckets create "gs://${BUCKET_NAME}" \
    --default-storage-class="${STORAGE_CLASS}" \
    --location="${LOCATION}" \
    --uniform-bucket-level-access \
    --no-public-access-prevention

echo "==> Bucket gs://${BUCKET_NAME} created successfully."
echo "==> Next step: Run ./02-configure-website.sh ${BUCKET_NAME}"
