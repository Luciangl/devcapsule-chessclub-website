# chessclub-website (ACS Smart Galați)

Modern, fast static website for **ACS Smart Galați** ([smartgalati.ro](https://smartgalati.ro/)), an active chess club in Galați, Romania supporting both youth beginner training and competitive national performance.

## Project Purpose & Architecture

- **Static Generation**: Clean, accessible component-based architecture (recommended: Astro + Tailwind CSS) ensuring high performance, zero runtime backend requirements, and easy human maintainability.
- **Content Authoring**: Non-developer contributors (coaches, administrators) maintain pages, profiles, and news via plain Markdown files in a structured `content/` directory.
- **Media Management**: Hybrid approach combining locally optimized core assets (logos, headshots) with external public photo album links (e.g. Google Photos) for tournament coverage without git bloat.
- **Chess Integrations**: Extensible roadmap for Lichess embeds, interactive PGN game viewers, and chess tactical puzzles.

## Project Contracts & Status

- Next candidate work order: [`smartgalati-test5`](engineering-docs/work-orders/2026-09-27-smartgalati-test5-prototype.md)
- Test4 candidate work order: [`smartgalati-test4`](engineering-docs/work-orders/2026-09-27-smartgalati-test4-prototype.md) — delivered by `claude-rocada-site/`
- Original product work order: [`engineering-docs/work-orders/2026-09-26-chessclub-website.md`](engineering-docs/work-orders/2026-09-26-chessclub-website.md)
- Requirements register: [`REQUIREMENTS.md`](REQUIREMENTS.md)
- Documentation index: [`index.md`](index.md)
- Live status & next resumable task: [`CURRENT-STATUS.md`](CURRENT-STATUS.md)

## Independent Design Candidates

- [`ag-flash3.8-site/`](ag-flash3.8-site/README.md): existing candidate.
- [`codex-astra-site/`](codex-astra-site/README.md): independent ivory/forest-green design, Markdown content, local development on port 4323, and GCS preview at `smartgalati-test3.mycodespace.ai` using the test2 load balancer.
- [`claude-rocada-site/`](claude-rocada-site/README.md): independent "Rocada" design (navy/amber on warm paper, six palettes including dark ones), content taken only from the club's original site including all 134 historical articles, local development on port 4325, and GCS preview at `smartgalati-test4.mycodespace.ai` using the test2 load balancer.
- [`smartgalati-test5-site/`](smartgalati-test5-site/README.md): independent design featuring a choice of 5 color themes (default, dark, solarized-light, nord, sepia), full markdown integration based on `test4`, interactive galleries and Lichess embed, local development on port 4327. Deployment currently blocked on GCP `BACKEND_BUCKETS` quota limit.

## Firebase Spark Preview

Deploy the Rocada/test4 static site to a separate unbilled Firebase project using
[the Spark deployment guide](docs/firebase-spark-deployment.md). Scripts include
project setup, billing checks, static deployment, and verification.

## GitHub Pages

[`.github/workflows/claude-rocada-pages.yml`](.github/workflows/claude-rocada-pages.yml)
publishes the Rocada/test4 site to this repository's GitHub Pages site at
`https://ccozianu.github.io/devcapsule-chessclub-website/` on every `main` change
under `claude-rocada-site/`. Enabling Pages (Source: GitHub Actions) and plan
eligibility for a private repository are owner steps; see
[the GitHub Pages deployment guide](docs/github-pages-deployment.md).

## MyCodeSpace

[`mycodespace-site/`](mycodespace-site/README.md) is the small English landing page for
mycodespace.ai, introducing DevCapsule as its first product. Local port: 4329.
Live at https://mycodespace.ai/ and https://www.mycodespace.ai/.
Deployment tooling reuses the shared GCS upload suite and the original load balancer.
