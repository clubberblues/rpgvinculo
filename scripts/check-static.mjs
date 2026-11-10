import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const htmlFiles = ['index.html', 'lobby.html', 'ficha.html', 'mesa.html', 'dice.html'];
const standaloneScripts = ['vinculo-ui.js'];
const failures = [];
let checkedInlineScripts = 0;

function reportFailure(message) {
  failures.push(message);
  process.stderr.write('FAIL: ' + message + '\n');
}

function checkJavaScript(source, label, isModule = false) {
  const args = ['--check'];
  if (isModule) args.push('--input-type=module');
  const result = spawnSync(process.execPath, args, {
    input: source,
    encoding: 'utf8',
    cwd: root,
    maxBuffer: 4 * 1024 * 1024
  });
  if (result.status !== 0) {
    reportFailure(label + '\n' + (result.stderr || result.stdout || 'Node syntax check failed'));
    return;
  }
  checkedInlineScripts += 1;
}

for (const relativePath of htmlFiles) {
  const absolutePath = resolve(root, relativePath);
  if (!existsSync(absolutePath)) {
    reportFailure('Required page not found: ' + relativePath);
    continue;
  }

  const html = readFileSync(absolutePath, 'utf8');
  const scriptTag = /<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi;
  let match;
  let inlineIndex = 0;

  while ((match = scriptTag.exec(html)) !== null) {
    const attributes = match[1] || '';
    const source = match[2] || '';
    const src = attributes.match(/\bsrc\s*=\s*["']([^"']+)["']/i);
    if (src) {
      const sourcePath = src[1].split(/[?#]/, 1)[0];
      if (!/^(?:[a-z]+:)?\/\//i.test(sourcePath) && !sourcePath.startsWith('data:') && sourcePath) {
        const localPath = resolve(dirname(absolutePath), sourcePath);
        if (!existsSync(localPath)) reportFailure(relativePath + ' references missing local script: ' + sourcePath);
      }
      continue;
    }

    const typeMatch = attributes.match(/\btype\s*=\s*["']([^"']+)["']/i);
    const type = (typeMatch?.[1] || '').toLowerCase();
    if (type && !['module', 'text/javascript', 'application/javascript'].includes(type)) continue;
    if (!source.trim()) continue;

    inlineIndex += 1;
    checkJavaScript(source, relativePath + ' inline script #' + inlineIndex, type === 'module');
  }
}

for (const relativePath of standaloneScripts) {
  const absolutePath = resolve(root, relativePath);
  if (!existsSync(absolutePath)) {
    reportFailure('Required shared script not found: ' + relativePath);
    continue;
  }
  checkJavaScript(readFileSync(absolutePath, 'utf8'), relativePath);
}

// Product invariant: a requested roll must wait for the user's click in the Dice iframe.
const mesa = readFileSync(resolve(root, 'mesa.html'), 'utf8');
const dice = readFileSync(resolve(root, 'dice.html'), 'utf8');
if (!mesa.includes("action:aguardarClique?'prepareRoll':'roll'")) {
  reportFailure('mesa.html no longer sends prepareRoll for click-required rolls.');
}
if (/\btrue\s*,\s*false\s*,/.test(mesa)) {
  reportFailure('mesa.html contains an explicit auto-roll callsite (true,false); review against the manual-roll requirement.');
}
if (!dice.includes("if (!aguardarClique) {") || !dice.includes("vinculoRollButton.addEventListener('click', triggerNativeThrow);") || !dice.includes('ROLAR AGORA')) {
  reportFailure('dice.html manual-click handshake changed; review before accepting automatic or hidden rolls.');
}

for (const required of ['registrar_iniciativa_d20', 'iniciar_iniciativa_com_dados', 'registrar_rolagem_ataque_iterativo_srd']) {
  if (!mesa.includes(required)) reportFailure('mesa.html is missing the manual-roll flow contract: ' + required);
}

// Product invariant: both campaign-deletion entry points must clean public and private Storage.
const lobby = readFileSync(resolve(root, 'lobby.html'), 'utf8');
for (const required of [
  "listarArquivosStorageRecursivo('midia','campaigns/'+id,0)",
  "listarArquivosStorageRecursivo('mesa-media','campaigns/'+id,0)",
  "{bucket:'midia',paths:caminhos.midia||[]}",
  "{bucket:'mesa-media',paths:caminhos.mesaMedia||[]}",
  "var totalMediaPaths=mediaPaths.midia.length+mediaPaths.mesaMedia.length"
]) {
  if (!lobby.includes(required)) reportFailure('lobby.html campaign deletion is missing Storage cleanup contract: ' + required);
}

// Product invariant: an uploaded private CBA asset is compensated if signed-URL creation fails.
for (const required of [
  'async function descartarUploadPrivadoCBA(path)',
  "sb.storage.from('mesa-media').remove([String(path)])",
  'await descartarUploadPrivadoCBA(path);'
]) {
  if (!mesa.includes(required)) reportFailure('mesa.html is missing private CBA upload compensation: ' + required);
}

const activePageSource = htmlFiles.map((file) => readFileSync(resolve(root, file), 'utf8')).join('\n');
if (/\.rpc\s*\(\s*['"`]roll_dice['"`]/.test(activePageSource)) {
  reportFailure('An active page calls server-side roll_dice; action rolls must come from the user-clicked Dice UI.');
}

if (failures.length) {
  process.stderr.write('\nStatic validation failed: ' + failures.length + ' issue(s).\n');
  process.exit(1);
}

process.stdout.write('Static validation passed. Checked ' + checkedInlineScripts + ' inline/shared JavaScript block(s) across ' + htmlFiles.length + ' active pages. Manual Dice click invariant verified.\n');
