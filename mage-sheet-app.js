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
    ['abjuration','Abjuração','Proteção, bloqueios, dissipação e defesa contra efeitos mágicos.'],
    ['conjuration','Conjuração','Cria ou invoca criaturas, objetos e energia; também permite teletransportar.'],
    ['divination','Adivinhação','Revela informações, detecta presenças e ajuda a descobrir o que está oculto.'],
    ['enchantment','Encantamento','Afeta a mente e as emoções, influenciando ou controlando criaturas.'],
    ['evocation','Evocação','Manipula energia para produzir fogo, frio, eletricidade, força e outros efeitos.'],
    ['illusion','Ilusão','Cria imagens, sons e sensações falsas para enganar os sentidos ou a mente.'],
    ['necromancy','Necromancia','Lida com vida, morte, energia vital e efeitos ligados aos mortos-vivos.'],
    ['transmutation','Transmutação','Altera propriedades de criaturas, objetos e matéria.']
  ];
  // Guia dinâmico: percorre os campos editáveis reais da ficha, sem etapas fixas.
  let sb, user, step = 0, raceData = null, classData = null, skillCatalog = [], featCatalog = [], spellCatalog = [], monsterCatalog = [], selectedFamiliar = null, catalogMode = null, pendingFeatSelections = null, spellCatalogTab = 'schools';
  let activeFeatCategory = 'todos';
  const normalize = value => String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
  const clean = node => (node && node.textContent || '').replace(/\s+/g, ' ').trim();
  // A ficha conserva alguns nomes tradicionais/abreviados; estes aliases ligam-nos ao catálogo SRD.
  const skillGuideAliases = {
    'blefar': 'blefe',
    'oficios': 'oficio',
    'furtividade': 'mover se silenciosamente',
    'identificar magias': 'identificar magia'
  };
  function findGuideSkill(label) {
    const visibleName = normalize(String(label || '').replace(/\*/g, ' '));
    const catalogName = skillGuideAliases[visibleName] || visibleName;
    return skillCatalog.find(entry => normalize(entry.nome) === catalogName) || null;
  }

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
    bar.innerHTML = '<div class="mage-sheet-meta"><strong>FICHA DO MAGO · D&D 3.5</strong><span id="mage-sheet-status" role="status" aria-live="polite">Preparando ficha…</span></div>';
    const style = document.createElement('style');
    style.textContent = '#mage-sheet-toolbar{position:relative;z-index:20;display:flex;gap:12px;align-items:center;justify-content:center;flex-wrap:wrap;padding:10px 16px;width:min(760px,calc(100% - 28px));margin:0 auto 22px;background:linear-gradient(135deg,rgba(246,237,215,.94),rgba(226,210,174,.94));color:#49351f;border:1px solid rgba(139,111,71,.48);border-radius:12px;box-shadow:0 5px 18px rgba(48,31,13,.10);font:13px Georgia,serif}#mage-sheet-toolbar .mage-sheet-meta{display:flex;flex-direction:column;gap:3px;flex:1;min-width:180px;text-align:center}#mage-sheet-status{color:#806747;font-size:12px}#mage-sheet-status[data-error=true]{color:#ff9b8f}#mage-sheet-toolbar .mage-sheet-actions{display:flex;gap:8px;flex-wrap:wrap}#mage-sheet-toolbar button{padding:7px 12px;border:1px solid rgba(139,111,71,.48);background:rgba(255,250,238,.78);color:#594126;border-radius:999px;cursor:pointer;font:600 12px Georgia,serif;transition:background .18s,transform .18s}#mage-sheet-toolbar button:hover{background:#fff8e9;transform:translateY(-1px)}#mage-sheet-toolbar #mage-save{background:#594126;color:#fff3d7;border-color:#594126}#mage-sheet-toolbar button:disabled{opacity:.45;cursor:not-allowed}.mage-class-feature-note{margin:6px 0 10px;padding:7px 10px;border-left:2px solid #b08d57;color:#6f5738;background:#f3ead7;font:12px Georgia,serif}.mage-step-focus{outline:2px solid rgba(176,141,87,.72)!important;outline-offset:3px;box-shadow:0 0 0 5px rgba(176,141,87,.12)!important;position:relative;z-index:2;border-radius:5px}.mage-step-note{position:fixed;left:16px;top:16px;bottom:16px;transform:none;z-index:10002;width:244px;max-height:none;overflow:auto;box-sizing:border-box;padding:14px 13px;background:linear-gradient(145deg,rgba(249,242,225,.985),rgba(231,216,185,.985));color:#49351f;border:1px solid rgba(139,111,71,.58);border-radius:16px;box-shadow:0 16px 48px rgba(25,16,7,.24);font:15px/1.5 Georgia,serif;text-align:center;backdrop-filter:blur(10px)}.mage-guide-actions{display:flex;justify-content:center;align-items:center;gap:9px;flex-wrap:wrap;margin-top:15px;padding-top:13px;border-top:1px solid rgba(139,111,71,.24)}.mage-guide-actions button{padding:8px 15px;border:1px solid rgba(139,111,71,.55);border-radius:999px;background:rgba(255,250,238,.78);color:#594126;cursor:pointer;font:600 12px Georgia,serif}.mage-guide-actions button:disabled{opacity:.35;cursor:not-allowed}.mage-guide-actions #mage-save{background:#594126;color:#fff3d7;border-color:#594126}.mage-guide-actions button:hover:not(:disabled){filter:brightness(1.04);transform:translateY(-1px)}.mage-step-note strong{display:block;font:700 17px Cinzel,Georgia,serif;color:#382514;margin:2px 0 5px}.mage-step-note .mage-guide-progress{height:3px;background:rgba(139,111,71,.18);border-radius:5px;overflow:hidden;margin:9px 0 0}.mage-step-note .mage-guide-progress span{display:block;height:100%;background:#a47d45;border-radius:5px}.mage-choice-panel{margin:12px 0 16px;padding:10px 12px;border:1px solid rgba(139,111,71,.65);background:rgba(255,255,255,.28);font:13px Georgia,serif;color:#2b1a0e}.mage-choice-panel label{font-family:Cinzel,serif;font-size:9px;font-weight:700;display:block;margin-bottom:4px}.mage-choice-panel select{width:100%;padding:6px;background:rgba(255,255,255,.65);border:1px solid #8b6f47;color:#2b1a0e}.mage-school-choices{display:flex;gap:8px 14px;flex-wrap:wrap;margin-top:8px}.mage-school-choices label{display:flex;align-items:center;gap:5px;font-family:Georgia,serif;font-size:12px;font-weight:400}.mage-school-choices input{accent-color:#8b6f47}.mage-choice-help{font-size:11px;margin-top:6px;color:#5a3f28}';
    
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
      '@media(max-width:650px){#mage-sheet-toolbar{width:calc(100% - 20px);padding:10px;margin:0 auto 16px;gap:8px}#mage-sheet-toolbar .mage-sheet-meta{flex-basis:100%}#mage-sheet-toolbar .mage-sheet-actions{justify-content:center}.mage-step-note{width:calc(100vw - 24px);padding:16px 15px;font-size:14px}.mage-step-note strong{font-size:16px}.mage-guide-actions{gap:7px}.mage-guide-actions button{padding:8px 12px}.mage-catalog-row{grid-template-columns:38px minmax(0,1fr) 112px}.mage-spell-catalog-row{grid-template-columns:38px minmax(0,1fr) 48px}.mage-catalog-choose{padding:6px 5px;font-size:9px}.mage-skill-budget{font-size:8px}}' +
      '.mage-catalog-content{display:flex;flex:1;min-height:0;gap:22px;overflow:hidden}' +
      '.mage-feat-categories{display:none;flex:0 0 190px;flex-direction:column;align-items:stretch;gap:13px;overflow:auto;padding:8px 8px 12px 2px;margin:0;border:0}' +
      '.mage-feat-categories.ativo{display:flex}' +
      '.mage-feat-category{display:block;width:100%;flex:0 0 auto;padding:5px 2px;border:0;background:transparent;color:#684d2e;text-align:left;cursor:pointer;font:700 13px Cinzel,Georgia,serif;letter-spacing:.35px;line-height:1.45;transition:color .2s,text-shadow .2s,filter .2s}' +
      '.mage-feat-category:hover{color:#3d2812;text-shadow:0 0 7px rgba(190,143,69,.48)}' +
      '.mage-feat-category.ativo{color:#2b1808;text-shadow:0 0 5px #fff1c4,0 0 10px rgba(211,158,67,.98),0 0 19px rgba(190,128,36,.9);filter:brightness(1.12)}' +
      '.mage-feat-category:focus-visible{outline:1px dotted #8b5e24;outline-offset:3px}' +
      '.mage-catalog-content .mage-catalog-list{flex:1;min-width:0;min-height:0}' +
      '@media(max-width:650px){.mage-catalog-content{gap:12px}.mage-feat-categories{flex-basis:142px;gap:11px}.mage-feat-category{font-size:11px}}'
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

    style.textContent += '\n' +
      '.mage-school-card,.mage-prep-row{border:1px solid rgba(139,111,71,.72);border-radius:8px;background:linear-gradient(115deg,rgba(255,249,232,.94),rgba(231,215,181,.88));color:#49331f;box-shadow:inset 0 0 0 1px rgba(255,255,255,.42);transition:border-color .2s,box-shadow .2s,background .2s,transform .2s}' +
      '.mage-school-card h3,.mage-prep-row strong{color:#593b20}.mage-school-card p,.mage-prep-row small{color:#684f34}' +
      '.mage-school-card.selected,.mage-school-card.mage-feat-selected-row,.mage-prep-row.mage-feat-selected-row{border:2px solid #b58a42!important;background:linear-gradient(110deg,rgba(244,224,177,.98),rgba(255,249,231,.98))!important;box-shadow:0 0 0 2px rgba(181,138,66,.22),0 0 17px rgba(190,143,69,.42),inset 0 0 14px rgba(181,138,66,.18)!important}' +
      '.mage-school-card.selected h3,.mage-prep-row.mage-feat-selected-row strong{color:#4a2e13;text-shadow:0 0 7px rgba(190,143,69,.22)}' +
      '.mage-school-progress{background:linear-gradient(110deg,rgba(250,241,219,.97),rgba(232,215,180,.94));border-color:#9c7945;color:#5b4025}' +
      '.mage-spell-tabs{background:linear-gradient(110deg,#4d3925,#2c2015);border-color:#9b7844}.mage-spell-tab{background:linear-gradient(135deg,#6b4b2c,#4b321d);border-color:#a7834e;color:#f6e6c7}.mage-spell-tab.ativo{background:linear-gradient(135deg,#b58a42,#765126);border-color:#f0d18b;color:#fff8e8;box-shadow:0 0 0 1px rgba(240,209,139,.38),0 0 16px rgba(190,143,69,.42)}' +
      '.mage-school-actions button{background:linear-gradient(135deg,#76532e,#4d321b);border-color:#a7834e;color:#fff0d0}.mage-school-actions button.active{background:linear-gradient(135deg,#b58a42,#765126);border-color:#e8c77e;color:#fff8e8;box-shadow:0 0 10px rgba(190,143,69,.38)}' +
      '.mage-prep-toggle{background:linear-gradient(135deg,#76532e,#4d321b);border-color:#a7834e;color:#fff0d0}.mage-prep-toggle.active{background:linear-gradient(135deg,#b58a42,#765126);border-color:#e8c77e;color:#fff8e8;box-shadow:0 0 10px rgba(190,143,69,.42)}' +
      '.mage-feat-selected-row{border:2px solid #b58a42!important;border-radius:7px;background:linear-gradient(90deg,rgba(211,174,103,.22),rgba(255,248,226,.5));box-shadow:0 0 0 2px rgba(181,138,66,.18),inset 0 0 12px rgba(181,138,66,.10);padding:3px!important}' +
      '.mage-feat-selected-row input:first-child{border-color:#a77a34!important;background:rgba(255,246,218,.92)!important;font-weight:700}' +
      '.mage-feat-unavailable{opacity:.43;filter:grayscale(.72)}.mage-feat-unavailable .mage-catalog-choose{cursor:not-allowed;opacity:.6}' +
      '.mage-feat-counter{position:sticky;top:0;z-index:2;padding:9px 11px;margin-bottom:5px;background:rgba(250,242,222,.97);border:1px solid rgba(139,111,71,.65);color:#594126;font:700 12px Georgia,serif;text-align:center}' +
      '.mage-guide-catalog-button{display:block;margin:12px auto 4px;padding:10px 18px;border:1px solid #8b6f47;border-radius:999px;background:linear-gradient(135deg,#74532d,#4a321b);color:#fff2d2;font:700 12px Cinzel,Georgia,serif;letter-spacing:.04em;cursor:pointer}.mage-guide-catalog-button:hover{filter:brightness(1.12);transform:translateY(-1px)}' +
      '.mage-feat-selected-row{border:1px solid #b58a42!important;background:linear-gradient(90deg,rgba(211,174,103,.24),rgba(255,248,226,.55));box-shadow:0 0 0 2px rgba(181,138,66,.22),0 0 14px rgba(181,138,66,.22)}.mage-feat-save-wrap{display:flex;justify-content:flex-end;position:sticky;bottom:0;padding:9px 2px 3px;background:linear-gradient(0deg,#d7c093 75%,rgba(215,192,147,0))}.mage-feat-save{padding:6px 12px;border:1px solid rgba(109,79,42,.55);border-radius:14px;background:rgba(89,65,38,.9);color:#fff2d2;font:600 10px Georgia,serif;letter-spacing:.03em;cursor:pointer;opacity:.9}.mage-feat-save:hover{opacity:1;filter:brightness(1.08)}';
    document.head.appendChild(style);
    const sheet = document.querySelector('.ficha');
    if (!sheet) throw new Error('O modelo original da ficha não foi encontrado.');
    sheet.insertBefore(bar, sheet.firstChild);
  }
  function labeledInput(panelTitle, labelText) {
    const p = panel(panelTitle);
    if (!p) return null;
    const target = normalize(labelText);
    const label = Array.from(p.querySelectorAll('label')).find(el => normalize(clean(el)) === target);
    return label && label.parentElement ? label.parentElement.querySelector('input,textarea,select') : null;
  }
  function schoolLabel(key) {
    const raw=normalize(key),found=schools.find(s=>s[0]===raw||normalize(s[1])===raw||raw.startsWith(s[0]+' ')||raw.startsWith(normalize(s[1])+' '));
    return found?found[1]:key;
  }
  function spellSchoolKey(value) {
    const raw=normalize(value),found=schools.find(s=>raw.startsWith(s[0])||raw.startsWith(normalize(s[1])));
    return found?found[0]:'';
  }
  function wizardSpell(spell) { return Array.isArray(spell.classes)&&spell.classes.includes('wizard'); }
  function wizardLevel() { const value=Number(groupValue('Nível')||1);return Math.max(1,Math.min(20,Number.isFinite(value)?value:1)); }
  function wizardMaxCircle() { return Math.min(9,Math.ceil(wizardLevel()/2)); }
  function uniqueSpellCatalog(items) {
    const map=new Map();
    items.forEach(spell=>{
      const key=normalize(spell.nome_pt||spell.nome)+'|'+wizardSpellCircle(spell),current=map.get(key);
      if(!current||(!wizardSpell(current)&&wizardSpell(spell)))map.set(key,spell);
      else if(wizardSpell(current)===wizardSpell(spell))map.set(key,choosePreferredSpell([current,spell]));
    });
    return Array.from(map.values()).sort((a,b)=>String(a.nome_pt||a.nome).localeCompare(String(b.nome_pt||b.nome),'pt-BR'));
  }
  function wizardSpellCircle(spell) {
    const match=String(spell.nivel||'').match(/(?:Sor\/)?Wiz\s+(\d+)/i);
    return match?Number(match[1]):Number(spell.circulo);
  }
  function spellEligibility(spell) {
    const reasons=[];
    if(!wizardSpell(spell))reasons.push('Não pertence à lista de Mago.');
    const school=spellSchoolKey(spell.escola);
    if(school&&selectedProhibitedSchools().includes(school))reasons.push('Pertence a uma escola proibida.');
    if(wizardSpellCircle(spell)>wizardMaxCircle())reasons.push('Seu nível atual ainda não permite este círculo.');
    return {eligible:reasons.length===0,reasons};
  }
  function wizardSpecialization() { return specializationKey(labeledInput('Magia','Especialização em Escola')?.value || ''); }
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
    if (identity && identity.wizard_specialization) specialization.value = schoolLabel(identity.wizard_specialization);
    if (identity && Array.isArray(identity.wizard_prohibited_schools)) prohibited.value = identity.wizard_prohibited_schools.map(schoolLabel).join(', ');
    specialization.readOnly=true;prohibited.readOnly=true;
    specialization.placeholder='Escolha no catálogo de escolas';prohibited.placeholder='Definidas no catálogo de escolas';
  }
  function wizardChoices() {
    const specializationInput = labeledInput('Magia','Especialização em Escola');
    const prohibitedInput = labeledInput('Magia','Escolas Proibidas');
    const specialization = specializationKey(specializationInput && specializationInput.value);
    if (!specialization) throw new Error('Escolha uma escola de especialização ou Universalista no catálogo de escolas.');
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
    return uniqueSpellCatalog(spellCatalog.filter(sp=>wizardSpell(sp)&&wizardSpellCircle(sp)===circle&&!prohibited.includes(spellSchoolKey(sp.escola))));
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
          if (check) { if (isCreate) check.checked = false; check.disabled = false; }
          row.hidden = !spells[index];
        });
      } else if (circle === 1) {
        const allowed = allowedSpells(1);
        const datalistId = ensureDatalist('mage-spell-list-level-1', allowed);
        list.querySelectorAll('input[type="text"]').forEach(input => { input.setAttribute('list', datalistId); input.readOnly = false; });
        if (isCreate) { list.querySelectorAll('input[type="checkbox"]').forEach(el => { el.checked = false; el.disabled = false; }); }
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
      input.disabled=false;input.title='Marque para deixar esta magia preparada. A preparação é livre e não controla limites diários.';
    });
    const magicPanel = panel('Magia');
    const magicRows = magicPanel && magicPanel.querySelectorAll('table tbody tr');
    if (magicRows && magicRows[1]) {
      magicRows[1].querySelectorAll('input').forEach(input => {
        if (isCreate) input.value = '';
        input.disabled = true;
      });
    }
    updateMagicKnownCounts();
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
    const matches = spellCatalog.filter(sp => wizardSpell(sp) && wizardSpellCircle(sp) === circle &&
      [sp.nome_pt,sp.nome].some(label => normalize(label) === key));
    if (!matches.length) throw new Error('A magia "' + name + '" não foi encontrada no catálogo de magias do Mago para o círculo ' + circle + '.');
    const spell=choosePreferredSpell(matches);
    if(selectedProhibitedSchools().includes(spellSchoolKey(spell.escola)))throw new Error('A magia "'+name+'" pertence a uma escola proibida para este Mago.');
    return spell.id;
  }
  function validateSpellbookEntries() {
    spellRows().forEach(row=>{
      if(!row.spell)throw new Error('A magia "'+row.name+'" não foi encontrada no catálogo. Escolha-a novamente pelo Grimório.');
      const result=spellEligibility(row.spell);
      if(!result.eligible)throw new Error('A magia "'+row.name+'" não pode permanecer no Grimório: '+result.reasons.join(' '));
    });
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
      const eligibility = featEligibility(feat);
      if (!eligibility.eligible) throw new Error('O talento "' + name + '" não atende aos pré-requisitos: ' + eligibility.reasons.join(' '));
      const entry = { id: feat.id };
      if (feat.exige_parametro) {
        const parameter = window.prompt('O talento "' + (feat.nome_pt || feat.nome) + '" exige uma escolha. Informe o parâmetro:');
        if (!parameter || !parameter.trim()) throw new Error('Informe o parâmetro exigido pelo talento ' + (feat.nome_pt || feat.nome) + '.');
        entry.parametro = parameter.trim();
      }
      if (feat.id === 'srd35_feat_scribe_scroll') throw new Error('Escrever Pergaminho é talento bônus automático do Mago de 1º nível; escolha outro talento geral.');
      selected.push(entry);
    }
    const expected = allowedGeneralFeatSlots();
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
    if (!p) return;
    const title = p.querySelector('.panel-title');
    if (!title) return;
    let note = p.querySelector('.mage-class-feature-note');
    if (!note) {
      note = document.createElement('div');
      note.className = 'mage-class-feature-note';
      note.textContent = 'Invocar Familiar · habilidade de classe do Mago. Escolha no catálogo qual criatura acompanhará o personagem; a invocação acontece conforme a narrativa.';
      title.insertAdjacentElement('afterend',note);
    }
    if (note.querySelector('.mage-guide-catalog-button')) return;
    const button = createNode('button','mage-guide-catalog-button','Abrir catálogo de familiares');
    button.type = 'button';
    button.addEventListener('click',()=>openCatalog('familiar'));
    note.appendChild(button);
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
      const tr = labeledInput('Magia','CD base das magias');
      const dcMod = labeledInput('Magia','Mod. CD');
      const failure = labeledInput('Magia','Falha Arcana');
      if (tr) tr.value = String(10 + intMod);
      if (dcMod) dcMod.value = String(intMod);
      if (failure) { failure.value = '—'; failure.readOnly = true; failure.title = 'Depende da armadura e do escudo equipados; ainda não há cálculo conectado neste painel.'; }
      const rows = magic.querySelectorAll('table tbody tr');
      if (isCreate && rows[1]) rows[1].querySelectorAll('input').forEach(input => { input.value = ''; input.disabled = true; });
      const knownCells = rows[0] ? rows[0].querySelectorAll('td') : [];
      const spellBlocks = Array.from(document.querySelectorAll('.spell-level-block'));
      for (let circle=0;circle<=9;circle++) {
        const input = knownCells[circle+1]?.querySelector('input');
        const block = spellBlocks[circle];
        const actualCount = block ? Array.from(block.querySelectorAll('.spell-list input[type="text"]')).filter(field => String(field.value || '').trim()).length : 0;
        if (input) { input.value = String(actualCount); input.readOnly = true; }
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
    const allowed = allowedSpells(1);
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
    ensureSpellCatalogStyles();
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
      const tabs = createNode('nav','mage-spell-tabs'); tabs.id='mage-spell-tabs'; tabs.setAttribute('aria-label','Etapas do Grimório');
      const tools = createNode('div','mage-catalog-tools');
      const search = createNode('input');
      search.id = 'mage-catalog-search';
      search.type = 'search';
      search.placeholder = 'Pesquisar no catálogo…';
      search.addEventListener('input',renderCatalogList);
      tools.appendChild(search);
      const content = createNode('div','mage-catalog-content');
      const categories = createNode('nav','mage-feat-categories');
      categories.id = 'mage-feat-categories';
      categories.setAttribute('aria-label','Categorias de talentos');
      const list = createNode('div','mage-catalog-list');
      list.id = 'mage-catalog-list';
      content.append(categories,list);
      shell.append(head,tabs,tools,content);
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
  function currentFeatAbilityScores() {
    const values = {};
    const p = panel('Atributos');
    if (!p) return values;
    p.querySelectorAll('.attr-row').forEach(row => {
      const key = clean(row.querySelector('.attr-name'));
      const input = row.querySelector('.attr-col input');
      const score = Number(input && input.value);
      if (key && Number.isFinite(score)) values[key] = score;
    });
    return values;
  }
  function currentFeatSkillRanks() {
    const values = {};
    const p = panel('Perícias');
    if (!p) return values;
    p.querySelectorAll('tbody tr').forEach(row => {
      const cells = Array.from(row.children);
      const name = normalize(clean(cells[0]).replace(/\\*/g,''));
      const ranks = Number(cells[4]?.querySelector('input')?.value || 0);
      if (name) values[name] = ranks;
    });
    return values;
  }
  function classGrantedFeatIds() {
    // O Mago recebe Escrever Pergaminho como talento bônus no 1º nível.
    return classData?.class_key === 'wizard' ? ['srd35_feat_scribe_scroll'] : [];
  }
  function featEligibility(feat) {
    const req = feat?.requisitos && typeof feat.requisitos === 'object' ? feat.requisitos : {};
    const reasons = [];
    const scores = currentFeatAbilityScores();
    const abilityLabels = {FOR:'FOR',DES:'DES',CON:'CON',INT:'INT',SAB:'SAB',CAR:'CAR'};
    const abilityKeys = {for_min:'FOR',des_min:'DES',con_min:'CON',int_min:'INT',sab_min:'SAB',car_min:'CAR'};
    Object.entries(abilityKeys).forEach(([key,stat]) => {
      if (req[key] !== undefined && Number(scores[stat] || 0) < Number(req[key])) reasons.push(stat+' '+req[key]+' necessário (atual: '+(scores[stat] ?? '—')+').');
    });
    const level = 1;
    const progression = String(classData?.bab_progression || '').toLowerCase();
    const bab = progression === 'poor' ? Math.floor(level / 2) : progression === 'medium' ? Math.floor(level * 0.75) : progression === 'good' ? level : (classData?.bab_bom ? level : 0);
    if (req.bab_min !== undefined && bab < Number(req.bab_min)) reasons.push('BBA +'+req.bab_min+' necessário (atual: +'+bab+').');
    if (req.level_min !== undefined && level < Number(req.level_min)) reasons.push('Nível '+req.level_min+' necessário.');
    if (req.character_level_min !== undefined && level < Number(req.character_level_min)) reasons.push('Nível de personagem '+req.character_level_min+' necessário.');
    if (req.class_level_min !== undefined && level < Number(req.class_level_min)) reasons.push('Nível '+req.class_level_min+' na classe '+(req.class_key_required || 'exigida')+' necessário.');
    if (req.class_key_required && classData?.class_key !== req.class_key_required) reasons.push('Exige a classe '+req.class_key_required+'.');
    if (req.caster_level_min !== undefined) {
      const casterLevel = classData?.class_key === 'wizard' ? level : 0;
      if (casterLevel < Number(req.caster_level_min)) reasons.push('Nível de conjurador '+req.caster_level_min+' necessário (atual: '+casterLevel+').');
    }
    const existingFeatIds = new Set(classGrantedFeatIds());
    if (Array.isArray(req.feat_ids)) {
      req.feat_ids.forEach(id => {
        if (!existingFeatIds.has(id)) {
          const prerequisite = featCatalog.find(item => item.id === id);
          reasons.push('Pré-requisito: '+(prerequisite?.nome_pt || prerequisite?.nome || id)+'.');
        }
      });
    }
    if (req.skill_ranks && typeof req.skill_ranks === 'object') {
      const ranks = currentFeatSkillRanks();
      Object.entries(req.skill_ranks).forEach(([skill,minimum]) => {
        const key = normalize(skill).replace(/_/g,' ');
        const actual = Number(ranks[key] || 0);
        if (actual < Number(minimum)) reasons.push('Graduação '+minimum+' em '+skill+' necessária (atual: '+actual+').');
      });
    }
    if (req.special_ability_required) {
      const abilities = {
        familiar: classData?.class_key === 'wizard',
        turn_or_rebuke_creatures: false,
        wild_shape: false
      };
      if (!abilities[req.special_ability_required]) reasons.push('A habilidade especial exigida não é concedida pela raça/classe escolhida.');
    }
    if (req.weapon_proficiency_required) {
      const exotic = req.parameter_type === 'weapon_exotic';
      const dwarfWaraxe = raceId === 'anao' || raceId === 'anão';
      if (exotic && !dwarfWaraxe) reasons.push('É necessário possuir proficiência com a arma exótica escolhida.');
      else if (exotic) reasons.push('A proficiência depende da arma específica escolhida; confirme-a antes de selecionar.');
    }
    if (req.feat_parameter_matches?.length) reasons.push('É necessário possuir o talento pré-requisito com o mesmo parâmetro escolhido.');
    if (req.dynamic_prerequisites) reasons.push('Pré-requisitos adicionais dependem de escolhas que esta ficha ainda não registra.');
    if (req.conditional_ability_min && req.parameter_type) {
      reasons.push('O requisito de atributo depende do parâmetro/arma escolhida.');
    }
    const knownKeys = new Set([
      'raw','type','audit_status','source_url','source_url_primary','official_catalog_index',
      'feat_ids','for_min','des_min','con_min','int_min','sab_min','car_min','bab_min',
      'level_min','character_level_min','class_level_min','class_key_required','caster_level_min',
      'skill_ranks','special_ability_required','weapon_proficiency_required','parameter_type',
      'conditional_ability_min','dynamic_prerequisites','feat_parameter_matches','feat_parameters',
      'repeatable','repeatable_mode'
    ]);
    const unsupported = Object.keys(req).filter(key => !knownKeys.has(key));
    if (unsupported.length) reasons.push('O catálogo contém requisito ainda não interpretado: '+unsupported.join(', ')+'.');
    const hasRaw = Boolean(String(req.raw || '').trim());
    const hasStructuredRule = Object.keys(req).some(key => !['raw','type','audit_status','source_url','source_url_primary','official_catalog_index','repeatable','repeatable_mode','parameter_type','feat_parameters'].includes(key));
    if (hasRaw && !hasStructuredRule && !req.dynamic_prerequisites) reasons.push('O pré-requisito textual ainda não está estruturado para validação automática.');
    return {eligible:reasons.length===0,reasons};
  }
  function featSelectionRows() {
    const p = panel('Talentos');
    return p ? Array.from(p.querySelectorAll('div[style*="grid-template-columns: 1fr 50px"]')).filter(row=>row.querySelectorAll('input').length===2) : [];
  }
  function updateFeatSelectionRows() {
    featSelectionRows().forEach(row => {
      const name = String(row.querySelector('input')?.value || '').trim();
      row.classList.toggle('mage-feat-selected-row',Boolean(name));
      row.querySelectorAll('input').forEach(input => {
        if (name) input.setAttribute('aria-label',input === row.querySelector('input') ? 'Talento selecionado: '+name : 'Referência do talento '+name);
      });
    });
  }
  function selectedGeneralFeatCount() {
    return featSelectionRows().filter(row => {
      const input = row.querySelector('input');
      return String(input?.value || '').trim() && normalize(input.value) !== 'escrever pergaminho';
    }).length;
  }
  function allowedGeneralFeatSlots() {
    return raceId === 'humano' ? 2 : 1;
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
  const featCategoryDefinitions = [
    {id:'todos',name:'Todos os talentos'},
    {id:'combate',name:'Combate'},
    {id:'defesa',name:'Defesa'},
    {id:'manobras',name:'Manobras e mobilidade'},
    {id:'magia',name:'Magia'},
    {id:'itens',name:'Criação de itens'},
    {id:'pericias',name:'Perícias'},
    {id:'lideranca',name:'Liderança e aliados'},
    {id:'outros',name:'Outros'}
  ];
  function featCategoryId(feat) {
    const text = normalize([feat.nome_pt,feat.nome,feat.descricao_pt,feat.descricao,feat.requisitos?.raw].filter(Boolean).join(' '));
    const has = pattern => pattern.test(text);
    if (has(/fabricar|criar|criacao|confeccionar|item magico|itens magicos|pergaminho|varinha|pocao|arma magica|armadura magica/)) return 'itens';
    if (has(/magia|magico|magica|conjur|feitic|escola de magia|resistencia a magia|foco em magia|penetracao de magia|metamag|sortilegio/)) return 'magia';
    if (has(/lideranca|seguidores|aliados|companheiro|familiar|montaria|coorte|recrutar/)) return 'lideranca';
    if (has(/pericia|pericias|perito|habilidade|conhecimento|oficio|artesanato|diplomacia|blefar|furtividade|sentir motivacao|usar instrumento magico/)) return 'pericias';
    if (has(/esquiva|defesa|defensiv|bloqueio|aparar|escudo|fortitude|resistencia|vitalidade|robustez|casco|pele de ferro|reducao de dano/)) return 'defesa';
    if (has(/iniciativa|reflexos de combate|ataque|combate|arma|tiro|disparo|arco|luta|golpe|critico|sucesso decisivo|especializacao|proficiência|proficiencia|foco em arma|trespassar|combater com duas armas|ataque poderoso/)) return 'combate';
    if (has(/manobra|agarrar|derrubar|desarmar|empurrar|imobilizar|investida|corrida|salto|acrobacia|movimento|mobilidade|montado|carga|voo/)) return 'manobras';
    return 'outros';
  }
  function renderFeatCategories() {
    const nav = document.getElementById('mage-feat-categories');
    if (!nav) return;
    nav.replaceChildren();
    nav.classList.toggle('ativo',catalogMode==='feats');
    if (catalogMode!=='feats') return;
    featCategoryDefinitions.forEach(category=>{
      const button=createNode('button','mage-feat-category'+(activeFeatCategory===category.id?' ativo':''),category.name);
      button.type='button';
      button.dataset.category=category.id;
      button.setAttribute('aria-pressed',activeFeatCategory===category.id?'true':'false');
      button.addEventListener('click',()=>{
        activeFeatCategory=category.id;
        renderCatalogList();
      });
      nav.appendChild(button);
    });
  }
  function ensureSpellCatalogStyles() {
    if(document.getElementById('mage-spell-catalog-styles'))return;
    const style=createNode('style');style.id='mage-spell-catalog-styles';
    style.textContent='.mage-catalog-backdrop{background:radial-gradient(ellipse at center,rgba(74,52,29,.48),rgba(16,11,7,.88));backdrop-filter:blur(16px) saturate(.72);-webkit-backdrop-filter:blur(16px) saturate(.72)}.mage-spell-tabs{display:none;gap:7px;margin:0 0 12px;padding:7px;border:1px solid #9b7844;background:linear-gradient(110deg,#4d3925,#2c2015);border-radius:9px}.mage-spell-tabs.ativo{display:flex}.mage-spell-tab{flex:1;min-width:0;padding:10px 7px;border:1px solid #a7834e;border-radius:7px;background:linear-gradient(135deg,#76532e,#4d321b);color:#f6e6c7;font:700 10px Cinzel,serif;cursor:pointer;transition:all .2s}.mage-spell-tab.ativo{border-color:#f0d18b;background:linear-gradient(145deg,#b58a42,#765126);color:#fff8e8;box-shadow:0 0 0 1px rgba(240,209,139,.38),0 0 16px rgba(190,143,69,.42)}.mage-school-card,.mage-prep-row{display:flex;align-items:center;justify-content:space-between;gap:12px;padding:13px;margin:7px 0;border:1px solid rgba(139,111,71,.72);border-radius:9px;background:linear-gradient(115deg,rgba(255,249,232,.97),rgba(231,215,181,.94));color:#49331f;box-shadow:inset 0 0 0 1px rgba(255,255,255,.42);transition:border-color .2s,box-shadow .2s,background .2s,transform .2s}.mage-school-card{display:grid;grid-template-columns:minmax(0,1fr) auto}.mage-school-card h3,.mage-prep-row strong{margin:0 0 4px;color:#593b20;font:700 13px Cinzel,serif}.mage-school-card p,.mage-prep-row small{margin:0;color:#684f34;font:13px/1.4 EB Garamond,serif}.mage-school-card.selected,.mage-school-card.mage-feat-selected-row,.mage-prep-row.mage-feat-selected-row,.mage-spell-catalog-row.mage-spell-selected{border:2px solid #b58a42!important;background:linear-gradient(110deg,rgba(244,224,177,.99),rgba(255,249,231,.99))!important;color:#49331f!important;box-shadow:0 0 0 2px rgba(181,138,66,.28),0 0 19px rgba(190,143,69,.52),inset 0 0 15px rgba(181,138,66,.2)!important}.mage-spell-catalog-row.mage-spell-selected .mage-catalog-mark{border-color:#b58a42;background:linear-gradient(145deg,#d8b56e,#fff0c9);box-shadow:0 0 12px rgba(190,143,69,.45)}.mage-spell-catalog-row.mage-spell-selected .mage-catalog-name{color:#4a2e13;text-shadow:0 0 7px rgba(190,143,69,.25)}.mage-school-card.selected h3,.mage-prep-row.mage-feat-selected-row strong{color:#4a2e13;text-shadow:0 0 7px rgba(190,143,69,.22)}.mage-school-actions{display:flex;flex-direction:column;gap:6px;justify-content:center}.mage-school-actions button,.mage-prep-toggle{border:1px solid #a7834e;border-radius:6px;background:linear-gradient(135deg,#76532e,#4d321b);color:#fff0d0;padding:7px 10px;font:700 9px Cinzel,serif;cursor:pointer;transition:all .2s}.mage-school-actions button.active,.mage-prep-toggle.active{background:linear-gradient(135deg,#b58a42,#765126);color:#fff8e8;border-color:#e8c77e;box-shadow:0 0 11px rgba(190,143,69,.48)}.mage-school-actions button:disabled{opacity:.42;cursor:not-allowed}.mage-school-progress{padding:10px 12px;margin:0 0 8px;border:1px solid #9c7945;border-radius:7px;background:linear-gradient(110deg,rgba(250,241,219,.98),rgba(232,215,180,.96));color:#5b4025;font:13px EB Garamond,serif}.mage-catalog-empty{padding:14px;border:1px solid #9c7945;border-radius:8px;background:linear-gradient(110deg,rgba(250,241,219,.98),rgba(232,215,180,.96));color:#5b4025}.mage-spell-unavailable{opacity:.48;filter:grayscale(.7)}.mage-feat-selected-row{border:2px solid #b58a42!important;border-radius:9px;background:linear-gradient(110deg,rgba(244,224,177,.99),rgba(255,249,231,.99))!important;box-shadow:0 0 0 2px rgba(181,138,66,.28),0 0 19px rgba(190,143,69,.52),inset 0 0 15px rgba(181,138,66,.2)!important}.mage-feat-selected-row input:first-child{border-color:#a77a34!important;background:rgba(255,246,218,.92)!important;font-weight:700}.mage-catalog-row.mage-spell-catalog-row{background:linear-gradient(115deg,rgba(255,249,232,.97),rgba(231,215,181,.94));border-color:rgba(139,111,71,.72);border-radius:9px;transition:all .2s}.mage-catalog-row.mage-spell-catalog-row .mage-catalog-meta{color:#684f34}.mage-catalog-row.mage-spell-catalog-row .mage-catalog-mark{background:linear-gradient(145deg,#c4a66d,#eadcb8);border-color:#8b6f47;color:#4b3218}.mage-prep-row{min-height:58px}.mage-prep-toggle{border-radius:20px;padding:8px 13px}.mage-prep-toggle:hover,.mage-school-actions button:hover:not(:disabled){filter:brightness(1.12);box-shadow:0 0 12px rgba(190,143,69,.32)}@media(max-width:600px){.mage-spell-tab{font-size:8px;padding:9px 3px}.mage-school-card{grid-template-columns:1fr}.mage-school-actions{flex-direction:row;flex-wrap:wrap}.mage-prep-row{align-items:flex-start}}';
    document.head.appendChild(style);
  }
  function renderSpellCatalogTabs() {
    const nav=document.getElementById('mage-spell-tabs');if(!nav)return;
    nav.replaceChildren();nav.classList.toggle('ativo',catalogMode==='spells');if(catalogMode!=='spells')return;
    [['schools','1 · ESCOLAS'],['grimoire','2 · GRIMÓRIO'],['prepare','3 · PREPARAÇÃO']].forEach(([id,label])=>{
      const b=createNode('button','mage-spell-tab'+(spellCatalogTab===id?' ativo':''),label);b.type='button';b.setAttribute('aria-pressed',spellCatalogTab===id?'true':'false');b.addEventListener('click',()=>setSpellCatalogTab(id));nav.appendChild(b);
    });
  }
  function setSpellCatalogTab(tab) {
    if(tab!=='schools'){try{wizardChoices();}catch(error){status(error.message,true);spellCatalogTab='schools';renderCatalogList();return;}}
    spellCatalogTab=tab;
    const tools=document.querySelector('#mage-catalog-overlay .mage-catalog-tools'),search=document.getElementById('mage-catalog-search'),level=document.getElementById('mage-catalog-level');
    if(tools)tools.style.display=tab==='schools'?'none':'flex';
    if(search)search.placeholder=tab==='prepare'?'Pesquisar nas magias conhecidas…':'Pesquisar no catálogo de magias…';
    if(level)level.style.display=tab==='grimoire'?'':'none';
    renderCatalogList();
  }
  function chooseWizardSpecialization(key) {
    const spec=labeledInput('Magia','Especialização em Escola'),prohibited=labeledInput('Magia','Escolas Proibidas');if(!spec||!prohibited)return;
    spec.value=key==='universalista'?'Universalista':schoolLabel(key);prohibited.value='';renderCatalogList();
    status(key==='universalista'?'Você escolheu o caminho Universalista. Nenhuma escola será proibida.':'Especialização escolhida. Agora marque as escolas proibidas.');
  }
  function toggleProhibitedSchool(key) {
    const spec=wizardSpecialization();if(!spec||spec==='universalista'||spec===key)return;
    const required=spec==='divination'?1:2,current=selectedProhibitedSchools(),next=current.includes(key)?current.filter(x=>x!==key):current.concat(key);
    if(next.length>required){status('Esta especialização permite '+required+' escola(s) proibida(s).',true);return;}
    const input=labeledInput('Magia','Escolas Proibidas');if(input)input.value=next.map(schoolLabel).join(', ');renderCatalogList();
  }
  function renderSchoolSelection(list) {
    const spec=wizardSpecialization(),banned=selectedProhibitedSchools(),required=spec==='divination'?1:2;
    list.appendChild(createNode('div','mage-school-progress',spec==='universalista'?'Universalista · acesso às oito escolas, sem proibições.':!spec?'Escolha sua especialização. Depois, marque '+required+' escolas proibidas.':'Escolas proibidas: '+banned.length+' de '+(spec==='universalista'?0:required)+'.'));
    const universal=createNode('article','mage-school-card'+(spec==='universalista'?' selected':''));
    const uc=createNode('div');uc.append(createNode('h3','','Universalista'),createNode('p','','Estude magia sem se especializar em uma escola e sem abrir mão de nenhuma tradição.'));
    const ua=createNode('div','mage-school-actions'),ub=createNode('button','',spec==='universalista'?'ESCOLHIDO':'ESCOLHER');ub.type='button';ub.addEventListener('click',()=>chooseWizardSpecialization('universalista'));ua.appendChild(ub);universal.append(uc,ua);list.appendChild(universal);
    schools.forEach(([key,name,description])=>{
      const card=createNode('article','mage-school-card'+(spec===key?' selected mage-feat-selected-row':banned.includes(key)?' mage-feat-selected-row':''));
      const body=createNode('div');body.append(createNode('h3','',name),createNode('p','',description));
      const actions=createNode('div','mage-school-actions');
      const choose=createNode('button','',spec===key?'ESPECIALIZADA':'ESPECIALIZAR');choose.type='button';choose.classList.toggle('active',spec===key);choose.addEventListener('click',()=>chooseWizardSpecialization(key));
      const ban=createNode('button','',banned.includes(key)?'PROIBIDA':'PROIBIR');ban.type='button';ban.classList.toggle('active',banned.includes(key));ban.disabled=!spec||spec==='universalista'||spec===key;ban.addEventListener('click',()=>toggleProhibitedSchool(key));
      actions.append(choose,ban);card.append(body,actions);list.appendChild(card);
    });
    const footer=createNode('div','mage-feat-save-wrap'),next=createNode('button','mage-feat-save','Continuar para o Grimório');next.type='button';next.disabled=!(spec==='universalista'||(spec&&banned.length===required));next.addEventListener('click',()=>setSpellCatalogTab('grimoire'));footer.appendChild(next);list.appendChild(footer);
  }
  function updateMagicKnownCounts() {
    const magic=panel('Magia'),rows=magic&&magic.querySelectorAll('table tbody tr');
    const cells=rows&&rows[0]?rows[0].querySelectorAll('td'):[];
    const blocks=Array.from(document.querySelectorAll('.spell-level-block'));
    for(let circle=0;circle<=9;circle++){
      const input=cells[circle+1]?.querySelector('input'),block=blocks.find(item=>parseInt(clean(item.querySelector('.spell-level-title')),10)===circle);
      const count=block?Array.from(block.querySelectorAll('.spell-list input[type="text"]')).filter(field=>String(field.value||'').trim()).length:0;
      if(input){input.value=String(count);input.readOnly=true;}
    }
  }
  function spellRows() {
    const out=[];document.querySelectorAll('.spell-level-block').forEach(block=>{
      const circle=parseInt(clean(block.querySelector('.spell-level-title')),10);
      block.querySelectorAll('.spell-row').forEach(row=>{const input=row.querySelector('input[type="text"]'),check=row.querySelector('input[type="checkbox"]'),name=String(input?.value||'').trim();if(name)out.push({circle,name,input,check,spell:spellCatalog.find(sp=>wizardSpell(sp)&&wizardSpellCircle(sp)===circle&&[sp.nome_pt,sp.nome].some(x=>normalize(x)===normalize(name)))});});
    });return out;
  }
  function expectedInitialSpellCount() {
    try{const base=getBaseAttributes(),racial=Number(raceData?.ajustes_atributos?.INT||0);return Math.max(1,3+Math.floor((Number(base.INT)+racial-10)/2));}catch(_){return 3;}
  }
  function renderGrimoireSelection(list,search) {
    const circle=Number(document.getElementById('mage-catalog-level')?.value??1),existing=spellRows(),known=existing.filter(row=>row.circle===circle);
    list.appendChild(createNode('div','mage-school-progress',isCreate&&circle===1?'Escolha '+expectedInitialSpellCount()+' magia(s) de 1º círculo. Selecionadas: '+known.length+'. Truques de 0º círculo entram automaticamente.':'Magias registradas neste círculo: '+known.length+'. Opções bloqueadas não atendem às regras da classe, escola ou nível.'));
    const spells=uniqueSpellCatalog(spellCatalog.filter(sp=>wizardSpellCircle(sp)===circle&&normalize((sp.nome_pt||sp.nome)+' '+sp.escola+' '+sp.nivel).includes(search)));
    if(!spells.length)list.appendChild(createNode('div','mage-catalog-empty','Nenhuma magia encontrada neste círculo com essa pesquisa.'));
    spells.forEach(spell=>{
      const name=spell.nome_pt||spell.nome,elig=spellEligibility(spell),selected=existing.some(row=>row.circle===circle&&normalize(row.name)===normalize(name));
      const meta='Círculo '+circle+' · '+schoolLabel(spellSchoolKey(spell.escola)||spell.escola)+' · '+(elig.eligible?(selected?'Já está no Grimório':'Permitida para Mago'):elig.reasons.join(' '));
      const details=['Escola: '+(spell.escola||'Não informada'),'Círculo de Mago: '+wizardSpellCircle(spell),'Nível: '+(spell.nivel||'Não informado'),'Alcance: '+(spell.alcance||'Não informado'),'Alvo: '+(spell.alvo||spell.area||'Não informado'),'Duração: '+(spell.duracao||'Não informada'),'Componentes: '+(spell.componentes||'Não informados')].join('\n');
      const row=spellCatalogRow(name,meta,'fa-wand-sparkles',()=>chooseSpell(spell),()=>openLore(name,meta+'\n'+details,spell.descricao_pt||spell.descricao||''));
      row.classList.toggle('mage-spell-selected',selected);
      row.setAttribute('aria-selected',selected?'true':'false');
      row.classList.toggle('mage-spell-unavailable',!elig.eligible);
      const button=row.querySelector('.mage-catalog-name');button.textContent=selected?'ADICIONADA · '+name:'＋ '+name;
      button.disabled=!elig.eligible||(isCreate&&circle===1&&!selected&&known.length>=expectedInitialSpellCount())||(isCreate&&circle>1)||(selected&&circle===0);
      button.title=elig.eligible?'Adicionar ou remover do Grimório':elig.reasons.join(' ');list.appendChild(row);
    });
  }
  function renderPreparationSelection(list,search) {
    const known=spellRows().filter(row=>row.spell&&wizardSpell(row.spell)&&!selectedProhibitedSchools().includes(spellSchoolKey(row.spell.escola)));
    if(!known.length){list.appendChild(createNode('div','mage-catalog-empty','Seu Grimório ainda não tem magias registradas. Escolha primeiro suas magias na aba Grimório.'));return;}
    const filtered=known.filter(row=>normalize(row.name+' '+row.circle+' '+row.spell.escola).includes(search));
    if(!filtered.length)list.appendChild(createNode('div','mage-catalog-empty','Nenhuma magia conhecida corresponde à pesquisa.'));
    filtered.forEach(row=>{
      const selected=Boolean(row.check?.checked),card=createNode('div','mage-prep-row'+(selected?' mage-feat-selected-row':'')),copy=createNode('div');copy.append(createNode('strong','',row.name),createNode('small','','Círculo '+row.circle+' · '+schoolLabel(spellSchoolKey(row.spell.escola)||row.spell.escola)));
      const button=createNode('button','mage-prep-toggle'+(selected?' active':''),selected?'PREPARADA':'PREPARAR');button.type='button';button.setAttribute('aria-pressed',row.check?.checked?'true':'false');
      button.addEventListener('click',()=>{if(row.check){row.check.checked=!row.check.checked;row.check.dispatchEvent(new Event('change',{bubbles:true}));button.classList.toggle('active',row.check.checked);card.classList.toggle('mage-feat-selected-row',row.check.checked);button.textContent=row.check.checked?'PREPARADA':'PREPARAR';button.setAttribute('aria-pressed',row.check.checked?'true':'false');}});
      card.append(copy,button);list.appendChild(card);
    });
    list.appendChild(createNode('div','mage-school-progress','Preparação livre: marque ou desmarque as magias que deseja deixar preparadas. Não há contador diário nem bloqueio por descanso.'));
  }
  function renderCatalogList() {
    const list = document.getElementById('mage-catalog-list');
    const search = normalize(document.getElementById('mage-catalog-search')?.value || '');
    if (!list || !catalogMode) return;
    renderFeatCategories();
    renderSpellCatalogTabs();
    list.replaceChildren();
    let items = [];
    if (catalogMode === 'feats') {
      items = featCatalog.filter(item=>item.id!=='srd35_feat_scribe_scroll' && normalize((item.nome_pt||item.nome)+' '+featPrerequisite(item)+' '+(item.descricao_pt||item.descricao||'')).includes(search));
      if (activeFeatCategory!=='todos') items=items.filter(item=>featCategoryId(item)===activeFeatCategory);
      const chosenCount = (pendingFeatSelections || []).length;
      const slots = allowedGeneralFeatSlots();
      const info = createNode('div','mage-feat-counter',(raceData?.nome || 'Raça')+' · '+(classData?.nome || 'Classe')+' 1º nível — escolhas: '+chosenCount+' de '+slots+'. '+(raceId === 'humano' ? 'Humano recebe 1 talento normal + 1 adicional racial.' : '1 talento por nível de personagem.')+' '+(classData?.class_key === 'wizard' ? 'Mago recebe Escrever Pergaminho como talento bônus de classe.' : ''));
      list.appendChild(info);
      items.forEach(feat=>{
        const name = feat.nome_pt || feat.nome;
        const description = feat.descricao_pt || feat.descricao || '';
        const eligibility = featEligibility(feat);
        const selected = (pendingFeatSelections || []).includes(feat.id);
        const meta = eligibility.eligible ? 'Pré-requisito: '+featPrerequisite(feat)+' · '+(selected ? 'Selecionado' : 'Elegível') : 'Não elegível: '+eligibility.reasons.join(' ');
        const row = catalogRow(name,meta,'fa-feather-pointed',()=>chooseFeat(feat),()=>openLore(name,meta,description));
        row.classList.toggle('mage-feat-unavailable',!eligibility.eligible);
        row.classList.toggle('mage-feat-selected-row',selected);
        const choose = row.querySelector('.mage-catalog-choose');
        choose.textContent = selected ? 'DESMARCAR' : 'ESCOLHER';
        choose.disabled = !eligibility.eligible || (!selected && chosenCount >= slots);
        choose.title = !eligibility.eligible ? eligibility.reasons.join(' ') : selected ? 'Remover esta seleção' : (chosenCount >= slots ? 'Remova uma escolha para selecionar outra.' : 'Selecionar talento');
        list.appendChild(row);
      });
      if (chosenCount === slots) {
        const saveWrap = createNode('div','mage-feat-save-wrap');
        const saveButton = createNode('button','mage-feat-save','Salvar escolhas');
        saveButton.type = 'button';
        saveButton.addEventListener('click',savePendingFeatSelections);
        saveWrap.appendChild(saveButton);
        list.appendChild(saveWrap);
      }
    } else if (catalogMode === 'spells') {
      if(spellCatalogTab==='schools')renderSchoolSelection(list);
      else if(spellCatalogTab==='prepare')renderPreparationSelection(list,search);
      else renderGrimoireSelection(list,search);
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
    if (!items.length && !list.children.length) list.appendChild(createNode('div','mage-catalog-empty','Nenhum resultado encontrado para esta pesquisa.'));
  }
  function openCatalog(mode) {
    ensureCatalogOverlays();
    catalogMode = mode;
    const overlay = document.getElementById('mage-catalog-overlay');
    const title = document.getElementById('mage-catalog-title');
    const tools = document.querySelector('#mage-catalog-overlay .mage-catalog-tools');
    const search = document.getElementById('mage-catalog-search');
    title.textContent = mode === 'feats' ? 'Talentos' : mode === 'spells' ? 'Grimório do Mago' : 'Familiar';
    if(mode==='spells'){
      if(isCreate)spellCatalogTab='schools';
      else {try{wizardChoices();spellCatalogTab='grimoire';}catch(_){spellCatalogTab='schools';}}
    }
    if (mode === 'feats') { initializePendingFeatSelections(); activeFeatCategory = 'todos'; }
    const categoryNav = document.getElementById('mage-feat-categories');
    if (categoryNav) categoryNav.classList.toggle('ativo',mode==='feats');
    tools.querySelectorAll('#mage-catalog-level').forEach(node=>node.remove());
    if (mode === 'spells') {
      const level = createNode('select');
      level.id = 'mage-catalog-level';
      for(let i=0;i<=9;i++){
        const option = createNode('option','',i===0?'Truques (0)':'Círculo '+i);
        option.value = String(i);
        level.appendChild(option);
      }
      level.value = '1';
      level.addEventListener('change',renderCatalogList);
      tools.appendChild(level);
      tools.style.display=spellCatalogTab==='schools'?'none':'flex';
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
  function initializePendingFeatSelections() {
    if (pendingFeatSelections !== null) return;
    const map = featMap();
    pendingFeatSelections = featSelectionRows().map(row => {
      const input = row.querySelector('input');
      const feat = map.get(normalize(input?.value || ''));
      return feat && feat.id !== 'srd35_feat_scribe_scroll' ? feat.id : null;
    }).filter(Boolean).slice(0,allowedGeneralFeatSlots());
  }
  function savePendingFeatSelections() {
    const slots = allowedGeneralFeatSlots();
    if (!pendingFeatSelections || pendingFeatSelections.length !== slots) {
      status('Selecione exatamente '+slots+' talento(s) antes de salvar.',true);
      return;
    }
    const map = new Map(featCatalog.map(feat=>[feat.id,feat]));
    const selected = pendingFeatSelections.map(id=>map.get(id)).filter(Boolean);
    if (selected.length !== slots) {
      status('Uma das escolhas não está mais disponível no catálogo. Revise a seleção.',true);
      return;
    }
    for (const feat of selected) {
      const eligibility = featEligibility(feat);
      if (!eligibility.eligible) {
        status('Não é possível salvar '+(feat.nome_pt||feat.nome)+': '+eligibility.reasons.join(' '),true);
        return;
      }
    }
    const rows = featSelectionRows();
    rows.forEach(row=>{
      const input = row.querySelector('input');
      if (input && !input.readOnly && normalize(input.value) !== 'escrever pergaminho') {
        row.querySelectorAll('input').forEach(field=>{field.value='';delete field.dataset.featId;});
      }
    });
    selected.forEach((feat,index)=>{
      let row = featSelectionRows().find(item=>!String(item.querySelector('input')?.value||'').trim());
      if (!row) { appendFeatRow(); row = featSelectionRows().at(-1); }
      const inputs = row.querySelectorAll('input');
      inputs[0].value = feat.nome_pt || feat.nome;
      inputs[1].value = '';
      inputs[0].dataset.featId = feat.id;
      inputs[0].dispatchEvent(new Event('input',{bubbles:true}));
    });
    updateFeatSelectionRows();
    pendingFeatSelections = selected.map(feat=>feat.id);
    closeCatalog();
    status('Escolhas de talentos salvas na ficha.');
  }
  function chooseFeat(feat) {
    initializePendingFeatSelections();
    const selectedIndex = pendingFeatSelections.indexOf(feat.id);
    if (selectedIndex >= 0) {
      pendingFeatSelections.splice(selectedIndex,1);
      status('Talento desmarcado. Escolha outro para completar a seleção.');
    } else {
      const eligibility = featEligibility(feat);
      if (!eligibility.eligible) { status('Não é possível selecionar '+(feat.nome_pt||feat.nome)+': '+eligibility.reasons.join(' '),true); return; }
      if (pendingFeatSelections.length >= allowedGeneralFeatSlots()) {
        status('Remova um talento selecionado antes de escolher outro.',true);
        return;
      }
      pendingFeatSelections.push(feat.id);
      status('Talento selecionado provisoriamente: '+(feat.nome_pt||feat.nome)+'.');
    }
    renderCatalogList();
  }
  function chooseSpell(spell) {
    const circle=wizardSpellCircle(spell),name=spell.nome_pt||spell.nome,eligibility=spellEligibility(spell);
    if(!eligibility.eligible){status('Esta magia não pode ser registrada: '+eligibility.reasons.join(' '),true);return;}
    const existing=spellRows().find(row=>row.circle===circle&&normalize(row.name)===normalize(name));
    if(existing){if(circle===0){status('Os truques de 0º círculo já fazem parte do Grimório inicial.');return;}existing.input.value='';existing.input.dispatchEvent(new Event('input',{bubbles:true}));if(existing.check)existing.check.checked=false;status('Magia removida do Grimório: '+name+'.');updateMagicKnownCounts();renderCatalogList();return;}
    if(isCreate&&circle===1&&spellRows().filter(row=>row.circle===1).length>=expectedInitialSpellCount()){status('Você já escolheu todas as magias iniciais permitidas.');return;}
    const block = Array.from(document.querySelectorAll('.spell-level-block')).find(item=>parseInt(clean(item.querySelector('.spell-level-title')),10)===circle);
    if (!block) { status('A ficha não possui uma área para este círculo de magia.',true); return; }
    const list = block.querySelector('.spell-list');
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
      status('Magia adicionada ao grimório: '+name+'.');updateMagicKnownCounts();renderCatalogList();
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
      sb.from('srd_skills').select('id,nome,atributo,treinada_apenas,penalidade_armadura,descricao,dados_tecnicos').neq('source_status','excluded'),
      sb.from('srd_feats').select('id,nome,nome_pt,descricao,descricao_pt,exige_parametro,requisitos,source_status'),
      sb.from('srd_spells').select('id,nome,nome_pt,descricao,descricao_pt,circulo,nivel,escola,alcance,alvo,area,duracao,componentes,classes,source_status')
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
      if (control.disabled || control.readOnly || control.type === 'hidden' || control.type === 'button' || control.type === 'submit' || control.type === 'checkbox') return;
      if (control.closest('[hidden],.mage-catalog-overlay,.mage-lore-overlay')) return;
      // Resistências, BBA e Agarrar são campos derivados; Resistência à Magia só se aplica quando houver uma fonte específica.
      const panelTitle = normalize(clean(control.closest('.panel')?.querySelector('.panel-title')));
      if (control.closest('.resist-row') || /resistencias/.test(panelTitle) || /base e agarrar/.test(panelTitle) || /iniciativa/.test(panelTitle) || /deslocamento/.test(panelTitle) || /equipamentos|ataques|armadura|ca/.test(panelTitle)) return;
      const target = guideTargetFor(control);
      if (!target || seen.has(target)) return;
      seen.add(target);
      const labelNode = target.querySelector('label,td:first-child,th:first-child,.attr-name,.resist-name,.panel-title');
      const label = clean(labelNode) || 'esta informação';
      const sectionPanel = control.closest('.panel');
      const sectionKey = normalize(sectionPanel ? clean(sectionPanel.querySelector('.panel-title')) : 'identidade');
      let help = 'Confira este campo e preencha o que estiver faltando. Essas informações ficam na ficha para você consultar durante a aventura.';
      const attributeHelp = {
        'for': 'FORÇA mede o poder físico. Ajuda nos golpes corpo a corpo, no dano e em tarefas como escalar, saltar e arrombar. Também influencia quanto equipamento você consegue carregar.',
        'des': 'DESTREZA mede agilidade e reflexos. Ajuda na Iniciativa, na defesa, nos testes de Reflexos e em perícias como Furtividade e Acrobacia. Algumas armaduras limitam esse benefício.',
        'con': 'CONSTITUIÇÃO mede saúde e resistência. Ela aumenta seus Pontos de Vida e ajuda a resistir a venenos, doenças e outros perigos físicos.',
        'int': 'INTELIGÊNCIA representa raciocínio, memória e estudo. Ajuda em conhecimentos e investigação e define seus pontos de perícia. Para o Mago, também é o atributo principal para lançar magias.',
        'sab': 'SABEDORIA reúne percepção, bom senso e força de vontade. Ajuda a perceber perigos e resistir a efeitos mentais. É importante para Clérigos e Druidas.',
        'car': 'CARISMA mede presença e força de personalidade. Ajuda em conversas, blefes e intimidação. É importante para Feiticeiros e Bardos.'
      };
      const attributeKey = normalize(label).replace(/[^a-z]/g,'');
      if (/atributos/.test(sectionKey) && attributeHelp[attributeKey]) help = attributeHelp[attributeKey];
      const fieldKey = normalize(label);
      if (/cabecalho|identidade/.test(sectionKey)) {
        const identityHelp = {
          'nome do personagem':'Dê um nome ao aventureiro. É assim que ele será identificado na ficha e durante a campanha.',
          'raca':'A raça define características do personagem, como ajustes nos atributos, velocidade, idiomas e habilidades especiais.',
          'tendencia':'Escolha a tendência do personagem. Ela serve como guia para suas escolhas, mas não define toda a personalidade dele.',
          'sexo':'Registre essa informação para a história do personagem. Ela não muda os atributos.',
          'idade':'A idade ajuda a contar a história do personagem e pode trazer efeitos conforme a raça.',
          'altura':'A altura inicial segue a raça escolhida. Você pode ajustar o valor para combinar com seu personagem.',
          'peso':'O peso inicial acompanha a raça e a altura. Ajuste se quiser representar melhor seu personagem.',
          'divindade':'Se o personagem segue uma divindade, registre o nome aqui.'
        };
        help = identityHelp[fieldKey] || 'Esta etapa reúne informações de identidade e história do aventureiro. Confira o dado apresentado e ajuste quando necessário.';
      } else if (/atributos/.test(sectionKey)) help = attributeHelp[attributeKey] || 'Os atributos são as seis capacidades básicas do personagem. Seus modificadores alimentam automaticamente perícias, combate e resistências.';
      else if (/pericias/.test(sectionKey)) {
        // Em cada linha da tabela, o controle é numérico; o nome está na primeira célula da linha.
        // guideCandidates já fornece esse texto em label, portanto nunca usamos control.value aqui.
        const skill = findGuideSkill(label);
        if (skill && skill.descricao) {
          const abilityNames = {FOR:'Força',DES:'Destreza',CON:'Constituição',INT:'Inteligência',SAB:'Sabedoria',CAR:'Carisma'};
          const ability = abilityNames[String(skill.atributo || '').toUpperCase()] || skill.atributo || 'atributo';
          const flags = [];
          if (skill.treinada_apenas) flags.push('Esta perícia exige treinamento: sem graduação, não é possível realizar o teste.');
          if (skill.penalidade_armadura) flags.push('A penalidade de armadura se aplica aos testes desta perícia.');
          help = skill.descricao + ' Atributo relacionado: ' + ability + '.' + (flags.length ? ' ' + flags.join(' ') : '');
        } else {
          help = 'Não foi possível localizar a descrição desta perícia no catálogo. Confira o nome exibido na ficha e o cadastro SRD antes de continuar.';
        }
      }
      else if (/talentos/.test(sectionKey)) help = 'Abra o catálogo para escolher seu talento. O sistema considera raça, classe, nível, atributos, BBA, perícias e talentos prévios; opções cujos pré-requisitos você ainda não cumpre aparecem apagadas e bloqueadas.';
      else if (/grimorio|magia/.test(sectionKey)) help = 'Aqui você escolhe as magias que farão parte do Grimório. A preparação e a remoção de magias acontecem durante a campanha, conforme a narrativa.';
      else if (/ataques/.test(sectionKey)) {
        const attackHelp = {
          'arma':'A arma inicial da classe será inserida automaticamente pelo pacote. Confira o nome e os dados do equipamento; o bônus de ataque e o dano são derivados das regras e dos atributos.',
          'bonus':'Este valor é calculado a partir do BBA, atributo aplicável, tamanho, proficiência e modificadores da arma. Não some bônus manualmente.',
          'dano':'O dano é preenchido conforme a arma, o modificador de atributo aplicável e outras regras pertinentes. O pacote inicial fornece a arma.',
          'critico':'Confira a margem de ameaça e o multiplicador de crítico próprios da arma selecionada no pacote inicial.',
          'alcance':'O alcance depende do tipo de arma. Armas de combate à distância e armas com alcance especial recebem seus valores correspondentes.',
          'tipo':'Este campo identifica o tipo de dano da arma, como cortante, perfurante ou contundente.',
          'municao':'Quando a arma utilizar munição, a quantidade e o tipo ficam registrados aqui.'
        };
        help = attackHelp[fieldKey] || 'Os dados de ataque são integrados ao equipamento inicial da classe. O sistema preenche os valores derivados; confira as informações apresentadas.';
      } else if (/armadura|ca/.test(sectionKey)) {
        const defenseHelp = {'total':'A Classe de Armadura total é calculada automaticamente com base em 10, armadura, escudo, Destreza, tamanho e demais bônus aplicáveis.','arm':'O bônus de armadura vem da proteção equipada no pacote inicial da classe.','esc':'O bônus de escudo é aplicado quando houver um escudo equipado.','des':'O modificador de Destreza entra na CA respeitando o limite máximo da armadura.','tam':'O modificador de tamanho é determinado pela raça e aplicado automaticamente.','nat':'Bônus de armadura natural só entram quando uma característica ou efeito os conceder.','defl':'Bônus de deflexão entram quando concedidos por habilidade, magia ou item.','out':'Use este campo apenas para modificadores de CA que não tenham categoria própria.'};
        help = defenseHelp[fieldKey] || 'A proteção inicial será fornecida pelo pacote da classe. A CA e seus componentes devem refletir automaticamente os equipamentos e modificadores aplicáveis.';
      }
      else if (/idiomas/.test(sectionKey)) help = 'Os idiomas concedidos pela raça e pela classe são preenchidos automaticamente. Confira a lista e registre apenas idiomas adicionais que tenham sido adquiridos por uma escolha válida.';
      items.push({target,control,label,help,sectionKey});
    });
    return items;
  }
  function guideNavigationEntries() {
    const sheet = document.querySelector('.ficha');
    const entries = [
      { label: 'Base', target: sheet && sheet.querySelector('.header-top') },
      { label: 'Atributos', panel: 'Atributos' },
      { label: 'Resistências', panel: 'Resistências', description: 'Mostram o quanto seu personagem consegue resistir a perigos. Fortitude protege o corpo, Reflexos ajuda a escapar de ameaças e Vontade protege a mente.', formula: 'Fortitude = bônus-base + Constituição. Reflexos = bônus-base + Destreza. Vontade = bônus-base + Sabedoria. Outros efeitos podem somar bônus ou penalidades.' },
      { label: 'Base e Agarrar', panel: 'Base e Agarrar', description: 'O BBA ajuda a acertar ataques. Agarrar é usado quando você tenta segurar ou imobilizar uma criatura.', formula: 'BBA: valor definido pela classe e pelo nível. Agarrar = BBA + Força + ajuste de tamanho + outros modificadores.' },
      { label: 'Iniciativa', panel: 'Iniciativa', description: 'Indica a rapidez com que seu personagem reage quando um combate começa.', formula: 'Iniciativa = modificador de Destreza + outros modificadores.' },
      { label: 'Deslocamento', panel: 'Deslocamento', description: 'É a distância que seu personagem pode percorrer. Armadura, carga e algumas habilidades podem mudar esse valor.', formula: 'Parte do deslocamento da raça ou classe; depois são considerados armadura, carga e efeitos que alterem o movimento.' },
      { label: 'Pontos de Vida', panel: 'Pontos de Vida', description: 'Representam quanto dano seu personagem aguenta antes de cair. A classe define o dado de vida e a Constituição influencia o total.', formula: 'Em cada nível: pontos do dado de vida + modificador de Constituição. Some também os ajustes concedidos por habilidades ou outros efeitos. No 1º nível, use o valor máximo do dado de vida.' },
      { label: 'Armadura (CA)', panel: 'Armadura (CA)', description: 'A Classe de Armadura indica o quanto é difícil acertar seu personagem. Armadura, escudo, agilidade e outros bônus podem protegê-lo.', formula: 'CA = 10 + armadura + escudo + Destreza permitida pela armadura + tamanho + outros bônus aplicáveis. CA de toque e desprevenido ignoram alguns desses bônus, conforme as regras.' },
      { label: 'Ataques', panel: 'Ataques' },
      { label: 'Perícias', panel: 'Perícias' },
      { label: 'Talentos', panel: 'Talentos' },
      { label: 'Familiar', panel: 'Familiar' },
      { label: 'Magia', panel: 'Grimório', description: 'Primeiro escolha sua escola de especialização e as escolas proibidas. Depois, registre as magias permitidas no Grimório e escolha quais ficam preparadas.' },
      { label: 'Resumo mágico', panel: 'Magia' },
      { label: 'Experiência', panel: 'Experiência' },
      { label: 'Traços Raciais', panel: 'Traços Raciais' },
      { label: 'Observações', panel: 'Observação' },
      { label: 'Equipamentos', panel: 'Equipamentos' },
      { label: 'Varinhas e Cajados', panel: 'Varinhas e Cajados' },
      { label: 'Capacidade de Carga', panel: 'Capacidade de Carga' },
      { label: 'Idiomas', panel: 'Idiomas' },
      { label: 'Recipientes', panel: 'Recipientes' },
      { label: 'Dinheiro', panel: 'Dinheiro' }
    ];
    return entries.map(entry => {
      if (!entry.target && entry.panel) {
        const wanted = normalize(entry.panel);
        entry.target = Array.from(sheet.querySelectorAll('.panel')).find(node => {
          const heading = normalize(clean(node.querySelector('.panel-title')));
          return heading === wanted || (entry.panel === 'Perícias' && heading.startsWith('pericias')) || (entry.panel === 'Grimório' && heading.startsWith('grimorio'));
        }) || null;
      }
      return entry;
    }).filter(entry => entry.target);
  }
  function guideCategoryFor(item) {
    const key = normalize(item.sectionKey || '');
    if (/identidade|cabecalho/.test(key)) return 'Base';
    if (/atributos/.test(key)) return 'Atributos';
    if (/resistencias/.test(key)) return 'Resistências';
    if (/base e agarrar/.test(key)) return 'Base e Agarrar';
    if (/iniciativa/.test(key)) return 'Iniciativa';
    if (/deslocamento/.test(key)) return 'Deslocamento';
    if (/pontos de vida/.test(key)) return 'Pontos de Vida';
    if (/armadura|ca/.test(key)) return 'Armadura (CA)';
    if (/ataques/.test(key)) return 'Ataques';
    if (/pericias/.test(key)) return 'Perícias';
    if (/talentos/.test(key)) return 'Talentos';
    if (/familiar/.test(key)) return 'Familiar';
    if (/grimorio|magia/.test(key)) return 'Magia';
    if (/experiencia/.test(key)) return 'Experiência';
    if (/tracos raciais/.test(key)) return 'Traços Raciais';
    if (/observacao/.test(key)) return 'Observações';
    if (/equipamentos/.test(key)) return 'Equipamentos';
    if (/varinhas e cajados/.test(key)) return 'Varinhas e Cajados';
    if (/capacidade de carga/.test(key)) return 'Capacidade de Carga';
    if (/idiomas/.test(key)) return 'Idiomas';
    if (/recipientes/.test(key)) return 'Recipientes';
    if (/dinheiro/.test(key)) return 'Dinheiro';
    return 'Base';
  }
  function renderGuideCategories(note, candidates, currentItem) {
    const oldNav = note.querySelector('.mage-guide-categories');
    if (oldNav) oldNav.remove();
    const layout = document.createElement('div');
    layout.className = 'mage-guide-layout';
    const nav = document.createElement('nav');
    nav.className = 'mage-guide-categories';
    nav.setAttribute('aria-label', 'Tópicos da ficha');
    const content = document.createElement('div');
    content.className = 'mage-guide-current';
    while (note.firstChild) content.appendChild(note.firstChild);
    layout.append(nav, content);
    note.appendChild(layout);
    const entries = guideNavigationEntries();
    entries.forEach(entry => {
      const button = document.createElement('button');
      button.type = 'button';
      button.className = 'mage-guide-category';
      button.textContent = entry.label;
      const firstStep = candidates.findIndex(candidate => guideCategoryFor(candidate) === entry.label);
      if (entry.label === guideCategoryFor(currentItem)) button.classList.add('ativo');
      button.addEventListener('click', () => {
        if (firstStep >= 0) {
          showStep(firstStep);
          return;
        }
        document.querySelectorAll('.mage-guide-category.ativo').forEach(node => node.classList.remove('ativo'));
        button.classList.add('ativo');
        document.querySelectorAll('.mage-step-focus').forEach(node => node.classList.remove('mage-step-focus'));
        entry.target.classList.add('mage-step-focus');
        entry.target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        const heading = content.querySelector('strong');
        if (heading) heading.textContent = entry.label;
        const help = content.querySelector('.mage-guide-help');
        if (help) {
          help.replaceChildren();
          const intro = document.createElement('p');
          intro.textContent = entry.description || 'Esta parte da ficha reúne informações do personagem. Confira os valores e consulte os campos durante a campanha.';
          help.appendChild(intro);
          if (entry.label === 'Magia') {
            const open = document.createElement('button');
            open.type = 'button'; open.className = 'mage-guide-catalog-button'; open.textContent = 'Abrir Grimório';
            open.addEventListener('click', () => openCatalog('spells'));
            help.appendChild(open);
          }
          if (entry.formula) {
            const formulaTitle = document.createElement('strong');
            formulaTitle.textContent = 'Como é calculado';
            const formulaText = document.createElement('p');
            formulaText.textContent = entry.formula;
            help.append(formulaTitle, formulaText);
          }
        }
      });
      nav.appendChild(button);
    });
    const styleId = 'mage-guide-category-style';
    if (!document.getElementById(styleId)) {
      const style = document.createElement('style');
      style.id = styleId;
      style.textContent = '.mage-step-note{width:244px;text-align:left;padding:14px 13px}.mage-guide-layout{display:flex;flex-direction:column;gap:10px;align-items:stretch}.mage-guide-categories{display:flex;flex-direction:column;gap:1px;max-height:42vh;overflow:auto;padding:2px 4px 8px 0;border-bottom:1px solid rgba(139,111,71,.25)}.mage-guide-category{appearance:none;border:0;background:transparent;text-align:left;padding:5px 4px;color:#725637;cursor:pointer;font:13px Georgia,serif;transition:color .18s,text-shadow .18s}.mage-guide-category:hover{color:#3f2a17}.mage-guide-category.ativo{color:#9a681d;text-shadow:0 0 7px rgba(255,190,77,.9),0 0 14px rgba(255,174,48,.55);font-weight:700}.mage-guide-current{min-width:0;text-align:left;font-size:13px}.mage-guide-current .mage-guide-actions{justify-content:flex-start}.mage-guide-toggle{display:block;width:100%;padding:6px 8px;margin:0 0 9px;border:1px solid rgba(139,111,71,.35);background:rgba(255,255,255,.28);color:#594126;text-align:left;cursor:pointer;font:700 11px Cinzel,Georgia,serif}.mage-step-note.recolhido{width:52px;height:48px;bottom:auto;padding:6px;overflow:hidden}.mage-step-note.recolhido>.mage-guide-toggle{width:100%;height:34px;margin:0;padding:3px;text-align:center}.mage-step-note.recolhido>.mage-guide-layout{display:none}@media(max-width:1000px){.mage-step-note{left:10px;top:10px;bottom:auto;width:min(270px,calc(100vw - 20px));max-height:calc(100vh - 20px)}.mage-step-note.recolhido{width:52px;height:48px}.mage-guide-categories{max-height:34vh}}@media(max-width:560px){.mage-step-note{padding:10px;width:min(250px,calc(100vw - 20px))}.mage-guide-category{font-size:11px;padding:5px 2px}.mage-guide-current{font-size:12px}.mage-guide-actions{gap:5px}.mage-guide-actions button{padding:7px 9px;font-size:10px}}';
      document.head.appendChild(style);
    }
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
    note.innerHTML = '<div style="font-size:10px;letter-spacing:.14em;text-transform:uppercase;color:#98764a;margin-bottom:6px;text-align:center">Sua jornada · etapa ' + (step+1) + ' de ' + candidates.length + '</div><strong>' + item.label + '</strong><div class="mage-guide-help">' + item.help + '</div>' + (/talentos/.test(item.sectionKey) ? '<button type="button" id="mage-guide-feats" class="mage-guide-catalog-button">Abrir catálogo de talentos</button>' : (/grimorio|magia/.test(item.sectionKey) ? '<button type="button" id="mage-guide-spells" class="mage-guide-catalog-button">Abrir Grimório</button>' : '')) + '<div class="mage-guide-progress"><span style="width:' + (((step+1)/candidates.length)*100) + '%"></span></div><div class="mage-guide-actions"><button type="button" id="mage-guide-prev">Voltar</button><button type="button" id="mage-guide-next">' + (step === candidates.length - 1 ? 'Concluir guia' : 'Avançar') + '</button><button type="button" id="mage-save">' + (isCreate ? 'Criar Mago' : 'Salvar ficha') + '</button></div>';
    renderGuideCategories(note,candidates,item);
    const guideToggle = document.createElement('button');
    guideToggle.type = 'button';
    guideToggle.className = 'mage-guide-toggle';
    guideToggle.textContent = '− Recolher GUIA';
    guideToggle.setAttribute('aria-expanded', 'true');
    guideToggle.addEventListener('click', () => {
      const collapsed = note.classList.toggle('recolhido');
      guideToggle.textContent = collapsed ? 'GUIA +' : '− Recolher GUIA';
      guideToggle.setAttribute('aria-expanded', String(!collapsed));
    });
    note.insertBefore(guideToggle, note.firstChild);
    const featButton = note.querySelector('#mage-guide-feats');
    if (featButton) featButton.onclick = () => openCatalog('feats');
    const spellButton = note.querySelector('#mage-guide-spells');
    if (spellButton) spellButton.onclick = () => openCatalog('spells');
    const prevButton = note.querySelector('#mage-guide-prev');
    const nextButton = note.querySelector('#mage-guide-next');
    prevButton.disabled = step === 0;
    prevButton.onclick = () => showStep(step - 1);
    nextButton.onclick = () => {
      const refreshed = guideCandidates();
      if (step >= refreshed.length - 1) {
        document.querySelectorAll('.mage-step-focus').forEach(el=>el.classList.remove('mage-step-focus'));
        status('Guia concluído. Você pode criar ou salvar sua ficha.');
        note.querySelector('strong').textContent = 'Jornada concluída';
        note.querySelector('.mage-guide-help').textContent = 'Você chegou ao fim do guia. Revise sua ficha e use o botão abaixo para ' + (isCreate ? 'criar o personagem.' : 'salvar as alterações.');
        nextButton.disabled = true;
        prevButton.disabled = true;
      } else showStep(step + 1);
    };
    note.querySelector('#mage-save').addEventListener('click', save);
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
      const expectedSpells = Math.max(1,3+Math.floor((finalInt-10)/2));
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
      const choices = wizardChoices();
      validateSpellbookEntries();
      const current = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
      if (current.error) throw current.error;
      if (!current.data) throw new Error('Ficha não encontrada ou sem permissão.');
      const identity = current.data.identidade && typeof current.data.identidade === 'object' ? current.data.identidade : {};
      identity.wizard_specialization = choices.wizard_specialization;
      identity.wizard_prohibited_schools = choices.wizard_prohibited_schools;
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
        sb.from('srd_classes').select('id,nome,class_key,bab_bom,bab_progression,pericias_por_nivel,pericias_classe,dados_tecnicos').eq('id', classId).maybeSingle(),
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
    if (isCreate) { updateFeatSelectionRows(); showStep(0); }
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

  // Coruja-guia: assistente contextual inspirado nos antigos assistentes do Office.

  function initOwlGuide() {
    if (document.getElementById('dnd35-owl-guide')) return;
    const style = document.createElement('style');
    style.id = 'dnd35-owl-guide-style';
    style.textContent = `
      #dnd35-owl-guide{position:fixed;right:22px;bottom:18px;z-index:10050;display:flex;align-items:flex-end;gap:12px;font-family:'EB Garamond',Georgia,serif;pointer-events:none;max-width:calc(100vw - 28px)}
      #dnd35-owl-guide *{box-sizing:border-box}
      #dnd35-owl-guide .lampiao-art{pointer-events:auto;width:164px;height:218px;object-fit:contain;object-position:center bottom;flex:0 0 auto;filter:drop-shadow(0 7px 12px rgba(0,0,0,.55));transform-origin:50% 70%;animation:lampiao-idle 4.2s ease-in-out infinite}
      #dnd35-owl-guide .lampiao-chat{pointer-events:auto;width:min(350px,calc(100vw - 205px));min-width:230px;padding:15px 17px 13px;background:linear-gradient(145deg,#fff4d8,#e5cf9f);color:#392817;border:2px solid #ae8345;border-radius:13px 13px 13px 3px;box-shadow:0 12px 34px rgba(0,0,0,.48),inset 0 0 18px rgba(255,255,255,.3);position:relative;margin-bottom:15px}
      #dnd35-owl-guide .lampiao-chat:before{content:"";position:absolute;left:-9px;bottom:28px;width:14px;height:14px;background:#e9d7ae;border-left:2px solid #ae8345;border-bottom:2px solid #ae8345;transform:rotate(45deg)}
      #dnd35-owl-guide .lampiao-title{font:900 11px Cinzel,Georgia,serif;letter-spacing:1.5px;text-transform:uppercase;color:#765020;margin:0 0 7px}
      #dnd35-owl-guide .lampiao-message{font-size:16px;line-height:1.4;margin:0;white-space:pre-line}
      #dnd35-owl-guide .lampiao-detail{display:none;margin-top:9px;padding-top:8px;border-top:1px solid rgba(139,103,52,.35);font-size:14px;line-height:1.4;color:#5a4128}
      #dnd35-owl-guide.show-detail .lampiao-detail{display:block}
      #dnd35-owl-guide .lampiao-actions{display:flex;gap:7px;flex-wrap:wrap;margin-top:13px}
      #dnd35-owl-guide .lampiao-actions button{border:1px solid #9b733c;border-radius:5px;background:linear-gradient(#f8e8c4,#dfc18c);color:#3b2917;padding:7px 10px;font:700 10px Cinzel,Georgia,serif;cursor:pointer;transition:transform .16s,box-shadow .16s}
      #dnd35-owl-guide .lampiao-actions button:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 3px 9px #79501e55}
      #dnd35-owl-guide .lampiao-actions button:disabled{opacity:.38;cursor:not-allowed}
      #dnd35-owl-guide .lampiao-actions .lampiao-close{margin-left:auto;background:linear-gradient(#6a3024,#421d17);border-color:#8e5a43;color:#f8e7c7}
      #dnd35-owl-guide .lampiao-minimized{display:none;pointer-events:auto;width:54px;height:54px;border-radius:50%;border:1px solid #d69b48;background:radial-gradient(circle,#ffcc68 0%,#a64a18 42%,#21130d 75%);box-shadow:0 0 18px #e77b27aa,0 5px 16px #0009;cursor:pointer;color:#ffe3a5;font-size:24px}
      #dnd35-owl-guide.closed .lampiao-art,#dnd35-owl-guide.closed .lampiao-chat{display:none}
      #dnd35-owl-guide.closed .lampiao-minimized{display:grid;place-items:center}
      #dnd35-owl-guide.pop-out .lampiao-art,#dnd35-owl-guide.pop-out .lampiao-chat{animation:lampiao-pop-out .25s cubic-bezier(.2,.8,.3,1) forwards}
      #dnd35-owl-guide.pop-in .lampiao-art,#dnd35-owl-guide.pop-in .lampiao-chat{animation:lampiao-pop-in .3s cubic-bezier(.2,.8,.3,1) both}
      #dnd35-owl-guide.closed{right:18px;bottom:18px}
      @keyframes lampiao-idle{0%,100%{transform:translateY(0) rotate(0)}35%{transform:translateY(-4px) rotate(-1deg)}70%{transform:translateY(1px) rotate(1deg)}}
      @keyframes lampiao-pop-out{0%{transform:scale(1);opacity:1}30%{transform:scale(1.15);opacity:1}100%{transform:scale(0);opacity:0}}
      @keyframes lampiao-pop-in{0%{transform:scale(0);opacity:0}70%{transform:scale(1.15);opacity:1}100%{transform:scale(1);opacity:1}}
      @media(max-width:680px){#dnd35-owl-guide{right:10px;bottom:10px;gap:4px}#dnd35-owl-guide .lampiao-art{width:104px;height:150px}#dnd35-owl-guide .lampiao-chat{width:min(290px,calc(100vw - 120px));min-width:190px;padding:11px 12px}#dnd35-owl-guide .lampiao-message{font-size:14px}#dnd35-owl-guide .lampiao-actions button{padding:6px 7px;font-size:9px}}
      @media(prefers-reduced-motion:reduce){#dnd35-owl-guide .lampiao-art{animation:none}#dnd35-owl-guide.pop-out .lampiao-art,#dnd35-owl-guide.pop-out .lampiao-chat,#dnd35-owl-guide.pop-in .lampiao-art,#dnd35-owl-guide.pop-in .lampiao-chat{animation:none}}
    `;
    document.head.appendChild(style);
    const root=document.createElement('aside');
    root.id='dnd35-owl-guide';
    root.setAttribute('aria-label','Guia do Lampião Errante');
    root.innerHTML='<svg class="lampiao-art" viewBox="0 0 240 320" role="img" aria-label="Lampião Errante"><defs><radialGradient id="lampGlow"><stop stop-color="#fff1a0"/><stop offset=".38" stop-color="#ffad35"/><stop offset="1" stop-color="#9b3e12"/></radialGradient><linearGradient id="iron" x2="1" y2="1"><stop stop-color="#92704a"/><stop offset=".3" stop-color="#211b17"/><stop offset=".62" stop-color="#6d4a2c"/><stop offset="1" stop-color="#171411"/></linearGradient><linearGradient id="cloth" x2="0" y2="1"><stop stop-color="#762d2b"/><stop offset="1" stop-color="#240f13"/></linearGradient><filter id="glow"><feGaussianBlur stdDeviation="5" result="b"/><feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter></defs><path d="M112 295 Q78 265 112 239 Q82 213 117 184 Q143 158 120 130 Q166 153 147 189 Q184 218 145 246 Q169 273 133 302Z" fill="url(#lampGlow)" opacity=".8" filter="url(#glow)"/><path d="M83 47 Q54 4 112 12 Q176 4 157 52" fill="none" stroke="#30231a" stroke-width="10"/><path d="M83 47 Q54 4 112 12 Q176 4 157 52" fill="none" stroke="#9a7547" stroke-width="3"/><path d="M81 47 L159 47 L176 83 L64 83Z" fill="url(#iron)" stroke="#b18a50" stroke-width="3"/><path d="M70 70 Q38 52 28 95 Q56 109 78 90 L92 73 Q128 98 166 77 Q204 88 184 119 Q150 132 105 109 L73 128 Q29 138 37 171 L62 160 L79 130 Q117 151 158 127 Q196 142 207 111 L177 92 L163 67Z" fill="url(#cloth)" stroke="#9a563d" stroke-width="2"/><path d="M75 91 L165 91 L185 218 Q177 250 120 254 Q63 250 55 218Z" fill="url(#iron)" stroke="#b18a50" stroke-width="4"/><path d="M78 108 Q120 87 162 108 L171 212 Q120 241 69 212Z" fill="#27160f" stroke="#8b693f" stroke-width="4"/><path d="M85 203 Q67 159 99 124 Q115 105 121 130 Q147 103 158 143 Q177 178 153 211 Q121 233 85 203Z" fill="url(#lampGlow)" filter="url(#glow)"/><path d="M88 151 Q103 132 117 151 Q104 160 88 151Z M126 151 Q143 132 158 151 Q142 160 126 151Z" fill="#1b100b"/><path d="M91 147 Q104 139 116 148 M129 148 Q143 139 155 147" fill="none" stroke="#e9b45a" stroke-width="5" stroke-linecap="round"/><path d="M75 134 L117 126 L112 141 L79 148Z M126 126 L166 135 L159 148 L129 141Z" fill="#241a14" stroke="#a17a48" stroke-width="3"/><path d="M63 214 Q120 235 177 214 L187 241 Q121 267 53 241Z" fill="url(#iron)" stroke="#a77d48" stroke-width="4"/><path d="M88 240 L76 264 L96 256 L111 274 L124 253 L144 268 L155 245" fill="none" stroke="#b18a50" stroke-width="5"/><path d="M61 120 Q32 135 31 166 L14 185 M177 124 Q204 135 208 163 L226 178" fill="none" stroke="#4b3827" stroke-width="9" stroke-linecap="round"/><path d="M14 185 l-9 13 18-3 8 12 7-18 -10-9Z M226 178 l10 12 -18-2 -8 13 -7-18 10-10Z" fill="#241b15" stroke="#98754a" stroke-width="3"/><path d="M70 82 Q44 96 57 112 M166 82 Q190 98 179 115" fill="none" stroke="#b58a51" stroke-width="3"/><path d="M95 253 L145 253 L155 285 Q120 301 85 285Z" fill="url(#iron)" stroke="#9a7547" stroke-width="3"/><circle cx="120" cy="272" r="10" fill="none" stroke="#d0a45c" stroke-width="2"/><path d="M120 261 L120 283 M109 272 L131 272 M112 264 L128 280 M128 264 L112 280" stroke="#d0a45c" stroke-width="1.5"/><path d="M56 99 L45 117 L59 111 M174 95 L190 113 L176 108" fill="none" stroke="#b45d42" stroke-width="3"/></svg>';
    const chat=document.createElement('div');
    chat.className='lampiao-chat';
    chat.innerHTML='<h3 class="lampiao-title">O Lampião Errante</h3><p class="lampiao-message"></p><div class="lampiao-detail"></div><div class="lampiao-actions"><button type="button" data-action="next">Seguir</button><button type="button" data-action="prev">Voltar</button><button type="button" data-action="about">Sobre esta etapa</button><button type="button" class="lampiao-close" data-action="close">Fechar guia</button></div>';
    const minimized=document.createElement('button');
    minimized.type='button'; minimized.className='lampiao-minimized'; minimized.textContent='✦'; minimized.setAttribute('aria-label','Reabrir o guia');
    root.append(chat,minimized);
    document.body.appendChild(root);
    const message=chat.querySelector('.lampiao-message');
    const detail=chat.querySelector('.lampiao-detail');
    const prev=chat.querySelector('[data-action="prev"]');
    const next=chat.querySelector('[data-action="next"]');
    const about=chat.querySelector('[data-action="about"]');
    const stageLines={
      'base':'Antes de distribuir qualquer coisa, confira o nome e os dados básicos. É aqui que a ficha ganha identidade. Não precisa correr: até heróis lendários começam preenchendo o próprio nome.',
      'atributos':'Força, Destreza, Constituição, Inteligência, Sabedoria e Carisma definem as capacidades do personagem. Para um Mago, Inteligência merece atenção especial: ela influencia suas magias e várias escolhas da ficha.',
      'pericias':'Aqui você distribui treinamento. Leia o uso de cada perícia e escolha aquelas que combinam com a história do personagem. Não confunda pontos de perícia com bônus de atributo; são partes diferentes do cálculo.',
      'talentos':'Este catálogo reúne talentos que concedem capacidades específicas. Confira os pré-requisitos antes de escolher: uma opção pode parecer excelente, mas não adianta cobiçar aquilo que seu personagem ainda não pode aprender.',
      'familiar':'Um familiar é um companheiro mágico, não um enfeite na margem da ficha. Abra o catálogo, compare as opções e escolha o vínculo que combina com seu Mago. Os detalhes da criatura ficam registrados na ficha.',
      'magia':'Primeiro vem a escola: ela define a tradição arcana do Mago e, se houver especialização, também as escolas proibidas. Depois você registra no Grimório as magias que as regras permitem. Na aba Preparação, escolhe quais das que já possui ficam preparadas.',
      'grimorio':'O Grimório é a coleção de magias que seu personagem aprendeu e mantém em seu livro. O catálogo mostra as opções; as escolhas válidas são registradas na ficha. Não confunda possuir uma magia com deixá-la preparada.',
      'resumo magico':'Este painel resume os dados mágicos calculados da ficha. Ele não substitui o Grimório: para adicionar ou preparar magias, volte à etapa Magia e abra o catálogo.',
      'equipamentos':'Confira o que o personagem carrega e veste. Armas, armaduras, escudos e carga podem influenciar valores da ficha. Se algo depender da decisão da campanha, combine com o Mestre.',
      'experiencia':'Aqui ficam os dados de experiência e progressão. Eles devem refletir o avanço definido na campanha, não uma escolha aleatória durante a criação.',
      'observacoes':'Use este espaço para registrar detalhes que ajudam a interpretar o personagem: hábitos, aparência, objetivos, promessas e informações importantes para a campanha.',

      'resistencias':'Fortitude, Reflexos e Vontade são suas três defesas. Constituição fortalece a Fortitude, Destreza ajuda nos Reflexos e Sabedoria sustenta a Vontade. Não são pontos de vida extras: são testes para resistir a perigos diferentes.',
      'base e agarrar':'O Bônus Base de Ataque acompanha a progressão da classe. Agarrar combina esse bônus com Força e ajustes aplicáveis. É a matemática por trás de acertar golpes e disputar força corpo a corpo.',
      'iniciativa':'Quando o combate começa, a Iniciativa ajuda a decidir quem age primeiro. O modificador de Destreza é a base; efeitos e talentos podem alterar o resultado.',
      'deslocamento':'Este valor indica quanto você consegue percorrer. Raça, classe, armadura, carga e habilidades podem mudar a distância. Confira o equipamento antes de culpar as próprias pernas.',
      'pontos de vida':'Pontos de Vida representam quanto dano o personagem suporta. O dado de vida vem da classe e Constituição acrescenta seu modificador. No primeiro nível, o dado de vida começa no valor máximo.',
      'armadura ca':'A Classe de Armadura reúne proteção da armadura, escudo, Destreza permitida, tamanho e outros bônus válidos. CA de toque e desprevenido ignoram partes diferentes dessa proteção.',
      'ataques':'Aqui ficam as formas de atacar e os bônus usados para acertar. Confira arma, proficiência, atributo e Bônus Base de Ataque. Uma arma que você não sabe usar costuma cobrar esse descuido.',
      'tracos raciais':'Estas características vêm da raça escolhida: sentidos, resistências, deslocamento e outras particularidades. Leia o que é aplicado automaticamente e o que serve como informação para a interpretação.',
      'varinhas e cajados':'Varinhas e cajados são itens mágicos com regras próprias de uso. Registre o que o personagem possui e consulte as descrições antes de tentar ativar um deles. Magia não é desculpa para apertar qualquer botão.',
      'capacidade de carga':'A carga depende do peso transportado e da Força. Ela pode afetar deslocamento e outras situações. Se a mochila parece carregar uma carroça, talvez seja hora de rever o inventário.',
      'idiomas':'Aqui você registra os idiomas que o personagem conhece. Raça, classe, Inteligência e escolhas permitidas podem influenciar essa lista. Conhecer um idioma não significa saber ler e escrever automaticamente.',
      'recipientes':'Mochilas, bolsas e outros recipientes ajudam a organizar o que o personagem carrega. Guarde cada item no lugar certo para manter o inventário compreensível.',
      'dinheiro':'Registre moedas e valores disponíveis para a campanha. Compras e recompensas alteram esse total; mantenha-o atualizado para não tentar pagar uma poção com promessas.',
      'experiencia':'A experiência acompanha o avanço do personagem. O Mestre define os ganhos da campanha; use este campo para manter o total e o nível coerentes.',
      'observacoes':'Anote aparência, objetivos, vínculos, hábitos e fatos importantes. É o espaço para aquilo que não cabe em números, mas que faz o personagem parecer alguém de verdade.',
      'resumo magico':'Este painel reúne os valores mágicos calculados e as escolhas de escola. Ele é um resumo, não o livro: para registrar ou preparar magias, abra o Grimório.',
      'equipamentos':'Confira armas, armaduras, escudos e itens carregados. Proficiência, peso e tipo de armadura podem afetar outros campos da ficha. Melhor descobrir isso aqui do que no meio de uma emboscada.'
    };
    const stageKey=item=>normalize((item&&item.sectionKey)|| (item&&item.label)||'');
    const stageText=item=>{
      const key=stageKey(item);
      const found=Object.keys(stageLines).find(k=>key.includes(k));
      if(found)return stageLines[found];
      const label=(item&&item.label)||'esta parte da ficha';
      const box=document.createElement('div');box.innerHTML=(item&&item.help)||'';
      const guidance=(box.textContent||'').replace(/\\s+/g,' ').trim();
      return guidance ? label+'. '+guidance+' Leia com atenção antes de seguir; não vou deixar você escolher no escuro.' : label+'. Esta escolha afeta os dados registrados na ficha. Confira os campos destacados e as regras indicadas antes de avançar.';
    };
    const detailText=item=>{
      const box=document.createElement('div');
      box.innerHTML=(item&&item.help)||'';
      const txt=(box.textContent||'').replace(/\s+/g,' ').trim();
      return txt||stageText(item);
    };
    const currentItem=()=>{const list=guideCandidates();return list[Math.max(0,Math.min(step,list.length-1))]||null;};
    const render=()=>{
      const list=guideCandidates();
      const item=currentItem();
      if(!item){message.textContent='A ficha está preenchida. Revise os dados e salve quando estiver tudo certo.';detail.textContent='';prev.disabled=true;next.disabled=true;return;}
      message.textContent=stageText(item);
      detail.textContent=detailText(item);
      prev.disabled=step<=0;
      next.disabled=step>=list.length-1;
      about.textContent=root.classList.contains('show-detail')?'Ocultar detalhes':'Sobre esta etapa';
    };
    const move=(delta)=>{
      const list=guideCandidates();
      const target=Math.max(0,Math.min(list.length-1,step+delta));
      if(target===step){render();return;}
      showStep(target);
      root.classList.remove('show-detail');
      render();
    };
    next.addEventListener('click',()=>move(1));
    prev.addEventListener('click',()=>move(-1));
    about.addEventListener('click',()=>{root.classList.toggle('show-detail');render();});
    const closeGuide=()=>{
      if(root.classList.contains('closed'))return;
      root.classList.remove('pop-in');root.classList.add('pop-out');
      window.setTimeout(()=>{root.classList.remove('pop-out');root.classList.add('closed');},260);
    };
    const reopen=()=>{
      root.classList.remove('closed');root.classList.add('pop-in');
      window.setTimeout(()=>root.classList.remove('pop-in'),320);
      render();
    };
    chat.querySelector('[data-action="close"]').addEventListener('click',closeGuide);
    minimized.addEventListener('click',reopen);
    const stepNote=document.getElementById('mage-step-note');
    if(stepNote){const stepObserver=new MutationObserver(()=>render());stepObserver.observe(stepNote,{subtree:true,childList:true,characterData:true,attributes:true});}
    render();
    window.setTimeout(()=>root.classList.add('pop-in'),100);
  }


  function bootMageSheet() {
    init().then(() => initOwlGuide()).catch(reportBootstrapError);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', bootMageSheet, { once: true });
  else bootMageSheet();
})();
