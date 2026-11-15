/* Vínculo — abas de Chat e LOG.
   Não injeta controles de zoom, não intercepta a roda do mouse e não transforma o grid.
   A escala do campo continua fixa em 1 quadrado = 1,5 m; os gestos nativos já existentes
   no editor/campo de batalha permanecem sob controle do próprio mesa.html. */
(function(){
  'use strict';
  function attachChat(){
    var list=document.getElementById('chat-lista'),panel=list&&list.closest('.painel-chat-mesa');
    if(!list||!panel||panel.dataset.friendsChat==='1')return;
    panel.dataset.friendsChat='1';
    var head=panel.querySelector('.painel-cab');
    if(head)head.textContent='Comunicação da mesa';
    var tabs=document.createElement('div');
    tabs.className='friends-chat-tabs';
    tabs.innerHTML='<button type="button" data-view="chat" aria-pressed="true">CHAT</button><button type="button" data-view="log" aria-pressed="false">LOG</button>';
    list.parentNode.insertBefore(tabs,list);
    tabs.addEventListener('click',function(e){
      var b=e.target.closest('[data-view]');if(!b)return;
      var mode=b.dataset.view;
      tabs.querySelectorAll('button').forEach(function(x){x.setAttribute('aria-pressed',String(x===b));});
      panel.classList.toggle('friends-show-log',mode==='log');
      panel.classList.toggle('friends-show-chat',mode==='chat');
      list.scrollTop=list.scrollHeight;
    });
    panel.classList.add('friends-show-chat');
  }
  function attach(){attachChat();}
  if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',attach);else attach();
  new MutationObserver(attach).observe(document.documentElement,{childList:true,subtree:true});
})();
