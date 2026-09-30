#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
if [[ "${1:-}" == --help ]]; then
  echo 'Usage: 02-deploy.sh [--prepare-only] PROJECT_ID [SITE_DIR]'
  echo 'Default SITE_DIR: claude-rocada-site. --prepare-only builds locally without cloud calls.'
  exit 0
fi
PREPARE_ONLY=false
if [[ "${1:-}" == --prepare-only ]]; then PREPARE_ONLY=true; shift; fi
[[ $# -le 2 ]] || fail 'Usage: 02-deploy.sh [--prepare-only] PROJECT_ID [SITE_DIR]'
set_project "${1:-}"
require_node
SITE_DIR="${2:-claude-rocada-site}"
# Only a source directory inside this checkout is accepted.
SITE_PATH="$(node --input-type=module -e '
import {realpathSync} from "node:fs"; import {resolve, relative, isAbsolute} from "node:path";
const root=realpathSync(process.argv[1]); const p=realpathSync(resolve(root,process.argv[2]));
const rel=relative(root,p); if (!rel || rel.startsWith("..") || isAbsolute(rel)) process.exit(1);
console.log(p);' "$REPO_ROOT" "$SITE_DIR")" || fail 'SITE_DIR must exist inside this checkout.'
[[ -f "${SITE_PATH}/package-lock.json" ]] || fail 'SITE_DIR needs a package-lock.json. Install its dependencies with npm ci first.'
if [[ "$PREPARE_ONLY" == false ]]; then require_tools; assert_spark; fi
# The Astro --site override controls canonical URLs without changing the GCS default.
(cd "$SITE_PATH" && npm run build -- --site "$SITE_URL")
DEPLOY_DIR="$(mktemp -d "${TMPDIR:-/tmp}/chessclub-firebase.XXXXXX")"
trap 'rm -rf -- "$DEPLOY_DIR"' EXIT
node "${FIREBASE_SCRIPT_DIR}/hosting.mjs" prepare "$PROJECT_ID" "${SITE_PATH}/dist" "$DEPLOY_DIR"
if [[ "$PREPARE_ONLY" == true ]]; then
  trap - EXIT
  printf 'Prepared static release (no cloud access): %s\n' "$DEPLOY_DIR"
  printf 'Inspect firebase.json and public/. Remove this temporary directory when finished.\n'
  exit 0
fi
# Check again after the build; never rely on cached preflight results.
assert_spark
# Use an isolated config and working directory: no inherited aliases, deploy hooks,
# framework auto-detection, or functions/SSR configuration from the source project.
cd "$DEPLOY_DIR"
# Adding Firebase to a Cloud project may not yet provision its Hosting site.
SITES_JSON="$("$FIREBASE_CLI" hosting:sites:list --project "$PROJECT_ID" --json --non-interactive)"
SITE_EXISTS="$(printf '%s' "$SITES_JSON" | node --input-type=module -e '
import {readFileSync} from "node:fs";
const reply=JSON.parse(readFileSync(0,"utf8"));
if(reply.status!=="success" || !Array.isArray(reply.result?.sites)) process.exit(1);
console.log(reply.result.sites.some(s=>s.name?.split("/").pop()===process.argv[1]));
' "$PROJECT_ID")" || fail 'Could not verify Hosting sites; deployment stopped.'
if [[ "$SITE_EXISTS" == false ]]; then
  assert_spark
  "$FIREBASE_CLI" hosting:sites:create "$PROJECT_ID" --project "$PROJECT_ID" --non-interactive
fi
assert_spark
"$FIREBASE_CLI" deploy --only hosting --project "$PROJECT_ID" --config "$DEPLOY_DIR/firebase.json" --non-interactive
assert_spark
printf 'Deployed static Hosting release: %s\n' "$SITE_URL"
printf 'Verify: %s/03-check-status.sh %s\n' "$FIREBASE_SCRIPT_DIR" "$PROJECT_ID"
