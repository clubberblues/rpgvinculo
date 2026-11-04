import { chromium } from "playwright";

const baseUrl = process.env.PAGES_BASE_URL || "https://clubberblues.github.io/rpgvinculo/";
const pages = [
  { path: "index.html", title: "Vínculo · Entrar" },
  { path: "ficha.html", title: "Vinculo - Ficha" },
  { path: "lobby.html", title: "Vínculo · Salão de Mesas" },
  { path: "mesa.html", title: "Vínculo · Mesa" },
  { path: "dice.html", title: "Project-Swords RPG Dice Roller" },
];

const browser = await chromium.launch({ headless: true });
const failures = [];
try {
  const page = await browser.newPage({ viewport: { width: 1365, height: 900 } });
  page.setDefaultNavigationTimeout(30000);

  for (const item of pages) {
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
    if (actual.language !== "pt-BR") failures.push(`${item.path}: expected lang pt-BR, received "${actual.language}"`);
    if (!actual.viewport) failures.push(`${item.path}: viewport meta tag missing`);
    if (actual.bodyTextLength < 10) failures.push(`${item.path}: page body appears empty`);

    if (failures.length === 0 || !failures.some(x => x.startsWith(item.path + ":"))) {
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
