#!/usr/bin/env bash
# Deployment wrapper for the smartgalati-test5 candidate.
#   npm run deploy -- provision   # first time: bucket, website config, upload, shared LB host rule, DNS
#   npm run deploy -- update      # afterwards: build and upload only
#   npm run deploy -- status      # DNS / certificate / HTTPS diagnostics
# Every parameter comes from deployment.env; the shared scripts keep their test2 defaults.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck source=deployment.env
source "${SCRIPT_DIR}/deployment.env"
cd "${REPO_ROOT}"
echo "Target: ${DOMAIN} -> gs://${BUCKET_NAME} (project ${PROJECT_ID}, site dir ${SITE_DIR})"
case "${1:-update}" in
  provision)
    bash scripts/gcs/01-create-bucket.sh
    bash scripts/gcs/02-configure-website.sh
    bash scripts/gcs/03-deploy-site.sh
    bash scripts/gcs/04b-add-to-existing-loadbalancer.sh
    bash scripts/gcs/05-configure-dns.sh
    ;;
  update)
    bash scripts/gcs/03-deploy-site.sh
    ;;
  status)
    bash scripts/gcs/check-status.sh "${DOMAIN}" "${LB_PROJECT_ID}"
    ;;
  *) echo 'Usage: npm run deploy -- [provision|update|status]' >&2; exit 2 ;;
esac
