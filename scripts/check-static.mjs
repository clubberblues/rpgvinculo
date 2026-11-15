import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';
import { dirname, resolve } from 'node:path';
import { runInNewContext } from 'node:vm';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const htmlFiles = ['index.html', 'lobby.html', 'ficha.html', 'mesa.html', 'dice.html'];
const standaloneScripts = ['vinculo-ui.js', 'class-controls-ui.js'];
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

// Class-control manifest: every basic class has its own level-1 controls and level gates.
const classControlsWindow = {};
runInNewContext(readFileSync(resolve(root, 'class-controls-ui.js'), 'utf8'), { window: classControlsWindow });
const classControls = classControlsWindow.VinculoClassControls;
assert.ok(classControls, 'Class controls module must expose its API.');
const classFixtures = [
  ['barbaro', 'barbarian', 'rage'],
  ['bardo', 'bard', 'bardic_music'],
  ['clerigo', 'cleric', 'turn_undead'],
  ['druida', 'druid', 'animal_companion'],
  ['guerreiro', 'fighter', 'bonus_combat_feat'],
  ['monge', 'monk', 'flurry_of_blows'],
  ['paladino', 'paladin', 'smite_evil'],
  ['ranger', 'ranger', 'favored_enemy'],
  ['ladino', 'rogue', 'sneak_attack'],
  ['feiticeiro', 'sorcerer', 'familiar'],
  ['mago', 'wizard', 'spellbook']
];
for (const [classId, key, actionKey] of classFixtures) {
  const profile = classControls.actionsFor({ sh: { classe_id: classId, nivel: 1 }, cl: { class_key: key } });
  assert.equal(profile.key, key, classId + ' must resolve to its class profile.');
  assert.ok(profile.actions.some((action) => action.key === actionKey), classId + ' must expose its level-1 signature control.');
}
assert.equal(classControls.actionsFor(null).key, '', 'An empty selection must not crash class controls.');
assert.equal(classControls.canCast('paladin', 3), false, 'Paladin must not cast before level 4.');
assert.equal(classControls.canCast('ranger', 3), false, 'Ranger must not cast before level 4.');
assert.equal(classControls.canCast('paladin', 4), true, 'Paladin spell controls unlock at level 4.');
assert.equal(classControls.canCast('ranger', 4), true, 'Ranger spell controls unlock at level 4.');
assert.equal(classControls.actionsFor({ sh: { classe_id: 'druida', nivel: 4 } }).actions.some((action) => action.key === 'wild_shape'), false, 'Druid Wild Shape must remain hidden before level 5.');
assert.equal(classControls.actionsFor({ sh: { classe_id: 'druida', nivel: 5 } }).actions.some((action) => action.key === 'wild_shape'), true, 'Druid Wild Shape must appear at level 5.');
assert.equal(classControls.actionsFor({ sh: { classe_id: 'paladino', nivel: 1 } }).actions.some((action) => action.key === 'manage_spells'), false, 'Paladin preparation controls must remain hidden at level 1.');
assert.equal(classControls.actionsFor({ sh: { classe_id: 'ranger', nivel: 1 } }).actions.some((action) => action.key === 'manage_spells'), false, 'Ranger preparation controls must remain hidden at level 1.');

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

const activePageSource = htmlFiles.map((file) => readFileSync(resolve(root, file), 'utf8')).join('\n');
if (/\.rpc\s*\(\s*['"`]roll_dice['"`]/.test(activePageSource)) {
  reportFailure('An active page calls server-side roll_dice; action rolls must come from the user-clicked Dice UI.');
}

if (failures.length) {
  process.stderr.write('\nStatic validation failed: ' + failures.length + ' issue(s).\n');
  process.exit(1);
}

process.stdout.write('Static validation passed. Checked ' + checkedInlineScripts + ' inline/shared JavaScript block(s) across ' + htmlFiles.length + ' active pages. Manual Dice click invariant verified.\n');
