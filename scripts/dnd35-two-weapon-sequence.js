(function(root){
  'use strict';
  function buildTwoWeaponSequence35(input){
    input=input||{};
    var bab=Number(input.baseAttackBonus),dex=Number(input.dexterity);
    if(!Number.isInteger(bab)||bab<0)throw new Error('Bônus base de ataque inválido para Combater com Duas Armas.');
    var primary=input.primaryWeapon,offhand=input.offhandWeapon;
    if(!primary||!offhand)throw new Error('É necessário equipar uma arma na mão principal e outra na mão secundária.');
    function details(weapon){return weapon&&weapon.detalhes&&typeof weapon.detalhes==='object'?weapon.detalhes:{};}
    var pd=details(primary),od=details(offhand);
    if(pd.weapon_melee===false||od.weapon_melee===false)throw new Error('Combater com Duas Armas exige duas armas corpo a corpo.');
    if(pd.weapon_two_handed===true||od.weapon_two_handed===true)throw new Error('Armas de duas mãos não podem compor esta sequência.');
    var basic=input.hasTwoWeaponFighting===true,improved=input.hasImprovedTwoWeaponFighting===true,greater=input.hasGreaterTwoWeaponFighting===true;
    if(basic&&(!Number.isFinite(dex)||dex<15))throw new Error('Combater com Duas Armas exige DES 15.');
    if(improved&&(!basic||bab<6||!Number.isFinite(dex)||dex<17))throw new Error('Combater com Duas Armas Aprimorado exige o talento básico, BBA +6 e DES 17.');
    if(greater&&(!improved||bab<11||!Number.isFinite(dex)||dex<19))throw new Error('Combater com Duas Armas Maior exige o talento aprimorado, BBA +11 e DES 19.');
    var offhandLight=od.weapon_light===true;
    var primaryPenalty=basic?(offhandLight?-2:-4):(offhandLight?-4:-6);
    var offhandPenalty=basic?(offhandLight?-2:-4):(offhandLight?-8:-10);
    var attacks=[];
    var primaryBabs=[bab];
    for(var iterative=bab-5;iterative>=1;iterative-=5)primaryBabs.push(iterative);
    primaryBabs.forEach(function(attackBab,index){
      attacks.push({sequence_index:attacks.length,hand:'main_hand',weapon_instance_id:primary.instance_id||null,weapon_id:primary.id||primary.equipment_id||null,weapon_name:String(primary.nome||'Arma principal'),base_attack_bonus:attackBab,two_weapon_penalty:primaryPenalty,attack_bonus_adjustment:attackBab-bab+primaryPenalty,iterative_index:index});
    });
    var offhandCount=1+(improved?1:0)+(greater?1:0);
    for(var i=0;i<offhandCount;i++){
      var offBab=bab-(i*5);
      if(offBab<1&&i>0)continue;
      attacks.push({sequence_index:attacks.length,hand:'off_hand',weapon_instance_id:offhand.instance_id||null,weapon_id:offhand.id||offhand.equipment_id||null,weapon_name:String(offhand.nome||'Arma secundária'),base_attack_bonus:offBab,two_weapon_penalty:offhandPenalty,attack_bonus_adjustment:offBab-bab+offhandPenalty,iterative_index:i});
    }
    return {base_attack_bonus:bab,dexterity:dex,offhand_light:offhandLight,penalties:{main_hand:primaryPenalty,off_hand:offhandPenalty},attacks:attacks};
  }
  root.buildTwoWeaponSequence35=buildTwoWeaponSequence35;
  if(typeof module!=='undefined'&&module.exports)module.exports=buildTwoWeaponSequence35;
})(typeof globalThis!=='undefined'?globalThis:this);
