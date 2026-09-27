# Independent Astra Website: Implementation and Delivery Evidence

Date: 2026-09-27
Requirements: R-SITE-001 through R-SITE-007

## Authorized Scope

Independent website in `codex-astra-site/`, preserving previous candidates, and deployment at `smartgalati-test3.mycodespace.ai` using the existing GCS scripts and test2 load balancer. The user explicitly retained the non-working enrollment URL for comparison. No production-domain cutover.

## Implementation

- Astro 5.18.2, static HTML, locally bundled variable fonts, custom responsive CSS and small browser scripts. No dependency on the other candidate's source/build.
- 20 static pages including the 404; 6 coaches, 7 news records, 3 performance records, 3 galleries with 51 local historical photos. New high-volume albums support external URLs. Photos optimized to responsive WebP.
- Romanian content and default locale; configurable future English locale. English translations are not represented as delivered.
- Markdown collections, schema validation, templates and Romanian authoring documentation; CMS remains optional as in the work-order overview.
- Date-only UTC rolling two-year archive cutoff. Exact cutoff stays current; leap-year clamp tested. Build-time routing generates year-specific archive URLs.
- Working Lichess game embed; browser confirmed `cg-board` renders and site content remains visible when Lichess requests are blocked.
- Contact details revealed on click, avoiding plaintext contact values in initial HTML. This deters naive scraping, not JavaScript-aware scraping.
- Existing editorial content reused; placeholder album/study URLs removed from this candidate. Club facts remain subject to owner verification before production.

## Validation

- `npm run build`: 20 pages, 0 errors, 0 warnings, 0 hints.
- `npm test`: 3 passing tests for boundary/date/URL behavior.
- `npm run dev -- --port 4323`: HTTP 200; IDE-accessible server.
- Production preview browser checks: all 19 content routes and 19 internal link targets; image loading, one main heading, Romanian language attribute.
- Viewports: 1440, 768, 390 and 320 pixels; no horizontal overflow on home; eight representative routes checked on mobile.
- Interactive checks: mobile menu open/Escape/navigation, contact reveal, news tag filtering, gallery album filtering, next-photo keyboard navigation, Escape and focus restoration.
- axe WCAG 2 A/AA + 2.1 AA scan: zero violations on home, courses, coaches, contact, gallery, news, archive and chess pages. This is automated evidence, not a claim of complete accessibility certification.
- Lichess iframe HTTP 200, board rendered in browser; blocked-iframe fallback checked.
- Custom 404 displays a recovery link. Screenshots available locally in `/tmp/astra-browser/`.

## Cloud Resources

- Bucket `gs://test3-smartgalati-mycodespace`, project `mycodespace3p`, region `europe-north1`.
- Shared IP `8.232.113.26`, URL map `chessclub-test2-url-map`, proxy `chessclub-test2-https-proxy`.
- Original default backend `chessclub-test2-backend` preserved. Original `chessclub-test2-cert` retained.
- Added backend `chessclub-test2-test3-smartgalati-mycodespace-backend`, host matcher `smartgalati-test3-mycodespace-ai-matcher`, certificate `chessclub-test2-smartgalati-test3-mycodespace-ai-cert`.
- DNS A `smartgalati-test3.mycodespace.ai` → `8.232.113.26`, zone `mycodespace`, project `central-trees-497510-h7`, TTL 300.
- Existing `scripts/gcs` scripts used unchanged. Candidate wrapper supplies explicit environment parameters; test2 configuration unchanged.
- Initial deployment served root and `/contact/` HTTP 200 through the new host rule. Managed certificate initially provisioning; final HTTPS verification recorded below when complete.

## Automation and Remaining Review

CI builds/tests site changes and supports manually triggered deployment with existing Workload Identity repository variables. Identity/IAM provisioning is not performed automatically; local authenticated deployment is fully operational. Owner visual selection and production readiness remain a separate review.

## Reference Documentation

- [Astro content collections](https://docs.astro.build/en/reference/modules/astro-content/)
- [Lichess official embed interface](https://lichess.org/developers)
- [ANAF current Form 230 information](https://static.anaf.ro/static/10/Anaf/Declaratii_R/230.html) linked from the support page; no fabricated prefilled form or tax deadline.
