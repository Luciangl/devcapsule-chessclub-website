#!/usr/bin/env bash
# ==============================================================================
# Shared Helpers and Environment Loader for GCS Deployment Suite
# ==============================================================================

# Ensure gcloud is found in PATH if installed in user xtras
if ! command -v gcloud &>/dev/null; then
  if [ -x "/home/devcapsule/xtras/google-cloud-sdk/bin/gcloud" ]; then
    export PATH="/home/devcapsule/xtras/google-cloud-sdk/bin:$PATH"
  elif [ -x "${HOME}/xtras/google-cloud-sdk/bin/gcloud" ]; then
    export PATH="${HOME}/xtras/google-cloud-sdk/bin:$PATH"
  fi
fi

# Load config.env from the same directory as this script if present
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${COMMON_DIR}/config.env" ]; then
  # shellcheck source=/dev/null
  source "${COMMON_DIR}/config.env"
fi

# Terminal colors
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}${BOLD}==>${NC} $*"
}

log_success() {
  echo -e "${GREEN}${BOLD}✔${NC} $*"
}

log_warn() {
  echo -e "${YELLOW}${BOLD}⚠${NC} $*"
}

log_error() {
  echo -e "${RED}${BOLD}✖${NC} $*" >&2
}

# Verify gcloud authentication
check_gcloud() {
  if ! command -v gcloud &>/dev/null; then
    log_error "gcloud CLI not found in PATH. Please install Google Cloud SDK."
    exit 1
  fi
  local active_account
  active_account="$(gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null || true)"
  if [ -z "${active_account}" ]; then
    log_error "No active gcloud account authenticated. Run: gcloud auth login"
    exit 1
  fi
}

# Ensure a Google Cloud API is enabled on a target project without hanging on interactive prompts
ensure_api_enabled() {
  local project_id="$1"
  local service_name="$2"
  log_info "Verifying API [${service_name}] is enabled on project [${project_id}]..."
  if ! gcloud services list --project="${project_id}" --enabled --filter="config.name:${service_name}" --format="value(config.name)" 2>/dev/null | grep -q "${service_name}"; then
    log_info "Enabling API [${service_name}] on project [${project_id}] (this may take 1-2 minutes)..."
    gcloud services enable "${service_name}" --project="${project_id}" --quiet
    log_success "API [${service_name}] enabled on project [${project_id}]."
  else
    log_success "API [${service_name}] already enabled on project [${project_id}]."
  fi
}

# Preemptively or reactively override Domain-Restricted Sharing (Org Policy) if needed for public web hosting
override_domain_restricted_sharing() {
  local project_id="$1"
  log_info "Ensuring orgpolicy.googleapis.com API is enabled on project [${project_id}]..."
  ensure_api_enabled "${project_id}" "orgpolicy.googleapis.com"

  local policy_file="${COMMON_DIR}/allow-all-domains.yaml"
  log_info "Updating ${policy_file} for project [${project_id}]..."
  # Replace project ID in allow-all-domains.yaml so it is always current
  if [ -f "${policy_file}" ]; then
    sed -i -E "s|projects/[^/]+/policies/iam.allowedPolicyMemberDomains|projects/${project_id}/policies/iam.allowedPolicyMemberDomains|g" "${policy_file}"
  else
    cat << POLICYYAML > "${policy_file}"
name: projects/${project_id}/policies/iam.allowedPolicyMemberDomains
spec:
  inheritFromParent: false
  rules:
    - allowAll: true
POLICYYAML
  fi

  log_info "Applying Org Policy override from ${policy_file}..."
  if gcloud org-policies set-policy "${policy_file}" --quiet; then
    log_success "Domain-Restricted Sharing override applied to project [${project_id}]."
    log_info "Waiting 15 seconds for IAM / Org Policy propagation..."
    sleep 15
    return 0
  else
    log_warn "Could not automatically apply Org Policy override via CLI (requires orgpolicy.policies.set)."
    log_warn "If 'allUsers' binding fails with HTTP 412, override 'Domain restricted sharing' in GCP Console:"
    log_warn "https://console.cloud.google.com/iam-admin/orgpolicies/iam.allowedPolicyMemberDomains?project=${project_id}"
    return 1
  fi
}
