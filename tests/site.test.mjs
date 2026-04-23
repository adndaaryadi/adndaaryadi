import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";

const pages = ["index.html", "projects.html", "contact.html"];

test("semua halaman profile punya navigasi lengkap", () => {
  for (const page of pages) {
    const html = readFileSync(page, "utf8");
    for (const href of ['./index.html', './projects.html', './contact.html']) {
      assert.ok(html.includes(href), `${page} belum punya link ${href}`);
    }
  }
});

test("halaman contact punya github dan email", () => {
  const html = readFileSync("contact.html", "utf8");
  assert.ok(html.includes("https://github.com/adndaaryadi"));
  assert.ok(html.includes("mailto:adindasalsaaryadi@gmail.com"));
});
