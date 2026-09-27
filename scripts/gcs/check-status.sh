#!/usr/bin/env bash
# ==============================================================================
# Script: Check Deployment, DNS, and SSL Certificate Status
#
# Provides real-time visibility into DNS propagation, Google-managed SSL
# certificate provisioning, and HTTPS connectivity.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

DOMAIN="${1:-${DOMAIN:-smartgalati-test2.mycodespace.ai}}"
LB_PROJECT_ID="${2:-${LB_PROJECT_ID:-mycodespace3p}}"

log_info "Diagnosing deployment for: ${DOMAIN}"
echo "    - Load Balancer Project: ${LB_PROJECT_ID}"
echo ""

# 1. DNS Resolution Probe
echo "------------------------------------------------------------------"
echo "1. DNS RESOLUTION PROBE"
echo "------------------------------------------------------------------"
for resolver in "8.8.8.8 (Google)" "1.1.1.1 (Cloudflare)"; do
  ip=$(echo "${resolver}" | cut -d' ' -f1)
  resolved=$(dig +short "@${ip}" "${DOMAIN}" A 2>/dev/null || nslookup "${DOMAIN}" "${ip}" 2>/dev/null | grep -E "Address: [0-9]" | awk '{print $2}' || true)
  if [ -n "${resolved}" ]; then
    log_success "${resolver}: resolves to ${resolved}"
  else
    log_warn "${resolver}: not yet resolving (or in propagation)"
  fi
done

# 2. Google-Managed SSL Certificate Probe
echo ""
echo "------------------------------------------------------------------"
echo "2. GOOGLE-MANAGED SSL CERTIFICATE STATUS"
echo "------------------------------------------------------------------"
# Find certificates matching the domain in LB_PROJECT_ID
MATCHING_CERTS=$(gcloud compute ssl-certificates list \
    --project="${LB_PROJECT_ID}" \
    --global \
    --filter="managed.domains:${DOMAIN}" \
    --format="value(name)" 2>/dev/null || true)

if [ -z "${MATCHING_CERTS}" ]; then
  # Fallback: check if the cert was named with prefix
  MATCHING_CERTS=$(gcloud compute ssl-certificates list \
      --project="${LB_PROJECT_ID}" \
      --global \
      --format="value(name)" 2>/dev/null || true)
fi

if [ -n "${MATCHING_CERTS}" ]; then
  for cert in ${MATCHING_CERTS}; do
    echo "Certificate: [${cert}]"
    CERT_STATUS=$(gcloud compute ssl-certificates describe "${cert}" \
        --project="${LB_PROJECT_ID}" --global --format="value(managed.status)" 2>/dev/null || echo "UNKNOWN")
    DOMAIN_STATUS=$(gcloud compute ssl-certificates describe "${cert}" \
        --project="${LB_PROJECT_ID}" --global --format="value(managed.domainStatus[${DOMAIN}])" 2>/dev/null || echo "UNKNOWN")
    
    if [ "${CERT_STATUS}" = "ACTIVE" ]; then
      log_success "Overall Status: ACTIVE (Certificate is live and serving traffic!)"
    elif [ "${CERT_STATUS}" = "PROVISIONING" ]; then
      log_warn "Overall Status: PROVISIONING (Google CA is validating DNS and signing certificate)"
      echo "    - Domain Status for ${DOMAIN}: ${DOMAIN_STATUS}"
      echo "    - Expected duration: 10 to 25 minutes after DNS A-record is live."
    else
      log_error "Overall Status: ${CERT_STATUS} (Domain Status: ${DOMAIN_STATUS})"
    fi
  done
else
  log_warn "No SSL certificates found covering ${DOMAIN} in project [${LB_PROJECT_ID}]."
fi

# 3. HTTPS End-to-End Connectivity Probe
echo ""
echo "------------------------------------------------------------------"
echo "3. HTTPS END-TO-END CONNECTIVITY PROBE"
echo "------------------------------------------------------------------"
set +e
HTTP_HEADER=$(curl -Is -m 8 "https://${DOMAIN}" 2>&1)
CURL_STATUS=$?
set -e

if [ ${CURL_STATUS} -eq 0 ]; then
  HTTP_CODE=$(echo "${HTTP_HEADER}" | grep -E "HTTP/[1-3]" | head -n1)
  log_success "Connection successful: ${HTTP_CODE}"
  echo "${HTTP_HEADER}" | grep -Ei "server:|via:|age:|cache-control:|alt-svc:" | sed 's/^/    /'
else
  if echo "${HTTP_HEADER}" | grep -qE "SSL_ERROR_SYSCALL|certificate|handshake"; then
    log_warn "Network routing is working (port 443 reachable), but TLS handshake is waiting for certificate activation."
  else
    log_warn "Connection attempt result: ${HTTP_HEADER}"
  fi
fi

echo "------------------------------------------------------------------"
