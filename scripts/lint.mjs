import { existsSync, readFileSync } from "node:fs";

const files = ["index.html", "projects.html", "contact.html", "style.css", "app.js"];
for (const file of files) {
  if (!existsSync(file)) {
    throw new Error(`File inti hilang: ${file}`);
  }
}

for (const page of ["index.html", "projects.html", "contact.html"]) {
  const html = readFileSync(page, "utf8");
  for (const marker of ["<!doctype html>", "<title>", 'name="description"', 'class="nav"']) {
    if (!html.includes(marker)) {
      throw new Error(`${page} belum punya ${marker}`);
    }
  }
}

const css = readFileSync("style.css", "utf8");
if (!css.includes("@media")) {
  throw new Error("style.css wajib punya breakpoint responsif");
}

console.log("profile static lint ok");
