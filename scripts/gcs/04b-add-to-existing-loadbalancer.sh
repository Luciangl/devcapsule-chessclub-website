#!/usr/bin/env bash
# ==============================================================================
# Script 04b: Add a Website to an EXISTING Google Cloud HTTPS Load Balancer
#
# Enables multi-site hosting on a single Cloud Load Balancer (Host-Based Routing):
# 1. Cross-Project Decoupling: Does NOT assume the Load Balancer is in the same
#    project as the storage bucket. The Load Balancer can be in LB_PROJECT_ID
#    (e.g., central-trees-497510-h7 or mycodespace3p), while GCS is in PROJECT_ID.
# 2. SSL Certificate Attachment: Creates a new Google-managed SSL certificate
#    for the new domain and appends it to the existing Target HTTPS Proxy
#    without replacing existing certificates.
# 3. Backend Bucket Creation: Creates a Backend Bucket pointing to gs://BUCKET_NAME
#    with Cloud CDN enabled.
# 4. URL Map Routing: Adds a path matcher and host rule to the existing URL Map
#    routing traffic for DOMAIN to the new Backend Bucket.
# 5. DNS Output: Discovers the existing Load Balancer's public IP and guides/runs
#    DNS configuration in DNS_PROJECT_ID.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/gcs/common.sh
source "${SCRIPT_DIR}/common.sh"

check_gcloud

# Parameters (CLI arguments take precedence over config.env)
BUCKET_NAME="${1:-${BUCKET_NAME:-test2}}"
DOMAIN="${2:-${DOMAIN:-smartgalati-test2.mycodespace.ai}}"
LB_PROJECT_ID="${3:-${LB_PROJECT_ID:-mycodespace3p}}"
EXISTING_LB_NAME="${4:-${EXISTING_LB_NAME:-chessclub-site}}"

