#!/usr/bin/env bash
# ==============================================================================
# Script 04: Setup Google Cloud HTTPS Load Balancer with Google-Managed SSL
#
# WHY THIS SCRIPT IS NEEDED:
# 1. Bucket Name vs Domain Name:
#    Direct CNAME (c.storage.googleapis.com) strictly requires the bucket name
#    to match the domain name exactly (e.g. gs://smartgalati-test.mycodespace.ai).
#    Since your bucket is named gs://test1-chessclubwebsite-mycodespace, direct
#    CNAME routing will fail with 404 / NoSuchBucket.
#
# 2. HTTPS / SSL:
#    Direct GCS CNAME hosting is HTTP-only. An External Application Load Balancer
#    provides Google-managed SSL certificates and free HTTPS.
#
# 3. Cloud CDN:
#    The Backend Bucket can have Cloud CDN enabled for ultra-fast worldwide edge caching.
# ==============================================================================

set -euo pipefail

BUCKET_NAME="${1:-test1-chessclubwebsite-mycodespace}"
DOMAIN="${2:-smartgalati-test.mycodespace.ai}"
NAME_PREFIX="chessclub-site"

echo "==> Setting up HTTPS Load Balancer for ${DOMAIN} pointing to gs://${BUCKET_NAME}..."

# 1. Reserve a Global Static IPv4 Address
echo "1. Reserving global external IP address..."
gcloud compute addresses create "${NAME_PREFIX}-ip" \
    --network-tier=PREMIUM \
    --ip-version=IPV4 \
    --global || true

LB_IP=$(gcloud compute addresses describe "${NAME_PREFIX}-ip" --global --format="value(address)")
echo "   >> Reserved IP: ${LB_IP}"

# 2. Create a Google-Managed SSL Certificate
echo "2. Creating Google-managed SSL certificate for ${DOMAIN}..."
gcloud compute ssl-certificates create "${NAME_PREFIX}-cert" \
    --domains="${DOMAIN}" \
    --global || true

# 3. Create Backend Bucket pointing to GCS
echo "3. Creating Backend Bucket..."
gcloud compute backend-buckets create "${NAME_PREFIX}-backend" \
    --gcs-bucket-name="${BUCKET_NAME}" \
    --enable-cdn || true

# 4. Create URL Map
echo "4. Creating URL Map..."
gcloud compute url-maps create "${NAME_PREFIX}-url-map" \
    --default-backend-bucket="${NAME_PREFIX}-backend" || true

# 5. Create Target HTTPS Proxy
echo "5. Creating Target HTTPS Proxy..."
gcloud compute target-https-proxies create "${NAME_PREFIX}-https-proxy" \
    --ssl-certificates="${NAME_PREFIX}-cert" \
    --url-map="${NAME_PREFIX}-url-map" || true

# 6. Create Global Forwarding Rule for HTTPS (Port 443)
echo "6. Creating Global Forwarding Rule for HTTPS..."
gcloud compute forwarding-rules create "${NAME_PREFIX}-https-rule" \
    --load-balancing-scheme=EXTERNAL_MANAGED \
    --network-tier=PREMIUM \
    --address="${NAME_PREFIX}-ip" \
    --global \
    --target-https-proxy="${NAME_PREFIX}-https-proxy" \
    --ports=443 || true

echo "=============================================================================="
echo "==> Load Balancer setup complete!"
echo "    Assigned Global Static IP: ${LB_IP}"
echo ""
echo "DNS CONFIGURATION REQUIRED:"
echo "In your DNS provider for 'mycodespace.ai', create an 'A' record:"
echo "    Type:  A"
echo "    Host:  smartgalati-test"
echo "    Value: ${LB_IP}"
echo ""
echo "Note: Google-managed SSL certificates take 15-30 minutes to provision"
echo "once the DNS 'A' record is detected by Google."
echo "=============================================================================="
