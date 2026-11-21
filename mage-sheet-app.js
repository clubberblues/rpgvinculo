/* D&D 3.5 — fluxo independente de criação e ficha do Mago.
 * A ficha original é a interface; RPC v2 grava a criação em uma única transação.
 */
(function () {
  'use strict';
  const URL = 'https://grrgwxcagvvafdmzsmro.supabase.co';
  const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdycmd3eGNhZ3Z2YWZkbXpzbXJvIiwicm9sZyI6ImFub24iLCJpYXQiOjE3OTAyNTY4MTQsImV4cCI6MjEwNTgzMjgxNH0.hqLiYynGXHwyUtqcbGTTa2orSStm7ko2C5R03QNmqtQ';
  const params = new URLSearchParams(location.search);
  const characterId = params.get('char');
  const isCreate = params.get('mode') === 'criar';
  const raceId = params.get('raca');
  const classId = params.get('classe');
  const core = window.DND35MageSheetCore;
  const schools = [
    ['abjuration','Abjuração'],['conjuration','Conjuração'],['divination','Adivinhação'],
    ['enchantment','Encantamento'],['evocation','Evocação'],['illusion','Ilusão'],
    ['necromancy','Necromancia'],['transmutation','Transmutação']
  ];
  const steps = [
    { title: 'Identidade', section: null, selector: '.header-top .input-group input', help: 'Informe o nome do personagem e confira os dados de identificação.' },
    { title: 'Atributos', section: 'Atributos', selector: '.attr-row input', help: 'Informe os seis valores-base. Os ajustes raciais e modificadores serão aplicados ao criar.' },
    { title: 'Resistências', section: 'Resistências', selector: '.resist-row input', help: 'Confira os valores calculados para o Mago de 1º nível.' },
    { title: 'Perícias', section: 'Perícias', selector: 'table input', help: 'Informe as graduações na coluna Grad. O banco valida o orçamento da classe.' },
    { title: 'Talentos', section: 'Talentos', selector: 'input', help: 'Escolha o talento geral permitido para a raça; humanos escolhem dois.' },
    { title: 'Grimório', section: 'Grimório', selector: '.spell-level-block input', help: 'Todos os truques permitidos entram automaticamente. Escolha as magias iniciais de 1º círculo.' },
    { title: 'Equipamentos', section: 'Equipamentos', selector: 'input', help: 'Registre livremente os equipamentos e seus pesos.' },
    { title: 'Idiomas', section: 'Idiomas', selector: 'textarea', help: 'Edite a lista livre de idiomas conhecidos.' }
  ];
  let sb, user, step = 0, raceData = null, classData = null, skillCatalog = [], featCatalog = [], spellCatalog = [];
  const normalize = value => String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
  const clean = node => (node && node.textContent || '').replace(/\s+/g, ' ').trim();

  function status(message, error) {
    const node = document.getElementById('mage-sheet-status');
    if (node) { node.textContent = message; node.dataset.error = error ? 'true' : 'false'; }
  }
  function group(label) {
    const target = normalize(label);
    return Array.from(document.querySelectorAll('.ficha .input-group'))
      .find(g => normalize(clean(g.querySelector('label'))) === target) || null;
  }
  function groupValue(label) {
    const g = group(label);
    const input = g && g.querySelector('input,textarea,select');
    return input ? String(input.value || '').trim() : '';
  }
  function setGroupValue(label, value) {
    const g = group(label);
    const input = g && g.querySelector('input,textarea,select');
    if (input && value !== undefined && value !== null) input.value = String(value);
  }
  function panel(title) {
    const target = normalize(title);
    return Array.from(document.querySelectorAll('.ficha .panel'))
      .find(p => normalize(clean(p.querySelector('.panel-title'))).includes(target)) || null;
  }
  function textareaInPanel(title) {
    const p = panel(title);
    return p && p.querySelector('textarea');
  }
  function addToolbar() {
    const bar = document.createElement('section');
    bar.id = 'mage-sheet-toolbar';
    bar.innerHTML = '<div class="mage-sheet-meta"><strong>FICHA DO MAGO · D&D 3.5</strong><span id="mage-sheet-status" role="status" aria-live="polite">Preparando ficha…</span></div><div class="mage-sheet-actions"><button type="button" id="mage-prev">Anterior</button><button type="button" id="mage-next">Próxima etapa</button><button type="button" id="mage-save">' + (isCreate ? 'Criar Mago' : 'Salvar ficha') + '</button></div>';
    const style = document.createElement('style');
    style.textContent = '#mage-sheet-toolbar{position:sticky;top:0;z-index:10001;display:flex;gap:14px;align-items:center;justify-content:space-between;flex-wrap:wrap;padding:10px 16px;margin:-20px -20px 18px;background:#1a120b;color:#f5e8c8;border-bottom:2px solid #b08d57;font:13px Georgia,serif}#mage-sheet-toolbar .mage-sheet-meta{display:flex;flex-direction:column;gap:3px}#mage-sheet-status{color:#d8c69f}#mage-sheet-status[data-error=true]{color:#ff9b8f}#mage-sheet-toolbar .mage-sheet-actions{display:flex;gap:8px;flex-wrap:wrap}#mage-sheet-toolbar button{padding:8px 13px;border:1px solid #b08d57;background:#332416;color:#f5e8c8;border-radius:4px;cursor:pointer;font-weight:700}#mage-sheet-toolbar button:disabled{opacity:.45;cursor:not-allowed}.mage-step-focus{outline:3px solid #1687d9!important;outline-offset:4px;box-shadow:0 0 0 6px #1687d955!important;position:relative;z-index:2}.mage-step-note{position:fixed;right:18px;bottom:18px;z-index:10002;max-width:340px;padding:14px 16px;background:#1a120b;color:#f5e8c8;border:1px solid #b08d57;border-radius:6px;box-shadow:0 8px 30px #0009;font:15px Georgia,serif}.mage-choice-panel{margin:12px 0 16px;padding:10px 12px;border:1px solid rgba(139,111,71,.65);background:rgba(255,255,255,.28);font:13px Georgia,serif;color:#2b1a0e}.mage-choice-panel label{font-family:Cinzel,serif;font-size:9px;font-weight:700;display:block;margin-bottom:4px}.mage-choice-panel select{width:100%;padding:6px;background:rgba(255,255,255,.65);border:1px solid #8b6f47;color:#2b1a0e}.mage-school-choices{display:flex;gap:8px 14px;flex-wrap:wrap;margin-top:8px}.mage-school-choices label{display:flex;align-items:center;gap:5px;font-family:Georgia,serif;font-size:12px;font-weight:400}.mage-school-choices input{accent-color:#8b6f47}.mage-choice-help{font-size:11px;margin-top:6px;color:#5a3f28}';
    document.head.appendChild(style);
    document.body.insertBefore(bar, document.body.firstChild);
    document.getElementById('mage-prev').addEventListener('click', () => showStep(step - 1));
    document.getElementById('mage-save').addEventListener('click', save);
  }
  function labeledInput(panelTitle, labelText) {
    const p = panel(panelTitle);
    if (!p) return null;
    const target = normalize(labelText);
    const label = Array.from(p.querySelectorAll('label')).find(el => normalize(clean(el)) === target);
    return label && label.parentElement ? label.parentElement.querySelector('input,textarea,select') : null;
  }
  function schoolLabel(key) {
    const found = schools.find(s => s[0] === key);
    return found ? found[1] : key;
  }
  function specializationKey(value) {
    const raw = normalize(value);
    if (raw === 'universalista') return 'universalista';
    const found = schools.find(s => s[0] === raw || normalize(s[1]) === raw);
    return found ? found[0] : '';
  }
  function setupWizardChoiceFields(identity) {
    const specialization = labeledInput('Magia','Especialização em Escola');
    const prohibited = labeledInput('Magia','Escolas Proibidas');
    if (!specialization || !prohibited) throw new Error('Os campos de especialização do Mago não foram encontrados na ficha original.');
    const specList = ensureDatalist('mage-specialization-options', [{nome:'Universalista'}, ...schools.map(s => ({nome:s[1]}))]);
    const schoolList = ensureDatalist('mage-prohibited-school-options', schools.map(s => ({nome:s[1]})));
    specialization.setAttribute('list',specList);
    prohibited.setAttribute('list',schoolList);
    if (identity && identity.wizard_specialization) specialization.value = schoolLabel(identity.wizard_specialization);
    if (identity && Array.isArray(identity.wizard_prohibited_schools)) {
      prohibited.value = identity.wizard_prohibited_schools.map(schoolLabel).join(', ');
    }
    specialization.addEventListener('input',renderSpellInputs);
    prohibited.addEventListener('input',renderSpellInputs);
    if (!isCreate) {
      specialization.readOnly = true;
      prohibited.readOnly = true;
    }
  }
  function wizardChoices() {
    const specializationInput = labeledInput('Magia','Especialização em Escola');
    const prohibitedInput = labeledInput('Magia','Escolas Proibidas');
    const specialization = specializationKey(specializationInput && specializationInput.value);
    if (!specialization) throw new Error('Preencha Especialização em Escola com Universalista ou uma escola válida.');
    const raw = String(prohibitedInput && prohibitedInput.value || '')
      .split(/[,;]+|\s+e\s+/i).map(x => x.trim()).filter(Boolean);
    const prohibited = raw.map(schoolKey);
    if (prohibited.some(key => !schools.some(s => s[0] === key))) throw new Error('Há uma escola proibida que não corresponde ao catálogo.');
    const required = specialization === 'universalista' ? 0 : specialization === 'divination' ? 1 : 2;
    if (prohibited.length !== required) throw new Error('A especialização selecionada exige exatamente ' + required + ' escola(s) proibida(s).');
    if (new Set(prohibited).size !== prohibited.length || prohibited.includes(specialization)) {
      throw new Error('Não repita a escola proibida nem escolha a própria escola de especialização.');
    }
    return { wizard_specialization: specialization, wizard_prohibited_schools: prohibited };
  }
  function schoolKey(value) {
    const raw = normalize(value);
    const first = raw.split(' ')[0];
    const found = schools.find(s => normalize(s[1]) === raw || s[0] === raw || s[0] === first);
    return found ? found[0] : raw;
  }
  function selectedProhibitedSchools() {
    const input = labeledInput('Magia','Escolas Proibidas');
    return String(input && input.value || '').split(/[,;]+|\s+e\s+/i).map(x => x.trim()).filter(Boolean).map(schoolKey);
  }
  function allowedSpells(circle) {
    const prohibited = selectedProhibitedSchools();
    return spellCatalog.filter(sp => Number(sp.circulo) === circle &&
      !prohibited.includes(schoolKey(sp.escola)));
  }
  function ensureDatalist(id, items) {
    let list = document.getElementById(id);
    if (!list) { list = document.createElement('datalist'); list.id = id; document.body.appendChild(list); }
    list.replaceChildren();
    items.forEach(item => {
      const option = document.createElement('option');
      option.value = item.nome_pt || item.nome;
      list.appendChild(option);
    });
    return id;
  }
  function renderSpellInputs() {
    if (!spellCatalog.length) return;
    let circle0;
    const blocks = Array.from(document.querySelectorAll('.ficha .spell-level-block'));
    blocks.forEach(block => {
      const title = clean(block.querySelector('.spell-level-title'));
      const circle = parseInt(title, 10);
      const list = block.querySelector('.spell-list');
      if (!list || Number.isNaN(circle)) return;
      const rows = Array.from(list.querySelectorAll('.spell-row'));
      if (circle === 0) {
        circle0 = block;
        const spells = allowedSpells(0);
        while (list.querySelectorAll('.spell-row').length < spells.length) {
          const clone = rows[0].cloneNode(true);
          list.appendChild(clone);
        }
        const allRows = Array.from(list.querySelectorAll('.spell-row'));
        allRows.forEach((row, index) => {
          const input = row.querySelector('input[type="text"]');
          const check = row.querySelector('input[type="checkbox"]');
          if (input) {
            input.value = spells[index] ? (spells[index].nome_pt || spells[index].nome) : '';
            input.readOnly = isCreate;
            input.disabled = !spells[index];
          }
          if (check) { if (isCreate) check.checked = false; check.disabled = isCreate; }
          row.hidden = !spells[index];
        });
      } else if (circle === 1) {
        const allowed = allowedSpells(1);
        const datalistId = ensureDatalist('mage-spell-list-level-1', allowed);
        list.querySelectorAll('input[type="text"]').forEach(input => { input.setAttribute('list', datalistId); input.readOnly = false; });
        const headerInputs = Array.from(block.querySelectorAll('.spell-header input'));
        if (headerInputs[1]) headerInputs[1].value = '';
        if (headerInputs[2]) headerInputs[2].value = '';
      } else if (isCreate) {
        block.querySelectorAll('input').forEach(input => { input.disabled = true; });
        block.style.opacity = '.48';
        block.title = 'Círculo ainda não acessível ao Mago de 1º nível.';
      } else {
        const allowed = allowedSpells(circle);
        const datalistId = ensureDatalist('mage-spell-list-level-' + circle, allowed);
        list.querySelectorAll('input[type="text"]').forEach(input => { input.setAttribute('list', datalistId); });
        block.style.opacity = '1';
        block.removeAttribute('title');
      }
    });
    if (circle0) {
      const headerInputs = Array.from(circle0.querySelectorAll('.spell-header input'));
      if (headerInputs[1]) headerInputs[1].value = String(allowedSpells(0).length);
      if (headerInputs[2]) headerInputs[2].value = '10 + modificador de Inteligência';
    }
  }
  function choosePreferredSpell(matches) {
    return matches.slice().sort((a,b) =>
      Number(b.source_status === 'verified_srd') - Number(a.source_status === 'verified_srd') ||
      Number(Boolean(b.nivel)) - Number(Boolean(a.nivel)) ||
      String(a.id).localeCompare(String(b.id))
    )[0];
  }
  function spellIdFromName(name, circle) {
    const key = normalize(name);
    const matches = spellCatalog.filter(sp => Number(sp.circulo) === circle &&
      [sp.nome_pt,sp.nome].some(label => normalize(label) === key));
    if (!matches.length) throw new Error('A magia "' + name + '" não foi encontrada no catálogo de magias do Mago para o círculo ' + circle + '.');
    return choosePreferredSpell(matches).id;
  }
  function collectFirstCircleSpells() {
    const block = Array.from(document.querySelectorAll('.ficha .spell-level-block'))
      .find(b => parseInt(clean(b.querySelector('.spell-level-title')),10) === 1);
    if (!block) throw new Error('O bloco de magias de 1º círculo não foi encontrado na ficha.');
    const names = Array.from(block.querySelectorAll('.spell-row input[type="text"]'))
      .map(input => String(input.value || '').trim()).filter(Boolean);
    const ids = names.map(name => spellIdFromName(name,1));
    if (new Set(ids).size !== ids.length) throw new Error('Não repita a mesma magia na seleção inicial de 1º círculo.');
    return ids;
  }
  function getBaseAttributes() {
    const p = panel('Atributos');
    if (!p) throw new Error('Painel de atributos não encontrado.');
    const result = {};
    p.querySelectorAll('.attr-row').forEach(row => {
      const name = clean(row.querySelector('.attr-name'));
      if (!name) return;
      const first = row.querySelector('.attr-col input');
      const value = Number(first && first.value);
      if (!Number.isInteger(value) || value < 8 || value > 18) throw new Error('Informe um valor-base entre 8 e 18 para ' + name + '.');
      result[name] = value;
    });
    if (Object.keys(result).length !== 6) throw new Error('Informe os seis atributos: FOR, DES, CON, INT, SAB e CAR.');
    return result;
  }
  function skillIdMap() {
    const map = new Map();
    skillCatalog.forEach(skill => {
      const key = normalize(skill.nome);
      if (!map.has(key) || (map.get(key).id.includes('srd35') && !skill.id.includes('srd35'))) map.set(key,skill);
    });
    return map;
  }
  function collectSkills() {
    const p = panel('Perícias');
    if (!p) throw new Error('Painel de perícias não encontrado.');
    const map = skillIdMap();
    const aliases = {
      'blefar':'blefe',
      'furtividade':'mover-se silenciosamente',
      'identificar magias':'identificar magia',
      'oficios':'oficio'
    };
    const skills = {};
    p.querySelectorAll('tbody tr').forEach(row => {
      const cells = Array.from(row.children);
      const name = clean(cells[0]).replace(/\s*\*\s*$/,'').trim();
      const input = cells[4] && cells[4].querySelector('input');
      const ranks = Number(input && input.value || 0);
      if (!name || !Number.isFinite(ranks) || ranks <= 0) return;
      const lookup = aliases[normalize(name)] || name;
      const skill = map.get(normalize(lookup));
      if (!skill) throw new Error('A perícia "' + name + '" não possui correspondência no catálogo SRD. Não vou descartar essa graduação.');
      skills[skill.id] = ranks;
    });
    return skills;
  }
  function featMap() {
    const map = new Map();
    featCatalog.forEach(feat => {
      [feat.nome_pt,feat.nome].filter(Boolean).forEach(name => {
        const key = normalize(name);
        if (!map.has(key)) map.set(key,feat);
      });
    });
    return map;
  }
  function collectFeats() {
    const p = panel('Talentos');
    if (!p) throw new Error('Painel de talentos não encontrado.');
    const inputs = Array.from(p.querySelectorAll('input[type="text"]'));
    const map = featMap();
    const selected = [];
    for (let i=0;i<inputs.length;i+=2) {
      const name = String(inputs[i].value || '').trim();
      if (!name) continue;
      const feat = map.get(normalize(name));
      if (!feat) throw new Error('O talento "' + name + '" não foi encontrado no catálogo SRD. Use o nome exibido nas sugestões.');
      const entry = { id: feat.id };
      if (feat.exige_parametro) {
        const parameter = window.prompt('O talento "' + (feat.nome_pt || feat.nome) + '" exige uma escolha. Informe o parâmetro:');
        if (!parameter || !parameter.trim()) throw new Error('Informe o parâmetro exigido pelo talento ' + (feat.nome_pt || feat.nome) + '.');
        entry.parametro = parameter.trim();
      }
      selected.push(entry);
    }
    const expected = raceId === 'humano' ? 2 : 1;
    if (selected.length !== expected) throw new Error('A raça escolhida exige ' + expected + ' talento(s) na criação. Você informou ' + selected.length + '.');
    return selected;
  }
  function splitLanguages() {
    const input = textareaInPanel('Idiomas');
    return String(input && input.value || '').split(/[\n,;]+/).map(x => x.trim()).filter(Boolean);
  }
  function collectEquipment() {
    const p = panel('Equipamentos');
    if (!p) return [];
    return Array.from(p.querySelectorAll('div[style*="grid-template-columns: 2fr 1fr 30px 30px"]'))
      .map(row => Array.from(row.querySelectorAll('input')))
      .filter(inputs => inputs.length === 4 && String(inputs[0].value || '').trim())
      .map(inputs => ({
        nome: String(inputs[0].value || '').trim(),
        localizacao: String(inputs[1].value || '').trim(),
        pagina: String(inputs[2].value || '').trim(),
        peso: String(inputs[3].value || '').trim()
      }));
  }
  function applyRacePresentation(race, profile) {
    setGroupValue('Classe','Mago');
    setGroupValue('Raça',race.nome);
    setGroupValue('Tamanho',race.tamanho || '');
    setGroupValue('Jogador',profile && profile.username || user.email?.split('@')[0] || '');
    setGroupValue('XP','0');
    setGroupValue('Nível','1');
    const traits = textareaInPanel('Traços Raciais');
    if (traits) traits.value = Array.isArray(race.habilidades_raciais) ? race.habilidades_raciais.join('\n') : '';
    const languageLine = (race.habilidades_raciais || []).find(x => /idiomas? autom[aá]ticos?:/i.test(x));
    const languageMatch = languageLine && languageLine.match(/idiomas? autom[aá]ticos?:\s*([^.]*)/i);
    const languages = textareaInPanel('Idiomas');
    if (languages && languageMatch && !languages.value.trim()) languages.value = languageMatch[1].replace(/\s+e\s+/i, ', ');
  }
  function sizeModifier(size) {
    return ({'miudo':2,'pequeno':1,'medio':0,'grande':-1,'enorme':-2,'imenso':-4,'colossal':-8})[normalize(size)] ?? 0;
  }
  function populateSkillTotals(final, modifiers, race) {
    const p = panel('Perícias');
    if (!p) return;
    const map = skillIdMap();
    const aliases = {'blefar':'blefe','furtividade':'mover-se silenciosamente','identificar magias':'identificar magia','oficios':'oficio'};
    p.querySelectorAll('tbody tr').forEach(row => {
      const cells = Array.from(row.children);
      const label = clean(cells[0]).replace(/\s*\*\s*$/,'').trim();
      const skill = map.get(normalize(aliases[normalize(label)] || label));
      if (!skill) return;
      const ability = skill.atributo || clean(cells[1]);
      const mod = Number(modifiers[ability] || 0);
      const ranks = Number(cells[4]?.querySelector('input')?.value || 0);
      const racial = race.id === 'elfo' && ['ouvir','procurar','observar'].includes(skill.id) ? 2 : 0;
      const total = cells[2]?.querySelector('input');
      const abilityInput = cells[3]?.querySelector('input');
      const misc = cells[5]?.querySelector('input');
      if (total) total.value = String(mod + ranks + racial);
      if (abilityInput) abilityInput.value = String(mod);
      if (misc) misc.value = String(racial);
    });
  }
  function applyCalculatedFields(base, race, selectedSpells) {
    const adjustments = race.ajustes_atributos || {};
    const final = {};
    Object.keys(base).forEach(key => { final[key] = Number(base[key]) + Number(adjustments[key] || 0); });
    const modifiers = {};
    Object.keys(final).forEach(key => { modifiers[key] = Math.floor((final[key] - 10) / 2); });
    const attrPanel = panel('Atributos');
    attrPanel.querySelectorAll('.attr-row').forEach(row => {
      const stat = clean(row.querySelector('.attr-name'));
      if (!stat || !(stat in final)) return;
      const cols = row.querySelectorAll('.attr-col');
      const value = cols[0]?.querySelector('input');
      const mod = cols[1]?.querySelector('input');
      if (value) value.value = String(final[stat]);
      if (mod) mod.value = String(modifiers[stat]);
    });
    const conMod = modifiers.CON, dexMod = modifiers.DES, wisMod = modifiers.SAB;
    const intMod = modifiers.INT;
    const hp = Math.max(1,4+conMod);
    const hpPanel = panel('Pontos de Vida');
    if (hpPanel) {
      const inputs = hpPanel.querySelectorAll('input');
      if (inputs[0]) inputs[0].value = String(hp);
      if (inputs[1]) inputs[1].value = '1d4';
      if (inputs[2]) inputs[2].value = '0';
    }
    const saves = panel('Resistências');
    if (saves) {
      saves.querySelectorAll('.resist-row').forEach(row => {
        const label = normalize(clean(row.querySelector('.resist-name')));
        if (!label) return;
        const mod = label === 'fortitude' ? conMod : label === 'reflexos' ? dexMod : wisMod;
        const baseSave = label === 'vontade' ? 2 : 0;
        const inputs = row.querySelectorAll('input');
        if (inputs[0]) inputs[0].value = String(baseSave + mod);
        if (inputs[1]) inputs[1].value = String(baseSave);
        if (inputs[2]) inputs[2].value = String(mod);
      });
    }
    const sizeMod = sizeModifier(race.tamanho);
    const basePanel = panel('Base e Agarrar');
    if (basePanel) {
      const inputs = basePanel.querySelectorAll('input');
      if (inputs[0]) inputs[0].value = '0';
      if (inputs[2]) inputs[2].value = String(modifiers.FOR + sizeMod);
      if (inputs[3]) inputs[3].value = '0';
      if (inputs[4]) inputs[4].value = String(modifiers.FOR);
      if (inputs[5]) inputs[5].value = String(sizeMod);
      if (inputs[6]) inputs[6].value = '0';
    }
    const initPanel = panel('Iniciativa');
    if (initPanel) {
      const inputs = initPanel.querySelectorAll('input');
      if (inputs[0]) inputs[0].value = String(dexMod);
      if (inputs[1]) inputs[1].value = String(dexMod);
    }
    const caPanel = panel('Armadura (CA)');
    if (caPanel) {
      const inputs = caPanel.querySelectorAll('input');
      const baseCa = 10 + dexMod + sizeMod;
      if (inputs[0]) inputs[0].value = String(baseCa);
      if (inputs[1]) inputs[1].value = '10';
      if (inputs[2]) inputs[2].value = '0';
      if (inputs[3]) inputs[3].value = '0';
      if (inputs[4]) inputs[4].value = String(dexMod);
      if (inputs[5]) inputs[5].value = String(sizeMod);
      if (inputs[6]) inputs[6].value = '0';
      if (inputs[7]) inputs[7].value = '0';
      if (inputs[8]) inputs[8].value = '0';
      if (inputs[9]) inputs[9].value = String(baseCa);
      if (inputs[10]) inputs[10].value = String(10 + sizeMod);
    }
    const magic = panel('Magia');
    if (magic) {
      const tr = labeledInput('Magia','TR de Magia');
      const dcMod = labeledInput('Magia','Mod. CD');
      const failure = labeledInput('Magia','Falha Arcana');
      if (tr) tr.value = String(10 + intMod);
      if (dcMod) dcMod.value = String(intMod);
      if (failure) failure.value = '0%';
      const rows = magic.querySelectorAll('table tbody tr');
      const knownCells = rows[0] ? rows[0].querySelectorAll('td') : [];
      for (let circle=0;circle<=9;circle++) {
        const input = knownCells[circle+1]?.querySelector('input');
        if (input) input.value = circle === 0 ? String(allowedSpells(0).length) : circle === 1 ? String(selectedSpells.length) : '0';
      }
    }
    populateSkillTotals(final,modifiers,race);
    const spellBlocks = Array.from(document.querySelectorAll('.ficha .spell-level-block'));
    spellBlocks.forEach(block => {
      const circle = parseInt(clean(block.querySelector('.spell-level-title')),10);
      const headers = Array.from(block.querySelectorAll('.spell-header input'));
      if (headers[1]) headers[1].value = circle === 0 ? String(allowedSpells(0).length) : circle === 1 ? String(selectedSpells.length) : '';
      if (headers[2]) headers[2].value = String(10 + intMod + circle);
    });
    return { final, modifiers, hp };
  }
  function updateFeatSuggestions() {
    const p = panel('Talentos');
    if (!p || !featCatalog.length) return;
    const id = ensureDatalist('mage-feat-catalog', featCatalog.map(f => ({nome:f.nome_pt || f.nome})));
    const inputs = Array.from(p.querySelectorAll('input[type="text"]'));
    for (let i=0;i<inputs.length;i+=2) inputs[i].setAttribute('list',id);
  }
  function updateSpellSuggestions() {
    if (!spellCatalog.length) return;
    const allowed = spellCatalog.filter(s => Number(s.circulo) === 1);
    const id = ensureDatalist('mage-spell-list-level-1', allowed.map(s => ({nome:s.nome_pt || s.nome})));
    const block = Array.from(document.querySelectorAll('.ficha .spell-level-block')).find(b => parseInt(clean(b.querySelector('.spell-level-title')),10) === 1);
    if (block) block.querySelectorAll('.spell-row input[type="text"]').forEach(input => input.setAttribute('list',id));
  }
  async function loadCatalogs() {
    const results = await Promise.all([
      sb.from('srd_skills').select('id,nome,atributo,treinada_apenas'),
      sb.from('srd_feats').select('id,nome,nome_pt,exige_parametro,requisitos'),
      sb.from('srd_spells').select('id,nome,nome_pt,circulo,nivel,escola,classes,source_status').contains('classes',['wizard'])
    ]);
    for (const result of results) if (result.error) throw result.error;
    skillCatalog = results[0].data || [];
    featCatalog = results[1].data || [];
    spellCatalog = results[2].data || [];
    updateFeatSuggestions();
    updateSpellSuggestions();
  }
  function showStep(next) {
    step = Math.max(0, Math.min(steps.length - 1, next));
    document.querySelectorAll('.mage-step-focus').forEach(el => el.classList.remove('mage-step-focus'));
    const config = steps[step];
    let target = null;
    if (!config.section) target = document.querySelector(config.selector);
    else {
      const p = panel(config.section);
      target = (p && p.querySelector(config.selector)) || (config.section === 'Grimório' ? document.querySelector(config.selector) : null);
    }
    if (target) {
      target.classList.add('mage-step-focus');
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
      if (target.matches('input,textarea,select')) target.focus({ preventScroll: true });
    }
    let note = document.getElementById('mage-step-note');
    if (!note) { note = document.createElement('aside'); note.id = 'mage-step-note'; note.className = 'mage-step-note'; document.body.appendChild(note); }
    note.textContent = (step + 1) + '/' + steps.length + ' · ' + config.title + ': ' + config.help;
    document.getElementById('mage-prev').disabled = step === 0;
    const nextButton = document.getElementById('mage-next');
    nextButton.textContent = step === steps.length - 1 ? 'Concluir orientação' : 'Próxima etapa';
    nextButton.onclick = step === steps.length - 1
      ? () => { note.remove(); document.querySelectorAll('.mage-step-focus').forEach(el => el.classList.remove('mage-step-focus')); status('Orientação concluída. Revise a ficha e clique em ' + (isCreate ? 'Criar Mago' : 'Salvar ficha') + '.'); }
      : () => showStep(step + 1);
  }
  async function loadCharacter() {
    const result = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
    if (result.error) throw result.error;
    if (!result.data) throw new Error('Ficha não encontrada ou sem permissão de leitura.');
    const identity = result.data.identidade && typeof result.data.identidade === 'object' ? result.data.identidade : {};
    core.hydrate(identity.ficha_mago_v2 || identity.ficha_original_v1);
    status('Ficha carregada. Edite os campos e salve quando terminar.');
  }
  async function createCharacter() {
    const button = document.getElementById('mage-save');
    button.disabled = true;
    try {
      const name = groupValue('Nome do Personagem');
      if (!name || name.length < 2 || name.length > 40) throw new Error('Informe o nome do personagem (2 a 40 caracteres).');
      const baseAttributes = getBaseAttributes();
      const choices = wizardChoices();
      const selectedSpells = collectFirstCircleSpells();
      const finalInt = Number(baseAttributes.INT) + Number((raceData.ajustes_atributos || {}).INT || 0);
      const expectedSpells = Math.max(3,3+Math.floor((finalInt-10)/2));
      if (selectedSpells.length !== expectedSpells) throw new Error('Com Inteligência final ' + finalInt + ', escolha exatamente ' + expectedSpells + ' magias de 1º círculo. Você informou ' + selectedSpells.length + '.');
      const skills = collectSkills();
      const feats = collectFeats();
      const languages = splitLanguages();
      const equipment = collectEquipment();
      applyCalculatedFields(baseAttributes,raceData,selectedSpells);
      const identity = {
        tendencia: groupValue('Tendência'),
        tamanho: groupValue('Tamanho'),
        idade: groupValue('Idade'),
        sexo: groupValue('Sexo'),
        altura_cm: groupValue('Altura'),
        peso_kg: groupValue('Peso'),
        divindade: groupValue('Divindade'),
        atributos_base: baseAttributes,
        deslocamento_base: raceData.deslocamento,
        ...choices
      };
      const firstCircleBlock = Array.from(document.querySelectorAll('.ficha .spell-level-block')).find(b => parseInt(clean(b.querySelector('.spell-level-title')),10) === 1);
      const firstCircleHeader = firstCircleBlock && firstCircleBlock.querySelectorAll('.spell-header input');
      if (firstCircleHeader && firstCircleHeader[1]) firstCircleHeader[1].value = String(selectedSpells.length);
      const snapshot = core.collect();
      status('Validando e gravando o Mago no banco em uma única transação…');
      const result = await sb.rpc('criar_mago_ficha_original_v2', {
        p_nome: name,
        p_raca_id: raceId,
        p_atributos_base: baseAttributes,
        p_pericias: skills,
        p_talentos: feats,
        p_identidade: identity,
        p_magias_primeiro_circulo: selectedSpells,
        p_idiomas: languages,
        p_equipamentos: equipment,
        p_ficha: snapshot
      });
      if (result.error) throw result.error;
      const newId = result.data;
      if (!newId) throw new Error('O banco não retornou o identificador do personagem.');
      const draftKey = 'dnd35-mage-draft:' + user.id + ':' + raceId;
      localStorage.removeItem(draftKey);
      const nextUrl = new URL('ficha-original.html', location.href);
      nextUrl.searchParams.set('char', String(newId));
      location.replace(nextUrl.toString());
    } catch (error) {
      status('Não foi possível criar o Mago: ' + (error.message || error), true);
      button.disabled = false;
    }
  }
  async function saveExisting() {
    const button = document.getElementById('mage-save');
    button.disabled = true;
    try {
      const current = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
      if (current.error) throw current.error;
      if (!current.data) throw new Error('Ficha não encontrada ou sem permissão.');
      const identity = current.data.identidade && typeof current.data.identidade === 'object' ? current.data.identidade : {};
      identity.ficha_mago_v2 = core.collect();
      const result = await sb.from('srd_character_sheets').update({ identidade }).eq('character_id', characterId).select('character_id').maybeSingle();
      if (result.error) throw result.error;
      if (!result.data) throw new Error('O banco não confirmou a gravação.');
      status('Ficha salva. ' + Object.keys(identity.ficha_mago_v2.fields).length + ' campos registrados.');
    } catch (error) { status('Falha ao salvar: ' + (error.message || error), true); }
    finally { button.disabled = false; }
  }
  function save() {
    if (isCreate) return createCharacter();
    return saveExisting();
  }
  async function init() {
    if (!window.supabase || !core) throw new Error('Dependências da ficha não foram carregadas.');
    sb = window.supabase.createClient(URL, KEY);
    const auth = await sb.auth.getUser();
    if (auth.error || !auth.data.user) { location.replace('index.html'); return; }
    user = auth.data.user;
    addToolbar();
    if (isCreate) {
      if (!raceId || !classId) throw new Error('A criação precisa receber raça e classe escolhidas no Lobby.');
      const [race, klass, profile] = await Promise.all([
        sb.from('srd_races').select('*').eq('id', raceId).maybeSingle(),
        sb.from('srd_classes').select('id,nome,class_key').eq('id', classId).maybeSingle(),
        sb.from('profiles').select('username').eq('id', user.id).maybeSingle()
      ]);
      if (race.error || klass.error) throw race.error || klass.error;
      if (!race.data || !klass.data || klass.data.class_key !== 'wizard') throw new Error('A ficha original nova está habilitada exclusivamente para a classe Mago.');
      raceData = race.data;
      classData = klass.data;
      await loadCatalogs();
      core.applyIdentity({ raceName: raceData.nome, playerName: profile.data?.username || user.email?.split('@')[0] || '' });
      applyRacePresentation(raceData,profile.data);
      setupWizardChoiceFields(null);
      renderSpellInputs();
      status('Ficha original pronta. Preencha os campos; ao criar, personagem e ficha serão gravados juntos no banco.');
    } else if (characterId) {
      const result = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
      if (result.error) throw result.error;
      if (!result.data) throw new Error('Ficha não encontrada ou sem permissão de leitura.');
      const identity = result.data.identidade && typeof result.data.identidade === 'object' ? result.data.identidade : {};
      await loadCatalogs();
      setupWizardChoiceFields(identity);
      renderSpellInputs();
      core.hydrate(identity.ficha_mago_v2 || identity.ficha_original_v1);
      status('Ficha carregada. Edite os campos e salve quando terminar.');
    } else {
      throw new Error('Abra a ficha a partir do Lobby ou da Mesa.');
    }
    showStep(0);
  }
  document.addEventListener('DOMContentLoaded', () => init().catch(error => status(error.message || String(error), true)));
})();
