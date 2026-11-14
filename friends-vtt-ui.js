/* Interface enxuta do VTT entre amigos — camada aditiva, sem alterar regras do jogo. */
(function(){
  'use strict';
  var SCALE_MIN=0.65,SCALE_MAX=2.5,SCALE_STEP=1.15;
  function board(){return document.getElementById('area-tabuleiro');}
  function world(){return document.getElementById('cba-live-world');}
  function currentZoom(){var w=world();return w?(Number(getComputedStyle(w).getPropertyValue('--cba-zoom'))||1):1;}
  function setZoom(value){
    var w=world();if(!w)return;
    var z=Math.max(SCALE_MIN,Math.min(SCALE_MAX,Number(value)||1));
    w.style.setProperty('--cba-zoom',String(z));
    var label=document.getElementById('friends-zoom-value');
    if(label)label.textContent=Math.round(z*100)+'%';
  }
  function attachBoard(){
    var area=board();if(!area||area.dataset.friendsUi==='1')return;
    area.dataset.friendsUi='1';
    var controls=document.createElement('div');
    controls.className='friends-map-controls';
    controls.setAttribute('aria-label','Controles de visualização do mapa');
    controls.innerHTML='<span class="friends-grid-note">1 quadrado = 1,5 m</span><button type="button" data-zoom="out" aria-label="Diminuir zoom">−</button><output id="friends-zoom-value">100%</output><button type="button" data-zoom="in" aria-label="Aumentar zoom">+</button><button type="button" data-zoom="reset" aria-label="Restaurar zoom">↺</button>';
    area.appendChild(controls);
    controls.addEventListener('click',function(e){
      var b=e.target.closest('[data-zoom]');if(!b)return;
      var z=currentZoom();
      if(b.dataset.zoom==='in')setZoom(z*SCALE_STEP);
      else if(b.dataset.zoom==='out')setZoom(z/SCALE_STEP);
      else setZoom(1);
    });
    area.addEventListener('wheel',function(e){
      if(e.target.closest&&e.target.closest('.friends-map-controls'))return;
      e.preventDefault();
      setZoom(currentZoom()*(e.deltaY<0?1.08:0.92));
    },{passive:false});
    setZoom(currentZoom());
  }
  function attachChat(){
    var list=document.getElementById('chat-lista'),panel=list&&list.closest('.painel');
    if(!list||!panel||panel.dataset.friendsChat==='1')return;
    panel.dataset.friendsChat='1';
    var head=panel.querySelector('.painel-cab');
    if(head)head.textContent='Comunicação da mesa';
    var tabs=document.createElement('div');tabs.className='friends-chat-tabs';
    tabs.innerHTML='<button type="button" data-view="chat" aria-pressed="true">CHAT</button><button type="button" data-view="log" aria-pressed="false">LOG</button>';
    list.parentNode.insertBefore(tabs,list);
    tabs.addEventListener('click',function(e){
      var b=e.target.closest('[data-view]');if(!b)return;
      var mode=b.dataset.view;
      tabs.querySelectorAll('button').forEach(function(x){x.setAttribute('aria-pressed',String(x===b));});
      panel.classList.toggle('friends-show-log',mode==='log');
      panel.classList.toggle('friends-show-chat',mode==='chat');
    });
    panel.classList.add('friends-show-chat');
  }
  function injectStyle(){
    if(document.getElementById('friends-vtt-ui-style'))return;
    var s=document.createElement('style');s.id='friends-vtt-ui-style';
    s.textContent='.friends-map-controls{position:absolute;z-index:80;right:12px;top:12px;display:flex;align-items:center;gap:6px;padding:7px;border:1px solid #b99a5b;border-radius:9px;background:rgba(12,18,15,.92);box-shadow:0 5px 18px #0008;color:#f5ecd6;font:700 11px system-ui,sans-serif}.friends-map-controls button{width:34px;height:34px;border:1px solid #76623c;border-radius:6px;background:#1c2a20;color:#f1d18a;font-size:20px;cursor:pointer}.friends-map-controls button:focus-visible,.friends-chat-tabs button:focus-visible{outline:2px solid #f5d98d;outline-offset:2px}.friends-map-controls output{min-width:42px;text-align:center;font-variant-numeric:tabular-nums}.friends-grid-note{padding:0 5px;color:#e5d4ae;white-space:nowrap}.friends-chat-tabs{display:flex;gap:6px;padding:7px 10px;background:#131d16;border-bottom:1px solid #665638}.friends-chat-tabs button{flex:1;min-height:34px;border:1px solid #75613d;border-radius:6px;background:#1b2419;color:#c9b98f;font:700 10px Cinzel,serif;letter-spacing:1px}.friends-chat-tabs button[aria-pressed=true]{background:#3b3321;border-color:#d0aa5d;color:#fff0c7}.friends-show-chat #chat-lista .chat-msg.sistema,.friends-show-chat #chat-lista .chat-msg.rolagem{display:none}.friends-show-log #chat-lista .chat-msg:not(.sistema):not(.rolagem){display:none}@media(max-width:700px){.friends-map-controls{top:8px;right:8px;gap:4px;padding:5px}.friends-map-controls button{width:32px;height:32px}.friends-grid-note{font-size:10px}}';
    document.head.appendChild(s);
  }
  function attach(){injectStyle();attachBoard();attachChat();}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',attach);else attach();
  new MutationObserver(attach).observe(document.documentElement,{childList:true,subtree:true});
})();
