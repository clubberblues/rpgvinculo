(function(global){
  'use strict';

  var aliases={
    barbarian:'barbarian',barbaro:'barbarian',
    bard:'bard',bardo:'bard',
    cleric:'cleric',clerigo:'cleric',
    druid:'druid',druida:'druid',
    fighter:'fighter',guerreiro:'fighter',
    monk:'monk',monge:'monk',
    paladin:'paladin',paladino:'paladin',
    ranger:'ranger',patrulheiro:'ranger',
    rogue:'rogue',ladino:'rogue',
    sorcerer:'sorcerer',feiticeiro:'sorcerer',
    wizard:'wizard',mago:'wizard'
  };

  var profiles={
    barbarian:{name:'Bárbaro',icon:'🔥',theme:'rage',actions:[
      ['rage','Fúria','🔥',1],['fast_movement','Movimento Rápido','👣',1],['illiteracy','Analfabetismo','📜',1],
      ['uncanny_dodge','Esquiva Sobrenatural','🛡️',2],['trap_sense','Sentido para Armadilhas','⚠️',3],
      ['damage_reduction','Redução de Dano','🪨',7],['greater_rage','Fúria Maior','🔥',11],
      ['indomitable_will','Vontade Indomável','🧠',14],['tireless_rage','Fúria Incansável','♾️',17],['mighty_rage','Fúria Poderosa','💥',20]
    ]},
    bard:{name:'Bardo',icon:'🎼',theme:'music',actions:[
      ['bardic_music','Música Bárdica','🎼',1],['bardic_knowledge','Conhecimento de Bardo','📚',1],
      ['inspire_competence','Inspirar Competência','✨',3],['suggestion','Sugestão','🗣️',6],
      ['inspire_greatness','Inspirar Grandeza','🌟',9],['song_of_freedom','Canção da Liberdade','🕊️',12],
      ['inspire_heroics','Inspirar Heroísmo','🏅',15],['mass_suggestion','Sugestão em Massa','🌀',18]
    ]},
    cleric:{name:'Clérigo',icon:'✝️',theme:'faith',actions:[
      ['domains','Domínios e Poderes','🔱',1],['turn_undead','Expulsar/Fascinar Mortos-Vivos','☀️',1],
      ['spontaneous_casting','Conversão Espontânea','✨',1]
    ]},
    druid:{name:'Druida',icon:'🌿',theme:'nature',actions:[
      ['animal_companion','Companheiro Animal','🐺',1],['nature_sense','Sentido da Natureza','🌱',1],
      ['wild_empathy','Empatia Selvagem','🦌',1],['woodland_stride','Caminho da Floresta','🍃',2],
      ['trackless_step','Rastro Invisível','🍂',3],['resist_natures_lure','Resistir ao Fascínio da Natureza','🌳',4],
      ['wild_shape','Forma Selvagem','🐾',5],['thousand_faces','Mil Faces','🎭',13],['timeless_body','Corpo Atemporal','⏳',15]
    ]},
    fighter:{name:'Guerreiro',icon:'⚔️',theme:'steel',actions:[
      ['bonus_combat_feat','Talento Bônus de Combate','🏅',1],['bonus_combat_feat_2','Novo Talento Bônus','🏅',2],
      ['bonus_combat_feat_4','Novo Talento Bônus','🏅',4],['bonus_combat_feat_6','Novo Talento Bônus','🏅',6],
      ['bonus_combat_feat_8','Novo Talento Bônus','🏅',8],['bonus_combat_feat_10','Novo Talento Bônus','🏅',10],
      ['bonus_combat_feat_12','Novo Talento Bônus','🏅',12],['bonus_combat_feat_14','Novo Talento Bônus','🏅',14],
      ['bonus_combat_feat_16','Novo Talento Bônus','🏅',16],['bonus_combat_feat_18','Novo Talento Bônus','🏅',18],
      ['bonus_combat_feat_20','Novo Talento Bônus','🏅',20]
    ]},
    monk:{name:'Monge',icon:'☯️',theme:'discipline',actions:[
      ['flurry_of_blows','Rajada de Golpes','💨',1],['unarmed_strike','Ataque Desarmado','👊',1],
      ['monk_ac_bonus','Defesa sem Armadura','🛡️',1],['monk_bonus_feat','Talento Bônus','🏅',1],
      ['evasion','Evasão','🌀',2],['still_mind','Mente Serena','🧘',3],
      ['ki_strike','Ataque Chi','✨',4],['slow_fall','Queda Lenta','🍃',4],
      ['purity_of_body','Pureza Corporal','💠',5],['improved_evasion','Evasão Aprimorada','🌀',9]
    ]},
    paladin:{name:'Paladino',icon:'🛡️',theme:'holy',actions:[
      ['aura_good','Aura do Bem','✨',1],['detect_evil','Detectar o Mal','👁️',1],['smite_evil','Punir o Mal','⚔️',1],
      ['divine_grace','Graça Divina','🌟',2],['lay_on_hands','Imposição das Mãos','🤲',2],
      ['aura_courage','Aura de Coragem','🦁',3],['divine_health','Saúde Divina','💠',3],
      ['turn_undead','Expulsar Mortos-Vivos','☀️',4],['special_mount','Montaria Especial','🐎',5]
    ]},
    ranger:{name:'Patrulheiro',icon:'🏹',theme:'wild',actions:[
      ['favored_enemy','Inimigo Predileto','🎯',1],['track','Rastrear','🐾',1],['wild_empathy','Empatia Selvagem','🦌',1],
      ['combat_style','Estilo de Combate','⚔️',2],['endurance','Resistência','🧭',3],
      ['animal_companion','Companheiro Animal','🐺',4],['improved_combat_style','Estilo de Combate Aprimorado','🏹',6],
      ['master_combat_style','Estilo de Combate Mestre','🏹',11]
    ]},
    rogue:{name:'Ladino',icon:'🗡️',theme:'shadow',actions:[
      ['sneak_attack','Ataque Furtivo','🗡️',1],['trapfinding','Encontrar Armadilhas','🪤',1],
      ['evasion','Evasão','🌀',2],['trap_sense','Sentido para Armadilhas','⚠️',3],
      ['uncanny_dodge','Esquiva Sobrenatural','🛡️',4],['improved_uncanny_dodge','Esquiva Sobrenatural Aprimorada','🌑',8],
      ['special_ability','Habilidade Especial','⭐',10]
    ]},
    sorcerer:{name:'Feiticeiro',icon:'🔮',theme:'arcane',actions:[
      ['spontaneous_spells','Repertório Arcano','🔮',1],['familiar','Familiar','🦉',1]
    ]},
    wizard:{name:'Mago',icon:'📘',theme:'arcane',actions:[
      ['spellbook','Grimório','📘',1],['spell_preparation','Preparar Magias','🃏',1],
      ['familiar','Familiar','🦉',1],['scribe_scroll','Escrever Pergaminho','📜',1],
      ['bonus_feat_5','Talento Bônus de Mago','🏅',5],['bonus_feat_10','Talento Bônus de Mago','🏅',10],
      ['bonus_feat_15','Talento Bônus de Mago','🏅',15],['bonus_feat_20','Talento Bônus de Mago','🏅',20]
    ]}
  };

  function normalize(value){
    return String(value==null?'':value).trim().normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/[^a-z0-9_-]/g,'');
  }
  function classKey(input){
    if(!input)return '';
    var sheet=input.sh||input.sheet||{},cls=input.cl||input.class||{},stats=input.monsterStats||{};
    var candidates=[sheet.classe_id,cls.class_key,cls.classKey,cls.id,cls.nome,stats.class_key,stats.classKey,stats.class_name,stats.className,input.class_key,input.class_name,input.classe];
    for(var i=0;i<candidates.length;i++){var key=aliases[normalize(candidates[i])];if(key)return key;}
    return '';
  }
  function levelOf(input){
    var sheet=input&&(input.sh||input.sheet)||{},stats=input&&input.monsterStats||{};
    return Math.max(1,Math.min(20,Number(sheet.nivel||stats.level||input.level)||1));
  }
  function canCast(key,level){
    if(key==='paladin'||key==='ranger')return level>=4;
    return ['bard','cleric','druid','sorcerer','wizard'].indexOf(key)>=0&&level>=1;
  }
  function preparationLabel(key){
    if(key==='wizard')return 'Abrir Grimório e Preparação';
    if(key==='sorcerer'||key==='bard')return 'Gerenciar Repertório';
    if(key==='cleric')return 'Preparar Magias e Domínios';
    if(key==='druid')return 'Preparar Magias';
    if(key==='paladin')return 'Preparar Magias de Paladino';
    if(key==='ranger')return 'Preparar Magias de Patrulheiro';
    return 'Preparar Magias';
  }
  function actionsFor(input){
    var key=classKey(input),profile=profiles[key],level=levelOf(input);
    if(!profile)return {key:'',name:'Aventureiro',level:level,theme:'default',actions:[]};
    var actions=profile.actions.filter(function(row){return level>=row[3];}).map(function(row){
      return {key:row[0],label:row[1],icon:row[2],level:row[3],kind:'feature'};
    });
    actions.unshift({key:'all_class_features',label:'Todas as Características de '+profile.name,icon:profile.icon,level:1,kind:'features'});
    if(canCast(key,level)){
      actions.push({key:'manage_spells',label:preparationLabel(key),icon:key==='wizard'?'📘':key==='sorcerer'||key==='bard'?'🔮':'✨',level:key==='paladin'||key==='ranger'?4:1,kind:'sheet'});
    }
    if(key==='druid'||(key==='ranger'&&level>=4)){
      actions.push({key:'manage_companion',label:'Ficha do Companheiro Animal',icon:'🐾',level:key==='druid'?1:4,kind:'sheet'});
    }
    if(key==='wizard'||key==='sorcerer')actions.push({key:'manage_familiar',label:'Ficha do Familiar',icon:'🦉',level:1,kind:'sheet'});
    return {key:key,name:profile.name,level:level,theme:profile.theme,actions:actions};
  }
  function tokenActions(item){
    var profile=actionsFor(item);
    return profile.actions.map(function(action){return Object.assign({},action,{available:true});});
  }
  global.VinculoClassControls={
    version:1,
    classKey:classKey,
    canCast:canCast,
    actionsFor:actionsFor,
    tokenActions:tokenActions
  };
})(window);
