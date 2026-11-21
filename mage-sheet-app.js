/* D&D 3.5 — aplicação da ficha original do Mago.
 * Sessão Supabase existente; sem dependência do criador antigo de fichas.
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
  let sb, user, step = 0;
  const steps = [
    { title: 'Identidade', section: null, selector: '.header-top .input-group input', help: 'Comece pelo nome do personagem e pelos dados de identificação.' },
    { title: 'Atributos', section: 'Atributos', selector: '.attr-row input', help: 'Preencha os valores dos seis atributos. Os modificadores serão calculados na etapa de regras.' },
    { title: 'Resistências', section: 'Resistências', selector: '.resist-row input', help: 'Confira as resistências do Mago e os modificadores aplicáveis.' },
    { title: 'Perícias', section: 'Perícias', selector: 'table input', help: 'Distribua os pontos de perícia de acordo com a classe e a Inteligência.' },
    { title: 'Talentos', section: 'Talentos', selector: 'input,textarea,select', help: 'Registre o talento escolhido e suas informações.' },
    { title: 'Grimório', section: 'Grimório', selector: '.spell-level-block input', help: 'Registre as magias permanentes do grimório. A preparação será uma lista separada durante a campanha.' },
    { title: 'Equipamentos', section: 'Equipamentos', selector: 'input,textarea,select', help: 'Registre os equipamentos e seus pesos na própria ficha.' },
    { title: 'Idiomas', section: 'Idiomas', selector: 'textarea,input', help: 'Registre os idiomas conhecidos.' }
  ];
  function status(message, error) {
    const node = document.getElementById('mage-sheet-status');
    if (node) { node.textContent = message; node.dataset.error = error ? 'true' : 'false'; }
  }
  function addToolbar() {
    const bar = document.createElement('section');
    bar.id = 'mage-sheet-toolbar';
    bar.innerHTML = '<div class="mage-sheet-meta"><strong>FICHA DO MAGO · D&D 3.5</strong><span id="mage-sheet-status" role="status" aria-live="polite">Preparando ficha…</span></div><div class="mage-sheet-actions"><button type="button" id="mage-prev">Anterior</button><button type="button" id="mage-next">Próxima etapa</button><button type="button" id="mage-save">Salvar ficha</button></div>';
    const style = document.createElement('style');
    style.textContent = '#mage-sheet-toolbar{position:sticky;top:0;z-index:10001;display:flex;gap:14px;align-items:center;justify-content:space-between;flex-wrap:wrap;padding:10px 16px;margin:-20px -20px 18px;background:#1a120b;color:#f5e8c8;border-bottom:2px solid #b08d57;font:13px Georgia,serif}#mage-sheet-toolbar .mage-sheet-meta{display:flex;flex-direction:column;gap:3px}#mage-sheet-status{color:#d8c69f}#mage-sheet-status[data-error=true]{color:#ff9b8f}#mage-sheet-toolbar .mage-sheet-actions{display:flex;gap:8px;flex-wrap:wrap}#mage-sheet-toolbar button{padding:8px 13px;border:1px solid #b08d57;background:#332416;color:#f5e8c8;border-radius:4px;cursor:pointer;font-weight:700}#mage-sheet-toolbar button:disabled{opacity:.45;cursor:not-allowed}.mage-step-focus{outline:3px solid #1687d9!important;outline-offset:4px;box-shadow:0 0 0 6px #1687d955!important;position:relative;z-index:2}.mage-step-note{position:fixed;right:18px;bottom:18px;z-index:10002;max-width:340px;padding:14px 16px;background:#1a120b;color:#f5e8c8;border:1px solid #b08d57;border-radius:6px;box-shadow:0 8px 30px #0009;font:15px Georgia,serif}';
    document.head.appendChild(style);
    document.body.insertBefore(bar, document.body.firstChild);
    document.getElementById('mage-prev').addEventListener('click', () => showStep(step - 1));
    document.getElementById('mage-save').addEventListener('click', save);
  }
  function showStep(next) {
    step = Math.max(0, Math.min(steps.length - 1, next));
    document.querySelectorAll('.mage-step-focus').forEach(el => el.classList.remove('mage-step-focus'));
    const config = steps[step];
    let target = null;
    if (!config.section) target = document.querySelector(config.selector);
    else {
      const panel = Array.from(document.querySelectorAll('.panel')).find(p => (p.querySelector('.panel-title')?.textContent || '').toLowerCase().includes(config.section.toLowerCase()));
      target = (panel && panel.querySelector(config.selector)) || (config.section === 'Grimório' ? document.querySelector(config.selector) : null);
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
    document.getElementById('mage-next').textContent = step === steps.length - 1 ? 'Concluir orientação' : 'Próxima etapa';
    if (step === steps.length - 1) document.getElementById('mage-next').onclick = () => { note.remove(); document.querySelectorAll('.mage-step-focus').forEach(el => el.classList.remove('mage-step-focus')); status('Orientação concluída. Você pode revisar e editar qualquer campo.'); };
    else document.getElementById('mage-next').onclick = () => showStep(step + 1);
  }
  async function loadCharacter() {
    const result = await sb.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
    if (result.error) throw result.error;
    if (!result.data) throw new Error('Ficha não encontrada ou sem permissão de leitura.');
    const identity = result.data.identidade && typeof result.data.identidade === 'object' ? result.data.identidade : {};
    core.hydrate(identity.ficha_mago_v2 || identity.ficha_original_v1);
    status('Ficha carregada. Edite os campos e salve quando terminar.');
  }
  async function save() {
    if (!characterId) {
      const key = 'dnd35-mage-draft:' + user.id + ':' + String(raceId || 'race');
      localStorage.setItem(key, JSON.stringify({ version: core.version, raceId, classId, snapshot: core.collect() }));
      status('Rascunho salvo neste navegador. A criação definitiva no banco ainda não foi concluída.', true);
      return;
    }
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
        sb.from('srd_races').select('id,nome').eq('id', raceId).maybeSingle(),
        sb.from('srd_classes').select('id,nome,class_key').eq('id', classId).maybeSingle(),
        sb.from('profiles').select('username').eq('id', user.id).maybeSingle()
      ]);
      if (race.error || klass.error) throw race.error || klass.error;
      if (!race.data || !klass.data || !/mago|wizard/i.test(String(klass.data.nome) + ' ' + String(klass.data.class_key))) throw new Error('Nesta etapa, a ficha nova está habilitada exclusivamente para a classe Mago.');
      core.applyIdentity({ raceName: race.data.nome, playerName: profile.data?.username || user.email?.split('@')[0] || '' });
      const draftKey = 'dnd35-mage-draft:' + user.id + ':' + raceId;
      const draft = localStorage.getItem(draftKey);
      if (draft) { try { const parsed = JSON.parse(draft); if (parsed.snapshot) core.hydrate(parsed.snapshot); } catch (_) {} }
      status('Ficha nova aberta no modelo original. Preencha os campos destacados; rascunho local disponível.');
    } else if (characterId) await loadCharacter();
    else throw new Error('Abra a ficha a partir do Lobby ou da Mesa.');
    showStep(0);
  }
  document.addEventListener('DOMContentLoaded', () => init().catch(error => status(error.message || String(error), true)));
})();
