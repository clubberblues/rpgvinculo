(function(){
  if(window.vttUI)return;
  var dialog=document.createElement('dialog');
  dialog.className='vtt-ui-dialog';
  dialog.setAttribute('aria-labelledby','vtt-ui-title');
  dialog.innerHTML='<header class="vtt-ui-head"><h2 id="vtt-ui-title"></h2></header><div class="vtt-ui-body"><div id="vtt-ui-message"></div><label id="vtt-ui-label" for="vtt-ui-field" hidden></label><input id="vtt-ui-field" class="vtt-ui-field" autocomplete="off" hidden><select id="vtt-ui-select" class="vtt-ui-field" hidden></select></div><footer class="vtt-ui-actions"><button type="button" data-vtt-cancel>Cancelar</button><button type="button" class="primary" data-vtt-ok>Continuar</button></footer>';
  document.body.appendChild(dialog);
  var title=dialog.querySelector('#vtt-ui-title'),message=dialog.querySelector('#vtt-ui-message'),label=dialog.querySelector('#vtt-ui-label'),input=dialog.querySelector('#vtt-ui-field'),select=dialog.querySelector('#vtt-ui-select'),cancel=dialog.querySelector('[data-vtt-cancel]'),ok=dialog.querySelector('[data-vtt-ok]');
  var tail=Promise.resolve();
  function enqueue(opts){
    var task=tail.then(function(){return new Promise(function(resolve){
      opts=opts||{};title.textContent=String(opts.title||'Vínculo');message.textContent=String(opts.message||'');
      var editable=opts.kind==='input'||opts.kind==='textarea'||opts.kind==='select';
      label.hidden=!editable;label.textContent=String(opts.label||'');
      input.hidden=opts.kind!=='input'&&opts.kind!=='textarea';input.type=opts.inputMode==='numeric'?'number':'text';input.value=String(opts.defaultValue==null?'':opts.defaultValue);input.placeholder=String(opts.placeholder||'');input.setAttribute('aria-label',String(opts.label||opts.title||'Informação'));
      input.style.height=opts.kind==='textarea'?'112px':'';if(opts.kind==='textarea')input.setAttribute('data-multiline','true');else input.removeAttribute('data-multiline');
      if(opts.kind==='textarea')input.setAttribute('style','height:112px');
      select.hidden=opts.kind!=='select';select.replaceChildren();
      (opts.options||[]).forEach(function(option){var el=document.createElement('option');el.value=String(option.value);el.textContent=String(option.label);select.appendChild(el);});
      if(opts.kind==='select'&&opts.defaultValue!=null)select.value=String(opts.defaultValue);
      cancel.hidden=opts.type==='alert';ok.textContent=String(opts.okLabel||(opts.type==='alert'?'Entendi':'Confirmar'));ok.className=opts.danger?'danger':'primary';
      var settled=false,previous=document.activeElement;
      function finish(value){if(settled)return;settled=true;dialog.removeEventListener('cancel',onCancel);dialog.close();if(previous&&previous.focus)previous.focus();resolve(value);}
      function onCancel(event){event.preventDefault();finish(opts.type==='confirm'?false:null);}
      dialog.addEventListener('cancel',onCancel);
      cancel.onclick=function(){finish(opts.type==='confirm'?false:null);};
      ok.onclick=function(){finish(opts.type==='confirm'?true:(opts.kind==='input'||opts.kind==='textarea'?input.value:(opts.kind==='select'?select.value:true)));};
      dialog.showModal();
      if(opts.kind==='input'||opts.kind==='textarea')input.focus();else if(opts.kind==='select')select.focus();else ok.focus();
      if(opts.kind==='input')input.onkeydown=function(event){if(event.key==='Enter'){event.preventDefault();ok.click();}};
    });});
    tail=task.then(function(){},function(){});
    return task;
  }
  window.vttUI={alert:function(message,title){return enqueue({type:'alert',title:title||'Aviso',message:message,okLabel:'Entendi'});},confirm:function(opts){opts=opts||{};opts.type='confirm';opts.okLabel=opts.okLabel||'Confirmar';return enqueue(opts);},ask:function(opts){opts=opts||{};opts.kind=opts.kind||'input';opts.okLabel=opts.okLabel||'Salvar';return enqueue(opts);}};
  window.alert=function(message){window.vttUI.alert(message);};
})();