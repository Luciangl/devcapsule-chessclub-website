#!/usr/bin/env bash
# ==============================================================================
# Script 04: Setup New Google Cloud HTTPS Load Balancer with SSL & Cloud CDN
#
# Lessons Learned Incorporated:
# 1. API enablement: automatically enables compute.googleapis.com non-interactively.
# 2. Project parameterization: pass --project explicitly for all compute resources
#    (defaults to LB_PROJECT_ID=mycodespace3p).
# 3. DNS Project awareness: outputs the exact DNS configuration pointing to
#    DNS_PROJECT_ID (central-trees-497510-h7) and offers automated DNS setup.
# 4. Mode awareness: supports delegating to 04b-add-to-existing-loadbalancer.sh
#    if adding to an existing load balancer is requested.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

# If user specified existing mode or passed --existing flag, delegate to 04b
if [[ "${1:-}" == "--existing" ]] || [[ "${LB_MODE:-}" == "existing" ]]; then
  shift || true
  exec "${SCRIPT_DIR}/04b-add-to-existing-loadbalancer.sh" "$@"
fi

BUCKET_NAME="${1:-${BUCKET_NAME:-test2}}"
DOMAIN="${2:-${DOMAIN:-smartgalati-test2.mycodespace.ai}}"
LB_PROJECT_ID="${3:-${LB_PROJECT_ID:-mycodespace3p}}"
NAME_PREFIX="${4:-${LB_NAME_PREFIX:-chessclub-test2}}"
DNS_PROJECT_ID="${DNS_PROJECT_ID:-central-trees-497510-h7}"
DNS_ZONE="${DNS_ZONE:-mycodespace}"

log_info "Setting up NEW HTTPS Load Balancer:"
echo "    - Domain:             ${DOMAIN}"
echo "    - Backend GCS Bucket: gs://${BUCKET_NAME}"
echo "    - LB Project:         ${LB_PROJECT_ID}"
echo "    - Resource Prefix:    ${NAME_PREFIX}"
echo "    - DNS Target Project: ${DNS_PROJECT_ID} (Zone: ${DNS_ZONE})"

# 1. Enable compute API in load balancer project
ensure_api_enabled "${LB_PROJECT_ID}" "compute.googleapis.com"

# 2. Reserve a Global Static IPv4 Address
log_info "1. Reserving global external IPv4 address (${NAME_PREFIX}-ip)..."
if ! gcloud compute addresses describe "${NAME_PREFIX}-ip" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute addresses create "${NAME_PREFIX}-ip" \
      --project="${LB_PROJECT_ID}" \
      --network-tier=PREMIUM \
      --ip-version=IPV4 \
      --global
fi

LB_IP=$(gcloud compute addresses describe "${NAME_PREFIX}-ip" --project="${LB_PROJECT_ID}" --global --format="value(address)")
log_success "Reserved IP: ${LB_IP}"

# 3. Create a Google-Managed SSL Certificate
log_info "2. Creating Google-managed SSL certificate for ${DOMAIN}..."
if ! gcloud compute ssl-certificates describe "${NAME_PREFIX}-cert" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute ssl-certificates create "${NAME_PREFIX}-cert" \
      --project="${LB_PROJECT_ID}" \
      --domains="${DOMAIN}" \
      --global
else
  log_success "Certificate ${NAME_PREFIX}-cert already exists in [${LB_PROJECT_ID}]."
fi

# 4. Create Backend Bucket pointing to GCS
log_info "3. Creating Backend Bucket pointing to gs://${BUCKET_NAME} with Cloud CDN..."
if ! gcloud compute backend-buckets describe "${NAME_PREFIX}-backend" --project="${LB_PROJECT_ID}" &>/dev/null; then
  gcloud compute backend-buckets create "${NAME_PREFIX}-backend" \
      --project="${LB_PROJECT_ID}" \
      --gcs-bucket-name="${BUCKET_NAME}" \
      --enable-cdn
else
  log_success "Backend bucket ${NAME_PREFIX}-backend already exists in [${LB_PROJECT_ID}]."
fi

# 5. Create URL Map
log_info "4. Creating URL Map..."
if ! gcloud compute url-maps describe "${NAME_PREFIX}-url-map" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute url-maps create "${NAME_PREFIX}-url-map" \
      --project="${LB_PROJECT_ID}" \
      --default-backend-bucket="${NAME_PREFIX}-backend" \
      --global
else
  log_success "URL Map ${NAME_PREFIX}-url-map already exists in [${LB_PROJECT_ID}]."
fi

# 6. Create Target HTTPS Proxy
log_info "5. Creating Target HTTPS Proxy..."
if ! gcloud compute target-https-proxies describe "${NAME_PREFIX}-https-proxy" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute target-https-proxies create "${NAME_PREFIX}-https-proxy" \
      --project="${LB_PROJECT_ID}" \
      --ssl-certificates="${NAME_PREFIX}-cert" \
      --url-map="${NAME_PREFIX}-url-map" \
      --global
else
  log_success "Target HTTPS Proxy ${NAME_PREFIX}-https-proxy already exists in [${LB_PROJECT_ID}]."
fi

# 7. Create Global Forwarding Rule for HTTPS (Port 443)
log_info "6. Creating Global Forwarding Rule for HTTPS on Port 443..."
if ! gcloud compute forwarding-rules describe "${NAME_PREFIX}-https-rule" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute forwarding-rules create "${NAME_PREFIX}-https-rule" \
      --project="${LB_PROJECT_ID}" \
      --load-balancing-scheme=EXTERNAL_MANAGED \
      --network-tier=PREMIUM \
      --address="${NAME_PREFIX}-ip" \
      --global \
      --target-https-proxy="${NAME_PREFIX}-https-proxy" \
      --ports=443
else
  log_success "Forwarding rule ${NAME_PREFIX}-https-rule already exists in [${LB_PROJECT_ID}]."
fi

echo ""
echo "=============================================================================="
log_success "Load Balancer setup complete!"
echo "    Assigned Global Static IP: ${LB_IP}"
echo "    Domain:                    ${DOMAIN}"
echo "=============================================================================="
echo ""
echo "==> Next step: Automatically configure DNS A record in project [${DNS_PROJECT_ID}]:"
echo "    ./scripts/gcs/05-configure-dns.sh ${DOMAIN} ${DNS_PROJECT_ID} ${DNS_ZONE} ${LB_IP}"
echo ""
echo "Or manual command in project [${DNS_PROJECT_ID}]:"
echo "    gcloud dns record-sets create \"${DOMAIN}.\" --project=\"${DNS_PROJECT_ID}\" --zone=\"${DNS_ZONE}\" --type=A --ttl=300 --rrdatas=\"${LB_IP}\""
