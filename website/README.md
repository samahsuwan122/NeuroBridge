# NeuroBridge — Landing Website

The public landing website for **NeuroBridge**, a supportive cognitive
rehabilitation platform connecting patients, families, and care teams. It
presents the vision, product modules, family and provider workflows, cognitive
games, supportive review boundaries, security posture, and roadmap. Support is one
supportive module — not the product identity.

> This is the **public marketing site**. It is separate from
> [`../web/`](../web/), which is reserved for the clinical/admin **web
> dashboard** (doctor / therapist / admin). It is also separate from the
> patient **mobile app** in [`../mobile/`](../mobile/).

## Stack

Intentionally **dependency-free**: static **HTML + CSS + vanilla JavaScript**.
No build step, no `node_modules`, no framework — it runs anywhere and stays easy
to review and demo. The JavaScript is progressive enhancement only: with JS
disabled, all content remains fully visible and usable.

- `index.html` — page markup and all sections
- `styles.css` — premium theme (ivory, deep emerald, teal, soft medical blue,
  sage panels, champagne accents, soft shadows, animated orbs) + responsive
  layout + reduced-motion support
- `script.js` — mobile nav toggle, reveal-on-scroll, single-open FAQ accordion,
  hero module search, provider governorate filter, subtle orb parallax
- `assets/` — original SVG artwork only: `logo.svg` (full lockup),
  `logo-mark.svg` (icon), `favicon.svg`, `memory-tree.svg`, and
  `assets/photos/` soft illustration placeholders (`older-adult-care.svg`,
  `doctor-review.svg`, `family-support.svg`, `therapy-session.svg`). Everything
  is hand-drawn SVG — **no external/downloaded images and no real patient or
  doctor photos**. Replace the placeholders with real, permissioned local images
  in `assets/photos/` if/when available (keep the `alt` text).

## Install

No installation required. There are no dependencies.

## Run (local preview)

Open the file directly, or serve the folder with any static server:

```bash
cd website

# Option A — open directly
#   just open index.html in a browser

# Option B — serve locally (Python)
python -m http.server 5500
#   then visit http://localhost:5500

# Option C — serve locally (Node, no install needed)
npx --yes serve .
```

## Build

No build is needed — the site is already production-ready static files. To
"build/deploy", copy the folder contents to any static host (GitHub Pages,
Netlify, S3, nginx, etc.).

An optional structure check (verifies every expected section is present) can be
run with Node:

```bash
node check.js   # if present; see repository notes
```

## Sections

1. Navigation (Home / Platform / Patients / Families / Care Teams / Clinics / Resources / Join / FAQ + Request demo)
2. Hero (search + suggestion chips + large image slot + floating overlay cards)
3. One connected platform (three big visual cards)
4. For Patients (illustration + phone mockup)
5. For Families (illustration + chat + memory wall + appointments + reports)
6. For Care Teams / doctors & therapists (illustration + clinical dashboard mockups)
7. For Clinics / medical centers (illustration + feature list)
8. Platform modules grid (13 modules, Available/Roadmap tags)
9. Provider directory & booking (governorate filter, demo providers only)
10. Memory Tree gallery (original SVG illustration + memory notes)
11. Cognitive games showcase (colored cards, current vs roadmap)
12. Reports & analytics (charts mockup)
13. Supportive review (safety boundary)
14. Security & trust
15. Resources — how it works (4 steps) + use cases
16. Join / Register interest (role cards + mailto form; no account creation)
17. Connected platform (illustration)
18. Early feedback
19. FAQ (accordion)
20. Final CTA
21. Footer (Platform / For Users / Resources / Project / Contact columns)

## Custom images (add your own later)

Every human/scene visual is an original SVG illustration placeholder. You can
drop your own **permissioned, local** photos into `assets/photos/` using the
recommended names — the site upgrades to your image if present and otherwise
keeps the SVG fallback, so **missing image files never break the page**. See
[`assets/photos/README.md`](assets/photos/README.md) for names and rules.

## Join / register interest

The Join section is a **demo UI only** — it does **not create real
accounts**. Submitting the form sends a request that the team reviews before any
account is set up; no personal data is stored client-side (no `localStorage`).
Backend account creation is a later module.

## Content & safety

NeuroBridge is a **connected care platform** for patients, families, and care
teams. The copy makes no medical claims about any condition. Suggestions are
described only as **supportive review** — supportive activity ideas and
performance-based summaries that **require doctor/therapist review**. Cognitive
exercises measure **game performance only**. Everything is framed around daily
follow-up, coordination, and clear reporting.

## Product name note

**"NeuroBridge" is the working name for this platform.**
Before any public or commercial deployment, the product name should be
**reviewed for trademark availability and possible conflicts** (there are
unrelated organizations using similar "NeuroBridge"/"Neuro Bridge" names in other
fields) and confirmed with appropriate legal/branding review.
