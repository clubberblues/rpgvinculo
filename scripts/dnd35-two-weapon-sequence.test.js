const test=require('node:test');
const assert=require('node:assert/strict');
const build=require('./dnd35-two-weapon-sequence.js');
const sword={id:'longsword',instance_id:'p1',nome:'Espada longa',detalhes:{weapon_melee:true,weapon_light:false}};
const dagger={id:'dagger',instance_id:'o1',nome:'Adaga',detalhes:{weapon_melee:true,weapon_light:true}};
const mace={id:'mace',instance_id:'o2',nome:'Maça',detalhes:{weapon_melee:true,weapon_light:false}};
test('sem talento: arma secundária leve aplica -4/-8',()=>{
 const r=build({baseAttackBonus:6,dexterity:14,primaryWeapon:sword,offhandWeapon:dagger});
 assert.deepEqual(r.penalties,{main_hand:-4,off_hand:-8});
 assert.deepEqual(r.attacks.map(a=>[a.hand,a.base_attack_bonus,a.two_weapon_penalty]),[['main_hand',6,-4],['main_hand',1,-4],['off_hand',6,-8]]);
});
test('sem talento: arma secundária não leve aplica -6/-10',()=>{
 const r=build({baseAttackBonus:6,dexterity:14,primaryWeapon:sword,offhandWeapon:mace});
 assert.deepEqual(r.penalties,{main_hand:-6,off_hand:-10});
});
test('talento básico reduz penalidades para -2/-2 com arma leve',()=>{
 const r=build({baseAttackBonus:5,dexterity:15,hasTwoWeaponFighting:true,primaryWeapon:sword,offhandWeapon:dagger});
 assert.deepEqual(r.penalties,{main_hand:-2,off_hand:-2});
});
test('Aprimorado acrescenta ataque secundário em BBA -5',()=>{
 const r=build({baseAttackBonus:6,dexterity:17,hasTwoWeaponFighting:true,hasImprovedTwoWeaponFighting:true,primaryWeapon:sword,offhandWeapon:dagger});
 assert.deepEqual(r.attacks.filter(a=>a.hand==='off_hand').map(a=>a.base_attack_bonus),[6,1]);
});
test('Maior acrescenta terceiro ataque secundário em BBA -10',()=>{
 const r=build({baseAttackBonus:11,dexterity:19,hasTwoWeaponFighting:true,hasImprovedTwoWeaponFighting:true,hasGreaterTwoWeaponFighting:true,primaryWeapon:sword,offhandWeapon:dagger});
 assert.deepEqual(r.attacks.filter(a=>a.hand==='off_hand').map(a=>a.base_attack_bonus),[11,6,1]);
});
test('recusa talento aprimorado sem pré-requisitos',()=>{
 assert.throws(()=>build({baseAttackBonus:5,dexterity:16,hasTwoWeaponFighting:true,hasImprovedTwoWeaponFighting:true,primaryWeapon:sword,offhandWeapon:dagger}),/Aprimorado exige/);
});
test('recusa armas de duas mãos',()=>{
 assert.throws(()=>build({baseAttackBonus:6,dexterity:17,primaryWeapon:{...sword,detalhes:{weapon_melee:true,weapon_two_handed:true}},offhandWeapon:dagger}),/duas mãos/);
});
