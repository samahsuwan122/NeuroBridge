# NeuroBridge — Public Website

The dependency-free public marketing website for NeuroBridge, a supportive
cognitive rehabilitation and follow-up platform connecting patients, families,
and care teams. This folder is separate from the application, backend, and
mobile client.

## Stack

Static HTML, CSS, and vanilla JavaScript. There is no build step or package
installation.

- `index.html` — public home page
- `about.html`, `platform.html`, `patients.html`, `families.html`,
  `care-teams.html`, `clinics.html`, and `resources.html` — focused public pages
- `request-demo.html` — access-request page
- `styles.css` — responsive light/dark NeuroBridge theme
- `script.js` — language and theme persistence, mobile navigation,
  access-request submission, and the local public AI demo
- `translations.js` — Arabic, French, Spanish, and German website copy
- `assets/` — the NeuroBridge logo mark and local JPG/PNG photographs

## Run locally

From this directory:

```bash
python -m http.server 5500
```

Then open `http://localhost:5500`.

## Validation

The dependency-free checker validates every HTML page, internal page links,
local asset references, one primary heading per page, and the required CSS and
JavaScript references:

```bash
node check.js
node --check script.js
node --check translations.js
node --check check.js
```

## Pages and content

The home page introduces NeuroBridge, its supportive safety boundaries, the
public AI demo, the project team, and primary calls to action. Dedicated pages
explain the platform, patient, family, care-team, clinic, resource/FAQ, and
access-request experiences in more detail.

Current pages use local JPG and PNG assets from `assets/photos/`. Keep images
local, permissioned, optimized for the web, and paired with meaningful `alt`
text where they convey content.

The access form does **not create an account**. It submits a pending request for
team review; no personal data is stored in website `localStorage`.

## Content and safety

NeuroBridge is presented as a connected care platform. Website copy must not
claim diagnosis, treatment decisions, medication advice, risk prediction, or
automated clinical judgment. Activities and reports remain performance-only
and intended for supportive care-team review.

## Product name

“NeuroBridge” is the working project name. Trademark and branding availability
should be reviewed before public or commercial deployment.
