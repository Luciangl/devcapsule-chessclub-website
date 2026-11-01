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

Contact refinement (owner instruction, 2026-11-01): remove the outbound LinkedIn
post link. Add “Get in touch with Costin”, prominent but subordinate to the
opening paragraph, with email rendered as SVG outlines and links to GitHub and
LinkedIn profiles. This slice must stop before production deployment.

Contact review refinement (2026-11-01): on wide screens, place the contact
invitation beside the explanation in two columns so it does not interrupt the
reading flow. Introduce it with “Curious? Want to find out more? Want to
contribute?” followed by “Get in touch with Costin!” on a separate line.
Use the owner's supplied JPG portrait, moved from the repository root into a
descriptively named site asset. Keep mobile stacked and stop before deployment.

Header refinement (2026-11-01): keep the header band close to its existing
text/wordmark height, remove the redundant “A home for everything you build”
intro announcement, and reduce empty space above the headline on desktop.

Body-flow refinement (2026-11-01): keep contact as a right-hand body column,
beginning beside the lead paragraph, so the paragraph never stretches above
the card. Text may reclaim the full body width below the card; keep the card
out of the header and preserve the stacked mobile reading order.
