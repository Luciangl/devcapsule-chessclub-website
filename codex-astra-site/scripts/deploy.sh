#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${SCRIPT_DIR}/deployment.env"
cd "${REPO_ROOT}"
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
  *) echo 'Usage: npm run deploy -- [provision|update]' >&2; exit 2 ;;
esac
