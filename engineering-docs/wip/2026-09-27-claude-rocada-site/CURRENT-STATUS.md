# Workstream Current Status: Claude Rocada Site

Name: `claude-rocada-site`

Start date: `2026-09-27`

State: active; implementation in progress

Definition read: WORKFLOW.md@eabe23ed644a, WORKFLOW-LOCAL.md@f38ceada0768

Branch association: `ws-claude-rocada-site/implementation`

Target branch: `main`

Delivery method: `direct-main` (owner-authorized prototype exception in `WORKFLOW-LOCAL.md`); synchronize by rebase onto `main`, fast-forward and push normally; never force-push `main`. No human-only merge step.

## Goal

Deliver the independent **smartgalati-test4** candidate commissioned by the
[test4 work order](../../work-orders/2026-09-27-smartgalati-test4-prototype.md):
its own design ("Rocada"), Markdown content, six palettes, gallery, archive,
Lichess demonstration, local development, and a live GCS preview at
`https://smartgalati-test4.mycodespace.ai` through the shared `chessclub-test2`
load balancer, then integrate under the prototype policy.

Candidate source directory: `claude-rocada-site/` (`SITE_DIR=claude-rocada-site`),
chosen as a descriptive name in the same spirit as the earlier candidates.

## Current Task

Site built, validated locally and provisioned (bucket, upload, host rule on
`chessclub-test2`, DNS `8.232.113.26`); managed certificate
`chessclub-test2-smartgalati-test4-mycodespace-ai-cert` is PROVISIONING.
Waiting for ACTIVE, then run the public browser/palette suites against
`https://smartgalati-test4.mycodespace.ai`, verify nested/missing routes and
test2/test3 continuity, complete the evidence note.

## Next Resumable Task

If interrupted: check `npm run deploy -- status` in `claude-rocada-site/`; once
HTTPS serves the Rocada site, run `SITE_URL=https://smartgalati-test4.mycodespace.ai
npm run test:browser` and `npm run test:themes`, fill the "Cloud Resources and Live
Verification" section of
`engineering-docs/implementation-notes/website/2026-09-27-claude-rocada-site.md`,
then finish (archive this directory, remove the root row) and integrate by
rebase + fast-forward + push under the prototype policy.

## Open Threads

- Factual audit: several records in earlier candidates (2022 Cupa României
  bronze, 2023 junior festival medal counts, 2024 Divizia B silver, weekly
  schedule, several 2022–2024 news stories) could not be found on the original
  site. This candidate uses only content confirmed on `smartgalati.ro`; see the
  content README for items still needing owner confirmation.

## Document Index

- `intake/README.md` — intake queue (open only when an item arrives).
- `intake-dispositions.md` — decisions on removed intake items.
