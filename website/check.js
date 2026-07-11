/* NeuroBridge AI — landing website structure & safety check.
   Dependency-free (Node core only). Verifies the landing page contains every
   required section and the required medical-safety wording, and contains none
   of the forbidden medical-claim terms.

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

// 1) Required section anchors (the 17 landing sections).
const requiredIds = [
  "top", "hero", "problem", "solution", "ecosystem", "ai", "games",
  "patient", "doctor", "family", "admin", "reports", "security",
  "research", "faq", "contact",
];
console.log("Sections:");
requiredIds.forEach((id) => {
  (html.includes(`id="${id}"`) ? ok : fail)(`section #${id}`);
});
// Footer is an element, not an id.
(html.includes("<footer") ? ok : fail)("footer element");

// 2) Required safety wording must be present.
console.log("Safety wording present:");
const mustInclude = [
  "not a diagnostic medical system",
  "not a medical diagnosis",
  "not a medical assessment",
  "ai-assisted support",
  "game performance only",
  "pending",
];
mustInclude.forEach((phrase) => {
  (lower.includes(phrase) ? ok : fail)(`"${phrase}"`);
});

// 3) Forbidden medical-claim terms must NOT appear as claims.
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
["styles.css", "script.js"].forEach((f) => {
  const present = html.includes(f) && fs.existsSync(path.join(__dirname, f));
  (present ? ok : fail)(f);
});

console.log("");
if (failures) {
  console.error(`FAILED: ${failures} check(s) did not pass.`);
  process.exit(1);
}
console.log("All checks passed.");
