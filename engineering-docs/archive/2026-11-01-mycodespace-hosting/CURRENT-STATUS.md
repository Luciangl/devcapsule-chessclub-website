# MyCodeSpace Hosting Delivery

Name: `mycodespace-hosting`
Start date: 2026-11-01
Outcome: deployed and verified; owner also confirmed both domains work.

## Result

Live: https://mycodespace.ai/ and https://www.mycodespace.ai/.
Apex A: 34.120.230.82; www CNAME: mycodespace.ai. TTL 300.
Google-managed certificate mycodespace-ai-apex-www-cert is ACTIVE for both.

Project: central-trees-497510-h7. Dedicated public bucket:
mycodespace-ai-site-central-trees-497510-h7. Existing shared load balancer:
chessclub-site. Dedicated backend: mycodespace-ai-site-backend; matcher:
mycodespace-ai-site-matcher. Original certificate and default backend preserved.
No project-wide organization policy was changed.

## Evidence

- Build/upload and repeat provisioning passed; existing resources reused.
- DNS verified through authoritative server, Google and Cloudflare resolvers.
- Both ordinary HTTPS requests passed at 09:22 UTC, with correct page content.
- Chromium on both hosts at 390/1440 px: correct page/link, no overflow,
  zero axe violations, no page errors.
- Owner independently confirmed everything works as intended.
- Original chess site and DevCapsule remained available throughout deployment.
- Shell/JavaScript syntax checks and git diff whitespace checks passed.

## Delivery and Next Step

Direct-main under WORKFLOW-LOCAL.md, branch ws-mycodespace-hosting/deployment.
Implementation: c13d4ff, with local dependency-symlink cleanup in 62d93bd;
no dependency symlink is present in the delivered tree.
Future changes: edit the site, then npm run deploy -- update from its directory.
No remaining deployment work. HTTP redirects are not configured; use HTTPS.
Owner's pre-existing DevCapsule TOML/lock changes remain untouched.

## Records

- [Site, targets and deployment commands](../../../mycodespace-site/README.md)
- [Requirements](../../requirements/2026-11-01-mycodespace-site.md)
- intake-dispositions.md: no received items.
