# Local Workflow: chessclub-website

This is the project's own half of the workflow. `WORKFLOW.md` beside it is the
installed generic definition and binds wherever it speaks; this file governs
wherever it is silent. The headings below are the topics a project usually
needs to settle for itself. Fill the ones that apply, delete the ones that do
not, and add any this project needs that were not foreseen. Bootstrap wrote
this file once and will not touch it again. See *The Project's Local
Workflow* in `WORKFLOW.md`.

## Integration Branch

Fill in only if it is not `main`. `WORKFLOW.md` says `main` throughout and
means the project's integration branch, whatever its name; state the name
here if it differs, for example `master` or `trunk`.

## Version Scheme

How the source names itself between releases and at a release, and the
command that sets it. For example: a Python project carries `X.Y.Z.dev0`
between releases and `X.Y.Z` at the release; a Maven project carries
`X.Y.Z-SNAPSHOT`. The marker must order before the release in the
ecosystem's tooling.

## Release Policy

The ref spelling if it differs from `release-<version>` and `v<version>`; how
a candidate is built and published; what the candidate gate checks and how a
documented exception is recorded; what acceptance evidence is required; and
where the acceptance record lives.

## Validation Commands

Each site directory is an independent Astro project with its own
`package-lock.json`. Every command below runs from the named site directory.

**Environment.** Node.js 22 (`node --version` prints `v22.x`; the capsule's
`node` capability provides it) and npm. In the site directory being changed:
`npm ci`. The browser suites additionally need Playwright's Chromium:
`npx playwright install chromium`.

**Unit tests.**

- `claude-rocada-site/`: `npm test && npm run test:contrast`
- `codex-astra-site/`: `npm test`
- `ag-flash3.8-site/`, `smartgalati-test5-site/`, `mycodespace-site/`: none;
  these prototypes carry no test suite.

**Integration tests.** The static build, in any site directory:
`npm run build`. It must finish with zero errors (it includes `astro check`
in `claude-rocada-site/`, `codex-astra-site/` and `ag-flash3.8-site/`).

**End-to-end tests.** Playwright against a running site, opt-in:

- `claude-rocada-site/`: start `npm run preview` (port 4326), then
  `npm run test:browser && npm run test:themes`. For the GitHub Pages base
  path: `npm run pages:build && npm run pages:check`.
- `codex-astra-site/`: start `npm run preview`, then
  `npm run test:browser && npm run test:themes`.
- The other sites: none.

Each site's `README.md` holds the full description, including `SITE_URL=`
for running the browser suites against a deployed host.

**Smoke test.** `npm run preview` in the site directory, then
`curl --fail --silent http://localhost:<port>/` returns the home page (the
port is in that site's `package.json`). After a deployment, the same `curl`
against the deployed URL.

**Gate.** Before a checkpoint and before integration, for every site
directory the change touches: its unit tests, then `npm run build`. A change
to documentation or workflow files only has no runtime gate; check the
Markdown links it adds and `git diff --check`.

**Candidate gate and acceptance evidence.** None: the project is in its
prototype phase and cuts no releases. A deployment is verified by the smoke
test and, where the site has them, the end-to-end suites against the deployed
URL; the evidence goes in the delivering workstream's status file.

## Host Capabilities

What the project needs from the machine and the hosting service that the
generic workflow cannot assume: branch permissions, runners, credentials, and
the justification for each.

## Exceptions

### Prototype-phase direct integration

Authorized by the project owner on 2026-09-27. While this project is a
prototype/design experiment, `direct-main` is the default delivery method.
Agents may integrate completed work into `main` and push `main` directly,
without a pull request or another per-change merge confirmation. This also
applies to the completed `codex-astra-site` workstream.

Reason: prioritize quick design experiments while retaining the workflow
scaffolding for later engineering practice. Keep validation proportional to
the change and retain concise requirements, evidence and resumable state.
Use the direct-main procedure in `WORKFLOW.md`: synchronize first, integrate
by one merge commit per deliverable (`git merge --no-ff`, the rule since
definition 0.3.0; fast-forward before that) and push normally; never
force-push `main`.

This exception ends when the owner declares the prototype phase over or
explicitly restores pull-request delivery. It does not authorize production
domain cutover, which remains a separate owner decision.
