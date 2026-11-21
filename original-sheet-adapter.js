/* D&D 3.5 — adaptador da ficha original enviada pelo usuário.
 * Não altera o layout. Persiste os campos visuais em identidade.ficha_original_v1.
 * O RLS do Supabase continua sendo a autoridade de autorização.
 */
(function () {
  'use strict';
  var params = new URLSearchParams(location.search);
  var characterId = params.get('char');
  var supabaseUrl = 'https://grrgwxcagvvafdmzsmro.supabase.co';
  var supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzkwMjU2ODE0LCJleHAiOjIxMDU4MzI4MTJ9.hqLiYynGXHwyUtqcbGTTa2orSStm7ko2C5R03QNmqtQ';
  var client = null;
  var statusNode = null;
  var saveButton = null;

  function slug(value) {
    return String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '')
      .toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '').slice(0, 72) || 'campo';
  }
  function sectionName(el) {
    var panel = el.closest('.panel, section, fieldset, article');
    if (panel) {
      var heading = panel.querySelector('h1,h2,h3,h4,legend,.panel-title,.section-title');
      if (heading && heading.textContent.trim()) return heading.textContent.trim();
    }
    var previous = el.closest('tr') || el.parentElement;
    for (var depth = 0; previous && depth < 5; depth++, previous = previous.parentElement) {
      var title = previous.querySelector(':scope > h1,:scope > h2,:scope > h3,:scope > h4,:scope > legend');
      if (title && title.textContent.trim()) return title.textContent.trim();
    }
    return 'Ficha';
  }
  function fieldLabel(el) {
    if (el.id) {
      var label = document.querySelector('label[for="' + CSS.escape(el.id) + '"]');
      if (label && label.textContent.trim()) return label.textContent.trim();
    }
    var row = el.closest('tr');
    if (row) {
      var cells = Array.from(row.children);
      var index = cells.indexOf(el.closest('td,th'));
      var preceding = cells.slice(0, Math.max(0, index)).map(function (c) { return c.textContent.trim(); }).filter(Boolean);
      if (preceding.length) return preceding.join(' ');
    }
    var parent = el.parentElement;
    if (parent) {
      var text = Array.from(parent.childNodes).filter(function (n) { return n.nodeType === 3; })
        .map(function (n) { return n.textContent.trim(); }).filter(Boolean).join(' ');
      if (text) return text;
      var nearby = parent.querySelector('label,span,strong,b');
      if (nearby && nearby !== el && nearby.textContent.trim()) return nearby.textContent.trim();
    }
    return el.getAttribute('placeholder') || el.getAttribute('aria-label') || el.name || 'campo';
  }
  function controls() {
    return Array.from(document.querySelectorAll('input,textarea,select')).filter(function (el) {
      return el.type !== 'file' && el.id !== 'portrait-input' && !el.disabled;
    });
  }
  function keyMap() {
    var counts = Object.create(null);
    return controls().map(function (el) {
      if (el.dataset.sheetField) return [el, el.dataset.sheetField];
      var base = slug(sectionName(el)) + '.' + slug(fieldLabel(el));
      counts[base] = (counts[base] || 0) + 1;
      var key = base + (counts[base] > 1 ? '.' + counts[base] : '');
      el.dataset.sheetField = key;
      return [el, key];
    });
  }
  function readValue(el) {
    if (el.type === 'checkbox') return !!el.checked;
    if (el.type === 'radio') return el.checked ? el.value : undefined;
    if (el.tagName === 'SELECT' && el.multiple) return Array.from(el.selectedOptions).map(function (o) { return o.value; });
    return el.value;
  }
  function collect() {
    var fields = {};
    keyMap().forEach(function (pair) {
      var value = readValue(pair[0]);
      if (value !== undefined) fields[pair[1]] = value;
    });
    return { version: 1, updated_at: new Date().toISOString(), fields: fields };
  }
  function hydrate(snapshot) {
    if (!snapshot || snapshot.version !== 1 || !snapshot.fields) return;
    keyMap().forEach(function (pair) {
      var el = pair[0], key = pair[1];
      if (!Object.prototype.hasOwnProperty.call(snapshot.fields, key)) return;
      var value = snapshot.fields[key];
      if (el.type === 'checkbox') el.checked = !!value;
      else if (el.type === 'radio') el.checked = el.value === value;
      else if (el.tagName === 'SELECT' && el.multiple && Array.isArray(value)) {
        Array.from(el.options).forEach(function (o) { o.selected = value.indexOf(o.value) >= 0; });
      } else el.value = value == null ? '' : String(value);
    });
  }
  function setStatus(message, isError) {
    if (!statusNode) return;
    statusNode.textContent = message;
    statusNode.style.color = isError ? '#8b2118' : '#42602b';
  }
  function installControls() {
    var bar = document.createElement('div');
    bar.id = 'original-sheet-save-bar';
    bar.setAttribute('role', 'region');
    bar.setAttribute('aria-label', 'Salvamento da ficha');
    bar.style.cssText = 'position:sticky;top:0;z-index:10000;display:flex;gap:12px;align-items:center;justify-content:flex-end;padding:8px 14px;background:#20190f;border:1px solid #b89050;color:#f5ecd6;font:14px Georgia,serif';
    statusNode = document.createElement('span');
    statusNode.setAttribute('aria-live', 'polite');
    statusNode.style.marginRight = 'auto';
    statusNode.textContent = characterId ? 'Ficha pronta para carregar.' : 'Selecione um personagem existente para salvar.';
    saveButton = document.createElement('button');
    saveButton.type = 'button';
    saveButton.textContent = 'Salvar ficha';
    saveButton.disabled = !characterId;
    saveButton.style.cssText = 'padding:8px 16px;border:1px solid #d6b56d;background:#5a4320;color:#fff1ce;border-radius:4px;font-weight:bold;cursor:pointer';
    saveButton.addEventListener('click', save);
    bar.append(statusNode, saveButton);
    document.body.insertBefore(bar, document.body.firstChild);
  }
  async function connect() {
    if (window.supabase && window.supabase.createClient) {
      client = window.supabase.createClient(supabaseUrl, supabaseKey);
      return;
    }
    await new Promise(function (resolve, reject) {
      var script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
      script.onload = resolve;
      script.onerror = function () { reject(new Error('Não foi possível carregar o cliente Supabase.')); };
      document.head.appendChild(script);
    });
    client = window.supabase.createClient(supabaseUrl, supabaseKey);
  }
  async function load() {
    if (!characterId) return;
    var result = await client.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
    if (result.error) throw result.error;
    if (!result.data) throw new Error('Ficha SRD não encontrada ou sem permissão de leitura.');
    var identity = result.data.identidade || {};
    hydrate(identity.ficha_original_v1);
    setStatus('Ficha carregada. Alterações ainda não salvas.');
  }
  async function save() {
    if (!client || !characterId || saveButton.disabled) return;
    saveButton.disabled = true;
    setStatus('Salvando…');
    try {
      var current = await client.from('srd_character_sheets').select('identidade').eq('character_id', characterId).maybeSingle();
      if (current.error) throw current.error;
      if (!current.data) throw new Error('Ficha não encontrada ou sem permissão.');
      var identity = current.data.identidade && typeof current.data.identidade === 'object' ? current.data.identidade : {};
      identity.ficha_original_v1 = collect();
      var updated = await client.from('srd_character_sheets').update({ identidade: identity }).eq('character_id', characterId).select('character_id').maybeSingle();
      if (updated.error) throw updated.error;
      if (!updated.data) throw new Error('O banco não confirmou a gravação. Verifique as permissões da ficha.');
      setStatus('Salvo. ' + Object.keys(identity.ficha_original_v1.fields).length + ' campos registrados.');
    } catch (error) {
      console.error('[ficha original]', error);
      setStatus('Falha ao salvar: ' + (error.message || 'erro desconhecido'), true);
    } finally {
      saveButton.disabled = false;
    }
  }
  window.DND35OriginalSheet = { collect: collect, hydrate: hydrate, save: save, keyMap: keyMap };
  document.addEventListener('DOMContentLoaded', async function () {
    installControls();
    try { await connect(); await load(); }
    catch (error) { console.error('[ficha original]', error); setStatus(error.message || 'Falha ao inicializar.', true); }
  });
})();
