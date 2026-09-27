# chessclub-website (ACS Smart Galați)

Modern, fast static website for **ACS Smart Galați** ([smartgalati.ro](https://smartgalati.ro/)), an active chess club in Galați, Romania supporting both youth beginner training and competitive national performance.

## Project Purpose & Architecture

- **Static Generation**: Clean, accessible component-based architecture (recommended: Astro + Tailwind CSS) ensuring high performance, zero runtime backend requirements, and easy human maintainability.
- **Content Authoring**: Non-developer contributors (coaches, administrators) maintain pages, profiles, and news via plain Markdown files in a structured `content/` directory.
- **Media Management**: Hybrid approach combining locally optimized core assets (logos, headshots) with external public photo album links (e.g. Google Photos) for tournament coverage without git bloat.
- **Chess Integrations**: Extensible roadmap for Lichess embeds, interactive PGN game viewers, and chess tactical puzzles.

## Project Contracts & Status

- Next candidate work order: [`smartgalati-test4`](engineering-docs/work-orders/2026-09-27-smartgalati-test4-prototype.md)
- Original product work order: [`engineering-docs/work-orders/2026-09-26-chessclub-website.md`](engineering-docs/work-orders/2026-09-26-chessclub-website.md)
- Requirements register: [`REQUIREMENTS.md`](REQUIREMENTS.md)
- Documentation index: [`index.md`](index.md)
- Live status & next resumable task: [`CURRENT-STATUS.md`](CURRENT-STATUS.md)

## Independent Design Candidates

- [`ag-flash3.8-site/`](ag-flash3.8-site/README.md): existing candidate.
- [`codex-astra-site/`](codex-astra-site/README.md): independent ivory/forest-green design, Markdown content, local development on port 4323, and GCS preview at `smartgalati-test3.mycodespace.ai` using the test2 load balancer.
