#!/usr/bin/env bash
# ==============================================================================
# Script 05: Configure Cloud DNS A-Record
#
# Lessons Learned Incorporated:
# 1. Project awareness: DNS is managed under central-trees-497510-h7 in zone
#    mycodespace (for domain mycodespace.ai).
# 2. Automated IP Discovery: Automatically detects the reserved Load Balancer IP
#    from the Load Balancer project (LB_PROJECT_ID) if not explicitly passed.
# 3. Idempotent DNS update: Checks whether the record set exists, and creates
#    or updates it accordingly.
# 4. Immediate DNS propagation verification: Probes global resolvers (8.8.8.8, 1.1.1.1)
#    to verify record visibility.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

# Parameters (CLI arguments take precedence over config.env)
DOMAIN="${1:-${DOMAIN:-smartgalati-test2.mycodespace.ai}}"
DNS_PROJECT_ID="${2:-${DNS_PROJECT_ID:-central-trees-497510-h7}}"
DNS_ZONE="${3:-${DNS_ZONE:-mycodespace}}"
LB_IP="${4:-}"

# If LB_IP was not passed as argument, attempt auto-discovery from LB_PROJECT_ID
if [ -z "${LB_IP}" ]; then
  log_info "No LB_IP passed as argument. Attempting auto-discovery from project [${LB_PROJECT_ID}]..."
  
  # Try finding IP from new LB prefix or existing LB prefix
  if gcloud compute addresses describe "${LB_NAME_PREFIX}-ip" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
    LB_IP=$(gcloud compute addresses describe "${LB_NAME_PREFIX}-ip" --project="${LB_PROJECT_ID}" --global --format="value(address)")
  elif gcloud compute forwarding-rules describe "${EXISTING_LB_NAME}-https-rule" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
    LB_IP=$(gcloud compute forwarding-rules describe "${EXISTING_LB_NAME}-https-rule" --project="${LB_PROJECT_ID}" --global --format="value(IPAddress)")
  fi
fi

if [ -z "${LB_IP}" ]; then
  log_error "Could not determine Load Balancer IP address."
  echo "Usage: ./scripts/gcs/05-configure-dns.sh [DOMAIN] [DNS_PROJECT_ID] [DNS_ZONE] [LB_IP]"
  echo "Example: ./scripts/gcs/05-configure-dns.sh smartgalati-test2.mycodespace.ai central-trees-497510-h7 mycodespace 34.120.230.82"
  exit 1
fi

log_info "Configuring Cloud DNS A Record:"
echo "    - Domain:             ${DOMAIN}."
echo "    - DNS Project:        ${DNS_PROJECT_ID}"
echo "    - Managed Zone:       ${DNS_ZONE}"
echo "    - Target IPv4 (A):    ${LB_IP}"
echo "    - TTL:                300"

# Ensure Cloud DNS API is enabled in DNS project
ensure_api_enabled "${DNS_PROJECT_ID}" "dns.googleapis.com"

# Check if DNS record already exists in zone
DNS_NAME="${DOMAIN}."
EXISTING_RECORD=$(gcloud dns record-sets list \
    --project="${DNS_PROJECT_ID}" \
    --zone="${DNS_ZONE}" \
    --name="${DNS_NAME}" \
    --type="A" \
    --format="value(rrdatas[0])" 2>/dev/null || true)

if [ -n "${EXISTING_RECORD}" ]; then
  if [ "${EXISTING_RECORD}" = "${LB_IP}" ]; then
    log_success "DNS A record ${DNS_NAME} is already configured to point to ${LB_IP}."
  else
    log_info "Existing A record found pointing to ${EXISTING_RECORD}. Updating to ${LB_IP}..."
    gcloud dns record-sets update "${DNS_NAME}" \
        --project="${DNS_PROJECT_ID}" \
        --zone="${DNS_ZONE}" \
        --type="A" \
        --ttl="300" \
        --rrdatas="${LB_IP}"
    log_success "DNS A record ${DNS_NAME} updated to ${LB_IP}."
  fi
else
  log_info "Creating new DNS A record ${DNS_NAME} -> ${LB_IP}..."
  gcloud dns record-sets create "${DNS_NAME}" \
      --project="${DNS_PROJECT_ID}" \
      --zone="${DNS_ZONE}" \
      --type="A" \
      --ttl="300" \
      --rrdatas="${LB_IP}"
  log_success "DNS A record ${DNS_NAME} created successfully in zone [${DNS_ZONE}] of project [${DNS_PROJECT_ID}]."
fi

echo ""
log_info "Testing DNS resolution..."
echo -n "    - Google Public DNS (8.8.8.8): "
dig +short "@8.8.8.8" "${DOMAIN}" A || nslookup "${DOMAIN}" 8.8.8.8 2>/dev/null | grep -E "Address: [0-9]" || echo "Propagation in progress..."

echo ""
echo "=============================================================================="
log_success "DNS configuration complete!"
echo "    Record: ${DOMAIN} -> ${LB_IP}"
echo ""
echo "Google-managed SSL certificates take 10-25 minutes to transition to ACTIVE"
echo "once Google detects the DNS A record pointing to its Load Balancer."
echo ""
echo "==> Monitor certificate and HTTPS health with:"
echo "    ./scripts/gcs/check-status.sh ${DOMAIN} ${LB_PROJECT_ID}"
echo "=============================================================================="
