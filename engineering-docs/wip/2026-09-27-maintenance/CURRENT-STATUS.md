# Workstream Current Status: Maintenance

Name: `maintenance`

Start date: `2026-09-27`

State: active; permanent maintenance

Definition read: WORKFLOW.md@eabe23ed644a, WORKFLOW-LOCAL.md@05687aa6136c

Branch association: `ws-maintenance/flaky-dropdown-menu`

## Goal

Own the defects that no open workstream covers, on `main` and on maintained
release lines, and drive maintenance releases, while this repository uses
multiple-streams mode.

## Queue

Read from `main`, not from this file: the bug records under
`engineering-docs/bugs/` whose `owner` is `maintenance` and whose `status` is
neither `closed` nor `retired`. See *Bug Intake* in `WORKFLOW.md`.

## Current State

Bug `engineering-docs/bugs/website/2026-09-27-flaky-dropdown-menu.md` resolved and verified:
- Added seamless hover bridge between trigger button and menu panel, eliminating cursor transit dropouts.
- Implemented click-to-pin persistent mode on "Clubul Nostru" with outside click and Escape key dismissal.
- Added active subpage highlight styling for child routes.
- Verified cleanly with `npm run build` (19 pages, 0 errors, 0 warnings).

## Planned Next Step

Integrate `ws-maintenance/flaky-dropdown-menu` into `main`, release claim `dropdown-usability`, publish status, and await next task.

## Open Threads

- None.
