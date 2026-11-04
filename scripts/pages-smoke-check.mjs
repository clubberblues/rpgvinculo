import { chromium } from "playwright";

const baseUrl = process.env.PAGES_BASE_URL || "https://clubberblues.github.io/rpgvinculo/";
const pages = [
  { path: "index.html", title: "Vínculo · Entrar" },
  { path: "ficha.html", title: "Vinculo - Ficha" },
  { path: "lobby.html", title: "Vínculo · Entrar" },
  { path: "mesa.html", title: "Vínculo · Mesa" },
  { path: "dice.html", title: "Project-Swords RPG Dice Roller — 3D Physics Dice for D&D and Tabletop RPGs", language: "en" },
];

const browser = await chromium.launch({ headless: true });
const failures = [];
try {
  const page = await browser.newPage({ viewport: { width: 1365, height: 900 } });
  page.setDefaultNavigationTimeout(30000);

  for (const item of pages) {
    const failuresBeforePage = failures.length;
    const url = new URL(item.path, baseUrl).toString();
    let response;
    for (let attempt = 1; attempt <= 6; attempt++) {
      try {
        response = await page.goto(url, { waitUntil: "domcontentloaded" });
        if (response && response.status() === 200) break;
      } catch (error) {
        if (attempt === 6) failures.push(`${item.path}: navigation failed: ${error.message}`);
      }
      if (attempt < 6) await new Promise(resolve => setTimeout(resolve, 10000));
    }

    if (!response) {
      failures.push(`${item.path}: no HTTP response`);
      continue;
    }
    if (response.status() !== 200) {
      failures.push(`${item.path}: expected HTTP 200, received ${response.status()}`);
      continue;
    }

    const actual = await page.evaluate(() => ({
      title: document.title,
      language: document.documentElement.lang,
      viewport: Boolean(document.querySelector('meta[name="viewport"]')),
      bodyTextLength: (document.body?.innerText || "").trim().length,
    }));

    if (actual.title !== item.title) failures.push(`${item.path}: unexpected title "${actual.title}"`);
    const expectedLanguage = item.language || "pt-BR";
    if (actual.language !== expectedLanguage) failures.push(`${item.path}: expected lang ${expectedLanguage}, received "${actual.language}"`);
    if (!actual.viewport) failures.push(`${item.path}: viewport meta tag missing`);
    if (actual.bodyTextLength < 10) failures.push(`${item.path}: page body appears empty`);

    if (failures.length === failuresBeforePage) {
      console.log(`PASS ${item.path} — HTTP 200, title, language, viewport and body verified`);
    }
  }
} finally {
  await browser.close();
}

if (failures.length) {
  console.error("\nPages smoke test failures:");
  for (const failure of failures) console.error(`- ${failure}`);
  process.exitCode = 1;
} else {
  console.log("\nAll public page smoke checks passed. This test does not authenticate or modify application data.");
}
