/* D&D 3.5 — fluxo independente de criação e ficha do Mago.
 * A ficha original é a interface; RPC v2 grava a criação em uma única transação.
 */
(function () {
  'use strict';
  const SUPABASE_URL = 'https://grrgwxcagvvafdmzsmro.supabase.co';
  const KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdycmd3eGNhZ3Z2YWZkbXpzbXJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyNTY4MTQsImV4cCI6MjEwNTgzMjgxNH0.hqLiYynGXHwyUtqcbGTTa2orSStm7ko2C5R03QNmqtQ';
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
  // Guia dinâmico: percorre os campos editáveis reais da ficha, sem etapas fixas.
  let sb, user, step = 0, raceData = null, classData = null, skillCatalog = [], featCatalog = [], spellCatalog = [], monsterCatalog = [], selectedFamiliar = null, catalogMode = null;
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
    bar.innerHTML = '<div class="mage-sheet-meta"><strong>FICHA DO MAGO · D&D 3.5</strong><span id="mage-sheet-status" role="status" aria-live="polite">Preparando ficha…</span></div><div class="mage-sheet-actions"><button type="button" id="mage-prev">Anterior</button><button type="button" id="mage-next">Próximo campo</button><button type="button" id="mage-save">' + (isCreate ? 'Criar Mago' : 'Salvar ficha') + '</button></div>';
    const style = document.createElement('style');
    style.textContent = '#mage-sheet-toolbar{position:relative;z-index:20;display:flex;gap:12px;align-items:center;justify-content:center;flex-wrap:wrap;padding:10px 16px;width:min(760px,calc(100% - 28px));margin:0 auto 22px;background:linear-gradient(135deg,rgba(246,237,215,.94),rgba(226,210,174,.94));color:#49351f;border:1px solid rgba(139,111,71,.48);border-radius:12px;box-shadow:0 5px 18px rgba(48,31,13,.10);font:13px Georgia,serif}#mage-sheet-toolbar .mage-sheet-meta{display:flex;flex-direction:column;gap:3px;flex:1;min-width:180px;text-align:center}#mage-sheet-status{color:#806747;font-size:12px}#mage-sheet-status[data-error=true]{color:#ff9b8f}#mage-sheet-toolbar .mage-sheet-actions{display:flex;gap:8px;flex-wrap:wrap}#mage-sheet-toolbar button{padding:7px 12px;border:1px solid rgba(139,111,71,.48);background:rgba(255,250,238,.78);color:#594126;border-radius:999px;cursor:pointer;font:600 12px Georgia,serif;transition:background .18s,transform .18s}#mage-sheet-toolbar button:hover{background:#fff8e9;transform:translateY(-1px)}#mage-sheet-toolbar #mage-save{background:#594126;color:#fff3d7;border-color:#594126}#mage-sheet-toolbar button:disabled{opacity:.45;cursor:not-allowed}.mage-class-feature-note{margin:6px 0 10px;padding:7px 10px;border-left:2px solid #b08d57;color:#6f5738;background:#f3ead7;font:12px Georgia,serif}.mage-step-focus{outline:2px solid rgba(176,141,87,.72)!important;outline-offset:3px;box-shadow:0 0 0 5px rgba(176,141,87,.12)!important;position:relative;z-index:2;border-radius:5px}.mage-step-note{position:fixed;left:50%;bottom:22px;transform:translateX(-50%);z-index:10002;width:min(440px,calc(100vw - 32px));box-sizing:border-box;padding:15px 20px 14px;background:linear-gradient(145deg,rgba(249,242,225,.97),rgba(231,216,185,.97));color:#49351f;border:1px solid rgba(139,111,71,.55);border-radius:14px;box-shadow:0 10px 34px rgba(25,16,7,.20);font:15px/1.45 Georgia,serif;text-align:center;backdrop-filter:blur(8px)}.mage-step-note strong{display:block;font:700 17px Cinzel,Georgia,serif;color:#382514;margin:2px 0 5px}.mage-step-note .mage-guide-progress{height:3px;background:rgba(139,111,71,.18);border-radius:5px;overflow:hidden;margin:9px 0 0}.mage-step-note .mage-guide-progress span{display:block;height:100%;background:#a47d45;border-radius:5px}.mage-choice-panel{margin:12px 0 16px;padding:10px 12px;border:1px solid rgba(139,111,71,.65);background:rgba(255,255,255,.28);font:13px Georgia,serif;color:#2b1a0e}.mage-choice-panel label{font-family:Cinzel,serif;font-size:9px;font-weight:700;display:block;margin-bottom:4px}.mage-choice-panel select{width:100%;padding:6px;background:rgba(255,255,255,.65);border:1px solid #8b6f47;color:#2b1a0e}.mage-school-choices{display:flex;gap:8px 14px;flex-wrap:wrap;margin-top:8px}.mage-school-choices label{display:flex;align-items:center;gap:5px;font-family:Georgia,serif;font-size:12px;font-weight:400}.mage-school-choices input{accent-color:#8b6f47}.mage-choice-help{font-size:11px;margin-top:6px;color:#5a3f28}';
    
    style.textContent += '\n' +
      '.mage-catalog-backdrop{position:fixed;inset:0;z-index:10004;display:none;align-items:center;justify-content:center;padding:24px;background:rgba(12,8,4,.72);backdrop-filter:blur(7px);-webkit-backdrop-filter:blur(7px)}' +
      '.mage-catalog-backdrop.ativo{display:flex}' +
      '.mage-catalog-shell{width:min(900px,96vw);max-height:min(86vh,900px);overflow:hidden;display:flex;flex-direction:column;background:linear-gradient(145deg,#eee1c2,#d7c093);color:#2b1a0e;border:1px solid #8b6f47;outline:4px solid rgba(26,15,8,.88);box-shadow:0 24px 70px #000c;padding:22px 26px}' +
      '.mage-catalog-head{display:flex;align-items:center;justify-content:space-between;gap:16px;border-bottom:1px solid rgba(90,63,40,.45);padding-bottom:12px;margin-bottom:12px}' +
      '.mage-catalog-head h2{font:900 22px Cinzel,serif;letter-spacing:2px;text-transform:uppercase;color:#3a2510}' +
      '.mage-catalog-close{border:1px solid #8b6f47;background:rgba(43,26,14,.08);color:#3a2510;font:700 20px Georgia;cursor:pointer;width:34px;height:34px}' +
      '.mage-catalog-tools{display:flex;gap:10px;margin-bottom:12px;flex-wrap:wrap}' +
      '.mage-catalog-tools input,.mage-catalog-tools select{min-width:0;flex:1;padding:9px 11px;border:1px solid #9b8057;background:rgba(255,255,255,.42);color:#2b1a0e;font:15px EB Garamond,serif}' +
      '.mage-catalog-list{overflow:auto;display:flex;flex-direction:column;gap:8px;padding:2px 4px 8px 0}' +
      '.mage-catalog-row{display:grid;grid-template-columns:54px minmax(0,1fr) 58px;align-items:center;gap:12px;padding:8px 10px;border:1px solid rgba(139,111,71,.65);background:rgba(255,255,255,.24);min-height:62px}' +
      '.mage-catalog-mark{width:48px;height:44px;display:flex;align-items:center;justify-content:center;border:1px solid #8b6f47;background:linear-gradient(145deg,#c4a66d,#eadcb8);color:#4b3218;font-size:19px}' +
      '.mage-catalog-name{display:block;border:0;background:transparent;color:#2b1a0e;text-align:left;font:700 17px Cinzel,serif;cursor:pointer;padding:0}' +
      '.mage-catalog-meta{display:block;margin-top:3px;color:#5a3f28;font:14px EB Garamond,serif;line-height:1.25}' +
      '.mage-catalog-view{border:0;background:transparent;color:rgba(90,63,40,.62);font:600 10px Cinzel,serif;letter-spacing:.25px;cursor:pointer;padding:3px 2px;opacity:.72}' +
      '.mage-catalog-view:hover{color:#3a2510;opacity:1;text-decoration:underline;text-underline-offset:3px}' +
      '.mage-catalog-actions{display:flex;align-items:center;justify-content:flex-end;gap:9px}' +
      '.mage-catalog-choose{border:1px solid rgba(139,111,71,.8);background:rgba(139,111,71,.12);color:#3a2510;padding:7px 9px;font:700 10px Cinzel,serif;letter-spacing:.5px;cursor:pointer;white-space:nowrap}' +
      '.mage-catalog-choose:hover{background:#8b6f47;color:#fff5df}' +
      '.mage-lore-copy{position:relative}' +
      '.mage-lore-head{display:flex;align-items:flex-start;justify-content:center;position:relative;padding:0 38px 0 0}' +
      '.mage-lore-head h2{flex:1}' +
      '.mage-lore-close{position:absolute;right:0;top:0;width:30px;height:30px;border:1px solid rgba(225,193,132,.55);background:rgba(0,0,0,.24);color:#f0e2c1;font:22px Georgia,serif;cursor:pointer;border-radius:3px}' +
      '.mage-lore-close:hover{background:rgba(225,193,132,.2);color:#fff}' +
      '.mage-ability-budget{margin:8px 0 2px;text-align:right;color:#5a3f28;font:700 10px Cinzel,serif;letter-spacing:.3px}' +
      '.attr-row{grid-template-columns:45px minmax(54px,1.45fr) repeat(3,minmax(30px,1fr));gap:4px}' +
      '.attr-col{min-width:0;width:100%}' +
      '.mage-ability-adjust{display:flex;align-items:center;justify-content:center;gap:0;width:100%;min-width:0;flex:1}' +
      '.mage-ability-adjust input{display:block;box-sizing:border-box;width:36px!important;min-width:24px!important;max-width:40px;flex:1 1 30px;padding-left:2px!important;padding-right:2px!important;text-align:center}' +
      '.mage-ability-adjust button,.mage-skill-adjust button{display:inline-flex;align-items:center;justify-content:center;width:9px;height:19px;min-width:9px;max-width:9px;padding:0;border:0;background:transparent;color:rgba(90,63,40,.62);font:700 11px Georgia,serif;line-height:18px;cursor:pointer;flex:0 0 9px}' +
      '.mage-ability-adjust button:hover,.mage-skill-adjust button:hover{color:#2b1a0e;background:rgba(139,111,71,.16)}' +
      '.mage-skill-budget{margin-left:auto;font:700 9px Cinzel,serif;letter-spacing:.2px;color:#6a4a29;white-space:nowrap}' +
      '.mage-skill-adjust{display:flex;align-items:center;justify-content:center;gap:1px;min-width:62px}' +
      '.mage-skill-adjust input{width:25px;min-width:20px;max-width:32px}' +
      '.mage-skill-adjust button{width:14px;min-width:14px;font-size:12px}' +
      '.mage-catalog-row{grid-template-columns:54px minmax(0,1fr) 132px}' +
      '.mage-spell-catalog-row{grid-template-columns:54px minmax(0,1fr) 58px}' +
      '.mage-spell-catalog-row .mage-catalog-view{border-bottom:1px solid #8b6f47;font:700 12px Cinzel,serif;letter-spacing:1px;padding:5px}' +
      '@media(max-width:650px){#mage-sheet-toolbar{width:calc(100% - 20px);padding:10px;margin:0 auto 16px;gap:8px}#mage-sheet-toolbar .mage-sheet-meta{flex-basis:100%}#mage-sheet-toolbar .mage-sheet-actions{justify-content:center}.mage-step-note{bottom:12px;padding:13px 15px;font-size:14px}.mage-step-note strong{font-size:16px}.mage-catalog-row{grid-template-columns:38px minmax(0,1fr) 112px}.mage-spell-catalog-row{grid-template-columns:38px minmax(0,1fr) 48px}.mage-catalog-choose{padding:6px 5px;font-size:9px}.mage-skill-budget{font-size:8px}}' +
      '.mage-catalog-empty{padding:28px 12px;text-align:center;color:#5a3f28;font:italic 16px EB Garamond,serif}' +
      '.mage-lore-backdrop{position:fixed;inset:0;z-index:10006;display:none;align-items:center;justify-content:center;padding:7vh 8vw;background:rgba(10,7,4,.58);backdrop-filter:blur(24px) saturate(.55);-webkit-backdrop-filter:blur(24px) saturate(.55);cursor:pointer}' +
      '.mage-lore-backdrop.ativo{display:flex}' +
      '.mage-lore-copy{width:min(780px,100%);max-height:86vh;overflow:auto;cursor:default;text-align:center;color:#f0e2c1;text-shadow:0 2px 12px #000;font:18px/1.65 EB Garamond,Georgia,serif;white-space:normal}' +
      '.mage-lore-copy h2{font:900 clamp(23px,3vw,34px)/1.2 Cinzel,serif;letter-spacing:2px;color:#e1c184;margin:0 0 22px;text-transform:uppercase}' +
      '.mage-lore-copy h3{font:700 13px Cinzel,serif;letter-spacing:1.5px;text-transform:uppercase;color:#d7b574;margin:20px 0 5px}' +
      '.mage-lore-copy p{margin:0 0 13px}' +
      ' .mage-lore-copy .mage-lore-meta{font:italic 15px EB Garamond,serif;color:#e5d2a8;margin-bottom:20px;white-space:pre-line}' +
      '.mage-catalog-trigger{cursor:pointer;transition:color .18s ease;text-decoration-color:transparent}' +
      '.mage-catalog-trigger:hover{color:#8b5e24;text-decoration:underline;text-decoration-color:#b08d57;text-underline-offset:4px}' +
      '.mage-familiar-selection{margin:6px 0 10px;padding:5px 0;border-bottom:1px dotted rgba(90,63,40,.45);font:italic 13px EB Garamond,serif;color:#6a4a29}' +
      '@media(max-width:650px){.mage-catalog-backdrop{padding:10px}.mage-catalog-shell{padding:14px;max-height:92vh}.mage-catalog-row{grid-template-columns:42px minmax(0,1fr) 44px;gap:8px;padding:7px}.mage-catalog-mark{width:38px;height:38px}.mage-catalog-name{font-size:14px}.mage-lore-backdrop{padding:5vh 6vw}.mage-lore-copy{font-size:16px}}';

    document.head.appendChild(style);
    const sheet = document.querySelector('.ficha');
    if (!sheet) throw new Error('O modelo original da ficha não foi encontrado.');
    sheet.insertBefore(bar, sheet.firstChild);
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
      !prohibited.includes(schoolKey(sp.escola)))
      .sort((a,b) => String(a.id).localeCompare(String(b.id)));
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
      const spellHeaderInputs = Array.from(block.querySelectorAll('.spell-header input'));
      if (spellHeaderInputs[0]) { if (isCreate) spellHeaderInputs[0].value = ''; spellHeaderInputs[0].disabled = true; }
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
        if (isCreate) { list.querySelectorAll('input[type="checkbox"]').forEach(el => { el.checked = false; el.disabled = true; }); }
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
    document.querySelectorAll('.spell-level-block .spell-list input[type="checkbox"]').forEach(input => {
      if (isCreate) input.checked = false;
      input.disabled = true;
    });
    const magicPanel = panel('Magia');
    const magicRows = magicPanel && magicPanel.querySelectorAll('table tbody tr');
    if (magicRows && magicRows[1]) {
      magicRows[1].querySelectorAll('input').forEach(input => {
        if (isCreate) input.value = '';
        input.disabled = true;
      });
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
      const displayedValue = Number(first && first.value);
      const value = displayedValue - Number((raceData && raceData.ajustes_atributos || {})[name] || 0);
      if (!Number.isInteger(value) || value < 8 || value > 18) throw new Error('O valor-base de ' + name + ' deve ficar entre 8 e 18.');
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
  function classSkillNames() {
    return (classData && Array.isArray(classData.pericias_classe) ? classData.pericias_classe : []).map(normalize);
  }
  function isClassSkill(name) {
    const key=normalize(name);
    return classSkillNames().some(item=>item===key||(item==='conhecimento qualquer'&&key.startsWith('conhecimento'))||(item==='oficio'&&key.startsWith('oficio'))||(item==='profissao'&&key.startsWith('profissao')));
  }
  function pointBuyCost(score) { return ({8:0,9:1,10:2,11:3,12:4,13:5,14:6,15:8,16:10,17:13,18:16})[Number(score)] ?? Infinity; }
  function pointBuyTotal(attributes) { return Object.values(attributes).reduce((sum,value)=>sum+pointBuyCost(value),0); }
  function skillPointsBudget() {
    const base=getBaseAttributes();
    const intScore=Number(base.INT)+Number((raceData&&raceData.ajustes_atributos||{}).INT||0);
    const intMod=Math.floor((intScore-10)/2);
    return Math.max(1,Number(classData&&classData.pericias_por_nivel||2)+intMod)*4+(raceData&&raceData.id==='humano'?4:0);
  }
  function skillRankCost(name) { return isClassSkill(name)?1:2; }
  function skillRankMaximum(name) { return isClassSkill(name)?4:2; }
  function racialSkillBonus(race,name) {
    const key=normalize(name);
    const bonuses={
      anao:{},
      elfo:{ouvir:2,procurar:2,observar:2},
      'meio-elfo':{ouvir:1,procurar:1,observar:1,diplomacia:2,'obter informacao':2,'obter informacoes':2},
      halfling:{escalar:2,saltar:2,ouvir:2,'mover se silenciosamente':2},
      gnomo:{ouvir:2}
    };
    return (bonuses[race&&race.id]||{})[key]||0;
  }
  function conditionalRacialSkillNote(race,name) {
    const key=normalize(name);
    if(race&&race.id==='anao'&&key==='procurar')return '+2 racial em Procurar para notar construções incomuns de pedra, armadilhas de pedra e detalhes subterrâneos.';
    if(race&&race.id==='anao'&&['avaliacao','oficio'].includes(key))return '+2 racial em Avaliação/Ofício somente em testes relacionados a pedra ou metal; some ao teste quando pertinente.';
    if(race&&race.id==='gnomo'&&key==='oficio')return '+2 racial em Ofício (alquimia); some ao teste quando a especialização for alquimia.';
    return '';
  }
  function skillAllocationStats() {
    const p=panel('Perícias'); let spent=0;
    if(p)p.querySelectorAll('tbody tr').forEach(row=>{
      const cells=Array.from(row.children),name=clean(cells[0]).replace(/\s*\*\s*$/,'').trim();
      const input=cells[4]&&cells[4].querySelector('input');
      const ranks=Math.max(0,Number(input&&input.value||0));
      if(name)spent+=ranks*skillRankCost(name);
    });
    const total=skillPointsBudget(); return {spent,total,remaining:total-spent};
  }
  function collectSkills() {
    const p=panel('Perícias');
    if(!p)throw new Error('Painel de perícias não encontrado.');
    const map=skillIdMap(),aliases={'blefar':'blefe','furtividade':'mover-se silenciosamente','identificar magias':'identificar magia','oficios':'oficio'};
    const skills={};
    p.querySelectorAll('tbody tr').forEach(row=>{
      const cells=Array.from(row.children),name=clean(cells[0]).replace(/\s*\*\s*$/,'').trim();
      const input=cells[4]&&cells[4].querySelector('input'),ranks=Number(input&&input.value||0);
      if(!name)return;
      if(!Number.isInteger(ranks)||ranks<0||ranks>skillRankMaximum(name))throw new Error('Graduações inválidas em '+name+'.');
      const skill=map.get(normalize(aliases[normalize(name)]||name));
      if(ranks>0&&!skill)throw new Error('A perícia "'+name+'" não possui correspondência no catálogo SRD. Não vou descartar essa graduação.');
      if(skill&&ranks>0)skills[skill.id]=ranks;
    });
    const allocation=skillAllocationStats();
    if(allocation.spent>allocation.total)throw new Error('Você distribuiu '+allocation.spent+' pontos de perícia, mas possui apenas '+allocation.total+'.');
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
  function addWizardBonusFeatToSheet() {
    const p = panel('Talentos');
    if (!p) throw new Error('Painel de talentos não encontrado.');
    const inputs = Array.from(p.querySelectorAll('input[type="text"]'));
    if (inputs.some((input,index) => index % 2 === 0 && normalize(input.value) === 'escrever pergaminho')) {
      lockWizardBonusFeatField();
      return;
    }
    for (let i=0;i<inputs.length;i+=2) {
      if (!String(inputs[i].value || '').trim()) {
        inputs[i].value = 'Escrever Pergaminho';
        if (inputs[i+1]) inputs[i+1].value = 'Mago 1';
        inputs[i].readOnly = true;
        if (inputs[i+1]) inputs[i+1].readOnly = true;
        inputs[i].dataset.classBonusFeat = 'scribe-scroll';
        return;
      }
    }
    throw new Error('Não há espaço livre na ficha para registrar o talento bônus Escrever Pergaminho.');
  }
  function lockWizardBonusFeatField() {
    const p = panel('Talentos');
    if (!p) return;
    const inputs = Array.from(p.querySelectorAll('input[type="text"]'));
    for (let i=0;i<inputs.length;i+=2) {
      if (normalize(inputs[i].value) === 'escrever pergaminho') {
        inputs[i].readOnly = true;
        if (inputs[i+1]) inputs[i+1].readOnly = true;
      }
    }
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
      if (feat.id === 'srd35_feat_scribe_scroll' && inputs[i].readOnly) continue;
      const entry = { id: feat.id };
      if (feat.exige_parametro) {
        const parameter = window.prompt('O talento "' + (feat.nome_pt || feat.nome) + '" exige uma escolha. Informe o parâmetro:');
        if (!parameter || !parameter.trim()) throw new Error('Informe o parâmetro exigido pelo talento ' + (feat.nome_pt || feat.nome) + '.');
        entry.parametro = parameter.trim();
      }
      if (feat.id === 'srd35_feat_scribe_scroll') throw new Error('Escrever Pergaminho é talento bônus automático do Mago de 1º nível; escolha outro talento geral.');
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
  function collectMoney() {
    const p = panel('Dinheiro');
    const inputs = p ? Array.from(p.querySelectorAll('input')).slice(0,4) : [];
    const keys = ['pc','pp','po','pl'];
    const result = {};
    keys.forEach((key,index) => {
      const raw = String(inputs[index] && inputs[index].value || '').trim();
      const value = raw ? Number(raw.replace(',','.')) : 0;
      if (!Number.isFinite(value) || value < 0) throw new Error('Informe uma quantidade válida e não negativa para ' + key.toUpperCase() + '.');
      result[key] = value;
    });
    return result;
  }
  function showFamiliarStatus(identity) {
    const p = panel('Familiar');
    if (!p || !identity || identity.wizard_familiar_available !== true || identity.wizard_familiar_choice !== 'pending') return;
    if (p.querySelector('.mage-class-feature-note')) return;
    const title = p.querySelector('.panel-title');
    if (!title) return;
    const note = document.createElement('div');
    note.className = 'mage-class-feature-note';
    note.textContent = 'Invocar Familiar · habilidade de classe disponível no 1º nível. A escolha e a invocação ficam para a narrativa; nenhum familiar foi criado automaticamente.';
    title.insertAdjacentElement('afterend',note);
  }
  function localDraftKey() {
    return 'dnd35-mage-draft:' + user.id + ':' + raceId;
  }
  function restoreLocalDraft() {
    try {
      const raw = localStorage.getItem(localDraftKey());
      if (!raw) return false;
      const draft = JSON.parse(raw);
      if (draft && draft.snapshot && draft.version === core.version) {
        core.hydrate(draft.snapshot);
        lockWizardBonusFeatField();
        renderSpellInputs();
        status('Rascunho local recuperado. Continue o preenchimento e crie a ficha quando estiver pronto.');
        return true;
      }
    } catch (error) {
      status('Não foi possível recuperar o rascunho local: ' + (error.message || error), true);
    }
    return false;
  }
  function bindLocalDraftAutosave() {
    const root = document.querySelector('.ficha');
    if (!root) return;
    const persist = () => {
      try {
        localStorage.setItem(localDraftKey(), JSON.stringify({
          version: core.version, raceId, classId, snapshot: core.collect()
        }));
      } catch (error) {
        status('Não foi possível salvar o rascunho local: ' + (error.message || error), true);
      }
    };
    root.addEventListener('input',persist);
    root.addEventListener('change',persist);
  }
  const alignmentOptions = [
    'Leal e Bom','Neutro e Bom','Caótico e Bom',
    'Leal e Neutro','Neutro','Caótico e Neutro',
    'Leal e Mau','Neutro e Mau','Caótico e Mau'
  ];
  function replaceIdentityInput(labelText, options) {
    const group = Array.from(document.querySelectorAll('.input-group')).find(el => normalize(clean(el.querySelector('label'))) === normalize(labelText));
    const old = group && group.querySelector('input,select');
    if (!old) return null;
    if (old.tagName === 'SELECT') return old;
    const select = document.createElement('select');
    select.className = old.className;
    select.innerHTML = '<option value="">Selecione...</option>' + options.map(value => '<option value="' + value + '">' + value + '</option>').join('');
    if (old.value && options.includes(old.value)) select.value = old.value;
    old.replaceWith(select);
    return select;
  }
  function rollDice(count, sides) {
    let total = 0;
    for (let i = 0; i < count; i++) total += 1 + Math.floor(Math.random() * sides);
    return total;
  }
  const physicalTables = {
    'anao': { male:[45,130,4,2,6], female:[43,100,4,2,6] },
    'elfo': { male:[53,85,6,1,6], female:[53,80,6,1,6] },
    'gnomo': { male:[36,40,4,0,1], female:[34,35,4,0,1] },
    'meio-elfo': { male:[55,100,8,2,4], female:[53,80,8,2,4] },
    'meio-orc': { male:[58,150,12,2,6], female:[53,110,12,2,6] },
    'halfling': { male:[32,30,4,0,1], female:[30,25,4,0,1] },
    'humano': { male:[58,120,10,2,4], female:[53,85,10,2,4] }
  };
  function setupIdentityChoices() {
    const alignment = replaceIdentityInput('Tendência', alignmentOptions);
    const sex = replaceIdentityInput('Sexo', ['Masculino','Feminino','Outro','Prefiro não informar']);
    const identityLine = document.querySelector('.ficha .input-line');
    if (!identityLine || document.getElementById('generate-racial-profile')) return;
    const button = document.createElement('button');
    button.type = 'button';
    button.id = 'generate-racial-profile';
    button.textContent = 'Gerar dados pela raça';
    button.style.cssText = 'margin:6px 0 10px auto;display:block;padding:7px 12px;border:1px solid #9b8057;border-radius:5px;background:rgba(155,128,87,.12);color:var(--tinta-escura);font:700 10px Cinzel,serif;cursor:pointer;';
    button.title = 'Gera tamanho, idade, altura e peso conforme as tabelas de D&D 3.5. Você pode editar qualquer campo depois.';
    const targetLine = Array.from(document.querySelectorAll('.ficha .input-line')).find(line => Array.from(line.querySelectorAll('label')).some(label => normalize(clean(label)) === 'peso'));
    if (targetLine) targetLine.insertAdjacentElement('afterend', button);
    button.addEventListener('click', () => {
      if (!raceData) return;
      const sexValue = normalize(sex && sex.value);
      if (!['masculino','feminino'].includes(sexValue)) {
        status('Escolha Masculino ou Feminino para gerar altura e peso. Você ainda pode preencher esses campos manualmente.');
        if (sex) sex.focus();
        return;
      }
      const table = physicalTables[raceData.id] && physicalTables[raceData.id][sexValue === 'masculino' ? 'male' : 'female'];
      if (!table) {
        status('Não há tabela racial cadastrada para essa raça. Os campos continuam livres para preenchimento manual.');
        return;
      }
      const [baseHeightIn, baseWeightLb, heightSides, weightCount, weightSides] = table;
      const heightExtra = rollDice(2, heightSides);
      const weightExtra = weightCount === 0 ? heightExtra : heightExtra * rollDice(weightCount, weightSides);
      const heightCm = Math.round((baseHeightIn + heightExtra) * 2.54);
      const weightKg = Math.round((baseWeightLb + weightExtra) * 0.45359237 * 10) / 10;
      const ageDice = ({'anao':7,'elfo':10,'gnomo':9,'meio-elfo':3,'meio-orc':2,'halfling':4,'humano':2})[raceData.id] || 2;
      const adulthood = ({'anao':40,'elfo':110,'gnomo':40,'meio-elfo':20,'meio-orc':14,'halfling':20,'humano':15})[raceData.id] || 15;
      const age = adulthood + rollDice(ageDice, 6);
      setGroupValue('Tamanho', raceData.tamanho || '');
      setGroupValue('Idade', String(age));
      setGroupValue('Altura', String(heightCm) + ' cm');
      setGroupValue('Peso', String(weightKg).replace('.', ',') + ' kg');
      status('Dados raciais gerados! Você pode editar tamanho, idade, altura e peso à vontade.');
      const root = document.querySelector('.ficha');
      if (root) root.dispatchEvent(new Event('change', {bubbles:true}));
    });
    [alignment,sex].forEach(control => control && control.addEventListener('change', () => {
      const root = document.querySelector('.ficha');
      if (root) root.dispatchEvent(new Event('change', {bubbles:true}));
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
    const money = panel('Dinheiro');
    if (money) Array.from(money.querySelectorAll('input')).slice(0,4).forEach(input => { if (!input.value.trim()) input.value = '0'; });
  }
  function sizeModifier(size) {
    return ({'miudo':2,'pequeno':1,'medio':0,'grande':-1,'enorme':-2,'imenso':-4,'colossal':-8})[normalize(size)] ?? 0;
  }
  function grappleSizeModifier(size) {
    return ({'miudo':-8,'pequeno':-4,'medio':0,'grande':4,'enorme':8,'imenso':12,'colossal':16})[normalize(size)] ?? 0;
  }
  function populateSkillTotals(final,modifiers,race) {
    const p=panel('Perícias'); if(!p)return;
    const map=skillIdMap(),aliases={'blefar':'blefe','furtividade':'mover-se silenciosamente','identificar magias':'identificar magia','oficios':'oficio'};
    p.querySelectorAll('tbody tr').forEach(row=>{
      const cells=Array.from(row.children),label=clean(cells[0]).replace(/\s*\*\s*$/,'').trim();
      const skill=map.get(normalize(aliases[normalize(label)]||label));
      const ability=skill&&skill.atributo||clean(cells[1]),mod=Number(modifiers[ability]||0);
      const ranksInput=cells[4]&&cells[4].querySelector('input');
      if(isCreate&&ranksInput&&!String(ranksInput.value).trim())ranksInput.value='0';
      const ranks=Number(ranksInput&&ranksInput.value||0),racial=racialSkillBonus(race,label);
      const classBonus=isClassSkill(label)&&ranks>0?3:0,other=Number(cells[6]&&cells[6].querySelector('input')&&cells[6].querySelector('input').value||0);
      const total=cells[2]&&cells[2].querySelector('input'),abilityInput=cells[3]&&cells[3].querySelector('input'),misc=cells[5]&&cells[5].querySelector('input');
      if(total){total.value=String(mod+ranks+racial+classBonus+other);total.readOnly=true;}
      if(abilityInput){abilityInput.value=String(mod);abilityInput.readOnly=true;}
      if(misc){misc.value=String(racial+classBonus);misc.readOnly=true;const notes=[];if(classBonus)notes.push('+3 por perícia de classe treinada');if(racial)notes.push('bônus racial +'+racial);const conditional=conditionalRacialSkillNote(race,label);if(conditional)notes.push(conditional);misc.title=notes.join('; ');}
    });
    refreshSkillAllocationUI();
  }
  const SUGGESTED_WIZARD_ATTRIBUTES={FOR:8,DES:13,CON:14,INT:15,SAB:12,CAR:10};
  function setBaseAttributeValues(base) {
    const adjustments=raceData&&raceData.ajustes_atributos||{},p=panel('Atributos');if(!p)return;
    p.querySelectorAll('.attr-row').forEach(row=>{
      const stat=clean(row.querySelector('.attr-name'));if(!(stat in base))return;
      const input=row.querySelector('.attr-col input');if(input){input.value=String(Number(base[stat])+Number(adjustments[stat]||0));input.dataset.lastValid=input.value;input.dispatchEvent(new Event('input',{bubbles:true}));}
    });
  }
  function updateAttributeBudget() {
    const p=panel('Atributos');if(!p)return;
    let note=p.querySelector('.mage-ability-budget');
    if(!note){note=createNode('div','mage-ability-budget');p.appendChild(note);}
    try{const spent=pointBuyTotal(getBaseAttributes());note.textContent='COMPRA DE PONTOS · '+spent+'/25';note.dataset.valid=spent<=25?'true':'false';}
    catch(_){note.textContent='COMPRA DE PONTOS · 25 disponíveis';note.dataset.valid='false';}
  }
  function recalculateCreationFromAttributes() {
    const base=getBaseAttributes();if(pointBuyTotal(base)>25)throw new Error('A compra de atributos ultrapassa os 25 pontos.');
    applyCalculatedFields(base,raceData,[]);updateAttributeBudget();
  }
  function changeBaseAttribute(stat,delta) {
    try{
      const base=getBaseAttributes(),next=Number(base[stat])+delta;if(next<8||next>18)return;
      const changed={...base,[stat]:next},spent=pointBuyTotal(changed);
      if(spent>25){status('Esse ajuste ultrapassa os 25 pontos de compra. Reduza outro atributo primeiro.');return;}
      setBaseAttributeValues(changed);recalculateCreationFromAttributes();status('Atributos atualizados · '+spent+'/25 pontos de compra.');
    }catch(error){status(error.message||String(error),true);}
  }
  function setupAttributeControls() {
    const p=panel('Atributos');if(!p||p.dataset.adjustControls==='true')return;p.dataset.adjustControls='true';
    p.querySelectorAll('.attr-row').forEach(row=>{
      const stat=clean(row.querySelector('.attr-name')),column=row.querySelectorAll('.attr-col')[0],input=column&&column.querySelector('input');
      if(!stat||!input)return;input.step='1';input.dataset.lastValid=String(input.value||'');input.setAttribute('aria-label','Valor final de '+stat+' com ajuste racial');
      const wrap=createNode('div','mage-ability-adjust'),minus=createNode('button','','−'),plus=createNode('button','','+');
      minus.type='button';minus.title='Diminuir '+stat;minus.setAttribute('aria-label','Diminuir '+stat);minus.addEventListener('click',()=>changeBaseAttribute(stat,-1));
      plus.type='button';plus.title='Aumentar '+stat;plus.setAttribute('aria-label','Aumentar '+stat);plus.addEventListener('click',()=>changeBaseAttribute(stat,1));
      input.parentNode.insertBefore(wrap,input);wrap.append(minus,input,plus);
      input.addEventListener('change',()=>{
        const previous=input.dataset.lastValid;
        try{const base=getBaseAttributes();if(pointBuyTotal(base)>25)throw new Error('A compra de atributos deve respeitar os 25 pontos.');recalculateCreationFromAttributes();input.dataset.lastValid=String(input.value);}
        catch(error){input.value=previous||'8';recalculateCreationFromAttributes();status(error.message||String(error),true);}
      });
    });updateAttributeBudget();
  }
  function refreshSkillAllocationUI() {
    const p=panel('Perícias');if(!p)return;
    const title=p.querySelector('.panel-title');
    if(title){let badge=title.querySelector('.mage-skill-budget');if(!badge){badge=createNode('span','mage-skill-budget');title.appendChild(badge);}
      try{const stats=skillAllocationStats();badge.textContent='PONTOS · '+stats.remaining+'/'+stats.total;badge.title=stats.spent+' gastos; perícias de classe custam 1 e demais custam 2.';badge.dataset.valid=stats.remaining>=0?'true':'false';}
      catch(_){badge.textContent='PONTOS · aguardando atributos';}
    }
    p.querySelectorAll('tbody tr').forEach(row=>{
      const cells=Array.from(row.children),name=clean(cells[0]).replace(/\s*\*\s*$/,'').trim(),input=cells[4]&&cells[4].querySelector('input');
      const buttons=input&&input.closest('.mage-skill-adjust')&&input.closest('.mage-skill-adjust').querySelectorAll('button');if(!buttons||buttons.length!==2)return;
      const current=Number(input.value||0),remaining=(()=>{try{return skillAllocationStats().remaining;}catch(_){return 0;}})();
      buttons[0].disabled=current<=0;buttons[1].disabled=current>=skillRankMaximum(name)||remaining<skillRankCost(name);
    });
  }
  function adjustSkillRank(row,delta) {
    const cells=Array.from(row.children),name=clean(cells[0]).replace(/\s*\*\s*$/,'').trim(),input=cells[4]&&cells[4].querySelector('input');if(!input)return;
    const next=Number(input.value||0)+delta;if(next<0||next>skillRankMaximum(name))return;
    const stats=skillAllocationStats();if(delta>0&&stats.remaining<skillRankCost(name)){status('Não há pontos de perícia suficientes para essa graduação.');return;}
    input.value=String(next);input.dataset.lastValid=String(next);input.dispatchEvent(new Event('input',{bubbles:true}));
    const base=getBaseAttributes(),final={};Object.keys(base).forEach(k=>final[k]=Number(base[k])+Number((raceData.ajustes_atributos||{})[k]||0));
    const modifiers={};Object.keys(final).forEach(k=>modifiers[k]=Math.floor((final[k]-10)/2));populateSkillTotals(final,modifiers,raceData);
  }
  function setupSkillAllocationControls() {
    const p=panel('Perícias');if(!p||p.dataset.adjustControls==='true')return;p.dataset.adjustControls='true';
    p.querySelectorAll('tbody tr').forEach(row=>{
      const cells=Array.from(row.children),name=clean(cells[0]).replace(/\s*\*\s*$/,'').trim(),cell=cells[4],input=cell&&cell.querySelector('input');if(!name||!input)return;
      input.type='number';input.step='1';input.min='0';input.max=String(skillRankMaximum(name));if(isCreate&&!String(input.value).trim())input.value='0';input.dataset.lastValid=String(Number(input.value||0));
      const wrap=createNode('div','mage-skill-adjust'),minus=createNode('button','','−'),plus=createNode('button','','+');
      minus.type='button';minus.setAttribute('aria-label','Remover graduação de '+name);minus.addEventListener('click',()=>adjustSkillRank(row,-1));
      plus.type='button';plus.setAttribute('aria-label','Adicionar graduação em '+name);plus.addEventListener('click',()=>adjustSkillRank(row,1));
      cell.insertBefore(wrap,input);wrap.append(minus,input,plus);
      input.addEventListener('change',()=>{
        const value=Number(input.value||0),previous=Number(input.dataset.lastValid||0);
        if(!Number.isInteger(value)||value<0||value>skillRankMaximum(name)){input.value=String(previous);status('Limite de graduações para '+name+': '+skillRankMaximum(name)+'.');}
        else if(skillAllocationStats().spent>skillAllocationStats().total){input.value=String(previous);status('Essa graduação excede os pontos de perícia disponíveis.');}
        else input.dataset.lastValid=String(value);
        const base=getBaseAttributes(),final={};Object.keys(base).forEach(k=>final[k]=Number(base[k])+Number((raceData.ajustes_atributos||{})[k]||0));
        const modifiers={};Object.keys(final).forEach(k=>modifiers[k]=Math.floor((final[k]-10)/2));populateSkillTotals(final,modifiers,raceData);
      });
    });refreshSkillAllocationUI();
  }
  function initializeCreationDefaults(draftRestored) {
    let base;
    if(!draftRestored){base={...SUGGESTED_WIZARD_ATTRIBUTES};setBaseAttributeValues(base);}
    else {
      try{base=getBaseAttributes();if(pointBuyTotal(base)>25)throw new Error('Rascunho excede o orçamento de atributos.');}
      catch(_){base={...SUGGESTED_WIZARD_ATTRIBUTES};setBaseAttributeValues(base);}
    }
    applyCalculatedFields(base,raceData,[]);setupAttributeControls();setupSkillAllocationControls();addWizardBonusFeatToSheet();updateAttributeBudget();
    status('Ficha pré-preenchida com uma distribuição sugerida para Mago de 1º nível. As regras permitem redistribuir os 25 pontos e escolher onde aplicar os pontos de perícia.');
  }

  function updateEquipmentWeight(items) {
    const p = panel('Equipamentos');
    if (!p) return;
    const inputs = p.querySelectorAll('input');
    const total = inputs[inputs.length - 1];
    const weights = items.map(item => {
      const match = String(item.peso || '').replace(',', '.').match(/-?\d+(?:\.\d+)?/);
      return match ? Number(match[0]) : 0;
    });
    if (total) total.value = weights.reduce((sum,value) => sum + value,0).toFixed(2).replace(/\.00$/,'') + ' kg';
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
      const value = cols[0]?.querySelector('.mage-ability-adjust input, input');
      const mod = cols[1]?.querySelector('input[type="number"]');
      const racial = cols[3]?.querySelector('input[type="number"]');
      if (value) value.value = String(final[stat]);
      if (mod) mod.value = String(modifiers[stat]);
      if (racial) { racial.value = String(Number(adjustments[stat] || 0)); racial.readOnly = true; racial.title = 'Ajuste racial aplicado automaticamente'; }
    });
    const movementPanel = panel('Deslocamento');
    if (movementPanel) {
      const movementInput = movementPanel.querySelector('input[data-sheet-field="deslocamento.base"]');
      if (movementInput) {
        const meters = Number(race && race.deslocamento);
        if (Number.isFinite(meters) && meters > 0) movementInput.value = meters + ' m';
        movementInput.title = 'Deslocamento base racial. Ajustes por carga, armadura ou habilidades podem ser aplicados durante a campanha.';
      }
    }
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
    const grappleMod = grappleSizeModifier(race.tamanho);
    const basePanel = panel('Base e Agarrar');
    if (basePanel) {
      const inputs = basePanel.querySelectorAll('input');
      if (inputs[0]) inputs[0].value = '0';
      if (inputs[2]) inputs[2].value = String(modifiers.FOR + grappleMod);
      if (inputs[3]) inputs[3].value = '0';
      if (inputs[4]) inputs[4].value = String(modifiers.FOR);
      if (inputs[5]) inputs[5].value = String(grappleMod);
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
      if (isCreate && rows[1]) rows[1].querySelectorAll('input').forEach(input => { input.value = ''; input.disabled = true; });
      const knownCells = rows[0] ? rows[0].querySelectorAll('td') : [];
      for (let circle=0;circle<=9;circle++) {
        const input = knownCells[circle+1]?.querySelector('input');
        if (input) input.value = circle === 0 ? String(allowedSpells(0).length) : circle === 1 ? String(selectedSpells.length) : '0';
      }
    }
    populateSkillTotals(final,modifiers,race);
    const xpPanel = panel('Experiência');
    if (xpPanel) {
      const inputs = xpPanel.querySelectorAll('input');
      if (inputs[0]) inputs[0].value = '0';
      if (inputs[1]) inputs[1].value = '0';
    }
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
    const id = ensureDatalist('mage-feat-catalog', featCatalog.filter(f => f.id !== 'srd35_feat_scribe_scroll').map(f => ({nome:f.nome_pt || f.nome})));
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

  function createNode(tag, className, text) {
    const node = document.createElement(tag);
    if (className) node.className = className;
    if (text !== undefined) node.textContent = text;
    return node;
  }
  function ensureCatalogOverlays() {
    if (!document.getElementById('mage-catalog-overlay')) {
      const overlay = createNode('div','mage-catalog-backdrop');
      overlay.id = 'mage-catalog-overlay';
      const shell = createNode('section','mage-catalog-shell');
      shell.setAttribute('role','dialog');
      shell.setAttribute('aria-modal','true');
      shell.setAttribute('aria-labelledby','mage-catalog-title');
      const head = createNode('header','mage-catalog-head');
      const title = createNode('h2','', 'Catálogo');
      title.id = 'mage-catalog-title';
      const close = createNode('button','mage-catalog-close','×');
      close.type = 'button';
      close.setAttribute('aria-label','Fechar catálogo');
      close.addEventListener('click',closeCatalog);
      head.append(title,close);
      const tools = createNode('div','mage-catalog-tools');
      const search = createNode('input');
      search.id = 'mage-catalog-search';
      search.type = 'search';
      search.placeholder = 'Pesquisar no catálogo…';
      search.addEventListener('input',renderCatalogList);
      tools.appendChild(search);
      const list = createNode('div','mage-catalog-list');
      list.id = 'mage-catalog-list';
      shell.append(head,tools,list);
      overlay.appendChild(shell);
      overlay.addEventListener('click',event=>{if(event.target===overlay)closeCatalog();});
      document.body.appendChild(overlay);
    }
    if (!document.getElementById('mage-lore-overlay')) {
      const overlay = createNode('div','mage-lore-backdrop');
      overlay.id = 'mage-lore-overlay';
      const copy = createNode('article','mage-lore-copy');
      copy.id = 'mage-lore-copy';
      copy.setAttribute('role','document');
      overlay.appendChild(copy);
      overlay.addEventListener('click',event=>{if(event.target===overlay)closeLore();});
      document.body.appendChild(overlay);
    }
  }
  function closeCatalog() {
    const overlay = document.getElementById('mage-catalog-overlay');
    if (overlay) overlay.classList.remove('ativo');
    catalogMode = null;
  }
  function closeLore() {
    const overlay = document.getElementById('mage-lore-overlay');
    if (overlay) overlay.classList.remove('ativo');
  }
  function loreParagraphs(parent, value) {
    const text = String(value || '').replace(/\r/g,'').trim();
    if (!text) {
      parent.appendChild(createNode('p','', 'Descrição ainda não cadastrada para este registro.'));
      return;
    }
    text.split(/\n{2,}/).forEach(part=>{
      const cleanPart = part.trim();
      if (!cleanPart) return;
      if (/^#{1,3}\s+/.test(cleanPart)) {
        parent.appendChild(createNode('h3','',cleanPart.replace(/^#{1,3}\s+/,'').trim()));
        return;
      }
      const labelMatch = cleanPart.match(/^(?:\*\*([^*]+)\*\*|([^:]{2,55})):?\s*([\s\S]*)$/);
      const knownLabel = /^(Benefício|Normal|Especial|Pré-requisito|Pré-requisitos|Descrição|Efeito|Nível|Componentes|Tempo de Execução|Alcance|Alvo|Área|Duração|Teste de Resistência|Resistência à Magia|Conjuração|Transmutação|Abjuração|Adivinhação|Evocação|Ilusão|Necromancia|Encantamento)$/i;
      if (labelMatch && knownLabel.test((labelMatch[1] || labelMatch[2] || '').trim())) {
        const heading = createNode('h3','',(labelMatch[1] || labelMatch[2]).trim());
        parent.appendChild(heading);
        const rest = (labelMatch[3] || '').trim();
        if (rest) { const paragraph=createNode('p','',rest); paragraph.style.whiteSpace='pre-line'; parent.appendChild(paragraph); }
      } else {
        const paragraph=createNode('p','',cleanPart);
        paragraph.style.whiteSpace='pre-line';
        parent.appendChild(paragraph);
      }
    });
  }
  function openLore(title, meta, description) {
    ensureCatalogOverlays();
    const overlay = document.getElementById('mage-lore-overlay');
    const copy = document.getElementById('mage-lore-copy');
    copy.replaceChildren();
    const head=createNode('header','mage-lore-head'),heading=createNode('h2','',title||'Descrição'),close=createNode('button','mage-lore-close','×');
    close.type='button';close.setAttribute('aria-label','Fechar descrição e voltar ao catálogo');close.addEventListener('click',closeLore);
    head.append(heading,close);copy.appendChild(head);
    if (meta) copy.appendChild(createNode('div','mage-lore-meta',meta));
    loreParagraphs(copy,description);
    overlay.classList.add('ativo');
  }
  function featPrerequisite(feat) {
    const req = feat && feat.requisitos && typeof feat.requisitos === 'object' ? feat.requisitos : {};
    if (req.raw && String(req.raw).trim()) return String(req.raw).trim();
    const parts = [];
    const abilities = [['for_min','For'],['des_min','Des'],['con_min','Con'],['int_min','Int'],['sab_min','Sab'],['car_min','Car']];
    abilities.forEach(([key,label])=>{if(req[key])parts.push(label+' '+req[key]);});
    if (req.bab_min !== undefined) parts.push('BBA +'+req.bab_min);
    if (req.level_min !== undefined) parts.push('Nível '+req.level_min);
    if (Array.isArray(req.feat_ids) && req.feat_ids.length) {
      const names = req.feat_ids.map(id=>{const f=featCatalog.find(item=>item.id===id);return f ? (f.nome_pt||f.nome) : id;});
      parts.push(names.join(', '));
    }
    if (Array.isArray(req.skill_ranks) && req.skill_ranks.length) parts.push('Graduações em perícias');
    return parts.join(' · ') || 'Pré-requisitos não detalhados no cadastro';
  }
  function catalogRow(name,meta,icon,onChoose,onView) {
    const row=createNode('div','mage-catalog-row'),mark=createNode('span','mage-catalog-mark'),glyph=createNode('i','fa-solid '+icon);
    glyph.setAttribute('aria-hidden','true');mark.appendChild(glyph);
    const main=createNode('div','mage-catalog-main'),title=createNode('span','mage-catalog-name',name),sub=createNode('span','mage-catalog-meta',meta||'');
    main.append(title,sub);
    const actions=createNode('div','mage-catalog-actions'),choose=createNode('button','mage-catalog-choose','ESCOLHER'),view=createNode('button','mage-catalog-view','ver mais');
    choose.type='button';choose.addEventListener('click',onChoose);view.type='button';view.addEventListener('click',onView);
    actions.append(choose,view);row.append(mark,main,actions);return row;
  }
  function spellCatalogRow(name,meta,icon,onChoose,onView) {
    const row=createNode('div','mage-catalog-row mage-spell-catalog-row');
    const mark=createNode('span','mage-catalog-mark'),glyph=createNode('i','fa-solid '+icon);
    glyph.setAttribute('aria-hidden','true');mark.appendChild(glyph);
    const main=createNode('div','mage-catalog-main'),choose=createNode('button','mage-catalog-name',name),sub=createNode('span','mage-catalog-meta',meta||'');
    choose.type='button';choose.addEventListener('click',onChoose);main.append(choose,sub);
    const view=createNode('button','mage-catalog-view','VER');view.type='button';view.addEventListener('click',onView);
    row.append(mark,main,view);return row;
  }
  function familiarLabel(monster) {
    const names = {bat:'Morcego',cat:'Gato',hawk:'Falcão',lizard:'Lagarto',owl:'Coruja',rat:'Rato',raven:'Corvo',toad:'Sapo',weasel:'Doninha'};
    return names[monster.id] || monster.nome;
  }
  function familiarSize(value) {
    const sizes = {diminutive:'Mínimo',tiny:'Miúdo',small:'Pequeno',medium:'Médio',large:'Grande',huge:'Enorme',gargantuan:'Imenso',colossal:'Colossal'};
    return sizes[normalize(value)] || value || '';
  }
  function renderCatalogList() {
    const list = document.getElementById('mage-catalog-list');
    const search = normalize(document.getElementById('mage-catalog-search')?.value || '');
    if (!list || !catalogMode) return;
    list.replaceChildren();
    let items = [];
    if (catalogMode === 'feats') {
      items = featCatalog.filter(item=>item.id!=='srd35_feat_scribe_scroll' && normalize((item.nome_pt||item.nome)+' '+featPrerequisite(item)).includes(search));
      items.forEach(feat=>{
        const name = feat.nome_pt || feat.nome;
        const description = feat.descricao_pt || feat.descricao || '';
        list.appendChild(catalogRow(name,'Pré-requisito: '+featPrerequisite(feat),'fa-feather-pointed',()=>chooseFeat(feat),()=>openLore(name,'Pré-requisito: '+featPrerequisite(feat),description)));
      });
    } else if (catalogMode === 'spells') {
      const level = Number(document.getElementById('mage-catalog-level')?.value ?? (isCreate ? 1 : 0));
      items = allowedSpells(level).filter(item=>normalize((item.nome_pt||item.nome)+' '+item.escola+' '+item.nivel).includes(search));
      items.forEach(spell=>{
        const name = spell.nome_pt || spell.nome;
        const meta = 'Círculo '+spell.circulo+' · '+schoolLabel(normalize(spell.escola).split(' ')[0])+' · '+(spell.alcance||'Alcance não informado');
        const details = [
          'Escola: '+(spell.escola||'Não informada'),
          'Círculo: '+spell.circulo,
          'Alcance: '+(spell.alcance||'Não informado'),
          'Alvo: '+(spell.alvo||spell.area||'Não informado'),
          'Duração: '+(spell.duracao||'Não informada'),
          'Componentes: '+(spell.componentes||'Não informados')
        ].join('\n');
        list.appendChild(spellCatalogRow(name,meta,'fa-wand-sparkles',()=>chooseSpell(spell),()=>openLore(name,details,spell.descricao_pt||spell.descricao||'')));
      });
    } else if (catalogMode === 'familiar') {
      items = monsterCatalog.filter(item=>normalize(item.nome+' '+item.nome_original+' '+item.tamanho).includes(search));
      items.forEach(monster=>{
        const meta = 'Animal · '+familiarSize(monster.tamanho)+' · ND '+monster.nd+' · '+(monster.deslocamento||'Deslocamento não informado');
        const details = [
          'Tamanho: '+(monster.tamanho||'Não informado'),
          'Pontos de vida: '+(monster.pv ?? monster.dados_vida ?? 'Não informado'),
          'Iniciativa: '+(monster.iniciativa||'Não informada'),
          'Deslocamento: '+(monster.deslocamento||'Não informado'),
          'Classe de Armadura: '+(monster.ca||'Não informada'),
          'Ataques: '+(monster.ataques||'Não informados')
        ].join('\n');
        list.appendChild(catalogRow(familiarLabel(monster),meta,'fa-paw',()=>chooseFamiliar(monster),()=>openLore(familiarLabel(monster),details,monster.descricao||'')));
      });
    }
    if (!items.length) list.appendChild(createNode('div','mage-catalog-empty','Nenhum resultado encontrado para esta pesquisa.'));
  }
  function openCatalog(mode) {
    ensureCatalogOverlays();
    catalogMode = mode;
    const overlay = document.getElementById('mage-catalog-overlay');
    const title = document.getElementById('mage-catalog-title');
    const tools = document.querySelector('#mage-catalog-overlay .mage-catalog-tools');
    const search = document.getElementById('mage-catalog-search');
    title.textContent = mode === 'feats' ? 'Talentos' : mode === 'spells' ? 'Grimório' : 'Familiar';
    tools.querySelectorAll('#mage-catalog-level').forEach(node=>node.remove());
    if (mode === 'spells') {
      const level = createNode('select');
      level.id = 'mage-catalog-level';
      for(let i=0;i<=9;i++){
        const option = createNode('option','',i===0?'Truques (0)':'Círculo '+i);
        option.value = String(i);
        level.appendChild(option);
      }
      level.value = String(isCreate ? 1 : 0);
      level.addEventListener('change',renderCatalogList);
      tools.appendChild(level);
    }
    search.value = '';
    overlay.classList.add('ativo');
    renderCatalogList();
    search.focus();
  }
  function bindCatalogTriggers() {
    document.querySelectorAll('.panel-title').forEach(title=>{
      const label = normalize(clean(title));
      const mode = label === 'talentos' ? 'feats' : label === 'familiar' ? 'familiar' : label.startsWith('grimorio') ? 'spells' : null;
      if (!mode || title.dataset.catalogBound) return;
      title.dataset.catalogBound = 'true';
      title.classList.add('mage-catalog-trigger');
      title.setAttribute('role','button');
      title.setAttribute('tabindex','0');
      title.addEventListener('click',()=>openCatalog(mode));
      title.addEventListener('keydown',event=>{if(event.key==='Enter'||event.key===' '){event.preventDefault();openCatalog(mode);}});
    });
  }
  function appendFeatRow() {
    const p = panel('Talentos');
    const rows = Array.from(p.querySelectorAll('div[style*="grid-template-columns: 1fr 50px"]')).filter(row=>row.querySelectorAll('input').length===2);
    const row = rows[0].cloneNode(true);
    row.querySelectorAll('input').forEach(input=>{input.value='';input.readOnly=false;input.removeAttribute('list');});
    rows[rows.length-1].insertAdjacentElement('afterend',row);
    return row.querySelectorAll('input');
  }
  function chooseFeat(feat) {
    const p = panel('Talentos');
    const rows = Array.from(p.querySelectorAll('div[style*="grid-template-columns: 1fr 50px"]')).filter(row=>row.querySelectorAll('input').length===2);
    const name = feat.nome_pt || feat.nome;
    const already = rows.some(row=>normalize(row.querySelector('input')?.value)===normalize(name));
    if (already) { status('Este talento já está registrado na ficha.'); closeCatalog(); return; }
    let row = rows.find(item=>!String(item.querySelector('input')?.value||'').trim());
    if (!row) { appendFeatRow(); row = Array.from(p.querySelectorAll('div[style*="grid-template-columns: 1fr 50px"]')).filter(item=>item.querySelectorAll('input').length===2).at(-1); }
    const inputs = row.querySelectorAll('input');
    inputs[0].value = name;
    inputs[1].value = '';
    inputs[0].dispatchEvent(new Event('input',{bubbles:true}));
    closeCatalog();
    status('Talento adicionado à ficha: '+name+'.');
  }
  function chooseSpell(spell) {
    const circle = Number(spell.circulo);
    const block = Array.from(document.querySelectorAll('.spell-level-block')).find(item=>parseInt(clean(item.querySelector('.spell-level-title')),10)===circle);
    if (!block) { status('A ficha não possui uma área para este círculo de magia.',true); return; }
    const list = block.querySelector('.spell-list');
    const name = spell.nome_pt || spell.nome;
    const inputs = Array.from(list.querySelectorAll('input[type="text"]'));
    let target = inputs.find(input=>!String(input.value||'').trim() && !input.disabled);
    if (!target) {
      const template = list.querySelector('.spell-row');
      const clone = template.cloneNode(true);
      clone.querySelectorAll('input').forEach(input=>{input.value='';input.checked=false;input.disabled=false;input.readOnly=false;});
      list.appendChild(clone);
      target = clone.querySelector('input[type="text"]');
    }
    if (target) {
      target.value = name;
      target.dispatchEvent(new Event('input',{bubbles:true}));
      closeCatalog();
      status('Magia adicionada ao grimório: '+name+'.');
    }
  }
  function chooseFamiliar(monster) {
    selectedFamiliar = monster;
    const p = panel('Familiar');
    const values = {
      'Tamanho':familiarSize(monster.tamanho),
      'Iniciativa':monster.iniciativa,
      'Deslocamento':monster.deslocamento,
      'PV':monster.pv ?? monster.dados_vida,
      'CA Total':monster.ca,
      'Ataque':monster.ataques,
      'Agarrar':monster.base_attack_grapple,
      'Ataque Total':monster.ataques,
      'Espaço':monster.espaco_alcance
    };
    Object.entries(values).forEach(([label,value])=>{if(value!==undefined&&value!==null){const input=labeledInput('Familiar',label);if(input)input.value=String(value);}});
    const spaceReach = String(monster.espaco_alcance || '').split('/');
    const space = labeledInput('Familiar','Espaço');
    const reach = labeledInput('Familiar','Alcance');
    if (space && spaceReach[0]) space.value = spaceReach[0].trim();
    if (reach && spaceReach[1]) reach.value = spaceReach.slice(1).join('/').trim();
    const localizedName = familiarLabel(monster);
    const note = createNode('div','mage-familiar-selection','Familiar escolhido: '+localizedName+' · dados copiados do registro da criatura ('+monster.nome+').');
    const title = p.querySelector('.panel-title');
    const old = p.querySelector('.mage-familiar-selection');
    if (old) old.remove();
    title.insertAdjacentElement('afterend',note);
    const textarea = p.querySelector('textarea');
    if (textarea) textarea.value = localizedName+' ('+monster.nome+')\n\n'+(monster.descricao||'');
    closeCatalog();
    status('Familiar registrado na ficha: '+monster.nome+'.');
  }
  function formatSpellCatalogDescription(spell) {
    const name = spell.nome_pt || spell.nome;
    return [name,spell.escola,spell.circulo,spell.descricao_pt||spell.descricao].filter(Boolean).join('\n\n');
  }

  async function loadCatalogs() {
    const results = await Promise.all([
      sb.from('srd_skills').select('id,nome,atributo,treinada_apenas'),
      sb.from('srd_feats').select('id,nome,nome_pt,descricao,descricao_pt,exige_parametro,requisitos,source_status'),
      sb.from('srd_spells').select('id,nome,nome_pt,descricao,descricao_pt,circulo,nivel,escola,alcance,alvo,area,duracao,componentes,classes,source_status').contains('classes',['wizard'])
    ]);
    for (const result of results) if (result.error) throw result.error;
    skillCatalog = results[0].data || [];
    featCatalog = results[1].data || [];
    spellCatalog = results[2].data || [];
    const familiarResult = await sb.from('srd_monsters').select('id,nome,nome_original,nd,tamanho,tipo,dados_vida,iniciativa,deslocamento,pv,ca,base_attack_grapple,ataques,espaco_alcance,descricao').in('id',['bat','cat','hawk','lizard','owl','rat','raven','toad','weasel']);
    monsterCatalog = familiarResult.error ? [] : (familiarResult.data || []);
    updateFeatSuggestions();
    updateSpellSuggestions();
  }
  function guideTargetFor(control) {
    return control.closest('.attr-row, .resist-row, .input-group, .spell-row, tr, .atk-block, .panel') || control;
  }
  function guideCandidates() {
    const controls = Array.from(document.querySelectorAll('.ficha input, .ficha textarea, .ficha select'));
    const seen = new Set();
    const items = [];
    controls.forEach(control => {
      if (control.disabled || control.readOnly || control.type === 'hidden' || control.type === 'button' || control.type === 'submit') return;
      if (control.closest('[hidden],.mage-catalog-overlay,.mage-lore-overlay')) return;
      // Resistências, BBA e Agarrar são campos derivados; Resistência à Magia só se aplica quando houver uma fonte específica.
      const panelTitle = normalize(clean(control.closest('.panel')?.querySelector('.panel-title')));
      if (control.closest('.resist-row') || /resistencias/.test(panelTitle) || /base e agarrar/.test(panelTitle) || /iniciativa/.test(panelTitle) || /deslocamento/.test(panelTitle)) return;
      const target = guideTargetFor(control);
      if (!target || seen.has(target)) return;
      seen.add(target);
      const labelNode = target.querySelector('label,td:first-child,th:first-child,.attr-name,.resist-name,.panel-title');
      const label = clean(labelNode) || 'esta informação';
      const sectionPanel = control.closest('.panel');
      const sectionKey = normalize(sectionPanel ? clean(sectionPanel.querySelector('.panel-title')) : 'identidade');
      let help = 'Preencha ou confira esta informação. Ela ficará registrada neste espaço da ficha para consulta durante a campanha.';
      const attributeHelp = {
        'for': 'FORÇA é o braço forte do personagem: ajuda a acertar golpes corpo a corpo, aumenta o dano e conta para tarefas físicas como escalar, saltar e arrombar. Também influencia quanto equipamento você consegue carregar.',
        'des': 'DESTREZA é agilidade, reflexo e coordenação. Entra na Iniciativa, na CA (quando você pode se esquivar), nos Reflexos e em perícias como Furtividade, Acrobacia e Abrir Fechaduras. Armaduras pesadas podem limitar parte desse benefício.',
        'con': 'CONSTITUIÇÃO é fôlego e resistência. Ela aumenta seus Pontos de Vida a cada nível e ajuda nos testes de Fortitude, usados para resistir a venenos, doenças e outros perigos que castigam o corpo.',
        'int': 'INTELIGÊNCIA é raciocínio, memória e estudo. Ela define quantos pontos de perícia você recebe e ajuda em perícias de conhecimento e investigação. Para o Mago, também é o atributo-chave das magias: influencia o que ele pode conjurar e a dificuldade para resistir a elas.',
        'sab': 'SABEDORIA é percepção, instinto e força de vontade. Ajuda na resistência de Vontade e em perícias como Ouvir, Observar, Sentir Motivação e Sobrevivência. É o atributo-chave de conjuradores como Clérigos e Druidas.',
        'car': 'CARISMA é presença, confiança e força de personalidade. Ajuda em Blefar, Diplomacia, Intimidar e Atuação. Também é o atributo-chave de conjuradores como Feiticeiros e Bardos.'
      };
      const attributeKey = normalize(label).replace(/[^a-z]/g,'');
      if (/atributos/.test(sectionKey) && attributeHelp[attributeKey]) help = attributeHelp[attributeKey];
      if (/cabecalho|identidade/.test(sectionKey)) help = 'Aqui ficam os dados que dão cara ao seu aventureiro: nome, raça, tendência e características físicas. Escolha o que quiser; os dados gerados pela raça são sugestões e podem ser alterados.';
      else if (/atributos/.test(sectionKey)) help = attributeHelp[attributeKey] || 'Os atributos são as seis capacidades básicas do personagem. O valor define o modificador que entra em testes, perícias, combate e resistências. Os ajustes raciais são considerados pelo sistema.';
      else if (/pericias/.test(sectionKey)) help = 'As perícias mostram aquilo em que seu personagem foi treinado. O atributo relacionado e os benefícios de classe ou raça entram no cálculo automaticamente.';
      else if (/talentos/.test(sectionKey)) help = 'Escolha uma habilidade especial para seu personagem. O catálogo apresenta os requisitos e os efeitos de cada talento.';
      else if (/grimorio|magia/.test(sectionKey)) help = 'Aqui você registra as magias do Grimório. A preparação acontece durante a campanha, conforme a narrativa.';
      else if (/equipamentos/.test(sectionKey)) help = 'Registre o que seu personagem carrega. Esses itens aparecem na ficha para consulta durante a aventura.';
      else if (/idiomas/.test(sectionKey)) help = 'Informe os idiomas que seu personagem conhece. Os idiomas concedidos pela raça devem aparecer preenchidos automaticamente.';
      items.push({target,control,label,help});
    });
    return items;
  }
  function showStep(next) {
    const candidates = guideCandidates();
    if (!candidates.length) {
      const oldNote = document.getElementById('mage-step-note');
      if (oldNote) oldNote.remove();
      status('Não há mais campos que precisem de preenchimento manual. Revise a ficha e salve.');
      return;
    }
    step = Math.max(0,Math.min(candidates.length - 1,next));
    document.querySelectorAll('.mage-step-focus').forEach(el=>el.classList.remove('mage-step-focus'));
    const item = candidates[step];
    item.target.classList.add('mage-step-focus');
    item.target.scrollIntoView({behavior:'smooth',block:'center'});
    let note = document.getElementById('mage-step-note');
    if (!note) { note = document.createElement('aside'); note.id = 'mage-step-note'; note.className = 'mage-step-note'; document.body.appendChild(note); }
    note.innerHTML = '<div style="font-size:10px;letter-spacing:.14em;text-transform:uppercase;color:#98764a;margin-bottom:6px">Sua jornada · etapa ' + (step+1) + ' de ' + candidates.length + '</div><strong>' + item.label + '</strong><div>' + item.help + '</div><div class="mage-guide-progress"><span style="width:' + (((step+1)/candidates.length)*100) + '%"></span></div>';
    document.getElementById('mage-prev').disabled = step === 0;
    const nextButton = document.getElementById('mage-next');
    nextButton.textContent = step === candidates.length - 1 ? 'Concluir guia' : 'Próximo campo';
    nextButton.onclick = () => {
      const refreshed = guideCandidates();
      if (step >= refreshed.length - 1) {
        note.remove();
        document.querySelectorAll('.mage-step-focus').forEach(el=>el.classList.remove('mage-step-focus'));
        status('Guia concluído. Revise a ficha e clique em ' + (isCreate ? 'Criar Mago' : 'Salvar ficha') + '.');
      } else showStep(step + 1);
    };
    document.getElementById('mage-prev').onclick = () => showStep(step - 1);
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
      const spentAttributePoints = pointBuyTotal(baseAttributes);
      if (spentAttributePoints !== 25) throw new Error('Distribua exatamente os 25 pontos de compra de atributos antes de criar a ficha. Você usou ' + spentAttributePoints + '/25.');
      const choices = wizardChoices();
      const selectedSpells = collectFirstCircleSpells();
      const finalInt = Number(baseAttributes.INT) + Number((raceData.ajustes_atributos || {}).INT || 0);
      const expectedSpells = Math.max(3,3+Math.floor((finalInt-10)/2));
      if (selectedSpells.length !== expectedSpells) throw new Error('Com Inteligência final ' + finalInt + ', escolha exatamente ' + expectedSpells + ' magias de 1º círculo. Você informou ' + selectedSpells.length + '.');
      const skills = collectSkills();
      const feats = collectFeats();
      addWizardBonusFeatToSheet();
      const languages = splitLanguages();
      const equipment = collectEquipment();
      const money = collectMoney();
      updateEquipmentWeight(equipment);
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
        wizard_familiar_available: true,
        wizard_familiar_choice: selectedFamiliar ? 'selected' : 'pending',
        wizard_familiar_id: selectedFamiliar ? selectedFamiliar.id : null,
        wizard_familiar_name: selectedFamiliar ? selectedFamiliar.nome : null,
        moedas: money,
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
      localStorage.removeItem(localDraftKey());
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
      if (selectedFamiliar) { identity.wizard_familiar_choice = 'selected'; identity.wizard_familiar_id = selectedFamiliar.id; identity.wizard_familiar_name = familiarLabel(selectedFamiliar); }
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
    sb = window.supabase.createClient(SUPABASE_URL, KEY);
    // Preserve a ficha visível durante a inicialização. Um estado de auth ainda
    // não hidratado não pode disparar redirecionamento e desmontar a ficha.
    const sessionResult = await sb.auth.getSession();
    if (sessionResult.error) throw new Error('Não foi possível recuperar sua sessão: ' + sessionResult.error.message);
    let authenticatedUser = sessionResult.data && sessionResult.data.session && sessionResult.data.session.user;
    if (!authenticatedUser) {
      const auth = await sb.auth.getUser();
      if (auth.error) throw new Error('Falha ao validar sua sessão: ' + auth.error.message);
      authenticatedUser = auth.data && auth.data.user;
    }
    if (!authenticatedUser) throw new Error('Sua sessão não foi encontrada nesta aba. A ficha foi mantida aberta; entre novamente pelo Lobby sem fechar sua sessão.');
    user = authenticatedUser;
    addToolbar();
    ensureCatalogOverlays();
    bindCatalogTriggers();
    document.addEventListener('keydown',event=>{if(event.key==='Escape'){closeLore();closeCatalog();}});
    if (isCreate) {
      if (!raceId || !classId) throw new Error('A criação precisa receber raça e classe escolhidas no Lobby.');
      const [race, klass, profile] = await Promise.all([
        sb.from('srd_races').select('*').eq('id', raceId).maybeSingle(),
        sb.from('srd_classes').select('id,nome,class_key,pericias_por_nivel,pericias_classe,dados_tecnicos').eq('id', classId).maybeSingle(),
        sb.from('profiles').select('username').eq('id', user.id).maybeSingle()
      ]);
      if (race.error || klass.error) throw race.error || klass.error;
      if (!race.data || !klass.data || klass.data.class_key !== 'wizard') throw new Error('A ficha original nova está habilitada exclusivamente para a classe Mago.');
      raceData = race.data;
      classData = klass.data;
      await loadCatalogs();
      core.applyIdentity({ raceName: raceData.nome, playerName: profile.data?.username || user.email?.split('@')[0] || '' });
      applyRacePresentation(raceData,profile.data);
      setupIdentityChoices();
      showFamiliarStatus({wizard_familiar_available:true,wizard_familiar_choice:'pending'});
      setupWizardChoiceFields(null);
      renderSpellInputs();
      const draftRestored=restoreLocalDraft();
      initializeCreationDefaults(draftRestored);
      bindLocalDraftAutosave();
    } else if (characterId) {
      const result = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
      if (result.error) throw result.error;
      if (!result.data) throw new Error('Ficha não encontrada ou sem permissão de leitura.');
      const identity = result.data.identidade && typeof result.data.identidade === 'object' ? result.data.identidade : {};
      await loadCatalogs();
      selectedFamiliar = identity.wizard_familiar_id ? (monsterCatalog.find(item=>item.id===identity.wizard_familiar_id) || null) : null;
      setupWizardChoiceFields(identity);
      renderSpellInputs();
      core.hydrate(identity.ficha_mago_v2 || identity.ficha_original_v1);
      lockWizardBonusFeatField();
      showFamiliarStatus(identity);
      status('Ficha carregada. Edite os campos e salve quando terminar.');
    } else {
      throw new Error('Abra a ficha a partir do Lobby ou da Mesa.');
    }
    if (isCreate) showStep(0);
  }
  function reportBootstrapError(error) {
    const message = error && error.message ? error.message : String(error || 'Erro desconhecido');
    let node = document.getElementById('mage-sheet-bootstrap-error');
    if (!node) {
      node = document.createElement('div');
      node.id = 'mage-sheet-bootstrap-error';
      node.setAttribute('role', 'alert');
      node.style.cssText = 'position:sticky;top:0;z-index:10020;margin:12px auto;padding:12px 16px;max-width:1200px;background:#4a1712;color:#fff0dc;border:2px solid #d49a62;font:16px Georgia,serif;white-space:normal';
      const sheet = document.querySelector('.ficha');
      if (sheet) sheet.insertBefore(node, sheet.firstChild);
      else document.body.insertBefore(node, document.body.firstChild);
    }
    node.textContent = 'Não foi possível inicializar a ficha: ' + message + ' — recarregue a página; se persistir, informe esta mensagem ao suporte.';
    const statusNode = document.getElementById('mage-sheet-status');
    if (statusNode) status(message, true);
  }
  function bootMageSheet() {
    init().catch(reportBootstrapError);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bootMageSheet, { once: true });
  else bootMageSheet();
})();
