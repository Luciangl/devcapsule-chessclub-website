# MyCodeSpace

Small English landing page for https://mycodespace.ai. DevCapsule is the first
product; the broader aim is to keep code, its working environment, and project
knowledge available when you come back years later.

Copy draws on [Costin's LinkedIn post](https://lnkd.in/p/dJNtaetF) and the
[DevCapsule website](https://devcapsule.mycodespace.ai/). It describes the broader
aim as an ambition, not a guarantee that DevCapsule runs arbitrary old software.

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

Uses the repository's [shared GCS suite](../scripts/gcs/README.md), with an
isolated wrapper. It does not inherit the chess sites' bucket or project targets.
No cloud resources or DNS changes have been made for this site.

Use a dedicated bucket: updates synchronize with deletion of destination files.
Set the actual target project and bucket first; these example values are not
provisioned resources:

```bash
export PROJECT_ID=your-gcp-project
export BUCKET_NAME=your-dedicated-mycodespace-bucket
npm run deploy -- plan
```

The default command prints a plan without contacting Google Cloud. For an
already configured bucket and domain:

```bash
npm run deploy -- update
```

For first-time hosting on an existing shared HTTPS load balancer, set:

```bash
export LB_PROJECT_ID=your-load-balancer-project
export EXISTING_LB_NAME=your-existing-load-balancer-prefix
export DNS_PROJECT_ID=your-dns-project
export DNS_ZONE=your-dns-zone
npm run deploy -- provision
```

Provision creates a public bucket, uploads the site, appends a managed certificate
and host rule, and changes the **mycodespace.ai apex A record**. Review existing
apex A/AAAA records and the load balancer's backend-bucket quota before running
it. Keep unrelated DNS records and routes intact. Shared bucket setup may try a
project-wide domain-sharing policy override if public access is blocked; review
that inherited behavior before provisioning. Google Cloud billing applies.

The configured domain is always `mycodespace.ai`. This wrapper does not configure
`www` or redirect HTTP. Certificate activation may take time. Validate HTTPS,
the root page, `/404.html`, a missing URL, and existing neighboring sites after
provisioning. After an update, HTML may remain cached for five minutes; if needed,
invalidate only host `mycodespace.ai` on the selected URL map.
