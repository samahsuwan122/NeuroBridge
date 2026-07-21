/* NeuroBridge — public website structure & safety check.
   Dependency-free (Node core only). Verifies the landing page contains every
   required section and the required medical-safety wording, contains none of
   the forbidden medical-claim terms, and that referenced local assets exist.

   Usage:  node check.js   (run from the website/ folder)
   Exits 0 on success, 1 on any failure. */
"use strict";

const fs = require("fs");
const path = require("path");

const html = fs.readFileSync(path.join(__dirname, "index.html"), "utf8");
const lower = html.toLowerCase();
let failures = 0;
const fail = (msg) => { console.error("  ✗ " + msg); failures++; };
const ok = (msg) => console.log("  ✓ " + msg);

// 1) Required section anchors (the 16 landing sections).
const requiredIds = [
  "top", "hero", "platform", "warm-stories", "patients", "families",
  "care-teams", "clinics", "modules", "booking", "memory", "games", "reports",
  "ai", "security", "resources", "join", "research", "stories", "faq", "contact",
];
console.log("Sections:");
requiredIds.forEach((id) => {
  (html.includes(`id="${id}"`) ? ok : fail)(`section #${id}`);
});
(html.includes("<footer") ? ok : fail)("footer element");

// 2) Required safety wording must be present.
console.log("Safety wording present:");
const mustInclude = [
  "not a diagnostic medical system",
  "not a medical diagnosis",
  "not a medical assessment",
  "supportive review",
  "game performance only",
  "performance-only",
  "care-team review",
  "non-diagnostic",
  "academic prototype",
  "pending",
];
mustInclude.forEach((phrase) => {
  (lower.includes(phrase) ? ok : fail)(`"${phrase}"`);
});

// 3) Forbidden medical-claim terms must NOT appear.
console.log("No forbidden medical claims:");
const forbidden = [
  "diagnose alzheimer", "diagnoses", "disease prediction", "predict disease",
  "dementia score", "alzheimer score", "cognitive impairment",
  "abnormal", "medical treatment", "replaces doctors", "replace doctors",
];
forbidden.forEach((term) => {
  (!lower.includes(term) ? ok : fail)(`must not contain "${term}"`);
});

// 4) Referenced local assets must exist.
console.log("Local assets:");
const assets = [
  "styles.css",
  "script.js",
  "assets/neurobridge-logo-mark.png",
  "assets/favicon.svg",
  "assets/memory-tree.svg",
  "assets/photos/older-adult-care.svg",
  "assets/photos/doctor-review.svg",
  "assets/photos/family-support.svg",
  "assets/photos/therapy-session.svg",
  "assets/photos/clinic-team.svg",
];
assets.forEach((f) => {
  const referenced = html.includes(f);
  const exists = fs.existsSync(path.join(__dirname, f));
  (referenced && exists ? ok : fail)(
    `${f}${referenced ? "" : " (not referenced)"}${exists ? "" : " (missing file)"}`
  );
});

console.log("");
if (failures) {
  console.error(`FAILED: ${failures} check(s) did not pass.`);
  process.exit(1);
}
console.log("All checks passed.");
