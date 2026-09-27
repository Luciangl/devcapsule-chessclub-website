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

What a pair runs before a checkpoint and before integration, and where the
full description lives.

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
by fast-forward and push normally; never force-push `main`.

This exception ends when the owner declares the prototype phase over or
explicitly restores pull-request delivery. It does not authorize production
domain cutover, which remains a separate owner decision.
