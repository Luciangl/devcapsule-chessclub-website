# Google Cloud Storage (GCS) Deployment Reference

This directory contains standalone, reviewed reference scripts for deploying the static website to **Google Cloud Storage (GCS)** and configuring custom domain HTTPS access.

All scripts are located outside the website source tree (`ag-flash3.8-site/`) so they can be reviewed and executed independently.

---

## 1. Review of the Proposed `buckets create` Command

### User Command Analyzed:
```bash
gcloud storage buckets create gs://test1-chessclubwebsite-mycodespace \
    --default-storage-class=STANDARD \
    --location=EUROPE-NORTH1 \
    --enable-hierarchical-namespace \
    --uniform-bucket-level-access \
    --public-access-prevention
```

### Best-Effort Review & Analysis:

| Flag | Verdict | Analysis & Impact |
| :--- | :--- | :--- |
| `gs://test1-chessclubwebsite-mycodespace` | **Valid with Load Balancer** | Standard bucket name. **Important:** Because this name differs from your domain (`smartgalati-test.mycodespace.ai`), it **cannot** be accessed via direct CNAME (`c.storage.googleapis.com`), which requires an exact name match. To use this bucket name for `smartgalati-test.mycodespace.ai`, an **External Application Load Balancer with Backend Bucket** is required (see script `04`). |
| `--default-storage-class=STANDARD` | **Recommended** | High-availability, low-latency class ideal for web-facing static assets. |
| `--location=EUROPE-NORTH1` | **Recommended** | Finland region; excellent latency for European and Romanian visitors. |
| `--uniform-bucket-level-access` | **Best Practice** | Modern IAM-only access model, disables legacy ACLs. |
| `--enable-hierarchical-namespace` | **Caution / Not Recommended** | Hierarchical Namespace (HNS) is designed for big data analytics (Dataproc/BigQuery) file-system semantics. It is immutable once created and incurs Class A charges on folder management. For static web hosting, standard flat namespace is the standard practice. |
| `--public-access-prevention` | **CRITICAL: Incompatible with public site** | **Public Access Prevention (PAP = enforced) strictly blocks `allUsers` access.** Any unauthenticated web visitor attempting to view the site will receive **HTTP 403 Forbidden**. To host a public website, PAP must be omitted or disabled (`--no-public-access-prevention`). |

---

## 2. Execution Scripts Overview

The deployment suite is divided into 4 sequential scripts:

### Script `01-create-bucket.sh`
Creates the GCS bucket with the corrected parameters for public web hosting:
```bash
./scripts/gcs/01-create-bucket.sh test1-chessclubwebsite-mycodespace EUROPE-NORTH1 STANDARD
```

### Script `02-configure-website.sh`
Sets the website entrypoints (`index.html`, `404.html`), disables PAP if previously set, and grants `allUsers` the `roles/storage.objectViewer` role:
```bash
./scripts/gcs/02-configure-website.sh test1-chessclubwebsite-mycodespace
```

### Script `03-deploy-site.sh`
Builds the Astro static site and synchronizes `dist/` to the bucket with optimal HTTP `Cache-Control` headers (1 year for immutable hashed `_astro/*` assets, 5 minutes for HTML files):
```bash
./scripts/gcs/03-deploy-site.sh test1-chessclubwebsite-mycodespace ag-flash3.8-site
```

### Script `04-setup-https-loadbalancer.sh`
Sets up an External Application Load Balancer (Google-managed SSL certificate + Cloud CDN) pointing to `test1-chessclubwebsite-mycodespace`:
```bash
./scripts/gcs/04-setup-https-loadbalancer.sh test1-chessclubwebsite-mycodespace smartgalati-test.mycodespace.ai
```
*Outputs the reserved static external IP address to configure in your DNS `A` record.*

---

## 3. Alternative: Direct CNAME (HTTP-Only)
If you want to avoid an Application Load Balancer and use direct GCS CNAME hosting:
1. Create a bucket whose name **exactly matches** the hostname:
   ```bash
   gcloud storage buckets create gs://smartgalati-test.mycodespace.ai \
       --location=EUROPE-NORTH1 \
       --uniform-bucket-level-access
   ```
2. Configure website settings:
   ```bash
   gcloud storage buckets update gs://smartgalati-test.mycodespace.ai \
       --web-main-page-suffix=index.html \
       --web-error-page=404.html
   gcloud storage buckets add-iam-policy-binding gs://smartgalati-test.mycodespace.ai \
       --member=allUsers \
       --role=roles/storage.objectViewer
   ```
3. Set DNS CNAME:
   * **Host**: `smartgalati-test`
   * **Target**: `c.storage.googleapis.com`

*(Note: Direct CNAME on GCS only serves HTTP, not HTTPS. The Load Balancer approach in Script 04 or Cloudflare proxy is needed for HTTPS.)*
