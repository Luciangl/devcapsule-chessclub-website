# ACS Smart Galați — Astra design candidate

Independent Astro static website for the owner's design comparison. Preview: https://smartgalati-test3.mycodespace.ai. The original site and other candidates remain independent.

## Run in the IDE

Requires Node.js 22 and npm. From the repository root:

```bash
cd codex-astra-site
npm ci
npm run dev -- --port 4323
```

Open http://localhost:4323. The server binds to `0.0.0.0` so the IDE can forward its port. Stop with Ctrl+C.

```bash
npm run build                 # type/schema checks and static dist/
npm run preview -- --port 4323
npm test                      # date boundaries and archive URLs
npx playwright install chromium
npm run test:browser           # against a running server on port 4323
```

Use `SITE_URL=https://smartgalati-test3.mycodespace.ai npm run test:browser` for deployed checks. Screenshots default to `/tmp/astra-browser`; override `ARTIFACT_DIR` as needed.

## Editing

See [the Romanian authoring guide](content/README.md). Content lives in `content/`; layouts/components in `src/`; design tokens and responsive styles in `src/styles/global.css`. Local photos in `src/assets/photos/` are optimized at build time. Fonts are bundled locally. No runtime backend, build-time third-party API, analytics, or remote font service is required. Lichess loads only on the chess page or articles explicitly configured with an embed.

Romanian is the default language; Astro's i18n configuration includes English as a future locale. No English translations or language switcher are advertised yet. Adding translations requires English content and routes under `/en/`, reusing the same layouts and components.

The six coach records and editorial content are migrated from the existing candidate. News dates remain historical. Unverified album/study placeholder links were omitted; the working Lichess demonstration uses the [official embed interface](https://lichess.org/developers). The enrollment URL intentionally remains `https://forms.gle/smartgalati-inscriere`, as requested, even though it is not working. Existing club facts and visual acceptance remain for owner review before production.

The work order describes a visual CMS as optional in its overview; this candidate delivers Markdown editing in the IDE and GitHub, with documented templates. No `/admin` authentication service is introduced.

## Deploy with the existing GCS scripts

Deployment parameters are isolated in `scripts/deployment.env`. This wrapper invokes the repository's `../scripts/gcs/` scripts; it does not change their test2 defaults.

| Resource | Value |
|---|---|
| Domain | `smartgalati-test3.mycodespace.ai` |
| Storage project / region | `mycodespace3p` / `europe-north1` |
| Bucket | `test3-smartgalati-mycodespace` |
| Shared load balancer | `chessclub-test2` in `mycodespace3p` |
| Shared IP | `8.232.113.26` |
| Backend bucket | `chessclub-test2-test3-smartgalati-mycodespace-backend` |
| Certificate | `chessclub-test2-smartgalati-test3-mycodespace-ai-cert` |
| Host matcher | `smartgalati-test3-mycodespace-ai-matcher` |
| DNS project / zone | `central-trees-497510-h7` / `mycodespace` |

With an authenticated `gcloud` account that has the required access:

```bash
npm run deploy -- provision   # initial bucket, upload, host/certificate and DNS
npm run deploy               # subsequent build and upload to test3 only
```

Uploads synchronize only the dedicated test3 bucket, including removing obsolete output there. Public object reads are required for this public static site. The provision command preserves the existing load balancer's default backend and attaches a separate certificate and host rule. Existing GCS tooling may adjust public-access policy if the project requires it; no credentials belong in this directory.

HTML cache lifetime is five minutes; hashed Astro assets are immutable for one year. Managed certificate issuance is asynchronous. Verify HTTPS after it becomes active, including a deep link and test2 continuity.

## Automation

`.github/workflows/codex-astra-site.yml` builds/tests changed site sources and provides an explicit manual deployment option through the same script. To enable CI deployment, configure repository variables `GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_DEPLOY_SERVICE_ACCOUNT` for an existing authorized Workload Identity setup. No long-lived key is stored. Local deployment works independently; this repository does not configure IAM federation automatically.

## Design and maintenance

Warm ivory, forest green, restrained terracotta, generous type, and real club photographs. All pages are static and usable without client rendering. JavaScript is limited to mobile navigation, news/gallery filtering, the accessible gallery dialog, and click-to-reveal contact details. Native links and buttons remain the primary controls.

The browser audit reports site-owned accessibility findings separately from the external Lichess iframe, whose player labels/move list currently have upstream contrast issues. The iframe has a descriptive title and a direct-link alternative.

The archive cutoff is computed during builds. Rebuild regularly to advance it. Archive boundary behavior is covered by tests; a static hosting service cannot recalculate it between deployments.

## Color themes and readable small text

The **Paletă** dropdown is in the desktop top strip and inside the mobile navigation menu. It remembers the visitor's selection on this domain, applies it before the page paints, and synchronizes other open tabs. If browser storage is unavailable it still changes the current page; a fresh visit returns to Astra.

| Choice | Palette source | Adaptation |
|---|---|---|
| Astra · original | Original site design | Ivory and forest green; default |
| Solarized Light | [Ethan Schoonover / Solarized](https://ethanschoonover.com/solarized/) | Warm paper and deep teal |
| Nord Snow | [Nord](https://www.nordtheme.com/docs/colors-and-palettes/) | Cool white and slate |
| Catppuccin Latte | [Catppuccin](https://github.com/catppuccin/catppuccin) | Pale lavender and plum |
| Gruvbox Light | [morhetz / Gruvbox](https://github.com/morhetz/gruvbox) | Warm parchment and charcoal |
| Rosé Pine Dawn | [Rosé Pine](https://github.com/rose-pine/rose-pine-theme) | Soft rose, cream and aubergine |

These are website adaptations of open-source palettes, with stronger foreground colors where needed for text contrast. Attribution and upstream license notices are bundled in `public/licenses/themes.txt`.

All color roles are centralized in `src/styles/themes.css`, with stable choice IDs in `src/lib/themes.ts`. Shared small-text sizes (`--text-label`, `--text-small`, `--text-ui`) and label weight are at the top of `src/styles/global.css`. Desktop top-strip text is 14px/600 at default browser settings; formerly tiny metadata and captions now use at least the 12px label token. Headlines, major spacing and page structure are preserved.

`npm run test:themes` tests all palettes on a production preview at port 4324 (or `SITE_URL`), including accessibility, mobile selection, persistence, disabled storage, early restoration and synchronization between tabs.
