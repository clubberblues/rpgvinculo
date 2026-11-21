/* D&D 3.5 — núcleo independente da ficha original do Mago.
 * Não depende do wizard antigo nem altera a estrutura visual da ficha.
 */
(function (global) {
  'use strict';
  const VERSION = 2;
  const norm = value => String(value || '').normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_+|_+$/g, '');
  const clean = node => (node && node.textContent || '').replace(/\s+/g, ' ').trim();
  const sectionOf = el => {
    const panel = el.closest('.panel');
    const title = panel && panel.querySelector('.panel-title');
    if (title) return clean(title);
    const spell = el.closest('.spell-level-block');
    if (spell) return clean(spell.querySelector('.spell-level-title')) || 'Grimorio';
    return 'Cabecalho';
  };
  const rowOf = el => {
    const attr = el.closest('.attr-row');
    if (attr) return clean(attr.querySelector('.attr-name')) || 'atributos';
    const resist = el.closest('.resist-row');
    if (resist) return clean(resist.querySelector('.resist-name')) || 'resistencias';
    const tr = el.closest('tr');
    if (tr) {
      const cells = Array.from(tr.children);
      const cell = el.closest('td,th');
      const idx = cells.indexOf(cell);
      const name = clean(cells[0]);
      const headers = tr.closest('table') && tr.closest('table').querySelectorAll('thead th');
      const column = headers && headers[idx] ? clean(headers[idx]) : 'coluna_' + (idx + 1);
      return [name || 'linha', column || 'campo'].join('.');
    }
    const attack = el.closest('.atk-block');
    if (attack) {
      const blockIndex = Array.from(attack.parentElement.querySelectorAll('.atk-block')).indexOf(attack) + 1;
      const label = el.parentElement && clean(el.parentElement.querySelector('label'));
      return 'ataque_' + blockIndex + '.' + (label || 'campo');
    }
    const group = el.closest('.input-group');
    if (group) return clean(group.querySelector('label')) || 'campo';
    const parent = el.parentElement;
    const label = parent && parent.querySelector('label');
    if (label && label !== el) return clean(label);
    const siblingText = parent && Array.from(parent.childNodes).filter(n => n.nodeType === 3).map(n => n.textContent.trim()).filter(Boolean).join(' ');
    return siblingText || el.getAttribute('aria-label') || el.getAttribute('placeholder') || 'campo_sem_rotulo';
  };
  function fieldKey(el, index) {
    if (el.dataset.sheetField) return el.dataset.sheetField;
    const section = norm(sectionOf(el)) || 'ficha';
    const row = norm(rowOf(el)) || 'campo';
    const same = Array.from(document.querySelectorAll('input,textarea,select')).filter(other => other !== el && norm(sectionOf(other)) === section && norm(rowOf(other)) === row);
    const key = section + '.' + row + (same.length ? '.' + (Array.from(document.querySelectorAll('input,textarea,select')).filter(other => norm(sectionOf(other)) === section && norm(rowOf(other)) === row).indexOf(el) + 1) : '');
    el.dataset.sheetField = key || ('campo_' + index);
    return el.dataset.sheetField;
  }
  function controls() {
    return Array.from(document.querySelectorAll('.ficha input, .ficha textarea, .ficha select'))
      .filter(el => el.type !== 'file' && el.id !== 'portrait-input' && !el.disabled);
  }
  function read(el) {
    if (el.type === 'checkbox') return !!el.checked;
    if (el.type === 'radio') return el.checked ? el.value : undefined;
    if (el.tagName === 'SELECT' && el.multiple) return Array.from(el.selectedOptions).map(o => o.value);
    return el.value;
  }
  function collect() {
    const fields = {};
    controls().forEach((el, index) => {
      const value = read(el);
      if (value !== undefined) fields[fieldKey(el, index)] = value;
    });
    return { version: VERSION, updated_at: new Date().toISOString(), fields };
  }
  function hydrate(snapshot) {
    if (!snapshot || ![1, VERSION].includes(Number(snapshot.version)) || !snapshot.fields) return;
    controls().forEach((el, index) => {
      const key = fieldKey(el, index);
      if (!Object.prototype.hasOwnProperty.call(snapshot.fields, key)) return;
      const value = snapshot.fields[key];
      if (el.type === 'checkbox') el.checked = !!value;
      else if (el.type === 'radio') el.checked = el.value === value;
      else if (el.tagName === 'SELECT' && el.multiple && Array.isArray(value)) {
        Array.from(el.options).forEach(o => { o.selected = value.includes(o.value); });
      } else el.value = value == null ? '' : String(value);
    });
  }
  function findHeaderField(label) {
    const target = norm(label);
    return Array.from(document.querySelectorAll('.header-top .input-group, .ficha > .input-line .input-group'))
      .find(group => norm(clean(group.querySelector('label'))) === target)?.querySelector('input,textarea,select') || null;
  }
  function findSectionField(section, row) {
    const target = norm(section);
    const panel = Array.from(document.querySelectorAll('.panel')).find(p => norm(clean(p.querySelector('.panel-title'))) === target);
    if (!panel) return null;
    const rowNode = Array.from(panel.querySelectorAll('.attr-row,.resist-row,tr,.input-group')).find(r => norm(rowOf(r.querySelector('input,textarea,select') || r)) === norm(row));
    return rowNode && rowNode.querySelector('input,textarea,select');
  }
  function applyIdentity(identity) {
    if (!identity) return;
    const classField = findHeaderField('Classe');
    const raceField = findHeaderField('Raça');
    if (classField) classField.value = 'Mago';
    if (raceField && identity.raceName) raceField.value = identity.raceName;
    const playerField = findHeaderField('Jogador');
    if (playerField && identity.playerName) playerField.value = identity.playerName;
    const campaignField = findHeaderField('Campanha');
    if (campaignField && identity.campaignName) campaignField.value = identity.campaignName;
    const levelField = findHeaderField('Nível');
    if (levelField && !levelField.value) levelField.value = '1';
  }
  global.DND35MageSheetCore = { version: VERSION, collect, hydrate, controls, applyIdentity, fieldKey };
})(window);
