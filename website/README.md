# NeuroBridge — Landing Website

The public landing website for **NeuroBridge**, an AI-powered cognitive
rehabilitation ecosystem. It presents the vision, product modules, cognitive
exercises, safe-AI boundaries, security posture, and roadmap.

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
- `styles.css` — premium theme (deep emerald/teal, ivory, sage cards, champagne
  gold accents, glass-like surfaces) + responsive layout
- `script.js` — mobile nav toggle, reveal-on-scroll, single-open FAQ

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

1. Navigation bar
2. Hero
3. Problem
4. Solution
5. Product ecosystem
6. AI engine
7. Cognitive exercises
8. Patient app
9. Doctor portal
10. Family portal
11. Admin dashboard
12. Reports & analytics
13. Security & privacy
14. Research / academic prototype
15. FAQ
16. Contact CTA
17. Footer

## Content & safety

NeuroBridge is **not a diagnostic medical system**. The copy makes no claim
to diagnose, predict disease, or treat any condition, and never says AI replaces
doctors. AI is described only as **AI-assisted support** — supportive activity
recommendations and performance summaries that are **not a medical diagnosis and
not a medical assessment** and **require doctor/therapist review**. Cognitive
exercises measure **game performance only**.
