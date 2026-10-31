-- D&D 3.5 SRD OGC monster stat blocks and full entry rules. Source: https://github.com/olimot/srd-v3.5-md/tree/main/monsters
-- Open Game License 1.0a; attribution retained in srd_source_url and dados_tecnicos.
insert into public.srd_monsters (id,nome,nome_original,nd,tamanho,tipo,tendencia,dados_vida,pv,iniciativa,deslocamento,ca,base_attack_grapple,ataques,espaco_alcance,fortitude,reflexos,vontade,forca,destreza,constituicao,inteligencia,sabedoria,carisma,pericias,talentos,qualidades_especiais,descricao,dados_tecnicos,srd_source_url,srd_canonical) values
('water_elemental_small','Water Elemental, Small','Water Elemental, Small','1','Small','Elemental (Water, Extraplanar)','Usually neutral','2d8+2 (11 hp)',11,'+0','20 ft. (4 squares), swim 90 ft.','17 (+1 size, +6 natural), touch 11, flat-footed 17','+1/–1','Slam +4 melee (1d6+3)','5 ft./5 ft.','+4','+0','+0',14,10,13,4,11,11,'Listen +2, Spot +3','Power Attack','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Water Elemental, Huge</th><th>Water Elemental, Greater</th><th>Water Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>+4</td><td>+5</td><td>+6</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +4 Dex, +9 natural), touch 12, flat-footed 17</td><td>22 (–2 size, +5 Dex, +9 natural), touch 13, flat-footed 17</td><td>23 (–2 size, +6 Dex, +9 natural), touch 14, flat-footed 17</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+27</td><td>+15/+31</td><td>+18/+35</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d10+7)</td><td>Slam +21 melee (2d10+8)</td><td>Slam +25 melee (2d10+9/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d10+7)</td><td>2 slams +21 melee (2d10+8)</td><td>2 slams +25 melee (2d10+9/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +9, Will +7</td><td>Fort +17, Ref +14, Will +9</td><td>Fort +19, Ref +16, Will +10</td></tr><tr><th>Abilities:</th><td>Str 24, Dex 18, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 26, Dex 20, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 28, Dex 22, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Cleave, Great Cleave, Power Attack, Improved Bull Rush, Iron Will</td><td>Alertness, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td><td>Alertness, Cleave, Great Cleave, Improved Critical (slam), Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"Slam +4 melee (1d6+3)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"3 HD (Small)","level_adjustment":"—","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/–1","attack":"Slam +4 melee (1d6+3)","full_attack":"Slam +4 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +0, Will +0","abilities":{"str":"14","dex":"10","con":"13","int":"4","wis":"11","cha":"11"},"skills":"Listen +2, Spot +3","feats":"Power Attack","special_attacks":"Water mastery, drench, vortex","special_qualities":"Darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('water_elemental_medium','Water Elemental, Medium','Water Elemental, Medium','3','Medium','Elemental (Water, Extraplanar)','Usually neutral','4d8+12 (30 hp)',30,'+1','20 ft. (4 squares), swim 90 ft.','19 (+1 Dex, +8 natural), touch 11, flat-footed 18','+3/+6','Slam +6 melee (1d8+4)','5 ft./5 ft.','+7','+2','+1',16,12,17,4,11,11,'Listen +3, Spot +4','Cleave, Power Attack','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Water Elemental, Huge</th><th>Water Elemental, Greater</th><th>Water Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>+4</td><td>+5</td><td>+6</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +4 Dex, +9 natural), touch 12, flat-footed 17</td><td>22 (–2 size, +5 Dex, +9 natural), touch 13, flat-footed 17</td><td>23 (–2 size, +6 Dex, +9 natural), touch 14, flat-footed 17</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+27</td><td>+15/+31</td><td>+18/+35</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d10+7)</td><td>Slam +21 melee (2d10+8)</td><td>Slam +25 melee (2d10+9/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d10+7)</td><td>2 slams +21 melee (2d10+8)</td><td>2 slams +25 melee (2d10+9/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +9, Will +7</td><td>Fort +17, Ref +14, Will +9</td><td>Fort +19, Ref +16, Will +10</td></tr><tr><th>Abilities:</th><td>Str 24, Dex 18, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 26, Dex 20, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 28, Dex 22, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Cleave, Great Cleave, Power Attack, Improved Bull Rush, Iron Will</td><td>Alertness, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td><td>Alertness, Cleave, Great Cleave, Improved Critical (slam), Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"Slam +6 melee (1d8+4)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"5–7 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"4d8+12 (30 hp)","hit_points":30,"base_attack_grapple":"+3/+6","attack":"Slam +6 melee (1d8+4)","full_attack":"Slam +6 melee (1d8+4)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +2, Will +1","abilities":{"str":"16","dex":"12","con":"17","int":"4","wis":"11","cha":"11"},"skills":"Listen +3, Spot +4","feats":"Cleave, Power Attack","special_attacks":"Water mastery, drench, vortex","special_qualities":"Darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('water_elemental_large','Water Elemental, Large','Water Elemental, Large','5','Large','Elemental (Water, Extraplanar)','Usually neutral','8d8+32 (68 hp)',68,'+2','20 ft. (4 squares), swim 90 ft.','20 (–1 size, +2 Dex, +9 natural), touch 11, flat-footed 18','+6/+15','Slam +10 melee (2d8+5)','10 ft./10 ft.','+10','+4','+2',20,14,19,6,11,11,'Listen +5, Spot +6','Cleave, Great Cleave, Power Attack','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Water Elemental, Huge</th><th>Water Elemental, Greater</th><th>Water Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td><td>Huge Elemental <small>(Water, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>+4</td><td>+5</td><td>+6</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td><td>30 ft. (6 squares), swim 120 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +4 Dex, +9 natural), touch 12, flat-footed 17</td><td>22 (–2 size, +5 Dex, +9 natural), touch 13, flat-footed 17</td><td>23 (–2 size, +6 Dex, +9 natural), touch 14, flat-footed 17</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+27</td><td>+15/+31</td><td>+18/+35</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d10+7)</td><td>Slam +21 melee (2d10+8)</td><td>Slam +25 melee (2d10+9/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d10+7)</td><td>2 slams +21 melee (2d10+8)</td><td>2 slams +25 melee (2d10+9/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td><td>Water mastery, drench, vortex</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +9, Will +7</td><td>Fort +17, Ref +14, Will +9</td><td>Fort +19, Ref +16, Will +10</td></tr><tr><th>Abilities:</th><td>Str 24, Dex 18, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 26, Dex 20, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 28, Dex 22, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Cleave, Great Cleave, Power Attack, Improved Bull Rush, Iron Will</td><td>Alertness, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td><td>Alertness, Cleave, Great Cleave, Improved Critical (slam), Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td><td>Elemental Plane of Water</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +10 melee (2d8+5)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"9–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d8+32 (68 hp)","hit_points":68,"base_attack_grapple":"+6/+15","attack":"Slam +10 melee (2d8+5)","full_attack":"2 slams +10 melee (2d8+5)","space_reach":"10 ft./10 ft.","saves":"Fort +10, Ref +4, Will +2","abilities":{"str":"20","dex":"14","con":"19","int":"6","wis":"11","cha":"11"},"skills":"Listen +5, Spot +6","feats":"Cleave, Great Cleave, Power Attack","special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('water_elemental_huge','Water Elemental, Huge','Water Elemental, Huge','7','Huge','Elemental (Water, Extraplanar)','Usually neutral','16d8+80 (152 hp)',152,'+4','30 ft. (6 squares), swim 120 ft.','21 (–2 size, +4 Dex, +9 natural), touch 12, flat-footed 17','+12/+27','Slam +17 melee (2d10+7)','15 ft./15 ft.','+15','+9','+7',24,18,21,6,11,11,'Listen +11, Spot +12','Alertness, Cleave, Great Cleave, Power Attack, Improved Bull Rush, Iron Will','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"}'::jsonb,'A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +17 melee (2d10+7)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"17–20 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+80 (152 hp)","hit_points":152,"base_attack_grapple":"+12/+27","attack":"Slam +17 melee (2d10+7)","full_attack":"2 slams +17 melee (2d10+7)","space_reach":"15 ft./15 ft.","saves":"Fort +15, Ref +9, Will +7","abilities":{"str":"24","dex":"18","con":"21","int":"6","wis":"11","cha":"11"},"skills":"Listen +11, Spot +12","feats":"Alertness, Cleave, Great Cleave, Power Attack, Improved Bull Rush, Iron Will","special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('water_elemental_greater','Water Elemental, Greater','Water Elemental, Greater','9','Huge','Elemental (Water, Extraplanar)','Usually neutral','21d8+105 (199 hp)',199,'+5','30 ft. (6 squares), swim 120 ft.','22 (–2 size, +5 Dex, +9 natural), touch 13, flat-footed 17','+15/+31','Slam +21 melee (2d10+8)','15 ft./15 ft.','+17','+14','+9',26,20,21,8,11,11,'Listen +14, Spot +14','Alertness, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"}'::jsonb,'A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +21 melee (2d10+8)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"22–23 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"21d8+105 (199 hp)","hit_points":199,"base_attack_grapple":"+15/+31","attack":"Slam +21 melee (2d10+8)","full_attack":"2 slams +21 melee (2d10+8)","space_reach":"15 ft./15 ft.","saves":"Fort +17, Ref +14, Will +9","abilities":{"str":"26","dex":"20","con":"21","int":"8","wis":"11","cha":"11"},"skills":"Listen +14, Spot +14","feats":"Alertness, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack","special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('water_elemental_elder','Water Elemental, Elder','Water Elemental, Elder','11','Huge','Elemental (Water, Extraplanar)','Usually neutral','24d8+120 (228 hp)',228,'+6','30 ft. (6 squares), swim 120 ft.','23 (–2 size, +6 Dex, +9 natural), touch 14, flat-footed 17','+18/+35','Slam +25 melee (2d10+9/19–20)','15 ft./15 ft.','+19','+16','+10',28,22,21,10,11,11,'Listen +29, Spot +29','Alertness, Cleave, Great Cleave, Improved Critical (slam), Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack','{"special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"}'::jsonb,'A water elemental can’t venture more than 180 feet from the body of water from which it was conjured.

Water elementals speak Aquan but rarely choose to do so.

#### Combat

A water elemental prefers to fight in a large body of water where it can disappear beneath the waves and suddenly swell up behind its opponents.

**Water Mastery (Ex):** A water elemental gains a +1 bonus on attack and damage rolls if both it and its opponent are touching water. If the opponent or the elemental is touching the ground, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

A water elemental can be a serious threat to a ship that crosses its path. An elemental can easily overturn small craft (5 feet of length per Hit Die of the elemental) and stop larger vessels (10 feet long per HD). Even large ships (20 feet long per HD) can be slowed to half speed.

**Drench (Ex):** The elemental’s touch puts out torches, campfires, exposed lanterns, and other open flames of nonmagical origin if these are of Large size or smaller. The creature can dispel magical fire it touches as _dispel magic_ (caster level equals elemental’s HD).

**Vortex (Su):** The elemental can transform itself into a whirlpool once every 10 minutes, provided it is underwater, and remain in that form for up to 1 round for every 2 HD it has. In vortex form, the elemental can move through the water or along the bottom at its swim speed. The vortex is 5 feet wide at the base, up to 30 feet wide at the top, and 10 feet or more tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in vortex form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the vortex if it touches or enters the vortex, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the vortex (see the table below for details) and may be swept up by it. An affected creature must succeed on a Reflex save when it comes into contact with the vortex or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful currents, automatically taking damage each round. An affected creature is allowed a Reflex save each round to escape the vortex. The creature still takes damage, but can leave if the save is successful. The DC for saves against the vortex’s effects varies with the elemental’s size. The save DC is Strength-based.

Creatures trapped in the vortex cannot move except to go where the elemental carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 10 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the vortex at one time as will fit inside the vortex’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the vortex happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the vortex’s base touches the bottom, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the vortex’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must make a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in vortex form cannot make slam attacks and does not threaten the area around it.

Skills: A water elemental has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Water Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Vortex</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>34 lb.</td><td>13</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>280 lb.</td><td>15</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>2,250 lb.</td><td>19</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>18,000 lb.</td><td>25</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>21,000 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>24,000 lb.</td><td>31</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +25 melee (2d10+9/19–20)","environment":"Elemental Plane of Water","organization":"Solitary","treasure":"None","advancement":"25–48 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"24d8+120 (228 hp)","hit_points":228,"base_attack_grapple":"+18/+35","attack":"Slam +25 melee (2d10+9/19–20)","full_attack":"2 slams +25 melee (2d10+9/19–20)","space_reach":"15 ft./15 ft.","saves":"Fort +19, Ref +16, Will +10","abilities":{"str":"28","dex":"22","con":"21","int":"10","wis":"11","cha":"11"},"skills":"Listen +29, Spot +29","feats":"Alertness, Cleave, Great Cleave, Improved Critical (slam), Improved Bull Rush, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack","special_attacks":"Water mastery, drench, vortex","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('elf_1st_level_warrior','Elf, 1st-Level Warrior','Elf, 1st-Level Warrior','1/2','Medium','Humanoid (Elf )','Usually chaotic good (Wood: Usually neutral)','1d8 (4 hp)',4,'+1','30 ft. (6 squares)','15 (+1 Dex, +3 studded leather, +1 light shield), touch 11, flat-footed 14','+1/+2','Longsword +2 melee (1d8+1/19–20) or longbow +3 ranged (1d8/x3)','5 ft./5 ft.','+2','+1','–1',13,13,10,10,9,8,'Hide +1, Listen +2, Search +3, Spot +2','Weapon Focus (longbow)','{"special_attacks":"None","special_qualities":"Elven traits"}'::jsonb,'Elves average 5 feet tall and typically weigh just over 100 pounds. They live on fruits and grains, though they occasionally hunt for fresh meat. Elves prefer colorful clothes, usually with a green-and-gray cloak that blends well with the colors of the forest.

Elves speak Elven, and most also know Common and Sylvan.

Most elves encountered outside their homes are warriors; the information presented here is for one of 1st level.

### Combat

Elves are cautious warriors and take time to analyze their opponents and the location of the fight if at all possible, maximizing their advantage by using ambushes, snipers, and camouflage. They prefer to fire from cover and retreat before they are found, repeating this maneuver until all of their enemies are dead.

They prefer longbows, shortbows, rapiers, and longswords. In melee, elves are graceful and deadly, using complex maneuvers that are beautiful to observe. Their wizards often use _sleep_ spells during combat because these won’t affect other elves.

**Elf Traits (Ex):** Elves possess the following racial traits.

— +2 Dexterity, –2 Constitution.

—Medium size.

—An elf ’s base land speed is 30 feet.

—Immunity to _sleep_ spells and effects, and a +2 racial saving throw bonus against enchantment spells or effects.

(Not reflected in the saving throw modifiers given here.)

—Low-light vision.

—Weapon Proficiency: Elves are automatically proficient with the longsword, rapier, longbow, composite longbow, shortbow, and composite shortbow.

— +2 racial bonus on Listen, Search, and Spot checks. An elf who merely passes within 5 feet of a secret or concealed door is entitled to a Search check to notice it as if she were actively looking for it.

—Automatic Languages: Common, Elven. Bonus Languages: Draconic, Gnoll, Gnome, Goblin, Orc, Sylvan.

—Favored Class: Wizard.

The elf warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The above information describes the high elf, the most common variety. There are five other major subraces of elf, in addition to half-elves, who share enough elven characteristics to be included here.

#### Half-Elf

Half-elves are not truly an elf subrace, but they are often mistaken for elves. Half-elves usually inherit a good blend of their parents’ physical characteristics.

**Half-Elf Traits (Ex):** Half-elves possess the following racial traits.

—Medium size.

—A half-elf ’s base land speed is 30 feet.

—Immunity to _sleep_ spells and similar magical effects, and a +2 racial bonus on saving throws against enchantment spells or effects.

—Low-light vision.

— +1 racial bonus on Listen, Search, and Spot checks. A half-elf does not have the elf ’s ability to notice secret doors simply by passing near them.

— +2 racial bonus on Diplomacy and Gather Information checks: Half-elves get along naturally with all people. This bonus may not apply in situations or settings where half-elves are viewed with distrust.

—Elven Blood: For all effects related to race, a half-elf is considered an elf. Half-elves, for example, are just as vulnerable to special effects that affect elves as their elf ancestors are, and they can use magic items that are only usable by elves.

—Automatic Languages: Common, Elven. Bonus Languages: Any (other than secret languages, such as Druidic).

—Favored Class: Any. When determining whether a multiclass half-elf takes an experience point penalty for multiclassing, her highest-level class does not count.

#### Aquatic Elf

Also called sea elves, these creatures are waterbreathing cousins to land-dwelling elves.

Aquatic elves fight underwater with tridents, spears, and nets.

**Aquatic Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Dexterity, –2 Intelligence. These adjustments replace the high elf ’s ability score adjustments.

—An aquatic elf has the aquatic subtype.

—An aquatic elf has a swim speed of 40 feet.

—Gills: Aquatic elves can survive out of the water for 1 hour per point of Constitution (after that, refer to the suffocation rules).

—Superior Low-Light Vision: Aquatic elves can see four times as far as a human in starlight, moonlight, torchlight, and similar conditions of low illumination. This trait replaces the high elf ’s low-light vision.

—Favored Class: Fighter. This trait replaces the high elf ’s favored class.

#### Drow

Also known as dark elves, drow are a depraved and evil subterranean offshoot.

White is the most common hair color among drow, but almost any pale shade is possible. Drow tend to be smaller and thinner than other sorts of elves, and their eyes are often a vivid red.

Drow usually coat their arrows with a potent venom.

**Poison (Ex):** An opponent hit by a drow’s poisoned weapon must succeed on a DC 13 Fortitude save or fall unconscious. After 1 minute, the subject must succeed on another DC 13 Fortitude save or remain unconscious for 2d4 hours. A typical drow carries 1d4–1 doses of drow knockout poison. Drow typically coat arrows and crossbow bolts with this poison, but it can also be applied to a melee weapon. Note that drow have no special ability to apply poison without risking being poisoned themselves. Since this poison is not a magical effect, drow and other elves are susceptible to it.

**Drow Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Intelligence, +2 Charisma.

—Darkvision out to 120 feet. This trait replaces the high elf ’s low-light vision.

—Spell resistance equal to 11 + class levels.

— +2 racial bonus on Will saves against spells and spell-like abilities.

—Spell-Like Abilities: Drow can use the following spell-like abilities once per day: _dancing lights, darkness, faerie fire._ Caster level equals the drow’s class levels.

—Weapon Proficiency: A drow is automatically proficient with the hand crossbow, the rapier, and the short sword. This trait replaces the high elf ’s weapon proficiency.

—Automatic Languages: Common, Elven, Undercommon. Bonus Languages: Abyssal, Aquan, Draconic, Drow Sign Language, Gnome, Goblin. This trait replaces the high elf ’s automatic and bonus languages.

—Light Blindness: Abrupt exposure to bright light (such as sunlight or a _daylight_ spell) blinds drow for 1 round. On subsequent rounds, they are dazzled as long as they remain in the affected area.

—Favored Class: Wizard (male) or cleric (female). This trait replaces the high elf ’s favored class.

—Level adjustment +2.

The drow warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

Challenge Rating: Drow with levels in NPC classes have a CR equal to their character level. Drow with levels in PC classes have a CR equal to their character level +1.

#### Gray Elf

Taller and grander in physical appearance than others of their race, gray elves have a reputation for being aloof and arrogant (even by elven standards). They have either silver hair and amber eyes or pale golden hair and violet eyes. They prefer clothing of white, silver, yellow, or gold, with cloaks of deep blue or purple.

**Gray Elf Traits (Ex):** These traits are in addition to the high elf traits.

— +2 Intelligence, –2 Strength.

#### Wild Elf

Wild elvesare barbaric and tribal. Wild elves’ hair color ranges from black to light brown, lightening to silvery white with age. They dress in simple clothing of animal skins and basic plant weaves.

**Wild Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Dexterity, –2 Intelligence. These adjustments replace the high elf ’s ability score adjustments.

—Favored Class: Sorcerer. This trait replaces the high elf ’s favored class.

#### Wood Elf

Their hair color ranges from yellow to a coppery red, and they are more muscular than other elves. Their clothing is in dark shades of green and earth tones to better blend in with their natural surroundings.

**Wood Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Strength, –2 Intelligence.

—Favored Class: Ranger. This trait replaces the high elf ’s favored class.','{"full_attack":"Longsword +2 melee(1d8+1/19–20) or longbow +3 ranged (1d8/x3)","environment":"Temperate forest (Half-elf: Temperate forests) (Aquatic: Temperate aquatic) (Gray: Temperate mountains) (Wild: Warm forests) (Wood: Temperate forests)","organization":"Squad (2–4), company (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or band (30–100 plus 20% noncombatants plus 1 3rd-level sergeant per 10 adults, 5 5th-level lieutenants, and 3 7th-level captains)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8 (4 hp)","hit_points":4,"base_attack_grapple":"+1/+2","attack":"Longsword +2 melee (1d8+1/19–20) or longbow +3 ranged (1d8/x3)","full_attack":"Longsword +2 melee(1d8+1/19–20) or longbow +3 ranged (1d8/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +1, Will –1*","abilities":{"str":"13","dex":"13","con":"10","int":"10","wis":"9","cha":"8"},"skills":"Hide +1, Listen +2, Search +3, Spot +2","feats":"Weapon Focus (longbow)","special_attacks":"None","special_qualities":"Elven traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('drow_1st_level_warrior','Drow, 1st-Level Warrior','Drow, 1st-Level Warrior','1 (see text)','Medium','Humanoid (Elf )','Usually neutral evil','1d8 (4 hp)',4,'+1','30 ft. (6 squares)','16 (+1 Dex, +4 chain shirt, +1 light shield) touch 11, flat-footed 15','+1/+2','Rapier +3 melee (1d6+1/18–20) or hand crossbow +2 ranged (1d4/19–20)','5 ft./5 ft.','+2','+1','–1',13,13,10,12,9,10,'Hide +0, Listen +2, Search +4, Spot +3','Weapon Focus (rapier)','{"special_attacks":"Poison, spell-like abilities","special_qualities":"Drow traits, spell resistance 12"}'::jsonb,'Elves average 5 feet tall and typically weigh just over 100 pounds. They live on fruits and grains, though they occasionally hunt for fresh meat. Elves prefer colorful clothes, usually with a green-and-gray cloak that blends well with the colors of the forest.

Elves speak Elven, and most also know Common and Sylvan.

Most elves encountered outside their homes are warriors; the information presented here is for one of 1st level.

### Combat

Elves are cautious warriors and take time to analyze their opponents and the location of the fight if at all possible, maximizing their advantage by using ambushes, snipers, and camouflage. They prefer to fire from cover and retreat before they are found, repeating this maneuver until all of their enemies are dead.

They prefer longbows, shortbows, rapiers, and longswords. In melee, elves are graceful and deadly, using complex maneuvers that are beautiful to observe. Their wizards often use _sleep_ spells during combat because these won’t affect other elves.

**Elf Traits (Ex):** Elves possess the following racial traits.

— +2 Dexterity, –2 Constitution.

—Medium size.

—An elf ’s base land speed is 30 feet.

—Immunity to _sleep_ spells and effects, and a +2 racial saving throw bonus against enchantment spells or effects.

(Not reflected in the saving throw modifiers given here.)

—Low-light vision.

—Weapon Proficiency: Elves are automatically proficient with the longsword, rapier, longbow, composite longbow, shortbow, and composite shortbow.

— +2 racial bonus on Listen, Search, and Spot checks. An elf who merely passes within 5 feet of a secret or concealed door is entitled to a Search check to notice it as if she were actively looking for it.

—Automatic Languages: Common, Elven. Bonus Languages: Draconic, Gnoll, Gnome, Goblin, Orc, Sylvan.

—Favored Class: Wizard.

The elf warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The above information describes the high elf, the most common variety. There are five other major subraces of elf, in addition to half-elves, who share enough elven characteristics to be included here.

#### Half-Elf

Half-elves are not truly an elf subrace, but they are often mistaken for elves. Half-elves usually inherit a good blend of their parents’ physical characteristics.

**Half-Elf Traits (Ex):** Half-elves possess the following racial traits.

—Medium size.

—A half-elf ’s base land speed is 30 feet.

—Immunity to _sleep_ spells and similar magical effects, and a +2 racial bonus on saving throws against enchantment spells or effects.

—Low-light vision.

— +1 racial bonus on Listen, Search, and Spot checks. A half-elf does not have the elf ’s ability to notice secret doors simply by passing near them.

— +2 racial bonus on Diplomacy and Gather Information checks: Half-elves get along naturally with all people. This bonus may not apply in situations or settings where half-elves are viewed with distrust.

—Elven Blood: For all effects related to race, a half-elf is considered an elf. Half-elves, for example, are just as vulnerable to special effects that affect elves as their elf ancestors are, and they can use magic items that are only usable by elves.

—Automatic Languages: Common, Elven. Bonus Languages: Any (other than secret languages, such as Druidic).

—Favored Class: Any. When determining whether a multiclass half-elf takes an experience point penalty for multiclassing, her highest-level class does not count.

#### Aquatic Elf

Also called sea elves, these creatures are waterbreathing cousins to land-dwelling elves.

Aquatic elves fight underwater with tridents, spears, and nets.

**Aquatic Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Dexterity, –2 Intelligence. These adjustments replace the high elf ’s ability score adjustments.

—An aquatic elf has the aquatic subtype.

—An aquatic elf has a swim speed of 40 feet.

—Gills: Aquatic elves can survive out of the water for 1 hour per point of Constitution (after that, refer to the suffocation rules).

—Superior Low-Light Vision: Aquatic elves can see four times as far as a human in starlight, moonlight, torchlight, and similar conditions of low illumination. This trait replaces the high elf ’s low-light vision.

—Favored Class: Fighter. This trait replaces the high elf ’s favored class.

#### Drow

Also known as dark elves, drow are a depraved and evil subterranean offshoot.

White is the most common hair color among drow, but almost any pale shade is possible. Drow tend to be smaller and thinner than other sorts of elves, and their eyes are often a vivid red.

Drow usually coat their arrows with a potent venom.

**Poison (Ex):** An opponent hit by a drow’s poisoned weapon must succeed on a DC 13 Fortitude save or fall unconscious. After 1 minute, the subject must succeed on another DC 13 Fortitude save or remain unconscious for 2d4 hours. A typical drow carries 1d4–1 doses of drow knockout poison. Drow typically coat arrows and crossbow bolts with this poison, but it can also be applied to a melee weapon. Note that drow have no special ability to apply poison without risking being poisoned themselves. Since this poison is not a magical effect, drow and other elves are susceptible to it.

**Drow Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Intelligence, +2 Charisma.

—Darkvision out to 120 feet. This trait replaces the high elf ’s low-light vision.

—Spell resistance equal to 11 + class levels.

— +2 racial bonus on Will saves against spells and spell-like abilities.

—Spell-Like Abilities: Drow can use the following spell-like abilities once per day: _dancing lights, darkness, faerie fire._ Caster level equals the drow’s class levels.

—Weapon Proficiency: A drow is automatically proficient with the hand crossbow, the rapier, and the short sword. This trait replaces the high elf ’s weapon proficiency.

—Automatic Languages: Common, Elven, Undercommon. Bonus Languages: Abyssal, Aquan, Draconic, Drow Sign Language, Gnome, Goblin. This trait replaces the high elf ’s automatic and bonus languages.

—Light Blindness: Abrupt exposure to bright light (such as sunlight or a _daylight_ spell) blinds drow for 1 round. On subsequent rounds, they are dazzled as long as they remain in the affected area.

—Favored Class: Wizard (male) or cleric (female). This trait replaces the high elf ’s favored class.

—Level adjustment +2.

The drow warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

Challenge Rating: Drow with levels in NPC classes have a CR equal to their character level. Drow with levels in PC classes have a CR equal to their character level +1.

#### Gray Elf

Taller and grander in physical appearance than others of their race, gray elves have a reputation for being aloof and arrogant (even by elven standards). They have either silver hair and amber eyes or pale golden hair and violet eyes. They prefer clothing of white, silver, yellow, or gold, with cloaks of deep blue or purple.

**Gray Elf Traits (Ex):** These traits are in addition to the high elf traits.

— +2 Intelligence, –2 Strength.

#### Wild Elf

Wild elvesare barbaric and tribal. Wild elves’ hair color ranges from black to light brown, lightening to silvery white with age. They dress in simple clothing of animal skins and basic plant weaves.

**Wild Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Dexterity, –2 Intelligence. These adjustments replace the high elf ’s ability score adjustments.

—Favored Class: Sorcerer. This trait replaces the high elf ’s favored class.

#### Wood Elf

Their hair color ranges from yellow to a coppery red, and they are more muscular than other elves. Their clothing is in dark shades of green and earth tones to better blend in with their natural surroundings.

**Wood Elf Traits (Ex):** These traits are in addition to the high elf traits, except where noted.

— +2 Strength, –2 Intelligence.

—Favored Class: Ranger. This trait replaces the high elf ’s favored class.','{"full_attack":"Rapier +3 melee (1d6+1/18–20) or hand crossbow +2 ranged (1d4/19–20)","environment":"Underground","organization":"Squad (2–4), patrol (5–8 plus 2 2nd-level sergeants and 1 leader of 3rd–6th level), or band (20–50 plus 10% noncombatants plus 1 2nd-level sergeant per 5 adults, 2d4 6th-level lieutenants, and 1d4 9th-level captains)","treasure":"Standard","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"1d8 (4 hp)","hit_points":4,"base_attack_grapple":"+1/+2","attack":"Rapier +3 melee (1d6+1/18–20) or hand crossbow +2 ranged (1d4/19–20)","full_attack":"Rapier +3 melee (1d6+1/18–20) or hand crossbow +2 ranged (1d4/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +1, Will –1*","abilities":{"str":"13","dex":"13","con":"10","int":"12","wis":"9","cha":"10"},"skills":"Hide +0, Listen +2, Search +4, Spot +3","feats":"Weapon Focus (rapier)","special_attacks":"Poison, spell-like abilities","special_qualities":"Drow traits, spell resistance 12"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('ethereal_filcher','Ethereal Filcher','Ethereal Filcher','3','Medium','Aberration','Usually neutral','5d8 (22 hp)',22,'+8','40 ft. (8 squares)','17 (+4 Dex, +3 natural), touch 14, flat-footed 13','+3/+3','Bite +3 melee (1d4)','5 ft./5 ft.','+1','+5','+5',10,18,11,7,12,10,'Listen +9, Sleight of Hand +12, Spot +9','Dodge, Improved Initiative','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., detect magic, ethereal jaunt"}'::jsonb,'Ethereal filchers are bizarre-looking creatures with a penchant for snatching trinkets from passersby. Their ability to move quickly between the Ethereal Plane and the Material Plane makes them spectacular pickpockets.

Ethereal filchers do not speak.

### Combat

An ethereal filcher prowls about, using its ethereal jaunt ability to move about unseen (and often through solid objects). Upon locating a likely mark, it shifts to the Material Plane, attempting to catch its victim unaware. The creature attempts to seize an item, then retreats quickly back to the Ethereal Plane. It is not above delivering a bite to distract its target. Once it secures a trinket, it scurries back to its lair to admire its prize. When badly wounded, a filcher escapes rather than continuing the fight.

Any number of simple ruses can blunt a filcher’s attack.

**Detect Magic (Su):** Ethereal filchers can detect magic as the spell (caster level 5th) at will.

**Ethereal Jaunt (Su):** An ethereal filcher can shift from the Ethereal Plane to the Material Plane as part of any move action, and shift back again as a free action. It can remain on the Ethereal Plane for 1 round before returning to the Material Plane. The ability is otherwise identical with the _ethereal jaunt_ spell (caster level 15th).

**Skills:** Ethereal filchers have a +8 racial bonus on Sleight of Hand checks, and a +4 racial bonus on Listen and Spot checks.','{"full_attack":"Bite +3 melee (1d4)","environment":"Underground","organization":"Solitary","treasure":"No coins; standard goods; double items","advancement":"6–7 HD (Medium); 8–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"5d8 (22 hp)","hit_points":22,"base_attack_grapple":"+3/+3","attack":"Bite +3 melee (1d4)","full_attack":"Bite +3 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +1, Ref +5, Will +5","abilities":{"str":"10","dex":"18","con":"11","int":"7","wis":"12","cha":"10"},"skills":"Listen +9, Sleight of Hand +12, Spot +9","feats":"Dodge, Improved Initiative","special_attacks":"—","special_qualities":"Darkvision 60 ft., detect magic, ethereal jaunt"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('ethereal_marauder','Ethereal Marauder','Ethereal Marauder','3','Medium','Magical Beast (Extraplanar)','Always neutral','2d10 (11 hp)',11,'+5','40 ft. (8 squares)','14 (+1 Dex, +3 natural), touch 11, flat-footed 13','+2/+4','Bite +4 melee (1d6+3)','5 ft./5 ft.','+3','+4','+1',14,12,11,7,12,10,'Listen +5, Move Silently +5, Spot +4','Improved Initiative','{"special_attacks":"","special_qualities":"Darkvision 60 ft., ethereal jaunt"}'::jsonb,'Ethereal marauders live and hunt on the Ethereal Plane. Ethereal marauders’ coloration ranges from bright blue to deep violet. An ethereal marauder stands about 4 feet tall, but its overall length is about 7 feet. It weighs about 200 pounds.

Ethereal marauders speak no known languages. Survivors of their attacks on the Material Plane claim that they emit an eerie, high whine that varies in pitch depending on the creature’s speed and health.

### Combat

Once a marauder locates prey, it shifts to the Material Plane to attack, attempting to catch its victim flat-footed. The creature bites its victim, then retreats quickly back to the Ethereal Plane. When badly hurt or wounded, a marauder escapes to its home plane rather than continuing the fight.

**Ethereal Jaunt (Su):** An ethereal marauder can shift from the Ethereal Plane to the Material Plane as a free action, and shift back again as a move action. The ability is otherwise identical with the _ethereal jaunt_ spell (caster level 15th).

**Skills:** Ethereal marauders have a +2 racial bonus on Listen, Move Silently, and Spot checks.','{"full_attack":"Bite +4 melee (1d6+3)","environment":"Ethereal Plane","organization":"Solitary","treasure":"None","advancement":"3–4 HD (Medium); 5–6 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"2d10 (11 hp)","hit_points":11,"base_attack_grapple":"+2/+4","attack":"Bite +4 melee (1d6+3)","full_attack":"Bite +4 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +1","abilities":{"str":"14","dex":"12","con":"11","int":"7","wis":"12","cha":"10"},"skills":"Listen +5, Move Silently +5, Spot +4","feats":"Improved Initiative","special_attacks":"","special_qualities":"Darkvision 60 ft., ethereal jaunt"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('ettercap','Ettercap','Ettercap','3','Medium','Aberration','Usually neutral evil','5d8+5 (27 hp)',27,'+3','30 ft. (6 squares), climb 30 ft.','14 (+3 Dex, +1 natural), touch 13, flat-footed 11','+3/+5','Bite +5 melee (1d8+2 plus poison) and 2 claws +3 melee (1d3+1)','5 ft./5 ft.','+4','+4','+6',14,17,13,6,15,8,'Climb +10, Craft (trapmaking) +4, Hide +9, Listen +4, Spot +8','Great Fortitude, Multiattack','{"special_attacks":"Poison, web","special_qualities":"Low-light vision"}'::jsonb,'An ettercap is about 6 feet tall and weighs about 200 pounds.

Ettercaps speak Common.

### Combat

Ettercaps are not brave creatures, but their cunning traps often ensure that the enemy never draws a weapon. When an ettercap does engage its enemies, it attacks with its keen-edged claws and venomous bite. It usually will not come within melee reach of any foe that is still able to move.

**Poison (Ex):** Injury, Fortitude DC 15, initial damage 1d6 Dex, secondary damage 2d6 Dex. The save DC is Constitution based and includes a +2 racial bonus.

**Web (Ex):** An ettercap can throw a web eight times per day. This is similar to an attack with a net but has a maximum range of 50 feet, with a range increment of 10 feet, and is effective against targets of up to Medium size. The web anchors the target in place, allowing no movement.

An entangled creature can escape with a DC 13 Escape Artist check or burst the web with a DC 17 Strength check. The check DCs are Constitution-based, and the Strength check DC includes a +4 racial bonus. The web has 6 hit points, hardness 0, and takes double damage from fire.

Ettercaps can also create sheets of sticky webbing from 5 to 60 feet square. They usually position these to snare flying creatures but can also try to trap prey on the ground. Approaching creatures must succeed on a DC 20 Spot check to notice a web, or they stumble into it and become trapped as though by a successful web attack. Attempts to escape or burst the webbing receive a +5 bonus if the trapped creature has something to walk on or grab while pulling free. Each 5-foot-square section has 6 hit points, hardness 0, and takes double damage from fire.

An ettercap can move across its own sheet web at its climb speed and can determine the exact location of any creature touching the web.

**Skills:** Ettercaps have a +4 racial bonus on Craft (trapmaking), Hide, and Spot checks. They have a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.','{"full_attack":"","environment":"Warm forests","organization":"Solitary, pair, or troupe (1–2 plus 2–4 Medium monstrous spiders)","treasure":"Standard","advancement":"6–7 HD (Medium); 8–15 HD (Large)","level_adjustment":"+4","statblock":{"hit_dice":"5d8+5 (27 hp)","hit_points":27,"base_attack_grapple":"+3/+5","attack":"Bite +5 melee (1d8+2 plus poison) and 2 claws +3 melee (1d3+1)","full_attack":"","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +4, Will +6","abilities":{"str":"14","dex":"17","con":"13","int":"6","wis":"15","cha":"8"},"skills":"Climb +10, Craft (trapmaking) +4, Hide +9, Listen +4, Spot +8","feats":"Great Fortitude, Multiattack","special_attacks":"Poison, web","special_qualities":"Low-light vision"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('ettin','Ettin','Ettin','6','Large','Giant','Usually chaotic evil','10d8+20 (65 hp)',65,'+3','30 ft. in hide armor (6 squares); base speed 40 ft.','18 (–1 size, –1 Dex, +7 natural, +3 hide), touch 8, flat-footed 18','+7/+17','Morningstar +12 melee (2d6+6) or javelin +5 ranged (1d8+6)','10 ft./10 ft.','+9','+2','+5',23,8,15,6,10,11,'Listen +10, Search +1, Spot +10','Alertness, Improved Initiative, Iron Will, Power Attack','{"special_attacks":"—","special_qualities":"Low-light vision, superior two-weapon fighting"}'::jsonb,'Ettins, or two-headed giants, are vicious and unpredictable hunters that stalk the night.

An ettin never bathes if it can help it, which usually leaves it so grimy and dirty its skin resembles thick, gray hide. Adult ettins are about 13 feet tall and weigh 5,200 pounds. They live about 75 years.

Ettins have no language of their own but speak a pidgin of Orc, Goblin, and Giant. Creatures that can speak any of these languages must succeed on a DC 15 Intelligence check to communicate with an ettin. Check once for each bit of information: If the other creature speaks two of these languages, the DC is 10, and for someone who speaks all three, the DC is 5.

### Combat

Though ettins aren’t very intelligent, they are cunning fighters.

They prefer to ambush their victims rather than charge into a straight fight, but once the battle has started, an ettin usually fights furiously until all enemies are dead.

**Superior Two-Weapon Fighting (Ex):** An ettin fights with a morningstar or javelin in each hand. Because each of its two heads controls an arm, the ettin does not take a penalty on attack or damage rolls for attacking with two weapons.

Skills: An ettin’s two heads give it a +2 racial bonus on Listen, Spot, and Search checks.','{"full_attack":"2 morningstars +12/+7 melee (2d6+6) or 2 javelins +5 ranged (1d8+6)","environment":"Cold hills","organization":"Solitary, gang (2–4), troupe (1–2 plus 1–2 brown bears), band (3–5 plus 1–2 brown bears), or colony (3–5 plus 1–2 brown bears and 7–12 orcs or 9–16 goblins)","treasure":"Standard","advancement":"By character class","level_adjustment":"+5","statblock":{"hit_dice":"10d8+20 (65 hp)","hit_points":65,"base_attack_grapple":"+7/+17","attack":"Morningstar +12 melee (2d6+6) or javelin +5 ranged (1d8+6)","full_attack":"2 morningstars +12/+7 melee (2d6+6) or 2 javelins +5 ranged (1d8+6)","space_reach":"10 ft./10 ft.","saves":"Fort +9, Ref +2, Will +5","abilities":{"str":"23","dex":"8","con":"15","int":"6","wis":"10","cha":"11"},"skills":"Listen +10, Search +1, Spot +10","feats":"Alertness, Improved Initiative, Iron Will, Power Attack","special_attacks":"—","special_qualities":"Low-light vision, superior two-weapon fighting"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('formian_worker','Formian Worker','Formian Worker','1/2','Small','Outsider (Lawful, Extraplanar)','Always lawful neutral','1d8+1 (5 hp)',5,'+2','40 ft. (8 squares)','17 (+1 size, +2 Dex, +4 natural), touch 13, flat-footed 15','+1/–2','Bite +3 melee (1d4+1)','5 ft./5 ft.','+3','+4','+2',13,14,13,6,10,9,'Climb +10, Craft (any one) +5, Hide +6, Listen +4, Search +2, Spot +4','Skill Focus (Craft [selected skill])','{"special_attacks":"—","special_qualities":"Cure serious wounds, hive mind, immunity to poison, petrification, and cold, make whole, resistance to electricity 10, fire 10, and sonic 10"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Formian Myrmarch</th><th>Formian Queen</th></tr><tr><td></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>12d8+48 (102 hp)</td><td>20d8+100 (190 hp)</td></tr><tr><th>Initiative:</th><td>+8</td><td>–5</td></tr><tr><th>Speed:</th><td>50 ft. (10 squares)</td><td>0 ft.</td></tr><tr><th>Armor Class:</th><td>28 (–1 size, +4 Dex, +15 natural), touch 13, flat-footed 24</td><td>23 (–1 size, +14 natural), touch 9, flat-footed 23</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+20</td><td>+20/+24</td></tr><tr><th>Attack:</th><td>Sting +15 melee (2d4+4 plus poison) or javelin +15 ranged (1d6+4)</td><td>—</td></tr><tr><th>Full Attack:</th><td>Sting +15 melee (2d4+4 plus poison) and bite +13 melee (2d6+2); or javelin +15/+10 ranged (1d6+4)</td><td>—</td></tr><tr><th>Space/Reach:</th><td>10 ft./5 ft.</td><td>10 ft./5 ft.</td></tr><tr><th>Special Attacks:</th><td>Poison, spell-like abilities</td><td>Spell-like abilities, spells</td></tr><tr><th>Special Qualities:</th><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 25</td><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 30, telepathy</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +12, Will +11</td><td>Fort +19, Ref —, Will +19</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 18, Con 18, Int 16, Wis 16, Cha 17</td><td>Str —, Dex —, Con 20, Int 20, Wis 20, Cha 21</td></tr><tr><th>Skills:</th><td>Climb +19, Concentration +18, Diplomacy +20, Hide +15, Knowledge (any one) +18, Listen +18, Move Silently +19, Search +18, Sense Motive +18, Spot +18, Survival +3 (+5 following tracks)</td><td>Appraise +28, Bluff +28, Concentration +28, Diplomacy +32, Disguise +5 (+7 acting), Intimidate +30, Knowledge (any three) +28, Listen +30, Sense Motive +28, Spellcraft +28 (+30 scrolls), Spot +30, Use Magic Device +28 (+30 scrolls)</td></tr><tr><th>Feats:</th><td>Dodge, Improved Initiative, Mobility, Multiattack, Spring Attack</td><td>Alertness, Eschew Materials<sup>B</sup>, Great Fortitude, Improved Counterspell, Iron Will, item creation feat (any one), Maximize Spell, Spell Focus (enchantment)</td></tr><tr><th>Environment:</th><td>A lawful-aligned plane</td><td>A lawful-aligned plane</td></tr><tr><th>Organization:</th><td>Solitary, team (2–4), or platoon (1 plus 7–18 workers and 6–11 warriors)</td><td>Hive (1 plus 100–400 workers, 11–40 warriors, 4–7 taskmasters with 1 dominated creature each, and 5–8 myrmarchs)</td></tr><tr><th>Challenge Rating:</th><td>10</td><td>17</td></tr><tr><th>Treasure:</th><td>Standard</td><td>Double standard</td></tr><tr><th>Alignment:</th><td>Always lawful neutral</td><td>Always lawful neutral</td></tr><tr><th>Advancement:</th><td>13–18 HD (Large); 19–24 HD (Huge)</td><td>21–30 HD (Huge); 31–40 HD (Gargantuan)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

A formian resembles a cross between an ant and a centaur. All formians are covered in a brownish-red carapace; size and appearance differs for each variety.

### Combat

Formians are generally aggressive, seeking to subdue all they encounter. If they perceive even the slightest threat to their hive-city or to their queen, they attack immediately and fight to the death. Any formian also attacks immediately if ordered to do so by a superior.

**Hive Mind (Ex):** All formians within 50 miles of their queen are in constant communication. If one is aware of a particular danger, they all are. If one in a group is not flatfooted, none of them are. No formian in a group is considered flanked unless all of them are.

### Worker

While workers cannot speak, they can convey simple concepts (such as danger) by body movements. Through the hive mind, however, they can communicate just fine—although their intelligence still limits the concepts that they can grasp.

A worker is about 3 feet long and about 2-1/2 feet high at the front. It weighs about 60 pounds. Its hands are suitable only for manual labor.

#### Combat

Formian workers fight only to defend their hive-cities, using their mandibled bite.

A formian worker’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**_Cure Serious Wounds_ (Sp):** Eight workers together can heal a creature’s wounds as though using the _cure serious wounds_ spell (caster level 7th). This is a full-round action for all eight workers.

**_Make Whole_ (Sp):** Three workers together can repair an object as though using the _make whole_ spell (caster level 7th). This is a fullround action for all three workers.

### Warrior

Warriors communicate through the hive mind to convey battle plans and make reports to their commanders. They cannot speak otherwise.

A warrior is about is about 5 feet long and about 4-1/2 feet high at the front. It weighs about 180 pounds.

#### Combat

Warriors are wicked combatants, using claws, bite, and a poisonous sting all at once. Through the hive mind, they attack with coordinated and extremely efficient tactics.

A formian warrior’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Taskmaster

These formians communicate only telepathically and derive sustenance from the mental energies of those they dominate.

A taskmaster is about the same size as a warrior.

#### Combat

Taskmasters rely on their dominated slaves to fight for them if at all possible. If necessary, though, they can defend themselves with claws and a poison sting.

A formian taskmaster’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Dominate Monster (Su):** A taskmaster can use a _dominate monster_ ability as the spell from a 10th-level caster (Will DC 17 negates), although the subject may be of any kind and may be up to Large size. Creatures that successfully save cannot be affected by the same taskmaster’s dominate monster ability for 24 hours. A single taskmaster can dominate up to four subjects at a time. The save DC is Charisma-based.

**Dominated Creature (Ex):** A taskmaster is never encountered alone. One dominated nonformian creature always accompanies it (choose or determine randomly any creature of CR 4).

**Poison (Ex):** Injury, Fortitude DC 15, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Myrmarch

Myrmarchs are the elite of formian society. Much more than those beneath them, these creatures are individuals, with goals, desires, and creative thought.

A myrmarch is about is about 7 feet long and about 5-1/2 feet high at the front. It weighs about 1,500 pounds. Its claws are capable of fine manipulation, like human hands. Each myrmarch wears a bronze helm to signify its position (the more elaborate the helm, the more prestigious the position).

Myrmarchs speak Formian and Common.

#### Combat

Myrmarchs’ claws are like hands and thus serve no combat purpose.

Myrmarchs occasionally employ javelins for ranged attacks, coated with poison from their own stingers.

They fight intelligently, aiding those under them (if any such are present) and commanding them through the hive mind. If chaotic creatures are present, however, a myrmarch is singleminded in its quest to destroy them.

A formian myrmarch’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 20, initial and secondary damage 2d6 Dex. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 17), _clairaudience/ clairvoyance, detect chaos, detect thoughts_ (DC 15), _magic circle against chaos_, _greater teleport;_ 1/day—_dictum_ (DC 20), _order’s wrath_ (DC 17). Caster level 12th. The save DCs are Charisma-based.

### Queen

The formian queen cannot move. With her telepathic abilities, though, she can send instructions to and get reports from any formian within her range.

She is about 10 feet long, perhaps 4 feet high, and weighs about 3,500 pounds.

The queen speaks Formian and Common, although she can communicate with any creature telepathically.

#### Combat

The queen does not fight. She has no ability to move. If necessary, a team of workers and myrmarchs (or dominated slaves) haul her enormous bulk to where she needs to go. This sort of occurrence is very rare, however, and most of the time the queen remains within her well-defended chambers.

Despite her utter lack of physical activity, the queen can cast spells and use spell-like abilities to great effect in her own defense as well as the defense of the hive-city.

**Spells:** The queen casts arcane spells as a 17th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/8/7/7/7/7/6/6/4, base save DC 15 + spell level): 0—_acid splash, arcane mark, daze, detect magic, light, mage hand, read magic, resistance, touch of fatigue;_ 1st—_comprehend languages, identify, mage armor, magic missile, shield;_ 2nd— _hypnotic pattern, invisibility, protection from arrows, resist energy, scorching ray;_ 3rd—_dispel magic, heroism, nondetection, slow;_ 4th— _confusion, detect scrying, black tentacles, scrying;_ 5th—_cone of cold, dismissal, teleport, wall of force;_ 6th—_analyze dweomer, geas/quest, repulsion;_ 7th—_summon monster VII, vision, waves of exhaustion;_ 8th—_prismatic wall, temporal stasis._

**Spell-Like Abilities:** At will—_calm emotions_ (DC 17), _charm monster_ (DC 19), _clairaudience/clairvoyance, detect chaos, detect thoughts, dictum_ (DC 22), _divination, hold monster_ (DC 20), _magic circle against chaos, order’s wrath_ (DC 19), _shield of law_ (DC 23), _true seeing._ Caster level 17th. The save DCs are Charisma-based.

**Telepathy (Su):** The queen can communicate telepathically with any intelligent creature within 50 miles whose presence she is aware of.','{"full_attack":"Bite +3 melee (1d4+1)","environment":"A lawful-aligned plane","organization":"Team (2–4) or crew (7–18)","treasure":"None","advancement":"2–3 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/–2","attack":"Bite +3 melee (1d4+1)","full_attack":"Bite +3 melee (1d4+1)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +2","abilities":{"str":"13","dex":"14","con":"13","int":"6","wis":"10","cha":"9"},"skills":"Climb +10, Craft (any one) +5, Hide +6, Listen +4, Search +2, Spot +4","feats":"Skill Focus (Craft [selected skill])","special_attacks":"—","special_qualities":"Cure serious wounds, hive mind, immunity to poison, petrification, and cold, make whole, resistance to electricity 10, fire 10, and sonic 10"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('formian_warrior','Formian Warrior','Formian Warrior','3','Medium','Outsider (Lawful, Extraplanar)','Always lawful neutral','4d8+8 (26 hp)',26,'+3','40 ft. (8 squares)','18 (+3 Dex, +5 natural), touch 13, flat-footed 15','+4/+7','Sting +7 melee (2d4+3 plus poison)','5 ft./5 ft.','+6','+7','+5',17,16,14,10,12,11,'Climb +10, Hide +10, Jump +14, Listen +8, Move Silently +10, (+3 following tracks), Tumble +12','Dodge, Multiattack','{"special_attacks":"Poison","special_qualities":"Hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 18"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Formian Myrmarch</th><th>Formian Queen</th></tr><tr><td></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>12d8+48 (102 hp)</td><td>20d8+100 (190 hp)</td></tr><tr><th>Initiative:</th><td>+8</td><td>–5</td></tr><tr><th>Speed:</th><td>50 ft. (10 squares)</td><td>0 ft.</td></tr><tr><th>Armor Class:</th><td>28 (–1 size, +4 Dex, +15 natural), touch 13, flat-footed 24</td><td>23 (–1 size, +14 natural), touch 9, flat-footed 23</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+20</td><td>+20/+24</td></tr><tr><th>Attack:</th><td>Sting +15 melee (2d4+4 plus poison) or javelin +15 ranged (1d6+4)</td><td>—</td></tr><tr><th>Full Attack:</th><td>Sting +15 melee (2d4+4 plus poison) and bite +13 melee (2d6+2); or javelin +15/+10 ranged (1d6+4)</td><td>—</td></tr><tr><th>Space/Reach:</th><td>10 ft./5 ft.</td><td>10 ft./5 ft.</td></tr><tr><th>Special Attacks:</th><td>Poison, spell-like abilities</td><td>Spell-like abilities, spells</td></tr><tr><th>Special Qualities:</th><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 25</td><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 30, telepathy</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +12, Will +11</td><td>Fort +19, Ref —, Will +19</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 18, Con 18, Int 16, Wis 16, Cha 17</td><td>Str —, Dex —, Con 20, Int 20, Wis 20, Cha 21</td></tr><tr><th>Skills:</th><td>Climb +19, Concentration +18, Diplomacy +20, Hide +15, Knowledge (any one) +18, Listen +18, Move Silently +19, Search +18, Sense Motive +18, Spot +18, Survival +3 (+5 following tracks)</td><td>Appraise +28, Bluff +28, Concentration +28, Diplomacy +32, Disguise +5 (+7 acting), Intimidate +30, Knowledge (any three) +28, Listen +30, Sense Motive +28, Spellcraft +28 (+30 scrolls), Spot +30, Use Magic Device +28 (+30 scrolls)</td></tr><tr><th>Feats:</th><td>Dodge, Improved Initiative, Mobility, Multiattack, Spring Attack</td><td>Alertness, Eschew Materials<sup>B</sup>, Great Fortitude, Improved Counterspell, Iron Will, item creation feat (any one), Maximize Spell, Spell Focus (enchantment)</td></tr><tr><th>Environment:</th><td>A lawful-aligned plane</td><td>A lawful-aligned plane</td></tr><tr><th>Organization:</th><td>Solitary, team (2–4), or platoon (1 plus 7–18 workers and 6–11 warriors)</td><td>Hive (1 plus 100–400 workers, 11–40 warriors, 4–7 taskmasters with 1 dominated creature each, and 5–8 myrmarchs)</td></tr><tr><th>Challenge Rating:</th><td>10</td><td>17</td></tr><tr><th>Treasure:</th><td>Standard</td><td>Double standard</td></tr><tr><th>Alignment:</th><td>Always lawful neutral</td><td>Always lawful neutral</td></tr><tr><th>Advancement:</th><td>13–18 HD (Large); 19–24 HD (Huge)</td><td>21–30 HD (Huge); 31–40 HD (Gargantuan)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

A formian resembles a cross between an ant and a centaur. All formians are covered in a brownish-red carapace; size and appearance differs for each variety.

### Combat

Formians are generally aggressive, seeking to subdue all they encounter. If they perceive even the slightest threat to their hive-city or to their queen, they attack immediately and fight to the death. Any formian also attacks immediately if ordered to do so by a superior.

**Hive Mind (Ex):** All formians within 50 miles of their queen are in constant communication. If one is aware of a particular danger, they all are. If one in a group is not flatfooted, none of them are. No formian in a group is considered flanked unless all of them are.

### Worker

While workers cannot speak, they can convey simple concepts (such as danger) by body movements. Through the hive mind, however, they can communicate just fine—although their intelligence still limits the concepts that they can grasp.

A worker is about 3 feet long and about 2-1/2 feet high at the front. It weighs about 60 pounds. Its hands are suitable only for manual labor.

#### Combat

Formian workers fight only to defend their hive-cities, using their mandibled bite.

A formian worker’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**_Cure Serious Wounds_ (Sp):** Eight workers together can heal a creature’s wounds as though using the _cure serious wounds_ spell (caster level 7th). This is a full-round action for all eight workers.

**_Make Whole_ (Sp):** Three workers together can repair an object as though using the _make whole_ spell (caster level 7th). This is a fullround action for all three workers.

### Warrior

Warriors communicate through the hive mind to convey battle plans and make reports to their commanders. They cannot speak otherwise.

A warrior is about is about 5 feet long and about 4-1/2 feet high at the front. It weighs about 180 pounds.

#### Combat

Warriors are wicked combatants, using claws, bite, and a poisonous sting all at once. Through the hive mind, they attack with coordinated and extremely efficient tactics.

A formian warrior’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Taskmaster

These formians communicate only telepathically and derive sustenance from the mental energies of those they dominate.

A taskmaster is about the same size as a warrior.

#### Combat

Taskmasters rely on their dominated slaves to fight for them if at all possible. If necessary, though, they can defend themselves with claws and a poison sting.

A formian taskmaster’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Dominate Monster (Su):** A taskmaster can use a _dominate monster_ ability as the spell from a 10th-level caster (Will DC 17 negates), although the subject may be of any kind and may be up to Large size. Creatures that successfully save cannot be affected by the same taskmaster’s dominate monster ability for 24 hours. A single taskmaster can dominate up to four subjects at a time. The save DC is Charisma-based.

**Dominated Creature (Ex):** A taskmaster is never encountered alone. One dominated nonformian creature always accompanies it (choose or determine randomly any creature of CR 4).

**Poison (Ex):** Injury, Fortitude DC 15, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Myrmarch

Myrmarchs are the elite of formian society. Much more than those beneath them, these creatures are individuals, with goals, desires, and creative thought.

A myrmarch is about is about 7 feet long and about 5-1/2 feet high at the front. It weighs about 1,500 pounds. Its claws are capable of fine manipulation, like human hands. Each myrmarch wears a bronze helm to signify its position (the more elaborate the helm, the more prestigious the position).

Myrmarchs speak Formian and Common.

#### Combat

Myrmarchs’ claws are like hands and thus serve no combat purpose.

Myrmarchs occasionally employ javelins for ranged attacks, coated with poison from their own stingers.

They fight intelligently, aiding those under them (if any such are present) and commanding them through the hive mind. If chaotic creatures are present, however, a myrmarch is singleminded in its quest to destroy them.

A formian myrmarch’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 20, initial and secondary damage 2d6 Dex. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 17), _clairaudience/ clairvoyance, detect chaos, detect thoughts_ (DC 15), _magic circle against chaos_, _greater teleport;_ 1/day—_dictum_ (DC 20), _order’s wrath_ (DC 17). Caster level 12th. The save DCs are Charisma-based.

### Queen

The formian queen cannot move. With her telepathic abilities, though, she can send instructions to and get reports from any formian within her range.

She is about 10 feet long, perhaps 4 feet high, and weighs about 3,500 pounds.

The queen speaks Formian and Common, although she can communicate with any creature telepathically.

#### Combat

The queen does not fight. She has no ability to move. If necessary, a team of workers and myrmarchs (or dominated slaves) haul her enormous bulk to where she needs to go. This sort of occurrence is very rare, however, and most of the time the queen remains within her well-defended chambers.

Despite her utter lack of physical activity, the queen can cast spells and use spell-like abilities to great effect in her own defense as well as the defense of the hive-city.

**Spells:** The queen casts arcane spells as a 17th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/8/7/7/7/7/6/6/4, base save DC 15 + spell level): 0—_acid splash, arcane mark, daze, detect magic, light, mage hand, read magic, resistance, touch of fatigue;_ 1st—_comprehend languages, identify, mage armor, magic missile, shield;_ 2nd— _hypnotic pattern, invisibility, protection from arrows, resist energy, scorching ray;_ 3rd—_dispel magic, heroism, nondetection, slow;_ 4th— _confusion, detect scrying, black tentacles, scrying;_ 5th—_cone of cold, dismissal, teleport, wall of force;_ 6th—_analyze dweomer, geas/quest, repulsion;_ 7th—_summon monster VII, vision, waves of exhaustion;_ 8th—_prismatic wall, temporal stasis._

**Spell-Like Abilities:** At will—_calm emotions_ (DC 17), _charm monster_ (DC 19), _clairaudience/clairvoyance, detect chaos, detect thoughts, dictum_ (DC 22), _divination, hold monster_ (DC 20), _magic circle against chaos, order’s wrath_ (DC 19), _shield of law_ (DC 23), _true seeing._ Caster level 17th. The save DCs are Charisma-based.

**Telepathy (Su):** The queen can communicate telepathically with any intelligent creature within 50 miles whose presence she is aware of.','{"full_attack":"Sting +7 melee (2d4+3 plus poison) and 2 claws +5 melee (1d6+1) and bite +5 melee (1d4+1)","environment":"A lawful-aligned plane","organization":"Solitary, team (2–4), or troop (6–11)","treasure":"None","advancement":"5–8 HD (Medium); 9–12 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"4d8+8 (26 hp)","hit_points":26,"base_attack_grapple":"+4/+7","attack":"Sting +7 melee (2d4+3 plus poison)","full_attack":"Sting +7 melee (2d4+3 plus poison) and 2 claws +5 melee (1d6+1) and bite +5 melee (1d4+1)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +7, Will +5","abilities":{"str":"17","dex":"16","con":"14","int":"10","wis":"12","cha":"11"},"skills":"Climb +10, Hide +10, Jump +14, Listen +8, Move Silently +10, (+3 following tracks), Tumble +12","feats":"Dodge, Multiattack","special_attacks":"Poison","special_qualities":"Hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 18"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('formian_taskmaster','Formian Taskmaster','Formian Taskmaster','7','Medium','Outsider (Lawful, Extraplanar)','Always lawful neutral','6d8+12 (39 hp)',39,'+7','40 ft. (8 squares)','19 (+3 Dex, +6 natural), touch 13, flat-footed 16','+6/+10','Sting +10 melee (2d4+4 plus poison)','5 ft./5 ft.','+7','+8','+8',18,16,14,11,16,19,'Climb +13, Diplomacy +6, Hide +12, Intimidate +13, Listen +12, Search +7, Spot +8, Survival +1 Move Silently +12, Search +9, Sense Motive +12, Spot +12, Survival +3 (+5 following tracks)','Dodge, Improved Initiative, Multiattack','{"special_attacks":"Dominate monster, dominated creature, poison","special_qualities":"Hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 21, telepathy 100 ft."}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Formian Myrmarch</th><th>Formian Queen</th></tr><tr><td></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td><td>Large Outsider <small>(Lawful, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>12d8+48 (102 hp)</td><td>20d8+100 (190 hp)</td></tr><tr><th>Initiative:</th><td>+8</td><td>–5</td></tr><tr><th>Speed:</th><td>50 ft. (10 squares)</td><td>0 ft.</td></tr><tr><th>Armor Class:</th><td>28 (–1 size, +4 Dex, +15 natural), touch 13, flat-footed 24</td><td>23 (–1 size, +14 natural), touch 9, flat-footed 23</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+20</td><td>+20/+24</td></tr><tr><th>Attack:</th><td>Sting +15 melee (2d4+4 plus poison) or javelin +15 ranged (1d6+4)</td><td>—</td></tr><tr><th>Full Attack:</th><td>Sting +15 melee (2d4+4 plus poison) and bite +13 melee (2d6+2); or javelin +15/+10 ranged (1d6+4)</td><td>—</td></tr><tr><th>Space/Reach:</th><td>10 ft./5 ft.</td><td>10 ft./5 ft.</td></tr><tr><th>Special Attacks:</th><td>Poison, spell-like abilities</td><td>Spell-like abilities, spells</td></tr><tr><th>Special Qualities:</th><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 25</td><td>Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 30, telepathy</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +12, Will +11</td><td>Fort +19, Ref —, Will +19</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 18, Con 18, Int 16, Wis 16, Cha 17</td><td>Str —, Dex —, Con 20, Int 20, Wis 20, Cha 21</td></tr><tr><th>Skills:</th><td>Climb +19, Concentration +18, Diplomacy +20, Hide +15, Knowledge (any one) +18, Listen +18, Move Silently +19, Search +18, Sense Motive +18, Spot +18, Survival +3 (+5 following tracks)</td><td>Appraise +28, Bluff +28, Concentration +28, Diplomacy +32, Disguise +5 (+7 acting), Intimidate +30, Knowledge (any three) +28, Listen +30, Sense Motive +28, Spellcraft +28 (+30 scrolls), Spot +30, Use Magic Device +28 (+30 scrolls)</td></tr><tr><th>Feats:</th><td>Dodge, Improved Initiative, Mobility, Multiattack, Spring Attack</td><td>Alertness, Eschew Materials<sup>B</sup>, Great Fortitude, Improved Counterspell, Iron Will, item creation feat (any one), Maximize Spell, Spell Focus (enchantment)</td></tr><tr><th>Environment:</th><td>A lawful-aligned plane</td><td>A lawful-aligned plane</td></tr><tr><th>Organization:</th><td>Solitary, team (2–4), or platoon (1 plus 7–18 workers and 6–11 warriors)</td><td>Hive (1 plus 100–400 workers, 11–40 warriors, 4–7 taskmasters with 1 dominated creature each, and 5–8 myrmarchs)</td></tr><tr><th>Challenge Rating:</th><td>10</td><td>17</td></tr><tr><th>Treasure:</th><td>Standard</td><td>Double standard</td></tr><tr><th>Alignment:</th><td>Always lawful neutral</td><td>Always lawful neutral</td></tr><tr><th>Advancement:</th><td>13–18 HD (Large); 19–24 HD (Huge)</td><td>21–30 HD (Huge); 31–40 HD (Gargantuan)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

A formian resembles a cross between an ant and a centaur. All formians are covered in a brownish-red carapace; size and appearance differs for each variety.

### Combat

Formians are generally aggressive, seeking to subdue all they encounter. If they perceive even the slightest threat to their hive-city or to their queen, they attack immediately and fight to the death. Any formian also attacks immediately if ordered to do so by a superior.

**Hive Mind (Ex):** All formians within 50 miles of their queen are in constant communication. If one is aware of a particular danger, they all are. If one in a group is not flatfooted, none of them are. No formian in a group is considered flanked unless all of them are.

### Worker

While workers cannot speak, they can convey simple concepts (such as danger) by body movements. Through the hive mind, however, they can communicate just fine—although their intelligence still limits the concepts that they can grasp.

A worker is about 3 feet long and about 2-1/2 feet high at the front. It weighs about 60 pounds. Its hands are suitable only for manual labor.

#### Combat

Formian workers fight only to defend their hive-cities, using their mandibled bite.

A formian worker’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**_Cure Serious Wounds_ (Sp):** Eight workers together can heal a creature’s wounds as though using the _cure serious wounds_ spell (caster level 7th). This is a full-round action for all eight workers.

**_Make Whole_ (Sp):** Three workers together can repair an object as though using the _make whole_ spell (caster level 7th). This is a fullround action for all three workers.

### Warrior

Warriors communicate through the hive mind to convey battle plans and make reports to their commanders. They cannot speak otherwise.

A warrior is about is about 5 feet long and about 4-1/2 feet high at the front. It weighs about 180 pounds.

#### Combat

Warriors are wicked combatants, using claws, bite, and a poisonous sting all at once. Through the hive mind, they attack with coordinated and extremely efficient tactics.

A formian warrior’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Taskmaster

These formians communicate only telepathically and derive sustenance from the mental energies of those they dominate.

A taskmaster is about the same size as a warrior.

#### Combat

Taskmasters rely on their dominated slaves to fight for them if at all possible. If necessary, though, they can defend themselves with claws and a poison sting.

A formian taskmaster’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Dominate Monster (Su):** A taskmaster can use a _dominate monster_ ability as the spell from a 10th-level caster (Will DC 17 negates), although the subject may be of any kind and may be up to Large size. Creatures that successfully save cannot be affected by the same taskmaster’s dominate monster ability for 24 hours. A single taskmaster can dominate up to four subjects at a time. The save DC is Charisma-based.

**Dominated Creature (Ex):** A taskmaster is never encountered alone. One dominated nonformian creature always accompanies it (choose or determine randomly any creature of CR 4).

**Poison (Ex):** Injury, Fortitude DC 15, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Myrmarch

Myrmarchs are the elite of formian society. Much more than those beneath them, these creatures are individuals, with goals, desires, and creative thought.

A myrmarch is about is about 7 feet long and about 5-1/2 feet high at the front. It weighs about 1,500 pounds. Its claws are capable of fine manipulation, like human hands. Each myrmarch wears a bronze helm to signify its position (the more elaborate the helm, the more prestigious the position).

Myrmarchs speak Formian and Common.

#### Combat

Myrmarchs’ claws are like hands and thus serve no combat purpose.

Myrmarchs occasionally employ javelins for ranged attacks, coated with poison from their own stingers.

They fight intelligently, aiding those under them (if any such are present) and commanding them through the hive mind. If chaotic creatures are present, however, a myrmarch is singleminded in its quest to destroy them.

A formian myrmarch’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 20, initial and secondary damage 2d6 Dex. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 17), _clairaudience/ clairvoyance, detect chaos, detect thoughts_ (DC 15), _magic circle against chaos_, _greater teleport;_ 1/day—_dictum_ (DC 20), _order’s wrath_ (DC 17). Caster level 12th. The save DCs are Charisma-based.

### Queen

The formian queen cannot move. With her telepathic abilities, though, she can send instructions to and get reports from any formian within her range.

She is about 10 feet long, perhaps 4 feet high, and weighs about 3,500 pounds.

The queen speaks Formian and Common, although she can communicate with any creature telepathically.

#### Combat

The queen does not fight. She has no ability to move. If necessary, a team of workers and myrmarchs (or dominated slaves) haul her enormous bulk to where she needs to go. This sort of occurrence is very rare, however, and most of the time the queen remains within her well-defended chambers.

Despite her utter lack of physical activity, the queen can cast spells and use spell-like abilities to great effect in her own defense as well as the defense of the hive-city.

**Spells:** The queen casts arcane spells as a 17th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/8/7/7/7/7/6/6/4, base save DC 15 + spell level): 0—_acid splash, arcane mark, daze, detect magic, light, mage hand, read magic, resistance, touch of fatigue;_ 1st—_comprehend languages, identify, mage armor, magic missile, shield;_ 2nd— _hypnotic pattern, invisibility, protection from arrows, resist energy, scorching ray;_ 3rd—_dispel magic, heroism, nondetection, slow;_ 4th— _confusion, detect scrying, black tentacles, scrying;_ 5th—_cone of cold, dismissal, teleport, wall of force;_ 6th—_analyze dweomer, geas/quest, repulsion;_ 7th—_summon monster VII, vision, waves of exhaustion;_ 8th—_prismatic wall, temporal stasis._

**Spell-Like Abilities:** At will—_calm emotions_ (DC 17), _charm monster_ (DC 19), _clairaudience/clairvoyance, detect chaos, detect thoughts, dictum_ (DC 22), _divination, hold monster_ (DC 20), _magic circle against chaos, order’s wrath_ (DC 19), _shield of law_ (DC 23), _true seeing._ Caster level 17th. The save DCs are Charisma-based.

**Telepathy (Su):** The queen can communicate telepathically with any intelligent creature within 50 miles whose presence she is aware of.','{"full_attack":"Sting +10 melee (2d4+4 plus poison) and 2 claws +8 melee (1d6+2)","environment":"A lawful-aligned plane","organization":"Solitary (1 plus 1 dominated creature) or conscription team (2–4 plus 1 dominated creature per team member)","treasure":"Standard","advancement":"7–9 HD (Medium); 10–12 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"6d8+12 (39 hp)","hit_points":39,"base_attack_grapple":"+6/+10","attack":"Sting +10 melee (2d4+4 plus poison)","full_attack":"Sting +10 melee (2d4+4 plus poison) and 2 claws +8 melee (1d6+2)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +8, Will +8","abilities":{"str":"18","dex":"16","con":"14","int":"11","wis":"16","cha":"19"},"skills":"Climb +13, Diplomacy +6, Hide +12, Intimidate +13, Listen +12, Search +7, Spot +8, Survival +1 Move Silently +12, Search +9, Sense Motive +12, Spot +12, Survival +3 (+5 following tracks)","feats":"Dodge, Improved Initiative, Multiattack","special_attacks":"Dominate monster, dominated creature, poison","special_qualities":"Hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 21, telepathy 100 ft."},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('formian_myrmarch','Formian Myrmarch','Formian Myrmarch','10','Large','Outsider (Lawful, Extraplanar)','Always lawful neutral','12d8+48 (102 hp)',102,'+8','50 ft. (10 squares)','28 (–1 size, +4 Dex, +15 natural), touch 13, flat-footed 24','+12/+20','Sting +15 melee (2d4+4 plus poison) or javelin +15 ranged (1d6+4)','10 ft./5 ft.','+12','+12','+11',19,18,18,16,16,17,'Climb +19, Concentration +18, Diplomacy +20, Hide +15, Knowledge (any one) +18, Listen +18, Move Silently +19, Search +18, Sense Motive +18, Spot +18, Survival +3 (+5 following tracks)','Dodge, Improved Initiative, Mobility, Multiattack, Spring Attack','{"special_attacks":"Poison, spell-like abilities","special_qualities":"Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 25"}'::jsonb,'A formian resembles a cross between an ant and a centaur. All formians are covered in a brownish-red carapace; size and appearance differs for each variety.

### Combat

Formians are generally aggressive, seeking to subdue all they encounter. If they perceive even the slightest threat to their hive-city or to their queen, they attack immediately and fight to the death. Any formian also attacks immediately if ordered to do so by a superior.

**Hive Mind (Ex):** All formians within 50 miles of their queen are in constant communication. If one is aware of a particular danger, they all are. If one in a group is not flatfooted, none of them are. No formian in a group is considered flanked unless all of them are.

### Worker

While workers cannot speak, they can convey simple concepts (such as danger) by body movements. Through the hive mind, however, they can communicate just fine—although their intelligence still limits the concepts that they can grasp.

A worker is about 3 feet long and about 2-1/2 feet high at the front. It weighs about 60 pounds. Its hands are suitable only for manual labor.

#### Combat

Formian workers fight only to defend their hive-cities, using their mandibled bite.

A formian worker’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**_Cure Serious Wounds_ (Sp):** Eight workers together can heal a creature’s wounds as though using the _cure serious wounds_ spell (caster level 7th). This is a full-round action for all eight workers.

**_Make Whole_ (Sp):** Three workers together can repair an object as though using the _make whole_ spell (caster level 7th). This is a fullround action for all three workers.

### Warrior

Warriors communicate through the hive mind to convey battle plans and make reports to their commanders. They cannot speak otherwise.

A warrior is about is about 5 feet long and about 4-1/2 feet high at the front. It weighs about 180 pounds.

#### Combat

Warriors are wicked combatants, using claws, bite, and a poisonous sting all at once. Through the hive mind, they attack with coordinated and extremely efficient tactics.

A formian warrior’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Taskmaster

These formians communicate only telepathically and derive sustenance from the mental energies of those they dominate.

A taskmaster is about the same size as a warrior.

#### Combat

Taskmasters rely on their dominated slaves to fight for them if at all possible. If necessary, though, they can defend themselves with claws and a poison sting.

A formian taskmaster’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Dominate Monster (Su):** A taskmaster can use a _dominate monster_ ability as the spell from a 10th-level caster (Will DC 17 negates), although the subject may be of any kind and may be up to Large size. Creatures that successfully save cannot be affected by the same taskmaster’s dominate monster ability for 24 hours. A single taskmaster can dominate up to four subjects at a time. The save DC is Charisma-based.

**Dominated Creature (Ex):** A taskmaster is never encountered alone. One dominated nonformian creature always accompanies it (choose or determine randomly any creature of CR 4).

**Poison (Ex):** Injury, Fortitude DC 15, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Myrmarch

Myrmarchs are the elite of formian society. Much more than those beneath them, these creatures are individuals, with goals, desires, and creative thought.

A myrmarch is about is about 7 feet long and about 5-1/2 feet high at the front. It weighs about 1,500 pounds. Its claws are capable of fine manipulation, like human hands. Each myrmarch wears a bronze helm to signify its position (the more elaborate the helm, the more prestigious the position).

Myrmarchs speak Formian and Common.

#### Combat

Myrmarchs’ claws are like hands and thus serve no combat purpose.

Myrmarchs occasionally employ javelins for ranged attacks, coated with poison from their own stingers.

They fight intelligently, aiding those under them (if any such are present) and commanding them through the hive mind. If chaotic creatures are present, however, a myrmarch is singleminded in its quest to destroy them.

A formian myrmarch’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 20, initial and secondary damage 2d6 Dex. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 17), _clairaudience/ clairvoyance, detect chaos, detect thoughts_ (DC 15), _magic circle against chaos_, _greater teleport;_ 1/day—_dictum_ (DC 20), _order’s wrath_ (DC 17). Caster level 12th. The save DCs are Charisma-based.

### Queen

The formian queen cannot move. With her telepathic abilities, though, she can send instructions to and get reports from any formian within her range.

She is about 10 feet long, perhaps 4 feet high, and weighs about 3,500 pounds.

The queen speaks Formian and Common, although she can communicate with any creature telepathically.

#### Combat

The queen does not fight. She has no ability to move. If necessary, a team of workers and myrmarchs (or dominated slaves) haul her enormous bulk to where she needs to go. This sort of occurrence is very rare, however, and most of the time the queen remains within her well-defended chambers.

Despite her utter lack of physical activity, the queen can cast spells and use spell-like abilities to great effect in her own defense as well as the defense of the hive-city.

**Spells:** The queen casts arcane spells as a 17th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/8/7/7/7/7/6/6/4, base save DC 15 + spell level): 0—_acid splash, arcane mark, daze, detect magic, light, mage hand, read magic, resistance, touch of fatigue;_ 1st—_comprehend languages, identify, mage armor, magic missile, shield;_ 2nd— _hypnotic pattern, invisibility, protection from arrows, resist energy, scorching ray;_ 3rd—_dispel magic, heroism, nondetection, slow;_ 4th— _confusion, detect scrying, black tentacles, scrying;_ 5th—_cone of cold, dismissal, teleport, wall of force;_ 6th—_analyze dweomer, geas/quest, repulsion;_ 7th—_summon monster VII, vision, waves of exhaustion;_ 8th—_prismatic wall, temporal stasis._

**Spell-Like Abilities:** At will—_calm emotions_ (DC 17), _charm monster_ (DC 19), _clairaudience/clairvoyance, detect chaos, detect thoughts, dictum_ (DC 22), _divination, hold monster_ (DC 20), _magic circle against chaos, order’s wrath_ (DC 19), _shield of law_ (DC 23), _true seeing._ Caster level 17th. The save DCs are Charisma-based.

**Telepathy (Su):** The queen can communicate telepathically with any intelligent creature within 50 miles whose presence she is aware of.','{"full_attack":"Sting +15 melee (2d4+4 plus poison) and bite +13 melee (2d6+2); or javelin +15/+10 ranged (1d6+4)","environment":"A lawful-aligned plane","organization":"Solitary, team (2–4), or platoon (1 plus 7–18 workers and 6–11 warriors)","treasure":"Standard","advancement":"13–18 HD (Large); 19–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"12d8+48 (102 hp)","hit_points":102,"base_attack_grapple":"+12/+20","attack":"Sting +15 melee (2d4+4 plus poison) or javelin +15 ranged (1d6+4)","full_attack":"Sting +15 melee (2d4+4 plus poison) and bite +13 melee (2d6+2); or javelin +15/+10 ranged (1d6+4)","space_reach":"10 ft./5 ft.","saves":"Fort +12, Ref +12, Will +11","abilities":{"str":"19","dex":"18","con":"18","int":"16","wis":"16","cha":"17"},"skills":"Climb +19, Concentration +18, Diplomacy +20, Hide +15, Knowledge (any one) +18, Listen +18, Move Silently +19, Search +18, Sense Motive +18, Spot +18, Survival +3 (+5 following tracks)","feats":"Dodge, Improved Initiative, Mobility, Multiattack, Spring Attack","special_attacks":"Poison, spell-like abilities","special_qualities":"Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 25"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('formian_queen','Formian Queen','Formian Queen','17','Large','Outsider (Lawful, Extraplanar)','Always lawful neutral','20d8+100 (190 hp)',190,'–5','0 ft.','23 (–1 size, +14 natural), touch 9, flat-footed 23','+20/+24','—','10 ft./5 ft.','+19','','+19',null,null,20,20,20,21,'Appraise +28, Bluff +28, Concentration +28, Diplomacy +32, Disguise +5 (+7 acting), Intimidate +30, Knowledge (any three) +28, Listen +30, Sense Motive +28, Spellcraft +28 (+30 scrolls), Spot +30, Use Magic Device +28 (+30 scrolls)','Alertness, Eschew MaterialsB, Great Fortitude, Improved Counterspell, Iron Will, item creation feat (any one), Maximize Spell, Spell Focus (enchantment)','{"special_attacks":"Spell-like abilities, spells","special_qualities":"Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 30, telepathy"}'::jsonb,'A formian resembles a cross between an ant and a centaur. All formians are covered in a brownish-red carapace; size and appearance differs for each variety.

### Combat

Formians are generally aggressive, seeking to subdue all they encounter. If they perceive even the slightest threat to their hive-city or to their queen, they attack immediately and fight to the death. Any formian also attacks immediately if ordered to do so by a superior.

**Hive Mind (Ex):** All formians within 50 miles of their queen are in constant communication. If one is aware of a particular danger, they all are. If one in a group is not flatfooted, none of them are. No formian in a group is considered flanked unless all of them are.

### Worker

While workers cannot speak, they can convey simple concepts (such as danger) by body movements. Through the hive mind, however, they can communicate just fine—although their intelligence still limits the concepts that they can grasp.

A worker is about 3 feet long and about 2-1/2 feet high at the front. It weighs about 60 pounds. Its hands are suitable only for manual labor.

#### Combat

Formian workers fight only to defend their hive-cities, using their mandibled bite.

A formian worker’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**_Cure Serious Wounds_ (Sp):** Eight workers together can heal a creature’s wounds as though using the _cure serious wounds_ spell (caster level 7th). This is a full-round action for all eight workers.

**_Make Whole_ (Sp):** Three workers together can repair an object as though using the _make whole_ spell (caster level 7th). This is a fullround action for all three workers.

### Warrior

Warriors communicate through the hive mind to convey battle plans and make reports to their commanders. They cannot speak otherwise.

A warrior is about is about 5 feet long and about 4-1/2 feet high at the front. It weighs about 180 pounds.

#### Combat

Warriors are wicked combatants, using claws, bite, and a poisonous sting all at once. Through the hive mind, they attack with coordinated and extremely efficient tactics.

A formian warrior’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Taskmaster

These formians communicate only telepathically and derive sustenance from the mental energies of those they dominate.

A taskmaster is about the same size as a warrior.

#### Combat

Taskmasters rely on their dominated slaves to fight for them if at all possible. If necessary, though, they can defend themselves with claws and a poison sting.

A formian taskmaster’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Dominate Monster (Su):** A taskmaster can use a _dominate monster_ ability as the spell from a 10th-level caster (Will DC 17 negates), although the subject may be of any kind and may be up to Large size. Creatures that successfully save cannot be affected by the same taskmaster’s dominate monster ability for 24 hours. A single taskmaster can dominate up to four subjects at a time. The save DC is Charisma-based.

**Dominated Creature (Ex):** A taskmaster is never encountered alone. One dominated nonformian creature always accompanies it (choose or determine randomly any creature of CR 4).

**Poison (Ex):** Injury, Fortitude DC 15, initial and secondary damage 1d6 Str. The save DC is Constitution-based.

### Myrmarch

Myrmarchs are the elite of formian society. Much more than those beneath them, these creatures are individuals, with goals, desires, and creative thought.

A myrmarch is about is about 7 feet long and about 5-1/2 feet high at the front. It weighs about 1,500 pounds. Its claws are capable of fine manipulation, like human hands. Each myrmarch wears a bronze helm to signify its position (the more elaborate the helm, the more prestigious the position).

Myrmarchs speak Formian and Common.

#### Combat

Myrmarchs’ claws are like hands and thus serve no combat purpose.

Myrmarchs occasionally employ javelins for ranged attacks, coated with poison from their own stingers.

They fight intelligently, aiding those under them (if any such are present) and commanding them through the hive mind. If chaotic creatures are present, however, a myrmarch is singleminded in its quest to destroy them.

A formian myrmarch’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 20, initial and secondary damage 2d6 Dex. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 17), _clairaudience/ clairvoyance, detect chaos, detect thoughts_ (DC 15), _magic circle against chaos_, _greater teleport;_ 1/day—_dictum_ (DC 20), _order’s wrath_ (DC 17). Caster level 12th. The save DCs are Charisma-based.

### Queen

The formian queen cannot move. With her telepathic abilities, though, she can send instructions to and get reports from any formian within her range.

She is about 10 feet long, perhaps 4 feet high, and weighs about 3,500 pounds.

The queen speaks Formian and Common, although she can communicate with any creature telepathically.

#### Combat

The queen does not fight. She has no ability to move. If necessary, a team of workers and myrmarchs (or dominated slaves) haul her enormous bulk to where she needs to go. This sort of occurrence is very rare, however, and most of the time the queen remains within her well-defended chambers.

Despite her utter lack of physical activity, the queen can cast spells and use spell-like abilities to great effect in her own defense as well as the defense of the hive-city.

**Spells:** The queen casts arcane spells as a 17th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/8/7/7/7/7/6/6/4, base save DC 15 + spell level): 0—_acid splash, arcane mark, daze, detect magic, light, mage hand, read magic, resistance, touch of fatigue;_ 1st—_comprehend languages, identify, mage armor, magic missile, shield;_ 2nd— _hypnotic pattern, invisibility, protection from arrows, resist energy, scorching ray;_ 3rd—_dispel magic, heroism, nondetection, slow;_ 4th— _confusion, detect scrying, black tentacles, scrying;_ 5th—_cone of cold, dismissal, teleport, wall of force;_ 6th—_analyze dweomer, geas/quest, repulsion;_ 7th—_summon monster VII, vision, waves of exhaustion;_ 8th—_prismatic wall, temporal stasis._

**Spell-Like Abilities:** At will—_calm emotions_ (DC 17), _charm monster_ (DC 19), _clairaudience/clairvoyance, detect chaos, detect thoughts, dictum_ (DC 22), _divination, hold monster_ (DC 20), _magic circle against chaos, order’s wrath_ (DC 19), _shield of law_ (DC 23), _true seeing._ Caster level 17th. The save DCs are Charisma-based.

**Telepathy (Su):** The queen can communicate telepathically with any intelligent creature within 50 miles whose presence she is aware of.','{"full_attack":"—","environment":"A lawful-aligned plane","organization":"Hive (1 plus 100–400 workers, 11–40 warriors, 4–7 taskmasters with 1 dominated creature each, and 5–8 myrmarchs)","treasure":"Double standard","advancement":"21–30 HD (Huge); 31–40 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"20d8+100 (190 hp)","hit_points":190,"base_attack_grapple":"+20/+24","attack":"—","full_attack":"—","space_reach":"10 ft./5 ft.","saves":"Fort +19, Ref —, Will +19","abilities":{"str":null,"dex":null,"con":"20","int":"20","wis":"20","cha":"21"},"skills":"Appraise +28, Bluff +28, Concentration +28, Diplomacy +32, Disguise +5 (+7 acting), Intimidate +30, Knowledge (any three) +28, Listen +30, Sense Motive +28, Spellcraft +28 (+30 scrolls), Spot +30, Use Magic Device +28 (+30 scrolls)","feats":"Alertness, Eschew MaterialsB, Great Fortitude, Improved Counterspell, Iron Will, item creation feat (any one), Maximize Spell, Spell Focus (enchantment)","special_attacks":"Spell-like abilities, spells","special_qualities":"Fast healing 2, hive mind, immunity to poison, petrification, and cold, resistance to electricity 10, fire 10, and sonic 10, spell resistance 30, telepathy"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('frost_worm','Frost Worm','Frost Worm','12','Huge','Magical Beast (Cold)','Usually neutral','14d10+70 (147 hp)',147,'+4','30 ft. (6 squares), burrow 10 ft.','18 (–2 size, +10 natural), touch 8, flat-footed 18','+14/+30','Bite +21 melee (2d8+12 plus 1d8 cold)','15 ft./10 ft.','+14','+9','+6',26,10,20,2,11,11,'Hide +3*, Listen +5, Spot +5','Alertness, Improved Initiative, Improved Natural Attack (bite), Iron Will, Weapon Focus (bite)','{"special_attacks":"Trill, cold, breath weapon","special_qualities":"Darkvision 60 ft., death throes, immunity to cold, low-light vision, vulnerability to fire"}'::jsonb,'A frost worn cannot burrow through stone, but can manage ice and frozen earth. When moving through such hard materials it leaves behind a usable tunnel about 5 feet in diameter.

A frost worm is about 40 feet long, 5 feet in diameter, and weighs about 8,000 pounds.

### Combat

Frost worms lurk under the snow, waiting for prey to come near.

They begin an attack with a trill and then set upon helpless prey with their bite.

**Trill (Su):** A frost worm can emit a noise that forces its prey to stand motionless. This sonic mind-affecting compulsion affects all creatures other than frost worms within a 100-foot radius. Creatures must succeed on a DC 17 Will save or be stunned for as long as the worm trills and for 1d4 rounds thereafter, even if they are attacked. However, if attacked or violently shaken (a full-round action), a victim is allowed another saving throw. Once a creature has resisted or broken the effect, it cannot be affected again by that same frost worm’s trill for 24 hours. The effect’s caster level is 14th. The save DC is Charisma-based.

**Cold (Ex):** A frost worm’s body generates intense cold, causing opponents to take an extra 1d8 points of cold damage every time the creature succeeds on a bite attack. Creatures attacking a frost worm unarmed or with natural weapons take this same cold damage each time one of their attacks hits.

**Breath Weapon (Su):** 30-foot cone, once per hour, damage 15d6 cold, Reflex DC 22 half. Opponents held motionless by the frost worm’s trill get no saving throw. The save DC is Constitution-based.

**Death Throes (Ex):** When killed, a frost worm turns to ice and shatters in an explosion that deals 12d6 points of cold damage and 8d6 points of piercing damage to everything within 100 feet (Reflex half DC 22). The save DC is Constitution-based.

**Skills:** \*A frost worm, due to its coloration and its affinity for burying itself in the snow, has a +10 racial bonus on Hide checks in its native environment.','{"full_attack":"Bite +21 melee (2d8+12 plus 1d8 cold)","environment":"Cold plains","organization":"Solitary","treasure":"None","advancement":"15–21 HD (Huge); 22–42 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"14d10+70 (147 hp)","hit_points":147,"base_attack_grapple":"+14/+30","attack":"Bite +21 melee (2d8+12 plus 1d8 cold)","full_attack":"Bite +21 melee (2d8+12 plus 1d8 cold)","space_reach":"15 ft./10 ft.","saves":"Fort +14, Ref +9, Will +6","abilities":{"str":"26","dex":"10","con":"20","int":"2","wis":"11","cha":"11"},"skills":"Hide +3*, Listen +5, Spot +5","feats":"Alertness, Improved Initiative, Improved Natural Attack (bite), Iron Will, Weapon Focus (bite)","special_attacks":"Trill, cold, breath weapon","special_qualities":"Darkvision 60 ft., death throes, immunity to cold, low-light vision, vulnerability to fire"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('shrieker','Shrieker','Shrieker','1','Medium','Plant','Always neutral','2d8+2 (11 hp)',11,'–5','0 ft.','8 (–5 Dex, +3 natural), touch 5, flat-footed 8','+1/–4','—','5 ft./0 ft.','+4','','–4',null,null,13,null,2,1,'—','—','{"special_attacks":"Shriek","special_qualities":"Low-light vision, plant traits"}'::jsonb,'### Combat

Shriekers and violet fungi often work together to attract and kill prey. When the shriekers’ hellish racket attracts a curious creature, the violet fungus tries to kill it. Both creatures enjoy the fruits of a successful hunt.

### Shrieker

A shrieker is a stationary fungus that emits a loud noise to attract prey or when disturbed. Shriekers live in dark, subterranean places, often in the company of violet fungi, whose poison they are immune to.

Shriekers come in of shades of purple.

#### Combat

A shrieker has no means of attack. Instead, it lures prey to its vicinity by emitting a loud noise.

**Shriek (Ex):** Movement or a light source within 10 feet of a shrieker causes the fungus to emit a piercing sound that lasts for 1d3 rounds. The sound attracts nearby creatures that are disposed to investigate it. Some creatures that live near shriekers come to learn that the fungus’s noise means there is food nearby.

### Violet Fungus

Violet fungi resemble shriekers and are often found growing among them.

A violet fungi’s coloration ranges from purple overall to dull gray or violet covered with purple spots.

#### Combat

A violet fungus flails about with its tentacles at living creatures that come within its reach.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d4 Str and 1d4 Con. The save DC is Constitution-based.','{"full_attack":"—","environment":"Underground","organization":"Solitary or patch (3–5)","treasure":"None","advancement":"3 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/–4","attack":"—","full_attack":"—","space_reach":"5 ft./0 ft.","saves":"Fort +4, Ref —, Will –4","abilities":{"str":null,"dex":null,"con":"13","int":null,"wis":"2","cha":"1"},"skills":"—","feats":"—","special_attacks":"Shriek","special_qualities":"Low-light vision, plant traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('violet_fungus','Violet Fungus','Violet Fungus','3','Medium','Plant','Always neutral','2d8+6 (15 hp)',15,'–1','10 ft. (2 squares)','13 (–1 Dex, +4 natural), touch 9, flat-footed 13','+1/+3','Tentacle +3 melee (1d6+2 plus poison)','5 ft./10 ft.','+6','–1','+0',14,8,16,null,11,9,'—','—','{"special_attacks":"Poison","special_qualities":"Low-light vision, plant traits"}'::jsonb,'### Combat

Shriekers and violet fungi often work together to attract and kill prey. When the shriekers’ hellish racket attracts a curious creature, the violet fungus tries to kill it. Both creatures enjoy the fruits of a successful hunt.

### Shrieker

A shrieker is a stationary fungus that emits a loud noise to attract prey or when disturbed. Shriekers live in dark, subterranean places, often in the company of violet fungi, whose poison they are immune to.

Shriekers come in of shades of purple.

#### Combat

A shrieker has no means of attack. Instead, it lures prey to its vicinity by emitting a loud noise.

**Shriek (Ex):** Movement or a light source within 10 feet of a shrieker causes the fungus to emit a piercing sound that lasts for 1d3 rounds. The sound attracts nearby creatures that are disposed to investigate it. Some creatures that live near shriekers come to learn that the fungus’s noise means there is food nearby.

### Violet Fungus

Violet fungi resemble shriekers and are often found growing among them.

A violet fungi’s coloration ranges from purple overall to dull gray or violet covered with purple spots.

#### Combat

A violet fungus flails about with its tentacles at living creatures that come within its reach.

**Poison (Ex):** Injury, Fortitude DC 14, initial and secondary damage 1d4 Str and 1d4 Con. The save DC is Constitution-based.','{"full_attack":"4 tentacles +3 melee (1d6+2 plus poison)","environment":"Underground","organization":"Solitary, patch (2–4), or mixed patch (2–4 violet fungi and 3–5 shriekers)","treasure":"None","advancement":"3–6 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d8+6 (15 hp)","hit_points":15,"base_attack_grapple":"+1/+3","attack":"Tentacle +3 melee (1d6+2 plus poison)","full_attack":"4 tentacles +3 melee (1d6+2 plus poison)","space_reach":"5 ft./10 ft.","saves":"Fort +6, Ref –1, Will +0","abilities":{"str":"14","dex":"8","con":"16","int":null,"wis":"11","cha":"9"},"skills":"—","feats":"—","special_attacks":"Poison","special_qualities":"Low-light vision, plant traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('gargoyle','Gargoyle','Gargoyle','4','Medium','Monstrous Humanoid (Earth)','Usually chaotic evil','4d8+19 (37 hp)',37,'+2','40 ft. (8 squares), fly 60 ft. (average)','16 (+2 Dex, +4 natural), touch 12, flat-footed 14','+4/+6','Claw +6 melee (1d4+2)','5 ft./5 ft.','+5','+6','+4',15,14,18,6,11,7,'Hide +7*, Listen +4, Spot +4','Multiattack, Toughness','{"special_attacks":"—","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., freeze"}'::jsonb,'Gargoyles often appear to be winged stone statues, for they can perch indefinitely without moving and use this disguise to surprise their foes. They require no food, water, or air, but often eat their fallen foes out of fondness for inflicting pain.

Gargoyles speak Common and Terran.

### Combat

Gargoyles either remain still, then suddenly attack, or dive onto their prey.

A gargoyle’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Freeze (Ex):** A gargoyle can hold itself so still it appears to be a statue. An observer must succeed on a DC 20 Spot check to notice the gargoyle is really alive.

**Skills:** Gargoyles have a +2 racial bonus on Hide, Listen, and Spot checks. \*The Hide bonus increases by +8 when a gargoyle is concealed against a background of stone.

### Kapoacinth

These cousins of the gargoyle have the aquatic subtype. They have a base land speed of 40 feet and a swim speed of 60 feet (no fly speed) and are found only in aquatic environments.

### Gargoyles as Characters

Gargoyle characters possess the following racial traits.

— +4 Strength, +4 Dexterity, +8 Constitution, –4 Intelligence, –4 Charisma.

—Medium size.

—A gargoyle’s base land speed is 40 feet. It also has a fly speed of 60 feet (average).

—Darkvision out to 60 feet.

—Racial Hit Dice: A gargoyle begins with four levels of monstrous humanoid, which provide 4d8 Hit Dice, a base attack bonus of +4, and base saving throw bonuses of Fort +1, Ref +4, and Will +4.

—Racial Skills: A gargoyle’s monstrous humanoid levels give it skill points equal to 7 x (2 + Int modifier). Its class skills are Hide, Listen, and Spot. A gargoyle has a +2 racial bonus on Hide, Listen, and Spot checks, and an additional +8 bonus on Hide checks when it is concealed against a background of stone.

—Racial Feats: A gargoyle’s monstrous humanoid levels give it two feats.

— +4 natural armor bonus.

—Special Qualities (see above): Damage reduction 10/magic, freeze.

—Automatic Languages: Common. Bonus Languages: Auran, Dwarven, Elven, Gnome, Halfling, Giant, Terran.

—Favored Class: Fighter.

—Level adjustment +5.','{"full_attack":"2 claws +6 melee (1d4+2) and bite +4 melee (1d6+1) and gore +4 melee (1d6+1)","environment":"Any","organization":"Solitary, pair, or wing (5–16)","treasure":"Standard","advancement":"5–6 HD (Medium); 7–12 HD (Large)","level_adjustment":"+5","statblock":{"hit_dice":"4d8+19 (37 hp)","hit_points":37,"base_attack_grapple":"+4/+6","attack":"Claw +6 melee (1d4+2)","full_attack":"2 claws +6 melee (1d4+2) and bite +4 melee (1d6+1) and gore +4 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +6, Will +4","abilities":{"str":"15","dex":"14","con":"18","int":"6","wis":"11","cha":"7"},"skills":"Hide +7*, Listen +4, Spot +4","feats":"Multiattack, Toughness","special_attacks":"—","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., freeze"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('djinni','Djinni','Djinni','5 (noble 8)','Large','Outsider (Air, Extraplanar)','Always chaotic good','7d8+14 (45 hp)',45,'+8','20 ft. (4 squares), fly 60 ft. (perfect)','16 (–1 size, +4 Dex, +3 natural), touch 13, flat-footed 12','+7/+15','Slam +10 melee (1d8+4)','10 ft./10 ft.','+7','+9','+7',18,19,14,14,15,15,'Appraise +12, Concentration +12, Craft (any one) +12, Diplomacy +4, Escape Artist +14, Knowledge (any one) +12, Listen +12, Move Silently +14, Sense Motive +12, Spellcraft +12, Spot +12, Use Rope +4 (+6 with bindings)','Combat Casting, Combat Reflexes, Dodge, Improved InitiativeB','{"special_attacks":"Air mastery, spell-like abilities, whirlwind","special_qualities":"Darkvision 60 ft., immunity to acid, plane shift, telepathy 100 ft."}'::jsonb,'The djinn (singular djinni) are genies from the Elemental Plane of Air.

A djinni is about 10-1/2 feet tall and weighs about 1,000 pounds.

Djinn speak Auran, Celestial, Common, and Ignan.

#### Combat

Djinn disdain physical combat, preferring to use their magical powers and aerial abilities against foes. A djinni overmatched in combat usually takes flight and becomes a whirlwind to harass those who follow.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against a djinni.

**Spell-Like Abilities:** At will—_invisibility_ (self only); 1/day— _create food and water, create wine_ (as _create water,_ but wine instead), _major creation_ (created vegetable matter is permanent), _persistent image_ (DC 17), _wind walk._ Once per day, a djinni can assume _gaseous form_ (as the spell) for up to 1 hour. Caster level 20th. The save DCs are Charisma-based.

**Whirlwind (Su):** A djinni can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 7 rounds. In this form, it can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top and up to 50 feet tall. The djinni controls the exact height, but it must be at least 10 feet.

A djinni’s movement while in whirlwind form does not provoke attacks of opportunity, even if the djinni enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the djinni moves into or through the creature’s space.

Creatures one or more size categories smaller than the djinni might take damage when caught in the whirlwind and be lifted into the air. An affected creature must succeed on a DC 20 Reflex save when it comes into contact with the whirlwind or take 3d6 points of damage. It must also succeed on a second DC 20 Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking 1d8 points of damage each round. A creature with a fly speed is allowed a DC 20 Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The save DC is Strength-based and includes a +3 racial adjustment.

Creatures trapped in the whirlwind cannot move except to go where the djinni carries them or to escape the whirlwind. Creatures caught in the whirlwind can otherwise act normally, but must make a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The djinni can have only as many trapped inside a whirlwind at one time as will fit inside the whirlwind’s volume.

The djinni can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the djinni and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

A djinni in whirlwind form cannot make melee attacks and does not threaten the area around it.

#### Noble Djinn

Some djinn (1% of the total population) are noble. A noble djinni can grant three _wishes_ to any being (nongenies only) who captures it. Noble djinn perform no other services and, upon granting the third _wish,_ are free of their servitude. Noble djinn are as strong as efreet (see below), with 10 Hit Dice.','{"full_attack":"2 slams +10 melee (1d8+4)","environment":"Elemental Plane of Air","organization":"Solitary, company (2–4), or band (6–15)","treasure":"Standard","advancement":"8–10 HD (Large); 11–21 (Huge)","level_adjustment":"+6","statblock":{"hit_dice":"7d8+14 (45 hp)","hit_points":45,"base_attack_grapple":"+7/+15","attack":"Slam +10 melee (1d8+4)","full_attack":"2 slams +10 melee (1d8+4)","space_reach":"10 ft./10 ft.","saves":"Fort +7, Ref +9, Will +7","abilities":{"str":"18","dex":"19","con":"14","int":"14","wis":"15","cha":"15"},"skills":"Appraise +12, Concentration +12, Craft (any one) +12, Diplomacy +4, Escape Artist +14, Knowledge (any one) +12, Listen +12, Move Silently +14, Sense Motive +12, Spellcraft +12, Spot +12, Use Rope +4 (+6 with bindings)","feats":"Combat Casting, Combat Reflexes, Dodge, Improved InitiativeB","special_attacks":"Air mastery, spell-like abilities, whirlwind","special_qualities":"Darkvision 60 ft., immunity to acid, plane shift, telepathy 100 ft."},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('efreeti','Efreeti','Efreeti','8','Large','Outsider (Extraplanar, Fire)','Always lawful evil','10d8+20 (65 hp)',65,'+7','20 ft. (4 squares), fly 40 ft. (perfect)','18 (–1 size, +3 Dex, +6 natural), touch 12, flat-footed 15','+10/+20','Slam +15 melee (1d8+6 plus 1d6 fire)','10 ft./ 10 ft.','+9','+10','+9',23,17,14,12,15,15,'Bluff +15, Craft (any one) +14, Concentration +15, Diplomacy +6, Disguise +2 (+4 acting), Intimidate +17, Listen +15, Move Silently +16, Sense Motive +15, Spellcraft +14, Spot +15','Combat Casting, Combat Reflexes, Dodge, Improved InitiativeB, Quicken Spell-Like Ability (scorching ray)','{"special_attacks":"Change size, heat, spell-like abilities","special_qualities":"Darkvision 60 ft., immunity to fire, plane shift, telepathy 100 ft., vulnerability to cold"}'::jsonb,'The efreet (singular efreeti) are genies from the Elemental Plane of Fire.

An efreeti stands about 12 feet tall and weighs about 2,000 pounds.

Efreet speak Auran, Common, Ignan, and Infernal.

#### Combat

Efreet love to mislead, befuddle, and confuse their foes. They do so for enjoyment as well as a battle tactic.

**_Change Size_ (Sp):** Twice per day, an efreeti can magically change a creature’s size. This works just like an _enlarge person_ or _reduce person_ spell (the efreeti chooses when using the ability), except that the ability can work on the efreeti. A DC 13 Fortitude save negates the effect. The save DC is Charisma-based. This is the equivalent of a 2nd-level spell.

**Heat (Ex):** An efreeti’s red-hot body deals 1d6 points of extra fire damage whenever it hits in melee, or in each round it maintains a hold when grappling.

**Spell-Like Abilities:** At will—_detect magic, produce flame, pyrotechnics_ (DC 14), _scorching ray_ (1 ray only); 3/day—_invisibility, wall of fire_ (DC 16); 1/day—grant up to three _wishes_ (to nongenies only), _gaseous form, permanent image_ (DC 18), _polymorph_ (self only). Caster level 12th. The save DCs are Charisma-based.','{"full_attack":"2 slams +15 melee (1d8+6 plus 1d6 fire)","environment":"Elemental Plane of Fire","organization":"Solitary, company (2–4), or band (6–15)","treasure":"Standard coins; double goods; standard items","advancement":"11–15 HD (Large); 16–30 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"10d8+20 (65 hp)","hit_points":65,"base_attack_grapple":"+10/+20","attack":"Slam +15 melee (1d8+6 plus 1d6 fire)","full_attack":"2 slams +15 melee (1d8+6 plus 1d6 fire)","space_reach":"10 ft./ 10 ft.","saves":"Fort +9, Ref +10, Will +9","abilities":{"str":"23","dex":"17","con":"14","int":"12","wis":"15","cha":"15"},"skills":"Bluff +15, Craft (any one) +14, Concentration +15, Diplomacy +6, Disguise +2 (+4 acting), Intimidate +17, Listen +15, Move Silently +16, Sense Motive +15, Spellcraft +14, Spot +15","feats":"Combat Casting, Combat Reflexes, Dodge, Improved InitiativeB, Quicken Spell-Like Ability (scorching ray)","special_attacks":"Change size, heat, spell-like abilities","special_qualities":"Darkvision 60 ft., immunity to fire, plane shift, telepathy 100 ft., vulnerability to cold"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('janni','Janni','Janni','4','Medium','Outsider (Native)','Usually neutral','6d8+6 (33 hp)',33,'+6','20 ft. (4 squares), fly 15 ft. (perfect) in chainmail; base land speed 30 ft., base fly speed 20 ft. (perfect)','18 (+2 Dex, +1 natural, +5 chainmail), touch 12, flat-footed 16','+6/+9','Scimitar +9 melee (1d6+4/18–20) or longbow +8 ranged (1d8/x3)','5 ft./5 ft.','+6','+7','+7',16,15,12,14,15,13,'Appraise +11, Concentration +10, Craft (any two) +11, Diplomacy +3, Escape Artist +6, Listen +11, Move Silently +6, Ride +11, Sense Motive +11, Spot +11, Use Rope +2 (+4 with bindings)','Combat Reflexes, Dodge, Improved InitiativeB, Mobility','{"special_attacks":"Change size, spell-like abilities","special_qualities":"Darkvision 60 ft., elemental endurance, plane shift, resistance to fire 10, telepathy 100 ft."}'::jsonb,'The jann (singular janni) are the weakest of the genies. Jann are formed out of all four elements and must therefore spend most of their time on the Material Plane.

Jann speak Common, one elemental language (Aquan, Auran, Ignan, or Terran) and one alignment language (Abyssal, Celestial, or Infernal).

#### Combat

Jann are physically strong and courageous, and do not take kindly to insult or injury. If they meet a foe they cannot defeat in a standup fight, they use flight and _invisibility_ to regroup and maneuver to a more advantageous position.

**_Change Size_ (Sp):** Twice per day, a janni can magically change a creature’s size. This works just like an _enlarge person_ or _reduce person_ spell (the janni chooses when using the ability), except that the ability can work on the janni. A DC 13 Fortitude save negates the effect. The save DC is Charisma-based. This is the equivalent of a 2nd-level spell.

**Spell-Like Abilities:** 3/day—_invisibility_ (self only), _speak with animals._ Caster level 12th. Once per day a janni can _create food and water_ (caster level 7th) and can use _ethereal jaunt_ (caster level 12th) for 1 hour. The save DCs are Charisma-based.

**Elemental Endurance (Ex):** Jann can survive on the Elemental Planes of Air, Earth, Fire, or Water for up to 48 hours. Failure to return to the Material Plane before that time expires causes a janni to take 1 point of damage per additional hour spent on the elemental plane, until it dies or returns to the Material Plane.

#### Jann as Characters

Janni characters possess the following racial traits.

— +6 Strength, +4 Dexterity, +2 Constitution, +4 Intelligence, +4 Wisdom, +2 Charisma.

—Medium size.

—A janni’s base land speed is 30 feet. It also has a fly speed of 20 feet (perfect).

—Darkvision out to 60 feet.

—Racial Hit Dice: A janni begins with six levels of outsider, which provide 6d8 Hit Dice, a base attack bonus of +6, and base saving throw bonuses of Fort +5, Ref +5, and Will +5.

—Racial Skills: A janni’s outsider levels give it skill points equal to 9 x (8 + Int modifier). Its class skills are Appraise, Concentration, Craft (any), Escape Artist, Listen, Move Silently, Ride, Sense Motive, and Spot.

—Racial Feats: A janni’s outsider levels give it three feats. A janni receives Improved Initiative as a bonus feat.

— +1 natural armor bonus.

—Special Attacks (see above): _Change size,_ spell-like abilities.

—Special Qualities (see above): Elemental endurance, _plane shift,_ resistance to fire 10, telepathy. 100 ft.

—Automatic Languages: Common. Bonus Languages: Abyssal, Aquan, Auran, Celestial, Ignan, Infernal, Terran.

—Favored Class: Rogue.

—Level adjustment +5.','{"full_attack":"Scimitar +9/+4 melee (1d6+4/18–20) or longbow +8/+3 ranged (1d8/x3)","environment":"Warm deserts","organization":"Solitary, company (2–4), or band (6–15)","treasure":"Standard","advancement":"7–9 HD (Medium); 10–18 HD (Large)","level_adjustment":"+5","statblock":{"hit_dice":"6d8+6 (33 hp)","hit_points":33,"base_attack_grapple":"+6/+9","attack":"Scimitar +9 melee (1d6+4/18–20) or longbow +8 ranged (1d8/x3)","full_attack":"Scimitar +9/+4 melee (1d6+4/18–20) or longbow +8/+3 ranged (1d8/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +7, Will +7","abilities":{"str":"16","dex":"15","con":"12","int":"14","wis":"15","cha":"13"},"skills":"Appraise +11, Concentration +10, Craft (any two) +11, Diplomacy +3, Escape Artist +6, Listen +11, Move Silently +6, Ride +11, Sense Motive +11, Spot +11, Use Rope +2 (+4 with bindings)","feats":"Combat Reflexes, Dodge, Improved InitiativeB, Mobility","special_attacks":"Change size, spell-like abilities","special_qualities":"Darkvision 60 ft., elemental endurance, plane shift, resistance to fire 10, telepathy 100 ft."},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('ghaele','Ghaele','Ghaele','13','Medium','Outsider (Chaotic, Extraplanar, Good)','Always chaotic good','10d8+20 (65 hp)',65,'+5','50 ft. (10 squares), fly 150 ft. (perfect)','25 (+1 Dex, +14 natural), touch 11, flat-footed 24,or 14 (+1 Dex, +3 deflection), touch 14, flat-footed 13','+10/+17','+4 holy greatsword +21 melee (2d6+14/19–20) or light ray +11 ranged touch (2d12)','5 ft./5 ft.','+9','+8','+10',25,12,15,16,17,16,'Concentration +15, Diplomacy +5, Escape Artist +14, Handle Animal +16, Hide +14, Knowledge (any two) +16, Listen +16, Move Silently +14, Ride +16, Sense Motive +16, Spot +16, Use Rope +1 (+3 with bindings)','Combat Expertise, Improved Disarm, Improved Initiative, Improved Trip','{"special_attacks":"Spell-like abilities, spells, gaze","special_qualities":"Alternate form, damage reduction 10/evil and cold iron, darkvision 60 ft., immunity to electricity and petrification, lowlight vision, protective aura, resistance to cold 10 and fire 10 spell resistance 28, tongues"}'::jsonb,'A ghaele can take the form of an incorporeal globe of eldritch colors, 5 feet in diameter. A ghaele is about 6 feet tall and weighs about 170 pounds.

Ghaeles speak Celestial, Infernal, and Draconic, but can communicate with almost any creature, thanks to their _tongues_ ability.

### Combat

Ghaeles who enter combat prefer direct confrontation and damaging attacks to more subtle or insidious methods. They usually fight in their humanoid form, wielding incandescent _+4 holy greatswords._ If a ghaele desires mobility, it assumes its globe form and blasts the enemy with light rays.

A ghaele’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and good-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** At will—_aid, charm monster_ (DC 17), _color spray_ (DC 14), _comprehend languages, continual flame, cure light wounds_ (DC 14), _dancing lights, detect evil, detect thoughts_ (DC 15), _disguise self, dispel magic, hold monster_ (DC 18), _greater invisibility_ (self only), _major image_ (DC 16), _see invisibility, greater teleport_ (self plus 50 pounds of objects only); 1/day—_chain lightning_ (DC 19), _prismatic spray_ (DC 20), _wall of force._ Caster level 12th. The save DCs are Charisma-based.

**Spells:** Ghaeles in humanoid form can cast divine spells as 14th-level clerics. A ghaele has access to two of the following domains: Air, Animal, Chaos, Good, or Plant (plus any others from its deity). The save DCs are Wisdom-based.

_Typical Cleric Spells Prepared_ (6/7/7/6/5/4/4/3; save DC 13 + spell level): 0—_cure minor wounds, detect magic, guidance, light, resistance, virtue;_ 1st—_bless, calm animals\*, command, divine favor, obscuring mist, sanctuary, shield of faith;_ 2nd—_aid, align weapon, bear ’s endurance, hold animal\*, lesser restoration, remove paralysis, zone of truth;_ 3rd—_daylight, gaseous form\*, prayer, remove curse, searing light, water breathing;_ 4th—_death ward, dismissal, divine power, restoration, summon nature’s ally IV (animal)\*;_ 5th—_control winds\*, flame strike, raise dead, true seeing;_ 6th—_banishment, blade barrier, chain lightning\*, heal;_ 7th—_animal shapes\*, holy word, summon monster VII._

\*Domain spell. Domains: Air and Animal.

**Gaze (Su):** In humanoid form—slay evil creatures of 5 or less HD, range 60 feet, Will DC 18 negates. Even if the save succeeds, the creature is affected as though by a _fear_ spell for 2d10 rounds. Nonevil creatures, and evil creatures with more than 5 HD, must succeed on a DC 18 Will save or suffer the _fear_ effect. The save DCs are Charisma-based.

**Light Ray (Ex):** A ghaele in globe form can project light rays with a range of 300 feet. This attack overcomes damage reduction of any type.

**Alternate Form (Su):** A ghaele can shift between its humanoid and globe forms as a standard action. In humanoid form, it cannot fly or use its light rays, but it can use its gaze attack and spell-like abilities, make physical attacks, and cast spells. In globe form, it can fly, use its light rays, and use spell-like abilities, but it cannot cast spells or use its gaze attack. The globe form is incorporeal, and the ghaele has no Strength score while in that form.

A ghaele remains in one form until it chooses to assume a new one. A change in form cannot be dispelled, nor does the ghaele revert to any particular form when killed. A _true seeing_ spell or ability, however, reveals both forms simultaneously.

**Protective Aura (Su):** Against attacks made or effects created by evil creatures, this ability provides a +4 deflection bonus to AC and a +4 resistance bonus on saving throws to anyone within 20 feet of the ghaele. Otherwise, it functions as a _magic circle against evil_ effect and a _lesser globe of invulnerability,_ both with a radius of 20 feet (caster level equals ghaele’s HD). (The defensive benefits from the circle are not included in a ghaele’s statistics block.)

**Tongues (Su):** Ghaeles can speak with any creature that has a language, as though using a _tongues_ spell (caster level 14th). This ability is always active.','{"full_attack":"+4 holy greatsword +21/+16 melee (2d6+14/19–20) or 2 light rays +11 ranged touch (2d12)","environment":"A chaotic good-aligned plane","organization":"Solitary, pair, or squad (3–5)","treasure":"No coins; double goods; standard items","advancement":"11–15 HD (Medium); 16–30 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"10d8+20 (65 hp)","hit_points":65,"base_attack_grapple":"+10/+17","attack":"+4 holy greatsword +21 melee (2d6+14/19–20) or light ray +11 ranged touch (2d12)","full_attack":"+4 holy greatsword +21/+16 melee (2d6+14/19–20) or 2 light rays +11 ranged touch (2d12)","space_reach":"5 ft./5 ft.","saves":"Fort +9, Ref +8, Will +10","abilities":{"str":"25","dex":"12","con":"15","int":"16","wis":"17","cha":"16"},"skills":"Concentration +15, Diplomacy +5, Escape Artist +14, Handle Animal +16, Hide +14, Knowledge (any two) +16, Listen +16, Move Silently +14, Ride +16, Sense Motive +16, Spot +16, Use Rope +1 (+3 with bindings)","feats":"Combat Expertise, Improved Disarm, Improved Initiative, Improved Trip","special_attacks":"Spell-like abilities, spells, gaze","special_qualities":"Alternate form, damage reduction 10/evil and cold iron, darkvision 60 ft., immunity to electricity and petrification, lowlight vision, protective aura, resistance to cold 10 and fire 10 spell resistance 28, tongues"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('ghoul','Ghoul','Ghoul','1','Medium','Undead','Always chaotic evil','2d12 (13 hp)',13,'+2','30 ft. (6 squares)','14 (+2 Dex, +2 natural), touch 12, flat-footed 12','+1/+2','Bite +2 melee (1d6+1 plus paralysis)','5 ft./5 ft.','+0','+2','+5',13,15,null,13,14,12,'Balance +6, Climb +5, Hide +6, Jump +5, Move Silently +6, Spot +7','Multiattack','{"special_attacks":"Ghoul fever, paralysis","special_qualities":"Darkvision 60 ft., undead traits, +2 turn resistance"}'::jsonb,'Ghouls speak the languages they spoke in life (usually Common).

### Combat

Ghouls try to attack with surprise whenever possible. They strike from behind tombstones and burst from shallow graves.

**Ghoul Fever (Su):** Disease—bite, Fortitude DC 12, incubation period 1 day, damage 1d3 Con and 1d3 Dex. The save DC is Charisma-based.

An afflicted humanoid who dies of ghoul fever rises as a ghoul at the next midnight. A humanoid who becomes a ghoul in this way retains none of the abilities it possessed in life. It is not under the control of any other ghouls, but it hungers for the flesh of the living and behaves like a normal ghoul in all respects. A humanoid of 4 Hit Dice or more rises as a ghast, not a ghoul.

**Paralysis (Ex):** Those hit by a ghoul’s bite or claw attack must succeed on a DC 12 Fortitude save or be paralyzed for 1d4+1 rounds. Elves have immunity to this paralysis. The save DC is Charisma-based.

### Lacedon

These cousins of the ghoul have the aquatic subtype. They lurk near hidden reefs or other places where ships are likely to meet their end. They have a base land speed of 30 feet and a swim speed of 30 feet and are found only in aquatic environments.

### Ghast

Although these creatures look just like their lesser kin, they are far more deadly and cunning.

#### Combat

**Ghoul Fever (Su):** Disease—bite, Fortitude DC 15, incubation period 1 day, damage 1d3 Con and 1d3 Dex. The save DC is Charisma-based.

**Paralysis (Ex):** Those hit by a ghast’s bite or claw attack must succeed on a DC 15 Fortitude save or be paralyzed for 1d4+1 rounds. Even elves can be affected by this paralysis. The save DC is Charisma-based.

**Stench (Ex):** The stink of death and corruption surrounding these creatures is overwhelming. Living creatures

within 10 feet must succeed on a DC 15 Fortitude save or be sickened for 1d6+4 minutes. A creature that successfully saves cannot be affected again by the same ghast’s stench for 24 hours. A _delay poison_ or _neutralize poison_ spell removes the effect from a sickened creature. Creatures with immunity to poison are unaffected, and creatures resistant to poison receive their normal bonus on their saving throws. The save DC is Charisma-based.','{"full_attack":"Bite +2 melee (1d6+1 plus paralysis) and 2 claws +0 melee (1d3 plus paralysis)","environment":"Any (Lacedon: Any aquatic)","organization":"Solitary, gang (2–4), or pack (7–12)","treasure":"None","advancement":"3 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d12 (13 hp)","hit_points":13,"base_attack_grapple":"+1/+2","attack":"Bite +2 melee (1d6+1 plus paralysis)","full_attack":"Bite +2 melee (1d6+1 plus paralysis) and 2 claws +0 melee (1d3 plus paralysis)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +2, Will +5","abilities":{"str":"13","dex":"15","con":null,"int":"13","wis":"14","cha":"12"},"skills":"Balance +6, Climb +5, Hide +6, Jump +5, Move Silently +6, Spot +7","feats":"Multiattack","special_attacks":"Ghoul fever, paralysis","special_qualities":"Darkvision 60 ft., undead traits, +2 turn resistance"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('ghast','Ghast','Ghast','3','Medium','Undead','Always chaotic evil','4d12+3 (29 hp)',29,'+3','30 ft. (6 squares)','17 (+3 Dex, +4 natural), touch 12, flat-footed 14','+2/+5','Bite +5 melee (1d8+3 plus paralysis)','5 ft./5 ft.','+1','+4','+6',17,17,null,13,14,16,'Balance +7, Climb +9, Hide +8, Jump +9, Move Silently +8, Spot +8','Multiattack, Toughness','{"special_attacks":"Ghoul fever, paralyis, stench","special_qualities":"Darkvision 60 ft., undead traits, +2 turn resistance"}'::jsonb,'Ghouls speak the languages they spoke in life (usually Common).

### Combat

Ghouls try to attack with surprise whenever possible. They strike from behind tombstones and burst from shallow graves.

**Ghoul Fever (Su):** Disease—bite, Fortitude DC 12, incubation period 1 day, damage 1d3 Con and 1d3 Dex. The save DC is Charisma-based.

An afflicted humanoid who dies of ghoul fever rises as a ghoul at the next midnight. A humanoid who becomes a ghoul in this way retains none of the abilities it possessed in life. It is not under the control of any other ghouls, but it hungers for the flesh of the living and behaves like a normal ghoul in all respects. A humanoid of 4 Hit Dice or more rises as a ghast, not a ghoul.

**Paralysis (Ex):** Those hit by a ghoul’s bite or claw attack must succeed on a DC 12 Fortitude save or be paralyzed for 1d4+1 rounds. Elves have immunity to this paralysis. The save DC is Charisma-based.

### Lacedon

These cousins of the ghoul have the aquatic subtype. They lurk near hidden reefs or other places where ships are likely to meet their end. They have a base land speed of 30 feet and a swim speed of 30 feet and are found only in aquatic environments.

### Ghast

Although these creatures look just like their lesser kin, they are far more deadly and cunning.

#### Combat

**Ghoul Fever (Su):** Disease—bite, Fortitude DC 15, incubation period 1 day, damage 1d3 Con and 1d3 Dex. The save DC is Charisma-based.

**Paralysis (Ex):** Those hit by a ghast’s bite or claw attack must succeed on a DC 15 Fortitude save or be paralyzed for 1d4+1 rounds. Even elves can be affected by this paralysis. The save DC is Charisma-based.

**Stench (Ex):** The stink of death and corruption surrounding these creatures is overwhelming. Living creatures

within 10 feet must succeed on a DC 15 Fortitude save or be sickened for 1d6+4 minutes. A creature that successfully saves cannot be affected again by the same ghast’s stench for 24 hours. A _delay poison_ or _neutralize poison_ spell removes the effect from a sickened creature. Creatures with immunity to poison are unaffected, and creatures resistant to poison receive their normal bonus on their saving throws. The save DC is Charisma-based.','{"full_attack":"Bite +5 melee (1d8+3 plus paralysis) and 2 claws +3 melee (1d4+1 plus paralysis)","environment":"Any","organization":"Solitary, gang (2–4), or pack (2–4 plus 7–12 ghouls)","treasure":"Standard","advancement":"5–8 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"4d12+3 (29 hp)","hit_points":29,"base_attack_grapple":"+2/+5","attack":"Bite +5 melee (1d8+3 plus paralysis)","full_attack":"Bite +5 melee (1d8+3 plus paralysis) and 2 claws +3 melee (1d4+1 plus paralysis)","space_reach":"5 ft./5 ft.","saves":"Fort +1, Ref +4, Will +6","abilities":{"str":"17","dex":"17","con":null,"int":"13","wis":"14","cha":"16"},"skills":"Balance +7, Climb +9, Hide +8, Jump +9, Move Silently +8, Spot +8","feats":"Multiattack, Toughness","special_attacks":"Ghoul fever, paralyis, stench","special_qualities":"Darkvision 60 ft., undead traits, +2 turn resistance"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('cloud_giant','Cloud Giant','Cloud Giant','11','Huge','Giant (Air)','Usually neutral good or neutral evil','17d8+102 (178 hp)',178,'+1','50 ft. (10 squares)','25 (–2 size, +1 Dex, +12 natural, +4 chain shirt), touch 9, flat-footed 24','+12/+32','Gargantuan morningstar +22 melee (4d6+18) or slam +22 melee (1d6+12) or rock +12 ranged (2d8+12)','15 ft./15 ft.','+16','+6','+10',35,13,23,12,16,13,'Climb +19, Craft (any one) +11, Diplomacy +3, Intimidate +11, Listen +15, Perform (stringed instruments) +2, Sense Motive +9, Spot +15','Awesome Blow, Cleave, Improved Bull Rush, Improved Overrun, Iron Will, Power Attack','{"special_attacks":"Rock throwing, spell-like abilities","special_qualities":"Low-light vision, oversized weapon, rock catching, scent"}'::jsonb,'Cloud giants’ skin ranges in color from milky white to light sky blue. Their hair is silvery white or brass, and their eyes are iridescent blue. Adult males are about 18 feet tall and weigh about 5,000 pounds. Females are slightly shorter and lighter. Cloud giants can live to be 400 years old.

Cloud giants dress in the finest clothing available and wear jewelry. To many, appearance indicates station: The better the clothes and the finer the jewelry, the more important the wearer. They also appreciate music, and most can play one or more instruments (the harp is a favorite).

#### Combat

Cloud giants fight in well-organized units, using carefully developed battle plans. They prefer to fight from a position above their opponents. A favorite tactic is to circle the enemies, barraging them with rocks while the giants with magical abilities confound them with spells.

**Rock Throwing (Ex):** The range increment is 140 feet for a cloud giant’s thrown rocks.

**Oversized Weapon (Ex):** A cloud giant wields a great, two-handed morningstar (big enough for Gargantuan creatures) without penalty.

**Spell-Like Abilities:** 3/day—_levitate_ (self plus 2,000 pounds), _obscuring mist_; 1/day—_fog cloud_. Caster level 15th.','{"full_attack":"Gargantuan morningstar +22/+17/+12 melee (4d6+18) or 2 slams +22 melee (1d6+12) or rock +12 ranged (2d8+12)","environment":"Temperate mountains","organization":"Solitary, gang (2–4), family (2–4 plus 35% noncombatants plus 1 sorcerer or cleric of 4th–7th level plus 2–5 griffons or 2–8 dire lions), or band (6–9 plus 1 sorcerer or cleric of 4th–7th level plus 2–5 griffons or 2–8 dire lions)","treasure":"Standard coins; double goods; standard items","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"17d8+102 (178 hp)","hit_points":178,"base_attack_grapple":"+12/+32","attack":"Gargantuan morningstar +22 melee (4d6+18) or slam +22 melee (1d6+12) or rock +12 ranged (2d8+12)","full_attack":"Gargantuan morningstar +22/+17/+12 melee (4d6+18) or 2 slams +22 melee (1d6+12) or rock +12 ranged (2d8+12)","space_reach":"15 ft./15 ft.","saves":"Fort +16, Ref +6, Will +10","abilities":{"str":"35","dex":"13","con":"23","int":"12","wis":"16","cha":"13"},"skills":"Climb +19, Craft (any one) +11, Diplomacy +3, Intimidate +11, Listen +15, Perform (stringed instruments) +2, Sense Motive +9, Spot +15","feats":"Awesome Blow, Cleave, Improved Bull Rush, Improved Overrun, Iron Will, Power Attack","special_attacks":"Rock throwing, spell-like abilities","special_qualities":"Low-light vision, oversized weapon, rock catching, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('fire_giant','Fire Giant','Fire Giant','10','Large','Giant (Fire)','Often lawful evil','15d8+75 (142 hp)',142,'–1','30 ft. in half-plate armor (6 squares); base speed 40 ft.','23 (–1 size, –1 Dex, +8 natural, +7 half-plate armor) touch 8, flat-footed 23','+11/+25','Greatsword +20 melee (3d6+15) or slam +20 melee (1d4+10) or rock +10 ranged (2d6+10 plus 2d6 fire)','10 ft./10 ft.','+14','+4','+9',31,9,21,10,14,11,'Climb +9, Craft (any one) +6, Intimidate +6, Jump +9, Spot +14','Cleave, Great Cleave, Improved Overrun, Improved Sunder, Iron Will, Power Attack','{"special_attacks":"Rock throwing","special_qualities":"Immunity to fire, low-light vision, rock catching, vulnerability to cold"}'::jsonb,'Some fire giants have bright orange hair.. An adult male is 12 feet tall, has a chest that measures 9 feet

around, and weighs about 7,000 pounds. Females are slightly shorter and lighter. Fire giants can live to be 350 years old.

Fire giants wear sturdy cloth or leather garments colored red, orange, yellow, or black. Warriors wear helmets and half-plate armor of blackened steel.

#### Combat

Fire giants heat their rocks in a nearby fire, geyser, or lava pools, so that they deal extra fire damage. They favor magic flaming swords in melee (when they can get them). They are also fond of grabbing smaller opponents and tossing them somewhere very hot.

**Rock Throwing (Ex):** The range increment is 120 feet for a fire giant’s thrown rocks.

#### Fire Giant Characters

Most groups of fire giants include clerics. A fire giant cleric has access to two of the following domains: Evil, Law, Trickery, or War (most choose Trickery or War, some choose both).','{"full_attack":"Greatsword +20/+15/+10 melee (3d6+15) or 2 slams +20 melee (1d4+10) or rock +10 ranged (2d6+10 plus 2d6 fire)","environment":"Warm mountains","organization":"Solitary, gang (2–5), band (6–9 plus 35% noncombatants plus 1 adept or cleric of 1st or 2nd level), hunting/raiding party (6–9 plus 1 adept or sorcerer of 3rd–5th level plus 2–4 hell hounds and 2–3 trolls or ettins), or tribe (21–30 plus 1 adept, cleric, or sorcerer of 6th or 7th level plus 12–30 hell hounds, 12–22 trolls, 5–12 ettins, and 1–2 young red dragons)","treasure":"Standard","advancement":"By character class","level_adjustment":"+4","statblock":{"hit_dice":"15d8+75 (142 hp)","hit_points":142,"base_attack_grapple":"+11/+25","attack":"Greatsword +20 melee (3d6+15) or slam +20 melee (1d4+10) or rock +10 ranged (2d6+10 plus 2d6 fire)","full_attack":"Greatsword +20/+15/+10 melee (3d6+15) or 2 slams +20 melee (1d4+10) or rock +10 ranged (2d6+10 plus 2d6 fire)","space_reach":"10 ft./10 ft.","saves":"Fort +14, Ref +4, Will +9","abilities":{"str":"31","dex":"9","con":"21","int":"10","wis":"14","cha":"11"},"skills":"Climb +9, Craft (any one) +6, Intimidate +6, Jump +9, Spot +14","feats":"Cleave, Great Cleave, Improved Overrun, Improved Sunder, Iron Will, Power Attack","special_attacks":"Rock throwing","special_qualities":"Immunity to fire, low-light vision, rock catching, vulnerability to cold"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('frost_giant','Frost Giant','Frost Giant','9','Large','Giant (Cold)','Often chaotic evil','14d8+70 (133 hp)',133,'–1','40 ft. (8 squares)','21 (–1 size, –1 Dex, +9 natural, +4 chain shirt) touch 8, flat-footed 21','+10/+23','Greataxe +18 melee (3d6+13/x3) or slam +18 melee (1d4+9) or rock +9 ranged (2d6+9)','10 ft./10 ft.','+14','+3','+6',29,9,21,10,14,11,'Climb +13, Craft (any one) +6, Intimidate +6, Jump +17, Spot +12','Cleave, Great Cleave, Improved Overrun, Improved Sunder, Power Attack','{"special_attacks":"Rock throwing","special_qualities":"Immunity to cold, low-light vision, rock catching, vulnerability to fire"}'::jsonb,'A frost giant’s hair can be light blue or dirty yellow, and its eyes usually match its hair color. Frost giants dress in skins and pelts, along with any jewelry they own. Frost giant warriors add chain shirts and metal helmets decorated with horns or feathers.

An adult male is about 15 feet tall and weighs about 2,800 pounds. Females are slightly shorter and lighter, but otherwise identical with males. Frost giants can live to be 250 years old.

#### Combat

Frost giants usually start combat at a distance, throwing rocks until they run out of ammunition or the opponent closes, then wading in with their enormous battleaxes.

A favorite tactic is to lay an ambush by hiding buried in the snow at the top of an icy or snowy slope, where opponents will have difficulty reaching them.

**Rock Throwing (Ex):** The range increment is 120 feet for a frost giant’s thrown rocks.','{"full_attack":"Huge greataxe +18/+13 melee (3d6+13/x3) or 2 slams +18 melee (1d4+9) or rock +9 ranged (2d6+9)","environment":"Cold mountains","organization":"Solitary, gang (2–5), band (6–9 plus 35% noncombatants plus 1 adept or cleric of 1st or 2nd level), hunting/raiding party (6–9 plus 35% noncombatants plus 1 adept or sorcerer of 3rd–5th level plus 2–4 winter wolves and 2–3 ogres), or tribe (21–30 plus 1 adept, cleric, or sorcerer of 6th or 7th level plus 12–30 winter wolves, 12–22 ogres, and 1–2 young white dragons)","treasure":"Standard","advancement":"By character class","level_adjustment":"+4","statblock":{"hit_dice":"14d8+70 (133 hp)","hit_points":133,"base_attack_grapple":"+10/+23","attack":"Greataxe +18 melee (3d6+13/x3) or slam +18 melee (1d4+9) or rock +9 ranged (2d6+9)","full_attack":"Huge greataxe +18/+13 melee (3d6+13/x3) or 2 slams +18 melee (1d4+9) or rock +9 ranged (2d6+9)","space_reach":"10 ft./10 ft.","saves":"Fort +14, Ref +3, Will +6","abilities":{"str":"29","dex":"9","con":"21","int":"10","wis":"14","cha":"11"},"skills":"Climb +13, Craft (any one) +6, Intimidate +6, Jump +17, Spot +12","feats":"Cleave, Great Cleave, Improved Overrun, Improved Sunder, Power Attack","special_attacks":"Rock throwing","special_qualities":"Immunity to cold, low-light vision, rock catching, vulnerability to fire"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('frost_giant_jarl_8th_level_blackguard','Frost Giant Jarl, 8th-Level Blackguard','Frost Giant Jarl, 8th-Level Blackguard','17','Large','Giant (Cold)','Always chaotic evil','14d8+84 plus 8d10+48 (231 hp)',231,'+5','30 ft. in +2 full plate armor (6 squares); base speed 40 ft.','29 (–1 size, +1 Dex, +9 natural, +10 +2 full plate armor) touch 10, flat-footed 28','+18/+33','+2 frost greataxe +30 melee (3d6+18/×3 plus 1d6 cold) or slam +28 melee (1d4+11) or rock +18 ranged (2d6+11)','10 ft./10 ft.','+25','+13','+13',32,12,22,10,12,18,'Climb +17, Hide +2, Jump +17, Knowledge (religion) +2, Ride +11, Spot +5','Cleave, Great Cleave, Improved Initiative, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack, Quick Draw','{"special_attacks":"Rock throwing, smite good, sneak attack +2d6","special_qualities":"Aura of despair, aura of evil, command undead, dark blessing, detect good, immunity to cold, low-light vision, poison use, resistance to fire 10, rock catching, vulnerability to fire"}'::jsonb,'A frost giant’s hair can be light blue or dirty yellow, and its eyes usually match its hair color. Frost giants dress in skins and pelts, along with any jewelry they own. Frost giant warriors add chain shirts and metal helmets decorated with horns or feathers.

An adult male is about 15 feet tall and weighs about 2,800 pounds. Females are slightly shorter and lighter, but otherwise identical with males. Frost giants can live to be 250 years old.

#### Combat

Frost giants usually start combat at a distance, throwing rocks until they run out of ammunition or the opponent closes, then wading in with their enormous battleaxes.

A favorite tactic is to lay an ambush by hiding buried in the snow at the top of an icy or snowy slope, where opponents will have difficulty reaching them.

**Rock Throwing (Ex):** The range increment is 120 feet for a frost giant’s thrown rocks.','{"full_attack":"+2 frost greataxe +30/+25/+20/+15 melee (3d6+18/×3 plus 1d6 cold) or 2 slams +28 melee (1d4+11) or rock +18 ranged (2d6+11)","environment":"Cold mountains","organization":"Solitary or with tribe","treasure":"Standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"14d8+84 plus 8d10+48 (231 hp)","hit_points":231,"base_attack_grapple":"+18/+33","attack":"+2 frost greataxe +30 melee (3d6+18/×3 plus 1d6 cold) or slam +28 melee (1d4+11) or rock +18 ranged (2d6+11)","full_attack":"+2 frost greataxe +30/+25/+20/+15 melee (3d6+18/×3 plus 1d6 cold) or 2 slams +28 melee (1d4+11) or rock +18 ranged (2d6+11)","space_reach":"10 ft./10 ft.","saves":"Fort +25, Ref +13, Will +13","abilities":{"str":"32","dex":"12","con":"22","int":"10","wis":"12","cha":"18"},"skills":"Climb +17, Hide +2, Jump +17, Knowledge (religion) +2, Ride +11, Spot +5","feats":"Cleave, Great Cleave, Improved Initiative, Improved Sunder, Iron Will, Lightning Reflexes, Power Attack, Quick Draw","special_attacks":"Rock throwing, smite good, sneak attack +2d6","special_qualities":"Aura of despair, aura of evil, command undead, dark blessing, detect good, immunity to cold, low-light vision, poison use, resistance to fire 10, rock catching, vulnerability to fire"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('hill_giant','Hill Giant','Hill Giant','7','Large','Giant','Often chaotic evil','12d8+48 (102 hp)',102,'–1','30 ft. in hide armor (6 squares); base speed 40 ft.','20 (–1 size, –1 Dex, +9 natural, +3 hide armor), touch 8, flat-footed 20','+9/+20','Greatclub +16 melee (2d8+10) or slam +15 melee (1d4+7) or rock +8 ranged (2d6+7)','10 ft./10 ft.','+12','+3','+4',25,8,19,6,10,7,'Climb +7, Jump +7, Listen +3, Spot +6','Cleave, Improved Bull Rush, Power Attack, Improved Sunder, Weapon Focus (greatclub)','{"special_attacks":"Rock throwing","special_qualities":"Low-light vision, rock catching"}'::jsonb,'Skin color among hill giants ranges from light tan to deep ruddy brown. Their hair is brown or black, with eyes the same color. Hill giants wear layers of crudely prepared hides with the fur left on. They seldom wash or repair their garments, preferring to simply add more hides as their old ones wear out.

Adults are about 10-1/2 feet tall and weigh about 1,100 pounds. Hill giants can live to be 200 years old.

#### Combat

Hill giants prefer to fight from high, rocky outcroppings, where they can pelt opponents with rocks and boulders while limiting the risk to themselves.

Hill giants love to make overrun attacks against smaller creatures when they first join battle. Thereafter, they stand fast and swing away with their massive clubs.

**Rock Throwing (Ex):** The range increment is 120 feet for a hill giant’s thrown rocks.','{"full_attack":"Greatclub +16/+11 melee (2d8+10) or 2 slams +15 melee (1d4+7) or rock +8 ranged (2d6+7)","environment":"Temperate hills","organization":"Solitary, gang (2–5), band (6–9 plus 35% noncombatants), hunting/raiding party (6–9 plus 2–4 dire wolves), or tribe (21–30 plus 35% noncombatants plus 12–30 dire wolves, 2–4 ogres, and 12–22 orcs)","treasure":"Standard","advancement":"By character class","level_adjustment":"+4","statblock":{"hit_dice":"12d8+48 (102 hp)","hit_points":102,"base_attack_grapple":"+9/+20","attack":"Greatclub +16 melee (2d8+10) or slam +15 melee (1d4+7) or rock +8 ranged (2d6+7)","full_attack":"Greatclub +16/+11 melee (2d8+10) or 2 slams +15 melee (1d4+7) or rock +8 ranged (2d6+7)","space_reach":"10 ft./10 ft.","saves":"Fort +12, Ref +3, Will +4","abilities":{"str":"25","dex":"8","con":"19","int":"6","wis":"10","cha":"7"},"skills":"Climb +7, Jump +7, Listen +3, Spot +6","feats":"Cleave, Improved Bull Rush, Power Attack, Improved Sunder, Weapon Focus (greatclub)","special_attacks":"Rock throwing","special_qualities":"Low-light vision, rock catching"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('stone_giant','Stone Giant','Stone Giant','8 (elder 9)','Large','Giant (Earth)','Usually neutral','14d8+56 (119 hp)',119,'+2','30 ft. in hide armor (6 squares); base speed 40 ft.','25 (–1 size, +2 Dex, +11 natural, +3 hide), touch 11, flat-footed 23','+10/+22','Greatclub +17 melee (2d8+12) or slam +17 melee (1d4+8) or rock +11 ranged (2d8+12)','10 ft./10 ft.','+13','+6','+7',27,15,19,10,12,11,'Climb +11, Hide +6*, Jump +11, Spot +12','Combat Reflexes, Iron Will, Point Blank Shot, Power Attack, Precise Shot','{"special_attacks":"Rock throwing","special_qualities":"Darkvision 60 ft., low-light vision, rock catching"}'::jsonb,'Stone giants prefer thick leather garments, dyed in shades of brown and gray to match the stone around them. Adults are about 12 feet tall and weigh about 1,500 pounds. Stone giants can live to be 800 years old.

#### Combat

Stone giants fight from a distance whenever possible, but if they can’t avoid melee, they use gigantic clubs chiseled out of stone. A favorite tactic of stone giants is to stand nearly motionless, blending in with the background, then move forward to throw rocks and surprise their foes.

**Rock Throwing (Ex):** The range increment is 180 feet for a stone giant’s thrown rocks. It uses both hands when throwing a rock.

**Rock Catching (Ex):** A stone giant gains a +4 racial bonus on its Reflex save when attempting to catch a thrown rock.

**Skills:** \*A stone giant gains a +8 racial bonus on Hide checks in rocky terrain.','{"full_attack":"Greatclub +17/+12 melee (2d8+12) or 2 slams +17 melee (1d4+8) or rock +11 ranged (2d8+12)","environment":"Temperate mountains","organization":"Solitary, gang (2–5), band (6–9 plus 35% noncombatants), hunting/raiding/trading party (6–9 plus 1 elder), or tribe (21–30 plus 35% noncombatants plus 1–3 elders and 3–6 dire bears)","treasure":"Standard","advancement":"By character class","level_adjustment":"+4 (elder +6)","statblock":{"hit_dice":"14d8+56 (119 hp)","hit_points":119,"base_attack_grapple":"+10/+22","attack":"Greatclub +17 melee (2d8+12) or slam +17 melee (1d4+8) or rock +11 ranged (2d8+12)","full_attack":"Greatclub +17/+12 melee (2d8+12) or 2 slams +17 melee (1d4+8) or rock +11 ranged (2d8+12)","space_reach":"10 ft./10 ft.","saves":"Fort +13, Ref +6, Will +7","abilities":{"str":"27","dex":"15","con":"19","int":"10","wis":"12","cha":"11"},"skills":"Climb +11, Hide +6*, Jump +11, Spot +12","feats":"Combat Reflexes, Iron Will, Point Blank Shot, Power Attack, Precise Shot","special_attacks":"Rock throwing","special_qualities":"Darkvision 60 ft., low-light vision, rock catching"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('storm_giant','Storm Giant','Storm Giant','13','Huge','Giant','Often chaotic good','19d8+114 (199 hp)',199,'+2','35 ft. (7 squares), swim 30 ft. (6 squares) in breastplate; base speed 50 ft., swim 40 ft.','27 (–2 size, +2 Dex, +12 natural, +5 breastplate) touch 10, flat-footed 25','+14/+36','Greatsword +26 melee (4d6+21/19–20) or slam +26 melee (1d6+14) or composite longbow (+14 Str bonus) +14 ranged (3d6+14/x3)','15 ft./15 ft.','+17','+8','+13',39,14,23,16,20,15,'Climb +20, Concentration +26, Craft (any one) +13, Diplomacy +4, Intimidate +12, Jump +24, Listen +15, Perform (sing) +12, Sense Motive +15, Spot +25, Swim +18*','Awesome Blow, Cleave, Combat Reflexes, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack','{"special_attacks":"Spell-like abilities","special_qualities":"Freedom of movement, immunity to electricity, low-light vision, rock catching, water breathing"}'::jsonb,'Very rarely, storm giants have violet skin. Violet-skinned storm giants have deep violet or blue-black hair with silvery gray or purple eyes. Adults are about 21 feet tall and weigh about 12,000 pounds. Storm giants can live to be 600 years old. Storm giants’ garb is usually a short, loose tunic belted at the waist, sandals or bare feet, and a headband. They wear a few pieces of simple but finely crafted jewelry, anklets (favored by barefoot giants), rings, or circlets being most common. They live quiet, reflective lives and spend their time musing about the world, composing and playing music, and tilling their land or gathering food.

#### Combat

Storm giants use weapons and spell-like abilities instead of throwing rocks. Their composite longbows have a range increment of 180 feet.

**Spell-Like Abilities:** 1/day—_call lightning_ (DC 15), _chain lightning_ (DC 18). Caster level 15th. 2/day—_control weather_, _levitate._ Caster level 20th. The save DCs are Charisma-based.

**Freedom of Movement (Su):** Storm giants have a continuous freedom of movement ability as the spell (caster level 20th). The effect can be dispelled, but the storm giant can create it again on its next turn as a free action.

**Water Breathing (Ex):** Storm giants can breathe underwater indefinitely and can freely use their spell-like abilities while submerged.

**Skills:** A storm giant has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line. \*Storm giants ignore all weight penalties for gear carried when swimming.

#### Storm Giant Characters

About 20% of adult storm giants are sorcerers or clerics. A storm giant cleric has access to two of the following domains: Chaos, Good, Protection, or War.','{"full_attack":"Greatsword +26/+21/+16 melee (4d6+21/19–20) or 2 slams +26 melee (1d6+14) or composite longbow (+14 Str bonus) +14/+9/+4 ranged (3d6+14/x3)","environment":"Warm mountains","organization":"Solitary or family (2–4 plus 35% noncombatants plus 1 sorcerer or cleric of 7th–10th level plus 1–2 rocs, 2–5 griffons, or 2–8 sea cats)","treasure":"Standard coins; double goods; standard items","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"19d8+114 (199 hp)","hit_points":199,"base_attack_grapple":"+14/+36","attack":"Greatsword +26 melee (4d6+21/19–20) or slam +26 melee (1d6+14) or composite longbow (+14 Str bonus) +14 ranged (3d6+14/x3)","full_attack":"Greatsword +26/+21/+16 melee (4d6+21/19–20) or 2 slams +26 melee (1d6+14) or composite longbow (+14 Str bonus) +14/+9/+4 ranged (3d6+14/x3)","space_reach":"15 ft./15 ft.","saves":"Fort +17, Ref +8, Will +13","abilities":{"str":"39","dex":"14","con":"23","int":"16","wis":"20","cha":"15"},"skills":"Climb +20, Concentration +26, Craft (any one) +13, Diplomacy +4, Intimidate +12, Jump +24, Listen +15, Perform (sing) +12, Sense Motive +15, Spot +25, Swim +18*","feats":"Awesome Blow, Cleave, Combat Reflexes, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack","special_attacks":"Spell-like abilities","special_qualities":"Freedom of movement, immunity to electricity, low-light vision, rock catching, water breathing"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('gibbering_mouther','Gibbering Mouther','Gibbering Mouther','5','Medium','Aberration','Usually neutral','4d8+24 (42 hp)',42,'+1','10 ft. (2 squares), swim 20 ft.','19 (+1 Dex, +8 natural), touch 11, flat-footed 18','+3/+3','Bite +4 melee (1) or spittle +4 ranged touch (1d4 acid plus blindness)','5 ft./5 ft.','+7','+4','+5',10,13,22,4,13,13,'Listen +4, Spot +9, Swim +8','Lightning Reflexes, Weapon Finesse','{"special_attacks":"Gibbering, spittle, improved grab, blood drain, engulf, ground manipulation","special_qualities":"Amorphous, damage reduction 5/bludgeoning, darkvision 60 ft."}'::jsonb,'A gibbering mouther is a horrible creature seemingly drawn from a lunatic’s nightmares. Although not evil, it thirsts after bodily fluids and seems to prefer the blood of intelligent creatures.

A gibbering mouther is about 3 feet across and 3 to 4 feet high. It weighs about 200 pounds.

Gibbering mouthers can speak Common, but seldom say anything other than gibberish.

### Combat

A gibbering mouther attacks by shooting out strings of protoplasmic flesh, each ending in one or more eyes and a mouth that bites at the enemy. A mouther can send out a total of six such members in any round.

**Gibbering (Su):** As soon as a mouther spots something edible, it begins a constant gibbering as a free action. All creatures (other than mouthers) within a 60-foot spread must succeed on a DC 13 Will save or be affected as though by a _confusion_ spell for 1d2 rounds. This is a sonic mind-affecting compulsion effect. A creature that successfully saves cannot be affected by the same gibbering mouther’s gibbering for 24 hours. The save DC is Charisma-based.

**Spittle (Ex):** As a free action every round, a gibbering mouther fires a stream of spittle at one opponent within 30 feet. The mouther makes a ranged touch attack; if it hits, it deals 1d4 points of acid damage, and the target must succeed on a DC 18 Fortitude save or be blinded for 1d4 rounds. Eyeless creatures are immune to the blinding effect, but are still subject to the acid damage. The save DC is Constitution-based.

**Improved Grab (Ex):** To use this ability, a gibbering mouther must hit with a bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Blood Drain (Ex):** On a successful grapple check after grabbing, that mouth attaches to the opponent. It automatically deals bite damage and drains blood, dealing 1 point of Constitution damage each round. A mouth can be ripped off (dealing 1 point of damage) with a DC 12 Strength check or severed by a successful sunder attempt (the mouth has 2 hit points).

A severed mouth continues to bite and drain blood for 1d4 rounds after such an attack. A creature whose Constitution is reduced to 0 is killed.

**Engulf (Ex):** A gibbering mouther can try to engulf a Medium or smaller opponent grabbed by three or more mouths.

The opponent must succeed on a DC 14 Reflex save or fall and be engulfed. In the next round, the mouther makes twelve bite attacks instead of six (each with a +4 attack bonus). An engulfed creature cannot attack the mouther from within. The previously attached mouths are now free to attack others. The save DC is Strength-based and includes a +2 racial bonus.

**Ground Manipulation (Su):** At will, as a standard action, a gibbering mouther can cause stone and earth in all adjacent squares to become a morass akin to quicksand. Softening earth, sand, or the like takes 1 round, while stone takes 2 rounds. Anyone other than the mouther in that area must take a move-equivalent action to avoid becoming mired (treat as being pinned).

**Amorphous (Ex):** A gibbering mouther is not subject to critical hits. It cannot be flanked.

**Skills:** Thanks to their multiple eyes, gibbering mouthers have a +4 racial bonus on Spot checks.

A gibbering mouther has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It always can choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"6 bites +4 melee (1) and spittle +4 ranged touch (1d4 acid plus blindness)","environment":"Underground","organization":"Solitary","treasure":"None","advancement":"5–12 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"4d8+24 (42 hp)","hit_points":42,"base_attack_grapple":"+3/+3","attack":"Bite +4 melee (1) or spittle +4 ranged touch (1d4 acid plus blindness)","full_attack":"6 bites +4 melee (1) and spittle +4 ranged touch (1d4 acid plus blindness)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +4, Will +5","abilities":{"str":"10","dex":"13","con":"22","int":"4","wis":"13","cha":"13"},"skills":"Listen +4, Spot +9, Swim +8","feats":"Lightning Reflexes, Weapon Finesse","special_attacks":"Gibbering, spittle, improved grab, blood drain, engulf, ground manipulation","special_qualities":"Amorphous, damage reduction 5/bludgeoning, darkvision 60 ft."},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('girallon','Girallon','Girallon','6','Large','Magical Beast','Always neutral','7d10+20 (58 hp)',58,'+3','40 ft. (8 squares), climb 40 ft.','16 (–1 size, +3 Dex, +4 natural), touch 12, flat-footed 15','+7/+17','Claw +12 melee (1d4+6)','10 ft./10 ft.','+7','+8','+5',22,17,14,2,12,7,'Climb +14, Move Silently +8, Spot +6','Iron Will, Toughness (2)','{"special_attacks":"Rend 2d4+9","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'Girallons are savage, magical cousins of the gorilla. When moving on the ground, a girallon walks on its legs and lower arms. An adult girallon is about 8 feet tall, broad-chested, and covered in thick, pure white fur. It weighs about 800 pounds.

### Combat

A solitary girallon usually conceals itself in the branches of a tree or under a pile of leaves and brush, with only its nose showing. When it spots or scents prey, it charges to the attack. A girallon picks up prey that is small enough to carry and withdraws, often vanishing into the trees before the victim’s companions can do anything to retaliate. Against larger foes, a girallon seeks to tear a single opponent to bits as quickly as it can.

**Rend (Ex):** A girallon that hits with two or more claw attacks latches onto the opponent’s body and tears the flesh. This attack automatically deals an extra 2d4+12 points of damage.

**Skills:** A girallon has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"4 claws +12 melee (1d4+6) and bite +7 melee (1d8+3)","environment":"Warm forests","organization":"Solitary or company (5–8)","treasure":"None","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d10+20 (58 hp)","hit_points":58,"base_attack_grapple":"+7/+17","attack":"Claw +12 melee (1d4+6)","full_attack":"4 claws +12 melee (1d4+6) and bite +7 melee (1d8+3)","space_reach":"10 ft./10 ft.","saves":"Fort +7, Ref +8, Will +5","abilities":{"str":"22","dex":"17","con":"14","int":"2","wis":"12","cha":"7"},"skills":"Climb +14, Move Silently +8, Spot +6","feats":"Iron Will, Toughness (2)","special_attacks":"Rend 2d4+9","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('gnoll','Gnoll','Gnoll','1','Medium','Humanoid (Gnoll)','Usually chaotic evil','2d8+2 (11 hp)',11,'+0','30 ft. (6 squares)','15 (+1 natural, +2 leather armor, +2 heavy steel shield), touch 10, flat-footed 15','+1/+3','Battleaxe +3 melee (1d8+2/x3) or shortbow +1 ranged (1d6/x3)','5 ft./5 ft.','+4','+0','+0',15,10,13,8,11,8,'Listen +2, Spot +3','Power Attack','{"special_attacks":"—","special_qualities":"Darkvision 60 ft."}'::jsonb,'Gnolls are hyena-headed, evil humanoids that wander in loose tribes. Most gnolls have dirty yellow or reddish-brown fur. A gnoll is a nocturnal carnivore, preferring intelligent creatures for food because they scream more. A gnoll is about 7-1/2 feet tall and weighs 300 pounds. Gnolls speak Gnoll.

### Combat

Gnolls like to attack when they have the advantage of numbers, using horde tactics and their physical strength to overwhelm and knock down their opponents. They show little discipline when fighting unless they have a strong leader; at such times, they can maintain ranks and fight as a unit. While they do not usually prepare traps, they do use ambushes and try to attack from a flanking position. Because of its shield, a gnoll’s modifier on Hide checks (untrained) is –2, which means gnolls always take special care to seek favorable conditions when laying ambushes (such as darkness, cover, or some other form of advantageous terrain).

### Gnolls as Characters

Gnoll characters possess the following racial traits.

—Strength +4, Constitution +2, Intelligence –2, Charisma –2.

—Size Medium.

—A gnoll’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: A gnoll begins with two levels of humanoid, which provide 2d8 Hit Dice, a base attack bonus of +1, and base saving throw bonuses of Fort +3, Ref +0, and Will +0.

—Racial Skills: A gnoll’s humanoid levels give it skill points equal to 5 x (2 + Int modifier). Its class skills are Listen and Spot.

—Racial Feats: A gnoll’s humanoid levels give it one feat.

— +1 natural armor bonus.

—Automatic Languages: Gnoll. Bonus Languages: Common, Draconic, Elven, Goblin, Orc.

—Favored Class: Ranger.

—Level adjustment +1.','{"full_attack":"Battleaxe +3 melee (1d8+2/x3) or shortbow +1 ranged (1d6/x3)","environment":"Warm plains","organization":"Solitary, pair, hunting party (2–5 and 1–2 hyenas), band (10–100 plus 50% noncombatants plus 1 3rd-level sergeant per 20 adults and 1 leader of 4th–6th level and 5–8 hyenas), or tribe (20–200 plus 1 3rd-level sergeant per 20 adults, 1 or 2 lieutenants of 4th or 5th level, 1 leader of 6th–8th level, and 7–12 hyenas; underground lairs also have 1–3 trolls)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/+3","attack":"Battleaxe +3 melee (1d8+2/x3) or shortbow +1 ranged (1d6/x3)","full_attack":"Battleaxe +3 melee (1d8+2/x3) or shortbow +1 ranged (1d6/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +0, Will +0","abilities":{"str":"15","dex":"10","con":"13","int":"8","wis":"11","cha":"8"},"skills":"Listen +2, Spot +3","feats":"Power Attack","special_attacks":"—","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('gnome_1st_level_warrior','Gnome, 1st-Level Warrior','Gnome, 1st-Level Warrior','1/2','Small','Humanoid (Gnome)','Usually neutral good','1d8+2 (6 hp)',6,'+0','20 ft. (4 squares)','16 (+1 size, +4 chain shirt, +1 light shield), touch 11, flat-footed 16','+1/–3','Longsword +2 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)','5 ft./5 ft.','+4','+0','–1',11,11,14,10,9,8,'Hide +3, Listen +1, Spot +1','Weapon Focus (light crossbow)','{"special_attacks":"—","special_qualities":"Gnome traits"}'::jsonb,'Gnomes stand 3 to 3-1/2 feet tall and weigh 40 to 45 pounds. Their skin color ranges from dark tan to woody brown, their hair is fair, and their eyes can be any shade of blue. Gnome males prefer short, carefully trimmed beards. Gnomes generally wear leather or earth tones, though they decorate their clothes with intricate stitching or fine jewelry. Gnomes reach adulthood at about age 40, and they live about 350 years, though some can live almost 500 years.

Gnomes speak their own language, Gnome. Most gnomes who travel outside gnome lands (as traders, tinkers, or adventurers) know Common, while warriors in gnome settlements usually learn Goblin.

Most gnomes encountered outside their home are warriors; the information in the statistics block is for one of 1st level.

### Combat

Gnomes prefer misdirection and deception over direct confrontation.

They would rather befuddle or embarrass foes (other than goblinoids or kobolds) than kill them.

Gnomes make heavy use of illusion magic and carefully prepared ambushes and traps whenever they can.

**Gnome Traits (Ex):** Gnomes possess the following racial traits.

— +2 Constitution, –2 Strength.

—Small size. +1 bonus to Armor Class, +1 bonus on attack rolls, +4 bonus on Hide checks, –4 penalty on grapple checks, lifting and carrying limits 3/4 those of Medium characters.

—A gnome’s base land speed is 20 feet.

—Low-light vision.

—Weapon Familiarity: Gnomes may treat gnome hooked hammers as martial weapons rather than exotic weapons.

— +2 racial bonus on saving throws against illusions.

—Add +1 to the Difficulty Class for all saving throws against illusion spells cast by gnomes. This adjustment stacks with those from similar effects, such as the Spell Focus feat.

— +1 racial bonus on attack rolls against kobolds and goblinoids (including goblins, hobgoblins, and bugbears).

— +4 dodge bonus to Armor Class against creatures of the giant type (such as ogres, trolls, and hill giants).

— +2 racial bonus on Listen checks.

— +2 racial bonus on Craft (alchemy) checks.

—Automatic Languages: Common, Gnome. Bonus Languages: Draconic, Dwarven, Elven, Giant, Goblin, Orc.

—Spell-Like Abilities: 1/day—_speak with animals_ (burrowing mammal only, duration 1 minute). A gnome with a Charisma score of at least 10 also has the following spell-like abilities: 1/day—_dancing lights, ghost sound, prestidigitation._ Caster level 1st; save DC 10 + gnome’s Cha modifier + spell level.

—Favored Class: Bard.

The gnome warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The information above is for rock gnomes, the most common variety.

There are two other major gnome subraces, which differ from rock gnomes as follows.

#### Svirfneblin

Also called deep gnomes, svirfneblin are said to dwell in great cities deep underground.

A svirfneblin has wiry, rock-colored skin usually medium brown to brownish gray. Only males are bald; females have stringy gray hair. The average svirfneblin lifespan is 250 years.

Svirfneblin speak Gnome, Common, and Undercommon.

**Svirfneblin Traits (Ex):** These traits are in addition to the rock gnome traits, except where noted.

— –2 Strength, +2 Dexterity, +2 Wisdom, –4 Charisma. These adjustments replace the rock gnome’s ability score adjustments.

—Stonecunning: This ability grants deep gnomes a +2 racial bonus on Search checks to notice unusual stonework. A deep gnome who merely comes within 10 feet of unusual stonework can make a Search check as though actively searching, and can use the Search skill to find stonework traps as a rogue can. A svirfneblin can also intuit depth, sensing the approximate distance underground as naturally as a human can sense which way is up.

—Darkvision out to 120 feet and low-light vision.

—Spell resistance equal to 11 + class levels.

— +2 racial bonus on all saving throws (figured into the statistics for the character presented here). This trait replaces the rock gnome’s racial bonus on saving throws against illusions.

—Add +1 to the Difficulty Class for all saving throws against illusion spells cast by svirfneblin. This adjustment stacks with those from similar effects, such as the Spell Focus feat.

— +1 racial bonus on attack rolls against kobolds and goblinoids.

— +4 dodge bonus to Armor Class against all creatures (figured into the statistics for the character presented here). This trait replaces the rock gnome’s dodge bonus against giants.

—Automatic Languages: Undercommon, Gnome, Common. Bonus Languages: Dwarven, Elven, Giant, Goblin, Orc, Terran. This trait replaces the rock gnome’s automatic and bonus languages.

—Spell-Like Abilities: 1/day—_blindness/deafness_ (typical save DC 13), _blur, disguise self_. Caster level equals the svirfneblin’s class levels. The save DC is Charisma-based and include a +4 racial modifier. This trait replaces the rock gnome’s spell-like abilities.

—Nondetection (Su): A svirfneblin has a continuous nondetection ability as the spell (caster level equal to class levels).

— +2 racial bonus on Craft (alchemy) and Listen checks.

— +2 racial bonus on Hide checks, which improves to +4 underground.

—Favored Class: Rogue.

—Level adjustment +3.

The svirfneblin warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

Challenge Rating: Svirfneblin with levels in NPC classes have a CR equal to their character level. Svirfneblin with levels in PC classes have a CR equal to their character level +1.

#### Forest Gnome

They are the smallest of all the gnomes, averaging 2 to 2-1/2 feet in height, but look just like regular gnomes except with bark-colored or gray-green skin, and eyes that can be brown or green as well as blue. A very long-lived people, forest gnomes have an average life expectancy of 500 years.

**Forest Gnome Traits (Ex):** These traits are in addition to the rock gnome traits, except where noted.

—_Pass without Trace_ (Su): A forest gnome has the innate ability to use _pass without trace_ (self only, as a free action) as the spell cast by a druid of the forest gnome’s class levels.

— +1 racial bonus on attack rolls against kobolds, goblinoids, orcs, and reptilian humanoids.

—Automatic Languages: Gnome, Elven, Sylvan, and a simple language that enables them to communicate on a very basic level with forest animals (this replaces the rock gnome’s _speak with animals_ ability). Bonus Languages: Common, Draconic, Dwarven, Giant, Goblin, Orc. This trait replaces the rock gnome’s automatic and bonus languages.

— +4 racial bonus on Hide checks, which improves to +8 in a wooded area.','{"full_attack":"Longsword +2 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","environment":"Temperate hills (Forest gnomes: Temperate forests)","organization":"Company (2–4), squad (11–20 plus 1 leader of 3rd–6th level and 2 3rd-level lieutenants), or band (30–50 plus 1 3rd-level sergeant per 20 adults, 5 5th-level lieutenants, 3 7th-level captains, and 2–5 dire badgers)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8+2 (6 hp)","hit_points":6,"base_attack_grapple":"+1/–3","attack":"Longsword +2 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","full_attack":"Longsword +2 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +0, Will –1","abilities":{"str":"11","dex":"11","con":"14","int":"10","wis":"9","cha":"8"},"skills":"Hide +3, Listen +1, Spot +1","feats":"Weapon Focus (light crossbow)","special_attacks":"—","special_qualities":"Gnome traits"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('svirfneblin_1st_level_warrior','Svirfneblin, 1st-Level Warrior','Svirfneblin, 1st-Level Warrior','1','Small','Humanoid (Gnome)','Usually neutral','1d8+4 (8 hp)',8,'+1','15 ft. in banded mail armor (3 squares); base speed 20 ft.','23 (+1 size, +1 Dex, +4 dodge, +6 banded mail, +1 buckler), touch 16, flat-footed 18','+1/–3','Heavy pick +2 melee (1d4/x4) or light crossbow +3 ranged (1d6/19–20)','5 ft./5 ft.','+5','+3','+2',11,13,12,10,11,4,'Hide +2, Listen +2, Spot +2','Toughness','{"special_attacks":"Spell-like abilities","special_qualities":"Gnome traits, svirfneblin traits, spell resistance 12"}'::jsonb,'Gnomes stand 3 to 3-1/2 feet tall and weigh 40 to 45 pounds. Their skin color ranges from dark tan to woody brown, their hair is fair, and their eyes can be any shade of blue. Gnome males prefer short, carefully trimmed beards. Gnomes generally wear leather or earth tones, though they decorate their clothes with intricate stitching or fine jewelry. Gnomes reach adulthood at about age 40, and they live about 350 years, though some can live almost 500 years.

Gnomes speak their own language, Gnome. Most gnomes who travel outside gnome lands (as traders, tinkers, or adventurers) know Common, while warriors in gnome settlements usually learn Goblin.

Most gnomes encountered outside their home are warriors; the information in the statistics block is for one of 1st level.

### Combat

Gnomes prefer misdirection and deception over direct confrontation.

They would rather befuddle or embarrass foes (other than goblinoids or kobolds) than kill them.

Gnomes make heavy use of illusion magic and carefully prepared ambushes and traps whenever they can.

**Gnome Traits (Ex):** Gnomes possess the following racial traits.

— +2 Constitution, –2 Strength.

—Small size. +1 bonus to Armor Class, +1 bonus on attack rolls, +4 bonus on Hide checks, –4 penalty on grapple checks, lifting and carrying limits 3/4 those of Medium characters.

—A gnome’s base land speed is 20 feet.

—Low-light vision.

—Weapon Familiarity: Gnomes may treat gnome hooked hammers as martial weapons rather than exotic weapons.

— +2 racial bonus on saving throws against illusions.

—Add +1 to the Difficulty Class for all saving throws against illusion spells cast by gnomes. This adjustment stacks with those from similar effects, such as the Spell Focus feat.

— +1 racial bonus on attack rolls against kobolds and goblinoids (including goblins, hobgoblins, and bugbears).

— +4 dodge bonus to Armor Class against creatures of the giant type (such as ogres, trolls, and hill giants).

— +2 racial bonus on Listen checks.

— +2 racial bonus on Craft (alchemy) checks.

—Automatic Languages: Common, Gnome. Bonus Languages: Draconic, Dwarven, Elven, Giant, Goblin, Orc.

—Spell-Like Abilities: 1/day—_speak with animals_ (burrowing mammal only, duration 1 minute). A gnome with a Charisma score of at least 10 also has the following spell-like abilities: 1/day—_dancing lights, ghost sound, prestidigitation._ Caster level 1st; save DC 10 + gnome’s Cha modifier + spell level.

—Favored Class: Bard.

The gnome warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The information above is for rock gnomes, the most common variety.

There are two other major gnome subraces, which differ from rock gnomes as follows.

#### Svirfneblin

Also called deep gnomes, svirfneblin are said to dwell in great cities deep underground.

A svirfneblin has wiry, rock-colored skin usually medium brown to brownish gray. Only males are bald; females have stringy gray hair. The average svirfneblin lifespan is 250 years.

Svirfneblin speak Gnome, Common, and Undercommon.

**Svirfneblin Traits (Ex):** These traits are in addition to the rock gnome traits, except where noted.

— –2 Strength, +2 Dexterity, +2 Wisdom, –4 Charisma. These adjustments replace the rock gnome’s ability score adjustments.

—Stonecunning: This ability grants deep gnomes a +2 racial bonus on Search checks to notice unusual stonework. A deep gnome who merely comes within 10 feet of unusual stonework can make a Search check as though actively searching, and can use the Search skill to find stonework traps as a rogue can. A svirfneblin can also intuit depth, sensing the approximate distance underground as naturally as a human can sense which way is up.

—Darkvision out to 120 feet and low-light vision.

—Spell resistance equal to 11 + class levels.

— +2 racial bonus on all saving throws (figured into the statistics for the character presented here). This trait replaces the rock gnome’s racial bonus on saving throws against illusions.

—Add +1 to the Difficulty Class for all saving throws against illusion spells cast by svirfneblin. This adjustment stacks with those from similar effects, such as the Spell Focus feat.

— +1 racial bonus on attack rolls against kobolds and goblinoids.

— +4 dodge bonus to Armor Class against all creatures (figured into the statistics for the character presented here). This trait replaces the rock gnome’s dodge bonus against giants.

—Automatic Languages: Undercommon, Gnome, Common. Bonus Languages: Dwarven, Elven, Giant, Goblin, Orc, Terran. This trait replaces the rock gnome’s automatic and bonus languages.

—Spell-Like Abilities: 1/day—_blindness/deafness_ (typical save DC 13), _blur, disguise self_. Caster level equals the svirfneblin’s class levels. The save DC is Charisma-based and include a +4 racial modifier. This trait replaces the rock gnome’s spell-like abilities.

—Nondetection (Su): A svirfneblin has a continuous nondetection ability as the spell (caster level equal to class levels).

— +2 racial bonus on Craft (alchemy) and Listen checks.

— +2 racial bonus on Hide checks, which improves to +4 underground.

—Favored Class: Rogue.

—Level adjustment +3.

The svirfneblin warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

Challenge Rating: Svirfneblin with levels in NPC classes have a CR equal to their character level. Svirfneblin with levels in PC classes have a CR equal to their character level +1.

#### Forest Gnome

They are the smallest of all the gnomes, averaging 2 to 2-1/2 feet in height, but look just like regular gnomes except with bark-colored or gray-green skin, and eyes that can be brown or green as well as blue. A very long-lived people, forest gnomes have an average life expectancy of 500 years.

**Forest Gnome Traits (Ex):** These traits are in addition to the rock gnome traits, except where noted.

—_Pass without Trace_ (Su): A forest gnome has the innate ability to use _pass without trace_ (self only, as a free action) as the spell cast by a druid of the forest gnome’s class levels.

— +1 racial bonus on attack rolls against kobolds, goblinoids, orcs, and reptilian humanoids.

—Automatic Languages: Gnome, Elven, Sylvan, and a simple language that enables them to communicate on a very basic level with forest animals (this replaces the rock gnome’s _speak with animals_ ability). Bonus Languages: Common, Draconic, Dwarven, Giant, Goblin, Orc. This trait replaces the rock gnome’s automatic and bonus languages.

— +4 racial bonus on Hide checks, which improves to +8 in a wooded area.','{"full_attack":"Heavy pick +2 melee (1d4/x4) or light crossbow +3 ranged (1d6/19–20)","environment":"Underground","organization":"Company (2–4), squad (11–20 plus 1 leader of 3rd–6th level and 2 3rd-level lieutenants), or band (30–50 plus 1 3rd-level sergeant per 20 adults, 5 5th-level lieutenants, 3 7th-level captains, and 2–5 Medium earth elementals)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+4 (8 hp)","hit_points":8,"base_attack_grapple":"+1/–3","attack":"Heavy pick +2 melee (1d4/x4) or light crossbow +3 ranged (1d6/19–20)","full_attack":"Heavy pick +2 melee (1d4/x4) or light crossbow +3 ranged (1d6/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +3, Will +2","abilities":{"str":"11","dex":"13","con":"12","int":"10","wis":"11","cha":"4"},"skills":"Hide +2, Listen +2, Spot +2","feats":"Toughness","special_attacks":"Spell-like abilities","special_qualities":"Gnome traits, svirfneblin traits, spell resistance 12"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('goblin','Goblin','Goblin, 1st-Level Warrior','1/3','Small','Humanoid (Goblinoid)','Usually neutral evil','1d8+1 (5 hp)',5,'+1','30 ft. (6 squares)','15 (+1 size, +1 Dex, +2 leather armor, +1 light shield), touch 12, flat-footed 14','+1/–3','Morningstar +2 melee (1d6) or javelin +3 ranged (1d4)','5 ft./5 ft.','+3','+1','–1',11,13,12,10,9,6,'Hide +5, Listen +2, Move Silently +5, Ride +4, Spot +2','Alertness','{"special_attacks":"—","special_qualities":"Darkvision 60 ft."}'::jsonb,'A goblin stands 3 to 3-1/2 feet tall and weigh 40 to 45 pounds. Its eyes are usually dull and glazed, varying in color from red to yellow. A goblin’s skin color ranges from yellow through any shade of orange to a deep red; usually all members of a single tribe are about the same color. Goblins wear clothing of dark leather, tending toward drab, soiled-looking colors. Goblins speak Goblin; those with Intelligence scores of 12 or higher also speak Common.

Most goblins encountered outside their homes are warriors; the information in the statistics block is for one of 1st level.

### Combat

Being bullied by bigger, stronger creatures has taught goblins to exploit what few advantages they have: sheer numbers and malicious ingenuity. The concept of a fair fight is meaningless in their society. They favor ambushes, overwhelming odds, dirty tricks, and any other edge they can devise.

Goblins have a poor grasp of strategy and are cowardly by nature, tending to flee the field if a battle turns against them. With proper supervision, though, they can implement reasonably complex plans, and in such circumstances their numbers can be a deadly advantage.

**Skills:** Goblins have a +4 racial bonus on Move Silently and Ride checks. Goblin cavalry (mounted on worgs) usually select the Mounted Combat feat in place of the Alertness feat, which reduces their Spot and Listen check modifiers from +3 to +1.

**Challenge Rating:** Goblins with levels in NPC classes have a CR equal to their character level –2.

### Goblins as Characters

Goblin characters possess the following racial traits.

— –2 Strength, +2 Dexterity, –2 Charisma.

—Small size: +1 bonus to Armor Class, +1 bonus on attack rolls, +4 bonus on Hide checks, –4 penalty on grapple checks, lifting and carrying limits 3/4 those of Medium characters.

—A goblin’s base land speed is 30 feet.

—Darkvision out to 60 feet.

— +4 racial bonus on Move Silently and Ride checks.

—Automatic Languages: Common, Goblin. Bonus Languages: Draconic, Elven, Giant, Gnoll, Orc.

—Favored Class: Rogue.

The goblin warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Morningstar +2 melee (1d6) or javelin +3 ranged (1d4)","environment":"Temperate plains","organization":"Gang (4–9), band (10–100 plus 100% noncombatants plus 1 3rd-level sergeant per 20 adults and 1 leader of 4th–6th level), warband (10–24 with worg mounts), or tribe (40–400 plus 100% noncombatants plus 1 3rd-level sergeant per 20 adults, 1 or 2 lieutenants of 4th or 5th level, 1 leader of 6th–8th level, 10–24 worgs, and 2–4 dire wolves)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/–3","attack":"Morningstar +2 melee (1d6) or javelin +3 ranged (1d4)","full_attack":"Morningstar +2 melee (1d6) or javelin +3 ranged (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +1, Will –1","abilities":{"str":"11","dex":"13","con":"12","int":"10","wis":"9","cha":"6"},"skills":"Hide +5, Listen +2, Move Silently +5, Ride +4, Spot +2","feats":"Alertness","special_attacks":"—","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('clay_golem','Clay Golem','Clay Golem','10','Large','Construct','Always neutral','11d10+30 (90 hp)',90,'–1','20 ft. (4 squares)','22 (–1 size, –1 Dex, +14 natural), touch 8, flat-footed 22','+8/+19','Slam +14 melee (2d10+7 plus cursed wound)','10 ft./10 ft.','+3','+2','+3',25,9,null,null,11,1,'—','—','{"special_attacks":"Berserk, cursed wound","special_qualities":"Construct traits, damage reduction 10/adamantine and bludgeoning, darkvision 60 ft., haste, immunity to magic, low-light vision"}'::jsonb,'This golem has a humanoid body made from clay. A clay golem wears no clothing except for a metal or stiff leather garment around its hips.

A clay golem golem cannot speak or make any vocal noise. It walks and moves with a slow, clumsy gait. It weighs around 600 pounds.

#### Combat

**Berserk (Ex):** When a clay golem enters combat, there is a cumulative 1% chance each round that its elemental spirit breaks free and the golem goes berserk. The uncontrolled golem goes on a rampage, attacking the nearest living creature or smashing some object smaller than itself if no creature is within reach, then moving on to spread more destruction. Once a clay golem goes berserk, no known method can reestablish control.

**Cursed Wound (Ex):** The damage a clay golem deals doesn’t heal naturally and resists healing spells. A character attempting to cast a conjuration (healing) spell on a creature damaged by a clay golem must succeed on a DC 26 caster level check, or the spell has no effect on the injured character.

**Immunity to Magic (Ex):** A clay golem is immune to any spell or spell-like ability that allows spell resistance. In addition, certain spells and effects function differently against the creature, as noted below.

A _move earth_ spell drives the golem back 120 feet and deals 3d12 points of damage to it.

A _disintegrate_ spell slows the golem (as the _slow_ spell) for 1d6 rounds and deals 1d12 points of damage.

An _earthquake_ spell cast directly at a clay golem stops it from moving on its next turn and deals 5d10 points of damage. The golem gets no saving throw against any of these effects.

Any magical attack against a clay golem that deals acid damage heals 1 point of damage for every 3 points of damage it would otherwise deal. If the amount of healing would cause the golem to exceed its full normal hit points, it gains any excess as temporary hit points. For example, a clay golem hit by the breath weapon of a black dragon heals 7 points of damage if the attack would have dealt 22 points of damage. A clay golem golem gets no saving throw against magical attacks that deal acid damage.

**Haste (Su):** After it has engaged in at least 1 round of combat, a clay golem can haste itself once per day as a free action. The effect lasts 3 rounds and is otherwise the same as the spell.

#### Construction

A clay golem’s body must be sculpted from a single block of clay weighing at least 1,000 pounds, treated with rare oils and powders worth 1,500 gp. Creating the body requires a DC 15 Craft (sculpting) check or a DC 15 Craft (pottery) check.

CL 11th; Craft Construct, _animate objects, commune, resurrection_, caster must be at least 11th level; Price 40,000 gp; Cost 21,500 gp + 1,540 XP.','{"full_attack":"2 slams +14 melee (2d10+7 plus cursed wound)","environment":"Any","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"12–18 HD (Large); 19–33 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"11d10+30 (90 hp)","hit_points":90,"base_attack_grapple":"+8/+19","attack":"Slam +14 melee (2d10+7 plus cursed wound)","full_attack":"2 slams +14 melee (2d10+7 plus cursed wound)","space_reach":"10 ft./10 ft.","saves":"Fort +3, Ref +2, Will +3","abilities":{"str":"25","dex":"9","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Berserk, cursed wound","special_qualities":"Construct traits, damage reduction 10/adamantine and bludgeoning, darkvision 60 ft., haste, immunity to magic, low-light vision"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('flesh_golem','Flesh Golem','Flesh Golem','7','Large','Construct','Always neutral','9d10+30 (79 hp)',79,'–1','30 ft. (6 squares)','18 (–1 size, –1 Dex, +10 natural), touch 8, flat-footed 18','+6/+15','Slam +10 melee (2d8+5)','10 ft./10 ft.','+3','+2','+3',21,9,null,null,11,1,'—','—','{"special_attacks":"Berserk","special_qualities":"Construct traits, damage reduction 5/adamantine, darkvision 60 ft., immunity to magic, low-light vision"}'::jsonb,'A flesh golem is a ghoulish collection of stolen humanoid body parts, stitched together into a single composite form. No natural animal willingly tracks a flesh golem. The golem wears whatever clothing its creator desires, usually just a ragged pair of trousers. It has no possessions and no weapons. It stands 8 feet tall and weighs almost 500 pounds.

A flesh golem golem cannot speak, although it can emit a hoarse roar of sorts. It walks and moves with a stiff-jointed gait, as if not in complete control of its body.

#### Combat

**Berserk (Ex):** When a flesh golem enters combat, there is a cumulative 1% chance each round that its elemental spirit breaks free and the golem goes berserk. The uncontrolled golem goes on a rampage, attacking the nearest living creature or smashing some object smaller than itself if no creature is within reach, then moving on to spread more destruction. The golem’s creator, if within 60 feet, can try to regain control by speaking firmly and persuasively to the golem, which requires a DC 19 Charisma check. It takes 1 minute of inactivity by the golem to reset the golem’s berserk chance to 0%.

**Immunity to Magic (Ex):** A flesh golem is immune to any spell or spell-like ability that allows spell resistance. In addition, certain spells and effects function differently against the creature, as noted below.

A magical attack that deals cold or fire damage slows a flesh golem (as the _slow_ spell) for 2d6 rounds, with no saving throw.

A magical attack that deals electricity damage breaks any _slow_ effect on the golem and heals 1 point of damage for every 3 points of damage the attack would otherwise deal. If the amount of healing would cause the golem to exceed its full normal hit points, it gains any excess as temporary hit points. For example, a flesh golem hit by a _lightning bolt_ heals 3 points of damage if the attack would have dealt 11 points of damage. A flesh golem golem gets no saving throw against attacks that deal electricity damage.

#### Construction

The pieces of a flesh golem must come from normal human corpses that have not decayed significantly. Assembly requires a minimum of six different bodies—one for each limb, the torso (including head), and the brain. In some cases, more bodies may be necessary. Special unguents and bindings worth 500 gp are also required. Note that creating a flesh golem requires casting a spell with the evil descriptor.

Assembling the body requires a DC 13 Craft (leatherworking) check or a DC 13 Heal check.

CL 8th; Craft Construct, _animate dead, bull’s strength, geas/quest, limited wish_, caster must be at least 8th level; Price 20,000 gp; Cost 10,500 gp + 780 XP.','{"full_attack":"2 slams +10 melee (2d8+5)","environment":"Any","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"10–18 HD (Large); 19–27 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"9d10+30 (79 hp)","hit_points":79,"base_attack_grapple":"+6/+15","attack":"Slam +10 melee (2d8+5)","full_attack":"2 slams +10 melee (2d8+5)","space_reach":"10 ft./10 ft.","saves":"Fort +3, Ref +2, Will +3","abilities":{"str":"21","dex":"9","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Berserk","special_qualities":"Construct traits, damage reduction 5/adamantine, darkvision 60 ft., immunity to magic, low-light vision"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('iron_golem','Iron Golem','Iron Golem','13','Large','Construct','Always neutral','18d10+30 (129 hp)',129,'–1','20 ft. (4 squares)','30 (–1 size, –1 Dex, +22 natural) touch 8, flat-footed 30','+12/+28','Slam +23 melee (2d10+11)','10 ft./10 ft.','+6','+5','+6',33,9,null,null,11,1,'—','—','{"special_attacks":"Breath weapon","special_qualities":"Construct traits, damage reduction 15/adamantine, darkvision 60 ft., immunity to magic, low-light vision"}'::jsonb,'This golem has a humanoid body made from iron. An iron golem can be fashioned in any manner, just like a stone golem (see below), although it almost always displays armor of some sort. Its features are much smoother than those of a stone golem. Iron golems sometimes carry a short sword in one hand. An iron golem is 12 feet tall and weighs about 5,000 pounds. An iron golem cannot speak or make any vocal noise, nor does it have any distinguishable odor. It moves with a ponderous but smooth gait. Each step causes the floor to tremble unless it is on a thick, solid foundation.

#### Combat

**Breath Weapon (Su):** 10-foot cube, cloud of poisonous gas lasting 1 round, free action once every 1d4+1 rounds; initial damage 1d4 Con, secondary damage 3d4 Con, Fortitude DC 19 negates. The save DC is Constitution-based.

**Immunity to Magic (Ex):** An iron golem is immune to any spell or spell-like ability that allows spell resistance. In addition, certain spells and effects function differently against the creature, as noted below.

A magical attack that deals electricity damage slows an iron golem (as the _slow_ spell) for 3 rounds, with no saving throw.

A magical attack that deals fire damage breaks any _slow_ effect on the golem and heals 1 point of damage for each 3 points of damage the attack would otherwise deal. If the amount of healing would cause the golem to exceed its full normal hit points, it gains any excess as temporary hit points. For example, an iron golem hit by a _fireball_ gains back 6 hit points if the damage total is 18 points. An iron golem gets no saving throw against fire effects.

An iron golem is affected normally by rust attacks, such as that of a rust monster or a _rusting grasp_ spell.

#### Construction

An iron golem’s body is sculpted from 5,000 pounds of pure iron, smelted with rare tinctures and admixtures costing at least 10,000 gp. Assembling the body requires a DC 20 Craft (armorsmithing) check or a DC 20 Craft (weaponsmithing) check.

CL 16th; Craft Construct, _cloudkill, geas/quest, limited wish, polymorph any object_, caster must be at least 16th level; Price 150,000 gp; Cost 80,000 gp + 5,600 XP.','{"full_attack":"2 slams +23 melee (2d10+11)","environment":"Any","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"19–24 HD (Large); 25–54 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"18d10+30 (129 hp)","hit_points":129,"base_attack_grapple":"+12/+28","attack":"Slam +23 melee (2d10+11)","full_attack":"2 slams +23 melee (2d10+11)","space_reach":"10 ft./10 ft.","saves":"Fort +6, Ref +5, Will +6","abilities":{"str":"33","dex":"9","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Breath weapon","special_qualities":"Construct traits, damage reduction 15/adamantine, darkvision 60 ft., immunity to magic, low-light vision"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('stone_golem','Stone Golem','Stone Golem','11','Large','Construct','Always neutral','14d10+30 (107 hp)',107,'–1','20 ft. (4 squares)','26 (–1 size, –1 Dex, +18 natural), touch 8, flat-footed 26','+10/+23','Slam +18 melee (2d10+9)','10 ft./10 ft.','+4','+3','+4',29,9,null,null,11,1,'—','—','{"special_attacks":"Slow","special_qualities":"Construct traits, damage reduction 10/adamantine, darkvision 60 ft., immunity to magic, low-light vision"}'::jsonb,'This golem has a humanoid body made from stone. A stone golem is 9 feet tall and weighs around 2,000 pounds. Its body is frequently stylized to suit its creator. For example, it might look like it is wearing armor, with a particular symbol carved on the breastplate, or have designs worked into the stone of its limbs.

#### Combat

Stone golems are formidable opponents, being physically powerful and difficult to harm.

**Slow (Su):** A stone golem can use a slow effect, as the spell, as a free action once every 2 rounds. The effect has a range of 10 feet and a duration of 7 rounds, requiring a DC 17 Will save to negate. The save DC is Constitution-based.

**Immunity to Magic (Ex):** A stone golem is immune to any spell or spell-like ability that allows spell resistance. In addition, certain spells and effects function differently against the creature, as noted below.

A _transmute rock to mud_ spell slows a stone golem (as the _slow_ spell) for 2d6 rounds, with no saving throw, while _transmute mud to rock_ heals all of its lost hit points.

A _stone to flesh_ spell does not actually change the golem’s structure but negates its damage reduction and immunity to magic for 1 full round.

#### Construction

A stone golem’s body is chiseled from a single block of hard stone, such as granite, weighing at least 3,000 pounds. The stone must be of exceptional quality, and costs 5,000 gp. Assembling the body requires a DC 17 Craft (sculpting) check or a DC 17 Craft (stonemasonry) check.

CL 14th; Craft Construct, _antimagic field, geas/quest, symbol of stunning_, caster must be at least 14th level; Price 90,000 gp; Cost 50,000 gp + 3,400 XP.','{"full_attack":"2 slams +18 melee (2d10+9)","environment":"Any","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"15–21 HD (Large); 22–42 (Huge)","level_adjustment":"—","statblock":{"hit_dice":"14d10+30 (107 hp)","hit_points":107,"base_attack_grapple":"+10/+23","attack":"Slam +18 melee (2d10+9)","full_attack":"2 slams +18 melee (2d10+9)","space_reach":"10 ft./10 ft.","saves":"Fort +4, Ref +3, Will +4","abilities":{"str":"29","dex":"9","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Slow","special_qualities":"Construct traits, damage reduction 10/adamantine, darkvision 60 ft., immunity to magic, low-light vision"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('greater_stone_golem','Greater Stone Golem','Greater Stone Golem','16','Huge','Construct','Always neutral','42d10+40 (271 hp)',271,'–2','20 ft. (4 squares)','27 (–2 size, –2 Dex, +21 natural), touch 6, flat-footed 27','+31/+52','Slam +42 melee (4d8+13)','15 ft./15 ft.','+14','+12','+14',37,7,null,null,11,1,'—','—','{"special_attacks":"Slow","special_qualities":"Construct traits, damage reduction 10/adamantine, darkvision 60 ft., immunity to magic, low-light vision"}'::jsonb,'This golem has a humanoid body made from stone. A stone golem is 9 feet tall and weighs around 2,000 pounds. Its body is frequently stylized to suit its creator. For example, it might look like it is wearing armor, with a particular symbol carved on the breastplate, or have designs worked into the stone of its limbs.

#### Combat

Stone golems are formidable opponents, being physically powerful and difficult to harm.

**Slow (Su):** A stone golem can use a slow effect, as the spell, as a free action once every 2 rounds. The effect has a range of 10 feet and a duration of 7 rounds, requiring a DC 17 Will save to negate. The save DC is Constitution-based.

**Immunity to Magic (Ex):** A stone golem is immune to any spell or spell-like ability that allows spell resistance. In addition, certain spells and effects function differently against the creature, as noted below.

A _transmute rock to mud_ spell slows a stone golem (as the _slow_ spell) for 2d6 rounds, with no saving throw, while _transmute mud to rock_ heals all of its lost hit points.

A _stone to flesh_ spell does not actually change the golem’s structure but negates its damage reduction and immunity to magic for 1 full round.

#### Construction

A stone golem’s body is chiseled from a single block of hard stone, such as granite, weighing at least 3,000 pounds. The stone must be of exceptional quality, and costs 5,000 gp. Assembling the body requires a DC 17 Craft (sculpting) check or a DC 17 Craft (stonemasonry) check.

CL 14th; Craft Construct, _antimagic field, geas/quest, symbol of stunning_, caster must be at least 14th level; Price 90,000 gp; Cost 50,000 gp + 3,400 XP.','{"full_attack":"2 slams +42 melee (4d8+13)","environment":"Any","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"42d10+40 (271 hp)","hit_points":271,"base_attack_grapple":"+31/+52","attack":"Slam +42 melee (4d8+13)","full_attack":"2 slams +42 melee (4d8+13)","space_reach":"15 ft./15 ft.","saves":"Fort +14, Ref +12, Will +14","abilities":{"str":"37","dex":"7","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Slow","special_qualities":"Construct traits, damage reduction 10/adamantine, darkvision 60 ft., immunity to magic, low-light vision"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('gorgon','Gorgon','Gorgon','8','Large','Magical Beast','Always neutral','8d10+40 (85 hp)',85,'+4','30 ft. (6 squares)','20 (–1 size, +11 natural), touch 9, flat-footed 20','+8/+17','Gore +12 melee (1d8+7)','10 ft./5 ft.','+11','+6','+5',21,10,21,2,12,9,'Listen +9, Spot +8','Alertness, Improved Initiative, Iron Will','{"special_attacks":"Breath weapon, trample 1d8+7","special_qualities":"Darkvision 60 ft., lowlight vision, scent"}'::jsonb,'A typical gorgon stands over 6 feet tall at the shoulder and measures 8 feet from snout to tail. It weighs about 4,000 pounds.

Gorgons are nothing if not aggressive. They attack intruders on sight, attempting to trample, gore, or petrify them. There is no way to calm these furious creatures, and they are impossible to domesticate.

### Combat

Whenever possible, a gorgon begins an encounter by charging at its opponents.

**Breath Weapon (Su):** 60-foot cone, once every 1d4 rounds (but no more than five times per day), turn to stone permanently, Fortitude DC 19 negates. The save DC is Constitution-based.

**Trample (Ex):** Reflex DC 19 half. The save DC is Strength-based.','{"full_attack":"Gore +12 melee (1d8+7)","environment":"Temperate plains","organization":"Solitary, pair, pack (3–4), or herd (5–13)","treasure":"None","advancement":"9–15 HD (Large); 16–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"8d10+40 (85 hp)","hit_points":85,"base_attack_grapple":"+8/+17","attack":"Gore +12 melee (1d8+7)","full_attack":"Gore +12 melee (1d8+7)","space_reach":"10 ft./5 ft.","saves":"Fort +11, Ref +6, Will +5","abilities":{"str":"21","dex":"10","con":"21","int":"2","wis":"12","cha":"9"},"skills":"Listen +9, Spot +8","feats":"Alertness, Improved Initiative, Iron Will","special_attacks":"Breath weapon, trample 1d8+7","special_qualities":"Darkvision 60 ft., lowlight vision, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('gray_render','Gray Render','Gray Render','8','Large','Magical Beast','Usually neutral','10d10+70 (125 hp)',125,'+0','30 ft. (6 squares)','19 (–1 size, +10 natural), touch 9, flat-footed 19','+10/+20','Bite +15 melee (2d6+6)','10 ft./10 ft.','+14','+7','+4',23,10,24,3,12,8,'Hide +2, Spot +10, Survival +3','Cleave, Power Attack, Improved Bull Rush, Track','{"special_attacks":"Improved grab, rend 2d6+9","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'A gray render stands about 9 feet tall in spite of its hunched posture and is about 4 feet wide. It weighs about 4,000 pounds.

Gray renders are never found in groups. Each of these asexual creatures produces one offspring and carries it for a time in a pouch, but thereafter the young render must fend for itself.

A unique quality of the gray render is its tendency to bond with, protect, and provide for another creature (or group of creatures) native to its surroundings. Whether accepted or not, the render always attempts to remain fairly close, watching over its adopted charge(s) and daily bringing an offering of meat. It never willingly harms adopted creatures and retreats if they attack it.

### Combat

A gray render attacks to kill, whether to bring down prey or to protect itself or those it has adopted. When hunting, it sometimes attempts to hide and wait for prey to wander close.

**Improved Grab (Ex):** To use this ability, a gray render must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Rend (Ex):** A gray render that wins a grapple check after a successful bite attack establishes a hold, latching onto the opponent’s body and tearing the flesh. This attack automatically deals 2d6+9 points of damage.

**Skills:** Gray renders have a +4 racial bonus on Spot checks due to their six keen eyes.','{"full_attack":"Bite +15 melee (2d6+6); 2 claws +10 melee (1d6+3)","environment":"Temperate marshes","organization":"Solitary","treasure":"None","advancement":"11–15 HD (Large); 16–30 HD (Huge)","level_adjustment":"+5 (cohort)","statblock":{"hit_dice":"10d10+70 (125 hp)","hit_points":125,"base_attack_grapple":"+10/+20","attack":"Bite +15 melee (2d6+6)","full_attack":"Bite +15 melee (2d6+6); 2 claws +10 melee (1d6+3)","space_reach":"10 ft./10 ft.","saves":"Fort +14, Ref +7, Will +4","abilities":{"str":"23","dex":"10","con":"24","int":"3","wis":"12","cha":"8"},"skills":"Hide +2, Spot +10, Survival +3","feats":"Cleave, Power Attack, Improved Bull Rush, Track","special_attacks":"Improved grab, rend 2d6+9","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('grick','Grick','Grick','3','Medium','Aberration','Usually neutral','2d8 (9 hp)',9,'+2','30 ft. (6 squares), climb 20 ft.','16 (+2 Dex, +4 natural), touch 12, flat-footed 14','+1/+3','Tentacle +3 melee (1d4+2)','5 ft./5 ft.','+0','+2','+5',14,14,11,3,14,5,'Climb +10, Hide +3*, Listen +6, Spot +6','Alertness, TrackB','{"special_attacks":"—","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., scent"}'::jsonb,'An adult grick is about 8 feet long from the tips of its tentacles to the end of its body and weighs some 200 pounds. Its body coloration is uniformly dark, with a pale underbelly.

### Combat

Gricks attack when hungry or threatened. They hunt by holing up near high-traffic areas, using their natural coloration to blend into convenient shadows. When prey (virtually anything that moves) ventures near, they lash out with their tentacles. A grick’s rubbery body seems to shed blows of any kind. Its jaws are relatively small and weak compared to its body mass, so rather than consume its kill immediately, a grick normally drags its victim back to its lair to be eaten at its leisure.

A grick’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

Multiple gricks do not fight in concert. Each attacks the prey closest to it, and breaks off the fight as soon as it can drag dead or unconscious prey away.

**Skills:** A grick has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.

\*Their coloration affords gricks a +8 racial bonus on Hide checks when in natural rocky areas.','{"full_attack":"4 tentacles +3 melee (1d4+2); bite –2 melee (1d3+1)","environment":"Underground","organization":"Solitary or cluster (2–4)","treasure":"1/10 coins; 50% goods; 50% items","advancement":"3–4 HD (Medium); 5–6 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"2d8 (9 hp)","hit_points":9,"base_attack_grapple":"+1/+3","attack":"Tentacle +3 melee (1d4+2)","full_attack":"4 tentacles +3 melee (1d4+2); bite –2 melee (1d3+1)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +2, Will +5","abilities":{"str":"14","dex":"14","con":"11","int":"3","wis":"14","cha":"5"},"skills":"Climb +10, Hide +3*, Listen +6, Spot +6","feats":"Alertness, TrackB","special_attacks":"—","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('griffon','Griffon','Griffon','4','Large','Magical Beast','Always neutral','7d10+21 (59 hp)',59,'+2','30 ft. (6 squares), fly 80 ft. (average)','17 (–1 size, +2 Dex, +6 natural), touch 11, flat-footed 15','+7/+15','Bite +11 melee (2d6+4)','10 ft./5 ft.','+8','+7','+5',18,15,16,5,13,8,'Jump +8, Listen +6, Spot +10','Iron Will, Multiattack, Weapon Focus (bite)','{"special_attacks":"Pounce, rake 1d6+2","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'Griffons are powerful, majestic creatures with the characteristics of both lions and eagles. From nose to tail, an adult griffon can measure as much as 8 feet. Neither males nor females are endowed with a mane. A pair of broad, golden wings emerge from the creature’s back and span 25 feet or more. A griffon weighs about 500 pounds.

A griffon cannot speak, but understands Common.

### Combat

Griffons prefer to pounce on their prey, either diving to the attack or leaping from above.

**Pounce (Ex):** If a griffon dives upon or charges a foe, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +8 melee, damage 1d6+2.

**Skills:** Griffons have a +4 racial bonus on Jump and Spot checks.

### Training a Griffon

Although intelligent, a griffon requires training before it can bear a rider in combat. To be trained, a griffon must have a friendly attitude toward the trainer (this can be achieved through a successful Diplomacy check). Training a friendly griffon requires six weeks of work and a DC 25 Handle Animal check. Riding a griffon requires an exotic saddle. A griffon can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

Griffon eggs are worth 3,500 gp apiece on the open market, while young are worth 7,000 gp each. Professional trainers charge 1,500 gp to rear or train a griffon.

Carrying Capacity: A light load for a griffon is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.','{"full_attack":"Bite +11 melee (2d6+4) and 2 claws +8 melee (1d4+2)","environment":"Temperate hills","organization":"Solitary, pair, or pride (6–10)","treasure":"None","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"7d10+21 (59 hp)","hit_points":59,"base_attack_grapple":"+7/+15","attack":"Bite +11 melee (2d6+4)","full_attack":"Bite +11 melee (2d6+4) and 2 claws +8 melee (1d4+2)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +7, Will +5","abilities":{"str":"18","dex":"15","con":"16","int":"5","wis":"13","cha":"8"},"skills":"Jump +8, Listen +6, Spot +10","feats":"Iron Will, Multiattack, Weapon Focus (bite)","special_attacks":"Pounce, rake 1d6+2","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('grimlock','Grimlock','Grimlock','1','Medium','Monstrous Humanoid','Often neutral evil','2d8+2 (11 hp)',11,'+1','30 ft. (6 squares)','15 (+1 Dex, +4 natural), touch 11, flat-footed 14','+2/+4','Battleaxe +4 melee (1d8+3/3)','5 ft./5 ft.','+1','+4','+2',15,13,13,10,8,6,'Climb +4, Hide +3*, Listen +5, Spot +3','Alertness, TrackB','{"special_attacks":"—","special_qualities":"Blindsight 40 ft., immunities, scent"}'::jsonb,'### Combat

Grimlocks are blind, but their exceptional senses of smell and hearing allow them to notice foes nearby. As a result, they usually shun ranged weapons and rush to the attack, brandishing their stone battleaxes.

**Blindsight (Ex):** Grimlocks can sense all foes within 40 feet as a sighted creature would. Beyond that range, they treat all targets as having total concealment.

Grimlocks are susceptible to sound- and scent-based attacks, however, and are affected normally by loud noises and sonic spells (such as _ghost sound_ or _silence_) and overpowering odors (such as _stinking cloud_ or incense-heavy air). Negating a grimlock’s sense of smell or hearing reduces this ability to normal Blind-Fight (as the feat). If both these senses are negated, a grimlock is effectively blinded.

**Immunities:** Grimlocks are immune to gaze attacks, visual effects, illusions, and other attack forms that rely on sight.

**Skills:** \*A grimlock’s dull gray skin helps it hide in its native terrain, conferring a +10 racial bonus on Hide checks when in mountains or underground.

### Grimlocks as Characters

Grimlock characters possess the following racial traits.

— +4 Strength, +2 Dexterity, +2 Constitution, –2 Wisdom, –4 Charisma.

—Medium size.

—A grimlock’s base land speed is 30 feet.

—Racial Hit Dice: A grimlock begins with two levels of monstrous humanoid, which provide 2d8 Hit Dice, a base attack bonus of +2, and base saving throw bonuses of Fort +0, Ref +3, and Will +3.

—Racial Skills: A grimlock’s monstrous humanoid levels give it skill points equal to 5 x (2 + Int modifier, minimum 1). Its class skills are Climb, Hide, Listen, and Spot. Grimlocks gain a +10 racial bonus on Hide checks in mountain or underground settings.

—Racial Feats: A grimlock’s monstrous humanoid levels give it one feat.

—Weapon Proficiency: A grimlock is automatically proficient with the battleaxe.

— +4 natural armor bonus.

—Special Qualities (see above): Blindsight 40 ft., immunities, scent.

—Automatic Languages: Common, Grimlock. Bonus Languages: Draconic, Dwarven, Gnome, Terran, Undercommon.

—Favored Class: Barbarian.

—Level adjustment +2.','{"full_attack":"Battleaxe +4 melee (1d8+3/3)","environment":"Underground","organization":"Gang (2–4), pack (10–20), tribe (10–60 plus 1 leader of 3rd–5th level per 10 adults).","treasure":"Standard coins; standard goods (gems only); standard items","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+2/+4","attack":"Battleaxe +4 melee (1d8+3/3)","full_attack":"Battleaxe +4 melee (1d8+3/3)","space_reach":"5 ft./5 ft.","saves":"Fort +1, Ref +4, Will +2","abilities":{"str":"15","dex":"13","con":"13","int":"10","wis":"8","cha":"6"},"skills":"Climb +4, Hide +3*, Listen +5, Spot +3","feats":"Alertness, TrackB","special_attacks":"—","special_qualities":"Blindsight 40 ft., immunities, scent"},"source_file":"monsters-g.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-g.html',true),
('annis','Annis','Annis','6','Large','Monstrous Humanoid','Usually chaotic evil','7d8+14 (45 hp)',45,'+1','40 ft. (8 squares)','20 (–1 size, +1 Dex, +10 natural), touch 10, flat-footed 19','+7/+18','Claw +13 melee (1d6+7)','10 ft./10 ft.','+6','+6','+6',25,12,14,13,13,10,'Bluff +8, Diplomacy +2, Disguise +0 (+2 acting), Hide +5, Intimidate +2, Listen +10, Spot +10','Alertness, Blind-Fight, Great Fortitude','{"special_attacks":"Improved grab, rake 1d6+7, rend 2d6+10, spell-like abilities","special_qualities":"Damage reduction 2/bludgeoning, darkvision 60 ft., spell resistance 19"}'::jsonb,'An annis commonly uses its _disguise self_ ability to take the form of an exceptionally tall human, a fair giant, or an ogre.

An annis stands some 8 feet tall and weighs about 325 pounds.

#### Combat

Though physically powerful, these hags do not favor simple assaults but try to divide and confuse their foes before combat. They love to pose as commoners or gentlefolk to lull their victims into a sense of false security before they attack.

**Improved Grab (Ex):** To use this ability, an annis must hit a Large or smaller opponent with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Rake (Ex):** Attack bonus +13 melee, damage 1d6+7. An annis can attack a grappled foe with both claws at no penalty.

**Rend (Ex):** An annis that hits with both claw attacks latches onto the opponent’s body and tears the flesh. This attack automatically deals an extra 2d6+10 points of damage.

**Spell-Like Abilities:** 3/day—_disguise self_, _fog cloud._ Caster level 8th.','{"full_attack":"2 claws +13 melee (1d6+7) and bite +8 melee (1d6+3)","environment":"Cold marshes","organization":"Solitary or covey (3 hags of any kind plus 1–8 ogres and 1–4 evil giants)","treasure":"Standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"7d8+14 (45 hp)","hit_points":45,"base_attack_grapple":"+7/+18","attack":"Claw +13 melee (1d6+7)","full_attack":"2 claws +13 melee (1d6+7) and bite +8 melee (1d6+3)","space_reach":"10 ft./10 ft.","saves":"Fort +6, Ref +6, Will +6","abilities":{"str":"25","dex":"12","con":"14","int":"13","wis":"13","cha":"10"},"skills":"Bluff +8, Diplomacy +2, Disguise +0 (+2 acting), Hide +5, Intimidate +2, Listen +10, Spot +10","feats":"Alertness, Blind-Fight, Great Fortitude","special_attacks":"Improved grab, rake 1d6+7, rend 2d6+10, spell-like abilities","special_qualities":"Damage reduction 2/bludgeoning, darkvision 60 ft., spell resistance 19"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('green_hag','Green Hag','Green Hag','5','Medium','Monstrous Humanoid','Usually chaotic evil','9d8+9 (49 hp)',49,'+1','30 ft. (6 squares), swim 30 ft.','22 (+1 Dex, +11 natural), touch 11, flat-footed 21','+9/+13','Claw +13 melee (1d4+4)','5 ft./5 ft.','+6','+7','+7',19,12,12,13,13,14,'Concentration +7, Craft or Knowledge (any one) +7, Hide +9, Listen +11, Spot +11 Swim +12','Alertness, Blind-Fight, Combat Casting, Great Fortitude','{"special_attacks":"Spell-like abilities, weakness, mimicry","special_qualities":"Darkvision 90 ft., spell resistance 18"}'::jsonb,'Green hags are found in desolate swamps and dark forests.

A green hag is about the same height and weight as a female human.

#### Combat

Green hags prefer to attack from hiding, usually after distracting foes. They often use darkvision to their advantage by attacking during moonless nights.

**Spell-Like Abilities:** At will—_dancing lights, disguise self, ghost sound_ (DC 12), _invisibility, pass without trace, tongues, water breathing._ Caster level 9th. The save DC is Charisma-based.

**Weakness (Su):** A green hag can weaken a foe by making a special touch attack. The opponent must succeed on a DC 16 Fortitude save or take 2d4 points of Strength damage. The save DC is Charisma-based.

**Mimicry (Ex):** A green hag can imitate the sounds of almost any animal found near its lair.

**Skills:** A green hag has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +13 melee (1d4+4)","environment":"Temperate marshes","organization":"Solitary or covey (3 hags of any kind plus 1–8 ogres and 1–4 evil giants)","treasure":"Standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"9d8+9 (49 hp)","hit_points":49,"base_attack_grapple":"+9/+13","attack":"Claw +13 melee (1d4+4)","full_attack":"2 claws +13 melee (1d4+4)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +7, Will +7","abilities":{"str":"19","dex":"12","con":"12","int":"13","wis":"13","cha":"14"},"skills":"Concentration +7, Craft or Knowledge (any one) +7, Hide +9, Listen +11, Spot +11 Swim +12","feats":"Alertness, Blind-Fight, Combat Casting, Great Fortitude","special_attacks":"Spell-like abilities, weakness, mimicry","special_qualities":"Darkvision 90 ft., spell resistance 18"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('sea_hag','Sea Hag','Sea Hag','4','Medium','Monstrous Humanoid (Aquatic)','Usually chaotic evil','3d8+6 (19 hp)',19,'+1','30 ft. (6 squares), swim 40 ft.','14 (+1 Dex, +3 natural), touch 11, flat-footed 13','+3/+7','Claw +7 melee (1d4+4)','5 ft./5 ft.','+2','+4','+4',19,12,12,10,13,14,'Craft or Knowledge (any one) +3, Hide +4, Listen +6, Spot +6, Swim +12','Alertness, Toughness','{"special_attacks":"Horrific appearance, evil eye","special_qualities":"Amphibious, spell resistance 14"}'::jsonb,'The sea hag is found in the water of seas or overgrown lakes.

A sea hag is about the same height and weight as a female human.

#### Combat

Sea hags are not subtle and prefer a direct approach to combat.

They usually remain in hiding until they can affect as many foes as possible with their horrific appearance.

**Horrific Appearance (Su):** The sight of a sea hag is so revolting that anyone (other than another hag) who sets eyes upon one must succeed on a DC 13 Fortitude save or instantly be weakened, taking 2d6 points of Strength damage. This damage cannot reduce a victim’s Strength score below 0, but anyone reduced to Strength 0 is helpless. Creatures that are affected by this power or that successfully save against it cannot be affected again by the same hag’s horrific appearance for 24 hours. The save DC is Charisma-based.

**Evil Eye (Su):** Three times per day, a sea hag can cast its dire gaze upon any single creature within 30 feet. The target must succeed on a DC 13 Will save or be dazed for three days, although _remove curse_ or _dispel evil_ can restore sanity sooner. In addition, an affected creature must succeed on a DC 13 Fortitude save or die from fright. Creatures with immunity to fear effects are not affected by the sea hag’s evil eye. The save DCs are Charisma-based.

**Amphibious (Ex):** Although sea hags are aquatic, they can survive indefinitely on land.

**Skills:** A sea hag has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +7 melee (1d4+4)","environment":"Temperate aquatic","organization":"Solitary or covey (3 hags of any kind plus 1–8 ogres and 1–4 evil giants)","treasure":"Standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"3d8+6 (19 hp)","hit_points":19,"base_attack_grapple":"+3/+7","attack":"Claw +7 melee (1d4+4)","full_attack":"2 claws +7 melee (1d4+4)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +4, Will +4","abilities":{"str":"19","dex":"12","con":"12","int":"10","wis":"13","cha":"14"},"skills":"Craft or Knowledge (any one) +3, Hide +4, Listen +6, Spot +6, Swim +12","feats":"Alertness, Toughness","special_attacks":"Horrific appearance, evil eye","special_qualities":"Amphibious, spell resistance 14"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('halfling_1st_level_warrior','Halfling, 1st-Level Warrior','Halfling, 1st-Level Warrior','1/2','Small','Humanoid (Halfling)','Usually neutral','1d8+1 (5 hp)',5,'+1','20 ft. (4 squares)','16 (+1 size, +1 Dex, +3 studded leather, +1 light shield), touch 12, flat-footed 15','+1/–3','Longsword +3 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)','5 ft./5 ft.','+4','+2','+0',11,13,12,10,9,8,'Climb +2, Hide +4, Jump –4, Listen +3, Move Silently +1','Weapon Focus (longsword)','{"special_attacks":"Halfling traits","special_qualities":"Halfling traits"}'::jsonb,'Halflings stand about 3 feet tall and usually weigh between 30 and 35 pounds. They have brown or black eyes. Halfling men often have long sideburns, but beards are rare among them and mustaches almost unseen. Halflings prefer simple, comfortable, and practical clothes. Unlike members of most races, they prefer actual comfort to shows of wealth. Halflings reach adulthood in their early twenties and generally live into the middle of their second century. Halflings speak Halfling and Common.

Most halflings encountered outside their home are warriors; the information in the statistics block is for one of 1st level.

### Combat

Halflings prefer to fight defensively, usually hiding and launching ranged attacks as the foe approaches. Their tactics are very much like those of elves but place more emphasis on cover and concealment and less on mobility.

**Halfling Traits (Ex):** Halflings possess the following racial traits.

— +2 Dexterity, –2 Strength.

—Small size. +1 bonus to Armor Class, +1 bonus on attack rolls, +4 bonus on Hide checks, –4 penalty on grapple checks, lifting and carrying limits 3/4 those of Medium characters.

—A halfling’s base land speed is 20 feet.

— +2 racial bonus on Climb, Jump, and Move Silently checks.

— +1 racial bonus on all saving throws.

— +2 morale bonus on saving throws against fear. This bonus stacks with the halfling’s +1 bonus on saving throws in general.

— +1 racial bonus on attack rolls with thrown weapons and slings.

— +2 racial bonus on Listen checks.

—Automatic Languages: Common, Halfling. Bonus Languages: Dwarven, Elven, Gnome, Goblin, Orc.

—Favored Class: Rogue.

The halfling warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The information above is for the lightfoot halfling, the most common halfling variety. There are two other major halfling subraces, which differ from lightfoot halflings as follows.

#### Tallfellow

Tallfellows are somewhat rare among halfling folk. Tallfellows are 4 feet tall or more and weigh between 30 and 35 pounds. They generally speak Elven in addition to Common and Halfling.

**Tallfellow Traits (Ex):** These traits are in addition to the lightfoot halfling traits, except where noted.

— +2 racial bonus on Search, Spot, and Listen checks. Like an elf, a tallfellow who merely passes within 5 feet of a secret or concealed door is entitled to a Search check as though actively looking for it. This trait replaces the lightfoot’s +2 bonus on Listen checks.

—Tallfellows are less athletic than lightfoot halflings and do not have a racial bonus on Climb, Jump, and Move Silently checks.

#### Deep Halfling

These halflings are shorter and stockier than the more common lightfeet.

Deep halflings are about 2-1/2 tall and weigh between 30 and 35 pounds. Deep halflings speak Dwarven fluently.

**Deep Halfling Traits (Ex):** These traits are in addition to the lightfoot halfling traits, except where noted.

—Darkvision out to 60 feet.

—Stonecunning: Like dwarves, deep halflings have a +2 racial bonus on checks to notice unusual stonework. Something that isn’t stone but that is disguised as stone also counts as unusual stonework. A deep halfling who merely comes within 10 feet of unusual stonework can make a check as though actively searching and can use the Search skill to find stonework traps as a rogue can. A deep halfling can also intuit depth, sensing the approximate distance underground as naturally as a human can sense which way is up.

— +2 racial bonus on Appraise checks and Craft checks that are related to stone or metal.

—Deep halflings are less athletic than lightfoot halflings and do not have a racial bonus on Climb, Jump, and Move Silently checks.','{"full_attack":"Longsword +3 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","environment":"Warm plains (Deep halfling: Warm hills) (Tallfellow: Temperate forests)","organization":"Company (2–4), squad (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or band (30–100 plus 100% noncombatants plus 1 3rd-level sergeant per 20 adults, 5 5th-level lieutenants, 3 7th-level captains, 6–10 dogs, and 2–5 riding dogs)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/–3","attack":"Longsword +3 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","full_attack":"Longsword +3 melee (1d6/19–20) or light crossbow +3 ranged (1d6/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +2, Will +0","abilities":{"str":"11","dex":"13","con":"12","int":"10","wis":"9","cha":"8"},"skills":"Climb +2, Hide +4, Jump –4, Listen +3, Move Silently +1","feats":"Weapon Focus (longsword)","special_attacks":"Halfling traits","special_qualities":"Halfling traits"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('harpy','Harpy','Harpy','4','Medium','Monstrous Humanoid','Usually chaotic evil','7d8 (31 hp)',31,'+2','20 ft. (4 squares), fly 80 ft. (average)','13 (+2 Dex, +1 natural), touch 12, flat-footed 11','+7/+7','Club +7 melee (1d6)','5 ft./5 ft.','+2','+7','+6',10,15,10,7,12,17,'Bluff +11, Intimidate +7, Listen +7, Perform (oratory) +5, Spot +3','Dodge, Flyby Attack, Persuasive','{"special_attacks":"Captivating song","special_qualities":"Darkvision 60 ft."}'::jsonb,'Harpies like to entrance hapless travelers with their magical songs and lead them to unspeakable torments. Only when a harpy has finished playing with its new “toys” will it release them from suffering by killing and consuming them.

### Combat

When a harpy engages in battle, it prefers to use Flyby Attack and strike with a melee weapon.

**Captivating Song (Su):** The most insidious ability of the harpy is its song. When a harpy sings, all creatures (other than harpies) within a 300-foot spread must succeed on a DC 16 Will save or become captivated. This is a sonic mind-affecting charm effect. A creature that successfully saves cannot be affected again by the same harpy’s song for 24 hours. The save DC is Charisma-based.

A captivated victim walks toward the harpy, taking the most direct route available. If the path leads into a dangerous area (through flame, off a cliff, or the like), that creature gets a second saving throw. Captivated creatures can take no actions other than to defend themselves. (Thus, a fighter cannot run away or attack but takes no defensive penalties.) A victim within 5 feet of the harpy stands there and offers no resistance to the monster’s attacks. The effect continues for as long as the harpy sings and for 1 round thereafter. A bard’s countersong ability allows the captivated creature to attempt a new Will save.

**Skills:** Harpies have a +4 racial bonus on Bluff and Listen checks.

### Harpy Archer

A cruel hunter and roaming brigand, the harpy archer has trained as a fighter specializing in ranged combat. Harpy archers often become mercenaries, selling their services to the highest bidder. When not employed, they make ends meet as highway robbers, forcing merchant caravans to pay protection money.

#### Combat

**Captivating Song (Su):** Will DC 17 negates.

_Possessions: +3 studded leather, +1 frost composite longbow_ (+1 Str bonus), 10 cold iron arrows, 10 silvered arrows, 5 _+2 arrows, lesser bracers of archery, potion of cure moderate wounds, potion of cat’s grace, cloak of resistance +2, ring of protection +1._ (Different harpy archers may have different possessions.)','{"full_attack":"Club +7/+2 melee (1d6) and 2 claws +2 melee (1d3)","environment":"Temperate marshes","organization":"Solitary, pair, or flight (7–12)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"7d8 (31 hp)","hit_points":31,"base_attack_grapple":"+7/+7","attack":"Club +7 melee (1d6)","full_attack":"Club +7/+2 melee (1d6) and 2 claws +2 melee (1d3)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +7, Will +6","abilities":{"str":"10","dex":"15","con":"10","int":"7","wis":"12","cha":"17"},"skills":"Bluff +11, Intimidate +7, Listen +7, Perform (oratory) +5, Spot +3","feats":"Dodge, Flyby Attack, Persuasive","special_attacks":"Captivating song","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('harpy_archer_7th_level_fighter','Harpy Archer, 7th-Level Fighter','Harpy Archer, 7th-Level Fighter','11','Medium','Monstrous Humanoid','Usually chaotic evil','7d8 + 7d10 + 28 (103 hp)',103,'+9','20 ft. (4 squares), fly 80 ft. (average)','AC 23 (+5 Dex, +1 natural, +6 +3 studded leather, +1 ring of protection +1), touch 16, flat-footed 18','+14/+15','+1 frost composite longbow (+1 Str bonus) +22 ranged (1d8+4/19–20/×3 plus 1d6 cold) or claw +15 melee (1d3+1)','5 ft./5 ft.','+11','+14','+11',12,20,14,6,11,19,'Bluff +11, Intimidate +5, Listen +7, Perform (oratory) +10, Spot +5','Alertness, Improved Critical (composite longbow), Improved Initiative, Iron Will, Manyshot, Point Blank Shot, Rapid Shot, Weapon Focus (composite longbow), Weapon Specialization (composite longbow)','{"special_attacks":"Captivating song","special_qualities":"Darkvision 60 ft."}'::jsonb,'Harpies like to entrance hapless travelers with their magical songs and lead them to unspeakable torments. Only when a harpy has finished playing with its new “toys” will it release them from suffering by killing and consuming them.

### Combat

When a harpy engages in battle, it prefers to use Flyby Attack and strike with a melee weapon.

**Captivating Song (Su):** The most insidious ability of the harpy is its song. When a harpy sings, all creatures (other than harpies) within a 300-foot spread must succeed on a DC 16 Will save or become captivated. This is a sonic mind-affecting charm effect. A creature that successfully saves cannot be affected again by the same harpy’s song for 24 hours. The save DC is Charisma-based.

A captivated victim walks toward the harpy, taking the most direct route available. If the path leads into a dangerous area (through flame, off a cliff, or the like), that creature gets a second saving throw. Captivated creatures can take no actions other than to defend themselves. (Thus, a fighter cannot run away or attack but takes no defensive penalties.) A victim within 5 feet of the harpy stands there and offers no resistance to the monster’s attacks. The effect continues for as long as the harpy sings and for 1 round thereafter. A bard’s countersong ability allows the captivated creature to attempt a new Will save.

**Skills:** Harpies have a +4 racial bonus on Bluff and Listen checks.

### Harpy Archer

A cruel hunter and roaming brigand, the harpy archer has trained as a fighter specializing in ranged combat. Harpy archers often become mercenaries, selling their services to the highest bidder. When not employed, they make ends meet as highway robbers, forcing merchant caravans to pay protection money.

#### Combat

**Captivating Song (Su):** Will DC 17 negates.

_Possessions: +3 studded leather, +1 frost composite longbow_ (+1 Str bonus), 10 cold iron arrows, 10 silvered arrows, 5 _+2 arrows, lesser bracers of archery, potion of cure moderate wounds, potion of cat’s grace, cloak of resistance +2, ring of protection +1._ (Different harpy archers may have different possessions.)','{"full_attack":"+1 frost composite longbow (+1 Str bonus) +22/+17/+12 ranged (1d8+4/19–20/×3 plus 1d6 cold) or 2 claws +15 melee (1d3+1)","environment":"Temperate marshes","organization":"Solitary","treasure":"Standard (including equipment)","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"7d8 + 7d10 + 28 (103 hp)","hit_points":103,"base_attack_grapple":"+14/+15","attack":"+1 frost composite longbow (+1 Str bonus) +22 ranged (1d8+4/19–20/×3 plus 1d6 cold) or claw +15 melee (1d3+1)","full_attack":"+1 frost composite longbow (+1 Str bonus) +22/+17/+12 ranged (1d8+4/19–20/×3 plus 1d6 cold) or 2 claws +15 melee (1d3+1)","space_reach":"5 ft./5 ft.","saves":"Fort +11, Ref +14, Will +11","abilities":{"str":"12","dex":"20","con":"14","int":"6","wis":"11","cha":"19"},"skills":"Bluff +11, Intimidate +5, Listen +7, Perform (oratory) +10, Spot +5","feats":"Alertness, Improved Critical (composite longbow), Improved Initiative, Iron Will, Manyshot, Point Blank Shot, Rapid Shot, Weapon Focus (composite longbow), Weapon Specialization (composite longbow)","special_attacks":"Captivating song","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('hellhound','Hellhound','Hellhound','3','Medium','Outsider (Evil, Extraplanar, Fire, Lawful)','Always lawful evil','4d8+4 (22 hp)',22,'+5','40 ft. (8 squares)','16 (+1 Dex, +5 natural), touch 11, flat-footed 15','+4/+5','Bite +5 melee (1d8+1 plus 1d6 fire)','5 ft./5 ft.','+5','+5','+4',13,13,13,6,10,6,'Hide +13, Jump +12, Listen +7, Move Silently +13, Spot +7, Survival +7*','Improved Initiative, Run, TrackB','{"special_attacks":"Breath weapon, fiery bite","special_qualities":"Darkvision 60 ft., immunity to fire, scent, vulnerability to cold"}'::jsonb,'A typical hell hound stands 4-1/2 feet high at the shoulder and weighs 120 pounds.

Hell hounds do not speak but understand Infernal.

### Combat

Hell hounds are efficient hunters. A favorite pack tactic is to surround prey quietly, then attack with one or two hounds, driving it toward the rest with their fiery breath. If the prey doesn’t run, the pack closes in. Hell hounds track fleeing prey relentlessly.

A hell hound’s natural weapons, as well as any weapons it wields, are treated as evil-aligned

and lawful-aligned for the purpose of overcoming damage reduction.

**Breath Weapon (Su):** 10-foot cone, once every 2d4 rounds, damage 2d6 fire, Reflex DC 13 half. The save DC is Constitution-based.

**Fiery Bite (Su):** A hell hound deals an extra 1d6 points of fire damage every time it bites an opponent, as if its bite were a flaming weapon.

**Skills:** Hell hounds have a +5 racial bonus on Hide and Move Silently checks.

\*They also receive a +8 racial bonus on Survival checks when tracking by scent, due to their keen sense of smell.

### Nessian Warhound

Nessian warhounds are coalblack mastiffs the size of draft horses, often fitted with shirts of infernal chainmail.

Nessian warhounds resemble hell hounds, except as otherwise noted.

**Breath Weapon (Su):** 10-foot cone, once every 2d4 rounds, damage 3d6 fire, Reflex DC 21 half. The save DC is Constitution- based.

**Fiery Bite (Su):** A Nessian warhound deals an extra 1d8 points of fire d a m a g e every time it bites an opponent, as if its bite were a flaming weapon.','{"full_attack":"Bite +5 melee (1d8+1 plus 1d6 fire)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, or pack (5–12)","treasure":"None","advancement":"5–8 HD (Medium); 9–12 HD (Large)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"4d8+4 (22 hp)","hit_points":22,"base_attack_grapple":"+4/+5","attack":"Bite +5 melee (1d8+1 plus 1d6 fire)","full_attack":"Bite +5 melee (1d8+1 plus 1d6 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +5, Will +4","abilities":{"str":"13","dex":"13","con":"13","int":"6","wis":"10","cha":"6"},"skills":"Hide +13, Jump +12, Listen +7, Move Silently +13, Spot +7, Survival +7*","feats":"Improved Initiative, Run, TrackB","special_attacks":"Breath weapon, fiery bite","special_qualities":"Darkvision 60 ft., immunity to fire, scent, vulnerability to cold"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('nessian_warhound','Nessian Warhound','Nessian Warhound','9','Large','Outsider (Evil, Extraplanar, Fire, Lawful)','Always lawful evil','12d8+60 (114 hp)',114,'+6','40 ft. (8 squares)','24 (–1 size, +2 Dex, +7 natural, +6 +2 chain shirt barding), touch 11, flat-footed 22','+12/+24','Bite +20 melee (2d6+12/19–20 plus 1d8 fire)','10 ft./10 ft.','+13','+10','+9',26,14,20,4,12,6,'Hide +17, Jump +19, Listen +18, Move Silently +21, Spot +18, Survival +8*, Tumble +3','Alertness, Improved Critical (bite), Improved Initiative, Track, Weapon Focus (bite)','{"special_attacks":"Breath weapon, fiery bite","special_qualities":"Darkvision 60 ft., immunity to fire, scent, vulnerability to cold"}'::jsonb,'A typical hell hound stands 4-1/2 feet high at the shoulder and weighs 120 pounds.

Hell hounds do not speak but understand Infernal.

### Combat

Hell hounds are efficient hunters. A favorite pack tactic is to surround prey quietly, then attack with one or two hounds, driving it toward the rest with their fiery breath. If the prey doesn’t run, the pack closes in. Hell hounds track fleeing prey relentlessly.

A hell hound’s natural weapons, as well as any weapons it wields, are treated as evil-aligned

and lawful-aligned for the purpose of overcoming damage reduction.

**Breath Weapon (Su):** 10-foot cone, once every 2d4 rounds, damage 2d6 fire, Reflex DC 13 half. The save DC is Constitution-based.

**Fiery Bite (Su):** A hell hound deals an extra 1d6 points of fire damage every time it bites an opponent, as if its bite were a flaming weapon.

**Skills:** Hell hounds have a +5 racial bonus on Hide and Move Silently checks.

\*They also receive a +8 racial bonus on Survival checks when tracking by scent, due to their keen sense of smell.

### Nessian Warhound

Nessian warhounds are coalblack mastiffs the size of draft horses, often fitted with shirts of infernal chainmail.

Nessian warhounds resemble hell hounds, except as otherwise noted.

**Breath Weapon (Su):** 10-foot cone, once every 2d4 rounds, damage 3d6 fire, Reflex DC 21 half. The save DC is Constitution- based.

**Fiery Bite (Su):** A Nessian warhound deals an extra 1d8 points of fire d a m a g e every time it bites an opponent, as if its bite were a flaming weapon.','{"full_attack":"Bite +20 melee (2d6+12/19–20 plus 1d8 fire)","environment":"A lawful evil plane","organization":"Solitary, pair, or pack (1–2 Nessian warhounds and 5–12 hell hounds)","treasure":"+2 chain shirt barding","advancement":"13–17 HD (Large); 18–24 HD (Huge)","level_adjustment":"+4 (cohort)","statblock":{"hit_dice":"12d8+60 (114 hp)","hit_points":114,"base_attack_grapple":"+12/+24","attack":"Bite +20 melee (2d6+12/19–20 plus 1d8 fire)","full_attack":"Bite +20 melee (2d6+12/19–20 plus 1d8 fire)","space_reach":"10 ft./10 ft.","saves":"Fort +13, Ref +10, Will +9","abilities":{"str":"26","dex":"14","con":"20","int":"4","wis":"12","cha":"6"},"skills":"Hide +17, Jump +19, Listen +18, Move Silently +21, Spot +18, Survival +8*, Tumble +3","feats":"Alertness, Improved Critical (bite), Improved Initiative, Track, Weapon Focus (bite)","special_attacks":"Breath weapon, fiery bite","special_qualities":"Darkvision 60 ft., immunity to fire, scent, vulnerability to cold"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('hippogriff','Hippogriff','Hippogriff','2','Large','Magical Beast','Always neutral','3d10+9 (25 hp)',25,'+2','50 ft. (10 squares), fly 100 ft. (average)','15 (–1 size, +2 Dex, +4 natural), touch 11, flat-footed 13','+3/+11','Claw +6 melee (1d4+4)','10 ft./5 ft.','+6','+5','+2',18,15,16,2,13,8,'Listen +4, Spot +8','Dodge, Wingover','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'Hippogriffs are aggressive flying creatures that combine features of horses and giant eagles. Voracious omnivores, hippogriffs will hunt humanoids as readily as any other meal. A typical hippogriff is 9 feet long, has a wingspan of 20 feet, and weighs 1,000 pounds.

### Combat

Hippogriffs dive at their prey and strike with their clawed forelegs. When they cannot dive, they slash with claws and beak. Mated pairs and flights of these creatures attack in concert, diving repeatedly to drive away or kill intruders. Hippogriffs fight to the death to defend their nests and their hatchlings, which are prized as aerial mounts and fetch a handsome price in many civilized areas.

**Skills:** Hippogriffs have a +4 racial bonus on Spot checks.

### Training a Hippogriff

A hippogriff requires training before it can bear a rider in combat.

Training a hippogriff requires six weeks of work and a DC 25 Handle Animal check. Riding a hippogriff requires an exotic saddle. A hippogriff can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

Hippogriff eggs are worth 2,000 gp apiece on the open market, while young are worth 3,000 gp each. Professional trainers charge 1,000 gp to rear or train a hippogriff.

**Carrying Capacity:** A light load for a hippogriff is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.','{"full_attack":"2 claws +6 melee (1d4+4) and bite +1 melee (1d8+2)","environment":"Temperate hills","organization":"Solitary, pair, or flight (7–12)","treasure":"None","advancement":"4–6 HD (Large); 7–9 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"3d10+9 (25 hp)","hit_points":25,"base_attack_grapple":"+3/+11","attack":"Claw +6 melee (1d4+4)","full_attack":"2 claws +6 melee (1d4+4) and bite +1 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +6, Ref +5, Will +2","abilities":{"str":"18","dex":"15","con":"16","int":"2","wis":"13","cha":"8"},"skills":"Listen +4, Spot +8","feats":"Dodge, Wingover","special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('hobgoblin','Hobgoblin','Hobgoblin, 1st-Level Warrior','1/2','Medium','Humanoid (Goblinoid)','Usually lawful evil','1d8+2 (6 hp)',6,'+1','30 ft. (6 squares)','15 (+1 Dex, +3 studded leather, +1 light shield), touch 11, flat-footed 14','+1/+2','Longsword +2 melee (1d8+1/19–20) or javelin +2 ranged (1d6+1)','5 ft./5 ft.','+4','+1','–1',13,13,14,10,9,8,'Hide +3, Listen +2, Move Silently +3, Spot +2','Alertness','{"special_attacks":"—","special_qualities":"Darkvision 60 ft."}'::jsonb,'Hobgoblins are larger cousins of goblins. Hobgoblins’ hair color ranges from dark reddish-brown to dark gray. They have dark orange or red-orange skin. Large males have blue or red noses. Hobgoblins’ eyes are yellowish or dark brown, while their teeth are yellow. Their garments tend to be brightly colored, often blood red with black-tinted leather. Their weaponry is kept polished and in good repair. Hobgoblins speak Goblin and Common. Most hobgoblins encountered outside their homes are warriors; the information in the statistics block is for one of 1st level.

### Combat

These creatures have a strong grasp of strategy and tactics and are capable of carrying out sophisticated battle plans. Under the leadership of a skilled strategist or tactician, their discipline can prove a deciding factor. Hobgoblins hate elves and attack them first, in preference to other opponents.

**Skills:** Hobgoblins have a +4 racial bonus on Move Silently checks.

The hobgoblin warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Hobgoblin Characters

Hobgoblin characters possess the following racial traits.

— +2 Dexterity, +2 Constitution.

—A hobgoblin’s base land speed is 30 feet.

—Darkvision out to 60 feet.

— +4 racial bonus on Move Silently checks.

—Automatic Languages: Common, Goblin. Bonus Languages: Draconic, Dwarven, Infernal, Giant, Orc.

—Favored Class: Fighter.

—Level adjustment +1.','{"full_attack":"Longsword +2 melee (1d8+1/19–20) or javelin +2 ranged (1d6+1)","environment":"Warm hills","organization":"Gang (4–9), band (10–100 plus 50% noncombatants plus 1 3rd-level sergeant per 20 adults and 1 leader of 4th–6th level), warband (10–24), or tribe (30–300 plus 50% noncombatants plus 1 3rd-level sergeant per 20 adults, 1 or 2 lieutenants of 4th or 5th level, 1 leader of 6th–8th level, 2–4 dire wolves, and 1–4 ogres or 1–2 trolls)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"1d8+2 (6 hp)","hit_points":6,"base_attack_grapple":"+1/+2","attack":"Longsword +2 melee (1d8+1/19–20) or javelin +2 ranged (1d6+1)","full_attack":"Longsword +2 melee (1d8+1/19–20) or javelin +2 ranged (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +1, Will –1","abilities":{"str":"13","dex":"13","con":"14","int":"10","wis":"9","cha":"8"},"skills":"Hide +3, Listen +2, Move Silently +3, Spot +2","feats":"Alertness","special_attacks":"—","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('homunculus','Homunculus','Homunculus','1','Tiny','Construct','Any (same as creator)','2d10 (11 hp)',11,'+2','20 ft. (4 squares), fly 50 ft. (good)','14 (+2 Dex, +2 size), touch 14, flat-footed 12','+1/–8','Bite +2 melee (1d4–1 plus poison)','2-1/2 ft./0 ft.','+0','+4','+1',8,15,null,10,12,7,'Hide +14, Listen +4, Spot +4','Lightning Reflexes','{"special_attacks":"Poison","special_qualities":"Construct traits, darkvision 60 ft., low-light vision"}'::jsonb,'A homunculus is a miniature servant created by a wizard. These creatures are weak combatants but make effective spies, messengers, and scouts. A homunculus’s creator determines its precise features. Homunculi are little more than tools designed to carry out assigned tasks. They are extensions of their creators, sharing the same alignment and basic nature. A homunculus cannot speak, but the process of creating one links it telepathically with its creator.

It knows what its master knows and can convey to him or her everything it sees and hears, out to a distance of 1,500 feet. A homunculus never travels beyond this range willingly, though it can be removed forcibly. If this occurs, the creature does everything in its power to regain contact with its master. An attack that destroys a homunculus deals 2d10 points of damage to its master.

If the creature’s master is slain, the homunculus also dies, and its body swiftly melts away into a pool of ichor.

### Combat

Homunculi land on their victims and bite with their venomous fangs.

**Poison (Ex):** Injury, Fortitude DC 13, initial damage sleep for 1 minute, secondary damage sleep for another 5d6 minutes. The save DC is Constitution-based and includes a +2 racial bonus.

### Construction

A homunculus is shaped from a mixture of clay, ashes, mandrake root, spring water, and one pint of the creator’s own blood. The materials cost 50 gp. The creature’s master may assemble the body or hire someone else to do the job. Creating the body requires a DC 12 Craft (sculpting) check or a DC 12 Craft (pottery) check.

After the body is sculpted, it is animated through an extended magical ritual that requires a specially prepared laboratory or workroom, similar to an alchemist’s laboratory and costing 500 gp to establish. If the creator is personally constructing the creature’s body, the building and ritual can be performed together.

A homunculus with more than 2 Hit Dice can be created, but each additional Hit Die adds +2,000 gp to the cost to create.

Craft Construct, _arcane eye, mirror image, mending,_ caster must be at least 4th level; Price — (never sold); Cost 1,050 gp + 78 XP.','{"full_attack":"Bite +2 melee (1d4–1 plus poison)","environment":"Any","organization":"Solitary","treasure":"None","advancement":"3–6 HD (Tiny)","level_adjustment":"—","statblock":{"hit_dice":"2d10 (11 hp)","hit_points":11,"base_attack_grapple":"+1/–8","attack":"Bite +2 melee (1d4–1 plus poison)","full_attack":"Bite +2 melee (1d4–1 plus poison)","space_reach":"2-1/2 ft./0 ft.","saves":"Fort +0, Ref +4, Will +1","abilities":{"str":"8","dex":"15","con":null,"int":"10","wis":"12","cha":"7"},"skills":"Hide +14, Listen +4, Spot +4","feats":"Lightning Reflexes","special_attacks":"Poison","special_qualities":"Construct traits, darkvision 60 ft., low-light vision"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('howler','Howler','Howler','3','Large','Outsider (Chaotic, Evil, Extraplanar)','Always chaotic evil','6d8+12 (39 hp)',39,'+7','60 ft. (12 squares)','17 (–1 size, +3 Dex, +5 natural), touch 12, flat-footed 14','+6/+15','Bite +10 melee (2d8+5)','10 ft./5 ft.','+7','+8','+7',21,17,15,6,14,8,'Climb +14, Hide +8, Listen +13, Move Silently +12, Search +7, Spot +13, Survival +2 (+4 following tracks)','Alertness, Combat Reflexes, Improved Initiative','{"special_attacks":"Quills, howl","special_qualities":"Darkvision 60 ft."}'::jsonb,'Howlers live on planes where chaos and evil hold sway. A howler is about 8 feet long and weighs about 2,000 pounds. Although they are surprisingly intelligent, howlers do not speak—they only howl. If there is a language within the howls, as some have suggested, even spells cannot decipher it. Howlers understand Abyssal.

### Combat

Howlers attack in groups, for they are cowardly and cruel. They prefer to charge into combat, race out, and then charge in again. A howler’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Quills (Ex):** A howler’s neck bristles with long quills. While biting, the creature thrashes about, striking with 1d4 of them. An opponent hit by a howler’s quill attack must succeed on a DC 16 Reflex save or have the quill break off in his or her flesh. Lodged quills impose a –1 penalty on attacks, saves, and checks per quill. The save DC is Dexterity-based.

A quill can be removed safely with a DC 20 Heal check; otherwise, removing a quill deals an extra 1d6 points of damage.

**Howl (Ex):** All beings other than outsiders that hear the creature’s howling for an hour or longer are subject to its effect, though it does not help the howler in combat. Anyone within hearing range of a howler for a full hour must succeed on a DC 12 Will save or take 1 point of Wisdom damage. The save DC is Charisma-based. The save must be repeated for each hour of exposure. This is a sonic mind-affecting effect.

### Training a Howler

Although intelligent, a howler requires training before it can bear a rider in combat. To be trained, a howler must have a friendly attitude toward the trainer (this can be achieved through a successful Diplomacy check). Training a friendly howler requires six weeks of work and a DC 25 Handle Animal check. Riding a howler requires an exotic saddle. A howler can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

**Carrying Capacity:** A light load for a howler is up to 460 pounds; a medium load, 461–920 pounds; and a heavy load, 921–1,380 pounds. A howler can drag 6,900 pounds.','{"full_attack":"Bite +10 melee (2d8+5) and 1d4 quills +5 melee (1d6+2)","environment":"A chaotic-aligned plane","organization":"Solitary, gang (2–4), or pack (6–10)","treasure":"None","advancement":"7–9 HD (Large); 11–18 HD (Huge)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"6d8+12 (39 hp)","hit_points":39,"base_attack_grapple":"+6/+15","attack":"Bite +10 melee (2d8+5)","full_attack":"Bite +10 melee (2d8+5) and 1d4 quills +5 melee (1d6+2)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +8, Will +7","abilities":{"str":"21","dex":"17","con":"15","int":"6","wis":"14","cha":"8"},"skills":"Climb +14, Hide +8, Listen +13, Move Silently +12, Search +7, Spot +13, Survival +2 (+4 following tracks)","feats":"Alertness, Combat Reflexes, Improved Initiative","special_attacks":"Quills, howl","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('five_headed_hydra','Five-Headed Hydra','Five-Headed Hydra','4 (normal); 6 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','5d10+28 (55 hp)',55,'+1','20 ft. (4 squares), swim 20 ft.','15 (–2 size, +1 Dex, +6 natural), touch 9, flat-footed 14','+5/+16','5 bites +6 melee (1d10+3)','15 ft./10 ft.','+9','+5','+3',17,12,20,2,10,9,'Listen +6, Spot +6, Swim +11','Combat ReflexesB, Iron Will, Toughness','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 15, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eight-Headed Hydra</th><th>Nine-Headed Hydra</th><th>Ten-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>8d10+43 (87 hp)</td><td>9d10+48 (97 hp)</td><td>10d10+53 (108 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, +1 Dex, +9 natural), touch 9, flat-footed 17</td><td>19 (–2 size, +1 Dex, +10 natural), touch 9, flat-footed 18</td><td>20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19</td></tr><tr><th>Base Attack/Grapple:</th><td>+8/+20</td><td>+9/+22</td><td>+10/+23</td></tr><tr><th>Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Full Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 18, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 19, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 20, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +11, Ref +7, Will +4</td><td>Fort +11, Ref +7, Will +5</td><td>Fort +12, Ref +8, Will +3</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +7, Spot +8, Swim +12</td><td>Listen +8, Spot +8, Swim +13</td><td>Listen +8, Spot +9, Swim +13</td></tr><tr><th>Feats:</th><td>Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7 (normal);<br>9 (pyro- or cryo-)</td><td>8 (normal);<br>10 (pyro- or cryo-)</td><td>9 (normal);<br>11 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"5 bites +6 melee (1d10+3)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"5d10+28 (55 hp)","hit_points":55,"base_attack_grapple":"+5/+16","attack":"5 bites +6 melee (1d10+3)","full_attack":"5 bites +6 melee (1d10+3)","space_reach":"15 ft./10 ft.","saves":"Fort +9, Ref +5, Will +3","abilities":{"str":"17","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +6, Spot +6, Swim +11","feats":"Combat ReflexesB, Iron Will, Toughness","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 15, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('six_headed_hydra','Six-Headed Hydra','Six-Headed Hydra','5 (normal); 7 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','6d10+33 (66 hp)',66,'+1','20 ft. (4 squares), swim 20 ft.','16 (–2 size, +1 Dex, +7 natural), touch 9, flat-footed 15','+6/+17','6 bites +8 melee (1d10+3)','15 ft./10 ft.','+10','+6','+4',17,12,20,2,10,9,'Listen +6, Spot +7, Swim +11','Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 16, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eight-Headed Hydra</th><th>Nine-Headed Hydra</th><th>Ten-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>8d10+43 (87 hp)</td><td>9d10+48 (97 hp)</td><td>10d10+53 (108 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, +1 Dex, +9 natural), touch 9, flat-footed 17</td><td>19 (–2 size, +1 Dex, +10 natural), touch 9, flat-footed 18</td><td>20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19</td></tr><tr><th>Base Attack/Grapple:</th><td>+8/+20</td><td>+9/+22</td><td>+10/+23</td></tr><tr><th>Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Full Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 18, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 19, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 20, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +11, Ref +7, Will +4</td><td>Fort +11, Ref +7, Will +5</td><td>Fort +12, Ref +8, Will +3</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +7, Spot +8, Swim +12</td><td>Listen +8, Spot +8, Swim +13</td><td>Listen +8, Spot +9, Swim +13</td></tr><tr><th>Feats:</th><td>Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7 (normal);<br>9 (pyro- or cryo-)</td><td>8 (normal);<br>10 (pyro- or cryo-)</td><td>9 (normal);<br>11 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"6 bites +8 melee (1d10+3)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"6d10+33 (66 hp)","hit_points":66,"base_attack_grapple":"+6/+17","attack":"6 bites +8 melee (1d10+3)","full_attack":"6 bites +8 melee (1d10+3)","space_reach":"15 ft./10 ft.","saves":"Fort +10, Ref +6, Will +4","abilities":{"str":"17","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +6, Spot +7, Swim +11","feats":"Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 16, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('seven_headed_hydra','Seven-Headed Hydra','Seven-Headed Hydra','6 (normal); 8 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','7d10+38 (77 hp)',77,'+1','20 ft. (4 squares), swim 20 ft.','17 (–2 size, +1 Dex, +8 natural), touch 9, flat-footed 16','+7/+19','7 bites +10 melee (1d10+4)','15 ft./10 ft.','+10','+6','+4',19,12,20,2,10,9,'Listen +7, Spot +7, Swim +12','Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 17, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eight-Headed Hydra</th><th>Nine-Headed Hydra</th><th>Ten-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>8d10+43 (87 hp)</td><td>9d10+48 (97 hp)</td><td>10d10+53 (108 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, +1 Dex, +9 natural), touch 9, flat-footed 17</td><td>19 (–2 size, +1 Dex, +10 natural), touch 9, flat-footed 18</td><td>20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19</td></tr><tr><th>Base Attack/Grapple:</th><td>+8/+20</td><td>+9/+22</td><td>+10/+23</td></tr><tr><th>Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Full Attack:</th><td>8 bites +11 melee (1d10+4)</td><td>9 bites +13 melee (1d10+5)</td><td>10 bites +14 melee (1d10+5)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 18, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 19, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 20, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +11, Ref +7, Will +4</td><td>Fort +11, Ref +7, Will +5</td><td>Fort +12, Ref +8, Will +3</td></tr><tr><th>Abilities:</th><td>Str 19, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 21, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +7, Spot +8, Swim +12</td><td>Listen +8, Spot +8, Swim +13</td><td>Listen +8, Spot +9, Swim +13</td></tr><tr><th>Feats:</th><td>Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7 (normal);<br>9 (pyro- or cryo-)</td><td>8 (normal);<br>10 (pyro- or cryo-)</td><td>9 (normal);<br>11 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"7 bites +10 melee (1d10+4)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"7d10+38 (77 hp)","hit_points":77,"base_attack_grapple":"+7/+19","attack":"7 bites +10 melee (1d10+4)","full_attack":"7 bites +10 melee (1d10+4)","space_reach":"15 ft./10 ft.","saves":"Fort +10, Ref +6, Will +4","abilities":{"str":"19","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +7, Spot +7, Swim +12","feats":"Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 17, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('eight_headed_hydra','Eight-Headed Hydra','Eight-Headed Hydra','7 (normal); 9 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','8d10+43 (87 hp)',87,'+1','20 ft. (4 squares), swim 20 ft.','18 (–2 size, +1 Dex, +9 natural), touch 9, flat-footed 17','+8/+20','8 bites +11 melee (1d10+4)','15 ft./10 ft.','+11','+7','+4',19,12,20,2,10,9,'Listen +7, Spot +8, Swim +12','Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 18, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"8 bites +11 melee (1d10+4)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"8d10+43 (87 hp)","hit_points":87,"base_attack_grapple":"+8/+20","attack":"8 bites +11 melee (1d10+4)","full_attack":"8 bites +11 melee (1d10+4)","space_reach":"15 ft./10 ft.","saves":"Fort +11, Ref +7, Will +4","abilities":{"str":"19","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +7, Spot +8, Swim +12","feats":"Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 18, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('nine_headed_hydra','Nine-Headed Hydra','Nine-Headed Hydra','8 (normal); 10 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','9d10+48 (97 hp)',97,'+1','20 ft. (4 squares), swim 20 ft.','19 (–2 size, +1 Dex, +10 natural), touch 9, flat-footed 18','+9/+22','9 bites +13 melee (1d10+5)','15 ft./10 ft.','+11','+7','+5',21,12,20,2,10,9,'Listen +8, Spot +8, Swim +13','Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 19, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"9 bites +13 melee (1d10+5)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"9d10+48 (97 hp)","hit_points":97,"base_attack_grapple":"+9/+22","attack":"9 bites +13 melee (1d10+5)","full_attack":"9 bites +13 melee (1d10+5)","space_reach":"15 ft./10 ft.","saves":"Fort +11, Ref +7, Will +5","abilities":{"str":"21","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +8, Spot +8, Swim +13","feats":"Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 19, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('ten_headed_hydra','Ten-Headed Hydra','Ten-Headed Hydra','9 (normal); 11 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','10d10+53 (108 hp)',108,'+1','20 ft. (4 squares), swim 20 ft.','20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19','+10/+23','10 bites +14 melee (1d10+5)','15 ft./10 ft.','+12','+8','+3',21,12,20,2,10,9,'Listen +8, Spot +9, Swim +13','Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 20, low-light vision, scent"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Eleven-Headed Hydra</th><th>Twelve-Headed Hydra</th></tr><tr><td></td><td>Huge Magical Beast</td><td>Huge Magical Beast</td></tr><tr><th>Hit Dice:</th><td>11d10+58 (118 hp)</td><td>12d10+63 (129 hp)</td></tr><tr><th>Initiative:</th><td>+1</td><td>+1</td></tr><tr><th>Speed:</th><td>20 ft. (4 squares), swim 20 ft.</td><td>20 ft. (4 squares), swim 20 ft.</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20</td><td>22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21</td></tr><tr><th>Base Attack/Grapple:</th><td>+11/+25</td><td>+12/+26</td></tr><tr><th>Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>11 bites +16 melee (1d10+6)</td><td>12 bites +17 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Darkvision 60 ft., fast healing 21, low-light vision, scent</td><td>Darkvision 60 ft., fast healing 22, low-light vision, scent</td></tr><tr><th>Saves:</th><td>Fort +12, Ref +8, Will +5</td><td>Fort +13, Ref +9, Will +6</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td><td>Str 23, Dex 12, Con 20, Int 2, Wis 10, Cha 9</td></tr><tr><th>Skills:</th><td>Listen +9, Spot +9, Swim +14</td><td>Listen +9, Spot +10, Swim +14</td></tr><tr><th>Feats:</th><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Iron Will, Toughness, Weapon Focus (bite)</td><td>Blind-Fight, Combat Reflexes<sup>B</sup>, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)</td></tr><tr><th>Environment:</th><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td><td>Temperate marshes<br>(Pyro: Warm marshes)<br>(Cryo: Cold marshes)</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>10 (normal);<br>12 (pyro- or cryo-)</td><td>11 (normal);<br>13 (pyro- or cryo-)</td></tr><tr><th>Treasure:</th><td>1/10 coins; 50% goods; 50% items</td><td>1/10 coins; 50% goods; 50% items</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>—</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td></tr></tbody></table>

Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"10 bites +14 melee (1d10+5)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"10d10+53 (108 hp)","hit_points":108,"base_attack_grapple":"+10/+23","attack":"10 bites +14 melee (1d10+5)","full_attack":"10 bites +14 melee (1d10+5)","space_reach":"15 ft./10 ft.","saves":"Fort +12, Ref +8, Will +3","abilities":{"str":"21","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +8, Spot +9, Swim +13","feats":"Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 20, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('eleven_headed_hydra','Eleven-Headed Hydra','Eleven-Headed Hydra','10 (normal); 12 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','11d10+58 (118 hp)',118,'+1','20 ft. (4 squares), swim 20 ft.','21 (–2 size, +1 Dex, +12 natural), touch 9, flat-footed 20','+11/+25','11 bites +16 melee (1d10+6)','15 ft./10 ft.','+12','+8','+5',23,12,20,2,10,9,'Listen +9, Spot +9, Swim +14','Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 21, low-light vision, scent"}'::jsonb,'Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"11 bites +16 melee (1d10+6)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"11d10+58 (118 hp)","hit_points":118,"base_attack_grapple":"+11/+25","attack":"11 bites +16 melee (1d10+6)","full_attack":"11 bites +16 melee (1d10+6)","space_reach":"15 ft./10 ft.","saves":"Fort +12, Ref +8, Will +5","abilities":{"str":"23","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +9, Spot +9, Swim +14","feats":"Blind-Fight, Combat ReflexesB, Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 21, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('twelve_headed_hydra','Twelve-Headed Hydra','Twelve-Headed Hydra','11 (normal); 13 (pyro- or cryo-)','Huge','Magical Beast','Usually neutral','12d10+63 (129 hp)',129,'+1','20 ft. (4 squares), swim 20 ft.','22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21','+12/+26','12 bites +17 melee (2d8+6)','15 ft./10 ft.','+13','+9','+6',23,12,20,2,10,9,'Listen +9, Spot +10, Swim +14','Blind-Fight, Combat ReflexesB, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 22, low-light vision, scent"}'::jsonb,'Hydras are reptile-like monsters with multiple heads. A hydra is gray-brown to dark brown, with a light yellow or tan underbelly. The eyes are amber and the teeth are yellow-white. It is about 20 feet long and weighs about 4,000 pounds. Hydras do not speak.

### Combat

Hydras can attack with all their heads at no penalty, even if they move or charge during the round.

A hydra can be killed either by severing all its heads or by slaying its body. To sever a head, an opponent must make a successful sunder attempt with a slashing weapon. (The player should declare where the attack is aimed before making the attack roll.) Making a sunder attempt provokes an attack of opportunity unless the foe has the Improved Sunder feat. An opponent can strike at a hydra’s heads from any position in which he could strike at the hydra itself, because the hydra’s head writhe and whip about in combat. An opponent can ready an action to attempt to sunder a hydra’s head when the creature bites at him. Each of a hydra’s heads has hit points equal to the creature’s full normal hit point total, divided by its original number of heads. Losing a head deals damage to the body equal to half the head’s full normal hit points. A natural reflex seals the neck shut to prevent further blood loss. A hydra can no longer attack with a severed head but takes no other penalties.

Each time a head is severed, two new heads spring from the stump in 1d4 rounds. A hydra can never have more than twice its original number of heads at any one time, and any extra heads it gains beyond its original number wither and die within a day. To prevent a severed head from growing back into two heads, at least 5 points of fire or acid damage must be dealt to the stump (a touch attack to hit) before the new heads appear. A flaming weapon (or similar effect) deals its energy damage to the stump in the same blow in which a head is severed. Fire or acid damage from an area effect may burn multiple stumps in addition to dealing damage to the hydra’s body. A hydra does not die from losing its heads until all its heads have been cut off and the stumps seared by fire or acid.

A hydra’s body can be slain just like any other creature’s, but hydras possess fast healing (see below) and are difficult to defeat in this fashion. Any attack that is not (or cannot be) an attempt to sunder a head affects the body.

Targeted magical effects cannot sever a hydra’s heads (and thus must be directed at the body) unless they deal slashing damage and could be used to make sunder attempts.

**Fast Healing (Ex):** Each round, a hydra heals damage equal to 10 + the number of its original heads.

**Skills:** Hydras have a +2 racial bonus on Listen and Spot checks, thanks to their multiple heads.

A hydra has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

**Feats:** A hydra’s Combat Reflexes feat allows it to use all its heads for attacks of opportunity.

### Pyrohydra

Huge Magical Beast (Fire)

These reddish hydras can breathe jets of fire 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of fire damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Fire attacks cannot prevent a pyrohydra’s stump from growing new heads (since a pyrohydra has immunity to fire), but 5 points of cold damage does.

### Cryohydra

Huge Magical Beast (Cold)

These purplish hydras can breathe jets of frost 10 feet high, 10 feet wide, and 20 feet long. All heads breathe once every 1d4 rounds. Each jet deals 3d6 points of cold damage per head. A successful Reflex save halves the damage. The save DC is 10 + 1/2 hydra’s original number of heads + hydra’s Con modifier.

Cold attacks cannot prevent a cryohydra’s stump from growing new heads (since a cryohydra has immunity to cold), but 5 points of fire damage does.','{"full_attack":"12 bites +17 melee (2d8+6)","environment":"Temperate marshes (Pyro: Warm marshes) (Cryo: Cold marshes)","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"12d10+63 (129 hp)","hit_points":129,"base_attack_grapple":"+12/+26","attack":"12 bites +17 melee (2d8+6)","full_attack":"12 bites +17 melee (2d8+6)","space_reach":"15 ft./10 ft.","saves":"Fort +13, Ref +9, Will +6","abilities":{"str":"23","dex":"12","con":"20","int":"2","wis":"10","cha":"9"},"skills":"Listen +9, Spot +10, Swim +14","feats":"Blind-Fight, Combat ReflexesB, Improved Natural Attack (bite), Iron Will, Toughness, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Darkvision 60 ft., fast healing 22, low-light vision, scent"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('kolyarut','Kolyarut','Kolyarut','12','Medium','Construct (Extraplanar, Lawful)','Always lawful neutral','13d10+20 (91 hp)',91,'+1','20 ft. in banded mail (4 squares); base speed 30 ft.','27 (+1 Dex, +10 natural, +6 banded mail) touch 11, flat-footed 26','+9/+11','Vampiric touch +11 melee touch (5d6) or enervation ray +10 ranged touch (as spell) or +2 longsword +13 melee (1d8+5/19–20) or slam +11 melee (1d6+3)','5 ft./5 ft.','+6','+7','+7',14,13,null,10,17,16,'Diplomacy +5, Disguise +12, Gather Information +12, Listen +11, Search +5, Sense Motive +12, Spot +11, Survival +3 (+5 following tracks)','Alertness, Combat Casting, Great Fortitude, Lightning Reflexes, Quickened Spell-Like Ability (suggestion)','{"special_attacks":"Enervation ray, spell-like abilities, vampiric touch","special_qualities":"Construct traits, damage reduction 10/chaotic, darkvision 60 ft., fast healing 5, low-light vision, spell resistance 22"}'::jsonb,'Kolyaruts mete out punishment to those who break bargains and oaths.

Before beginning a mission against a deal-breaker, a kolyarut learns as much about the contract or oath as possible. It’s not interested in those who break deals accidentally or against their will— only those who willingly break contracts violate the principle that kolyaruts are created to uphold. If a written contract was broken, the kolyarut typically carries a copy of the contract with it.

Kolyaruts are the most talkative of the inevitables, making credible attempts at social niceties such as proper greetings before getting down to the matter at hand. They can use _disguise self_ to appear as almost any kind of humanoid—useful if they need to go undercover to catch their quarry.

#### Combat

Like all inevitables, a kolyarut is patient enough to study a target before striking. It has a good idea of the deal-breaker’s abilities and defenses before it enters battle. When it fights, it tries to get the conflict over as soon as possible, minimizing excess bloodshed and mayhem. It doesn’t let concern for innocents delay or endanger its mission, however.

A kolyarut’s favorite tactic is to use _invisibility_ or _disguise self_ to sneak close, then eliminate the quarry with its vampiric touch ability before it can react. A kolyarut has no compunctions about using its vampiric touch ability on allies to increase its own power, if doing so helps it complete its mission.

A kolyarut’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Enervation Ray (Su):** A kolyarut can fire a black enervation ray at targets within 200 feet. The effect is identical with the _enervation_ spell (caster level 13th).

**Spell-Like Abilities:** At will—_discern lies_ (DC 17)_, disguise self, fear_ (DC 17)_, hold person_ (DC 16)_, invisibility, locate creature, suggestion_ (DC 16); 1/day—_hold monster_ (DC 17)_, mark of justice;_ 1/week— _geas/quest._ Caster level 13th. The save DCs are Charisma-based.

**Vampiric Touch (Su):** As a melee touch attack, a kolyarut can steal life force from its foe, as the _vampiric touch_ spell (caster level 13th).

**Skills:** A kolyarut has a +4 racial bonus on Disguise, Gather Information, and Sense Motive checks.','{"full_attack":"Vampiric touch +11/+6 melee touch (5d6) or enervation ray +10 ranged touch (as spell) or +2 longsword +13/+8 melee (1d8+5/19–20) or slam +11/+6 melee (1d6+3)","environment":"A lawful-aligned plane","organization":"Solitary","treasure":"None","advancement":"14–22 HD (Medium); 23–39 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"13d10+20 (91 hp)","hit_points":91,"base_attack_grapple":"+9/+11","attack":"Vampiric touch +11 melee touch (5d6) or enervation ray +10 ranged touch (as spell) or +2 longsword +13 melee (1d8+5/19–20) or slam +11 melee (1d6+3)","full_attack":"Vampiric touch +11/+6 melee touch (5d6) or enervation ray +10 ranged touch (as spell) or +2 longsword +13/+8 melee (1d8+5/19–20) or slam +11/+6 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +7, Will +7","abilities":{"str":"14","dex":"13","con":null,"int":"10","wis":"17","cha":"16"},"skills":"Diplomacy +5, Disguise +12, Gather Information +12, Listen +11, Search +5, Sense Motive +12, Spot +11, Survival +3 (+5 following tracks)","feats":"Alertness, Combat Casting, Great Fortitude, Lightning Reflexes, Quickened Spell-Like Ability (suggestion)","special_attacks":"Enervation ray, spell-like abilities, vampiric touch","special_qualities":"Construct traits, damage reduction 10/chaotic, darkvision 60 ft., fast healing 5, low-light vision, spell resistance 22"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('marut','Marut','Marut','15','Large','Construct (Extraplanar, Lawful)','Always lawful neutral','15d10+30 (112 hp)',112,'+1','30 ft. in full plate armor (6 squares); base speed 40 ft.','34 (–1 size, +1 Dex, +16 natural, +8 full plate armor), touch 10, flat-footed 33','+11/+27','Slam +22 melee (2d6+12 plus 3d6 sonic or 3d6 electricity)','10 ft./10 ft.','+7','+6','+8',35,13,null,12,17,18,'Concentration +13, Diplomacy +6, Knowledge (religion) +10, Listen +16, Search +10, Sense Motive +12, Spot +16, Survival +3 (+5 following tracks)','Ability Focus (fists), Awesome Blow, Combat Casting, Great Fortitude, Improved Bull Rush, Power Attack','{"special_attacks":"Fists of thunder and lightning, spell-like abilities","special_qualities":"Construct traits, damage reduction 15/chaotic, darkvision 60 ft., fast healing 10, low-light vision, spell resistance 25"}'::jsonb,'Maruts confront those who would try to deny the grave itself.

Any who use unnatural means to extend their life span could be targeted by a marut. Those who take extraordinary measures to cheat death in some other way might be labeled transgressors as well. Those who use magic to reverse death aren’t worthy of a marut’s attention unless they do so repeatedly or on a massive scale.

When a marut has identified its target, it walks surely and implacably toward the foe, never resting.

#### Combat

Once it has found its target, a marut brings it the death it has been trying to avoid. Those who defile death through necromancy may instead receive a _geas_ and/or _mark of justice_ to enforce proper respect. It typically uses _wall of force_ to shut off any escape routes, then opens up with _chain lightning_ while it closes to melee range. Once there, it strikes with its massive fists, using _circle of death_ if beset by numbers of defenders. It hits spellcasting opponents with repeated uses of _greater dispel magic,_ and it uses _dimension door_ and _locate creature_ to track down foes who flee.

A marut’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Fists of Thunder and Lightning (Su):** A marut’s left fist delivers a loud thunderclap whenever it hits something, dealing an extra 3d6 points of sonic damage and causing the target to be deafened for 2d6 rounds (Fortitude DC 31 negates the deafness). Its right fist delivers a shock for an extra 3d6 points of electricity damage, and the flash of lightning causes the target to be blinded for 2d6 rounds (Fortitude DC 31 negates the blindness). The save DCs are Strength-based and include the marut’s Ability Focus feat.

**Spell-Like Abilities:** At will—_air walk, dimension door, fear_ (DC 18)_, greater command_ (DC 19)_, greater dispel magic, mass inflict light wounds_ (DC 19), _locate creature, true seeing;_ 1/day—_chain lightning_ (DC 20)_, circle of death_ (DC 20)_, mark of justice, wall of force;_ 1/week— _earthquake_ (DC 22)_, geas/quest, plane shift_ (DC 21). Caster level 14th. The save DCs are Charisma-based.

**Skills:** A marut has a +4 racial bonus on Concentration, Listen, and Spot checks.','{"full_attack":"2 slams +22 melee (2d6+12 plus 3d6 sonic or 3d6 electricity)","environment":"A lawful-aligned plane","organization":"Solitary","treasure":"None","advancement":"16–28 HD (Large); 29–45 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"15d10+30 (112 hp)","hit_points":112,"base_attack_grapple":"+11/+27","attack":"Slam +22 melee (2d6+12 plus 3d6 sonic or 3d6 electricity)","full_attack":"2 slams +22 melee (2d6+12 plus 3d6 sonic or 3d6 electricity)","space_reach":"10 ft./10 ft.","saves":"Fort +7, Ref +6, Will +8","abilities":{"str":"35","dex":"13","con":null,"int":"12","wis":"17","cha":"18"},"skills":"Concentration +13, Diplomacy +6, Knowledge (religion) +10, Listen +16, Search +10, Sense Motive +12, Spot +16, Survival +3 (+5 following tracks)","feats":"Ability Focus (fists), Awesome Blow, Combat Casting, Great Fortitude, Improved Bull Rush, Power Attack","special_attacks":"Fists of thunder and lightning, spell-like abilities","special_qualities":"Construct traits, damage reduction 15/chaotic, darkvision 60 ft., fast healing 10, low-light vision, spell resistance 25"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('zelekhut','Zelekhut','Zelekhut','9','Large','Construct (Extraplanar, Lawful)','Always lawful neutral','8d10+30 (74 hp)',74,'+0','35 ft. in plate barding (7 squares), fly 40 ft. (average) in plate barding (8 squares); base speed 50 ft., fly 60 ft. (average)','27 (–1 size, +10 natural, +8 plate barding), touch 9, flat-footed 27','+6/+15','Spiked chain +10 melee (2d6+5 plus 1d6 electricity)','10 ft./10 ft.','+4','+2','+5',21,11,null,10,17,15,'Diplomacy +4, Listen +9, Search +9, Sense Motive +12, Spot +9, Survival +3 (+5 following tracks)','Great Fortitude, Ride-By Attack, Spirited Charge','{"special_attacks":"Spell-like abilities","special_qualities":"Construct traits, damage reduction 10/chaotic, darkvision 60 ft., fast healing 5, low-light vision, spell resistance 20"}'::jsonb,'Zelekhuts are charged with hunting down those who would deny justice—especially those who flee to escape punishment. Expert trackers, they use a combination of natural skill and magic to find fugitives wherever they may hide.

A zelekhut may initially appear rather non-threatening—but when it is about to enter combat, it can cause two spiked chains to spring forth from its forearms as a free action. In similar fashion, it can cause a pair of golden metallic wings to emerge from its back. Retracting the chains or the wings is also a free action.

#### Combat

Once it has found its fugitive, a zelekhut uses its speed and its spell-like abilities to cover the most likely escape routes. Then it immobilizes any defenders while attempting to protect any innocent bystanders. Finally, it apprehends the fugitive with its spiked chains, tripping or disarming the foe as needed.

A zelekhut’s natural weapons, as well as any weapons it wields, are treated as lawful-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** At will—_clairaudience/clairvoyance, dimensional anchor, dispel magic, fear_ (DC 16)_, hold person_ (DC 15)_, locate creature, true seeing;_ 3/day—_hold monster_ (DC 17)_, mark of justice_; 1/week— _lesser geas_ (DC 16). Caster level 8th. The save DCs are Charisma-based.

**Skills:** A zelekhut has a +4 racial bonus on Search and Sense Motive checks.

**Feats:** Due to its centaur-like construction, a zelekhut qualifies for feats as if it had the Mounted Combat feat.','{"full_attack":"2 spiked chains +10 melee (2d6+5 plus 1d6 electricity)","environment":"A lawful-aligned plane","organization":"Solitary","treasure":"None","advancement":"9–16 HD (Large); 17–24 HD (Huge)","level_adjustment":"+7","statblock":{"hit_dice":"8d10+30 (74 hp)","hit_points":74,"base_attack_grapple":"+6/+15","attack":"Spiked chain +10 melee (2d6+5 plus 1d6 electricity)","full_attack":"2 spiked chains +10 melee (2d6+5 plus 1d6 electricity)","space_reach":"10 ft./10 ft.","saves":"Fort +4, Ref +2, Will +5","abilities":{"str":"21","dex":"11","con":null,"int":"10","wis":"17","cha":"15"},"skills":"Diplomacy +4, Listen +9, Search +9, Sense Motive +12, Spot +9, Survival +3 (+5 following tracks)","feats":"Great Fortitude, Ride-By Attack, Spirited Charge","special_attacks":"Spell-like abilities","special_qualities":"Construct traits, damage reduction 10/chaotic, darkvision 60 ft., fast healing 5, low-light vision, spell resistance 20"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('invisible_stalker','Invisible Stalker','Invisible Stalker','7','Large','Elemental (Air, Extraplanar)','Usually neutral','8d8+16 (52 hp)',52,'+8','30 ft. (6 squares), fly 30 ft. (perfect)','17 (–1 size, +4 Dex, +4 natural), touch 13, flat-footed 13','+6/+14','Slam +10 melee (2d6+4)','10 ft./10 ft.','+4','+10','+4',18,19,14,14,15,11,'Listen +13, Move Silently +15, Search +13, Spot +13, Survival +2 (+4 following tracks)','Combat Reflexes, Improved Initiative, Weapon Focus (slam)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., elemental traits, natural invisibility, improved tracking"}'::jsonb,'Invisible stalkers are creatures native to the Elemental Plane of Air. They sometimes serve wizards and sorcerers, who summon them to perform specific tasks.

A summoned invisible stalker undertakes whatever task the summoner commands, even if the task sends it hundreds or thousands of miles away. The creature follows a command until the task is completed and obeys only the summoner. However, it resents protracted missions or complex tasks and seeks to pervert its instructions accordingly.

Invisible stalkers have an amorphous form. A _see invisibility_ spell shows only a dim outline of a cloud, while a _true seeing_ spell reveals a roiling cloud of vapor.

These creatures speak only Auran but can understand Common.

### Combat

An invisible stalker attacks by using the air itself as a weapon. It creates a sudden, intense blast of wind that pounds a single target on the same plane as the creature.

An invisible stalker can be killed only when it is on the Elemental Plane of Air. When performing a task elsewhere, it automatically returns to its home plane when it takes damage sufficient to destroy it.

**Natural Invisibility (Su):** This ability is constant, allowing a stalker to remain invisible even when attacking. This ability is inherent and not subject to the _invisibility purge_ spell.

**Improved Tracking (Ex):** An invisible stalker is a consummate tracker and makes Spot checks instead of the usual Survival checks to trace a creature’s passage.','{"full_attack":"2 slams +10 melee (2d6+4)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"9–12 HD (Large); 13–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"8d8+16 (52 hp)","hit_points":52,"base_attack_grapple":"+6/+14","attack":"Slam +10 melee (2d6+4)","full_attack":"2 slams +10 melee (2d6+4)","space_reach":"10 ft./10 ft.","saves":"Fort +4, Ref +10, Will +4","abilities":{"str":"18","dex":"19","con":"14","int":"14","wis":"15","cha":"11"},"skills":"Listen +13, Move Silently +15, Search +13, Spot +13, Survival +2 (+4 following tracks)","feats":"Combat Reflexes, Improved Initiative, Weapon Focus (slam)","special_attacks":"—","special_qualities":"Darkvision 60 ft., elemental traits, natural invisibility, improved tracking"},"source_file":"monsters-h-i.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-h-i.html',true),
('kobold','Kobold','Kobold, 1st-Level Warrior','1/4','Small','Humanoid (Reptilian)','Usually lawful evil','1d8 (4 hp)',4,'+1','30 ft. (6 squares)','15 (+1 size, +1 Dex, +1 natural, +2 leather), touch 12, flat-footed 14','+1/–4','Spear +1 melee (1d6–1/x3) or sling +3 ranged (1d3)','5 ft./5 ft.','+2','+1','–1',9,13,10,10,9,8,'Craft (trapmaking) +2, Hide +6, Listen +2, Move Silently +2, Profession (miner) +2, Search +2, Spot +2','Alertness','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., light sensitivity"}'::jsonb,'Kobolds are short, reptilian humanoids with cowardly and sadistic tendencies.

A kobold’s scaly skin ranges from dark rusty brown to a rusty black color. It has glowing red eyes. Its tail is nonprehensile. Kobolds wear ragged clothing, favoring red and orange. A kobold is 2 to 2-1/2 feet tall and weighs 35 to 45 pounds. Kobolds speak Draconic with a voice that sounds like that of a yapping dog.

### Combat

Kobolds like to attack with overwhelming odds—at least two to one—or trickery; should the odds fall below this threshold, they usually flee. However, they attack gnomes on sight if their numbers are equal.

They begin a fight by slinging bullets, closing only when they can see that their foes have been weakened. Whenever they can, kobolds set up ambushes near trapped areas.

**Light Sensitivity (Ex):** Kobolds are dazzled in bright sunlight or within the radius of a _daylight_ spell.

**Skills:** Kobolds have a +2 racial bonus on Craft (trapmaking), Profession (miner), and Search checks.

The kobold warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

**Challenge Rating:** Kobolds with levels in NPC classes have a CR equal to their character level –3.

### Kobold Characters

Kobold characters possess the following racial traits.

— –4 Strength, +2 Dexterity, –2 Constitution.

—Small size: +1 bonus to Armor Class, +1 bonus on attack rolls, +4 bonus on Hide checks, –4 penalty on grapple checks, lifting and carrying limits 3/4 those of Medium characters.

—A kobold’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Racial Skills: A kobold character has a +2 racial bonus on Craft (trapmaking), Profession (miner), and Search checks.

—Racial Feats: A kobold character gains feats according to its character class.

— +1 natural armor bonus.

—Special Qualities (see above): Light sensitivity.

—Automatic Languages: Draconic. Bonus Languages: Common, Undercommon.

—Favored Class: Sorcerer.

—Level adjustment +0.','{"full_attack":"Spear +1 melee (1d6–1/x3) or sling +3 ranged (1d3)","environment":"Temperate forests","organization":"Gang (4–9), band (10–100 plus 100% noncombatants plus 1 3rd-level sergeant per 20 adults and 1 leader of 4th–6th level), warband (10–24 plus 2–4 dire weasels), tribe (40–400 plus 1 3rd-level sergeant per 20 adults, 1 or 2 lieutenants of 4th or 5th level, 1 leader of 6th–8th level, and 5–8 dire weasels)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8 (4 hp)","hit_points":4,"base_attack_grapple":"+1/–4","attack":"Spear +1 melee (1d6–1/x3) or sling +3 ranged (1d3)","full_attack":"Spear +1 melee (1d6–1/x3) or sling +3 ranged (1d3)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +1, Will –1","abilities":{"str":"9","dex":"13","con":"10","int":"10","wis":"9","cha":"8"},"skills":"Craft (trapmaking) +2, Hide +6, Listen +2, Move Silently +2, Profession (miner) +2, Search +2, Spot +2","feats":"Alertness","special_attacks":"—","special_qualities":"Darkvision 60 ft., light sensitivity"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('kraken','Kraken','Kraken','12','Gargantuan','Magical Beast (Aquatic)','Usually neutral evil','20d10+180 (290 hp)',290,'+4','Swim 20 ft. (4 squares)','20 (–4 size, +14 natural), touch 6, flat-footed 20','+20/+44','Tentacle +28 melee (2d8+12/19–20)','20 ft./15 ft. (60 ft. with tentacle, 30 ft. with arm)','+21','+12','+13',34,10,29,21,20,20,'Concentration +21, Diplomacy +7, Hide +0, Intimidate +16, Knowledge (geography) +17, Knowledge (nature) +16, Listen +30, Search +28, Sense Motive +17, Spot +30, Survival +5 (+7 following tracks), Swim +20, Use Magic Device +16','Alertness, Blind-Fight, Combat Expertise, Improved Critical (tentacle), Improved Initiative, Improved Trip, Iron Will','{"special_attacks":"Improved grab, constrict 2d8+12 or 1d6+6","special_qualities":"Darkvision 60 ft., ink cloud, jet, low-light vision, spell-like abilities"}'::jsonb,'Six of the beast’s tentacles are shorter arms about 30 feet long; the remaining two are nearly 60 feet long and covered with barbs. Its beaklike mouth is located where the tentacles meet the lower portion of its body.

Krakens speak Common and Aquan.

### Combat

Krakens strike their opponents with their barbed tentacles, then grab and crush with their arms or drag victims into their huge jaws. An opponent can make sunder attempts against a kraken’s tentacles or arms as if they were weapons. A kraken’s tentacles have 20 hit points, and its arms have 10 hit points. If a kraken is currently grappling a target with one tentacle or arm, it usually uses another limb to make its attack of opportunity against the sunder attempt. Severing a kraken’s tentacle or arm deals damage to the kraken equal to half the limb’s full normal hit points. A kraken usually withdraws from combat if it loses both tentacles or three of its arms. A kraken regrows severed limbs in 1d10+10 days.

**Improved Grab (Ex):** To use this ability, the kraken must hit with an arm or tentacle attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Constrict (Ex):** A kraken deals automatic arm or tentacle damage with a successful grapple check.

**Jet (Ex):** A kraken can jet backward once per round as a full-round action, at a speed of 280 feet. It must move in a straight line, but does not provoke attacks of opportunity while jetting.

**Ink Cloud (Ex):** A kraken can emit a cloud of jet-black ink in an 80-foot spread once per minute as a free action. The cloud provides total concealment, which the kraken normally uses to escape a fight that is going badly. Creatures within the cloud are considered to be in darkness.

**Spell-Like Abilities:** 1/day—_control weather, control winds, dominate animal_ (DC 18), _resist energy._ Caster level 9th. The save DC is Charisma-based.

**Skills:** A kraken has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 tentacles +28 melee (2d8+12/19–20) and 6 arms +23 melee (1d6+6) and bite +23 melee (4d6+6)","environment":"Temperate aquatic","organization":"Solitary","treasure":"Triple standard","advancement":"21–32 HD (Gargantuan); 33–60 HD (Colossal)","level_adjustment":"—","statblock":{"hit_dice":"20d10+180 (290 hp)","hit_points":290,"base_attack_grapple":"+20/+44","attack":"Tentacle +28 melee (2d8+12/19–20)","full_attack":"2 tentacles +28 melee (2d8+12/19–20) and 6 arms +23 melee (1d6+6) and bite +23 melee (4d6+6)","space_reach":"20 ft./15 ft. (60 ft. with tentacle, 30 ft. with arm)","saves":"Fort +21, Ref +12, Will +13","abilities":{"str":"34","dex":"10","con":"29","int":"21","wis":"20","cha":"20"},"skills":"Concentration +21, Diplomacy +7, Hide +0, Intimidate +16, Knowledge (geography) +17, Knowledge (nature) +16, Listen +30, Search +28, Sense Motive +17, Spot +30, Survival +5 (+7 following tracks), Swim +20, Use Magic Device +16","feats":"Alertness, Blind-Fight, Combat Expertise, Improved Critical (tentacle), Improved Initiative, Improved Trip, Iron Will","special_attacks":"Improved grab, constrict 2d8+12 or 1d6+6","special_qualities":"Darkvision 60 ft., ink cloud, jet, low-light vision, spell-like abilities"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('krenshar','Krenshar','Krenshar','1','Medium','Magical Beast','Usually neutral','2d10 (11 hp)',11,'+2','40 ft. (8 squares)','15 (+2 Dex, +3 natural), touch 12, flat-footed 13','+2/+2','Bite +2 melee (1d6)','5 ft./5 ft.','+3','+5','+1',11,14,11,6,12,13,'Hide +4, Jump +9, Listen +3, Move Silently +6','Multiattack, TrackB','{"special_attacks":"Scare","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'The krenshar is a strange, catlike carnivore with extremely flexible skin on its head. A typical krenshar measures 4 or 5 feet in length with a long, narrow head. It weighs about 175 pounds.

### Combat

Krenshars use solitary scouts to drive prey into the waiting clutches of the pride. The scout appears from hiding, uses its scare ability, then chases the fleeing target to join the attack.

**Scare (Ex or Su):** As a standard action, a krenshar can pull the skin back from its head, revealing the musculature and bony structures of its skull. This alone is usually sufficient to scare away foes (treat as a Bluff check with a +3 bonus).

Combining this scare ability with a loud screech produces an unsettling effect that works like a _scare_ spell from a 3rd-level caster (Will DC 13 partial). A creature that successfully saves cannot be affected again by the same krenshar’s scare ability for 24 hours. The shriek does not affect other krenshars. This is a supernatural, sonic mind-affecting fear effect. The save DC is Charisma-based.

**Skills:** Krenshars have a +4 racial bonus on Jump and Move Silently checks.','{"full_attack":"Bite +2 melee (1d6) and 2 claws +0 melee (1d4)","environment":"Temperate forests","organization":"Solitary, pair, or pride (6–10)","treasure":"None","advancement":"3–4 HD (Medium); 5–8 HD (Large)","level_adjustment":"+2","statblock":{"hit_dice":"2d10 (11 hp)","hit_points":11,"base_attack_grapple":"+2/+2","attack":"Bite +2 melee (1d6)","full_attack":"Bite +2 melee (1d6) and 2 claws +0 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +5, Will +1","abilities":{"str":"11","dex":"14","con":"11","int":"6","wis":"12","cha":"13"},"skills":"Hide +4, Jump +9, Listen +3, Move Silently +6","feats":"Multiattack, TrackB","special_attacks":"Scare","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('lamia','Lamia','Lamia','6','Large','Magical Beast','Usually chaotic evil','9d10+9 (58 hp)',58,'+2','60 ft. (12 squares)','18 (–1 size, +2 Dex, +7 natural), touch 11, flat-footed 16','+9/+17','Touch +12 melee (1d4 Wisdom drain) or dagger +12 melee (1d6+4/19–20) or claw +12 melee (1d4+4)','10 ft./5 ft.','+7','+8','+7',18,15,12,13,15,12,'Bluff +14, Concentration +10, Diplomacy +3, Disguise +1 (+3 acting), Hide +11, Intimidate +3, Spot +11','Dodge, Iron Will, Mobility, Spring Attack','{"special_attacks":"Spell-like abilities, Wisdom drain","special_qualities":"Darkvision 60 ft., low-light vision"}'::jsonb,'A typical lamia is about 8 feet long and weighs about 700 pounds.

### Combat

Though a lamia is powerful and dangerous in close combat, it has no stomach for a fair fight. It uses its illusion abilities to lure heroes into perilous situations, and then uses its Spring Attack feat to bound out of the shadows and drain Wisdom from its opponents. When it has sapped the will of its victim, it uses its enchantment abilities to beguile and ensnare the unfortunate soul. A lamia forced into physical combat attacks with a dagger in one of its human hands and a pair of lion-like claws.

**Spell-Like Abilities:** At will—_disguise self, ventriloquism_; 3/day—_charm monster_ (DC 15), _major image_ (DC 14), _mirror image, suggestion_ (DC 14); 1/day—_deep slumber_ (DC 14). Caster level 9th. The save DCs are Charisma-based.

**Wisdom Drain (Su):** A lamia drains 1d4 points of Wisdom each time it hits with its melee touch attack. (Unlike with other kinds of ability drain attacks, a lamia does not heal any damage when it uses its Wisdom drain.) Lamias try to use this power early in an encounter to make foes more susceptible to _charm monster_ and _suggestion._

**Skills:** Lamias have a +4 racial bonus on Bluff and Hide checks.','{"full_attack":"Touch +12 melee (1d4 Wisdom drain); or dagger +12/+7 melee (1d6+4/19–20) and 2 claws +7 melee (1d4+2)","environment":"Temperate deserts","organization":"Solitary, pair, or gang (3–4)","treasure":"Standard","advancement":"10–13 HD (Large); 14–27 HD (Huge)","level_adjustment":"+4","statblock":{"hit_dice":"9d10+9 (58 hp)","hit_points":58,"base_attack_grapple":"+9/+17","attack":"Touch +12 melee (1d4 Wisdom drain) or dagger +12 melee (1d6+4/19–20) or claw +12 melee (1d4+4)","full_attack":"Touch +12 melee (1d4 Wisdom drain); or dagger +12/+7 melee (1d6+4/19–20) and 2 claws +7 melee (1d4+2)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +8, Will +7","abilities":{"str":"18","dex":"15","con":"12","int":"13","wis":"15","cha":"12"},"skills":"Bluff +14, Concentration +10, Diplomacy +3, Disguise +1 (+3 acting), Hide +11, Intimidate +3, Spot +11","feats":"Dodge, Iron Will, Mobility, Spring Attack","special_attacks":"Spell-like abilities, Wisdom drain","special_qualities":"Darkvision 60 ft., low-light vision"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('lammasu','Lammasu','Lammasu','8','Large','Magical Beast','Always lawful good','7d10+21 (59 hp)',59,'+1','30 ft. (6 squares), fly 60 ft.(average)','20 (–1 size, +1 Dex, +10 natural), touch 10, flat-footed 19','+7/+17','Claw +12 melee (1d6+6)','10 ft./5 ft.','+8','+8','+7',23,12,17,16,17,14,'Concentration +13, Diplomacy +4, Knowledge (arcana) +13, Listen +13, Sense Motive +13, Spot +15','Blind-Fight, Iron Will, Lightning Reflexes','{"special_attacks":"Pounce, rake 1d6+3, spells","special_qualities":"Darkvision 60 ft., low-light vision, magic circle against evil, spell-like abilities"}'::jsonb,'A typical lammasu is about 8 feet long and weighs about 500 pounds. Lammasus speak Common, Draconic, and Celestial.

### Combat

A lammasu attacks with spells or its razor-sharp claws. It almost always enters combat if it observes a good creature being threatened by evil.

**Spells:** A lammasu casts spells as a 7th-level cleric, and can choose spells from the cleric spell list, plus any two of the following domains: Good, Healing, Knowledge, or Law.

_Typical Cleric Spells Prepared_ (6/6/5/4/2; save DC 13 + spell level): 0—_detect magic, guidance_ (2), _light, read magic, resistance;_ 1st—_bless_ (2), _detect evil, divine favor, entropic shield, protection from evil_\*; 2nd— _aid_\*, _bear’s endurance, bull’s strength, lesser restoration, resist energy;_ 3rd—_daylight, dispel magic, magic circle against evil_\*, _remove curse;_ 4th—_holy smite\*, neutralize poison._

\*Domain spell. Domains: Good and Healing.

**Magic Circle against Evil (Su):** A lammasu radiates a continuous magic circle against evil that affects a 20-foot radius.

**Spell-Like Abilities:** 2/day—_greater invisibility_ (self only); 1/day—_dimension door_. Caster level 7th.

**Pounce (Ex):** If a lammasu charges a foe, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +12 melee, damage 1d6+3.

**Skills:** Lammasus have a +2 racial bonus on Spot checks.

### Golden Protector (Celestial Half-Dragon Lammasu)

Child of a celestial lammasu and a gold dragon, the golden protector has migrated to the Material Plane to more actively combat evil.

#### Combat

The golden protector’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Breath Weapon (Su):** 30-foot cone, 1/day, damage 6d8 fire, Reflex DC 21 half.

**Smite Evil (Su):** Once per day a golden protector can make a normal melee attack to deal an extra 10 points of damage against an evil opponent.

_Typical Cleric Spells Prepared_ (6/7/5/4/3; save DC 15 + spell level): 0—_detect magic, guidance_ (2), _light, read magic, resistance;_ 1st—_bless_ (2), _detect evil, divine favor (2), entropic shield, protection from evil_\*; 2nd—_aid_\*, _bear’s endurance, bull’s strength, lesser restoration, resist energy;_ 3rd—_daylight, dispel magic, magic circle against evil_\*, _remove curse;_ 4th—_dismissal, holy smite\*, neutralize poison._

\*Domain spell. Domains: Good and Healing.

**Rake (Ex):** Attack bonus +19 melee, damage 1d6+4.

_Possessions: Bracers of armor +2, ring of protection_ +1. (Different golden protectors may have different possessions.)','{"full_attack":"2 claws +12 melee (1d6+6)","environment":"Temperate deserts","organization":"Solitary","treasure":"Standard","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"+5","statblock":{"hit_dice":"7d10+21 (59 hp)","hit_points":59,"base_attack_grapple":"+7/+17","attack":"Claw +12 melee (1d6+6)","full_attack":"2 claws +12 melee (1d6+6)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +8, Will +7","abilities":{"str":"23","dex":"12","con":"17","int":"16","wis":"17","cha":"14"},"skills":"Concentration +13, Diplomacy +4, Knowledge (arcana) +13, Listen +13, Sense Motive +13, Spot +15","feats":"Blind-Fight, Iron Will, Lightning Reflexes","special_attacks":"Pounce, rake 1d6+3, spells","special_qualities":"Darkvision 60 ft., low-light vision, magic circle against evil, spell-like abilities"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('golden_protector_celestial_half_dragon_lammasu','Golden Protector (Celestial Half-Dragon Lammasu)','Golden Protector (Celestial Half-Dragon Lammasu)','13','Large','Dragon','Always lawful good','10d12+60 (125 hp)',125,'+3','30 ft. (6 squares), fly 60 ft.(average)','29 (–1 size, +3 Dex, +14 natural, +2 bracers of armor +2, +1 ring of protection +1), touch 13, flat-footed 26','+10/+23','Claw +19 melee (1d6+9)','10 ft./5 ft.','+13','+12','+10',28,17,22,18,20,18,'Concentration +19, Diplomacy +19, Knowledge (arcana) +17, Knowledge (the planes) +17, Listen +18, Search +17, Sense Motive +18, Spellcraft +19, Spot +20, Survival +18 (+20 other planes and tracking)','Blind-Fight, Iron Will, Lightning Reflexes, Weapon Focus (claw)','{"special_attacks":"Breath weapon, pounce, smite evil, rake 1d6+4, spells","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., immunity to fire, sleep, and paralysis, low-light vision, magic circle against evil, resistance to acid 10, cold 10, and electricity 10, spell-like abilities, spell resistance 15"}'::jsonb,'A typical lammasu is about 8 feet long and weighs about 500 pounds. Lammasus speak Common, Draconic, and Celestial.

### Combat

A lammasu attacks with spells or its razor-sharp claws. It almost always enters combat if it observes a good creature being threatened by evil.

**Spells:** A lammasu casts spells as a 7th-level cleric, and can choose spells from the cleric spell list, plus any two of the following domains: Good, Healing, Knowledge, or Law.

_Typical Cleric Spells Prepared_ (6/6/5/4/2; save DC 13 + spell level): 0—_detect magic, guidance_ (2), _light, read magic, resistance;_ 1st—_bless_ (2), _detect evil, divine favor, entropic shield, protection from evil_\*; 2nd— _aid_\*, _bear’s endurance, bull’s strength, lesser restoration, resist energy;_ 3rd—_daylight, dispel magic, magic circle against evil_\*, _remove curse;_ 4th—_holy smite\*, neutralize poison._

\*Domain spell. Domains: Good and Healing.

**Magic Circle against Evil (Su):** A lammasu radiates a continuous magic circle against evil that affects a 20-foot radius.

**Spell-Like Abilities:** 2/day—_greater invisibility_ (self only); 1/day—_dimension door_. Caster level 7th.

**Pounce (Ex):** If a lammasu charges a foe, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +12 melee, damage 1d6+3.

**Skills:** Lammasus have a +2 racial bonus on Spot checks.

### Golden Protector (Celestial Half-Dragon Lammasu)

Child of a celestial lammasu and a gold dragon, the golden protector has migrated to the Material Plane to more actively combat evil.

#### Combat

The golden protector’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Breath Weapon (Su):** 30-foot cone, 1/day, damage 6d8 fire, Reflex DC 21 half.

**Smite Evil (Su):** Once per day a golden protector can make a normal melee attack to deal an extra 10 points of damage against an evil opponent.

_Typical Cleric Spells Prepared_ (6/7/5/4/3; save DC 15 + spell level): 0—_detect magic, guidance_ (2), _light, read magic, resistance;_ 1st—_bless_ (2), _detect evil, divine favor (2), entropic shield, protection from evil_\*; 2nd—_aid_\*, _bear’s endurance, bull’s strength, lesser restoration, resist energy;_ 3rd—_daylight, dispel magic, magic circle against evil_\*, _remove curse;_ 4th—_dismissal, holy smite\*, neutralize poison._

\*Domain spell. Domains: Good and Healing.

**Rake (Ex):** Attack bonus +19 melee, damage 1d6+4.

_Possessions: Bracers of armor +2, ring of protection_ +1. (Different golden protectors may have different possessions.)','{"full_attack":"Claw +19 melee (1d6+9) and bite +13 melee (1d8+4)","environment":"A lawful good plane","organization":"Solitary","treasure":"Standard","advancement":"11–30 HD (Huge)","level_adjustment":"+10","statblock":{"hit_dice":"10d12+60 (125 hp)","hit_points":125,"base_attack_grapple":"+10/+23","attack":"Claw +19 melee (1d6+9)","full_attack":"Claw +19 melee (1d6+9) and bite +13 melee (1d8+4)","space_reach":"10 ft./5 ft.","saves":"Fort +13, Ref +12, Will +10","abilities":{"str":"28","dex":"17","con":"22","int":"18","wis":"20","cha":"18"},"skills":"Concentration +19, Diplomacy +19, Knowledge (arcana) +17, Knowledge (the planes) +17, Listen +18, Search +17, Sense Motive +18, Spellcraft +19, Spot +20, Survival +18 (+20 other planes and tracking)","feats":"Blind-Fight, Iron Will, Lightning Reflexes, Weapon Focus (claw)","special_attacks":"Breath weapon, pounce, smite evil, rake 1d6+4, spells","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., immunity to fire, sleep, and paralysis, low-light vision, magic circle against evil, resistance to acid 10, cold 10, and electricity 10, spell-like abilities, spell resistance 15"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('leonal','Leonal','Leonal','12','Medium','Outsider (Extraplanar, Good)','Always neutral good','12d8+60 (114 hp)',114,'+3','60 ft. (12 squares)','27 (+3 Dex, +14 natural)','+12/+20','Claw +20 melee (1d6+8)','5 ft./5 ft.','+13','+11','+10',27,17,20,14,14,15,'Balance +22, Concentration +12, Diplomacy +4, Hide +22, Intimidate +10, Jump +35, Knowledge (any) +17, Listen +17, Move Silently +22, Sense Motive +17, Spot +17, Survival +17','Ability Focus (roar), Dodge, Mobility, Spring Attack, Track','{"special_attacks":"Roar, pounce, improved grab, rake 1d6+8, spell-like abilities","special_qualities":"Damage reduction 10/evil and silver, darkvision 60 ft., immunity to electricity and petrification, lay on hands, lowlight vision, protective aura, resistance to cold 10 and sonic 10, speak with animals, spell resistance 28"}'::jsonb,'### Combat

Leonals like their battles as straightforward as can be. They begin with a roar to put their foes off balance, then follow up with a frenzy of claw and bite attacks. They closely coordinate with others in their pride, watching one another’s flanks and setting up devastating attacks.

A leonal’s natural weapons, as well as any weapons it wields, are treated as good-aligned for the purpose of overcoming damage reduction.

**Roar (Su):** A leonal can roar up to three times per day. Each roar releases a blast in a 60-foot cone that duplicates the effects of a _holy word_ spell and deals an extra 2d6 points of sonic damage (Fortitude DC 20 negates). The save DC is Charisma-based.

**Pounce (Ex):** If a leonal charges a foe, it can make a full attack, including two rake attacks.

**Improved Grab (Ex):** To use this ability, a leonal must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Rake (Ex):** Attack bonus +20 melee, damage 1d6+8.

**Spell-Like Abilities:** At will—_detect thoughts, fireball_ (DC 15), _hold monster_ (DC 17)_, polymorph, wall of force;_ 3/day—_cure critical wounds_ (DC 16)_, neutralize poison, remove disease;_ 1/day—_heal_ (DC 18). Caster level 10th. The save DCs are Charisma-based.

**Lay on Hands (Su):** As the paladin class feature, except that each day, a leonal can heal an amount of damage equal to its full normal hit points.

**Protective Aura (Su):** Against attacks made or effects created by evil creatures, this ability provides a +4 deflection bonus to AC and a +4 resistance bonus on saving throws to anyone within 20 feet of the leonal. Otherwise, it functions as a _magic circle against evil_ effect and a _lesser globe of invulnerability,_ both with a radius of 20 feet (caster level equals leonal’s HD). (The defensive benefits from the circle are not included in a leonal’s statistics block.)

**Speak with Animals (Su):** This ability works like _speak with animals_ (caster level 8th) but is a free action and does not require sound.

**Skills:** Leonals have a +4 racial bonus on Balance, Hide, and Move Silently checks.','{"full_attack":"2 claws +20 melee (1d6+8) and bite +15 melee (1d8+4)","environment":"A good-aligned plane.","organization":"Solitary or pride (4–9)","treasure":"No coins; double goods; standard items","advancement":"13–18 HD (Medium); 19–36 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"12d8+60 (114 hp)","hit_points":114,"base_attack_grapple":"+12/+20","attack":"Claw +20 melee (1d6+8)","full_attack":"2 claws +20 melee (1d6+8) and bite +15 melee (1d8+4)","space_reach":"5 ft./5 ft.","saves":"Fort +13 (+17 against poison), Ref +11, Will +10","abilities":{"str":"27","dex":"17","con":"20","int":"14","wis":"14","cha":"15"},"skills":"Balance +22, Concentration +12, Diplomacy +4, Hide +22, Intimidate +10, Jump +35, Knowledge (any) +17, Listen +17, Move Silently +22, Sense Motive +17, Spot +17, Survival +17","feats":"Ability Focus (roar), Dodge, Mobility, Spring Attack, Track","special_attacks":"Roar, pounce, improved grab, rake 1d6+8, spell-like abilities","special_qualities":"Damage reduction 10/evil and silver, darkvision 60 ft., immunity to electricity and petrification, lay on hands, lowlight vision, protective aura, resistance to cold 10 and sonic 10, speak with animals, spell resistance 28"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('lillend','Lillend','Lillend','7','Large','Outsider (Chaotic, Extraplanar, Good)','Always chaotic good','7d8+14 (45 hp)',45,'+3','20 ft. (4 squares), fly 70 ft. (average)','17 (–1 size, +3 Dex, +5 natural), touch 12, flat-footed 14','+7/+16','Short sword +11 melee (1d8+5/19–20)','10 ft./10 ft.','+7','+10','+8',20,17,15,14,16,18,'Appraise +12, Concentration +12, Diplomacy +16, Knowledge (arcana) +12, Listen +13, Perform (any one) +14, Sense Motive +13, Spellcraft +14, Spot +13, Survival +17','Combat Casting, Extend Spell, Lightning Reflexes','{"special_attacks":"Constrict 2d6+5, improved grab, spells, spell-like abilities","special_qualities":"Darkvision 60 ft., immunity to poison, resistance to fire 10"}'::jsonb,'A typical lillend’s coils are 20 feet long. The creature weighs about 3,800 pounds. A few lillends have male torsos.

Lillends speak Celestial, Infernal, Abyssal, and Common.

### Combat

Lillends are generally peaceful unless they intend vengeance against someone they believe guilty of harming, or even threatening, a favored art form, artwork, or artist. Then they become implacable foes. They use their spells and spell-like abilities to confuse and weaken opponents before entering combat. A covey of lillends usually discusses strategy before a battle.

A lillend’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and good-aligned for the purpose of overcoming damage reduction.

**Constrict (Ex):** A lillend deals 2d6+5 points of damage with a successful grapple check. Constricting uses the entire lower portion of its body, so it cannot take any move actions when constricting, though it can still attack with its sword.

**Improved Grab (Ex):** To use this ability, a lillend must hit with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Spells:** A lillend casts arcane spells as a 6th-level bard.

_Typical Bard Spells Known_ (3/4/3; save DC 14 + spell level): 0— _dancing lights, daze, detect magic, lullaby, mage hand, read magic;_ 1st— _charm person, cure light wounds, identify, sleep;_ 2nd—_hold person, invisibility, sound burst._

**Spell-Like Abilities:** 3/day—_darkness, hallucinatory terrain_ (DC 18), _knock, light;_ 1/day—_charm person_ (DC 15), _speak with animals, speak with plants_. Caster level 10th. The save DCs are Charisma-based.

A lillend also has the bardic music ability as a 6th-level bard.

**Skills:** Lillends have a +4 racial bonus on Survival checks.','{"full_attack":"Short sword +11/+6 melee (1d8+5/19–20) and tail slap +6 melee (2d6+2)","environment":"A chaos-aligned plane","organization":"Solitary or covey (2–4)","treasure":"Standard","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"+6","statblock":{"hit_dice":"7d8+14 (45 hp)","hit_points":45,"base_attack_grapple":"+7/+16","attack":"Short sword +11 melee (1d8+5/19–20)","full_attack":"Short sword +11/+6 melee (1d8+5/19–20) and tail slap +6 melee (2d6+2)","space_reach":"10 ft./10 ft.","saves":"Fort +7, Ref +10, Will +8","abilities":{"str":"20","dex":"17","con":"15","int":"14","wis":"16","cha":"18"},"skills":"Appraise +12, Concentration +12, Diplomacy +16, Knowledge (arcana) +12, Listen +13, Perform (any one) +14, Sense Motive +13, Spellcraft +14, Spot +13, Survival +17","feats":"Combat Casting, Extend Spell, Lightning Reflexes","special_attacks":"Constrict 2d6+5, improved grab, spells, spell-like abilities","special_qualities":"Darkvision 60 ft., immunity to poison, resistance to fire 10"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('lizardfolk','Lizardfolk','Lizardfolk','1','Medium','Humanoid (Reptilian)','Usually neutral','2d8+2 (11 hp)',11,'+0','30 ft. (6 squares)','15 (+5 natural) or 17 (+5 natural, +2 heavy shield), touch 10, flat-footed 15 or 17','+1/+2','Claw +2 melee (1d4+1) or club +2 melee (1d6+1) or javelin +1 ranged (1d6+1)','5 ft./5 ft.','+1','+3','+0',13,10,13,9,10,10,'Balance +4, Jump +5, Swim +2','Multiattack','{"special_attacks":"—","special_qualities":"Hold breath"}'::jsonb,'A lizardfolk is usually 6 to 7 feet tall with green, gray, or brown scales. Its tail is used for balance and is 3 to 4 feet long. A lizardfolk can weigh from 200 to 250 pounds.

Lizardfolk speak Draconic.

### Combat

Lizardfolk fight as unorganized individuals. They prefer frontal assaults and massed rushes, sometimes trying to force foes into the water, where the lizardfolk have an advantage. If outnumbered or if their territory is being invaded, they set snares, plan ambushes, and make raids to hinder enemy supplies. Advanced tribes use more sophisticated tactics and have better traps and ambushes.

**Hold Breath:** A lizardfolk can hold its breath for a number of rounds equal to four times its Constitution score before it risks drowning.

**Skills:** Because of their tails, lizardfolk have a +4 racial bonus on Jump, Swim, and Balance checks. The skill modifiers given in the statistics block include a –2 armor check penalty (–4 on Swim checks) for carrying a heavy shield.

### Lizardfolk as Characters

Lizardfolk characters possess the following racial traits.

— +2 Strength, +2 Constitution, –2 Intelligence.

—Medium size.

—A lizardfolk’s base land speed is 30 feet.

—Racial Hit Dice: A lizardfolk begins with two levels of humanoid, which provide 2d8 Hit Dice, a base attack bonus of +1, and base saving throw bonuses of Fort +0, Ref +3, and Will +0.

—Racial Skills: A lizardfolk’s humanoid levels give it skill points equal to 5 x (2 + Int modifier, minimum 1). Its class skills are Balance, Jump, and Swim. Lizardfolk have a +4 racial bonus on Balance, Jump, and Swim checks.

—Racial Feats: A lizardfolk’s humanoid levels give it one feat.

—Weapon and Armor Proficiency: A lizardfolk is automatically proficient with simple weapons and shields.

— +5 natural armor bonus.

—Natural Weapons: 2 claws (1d4) and bite (1d4).

—Special Qualities (see above): Hold breath.

—Automatic Languages: Common, Draconic. Bonus Languages: Aquan, Goblin, Gnoll, Orc.

—Favored Class: Druid.

—Level adjustment +1.','{"full_attack":"2 claws +2 melee (1d4+1) and bite +0 melee (1d4); or club +2 melee (1d6+1) and bite +0 melee (1d4); or javelin +1 ranged (1d6+1)","environment":"Temperate marshes","organization":"Gang (2–3), band (6–10 plus 50% noncombatants plus 1 leader of 3rd–6th level), or tribe (30–60 plus 2 lieutenants of 3rd–6th level and 1 leader of 4th–10th level)","treasure":"50% coins; 50% goods; 50% items","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/+2","attack":"Claw +2 melee (1d4+1) or club +2 melee (1d6+1) or javelin +1 ranged (1d6+1)","full_attack":"2 claws +2 melee (1d4+1) and bite +0 melee (1d4); or club +2 melee (1d6+1) and bite +0 melee (1d4); or javelin +1 ranged (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +1, Ref +3, Will +0","abilities":{"str":"13","dex":"10","con":"13","int":"9","wis":"10","cha":"10"},"skills":"Balance +4, Jump +5, Swim +2","feats":"Multiattack","special_attacks":"—","special_qualities":"Hold breath"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('locathah','Locathah','Locathah','1/2','Medium','Humanoid (Aquatic)','Usually neutral','2d8 (9 hp)',9,'+1','10 ft. (2 squares), swim 60 ft.','14 (+1 Dex, +3 natural), touch 11, flat-footed 13','+1/+1','Longspear +2 melee (1d8/3) or light crossbow +2 ranged (1d8/19–20)','5 ft./5 ft.','+3','+1','+1',10,12,10,null,13,11,'Craft (any one) +6, Listen +6, Spot +6, Swim +8','Weapon Focus (longspear)','{"special_attacks":"—","special_qualities":"—"}'::jsonb,'Although humanoid in shape, locathahs are clearly more fish than human. The average locathah stands 5 feet tall and weighs 175 pounds. Females and males look very much alike, although the former can be recognized by the two ochre stripes marking their egg sacs.

Locathahs speak Aquan.

### Combat

Any battle with locathahs usually begins with the creatures loosing volleys of bolts from their crossbows; underwater, their crossbows have a range increment of 20 feet. If they have managed to set up an ambush or other trap, they continue to employ crossbows for as long as possible. Otherwise, they close to bring their longspears into play. Although primarily used for fishing, these spears make formidable weapons.

Locathahs lack teeth, claws, and other natural weapons, so they are not especially dangerous if unarmed. A weaponless locathah will generally turn and flee.

**Skills:** A locathah has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered.

It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"Longspear +2 melee (1d8/3) or light crossbow +2 ranged (1d8/19–20)","environment":"Warm aquatic","organization":"Company (2–4), patrol (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or tribe (30–100 plus 100% noncombatants plus 1 3rd-level sergeant per 10 adults, 5 5th-level lieutenants, and 3 7th-level captains)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"2d8 (9 hp)","hit_points":9,"base_attack_grapple":"+1/+1","attack":"Longspear +2 melee (1d8/3) or light crossbow +2 ranged (1d8/19–20)","full_attack":"Longspear +2 melee (1d8/3) or light crossbow +2 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +1, Will +1","abilities":{"str":"10","dex":"12","con":"10","int":null,"wis":"13","cha":"11"},"skills":"Craft (any one) +6, Listen +6, Spot +6, Swim +8","feats":"Weapon Focus (longspear)","special_attacks":"—","special_qualities":"—"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werebear_human_form','Werebear, Human Form','Werebear, Human Form','5','Medium','Humanoid (Human, Shapechanger)','Always lawful good','1d8+1 plus 6d8+30 (62 hp)',62,'+0','30 ft. (6 squares)','15 (+2 natural, +3 studded leather armor), touch 10, flat-footed 15','+5/+6','Greataxe +6 melee (1d12+1/x3) or throwing axe +5 ranged (1d6+1)','5 ft./5 ft.','+8','+5','+4',13,11,12,10,11,8,'Handle Animal +3, Listen +4, Spot +4, Swim +1','Endurance, Iron WillB, Multiattack, Power Attack, Run, TrackB','{"special_attacks":"—","special_qualities":"Alternate form, bear empathy, low-light vision, scent"}'::jsonb,'Werebears in humanoid form tend to be stout, well-muscled, and hairy. Their brown hair is thick, and males usually wear beards. They may have reddish, blond, ivory, or black hair, matching the color of the ursine form. They dress in simple cloth and leather garments that are easy to remove, repair, or replace

#### Combat

Werebears fight just as brown bears do in animal form. In humanoid or hybrid form, they favor large, heavy weapons such as greataxes or greatswords. The werebear’s greataxe is a Medium weapon, so it can wield the axe in one hand in hybrid form.

**Alternate Form (Su):** A werebear can assume the form of a brown bear or a bear-humanoid hybrid.

**Bear Empathy (Ex):** Communicate with bears and dire bears, and +4 racial bonus on Charisma-based checks against bears and dire bears.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werebear’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a werebear must be in bear form and must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Skills:** Werebears have a +4 racial bonus on Swim checks in any bear form.

The werebear presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Greataxe +6 melee (1d12+1/x3) or throwing axe +5 ranged (1d6+1)","environment":"Cold forests","organization":"Solitary, pair, family (3–4), or troupe (2–4 plus 1–4 brown bears)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+30 (62 hp)","hit_points":62,"base_attack_grapple":"+5/+6","attack":"Greataxe +6 melee (1d12+1/x3) or throwing axe +5 ranged (1d6+1)","full_attack":"Greataxe +6 melee (1d12+1/x3) or throwing axe +5 ranged (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +8, Ref +5, Will +4","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Listen +4, Spot +4, Swim +1","feats":"Endurance, Iron WillB, Multiattack, Power Attack, Run, TrackB","special_attacks":"—","special_qualities":"Alternate form, bear empathy, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werebear_bear_form','Werebear, Bear Form','Werebear, Bear Form','5','Large','Humanoid (Human, Shapechanger)','Always lawful good','1d8+1 plus 6d8+30 (62 hp)',62,'+1','40 ft. (8 squares)','17 (–1 size, +1 Dex, +7 natural), touch 10, flat-footed 16','+5/+18','Claw +13 melee (1d8+9)','10 ft./5 ft.','+12','+6','+4',29,13,20,10,11,8,'Handle Animal +3, Listen +4, Spot +4, Swim +13','(same as human form)','{"special_attacks":"Improved grab, curse of lycanthropy","special_qualities":"Alternate form, bear empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Werebears in humanoid form tend to be stout, well-muscled, and hairy. Their brown hair is thick, and males usually wear beards. They may have reddish, blond, ivory, or black hair, matching the color of the ursine form. They dress in simple cloth and leather garments that are easy to remove, repair, or replace

#### Combat

Werebears fight just as brown bears do in animal form. In humanoid or hybrid form, they favor large, heavy weapons such as greataxes or greatswords. The werebear’s greataxe is a Medium weapon, so it can wield the axe in one hand in hybrid form.

**Alternate Form (Su):** A werebear can assume the form of a brown bear or a bear-humanoid hybrid.

**Bear Empathy (Ex):** Communicate with bears and dire bears, and +4 racial bonus on Charisma-based checks against bears and dire bears.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werebear’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a werebear must be in bear form and must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Skills:** Werebears have a +4 racial bonus on Swim checks in any bear form.

The werebear presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"2 claws +13 melee (1d8+9) and bite +11 melee (2d6+4)","environment":"Cold forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+30 (62 hp)","hit_points":62,"base_attack_grapple":"+5/+18","attack":"Claw +13 melee (1d8+9)","full_attack":"2 claws +13 melee (1d8+9) and bite +11 melee (2d6+4)","space_reach":"10 ft./5 ft.","saves":"Fort +12, Ref +6, Will +4","abilities":{"str":"29","dex":"13","con":"20","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Listen +4, Spot +4, Swim +13","feats":"(same as human form)","special_attacks":"Improved grab, curse of lycanthropy","special_qualities":"Alternate form, bear empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werebear_hybrid_form','Werebear, Hybrid Form','Werebear, Hybrid Form','5','Large','Humanoid (Human, Shapechanger)','Always lawful good','1d8+1 plus 6d8+30 (62 hp)',62,'+1','30 ft. (6 squares)','17 (–1 size, +1 Dex, +7 natural) touch 10, flat-footed 16','+5/+18','Greataxe +11 melee (1d12+13/x3); or claw +13 melee (1d6+9)','10 ft./10 ft.','+12','+6','+4',29,13,20,10,11,8,'Handle Animal +3, Listen +4, Spot +5, Swim +9','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, bear empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Werebears in humanoid form tend to be stout, well-muscled, and hairy. Their brown hair is thick, and males usually wear beards. They may have reddish, blond, ivory, or black hair, matching the color of the ursine form. They dress in simple cloth and leather garments that are easy to remove, repair, or replace

#### Combat

Werebears fight just as brown bears do in animal form. In humanoid or hybrid form, they favor large, heavy weapons such as greataxes or greatswords. The werebear’s greataxe is a Medium weapon, so it can wield the axe in one hand in hybrid form.

**Alternate Form (Su):** A werebear can assume the form of a brown bear or a bear-humanoid hybrid.

**Bear Empathy (Ex):** Communicate with bears and dire bears, and +4 racial bonus on Charisma-based checks against bears and dire bears.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werebear’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a werebear must be in bear form and must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Skills:** Werebears have a +4 racial bonus on Swim checks in any bear form.

The werebear presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Claw +13 melee (1d6+9) and greataxe +9 melee (1d12+4/x3) and bite +11 melee (1d8+4) or 2 claws +13 melee (1d6+9) and bite +11 melee (1d8+4)","environment":"Cold forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+30 (62 hp)","hit_points":62,"base_attack_grapple":"+5/+18","attack":"Greataxe +11 melee (1d12+13/x3); or claw +13 melee (1d6+9)","full_attack":"Claw +13 melee (1d6+9) and greataxe +9 melee (1d12+4/x3) and bite +11 melee (1d8+4) or 2 claws +13 melee (1d6+9) and bite +11 melee (1d8+4)","space_reach":"10 ft./10 ft.","saves":"Fort +12, Ref +6, Will +4","abilities":{"str":"29","dex":"13","con":"20","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Listen +4, Spot +5, Swim +9","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, bear empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('wereboar_human_form','Wereboar, Human Form','Wereboar, Human Form','4','Medium','Humanoid (Human, Shapechanger)','Always neutral','1d8+4 plus 3d8+12 (34 hp)',34,'+0','20 ft. in scale mail (4 squares); base speed 30 ft.','18 (+2 natural, +4 scale mail, +2 heavy shield) touch 10, flat-footed 18','+3/+4','Battleaxe +4 melee (1d8+1/x3) or javelin +3 ranged (1d6+1)','5 ft./5 ft.','+6','+3','+3',13,11,12,10,11,8,'Handle Animal +3, Intimidate +3, Listen +5, Spot +4','AlertnessB, Improved Bull Rush, Iron WillB, Power Attack, Toughness','{"special_attacks":"—","special_qualities":"Alternate form, boar empathy, ferocity, low-light vision, scent"}'::jsonb,'A wereboar in humanoid form tends to be a stocky, muscular individual of average height. It dresses in simple garments that are easy to remove, repair, or replace.

#### Combat

In any form, wereboars are as ferocious as normal boars. When in hybrid form, they fight with a weapon and their dangerous gore attack.

**Alternate Form (Su):** A wereboar can assume the form of a boar or a boar-humanoid hybrid.

**Boar Empathy (Ex):** Communicate with boars and dire boars, and +4 racial bonus on Charisma-based checks against boars and dire boars.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by the wereboar’s gore attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Ferocity (Ex):** A wereboar is such a tenacious combatant that it continues to fight without penalty even while disabled or dying.

The wereboar presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Battleaxe +4 melee (1d8+1/x3) or javelin +3 ranged (1d6+1)","environment":"Temperate forests","organization":"Solitary, pair, brood (3–4), or troupe (2–4 plus 1–4 boars)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+4 plus 3d8+12 (34 hp)","hit_points":34,"base_attack_grapple":"+3/+4","attack":"Battleaxe +4 melee (1d8+1/x3) or javelin +3 ranged (1d6+1)","full_attack":"Battleaxe +4 melee (1d8+1/x3) or javelin +3 ranged (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +3, Will +3","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Intimidate +3, Listen +5, Spot +4","feats":"AlertnessB, Improved Bull Rush, Iron WillB, Power Attack, Toughness","special_attacks":"—","special_qualities":"Alternate form, boar empathy, ferocity, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('wereboar_boar_form','Wereboar, Boar Form','Wereboar, Boar Form','4','Medium','Humanoid (Human, Shapechanger)','Always neutral','1d8+4 plus 3d8+12 (34 hp)',34,'+0','40 ft. (8 squares)','18 (+8 natural) touch 10, flat- footed 18','+3/+6','Gore +6 melee (1d8+4)','5 ft./5 ft.','+9','+3','+3',17,11,18,10,11,8,'Handle Animal +3, Intimidate +3, Listen +5, Spot +4','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"}'::jsonb,'A wereboar in humanoid form tends to be a stocky, muscular individual of average height. It dresses in simple garments that are easy to remove, repair, or replace.

#### Combat

In any form, wereboars are as ferocious as normal boars. When in hybrid form, they fight with a weapon and their dangerous gore attack.

**Alternate Form (Su):** A wereboar can assume the form of a boar or a boar-humanoid hybrid.

**Boar Empathy (Ex):** Communicate with boars and dire boars, and +4 racial bonus on Charisma-based checks against boars and dire boars.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by the wereboar’s gore attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Ferocity (Ex):** A wereboar is such a tenacious combatant that it continues to fight without penalty even while disabled or dying.

The wereboar presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Gore +6 melee (1d8+4)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+4 plus 3d8+12 (34 hp)","hit_points":34,"base_attack_grapple":"+3/+6","attack":"Gore +6 melee (1d8+4)","full_attack":"Gore +6 melee (1d8+4)","space_reach":"5 ft./5 ft.","saves":"Fort +9, Ref +3, Will +3","abilities":{"str":"17","dex":"11","con":"18","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Intimidate +3, Listen +5, Spot +4","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true)
on conflict(id) do update set nome=case when public.srd_monsters.srd_canonical then public.srd_monsters.nome else excluded.nome end,nome_original=excluded.nome_original,nd=excluded.nd,tamanho=excluded.tamanho,tipo=excluded.tipo,tendencia=excluded.tendencia,dados_vida=excluded.dados_vida,pv=excluded.pv,iniciativa=excluded.iniciativa,deslocamento=excluded.deslocamento,ca=excluded.ca,base_attack_grapple=excluded.base_attack_grapple,ataques=excluded.ataques,espaco_alcance=excluded.espaco_alcance,fortitude=excluded.fortitude,reflexos=excluded.reflexos,vontade=excluded.vontade,forca=excluded.forca,destreza=excluded.destreza,constituicao=excluded.constituicao,inteligencia=excluded.inteligencia,sabedoria=excluded.sabedoria,carisma=excluded.carisma,pericias=excluded.pericias,talentos=excluded.talentos,qualidades_especiais=excluded.qualidades_especiais,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,srd_canonical=true;