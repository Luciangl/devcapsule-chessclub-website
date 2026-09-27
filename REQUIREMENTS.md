# Requirements Register

This file is the project-level overview and index for accepted requirements.
Canonical detailed records belong under `engineering-docs/requirements/`.

## Current Requirements

### R-SITE-001: Static Site Architecture and Multilingual Scaffolding

Statement: Build a clean, high-performance static website using a modern component-based SSG (recommended: Astro + Tailwind CSS) ensuring ease of human comprehension, fast local previews, straightforward styling updates, and built-in configurable multilingual (i18n) support with Romanian (`ro`) as the default language.

Priority: gating

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Section 2)

Validation:

- Site builds purely static HTML/CSS with `npm run build`; hot-reload local preview works via `npm run dev`; i18n routing structure is present and configurable.

### R-SITE-002: Markdown-First Content Authoring for Non-Developers

Statement: Define a structured `content/` directory where non-developer club contributors can author and maintain pages, coach profiles, achievements, and news posts via plain Markdown and intuitive frontmatter headers, compatible with both direct GitHub web editing and an optional lightweight Git-backed visual CMS (e.g. Keystatic / Decap CMS).

Priority: gating

Status: accepted

Implementation:

- `content/pages/`
- `content/coaches/`
- `content/performances/`
- `content/news/`
- `content/galleries/`

Validation:

- Non-technical contributors can add or update content by creating/editing `.md` files without touching website presentation code; edits from GitHub web and CMS write identical standard Markdown files.

### R-SITE-003: Media & Image Management Strategy

Statement: Implement a hybrid image strategy: host curated core assets (logos, headshots, post covers) locally with automated build-time optimization, while linking high-volume tournament photo galleries to external shared public albums (such as Google Photos).

Priority: gating

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Section 4)

Validation:

- Git repository stays lightweight; coaches can upload phone-captured tournament photos to Google Photos and link albums in post frontmatter.

### R-SITE-004: Lichess and Chess Plugin Integration

Statement: Provide an extensible component architecture for embedding Lichess studies, games, broadcast widgets, and PGN viewers without coupling the core static site to external API availability.

Priority: wanted

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Section 5)

Validation:

- Demonstration of interactive/embedded Lichess study/board component in an article.

### R-SITE-005: Core Content Migration, Visual Redesign & 2-Year Archiving

Statement: Migrate and restructure existing club information from `smartgalati.ro` (Despre Noi, Antrenori, Echipe, Performanțe, Contact, Susține 3.5%) into Markdown, completely disregarding the outdated WordPress theme in favor of a modern, responsive, mobile-first design. Automatically route content older than 2 years under an indexed Archive (`/arhiva/` or `/noutati/arhiva/`) in both navigation and URL scheme.

Priority: gating

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Sections 3, 6 & 7)

Validation:

- Visual review across desktop and mobile screens; complete coverage of club essentials; automatic date-based routing of articles older than 2 years to the archive view.

### R-SITE-006: Inquiries Form & Contact Anti-Spam Protection

Statement: Integrate a configurable external forms link (e.g. Google Forms) for student inquiries/enrollment, and protect public club contact details (phone and email) from automated spam scrapers using obfuscation (e.g. CSS reversal, entity encoding, or click-to-reveal).

Priority: gating

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Section 6)

Validation:

- Google Forms link is configurable; email and phone numbers are inaccessible to naive web scraping while fully usable by human visitors.

### R-SITE-007: Hosting & Hosted Preview Deployment

Statement: Support static hosting via GitHub Pages or Google Cloud Storage, with automated preview builds deployed to `smartgalati-test.mycodespace.ai`.

Priority: gating

Status: accepted

Implementation:

- `engineering-docs/work-orders/2026-09-26-chessclub-website.md` (Section 8)

Validation:

- Working preview verified at `smartgalati-test.mycodespace.ai`.

## Independent Astra Candidate (2026-09-27)

The owner authorized a second independent implementation of R-SITE-001 through R-SITE-007 in `codex-astra-site/`, with its own visual design and Markdown content. This is a comparison candidate, not a replacement for `ag-flash3.8-site/`.

For this candidate R-SITE-007 is narrowed to the existing `scripts/gcs` deployment tooling, dedicated bucket `test3-smartgalati-mycodespace`, domain `smartgalati-test3.mycodespace.ai`, and the same `chessclub-test2` load balancer used by test2. Existing test2 routing must remain functional.

The enrollment link remains `https://forms.gle/smartgalati-inscriere` by explicit owner instruction despite its known non-working state. Its external availability is not an acceptance gate for this experiment. Production cutover is outside scope.

Implementation and validation: [candidate guide](codex-astra-site/README.md), [authoring guide](codex-astra-site/content/README.md), and [delivery evidence](engineering-docs/implementation-notes/website/2026-09-27-codex-astra-site.md).

### Astra design refinement: readability and selectable palettes (2026-09-27)

Owner requested larger/heavier desktop top-band text and similarly small labels while preserving the established airy layout. Provide six dropdown choices: original Astra plus five adapted open-source light schemes, remembering each visitor's selection. Shared color and typography tokens govern the whole candidate. Validation includes responsive layout, contrast scans across all palettes, keyboard/native controls, persistence and storage-denied fallback. Applies to the Astra candidate only.

## Independent Rocada Candidate (2026-09-27, smartgalati-test4)

The [test4 work order](engineering-docs/work-orders/2026-09-27-smartgalati-test4-prototype.md) commissioned a third independent implementation of R-SITE-001 through R-SITE-007 in `claude-rocada-site/`, under the test3 conditions (readability tokens, 5–6 selectable palettes, fixed enrollment URL, GCS-only hosting on the shared `chessclub-test2` load balancer). For this candidate R-SITE-007 is narrowed to bucket `test4-smartgalati-mycodespace` and domain `smartgalati-test4.mycodespace.ai`; test2 and test3 routing must remain functional.

Content fidelity clarification: this candidate uses only material confirmed on the club's original website (pages, coach bios, team rosters, performances and all 134 published articles, each carrying its `source_url`). Records present in earlier candidates but not found on the original site (a 2022 Cupa României medal, 2023 junior festival medal counts, a 2024 Divizia B silver, a weekly schedule, several 2022–2024 stories) are not reproduced. Items still requiring owner confirmation are listed in the [candidate content guide](claude-rocada-site/content/README.md#de-verificat-cu-clubul).

Implementation and validation: [candidate guide](claude-rocada-site/README.md), [authoring guide](claude-rocada-site/content/README.md), and [delivery evidence](engineering-docs/implementation-notes/website/2026-09-27-claude-rocada-site.md).
