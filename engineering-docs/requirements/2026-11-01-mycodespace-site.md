# R-MYCODESPACE-001: MyCodeSpace website

Status: accepted
Priority: gating
Accepted: 2026-11-01, by owner instruction in chat.

- Deliver in `mycodespace-site/`; preserve existing club sites.
- Target domain: https://mycodespace.ai.
- Clearly identify https://devcapsule.mycodespace.ai as the first product,
  with more to follow; make that link the primary action.
- Owner refined the focus on 2026-11-01: a personal google3-like codespace
  for students, hobbyists and professionals. Use the approved headline "Your
  code. Your projects. Your own space." and explain a home for projects, tools,
  and knowledge. Returning to old code is one benefit, not the main pitch.
  DevCapsule is the first step. No broad security or Google affiliation claims.
- Keep copy concise and conversational. Do not promise future products,
  release dates, or permanent compatibility with all historical programs.
- Follow the existing Astro static build and shared GCS deployment approach.
- Provide a readable responsive page, keyboard focus and a custom 404 page.
- Owner authorized live deployment on 2026-11-01 after accepting the page.
  Serve both apex and www over valid HTTPS, using an apex A record and a www
  CNAME. Preserve existing chess websites and DevCapsule DNS.

Validation: static build, browser checks on mobile and desktop, accessibility
scan, primary link verification, and deployment wrapper plan/failure checks.
