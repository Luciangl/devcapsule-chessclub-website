# MyCodeSpace

Small English landing page for https://mycodespace.ai. DevCapsule is the first
product; the broader aim is a personal home for code, projects, tools, and
project knowledge, for students, hobbyists and professionals.

Copy draws on [Costin's LinkedIn post](https://lnkd.in/p/dJNtaetF) and the
[DevCapsule website](https://devcapsule.mycodespace.ai/). It describes the broader
aim as an ambition. The owner approved the personal google3 analogy on
2026-11-01. Google’s shared-codebase background is documented in
[Google’s repository paper](https://research.google/pubs/why-google-stores-billions-of-lines-of-code-in-a-single-repository/).
This is not a claim of Google affiliation or a security guarantee.

## Local development

From this directory:

```bash
npm ci
npm run dev
```

Open http://localhost:4329. `npm run build` produces static files in `dist/`;
`npm run preview` serves the build on the same port. Stop dev before preview.
There is no backend, browser JavaScript, analytics, remote font, or account setup.

Edit `src/pages/index.astro` for copy and `src/styles/global.css` for appearance.
The short page deliberately keeps content in one file rather than adding a CMS.
`src/pages/404.astro` is the custom error page. Public assets include the favicon,
robots.txt and single-page sitemap.

## GCS deployment

Live addresses: https://mycodespace.ai/ and https://www.mycodespace.ai/.
Both serve this site; the canonical URL is the apex.

The wrapper uses the repository's [shared upload script](../scripts/gcs/README.md)
and a scoped provisioning helper. Defaults in `scripts/deployment.env` identify
only this site's resources:

| Resource | Value |
|---|---|
| GCP project (storage, load balancer, DNS) | `central-trees-497510-h7` |
| Dedicated bucket | `mycodespace-ai-site-central-trees-497510-h7` |
| Shared load balancer | `chessclub-site` |
| Shared IP | `34.120.230.82` |
| Backend bucket | `mycodespace-ai-site-backend` |
| Host matcher | `mycodespace-ai-site-matcher` |
| Managed certificate | `mycodespace-ai-apex-www-cert` |
| DNS zone | `mycodespace` |
| Apex A | `mycodespace.ai` → `34.120.230.82` |
| www CNAME | `www.mycodespace.ai` → `mycodespace.ai.` |

Authenticate with `gcloud auth login`, then run from this directory:

```bash
npm run deploy -- plan      # Prints targets; no cloud changes
npm run deploy -- update    # Builds and synchronizes this site's bucket
```

Updates delete unmatched files in the dedicated bucket. HTML is cached for five
minutes; hashed Astro assets are cached for a year. If needed, invalidate only
hosts `mycodespace.ai` and `www.mycodespace.ai` on `chessclub-site-url-map`.

For initial setup or to reapply missing resources:

```bash
npm run deploy -- provision
```

Provision checks the existing load balancer and conflicting DNS records, creates
the dedicated public bucket/backend, builds and uploads the site, appends a
certificate covering both names, adds an exact host rule, and creates/updates
only the apex A and www CNAME. It preserves existing certificates, default
backend, other host rules, and unrelated DNS records. It does not change
project-wide organization policies or configure HTTP redirects. GCP billing
applies. Existing targets can be overridden with environment variables.

Certificate activation and routing propagation may take time. Verify both HTTPS
hosts and the original chess site after provisioning. DevCapsule remains on its
existing independent GitHub Pages CNAME.
