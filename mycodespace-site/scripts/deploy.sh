#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${SCRIPT_DIR}/deployment.env"
mode="${1:-plan}"
case "$mode" in
  plan|update|provision) ;;
  *) echo 'Usage: npm run deploy -- [plan|update|provision]' >&2; exit 2 ;;
esac
# Require explicit targets before shared config.env can supply chess-site defaults.
: "${PROJECT_ID:?Set PROJECT_ID to the GCS project}"
: "${BUCKET_NAME:?Set BUCKET_NAME to a dedicated MyCodeSpace bucket}"
export PROJECT_ID BUCKET_NAME
if [[ "$mode" == provision ]]; then
  : "${LB_PROJECT_ID:?Set LB_PROJECT_ID to the existing load balancer project}"
  : "${EXISTING_LB_NAME:?Set EXISTING_LB_NAME to the existing load balancer prefix}"
  : "${DNS_PROJECT_ID:?Set DNS_PROJECT_ID to the Cloud DNS project}"
  : "${DNS_ZONE:?Set DNS_ZONE to the Cloud DNS zone}"
  export LB_PROJECT_ID EXISTING_LB_NAME DNS_PROJECT_ID DNS_ZONE
fi
printf 'Site: %s\nDomain: %s\nProject: %s\nBucket: gs://%s\nMode: %s\n' "$SITE_DIR" "$DOMAIN" "$PROJECT_ID" "$BUCKET_NAME" "$mode"
cd "$REPO_ROOT"
case "$mode" in
  plan) echo 'No cloud changes. update uploads dist; provision also creates hosting resources and changes apex DNS.' ;;
  update) bash scripts/gcs/03-deploy-site.sh ;;
  provision)
    bash scripts/gcs/01-create-bucket.sh
    bash scripts/gcs/02-configure-website.sh
    bash scripts/gcs/03-deploy-site.sh
    bash scripts/gcs/04b-add-to-existing-loadbalancer.sh
    # Pass the address explicitly: shared DNS helper otherwise derives a new-LB prefix.
    source scripts/gcs/common.sh
    lb_address="$(gcloud compute forwarding-rules describe "${EXISTING_LB_NAME}-https-rule" --project="$LB_PROJECT_ID" --global --format='value(IPAddress)')"
    [[ -n "$lb_address" ]] || { echo 'No load balancer address found' >&2; exit 1; }
    bash scripts/gcs/05-configure-dns.sh "$DOMAIN" "$DNS_PROJECT_ID" "$DNS_ZONE" "$lb_address"
    ;;
esac
