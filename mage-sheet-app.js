    style.textContent = `\n      .mage-step-note,.mage-guide-toggle{display:none!important}\n
      #dnd35-owl-guide{position:fixed;left:50%;top:50%;transform:translate(-50%,-50%);z-index:10050;display:flex;align-items:flex-end;gap:12px;font-family:'EB Garamond',Georgia,serif;pointer-events:none;max-width:calc(100vw - 28px);max-height:calc(100vh - 24px)}
      #dnd35-owl-guide *{box-sizing:border-box}
      #dnd35-owl-guide .lampiao-stage{pointer-events:auto;position:relative;width:126px;height:168px;flex:0 0 auto;transform-origin:50% 70%;isolation:isolate;animation:lampiao-idle 5.6s ease-in-out infinite;display:grid;place-items:center} 
      #dnd35-owl-guide .lampiao-stage.no-art:after{content:'🏮';position:absolute;inset:0;display:grid;place-items:center;font:100px/1 serif;filter:drop-shadow(0 0 18px #ff9b32);opacity:1;background:none;animation:none}
      #dnd35-owl-guide .lampiao-art{position:relative;z-index:2;width:100%;height:100%;object-fit:contain;object-position:center bottom;filter:drop-shadow(0 9px 13px rgba(0,0,0,.62));transform-origin:50% 70%;animation:lampiao-body-sway 6.8s ease-in-out infinite}
      #dnd35-owl-guide .lampiao-stage:before{content:"";position:absolute;z-index:1;left:28%;right:28%;bottom:7%;height:32%;border-radius:50%;background:radial-gradient(ellipse,rgba(255,179,66,.48),rgba(183,76,23,.17) 48%,transparent 74%);filter:blur(13px);animation:lampiao-ember 2.7s ease-in-out infinite}
      #dnd35-owl-guide .lampiao-stage:after{content:"";position:absolute;z-index:3;left:44%;top:0;width:34%;height:42%;pointer-events:none;background:radial-gradient(ellipse at 50% 85%,rgba(190,184,165,.23),rgba(132,130,120,.10) 35%,transparent 72%);filter:blur(8px);opacity:0;animation:lampiao-smoke 7s ease-in-out infinite}
      #dnd35-owl-guide .lampiao-stage.reacting{animation:lampiao-react .48s cubic-bezier(.2,.8,.2,1)}
      #dnd35-owl-guide .lampiao-stage.reacting .lampiao-art{animation:lampiao-react-body .48s cubic-bezier(.2,.8,.2,1)}
      #dnd35-owl-guide .lampiao-stage.speaking .lampiao-art{animation:lampiao-speaking 1.1s ease-in-out 2}
      #dnd35-owl-guide .lampiao-stage.speaking:before{animation:lampiao-ember  .65s ease-in-out infinite}
      #dnd35-owl-guide .lampiao-chat{pointer-events:auto;width:min(310px,calc(100vw - 155px));min-width:210px;padding:12px 14px 11px;background:linear-gradient(145deg,#fff4d8,#e5cf9f);color:#392817;border:2px solid #ae8345;border-radius:13px 13px 13px 3px;box-shadow:0 12px 34px rgba(0,0,0,.48),inset 0 0 18px rgba(255,255,255,.3);position:relative;margin-bottom:15px}
      #dnd35-owl-guide .lampiao-chat:before{content:"";position:absolute;left:-9px;bottom:28px;width:14px;height:14px;background:#e9d7ae;border-left:2px solid #ae8345;border-bottom:2px solid #ae8345;transform:rotate(45deg)}
      #dnd35-owl-guide .lampiao-title{font:900 11px Cinzel,Georgia,serif;letter-spacing:1.5px;text-transform:uppercase;color:#765020;margin:0 0 7px}
      #dnd35-owl-guide .lampiao-message{font-size:15px;line-height:1.35;margin:0;white-space:pre-line}
      #dnd35-owl-guide .lampiao-detail{display:none;margin-top:9px;padding-top:8px;border-top:1px solid rgba(139,103,52,.35);font-size:13px;line-height:1.4;color:#5a4128}
      #dnd35-owl-guide.show-detail .lampiao-detail{display:block}
      #dnd35-owl-guide .lampiao-actions{display:flex;gap:7px;flex-wrap:wrap;margin-top:13px}
      #dnd35-owl-guide .lampiao-actions button{border:1px solid #9b733c;border-radius:5px;background:linear-gradient(#f8e8c4,#dfc18c);color:#3b2917;padding:7px 10px;font:700 10px Cinzel,Georgia,serif;cursor:pointer;transition:transform .16s,box-shadow .16s}
      #dnd35-owl-guide .lampiao-actions button:hover:not(:disabled){transform:translateY(-2px);box-shadow:0 3px 9px #79501e55}
      #dnd35-owl-guide .lampiao-actions button:disabled{opacity:.38;cursor:not-allowed}
      #dnd35-owl-guide .lampiao-actions .lampiao-close{margin-left:auto;background:linear-gradient(#6a3024,#421d17);border-color:#8e5a43;color:#f8e7c7}
      #dnd35-owl-guide .lampiao-minimized{display:none;pointer-events:auto;align-items:center;gap:7px;padding:5px 11px 5px 7px;border-radius:22px;border:1px solid #d69b48;background:linear-gradient(120deg,#342014,#1b120d);box-shadow:0 0 12px #e77b2744,0 3px 10px #0008;cursor:pointer;color:#ffe3a5;font:700 11px Cinzel,Georgia,serif;letter-spacing:1px}#dnd35-owl-guide .lampiao-minimized:before{content:'✦';display:grid;place-items:center;width:27px;height:27px;border-radius:50%;background:radial-gradient(circle,#ffcc68 0%,#a64a18 55%,#21130d 80%);font-size:17px}
      #dnd35-owl-guide.closed .lampiao-stage,#dnd35-owl-guide.closed .lampiao-chat{display:none}
      #dnd35-owl-guide.closed .lampiao-minimized{display:flex;place-items:center}
      #dnd35-owl-guide.pop-out .lampiao-stage,#dnd35-owl-guide.pop-out .lampiao-chat{animation:lampiao-pop-out .25s cubic-bezier(.2,.8,.3,1) forwards}
      #dnd35-owl-guide.pop-in .lampiao-stage,#dnd35-owl-guide.pop-in .lampiao-chat{animation:lampiao-pop-in .3s cubic-bezier(.2,.8,.3,1) both}
      #dnd35-owl-guide.closed{left:12px;top:12px;right:auto;bottom:auto;transform:none;max-height:none}
      @keyframes lampiao-idle{0%,100%{transform:translateY(0)}45%{transform:translateY(-3px)}75%{transform:translateY(1px)}}
      @keyframes lampiao-body-sway{0%,100%{transform:rotate(0) translateX(0)}28%{transform:rotate(-.7deg) translateX(-1px)}66%{transform:rotate(.55deg) translateX(1px)}}
      @keyframes lampiao-ember{0%,100%{opacity:.56;transform:scale(.88)}50%{opacity:1;transform:scale(1.13)}}
      @keyframes lampiao-smoke{0%,70%,100%{opacity:0;transform:translate(0,12px) scale(.72)}76%{opacity:.45}92%{opacity:.1;transform:translate(9px,-20px) scale(1.35)}}
      @keyframes lampiao-react{0%{transform:scale(1)}32%{transform:scale(1.055) translateY(-5px)}65%{transform:scale(.98) translateY(1px)}100%{transform:scale(1)}}
      @keyframes lampiao-react-body{0%,100%{transform:rotate(0)}30%{transform:rotate(-2deg)}68%{transform:rotate(1deg)}}
      @keyframes lampiao-speaking{0%,100%{transform:translateY(0) rotate(0)}25%{transform:translateY(-2px) rotate(-.6deg)}55%{transform:translateY(0) rotate(.6deg)}}
      @media(max-width:680px){#dnd35-owl-guide .lampiao-stage{width:88px;height:124px}}
      @media(prefers-reduced-motion:reduce){#dnd35-owl-guide .lampiao-stage,#dnd35-owl-guide .lampiao-art,#dnd35-owl-guide .lampiao-stage:before,#dnd35-owl-guide .lampiao-stage:after{animation:none}}

      @keyframes lampiao-pop-out{0%{transform:scale(1);opacity:1}30%{transform:scale(1.15);opacity:1}100%{transform:scale(0);opacity:0}}
      @keyframes lampiao-pop-in{0%{transform:scale(0);opacity:0}70%{transform:scale(1.15);opacity:1}100%{transform:scale(1);opacity:1}}
      @media(max-width:680px){#dnd35-owl-guide{right:auto;bottom:auto;gap:4px}#dnd35-owl-guide .lampiao-art{width:88px;height:124px}#dnd35-owl-guide .lampiao-chat{width:min(290px,calc(100vw - 120px));min-width:190px;padding:11px 12px}#dnd35-owl-guide .lampiao-message{font-size:14px}#dnd35-owl-guide .lampiao-actions button{padding:6px 7px;font-size:9px}}
      @media(prefers-reduced-motion:reduce){#dnd35-owl-guide .lampiao-art{animation:none}#dnd35-owl-guide.pop-out .lampiao-art,#dnd35-owl-guide.pop-out .lampiao-chat,#dnd35-owl-guide.pop-in .lampiao-art,#dnd35-owl-guide.pop-in .lampiao-chat{animation:none}}
    `;
    document.head.appendChild(style);
    const legacyGuide=document.getElementById('mage-step-note');if(legacyGuide)legacyGuide.remove();
    const root=document.createElement('aside');
    root.id='dnd35-owl-guide';
    root.setAttribute('aria-label','Guia do Lampião Errante');
    root.innerHTML='<div class="lampiao-stage no-art"><img class="lampiao-art" src="assets/lampiao-errante.png" alt="Lampião Errante" onerror="this.remove();this.parentElement.classList.add(\'no-art\')"></div>'
    const chat=document.createElement('div');
    chat.className='lampiao-chat';
    chat.innerHTML='<h3 class="lampiao-title">O Lampião Errante</h3><p class="lampiao-message"></p><div class="lampiao-detail"></div><div class="lampiao-actions"><button type="button" data-action="next">Seguir</button><button type="button" data-action="prev">Voltar</button><button type="button" data-action="about">Sobre esta etapa</button><button type="button" class="lampiao-close" data-action="close">Fechar guia</button></div>';
    const stage=root.querySelector('.lampiao-stage');
    const minimized=document.createElement('button');
    minimized.type='button'; minimized.className='lampiao-minimized'; minimized.textContent='GUIA'; minimized.setAttribute('aria-label','Reabrir o Guia do Lampião Errante');
    root.append(chat,minimized);
    document.body.appendChild(root);
    const centerGuide=()=>{root.style.left='50%';root.style.top='50%';root.style.right='auto';root.style.bottom='auto';root.style.transform='translate(-50%,-50%)';root.dataset.userMoved='false';};
    const guideIsOutOfView=()=>{const r=root.getBoundingClientRect();return r.bottom<0||r.top>window.innerHeight||r.right<0||r.left>window.innerWidth;};
    let guideDrag=null;
    const beginGuideDrag=e=>{if(e.button!==0||root.classList.contains('closed'))return;if(e.target.closest('button'))return;const r=root.getBoundingClientRect();guideDrag={x:e.clientX,y:e.clientY,left:r.left,top:r.top};root.style.transform='none';root.style.left=r.left+'px';root.style.top=r.top+'px';root.style.right='auto';root.style.bottom='auto';root.dataset.userMoved='true';e.preventDefault();};
    const moveGuideDrag=e=>{if(!guideDrag)return;const x=Math.max(0,Math.min(window.innerWidth-root.offsetWidth,guideDrag.left+e.clientX-guideDrag.x));const y=Math.max(0,Math.min(window.innerHeight-root.offsetHeight,guideDrag.top+e.clientY-guideDrag.y));root.style.left=x+'px';root.style.top=y+'px';};
    const endGuideDrag=()=>{guideDrag=null;};
    stage.addEventListener('pointerdown',beginGuideDrag);chat.querySelector('.lampiao-title').style.cursor='grab';chat.querySelector('.lampiao-title').addEventListener('pointerdown',beginGuideDrag);window.addEventListener('pointermove',moveGuideDrag);window.addEventListener('pointerup',endGuideDrag);
    window.addEventListener('scroll',()=>{if(!root.classList.contains('closed')&&guideIsOutOfView())centerGuide();},{passive:true});
    window.addEventListener('resize',()=>{if(!root.classList.contains('closed')&&guideIsOutOfView())centerGuide();});
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
      const label=(item&&item.label)||'esta escolha';
      const key=stageKey(item);
      if(/atribut/.test(key))return 'Ora, escolha com juízo. Até um Mago precisa saber onde é forte — e onde é só teimoso.';
      if(/per[ií]cia/.test(key))return 'Escolha o que combina com sua história. Não dá para ser especialista em tudo, nem com uma biblioteca inteira.';
      if(/talento/.test(key))return 'Um talento pode mudar seu jeito de agir. Veja os requisitos antes de se apaixonar pela ideia.';
      if(/familiar/.test(key))return 'Escolha seu companheiro arcano. E lembre: até familiar tem opinião própria.';
      if(/magia|grim[oó]rio|prepara/.test(key))return 'Magia exige estudo. Vamos separar o que você aprendeu daquilo que deixa preparado.';
      if(/equip/.test(key))return 'Revise o que leva. A magia não vai carregar sua mochila por você.';
      return 'Vamos cuidar de “'+label+'”. Confira os detalhes; eu fico aqui, julgando em silêncio.';
    };
    const detailText=item=>{
      const box=document.createElement('div');
      box.innerHTML=(item&&item.help)||'';
      const txt=(box.textContent||'').replace(/\s+/g,' ').trim();
      return txt||'Confira esta etapa e preencha o campo indicado.';
    };
    const currentItem=()=>{const list=guideCandidates();return list[Math.max(0,Math.min(step,list.length-1))]||null;};
    const render=()=>{
      const list=guideCandidates();
      const item=currentItem();
      if(!item){message.textContent='A ficha está preenchida. Revise os dados e salve quando estiver tudo certo.';detail.textContent='';prev.disabled=true;next.disabled=true;return;}
      message.textContent=stageText(item);
      detail.textContent=detailText(item);
      stage.classList.remove('speaking'); void stage.offsetWidth; stage.classList.add('speaking'); window.setTimeout(()=>stage.classList.remove('speaking'),2200);
      prev.disabled=step<=0;
      next.disabled=step>=list.length-1;
      about.textContent=root.classList.contains('show-detail')?'Ocultar detalhes':'Sobre esta etapa';
    };
    const move=(delta)=>{
      const list=guideCandidates();
      const target=Math.max(0,Math.min(list.length-1,step+delta));
      if(target===step){render();return;}
      showStep(target);
      stage.classList.remove('reacting'); void stage.offsetWidth; stage.classList.add('reacting'); window.setTimeout(()=>stage.classList.remove('reacting'),520);
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
      root.classList.remove('closed');centerGuide();root.classList.add('pop-in');
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
