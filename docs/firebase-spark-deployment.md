# Deploy Rocada/test4 to Firebase Spark

The scripts in `scripts/firebase/` publish `claude-rocada-site` to classic
**Firebase Hosting on Spark**, using `https://PROJECT_ID.web.app`. They build
Astro locally and upload static files. No Firebase SDK is needed in the site.

## One-time setup

From the repository root, use Bash, Node **22**, npm, and the
[Google Cloud CLI](https://cloud.google.com/sdk/docs/install). Authenticate the
same Google account with both CLIs; it needs permission to create a project,
add Firebase, manage Hosting, and read the project's billing information.
The scripts also recognize the DevCapsule gcloud installation under
`/home/devcapsule/xtras/google-cloud-sdk` or `$HOME/xtras/google-cloud-sdk`.

```bash
npm ci --prefix scripts/firebase
npm ci --prefix claude-rocada-site

gcloud auth login
scripts/firebase/node_modules/.bin/firebase login
```

If gcloud is outside your shell's PATH, add its `bin` directory before logging
in. On a remote terminal, Firebase supports `login --no-localhost`.
The Firebase CLI is pinned in this repository's package lock.

Choose an unused, globally unique Google project ID, 6–30 lowercase letters,
numbers or hyphens, starting with a letter and ending with a letter or number.
Replace this example before running:

```bash
export FIREBASE_PROJECT_ID=your-unique-rocada-project
scripts/firebase/01-create-project.sh "$FIREBASE_PROJECT_ID"
scripts/firebase/02-deploy.sh "$FIREBASE_PROJECT_ID"
scripts/firebase/03-check-status.sh "$FIREBASE_PROJECT_ID"
```

`01` creates a separate Google project without linking billing and adds Firebase.
It deliberately stops if the project already exists. Alternatively, create a
new **Spark** project in the Firebase console, leave billing unlinked, and skip
`01`. If adding Firebase fails after project creation, retain the project and
finish adding Firebase in the console, then use `02`; nothing is automatically
deleted. Organization policy or project-creation quotas may require an account
administrator's help.

`02` verifies the billing state, builds the site, checks billing again, and
creates the matching Hosting site if necessary before publishing the live
release. First-time site provisioning may take a few minutes to propagate; if
publication fails with a missing-site error, wait and rerun `02`.

`03` checks billing, displays the Hosting site, and verifies home, contact,
gallery, the 404 page, the canonical hostname, and a trailing-slash redirect.
It does not report remaining traffic quota; view that in Firebase Console →
Hosting → Usage.

The URL is `https://YOUR_PROJECT_ID.web.app`. Subsequent changes need only
`02`, followed by `03`. The project ID may also be supplied through
`FIREBASE_PROJECT_ID` with no argument. No default cloud project or Firebase
alias is used. `02` accepts an optional second argument for another compatible
Astro directory in this checkout, but only Rocada is verified here and `03`
expects Rocada's routes.

## What keeps the hosting bill at $0

The guard requires the exact target project's Cloud Billing response to show
`billingEnabled: false` and no linked billing account. A paid project, a linked
but disabled billing account, unreadable billing information, or malformed
response stops the operation. There is no bypass flag. Billing is rechecked
immediately before publication and afterwards.

The deployment uses a generated configuration in a temporary directory,
containing only `hosting`, with an explicit project/site ID and copied `dist/`
files. It never imports source Firebase configuration, functions, SSR, deploy
hooks, or aliases. Hidden files and symlinks in `dist/` are rejected. HTML and
unversioned files cache for five minutes; fingerprinted `/_astro/` assets cache
for a year. Real page routes and a custom `404.html` are retained.

**The financial boundary is keeping the project on Spark with no billing
account attached.** The scripts neither attach billing nor upgrade the plan.
They cannot prevent a project administrator linking billing later, or doing so
concurrently with a deployment. Keep this project separate from billed projects
and limit who can change billing. A post-deployment guard failure reports the
problem but cannot undo an administrator's billing change or the published
release.

As checked on 2026-09-30, the Hosting usage guide describes 10 GB of storage and
10 GB/month of data transfer at no cost. On Spark, reaching the storage limit
blocks new deployments; exceeding transfer allowance disables serving after a
short grace period until the next month. This accepts downtime rather than
paid overage. Retained releases count toward storage, so configure release
retention or delete old releases if necessary. See the
[official quota and shutdown rules](https://firebase.google.com/docs/hosting/usage-quotas-pricing).

The default `web.app` address needs no purchased domain. Existing GCS hosting
continues to incur its own charges until separately retired. These scripts do
not change GCS resources or DNS. A custom domain is a separate migration and
requires updating the deployment's canonical URL; the scripts currently use
`web.app` throughout.

## Local validation without a cloud project

```bash
npm test --prefix scripts/firebase
npm test --prefix claude-rocada-site
scripts/firebase/02-deploy.sh --prepare-only demo-rocada-spark
```

`--prepare-only` runs no cloud commands and retains an artifact directory printed
at the end. It contains `firebase.json` and `public/`; inspect those before any
live deployment. Remove the temporary directory yourself when finished.

To test that artifact with Firebase's Hosting emulator, replace the example
artifact path with the printed path:

```bash
REPO_DIR="$PWD"
ARTIFACT_DIR=/tmp/chessclub-firebase.REPLACE
cd "$ARTIFACT_DIR"
"$REPO_DIR/scripts/firebase/node_modules/.bin/firebase" emulators:exec \
  --only hosting --project demo-rocada-spark --config "$ARTIFACT_DIR/firebase.json" \
  "node '$REPO_DIR/scripts/firebase/tests/check-emulator.mjs'"
```

The emulator check uses local port 5000 and the `demo-rocada-spark` canonical
hostname. It verifies routes, redirects, canonical URL, and cache headers.
Automated command tests use mocked CLIs; neither those nor the emulator prove
that a particular account has cloud provisioning permissions. Live project
creation and publication still need an authenticated operator.

Implementation references:
[Firebase CLI](https://firebase.google.com/docs/cli),
[Hosting configuration](https://firebase.google.com/docs/hosting/full-config),
[Cloud Billing project information](https://cloud.google.com/billing/docs/reference/rest/v1/projects/getBillingInfo).