# Derive clean resource identifiers
SANITIZED_DOMAIN="${DOMAIN//./-}"
CERT_NAME="${EXISTING_LB_NAME}-${SANITIZED_DOMAIN}-cert"
# Keep cert name within GCP 63 char limit if necessary
if [ ${#CERT_NAME} -gt 63 ]; then
  CERT_NAME="${EXISTING_LB_NAME}-$(echo -n "${DOMAIN}" | md5sum | cut -c 1-8)-cert"
fi

BACKEND_BUCKET_NAME="${EXISTING_LB_NAME}-${BUCKET_NAME}-backend"
MATCHER_NAME="${SANITIZED_DOMAIN}-matcher"
if [ ${#MATCHER_NAME} -gt 63 ]; then
  MATCHER_NAME="m-$(echo -n "${DOMAIN}" | md5sum | cut -c 1-8)"
fi

URL_MAP_NAME="${EXISTING_LB_NAME}-url-map"
TARGET_PROXY_NAME="${EXISTING_LB_NAME}-https-proxy"
FORWARDING_RULE_NAME="${EXISTING_LB_NAME}-https-rule"

DNS_PROJECT_ID="${DNS_PROJECT_ID:-central-trees-497510-h7}"
DNS_ZONE="${DNS_ZONE:-mycodespace}"

log_info "Adding Website to EXISTING HTTPS Load Balancer:"
echo "    - Domain:               ${DOMAIN}"
echo "    - GCS Storage Bucket:   gs://${BUCKET_NAME}"
echo "    - Load Balancer Proj:   ${LB_PROJECT_ID}"
echo "    - Existing LB Prefix:   ${EXISTING_LB_NAME}"
echo "    - Existing URL Map:     ${URL_MAP_NAME}"
echo "    - Existing Proxy:       ${TARGET_PROXY_NAME}"
echo "    - DNS Target Project:   ${DNS_PROJECT_ID} (Zone: ${DNS_ZONE})"

# 1. Verify existing Load Balancer resources exist in LB_PROJECT_ID
log_info "1. Verifying existing Load Balancer resources in project [${LB_PROJECT_ID}]..."

if ! gcloud compute url-maps describe "${URL_MAP_NAME}" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  log_error "URL Map [${URL_MAP_NAME}] not found in project [${LB_PROJECT_ID}]."
  log_warn "If this is a new Load Balancer, run ./scripts/gcs/04-setup-https-loadbalancer.sh instead."
  exit 1
fi

if ! gcloud compute target-https-proxies describe "${TARGET_PROXY_NAME}" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  log_error "Target HTTPS Proxy [${TARGET_PROXY_NAME}] not found in project [${LB_PROJECT_ID}]."
  exit 1
fi

log_success "Existing Load Balancer components verified in [${LB_PROJECT_ID}]."

# 2. Create a Google-Managed SSL Certificate for the new domain
log_info "2. Creating Google-managed SSL certificate [${CERT_NAME}] for ${DOMAIN}..."
if ! gcloud compute ssl-certificates describe "${CERT_NAME}" --project="${LB_PROJECT_ID}" --global &>/dev/null; then
  gcloud compute ssl-certificates create "${CERT_NAME}" \
      --project="${LB_PROJECT_ID}" \
      --domains="${DOMAIN}" \
      --global
else
  log_success "SSL Certificate [${CERT_NAME}] already exists."
fi

# 3. Attach SSL Certificate to Existing Target HTTPS Proxy
log_info "3. Attaching certificate to Target HTTPS Proxy [${TARGET_PROXY_NAME}]..."
EXISTING_CERTS=$(gcloud compute target-https-proxies describe "${TARGET_PROXY_NAME}" \
    --project="${LB_PROJECT_ID}" --global --format="value(sslCertificates.map().basename().list())" || true)

if echo "${EXISTING_CERTS}" | grep -q "${CERT_NAME}"; then
  log_success "Certificate [${CERT_NAME}] is already attached to [${TARGET_PROXY_NAME}]."
else
  log_info "Current certificates on proxy: ${EXISTING_CERTS}"
  NEW_CERTS_LIST="${EXISTING_CERTS},${CERT_NAME}"
  # Remove leading/trailing commas if any
  NEW_CERTS_LIST="${NEW_CERTS_LIST#,}"
  NEW_CERTS_LIST="${NEW_CERTS_LIST%,}"
  
  gcloud compute target-https-proxies update "${TARGET_PROXY_NAME}" \
      --project="${LB_PROJECT_ID}" \
      --global \
      --ssl-certificates="${NEW_CERTS_LIST}"
  log_success "Updated [${TARGET_PROXY_NAME}] with certificates: ${NEW_CERTS_LIST}"
fi

# 4. Create Backend Bucket pointing to GCS
log_info "4. Creating Backend Bucket [${BACKEND_BUCKET_NAME}] pointing to gs://${BUCKET_NAME} with Cloud CDN..."
if ! gcloud compute backend-buckets describe "${BACKEND_BUCKET_NAME}" --project="${LB_PROJECT_ID}" &>/dev/null; then
  gcloud compute backend-buckets create "${BACKEND_BUCKET_NAME}" \
      --project="${LB_PROJECT_ID}" \
      --gcs-bucket-name="${BUCKET_NAME}" \
      --enable-cdn
else
  log_success "Backend bucket [${BACKEND_BUCKET_NAME}] already exists."
fi

# 5. Add Path Matcher / Host Rule to existing URL Map
log_info "5. Configuring host routing in URL Map [${URL_MAP_NAME}] for host [${DOMAIN}]..."
EXISTING_HOSTS=$(gcloud compute url-maps describe "${URL_MAP_NAME}" --project="${LB_PROJECT_ID}" --global --format="value(hostRules[].hosts)" || true)

if echo "${EXISTING_HOSTS}" | grep -q "${DOMAIN}"; then
  log_success "Host rule for [${DOMAIN}] already configured in URL Map [${URL_MAP_NAME}]."
else
  gcloud compute url-maps add-path-matcher "${URL_MAP_NAME}" \
      --project="${LB_PROJECT_ID}" \
      --global \
      --default-backend-bucket="${BACKEND_BUCKET_NAME}" \
      --path-matcher-name="${MATCHER_NAME}" \
      --new-hosts="${DOMAIN}"
  log_success "Added path matcher [${MATCHER_NAME}] routing [${DOMAIN}] -> [${BACKEND_BUCKET_NAME}]."
fi

# 6. Retrieve the Load Balancer IP from Forwarding Rule
log_info "6. Retrieving public IP address from forwarding rule [${FORWARDING_RULE_NAME}]..."
LB_IP=$(gcloud compute forwarding-rules describe "${FORWARDING_RULE_NAME}" --project="${LB_PROJECT_ID}" --global --format="value(IPAddress)")
log_success "Load Balancer IP: ${LB_IP}"

echo ""
echo "=============================================================================="
log_success "Website [${DOMAIN}] successfully added to existing Load Balancer [${EXISTING_LB_NAME}]!"
echo "    Load Balancer IP: ${LB_IP}"
echo "    Target Domain:    ${DOMAIN}"
echo "    Backend Bucket:   ${BACKEND_BUCKET_NAME} -> gs://${BUCKET_NAME}"
echo "=============================================================================="
echo ""
echo "==> Next step: Automatically configure DNS A record in project [${DNS_PROJECT_ID}]:"
echo "    ./scripts/gcs/05-configure-dns.sh ${DOMAIN} ${DNS_PROJECT_ID} ${DNS_ZONE} ${LB_IP}"
echo ""
echo "Or manual command in project [${DNS_PROJECT_ID}]:"
echo "    gcloud dns record-sets create \"${DOMAIN}.\" --project=\"${DNS_PROJECT_ID}\" --zone=\"${DNS_ZONE}\" --type=A --ttl=300 --rrdatas=\"${LB_IP}\""
