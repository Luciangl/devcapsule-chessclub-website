# Independent Rocada Website (smartgalati-test4): Implementation and Delivery Evidence

Date: 2026-09-27
Requirements: R-SITE-001 through R-SITE-007, as narrowed by the [test4 work order](../../work-orders/2026-09-27-smartgalati-test4-prototype.md)

## Authorized Scope

Third independent candidate in `claude-rocada-site/` (source directory chosen as a descriptive name; `SITE_DIR=claude-rocada-site`), deployed at `https://smartgalati-test4.mycodespace.ai` through the existing GCS scripts and the shared `chessclub-test2` load balancer. Enrollment URL kept at the owner's fixed value. No production cutover.

## Design

"Rocada" (castling): navy ink and amber accents on warm paper, Fraunces variable display face with Atkinson Hyperlegible body text (both SIL OFL, bundled locally), a chessboard texture behind page titles, a dark navy hero and support band, card grids with a strong top rule. Not a recolor of either earlier candidate: different type, layout, navigation model (top information band + white navigation bar + "Clubul" dropdown), dark palettes included.

## Content Fidelity Audit

The original `smartgalati.ro` pages and all 134 published posts (May 2016 – February 2025) were downloaded and parsed. Findings that shaped this candidate:

- Several records carried by earlier candidates could not be found on the original site: "Cupa României 2022 – bronz", "Festivalul Național Rapid & Blitz 2023 – 2 aur, 1 argint, 2 bronz", "Divizia B 2024 – argint și calificare", a weekly schedule table, and the news stories dated 2022-10-05, 2023-11-10, 2024-03-20 and 2024-11-15. They are not reproduced here.
- Confirmed facts used instead: founding in early 2014; 2016 national champion Cristi Coca (U12) and the junior team medals at Iași; 2017 Divizia B win and promotion, Teodora Trăistaru national solving champion, junior team medals; 2018 Divizia A win and Superliga qualification; 2022 Superliga 4th place, Dragoș Antonică IM norm and 4th at the U18 World Championship; 2023 Superliga bronze (first Galați medal at that level) and five junior team medals at Sebeș; 2024 Superliga 5th place, Divizia A qualification, F8 gold and F16 silver, Antonică gold at solving; club leadership, contact e-mail and phone; the 2023 Superliga roster and the published senior/junior rosters with their dates.
- All 134 articles were converted to Markdown with their real dates and `source_url`; personal Facebook links were dropped, and phone numbers, e-mail addresses and one bank account in old announcements were replaced with a pointer to the contact page. The first photo of each 2024–2025 post was copied as a local cover (23 images); older posts link to the original for photos.
- Coach bios are the club's own texts (`/instructorii-nostri/`), lightly normalized; the six required coaches with their published titles and ratings.
- Items for owner confirmation are listed in `claude-rocada-site/content/README.md`.

## Implementation

- Astro 5.18.2 static output, `trailingSlash: 'always'`, sharp image optimization, no Tailwind, no runtime service; 284 pages (home, 6 content pages, coaches, performances, gallery + 3 albums, news index, 12 current articles, archive index + 9 year indexes + 122 archived articles, 122 redirect stubs at the old news addresses, chess page, 404).
- Content collections with zod validation (`src/content.config.ts`); templates `_template.md` excluded by the glob; Romanian authoring guide.
- Rolling two-year archive (`src/lib/archive.mjs`), UTC date-only, leap-day clamp; archived articles served at `/arhiva/<year>/<slug>/`; old `/noutati/<slug>/` addresses become meta-refresh stubs so links survive the move.
- Six palettes in `src/styles/themes.css` (Rocada, Solarized Light/Dark, Catppuccin Latte/Mocha, Nord), semantic tokens only, credits at `/licenses/palettes.txt`; labelled native `<select>` in the desktop band and mobile menu, inline head script restores the stored choice before paint, `storage` event keeps tabs in sync, blocked storage degrades gracefully.
- Typography tokens: 17px body, 14px minimum, bold band/meta text.
- Header dropdown: gapless hover region, `:focus-within`, button with `aria-expanded`, Escape/outside click; mobile menu with `hidden`, Escape, focus management.
- Contact: reversed-string encoding, click/keyboard reveal producing `tel:`/`mailto:` links; limits documented.
- Gallery: `<dialog>` lightbox with counter, prev/next, arrow keys, Escape, focus return; thumbnails are plain links to the large WebP without JavaScript.
- Lichess: one public game embed with direct link; page verified with lichess.org blocked.
- i18n scaffold: `src/i18n/` with `ro.ts`, documented steps for a second locale.

## Validation (local, 2026-09-27)

- `npm run build`: astro check 0 errors / 0 warnings / 0 hints; 284 pages.
- `npm test`: 6 archive tests pass (cutoff, boundary day, leap-day clamp, time-of-day independence, configurable window, slug/path routing).
- `npm run test:contrast`: 38 token pairings × 6 palettes pass (≥4.5:1 text, ≥3:1 focus/borders) after adjusting Solarized, Catppuccin and Nord values.
- `npm run test:browser` (Playwright 1.63, Chromium): 16 routes HTTP 200 with one `h1` and `lang="ro"`; all internal link targets 200; archived-article redirect stub; custom 404; dropdown hover/pointer-into-menu/Enter/Tab/Escape; contact reveal (no plain values in HTML, keyboard reveal, `tel:`/`mailto:`); lightbox open/arrow/alt/Escape/focus return; Lichess iframe + fallback with lichess.org blocked; widths 320/390/768/1024/1440 without horizontal overflow, mobile menu with palette control; 720×450 zoom proxy; axe WCAG 2 A/AA + 2.1 AA on six pages with zero violations; no console errors.
- `npm run test:themes`: six palettes applied, stored and restored on three pages each with zero axe violations; early restoration with bundled JS blocked; invalid stored value fallback; blocked `localStorage`; mobile select; cross-tab synchronization.
- Hot reload: `npm run dev` on port 4325; appending a paragraph to `content/pages/inscrieri.md` appeared in the served page within three seconds; reverted.
- Lighthouse 12.8.2, mobile simulation against `npm run preview` on this container: performance 99, accessibility 100, best practices 100, SEO 100; FCP 1.5 s, LCP 2.1 s, TBT 0 ms, CLS 0.017, 452 KiB. Lab numbers, not a guarantee for arbitrary networks.
- Screenshots reviewed in the session (home, news, archive, gallery, coaches, contact, performances, chess, palettes, 320/390 widths); emoji in headless Chromium render as boxes only because the container lacks an emoji font.

## Cloud Resources and Live Verification

(filled in below after provisioning)
