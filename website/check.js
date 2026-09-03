/* NeuroBridge public website multipage structure check.
   Dependency-free (Node core only). Run from any directory with:
   node website/check.js
*/
"use strict";

const fs = require("fs");
const path = require("path");

const root = __dirname;
const pages = fs.readdirSync(root).filter((name) => name.endsWith(".html")).sort();
let failures = 0;

function fail(message) {
  console.error(`  FAIL ${message}`);
  failures += 1;
}

function ok(message) {
  console.log(`  OK   ${message}`);
}

function localPath(reference) {
  const value = reference.split("#", 1)[0].split("?", 1)[0];
  return value ? path.resolve(root, decodeURIComponent(value)) : null;
}

if (!pages.length) fail("no HTML pages found");

for (const page of pages) {
  const html = fs.readFileSync(path.join(root, page), "utf8");
  console.log(`\n${page}`);

  const h1Count = (html.match(/<h1(?:\s|>)/gi) || []).length;
  if (h1Count === 1) ok("contains exactly one h1");
  else fail(`must contain exactly one h1 (found ${h1Count})`);

  for (const required of ["styles.css", "translations.js", "script.js"]) {
    const attribute = required.endsWith(".css") ? "href" : "src";
    const escapedRequired = required.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const expression = new RegExp(`${attribute}=["']${escapedRequired}["']`, "i");
    if (expression.test(html)) ok(`references ${required}`);
    else fail(`does not reference ${required}`);
  }

  const references = [...html.matchAll(/(?:src|href)=["']([^"']+)["']/gi)]
    .map((match) => match[1]);

  for (const reference of references) {
    if (/^(?:https?:|mailto:|tel:|data:|javascript:)/i.test(reference)) continue;

    if (reference.startsWith("#")) {
      const id = reference.slice(1);
      const escaped = id.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      if (!id || new RegExp(`\\bid=["']${escaped}["']`).test(html)) continue;
      fail(`broken same-page link ${reference}`);
      continue;
    }

    const target = localPath(reference);
    if (!target || !fs.existsSync(target)) {
      fail(`missing local reference ${reference}`);
      continue;
    }

    const fragment = reference.includes("#") ? reference.slice(reference.indexOf("#") + 1) : "";
    if (fragment && target.endsWith(".html")) {
      const targetHtml = fs.readFileSync(target, "utf8");
      const escaped = fragment.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
      if (!new RegExp(`\\bid=["']${escaped}["']`).test(targetHtml)) {
        fail(`missing fragment #${fragment} in ${path.basename(target)}`);
      }
    }
  }
}

console.log("");
if (failures) {
  console.error(`FAILED: ${failures} check(s) did not pass.`);
  process.exit(1);
}
console.log(`All checks passed for ${pages.length} HTML pages.`);
