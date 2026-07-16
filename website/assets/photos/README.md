# NeuroBridge website — photo / image slots

This folder holds the website's visual assets. Every human/scene visual on the
site is currently an **original hand-drawn SVG illustration placeholder** (no
external, downloaded, or real patient/doctor photos).

## How to add your own images (later)

You can drop your own **permissioned, local** images here using the recommended
file names below. The website will **automatically upgrade** to your image if
the file is present, and otherwise keep showing the SVG illustration fallback —
so **missing image files never break the page**.

How it works: each image slot renders the SVG fallback as the default `src` and
carries a `data-upgrade="assets/photos/<name>.jpg"` attribute. On load, a tiny
script preloads that file; if (and only if) it loads successfully, the slot
swaps to your photo. No JS or a missing file → the SVG stays.

### Which image controls which section

Drop a file with the **exact** name below and it becomes that section's main
photo card. If the file is absent, the listed SVG illustration is shown instead
(no broken images, layout unchanged).

| File name (put in this folder)   | Controls this section / card                         | SVG fallback if missing   |
|----------------------------------|------------------------------------------------------|---------------------------|
| `hero-older-adult.jpg`           | **Hero** large photo card (+ Academic-prototype card)| `older-adult-care.svg`    |
| `patient-app-preview.jpg`        | **For Patients** photo card (+ Stories: "new step")  | `therapy-session.svg`     |
| `family-portal-preview.jpg`      | **For Families** photo card                          | `family-support.svg`      |
| `family-support.jpg`             | **Platform** families card (+ Stories: "family")     | `family-support.svg`      |
| `doctor-dashboard-preview.jpg`   | **For Care Teams** (doctors/therapists) photo card   | `doctor-review.svg`       |
| `doctor-review.jpg`              | **Platform** providers card (+ Stories: "review")    | `doctor-review.svg`       |
| `therapy-session.jpg`            | **Platform** patients card                           | `therapy-session.svg`     |
| `clinic-team.jpg`                | **For Clinics** photo card (+ Stories: "reviewed")   | `clinic-team.svg`         |
| `provider-directory.jpg`         | **Provider directory** banner                        | `doctor-review.svg`       |
| `memory-tree.png`                | **Memory Tree** centerpiece — use a **transparent PNG** (no box) | `memory-tree.svg` |
| `memory-tree.jpg`                | Stories poster card ("memory grows")                 | `memory-tree.svg`         |

*"Stories" = the "Warm cognitive support stories" poster cards.*

- Use **JPG, PNG, or WebP** (the `.jpg` name is what the slot looks for).
- Keep the file name **exactly** as above so the slot picks it up.
- Recommended size **~1200×900 (4:3)**, landscape, warm/natural tone. Photo cards
  use `object-fit: cover`, so any 4:3 (or wider) image crops cleanly with no
  distortion.
- Keep or update the surrounding `alt` text in `index.html` for accessibility.
- The navbar/footer brand image is separate: `assets/neurobridge-logo-mark.png`.

## Rules

- **Do not** use real patient or doctor photos without explicit permission.
- **Do not** download copyrighted images.
- Only local files in this folder are referenced — no external image URLs.
