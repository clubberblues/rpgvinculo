-- D&D 3.5 SRD OGC monster stat blocks and full entry rules. Source: https://github.com/olimot/srd-v3.5-md/tree/main/monsters
-- Open Game License 1.0a; attribution retained in srd_source_url and dados_tecnicos.
insert into public.srd_monsters (id,nome,nome_original,nd,tamanho,tipo,tendencia,dados_vida,pv,iniciativa,deslocamento,ca,base_attack_grapple,ataques,espaco_alcance,fortitude,reflexos,vontade,forca,destreza,constituicao,inteligencia,sabedoria,carisma,pericias,talentos,qualidades_especiais,descricao,dados_tecnicos,srd_source_url,srd_canonical) values
('wereboar_hybrid_form','Wereboar, Hybrid Form','Wereboar, Hybrid Form','4','Medium','Humanoid (Human, Shapechanger)','Always neutral','1d8+4 plus 3d8+12 (34 hp)',34,'+0','30 ft. (6 squares)','18 (+8 natural) touch 10, flat-footed 18','+3/+6','Battleaxe +6 melee (1d8+4/x3) or claw +6 melee (1d4+3)','5 ft./5 ft.','+9','+3','+3',17,11,18,10,11,8,'Handle Animal +3, Intimidate +3, Listen +5, Spot +4','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"}'::jsonb,'A wereboar in humanoid form tends to be a stocky, muscular individual of average height. It dresses in simple garments that are easy to remove, repair, or replace.

#### Combat

In any form, wereboars are as ferocious as normal boars. When in hybrid form, they fight with a weapon and their dangerous gore attack.

**Alternate Form (Su):** A wereboar can assume the form of a boar or a boar-humanoid hybrid.

**Boar Empathy (Ex):** Communicate with boars and dire boars, and +4 racial bonus on Charisma-based checks against boars and dire boars.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by the wereboar’s gore attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Ferocity (Ex):** A wereboar is such a tenacious combatant that it continues to fight without penalty even while disabled or dying.

The wereboar presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Battleaxe +6 melee (1d8+4/x3) and gore +1 melee (1d6+1); or 2 claws +6 melee (1d4+3) and gore +1 melee (1d6+1)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+4 plus 3d8+12 (34 hp)","hit_points":34,"base_attack_grapple":"+3/+6","attack":"Battleaxe +6 melee (1d8+4/x3) or claw +6 melee (1d4+3)","full_attack":"Battleaxe +6 melee (1d8+4/x3) and gore +1 melee (1d6+1); or 2 claws +6 melee (1d4+3) and gore +1 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +9, Ref +3, Will +3","abilities":{"str":"17","dex":"11","con":"18","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +3, Intimidate +3, Listen +5, Spot +4","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('wererat_human_form','Wererat, Human Form','Wererat, Human Form','2','Medium','Humanoid (Human, Shapechanger)','Always lawful evil','1d8+1 plus 1d8+2 (12 hp)',12,'+0','30 ft. (6 squares)','15 (+2 natural, +2 leather, +1 buckler) touch 10, flat-footed 15','+1/+2','Rapier +2 melee (1d6+1/18–20) or light crossbow +1 ranged (1d8/19–20)','5 ft./5 ft.','+5','+2','+4',13,11,12,10,11,8,'Climb +0, Handle Animal +3, Hide +1, Listen +4, Move Silently +0, Spot +4, Swim +9','Alertness, Dodge, Iron WillB, Weapon FinesseB','{"special_attacks":"—","special_qualities":"Alternate form, rat empathy, low-light vision, scent"}'::jsonb,'A wererat in humanoid form tends to be a thin, wiry individual of shorter than average height. The eyes constantly dart around, and the nose and mouth may twitch if he or she is excited. Males often have thin, ragged mustaches.

#### Combat

In animal form, wererats avoid combat, preferring to use their dire rat shape for skulking and spying. In hybrid form, a wererat fights with a rapier and light crossbow.

**Alternate Form (Su):** A wererat can assume a bipedal hybrid form or the form of a dire rat.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a wererat’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Disease (Ex):** Filth fever; bite, Fortitude DC 12, incubation period 1d3 days, damage 1d3 Dex and 1d3 Con. The save DC is Constitution-based.

**Rat Empathy (Ex):** Communicate with rats and dire rats, and +4 racial bonus on Charisma-based checks against rats and dire rats.

**Skills:** A wererat in rat or hybrid form uses its Dexterity modifier for Climb or Swim checks. It has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.

Wererats have a +8 racial bonus on Swim checks from their dire rat form.

**Feats:** Wererats gain Weapon Finesse as a bonus feat.

The wererat presented here is based on a 1st-level human warrior who is a natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Rapier +2 melee (1d6+1/18–20) or light crossbow +1 ranged (1d8/19–20)","environment":"Any","organization":"Solitary, pair, pack (6–10), or troupe (2–5 plus 5–8 dire rats)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 1d8+2 (12 hp)","hit_points":12,"base_attack_grapple":"+1/+2","attack":"Rapier +2 melee (1d6+1/18–20) or light crossbow +1 ranged (1d8/19–20)","full_attack":"Rapier +2 melee (1d6+1/18–20) or light crossbow +1 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +2, Will +4","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"8"},"skills":"Climb +0, Handle Animal +3, Hide +1, Listen +4, Move Silently +0, Spot +4, Swim +9","feats":"Alertness, Dodge, Iron WillB, Weapon FinesseB","special_attacks":"—","special_qualities":"Alternate form, rat empathy, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('wererat_dire_rat_form','Wererat, Dire Rat Form','Wererat, Dire Rat Form','2','Small','Humanoid (Human, Shapechanger)','Always lawful evil','1d8+1 plus 1d8+2 (12 hp)',12,'+3','40 ft. (8 squares), climb 20 ft.','17 (+1 size, +3 Dex, +3 natural), touch 14, flat-footed 14','+1/–2','Bite +6 melee (1d4+1 plus disease)','5 ft./5 ft.','+6','+5','+4',13,17,14,10,11,8,'Climb +11, Handle Animal +3, Hide +8, Listen +4, Move Silently +4, Spot +4, Swim +11','(same as human form)','{"special_attacks":"Curse of lycanthropy, disease","special_qualities":"Alternate form, rat empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'A wererat in humanoid form tends to be a thin, wiry individual of shorter than average height. The eyes constantly dart around, and the nose and mouth may twitch if he or she is excited. Males often have thin, ragged mustaches.

#### Combat

In animal form, wererats avoid combat, preferring to use their dire rat shape for skulking and spying. In hybrid form, a wererat fights with a rapier and light crossbow.

**Alternate Form (Su):** A wererat can assume a bipedal hybrid form or the form of a dire rat.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a wererat’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Disease (Ex):** Filth fever; bite, Fortitude DC 12, incubation period 1d3 days, damage 1d3 Dex and 1d3 Con. The save DC is Constitution-based.

**Rat Empathy (Ex):** Communicate with rats and dire rats, and +4 racial bonus on Charisma-based checks against rats and dire rats.

**Skills:** A wererat in rat or hybrid form uses its Dexterity modifier for Climb or Swim checks. It has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.

Wererats have a +8 racial bonus on Swim checks from their dire rat form.

**Feats:** Wererats gain Weapon Finesse as a bonus feat.

The wererat presented here is based on a 1st-level human warrior who is a natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Bite +6 melee (1d4+1 plus disease)","environment":"Any","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 1d8+2 (12 hp)","hit_points":12,"base_attack_grapple":"+1/–2","attack":"Bite +6 melee (1d4+1 plus disease)","full_attack":"Bite +6 melee (1d4+1 plus disease)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +5, Will +4","abilities":{"str":"13","dex":"17","con":"14","int":"10","wis":"11","cha":"8"},"skills":"Climb +11, Handle Animal +3, Hide +8, Listen +4, Move Silently +4, Spot +4, Swim +11","feats":"(same as human form)","special_attacks":"Curse of lycanthropy, disease","special_qualities":"Alternate form, rat empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('wererat_hybrid_form','Wererat, Hybrid Form','Wererat, Hybrid Form','2','Medium','Humanoid (Human, Shapechanger)','Always lawful evil','1d8+1 plus 1d8+2 (12 hp)',12,'+3','30 ft. (6 squares)','16 (+3 Dex, +3 natural) touch 13, flat-footed 13','+1/+2','Rapier +5 melee (1d6+1/18–20) or light crossbow +4 ranged (1d8/19–20)','5 ft./5 ft.','+6','+5','+4',13,17,14,10,11,8,'Climb +4, Handle Animal +3, Hide +5, Listen +4, Move Silently +4, Spot +4, Swim +9','(same as human form)','{"special_attacks":"Curse of lycanthropy, disease","special_qualities":"Alternate form, rat empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'A wererat in humanoid form tends to be a thin, wiry individual of shorter than average height. The eyes constantly dart around, and the nose and mouth may twitch if he or she is excited. Males often have thin, ragged mustaches.

#### Combat

In animal form, wererats avoid combat, preferring to use their dire rat shape for skulking and spying. In hybrid form, a wererat fights with a rapier and light crossbow.

**Alternate Form (Su):** A wererat can assume a bipedal hybrid form or the form of a dire rat.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a wererat’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Disease (Ex):** Filth fever; bite, Fortitude DC 12, incubation period 1d3 days, damage 1d3 Dex and 1d3 Con. The save DC is Constitution-based.

**Rat Empathy (Ex):** Communicate with rats and dire rats, and +4 racial bonus on Charisma-based checks against rats and dire rats.

**Skills:** A wererat in rat or hybrid form uses its Dexterity modifier for Climb or Swim checks. It has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.

Wererats have a +8 racial bonus on Swim checks from their dire rat form.

**Feats:** Wererats gain Weapon Finesse as a bonus feat.

The wererat presented here is based on a 1st-level human warrior who is a natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Rapier +4 melee (1d6+1/18–20) and bite –1 melee (1d6 plus disease); or light crossbow +4 ranged (1d8/19–20)","environment":"Any","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 1d8+2 (12 hp)","hit_points":12,"base_attack_grapple":"+1/+2","attack":"Rapier +5 melee (1d6+1/18–20) or light crossbow +4 ranged (1d8/19–20)","full_attack":"Rapier +4 melee (1d6+1/18–20) and bite –1 melee (1d6 plus disease); or light crossbow +4 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +5, Will +4","abilities":{"str":"13","dex":"17","con":"14","int":"10","wis":"11","cha":"8"},"skills":"Climb +4, Handle Animal +3, Hide +5, Listen +4, Move Silently +4, Spot +4, Swim +9","feats":"(same as human form)","special_attacks":"Curse of lycanthropy, disease","special_qualities":"Alternate form, rat empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('weretiger_human_form','Weretiger, Human Form','Weretiger, Human Form','5','Medium','Humanoid (Human, Shapechanger)','Always neutral','1d8+1 plus 6d8+18 (50 hp)',50,'+4','20 ft. in breastplate (4 squares); base speed 30 ft.','17 (+2 natural, +5 breastplate) touch 10, flat-footed 17','+5/+6','Glaive +6 melee (1d10+1/x3) or composite longbow (+1 Str bonus) +5 ranged (1d8+1/x3)','5 ft./5 ft. (10 ft. with glaive)','+8','+5','+4',13,11,12,10,11,8,'Balance +0, Climb +1, Handle Animal +3, Hide +0, Listen +6, Move Silently +0, Spot +6','AlertnessB, Combat Reflexes, Improved Initiative, Improved Natural Attack (bite, claw), Iron WillB','{"special_attacks":"—","special_qualities":"Alternate form, tiger empathy, low-light vision, scent"}'::jsonb,'Weretigers in humanoid form tend to be sleekly muscular, taller than average, and very agile.

#### Combat

Weretigers can assume a hybrid form as well as an animal form. In tiger form, they can pounce and grab just as normal tigers do. In hybrid form, they rely on their deadly claws.

**Alternate Form (Su):** A weretiger can assume a bipedal hybrid form or the form of a tiger.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a weretiger’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a weretiger in tiger form must hit with a claw or bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a weretiger in tiger form charges an opponent, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +9 melee, damage 1d8+3.

**Tiger Empathy (Ex):** Communicate with tigers and dire tigers, and +4 racial bonus on Charisma-based checks against tigers and dire tigers.

**Skills:** In any form, weretigers have a +4 bonus on Balance, Hide, and Move Silently checks. \*In areas of tall grass or heavy undergrowth, the Hide bonus improves to +8 in the tiger form.

The weretiger presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Glaive +6 melee (1d10+1/x3) or composite longbow (+1 Str bonus) +5 ranged (1d8+1/x3)","environment":"Warm forests","organization":"Solitary or pair","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+18 (50 hp)","hit_points":50,"base_attack_grapple":"+5/+6","attack":"Glaive +6 melee (1d10+1/x3) or composite longbow (+1 Str bonus) +5 ranged (1d8+1/x3)","full_attack":"Glaive +6 melee (1d10+1/x3) or composite longbow (+1 Str bonus) +5 ranged (1d8+1/x3)","space_reach":"5 ft./5 ft. (10 ft. with glaive)","saves":"Fort +8, Ref +5, Will +4","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"8"},"skills":"Balance +0, Climb +1, Handle Animal +3, Hide +0, Listen +6, Move Silently +0, Spot +6","feats":"AlertnessB, Combat Reflexes, Improved Initiative, Improved Natural Attack (bite, claw), Iron WillB","special_attacks":"—","special_qualities":"Alternate form, tiger empathy, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('weretiger_tiger_form','Weretiger, Tiger Form','Weretiger, Tiger Form','5','Large','Humanoid (Human, Shapechanger)','Always neutral','1d8+1 plus 6d8+18 (50 hp)',50,'+6','40 ft. (8 squares)','16 (–1 size, +2 Dex, +5 natural), touch 11, flat-footed 14','+5/+16','','10 ft./5 ft.','+10','+7','+4',25,15,16,10,11,8,'Balance +6, Climb +12, Handle Animal +3, Hide +2*, Listen +6, Move Silently +12, Spot +6','(same as human form)','{"special_attacks":"Pounce, improved grab, rake, curse of lycanthropy","special_qualities":"Alternate form, tiger empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Weretigers in humanoid form tend to be sleekly muscular, taller than average, and very agile.

#### Combat

Weretigers can assume a hybrid form as well as an animal form. In tiger form, they can pounce and grab just as normal tigers do. In hybrid form, they rely on their deadly claws.

**Alternate Form (Su):** A weretiger can assume a bipedal hybrid form or the form of a tiger.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a weretiger’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a weretiger in tiger form must hit with a claw or bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a weretiger in tiger form charges an opponent, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +9 melee, damage 1d8+3.

**Tiger Empathy (Ex):** Communicate with tigers and dire tigers, and +4 racial bonus on Charisma-based checks against tigers and dire tigers.

**Skills:** In any form, weretigers have a +4 bonus on Balance, Hide, and Move Silently checks. \*In areas of tall grass or heavy undergrowth, the Hide bonus improves to +8 in the tiger form.

The weretiger presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"2 claws +11 melee (1d8+7) and bite +6 melee (2d6+3)","environment":"Warm forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+18 (50 hp)","hit_points":50,"base_attack_grapple":"+5/+16","attack":"","full_attack":"2 claws +11 melee (1d8+7) and bite +6 melee (2d6+3)","space_reach":"10 ft./5 ft.","saves":"Fort +10, Ref +7, Will +4","abilities":{"str":"25","dex":"15","con":"16","int":"10","wis":"11","cha":"8"},"skills":"Balance +6, Climb +12, Handle Animal +3, Hide +2*, Listen +6, Move Silently +12, Spot +6","feats":"(same as human form)","special_attacks":"Pounce, improved grab, rake, curse of lycanthropy","special_qualities":"Alternate form, tiger empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('weretiger_hybrid_form','Weretiger, Hybrid Form','Weretiger, Hybrid Form','5','Large','Humanoid (Human, Shapechanger)','Always neutral','1d8+1 plus 6d8+18 (50 hp)',50,'+6','30 ft. (6 squares)','16 (–1 size, +2 Dex, +5 natural), touch 11, flat-footed 14','+5/+16','','10 ft./10 ft.','+10','+7','+4',25,15,16,10,11,8,'Balance +6, Climb +12, Handle Animal +3, Hide +2, Listen +6, Move Silently +12, Spot +6','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, tiger empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Weretigers in humanoid form tend to be sleekly muscular, taller than average, and very agile.

#### Combat

Weretigers can assume a hybrid form as well as an animal form. In tiger form, they can pounce and grab just as normal tigers do. In hybrid form, they rely on their deadly claws.

**Alternate Form (Su):** A weretiger can assume a bipedal hybrid form or the form of a tiger.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a weretiger’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Improved Grab (Ex):** To use this ability, a weretiger in tiger form must hit with a claw or bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a weretiger in tiger form charges an opponent, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +9 melee, damage 1d8+3.

**Tiger Empathy (Ex):** Communicate with tigers and dire tigers, and +4 racial bonus on Charisma-based checks against tigers and dire tigers.

**Skills:** In any form, weretigers have a +4 bonus on Balance, Hide, and Move Silently checks. \*In areas of tall grass or heavy undergrowth, the Hide bonus improves to +8 in the tiger form.

The weretiger presented here is a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"2 claws +11 melee (1d8+7) and bite +6 melee (2d6+3)","environment":"Warm forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 6d8+18 (50 hp)","hit_points":50,"base_attack_grapple":"+5/+16","attack":"","full_attack":"2 claws +11 melee (1d8+7) and bite +6 melee (2d6+3)","space_reach":"10 ft./10 ft.","saves":"Fort +10, Ref +7, Will +4","abilities":{"str":"25","dex":"15","con":"16","int":"10","wis":"11","cha":"8"},"skills":"Balance +6, Climb +12, Handle Animal +3, Hide +2, Listen +6, Move Silently +12, Spot +6","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, tiger empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_human_form','Werewolf, Human Form','Werewolf, Human Form','3','Medium','Humanoid (Human, Shapechanger)','Always chaotic evil','1d8+1 plus 2d8+6 (20 hp)',20,'+4','30 ft. (6 squares)','17 (+2 natural, +4 chain shirt, +1 light shield) touch 10, flat-footed 17','+2/+3','Longsword +3 melee (1d8+1/19–20) or light crossbow +2 ranged (1d8/19–20)','5 ft./5 ft.','+6','+3','+2',13,11,12,10,11,8,'Handle Animal +1, Hide +1, Listen +1, Move Silently +2, Spot +1, Survival +2','Improved Initiative, Iron WillB, Stealthy, TrackB, Weapon Focus (bite)','{"special_attacks":"—","special_qualities":"Alternate form, wolf empathy, low-light vision, scent"}'::jsonb,'Werewolves in humanoid form have no distinguishing traits.

#### Combat

In wolf form, a werewolf can trip just as a normal wolf does. A werewolf in hybrid form usually dispenses with weapon attacks, though it can wield a weapon and use its bite as a secondary natural attack.

**Alternate Form (Su):** A werewolf can assume a bipedal hybrid form or the form of a wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf in animal form that hits with a bite attack can attempt to trip the opponent (+2 check modifier) as a free action without making a touch attack or provoking an attack of opportunity.

If the attempt fails, the opponent cannot react to trip the werewolf.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

The werewolf presented here is based on a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Longsword +3 melee (1d8+1/19–20) or light crossbow +2 ranged (1d8/19–20)","environment":"Temperate forests","organization":"Solitary, pair, pack (6–10), or troupe (2–5 plus 5–8 wolves)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 2d8+6 (20 hp)","hit_points":20,"base_attack_grapple":"+2/+3","attack":"Longsword +3 melee (1d8+1/19–20) or light crossbow +2 ranged (1d8/19–20)","full_attack":"Longsword +3 melee (1d8+1/19–20) or light crossbow +2 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +3, Will +2","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +1, Hide +1, Listen +1, Move Silently +2, Spot +1, Survival +2","feats":"Improved Initiative, Iron WillB, Stealthy, TrackB, Weapon Focus (bite)","special_attacks":"—","special_qualities":"Alternate form, wolf empathy, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_wolf_form','Werewolf, Wolf Form','Werewolf, Wolf Form','3','Medium','Humanoid (Human, Shapechanger)','Always chaotic evil','1d8+1 plus 2d8+6 (20 hp)',20,'+6','50 ft. (10 squares)','16 (+2 Dex, +4 natural), touch 12, flat-footed 14','+2/+4','Bite +5 melee (1d6+3)','5 ft./5 ft.','+8','+5','+2',15,15,16,10,11,8,'Handle Animal +1, Hide +6, Listen +1, Move Silently +6, Spot +1, Survival +2*','(same as human form)','{"special_attacks":"Curse of lycanthropy, trip","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Werewolves in humanoid form have no distinguishing traits.

#### Combat

In wolf form, a werewolf can trip just as a normal wolf does. A werewolf in hybrid form usually dispenses with weapon attacks, though it can wield a weapon and use its bite as a secondary natural attack.

**Alternate Form (Su):** A werewolf can assume a bipedal hybrid form or the form of a wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf in animal form that hits with a bite attack can attempt to trip the opponent (+2 check modifier) as a free action without making a touch attack or provoking an attack of opportunity.

If the attempt fails, the opponent cannot react to trip the werewolf.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

The werewolf presented here is based on a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"Bite +5 melee (1d6+3)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 2d8+6 (20 hp)","hit_points":20,"base_attack_grapple":"+2/+4","attack":"Bite +5 melee (1d6+3)","full_attack":"Bite +5 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +8, Ref +5, Will +2","abilities":{"str":"15","dex":"15","con":"16","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +1, Hide +6, Listen +1, Move Silently +6, Spot +1, Survival +2*","feats":"(same as human form)","special_attacks":"Curse of lycanthropy, trip","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_hybrid_form','Werewolf, Hybrid Form','Werewolf, Hybrid Form','3','Medium','Humanoid (Human, Shapechanger)','Always chaotic evil','1d8+1 plus 2d8+6 (20 hp)',20,'+6','30 ft. (6 squares)','16 (+2 Dex, +4 natural), touch 12, flat-footed 14','+2/+4','Claw +4 melee (1d4+2)','5 ft./5 ft.','+8','+5','+2',15,15,16,10,11,8,'Handle Animal +1, Hide +6, Listen +1, Move Silently +6, Spot +1, Survival +2*','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Werewolves in humanoid form have no distinguishing traits.

#### Combat

In wolf form, a werewolf can trip just as a normal wolf does. A werewolf in hybrid form usually dispenses with weapon attacks, though it can wield a weapon and use its bite as a secondary natural attack.

**Alternate Form (Su):** A werewolf can assume a bipedal hybrid form or the form of a wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf’s bite attack in animal or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf in animal form that hits with a bite attack can attempt to trip the opponent (+2 check modifier) as a free action without making a touch attack or provoking an attack of opportunity.

If the attempt fails, the opponent cannot react to trip the werewolf.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

The werewolf presented here is based on a 1st-level human warrior and natural lycanthrope, using the following base ability scores: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.','{"full_attack":"2 claws +4 melee (1d4+2) and bite +0 melee (1d6+1)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"1d8+1 plus 2d8+6 (20 hp)","hit_points":20,"base_attack_grapple":"+2/+4","attack":"Claw +4 melee (1d4+2)","full_attack":"2 claws +4 melee (1d4+2) and bite +0 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +8 Ref +5, Will +2","abilities":{"str":"15","dex":"15","con":"16","int":"10","wis":"11","cha":"8"},"skills":"Handle Animal +1, Hide +6, Listen +1, Move Silently +6, Spot +1, Survival +2*","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_lord_human_form','Werewolf Lord, Human Form','Werewolf Lord, Human Form','14','Medium','Humanoid','Always chaotic evil','10d10+20 plus 6d8+30 (132 hp)',132,'+2','','26 (+2 Dex, +3 natural, +6 +2 mithral chain shirt, +5 +3 heavy shield) touch 12, flat-footed 24','+14/+18','+2 bastard sword +21 melee (1d10+8/17–20) or masterwork composite longbow (+4 Str bonus) (2d8+15/17–20) +17 ranged (1d8+4/×3)','5 ft./5 ft.','+16','+12','+13',18,14,14,10,12,12,'Handle Animal +4, Hide +6, Listen +9, Move Silently +8, Spot +13, Survival +5','Alertness, Cleave, Combat Reflexes, Exotic Weapon Proficiency (bastard Sword), Improved Critical (bastard sword), Improved Critical (bite), Improved Natural Armor, Improved Natural Attack (bite), Iron WillB, Power Attack, Run, Stealthy, TrackB, Weapon Focus (bastard sword), Weapon Focus (bite), Weapon Specialization (bastard sword)','{"special_attacks":"—","special_qualities":"Alternate form, wolf empathy, low-light vision, scent"}'::jsonb,'Stronger, hardier, and more deadly than its lesser fellows, the werewolf lord is a murderous beast that delights in wreaking havoc.

The werewolf lord presented here is a 10th-level human fighter and natural lycanthrope, using the following base ability scores: Str 16, Dex 14, Con 14, Int 10, Wis 10, Cha 12.

#### Combat

Werewolf lords can assume a hybrid form as well as an animal form. In dire wolf form, they can trip just as normal wolves do. In hybrid form, they can wield weapons or fight with their claws.

**Alternate Form (Su):** A werewolf lord can assume a bipedal hybrid form or the form of a dire wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf lord’s bite attack in wolf or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf lord in dire wolf form that hits with a bite attack can attempt to trip the opponent (+15 check modifier) as a free action without making a touch attack or provoking an attack of opportunity. If the attempt fails, the opponent cannot react to trip the werewolf lord.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf lord in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

_Possessions: +2 mithral chain shirt, +3 heavy shield, +2 bastard sword, gauntlets of ogre power, cloak of resistance +2,_ masterwork composite longbow (+4 Str bonus).','{"full_attack":"+2 bastard sword +21/+16/+11 melee (1d10+8/17–20) or masterwork composite longbow (+4 Str bonus) +17/+12/+7ranged (1d8+4/×3)","environment":"Temperate forests","organization":"Solitary, pair, or pack (1–2 werewolf lords plus 2–4 werewolves plus 5–8 wolves)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"10d10+20 plus 6d8+30 (132 hp)","hit_points":132,"base_attack_grapple":"+14/+18","attack":"+2 bastard sword +21 melee (1d10+8/17–20) or masterwork composite longbow (+4 Str bonus) (2d8+15/17–20) +17 ranged (1d8+4/×3)","full_attack":"+2 bastard sword +21/+16/+11 melee (1d10+8/17–20) or masterwork composite longbow (+4 Str bonus) +17/+12/+7ranged (1d8+4/×3)","space_reach":"5 ft./5 ft.","saves":"Fort +16, Ref +12, Will +13","abilities":{"str":"18","dex":"14","con":"14","int":"10","wis":"12","cha":"12"},"skills":"Handle Animal +4, Hide +6, Listen +9, Move Silently +8, Spot +13, Survival +5","feats":"Alertness, Cleave, Combat Reflexes, Exotic Weapon Proficiency (bastard Sword), Improved Critical (bastard sword), Improved Critical (bite), Improved Natural Armor, Improved Natural Attack (bite), Iron WillB, Power Attack, Run, Stealthy, TrackB, Weapon Focus (bastard sword), Weapon Focus (bite), Weapon Specialization (bastard sword)","special_attacks":"—","special_qualities":"Alternate form, wolf empathy, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_lord_dire_wolf_form','Werewolf Lord, Dire Wolf Form','Werewolf Lord, Dire Wolf Form','14','Large','Humanoid','Always chaotic evil','10d10+20 plus 6d8+30 (132 hp)',132,'+4','','19 (–1 size, +4 Dex, +6 natural), touch 13, flat-footed 15','+14/+29','Bite +25 melee (2d6+16/19–20)','10 ft./5 ft.','+17','+12','+11',32,18,20,10,12,12,'Handle Animal +4, Hide +6, Listen +9, Move Silently +12, Spot +13, Survival +5*','(same as human form)','{"special_attacks":"Curse of lycanthropy, trip","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Stronger, hardier, and more deadly than its lesser fellows, the werewolf lord is a murderous beast that delights in wreaking havoc.

The werewolf lord presented here is a 10th-level human fighter and natural lycanthrope, using the following base ability scores: Str 16, Dex 14, Con 14, Int 10, Wis 10, Cha 12.

#### Combat

Werewolf lords can assume a hybrid form as well as an animal form. In dire wolf form, they can trip just as normal wolves do. In hybrid form, they can wield weapons or fight with their claws.

**Alternate Form (Su):** A werewolf lord can assume a bipedal hybrid form or the form of a dire wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf lord’s bite attack in wolf or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf lord in dire wolf form that hits with a bite attack can attempt to trip the opponent (+15 check modifier) as a free action without making a touch attack or provoking an attack of opportunity. If the attempt fails, the opponent cannot react to trip the werewolf lord.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf lord in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

_Possessions: +2 mithral chain shirt, +3 heavy shield, +2 bastard sword, gauntlets of ogre power, cloak of resistance +2,_ masterwork composite longbow (+4 Str bonus).','{"full_attack":"Bite +25 melee (2d6+16/19–20)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"10d10+20 plus 6d8+30 (132 hp)","hit_points":132,"base_attack_grapple":"+14/+29","attack":"Bite +25 melee (2d6+16/19–20)","full_attack":"Bite +25 melee (2d6+16/19–20)","space_reach":"10 ft./5 ft.","saves":"Fort +17, Ref +12, Will +11","abilities":{"str":"32","dex":"18","con":"20","int":"10","wis":"12","cha":"12"},"skills":"Handle Animal +4, Hide +6, Listen +9, Move Silently +12, Spot +13, Survival +5*","feats":"(same as human form)","special_attacks":"Curse of lycanthropy, trip","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('werewolf_lord_hybrid_form','Werewolf Lord, Hybrid Form','Werewolf Lord, Hybrid Form','14','Large','Humanoid','Always chaotic evil','10d10+20 plus 6d8+30 (132 hp)',132,'+4','','19 (–1 size, +4 Dex, +6 natural), touch 13, flat-footed 15','+14/+27','Claw +24 melee (1d6+11) or +2 bastard sword +27 melee','10 ft./10 ft.','+17','+12','+11',32,18,20,10,12,12,'Handle Animal +4, Hide +6, Listen +9, Move Silently +12, Spot +13, Survival +5*','(same as human form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"}'::jsonb,'Stronger, hardier, and more deadly than its lesser fellows, the werewolf lord is a murderous beast that delights in wreaking havoc.

The werewolf lord presented here is a 10th-level human fighter and natural lycanthrope, using the following base ability scores: Str 16, Dex 14, Con 14, Int 10, Wis 10, Cha 12.

#### Combat

Werewolf lords can assume a hybrid form as well as an animal form. In dire wolf form, they can trip just as normal wolves do. In hybrid form, they can wield weapons or fight with their claws.

**Alternate Form (Su):** A werewolf lord can assume a bipedal hybrid form or the form of a dire wolf.

**Curse of Lycanthropy (Su):** Any humanoid or giant hit by a werewolf lord’s bite attack in wolf or hybrid form must succeed on a DC 15 Fortitude save or contract lycanthropy.

**Trip (Ex):** A werewolf lord in dire wolf form that hits with a bite attack can attempt to trip the opponent (+15 check modifier) as a free action without making a touch attack or provoking an attack of opportunity. If the attempt fails, the opponent cannot react to trip the werewolf lord.

**Wolf Empathy (Ex):** Communicate with wolves and dire wolves, and +4 racial bonus on Charisma-based checks against wolves and dire wolves.

**Skills:** \*A werewolf lord in hybrid or wolf form gains a +4 racial bonus on Survival checks when tracking by scent.

_Possessions: +2 mithral chain shirt, +3 heavy shield, +2 bastard sword, gauntlets of ogre power, cloak of resistance +2,_ masterwork composite longbow (+4 Str bonus).','{"full_attack":"2 claws +24 melee (1d6+11) and bite +20 melee (2d6+5/19–20); or +2 bastard sword +27/+22/+17 melee (2d8+15/17–20) and bite +20 melee (2d6+5/19–20)","environment":"Temperate forests","organization":"(same as human form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+3","statblock":{"hit_dice":"10d10+20 plus 6d8+30 (132 hp)","hit_points":132,"base_attack_grapple":"+14/+27","attack":"Claw +24 melee (1d6+11) or +2 bastard sword +27 melee","full_attack":"2 claws +24 melee (1d6+11) and bite +20 melee (2d6+5/19–20); or +2 bastard sword +27/+22/+17 melee (2d8+15/17–20) and bite +20 melee (2d6+5/19–20)","space_reach":"10 ft./10 ft.","saves":"Fort +17, Ref +12, Will +11","abilities":{"str":"32","dex":"18","con":"20","int":"10","wis":"12","cha":"12"},"skills":"Handle Animal +4, Hide +6, Listen +9, Move Silently +12, Spot +13, Survival +5*","feats":"(same as human form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, wolf empathy, damage reduction 10/silver, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('hill_giant_dire_wereboar_giant_form','Hill Giant Dire Wereboar Giant Form','Hill Giant Dire Wereboar Giant Form','11','Large','Giant (Shapechanger)','Always neutral','12d8+51 plus 7d8+49 (185 hp)',185,'–1','30 ft. in hide armor (6 squares); base speed 40 ft.','22 (–1 size, –1 Dex, +11 natural, +3 hide armor), touch 8, flat-footed 22','+14/+25','Greatclub +21 melee (2d8+10) or slam +20 melee (1d4+7) or rock +12 ranged (2d6+7)','10 ft./10 ft.','+17','+8','+12',25,8,19,6,12,7,'Climb +10, Jump +10, Listen +10, Spot +12','AlertnessB, Cleave, Endurance, Improved Bull Rush, Improved Sunder, Iron WillB, Power Attack, Weapon Focus (greatclub)','{"special_attacks":"Rock throwing","special_qualities":"Alternate form, boar empathy, ferocity, low-light vision, rock catching, scent"}'::jsonb,'Dire wereboars in giant form look much like normal hill giants, though slightly stockier, and with coarser, stiffer hair and stiff. The dire wereboar described here is based on a hill giant and natural lycanthrope with normal ability scores for a hill giant.','{"full_attack":"Greatclub +21/+16 melee (2d8+10) or 2 slams +20 melee (1d4+7) or rock +12 ranged (2d6+7)","environment":"Temperate hills","organization":"Solitary, pair, brood (3–4), or troupe (2–4 plus 1–4 dire boars)","treasure":"Standard","advancement":"By character class","level_adjustment":"+7","statblock":{"hit_dice":"12d8+51 plus 7d8+49 (185 hp)","hit_points":185,"base_attack_grapple":"+14/+25","attack":"Greatclub +21 melee (2d8+10) or slam +20 melee (1d4+7) or rock +12 ranged (2d6+7)","full_attack":"Greatclub +21/+16 melee (2d8+10) or 2 slams +20 melee (1d4+7) or rock +12 ranged (2d6+7)","space_reach":"10 ft./10 ft.","saves":"Fort +17, Ref +8, Will +12","abilities":{"str":"25","dex":"8","con":"19","int":"6","wis":"12","cha":"7"},"skills":"Climb +10, Jump +10, Listen +10, Spot +12","feats":"AlertnessB, Cleave, Endurance, Improved Bull Rush, Improved Sunder, Iron WillB, Power Attack, Weapon Focus (greatclub)","special_attacks":"Rock throwing","special_qualities":"Alternate form, boar empathy, ferocity, low-light vision, rock catching, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('hill_giant_dire_wereboar_dire_boar_form','Hill Giant Dire Wereboar Dire Boar Form','Hill Giant Dire Wereboar Dire Boar Form','11','Large','Giant (Shapechanger)','Always neutral','12d8+51 plus 7d8+49 (185 hp)',185,'–1','40 ft. (8 squares)','16 (–1 size, –1 Dex, +8 natural), touch 8, flat-footed 16','+14/+33','Gore +28 melee (1d8+22)','10 ft./5 ft.','+20','+8','+12',41,8,25,6,12,7,'Climb +18, Jump +22, Listen +10, Spot +12','(same as giant form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"}'::jsonb,'Dire wereboars in giant form look much like normal hill giants, though slightly stockier, and with coarser, stiffer hair and stiff. The dire wereboar described here is based on a hill giant and natural lycanthrope with normal ability scores for a hill giant.','{"full_attack":"Gore +28 melee (1d8+22)","environment":"Temperate hills","organization":"(same as giant form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+7","statblock":{"hit_dice":"12d8+51 plus 7d8+49 (185 hp)","hit_points":185,"base_attack_grapple":"+14/+33","attack":"Gore +28 melee (1d8+22)","full_attack":"Gore +28 melee (1d8+22)","space_reach":"10 ft./5 ft.","saves":"Fort +20, Ref +8, Will +12","abilities":{"str":"41","dex":"8","con":"25","int":"6","wis":"12","cha":"7"},"skills":"Climb +18, Jump +22, Listen +10, Spot +12","feats":"(same as giant form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('hill_giant_dire_wereboar_hybrid_boar_form','Hill Giant Dire Wereboar Hybrid Boar Form','Hill Giant Dire Wereboar Hybrid Boar Form','11','Large','Giant (Shapechanger)','Always neutral','12d8+51 plus 7d8+49 (185 hp)',185,'–1','40 ft. (8 squares)','19 (–1 size, –1 Dex, +11 natural), touch 8, flat-footed 19','+14/+33','Greatclub +29 melee (2d8+22) or claw +28 melee (1d6+15)','10 ft./10 ft.','+20','+8','+12',41,8,25,6,12,7,'Climb +18, Jump +22, Listen 10, Spot +12','(same as giant form)','{"special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"}'::jsonb,'Dire wereboars in giant form look much like normal hill giants, though slightly stockier, and with coarser, stiffer hair and stiff. The dire wereboar described here is based on a hill giant and natural lycanthrope with normal ability scores for a hill giant.','{"full_attack":"Greatclub +29 melee (2d8+22) and gore +23 melee (1d8+7); or 2 claws +28 melee (1d6+15) and gore +23 melee (1d8+7)","environment":"Temperate hills","organization":"(same as giant form)","treasure":"Standard","advancement":"By character class","level_adjustment":"+7","statblock":{"hit_dice":"12d8+51 plus 7d8+49 (185 hp)","hit_points":185,"base_attack_grapple":"+14/+33","attack":"Greatclub +29 melee (2d8+22) or claw +28 melee (1d6+15)","full_attack":"Greatclub +29 melee (2d8+22) and gore +23 melee (1d8+7); or 2 claws +28 melee (1d6+15) and gore +23 melee (1d8+7)","space_reach":"10 ft./10 ft.","saves":"Fort +20, Ref +8, Will +12","abilities":{"str":"41","dex":"8","con":"25","int":"6","wis":"12","cha":"7"},"skills":"Climb +18, Jump +22, Listen 10, Spot +12","feats":"(same as giant form)","special_attacks":"Curse of lycanthropy","special_qualities":"Alternate form, boar empathy, damage reduction 10/silver, ferocity, low-light vision, scent"},"source_file":"monsters-k-l.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-k-l.html',true),
('magmin','Magmin','Magmin','3','Small','Elemental (Fire, Extraplanar)','Always chaotic neutral','2d8+2 (11 hp)',11,'+0','30 ft. (6 squares)','17 (+1 size, +6 natural), touch 11, flat-footed 17','+1/–1','Burning touch +4 melee touch (1d8 fire plus combustion) or slam +4 melee (1d3+3 plus combustion)','5 ft./5 ft.','+3','+3','+0',15,11,13,8,10,10,'Climb +4, Spot +3','Great Fortitude','{"special_attacks":"Combustion, fiery aura","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., elemental traits, immunity to fire, melt weapons, vulnerability to cold"}'::jsonb,'Magmins are small, human-shaped beings from the Elemental Plane of Fire that radiate intense heat and are wreathed in an aura of searing flames. A typical magmin is 4 feet tall and weighs 400 pounds.

Magmins speak Ignan.

### Combat

Although small, magmins are dangerous opponents. Their touch is effective against those who lack protection or immunity from heat and flames, but if faced with opponents who have immunity to fire, magmins rely on their slam attack. In any case, magmins are not valiant fighters. They usually flee if injured, although often only far enough to set up a fiery ambush for their enemies.

A magmin’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Combustion (Ex):** Anyone a magmin touches must succeed on a DC 12 Reflex save or take an extra 1d8 points of fire damage as clothes ignite or armor becomes searing hot. The damage continues for another 1d4+2 rounds after the magmin’s last successful attack. Magmins can also ignite flammable materials with a touch. The save DC is Constitution-based.

**Fiery Aura (Ex):** Anyone within 20 feet of a magmin must succeed on a DC 12 Fortitude save or take 1d6 points of heat damage per round from the intense heat. The save DC is Constitution-based.

**Melt Weapons (Ex):** Any metal weapon that strikes a magmin must succeed on a DC 12 Fortitude save or melt away into slag. The save DC is Constitution-based.','{"full_attack":"Burning touch +4 melee touch (1d8 fire plus combustion) or slam +4 melee (1d3+3 plus combustion)","environment":"Elemental Plane of Fire","organization":"Solitary, gang (2–4), or squad (6–10)","treasure":"Standard coins; standard goods (nonflammables only); standard items (nonflammables only)","advancement":"3–4 HD (Small); 5–6 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/–1","attack":"Burning touch +4 melee touch (1d8 fire plus combustion) or slam +4 melee (1d3+3 plus combustion)","full_attack":"Burning touch +4 melee touch (1d8 fire plus combustion) or slam +4 melee (1d3+3 plus combustion)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +3, Will +0","abilities":{"str":"15","dex":"11","con":"13","int":"8","wis":"10","cha":"10"},"skills":"Climb +4, Spot +3","feats":"Great Fortitude","special_attacks":"Combustion, fiery aura","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., elemental traits, immunity to fire, melt weapons, vulnerability to cold"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('manticore','Manticore','Manticore','5','Large','Magical Beast','Usually lawful evil','6d10+24 (57 hp)',57,'+2','30 ft. (6 squares), fly 50 ft. (clumsy)','17 (–1 size, +2 Dex, +6 natural), touch 11, flat-footed 15','+6/+15','Claw +10 melee (2d4+5) or 6 spikes +8 ranged (1d8+2/19–20)','10 ft./5 ft.','+9','+7','+3',20,15,19,7,12,9,'Listen +5, Spot +9, Survival +1','Flyby Attack, Multiattack, TrackB, Weapon Focus (spikes)','{"special_attacks":"Spikes","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'A typical manticore is about 10 feet long and weighs about 1,000 pounds. Manticores speak Common.

### Combat

A manticore begins most attacks with a volley of spikes, then closes. In the outdoors, it often uses its powerful wings to stay aloft during battle.

**Spikes (Ex):** With a snap of its tail, a manticore can loose a volley of six spikes as a standard action (make an attack roll for each spike). This attack has a range of 180 feet with no range increment. All targets must be within 30 feet of each other. The creature can launch only twenty-four spikes in any 24-hour period.

**Skills:** \*Manticores have a +4 racial bonus on Spot checks.','{"full_attack":"2 claws +10 melee (2d4+5) and bite +8 melee (1d8+2); or 6 spikes +8 ranged (1d8+2/19–20)","environment":"Warm marshes","organization":"Solitary, pair, or pride (3–6)","treasure":"Standard","advancement":"7–16 HD (Large); 17–18 HD (Huge)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"6d10+24 (57 hp)","hit_points":57,"base_attack_grapple":"+6/+15","attack":"Claw +10 melee (2d4+5) or 6 spikes +8 ranged (1d8+2/19–20)","full_attack":"2 claws +10 melee (2d4+5) and bite +8 melee (1d8+2); or 6 spikes +8 ranged (1d8+2/19–20)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +7, Will +3","abilities":{"str":"20","dex":"15","con":"19","int":"7","wis":"12","cha":"9"},"skills":"Listen +5, Spot +9, Survival +1","feats":"Flyby Attack, Multiattack, TrackB, Weapon Focus (spikes)","special_attacks":"Spikes","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('medusa','Medusa','Medusa','7','Medium','Monstrous Humanoid','Usually lawful evil','6d8+6 (33 hp)',33,'+2','30 ft. (6 squares)','15 (+2 Dex, +3 natural), touch 12, flat-footed 13','+6/+6','Shortbow +8 ranged (1d6/x3) or dagger +8 melee (1d4/19–20) or snakes +8 melee (1d4 plus poison)','5 ft./5 ft.','+3','+7','+6',10,15,12,12,13,15,'Bluff +9, Diplomacy +4, Disguise +9 (+11 acting), Intimidate +4, Move Silently +8, Spot +8','Point Blank Shot, Precise Shot, Weapon Finesse','{"special_attacks":"Petrifying gaze, poison","special_qualities":"Darkvision 60 ft."}'::jsonb,'A medusa is indistinguishable from a normal human at distances greater than 30 feet (or closer, if its face is concealed). The creature often wears garments that enhance its body while hiding its face behind a hood or veil.

A typical medusa is 5 to 6 feet tall and about the same weight as a human.

Medusas speak Common.

### Combat

A medusa tries to disguise its true nature until the intended victim is within range of its petrifying gaze, using subterfuge and bluffing games to convince the target that there is no danger. It uses normal weapons to attack those who avert their eyes or survive its gaze, while its poisonous snakes strike at adjacent opponents.

**Petrifying Gaze (Su):** Turn to stone permanently, 30 feet, Fortitude DC 15 negates. The save DC is Charisma-based.

**Poison (Ex):** Injury, Fortitude DC 14, initial damage 1d6 Str, secondary damage 2d6 Str. The save DC is Constitution-based.','{"full_attack":"Shortbow +8/+3 ranged (1d6/x3); or dagger +8/+3 melee (1d4/19–20) and snakes +3 melee (1d4 plus poison)","environment":"Temperate marshes","organization":"Solitary or covey (2–4)","treasure":"Double standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"6d8+6 (33 hp)","hit_points":33,"base_attack_grapple":"+6/+6","attack":"Shortbow +8 ranged (1d6/x3) or dagger +8 melee (1d4/19–20) or snakes +8 melee (1d4 plus poison)","full_attack":"Shortbow +8/+3 ranged (1d6/x3); or dagger +8/+3 melee (1d4/19–20) and snakes +3 melee (1d4 plus poison)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +7, Will +6","abilities":{"str":"10","dex":"15","con":"12","int":"12","wis":"13","cha":"15"},"skills":"Bluff +9, Diplomacy +4, Disguise +9 (+11 acting), Intimidate +4, Move Silently +8, Spot +8","feats":"Point Blank Shot, Precise Shot, Weapon Finesse","special_attacks":"Petrifying gaze, poison","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('air_mephit','Air Mephit','Air Mephit','3','Small','Outsider (Air, Extraplanar)','Usually neutral','3d8 (13 hp)',13,'+7','30 ft. (6 squares), fly 60 ft. (perfect)','17 (+1 size, +3 Dex, +3 natural), touch 14, flat-footed 14','+3/–1','Claw +4 melee (1d3)','5 ft./5 ft.','+3','+6','+3',10,17,10,6,11,15,'Bluff +8, Escape Artist +9, Hide +13, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Air mephits come from the Elemental Plane of Air. An air mephit is about 4 feet tall and weighs about 1 pound.

Air mephits speak Common and Auran.

#### Combat

**Breath Weapon (Su):** 15-foot cone of dust and grit, damage 1d8, Reflex DC 12 half. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour an air mephit can surround itself with vapor, duplicating the effect of a _blur_ spell (caster level 3rd). Once per day it can use _gust of wind_ (DC 14, caster level 6th) . The save DC is Charisma-based.

**Fast Healing (Ex):** An air mephit heals only if exposed to moving air, be it a breeze, a draft, a spell effect, or even the mephit fanning itself.','{"full_attack":"2 claws +4 melee (1d3)","environment":"Elemental Plane of Air","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3)","full_attack":"2 claws +4 melee (1d3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +6, Will +3","abilities":{"str":"10","dex":"17","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +9, Hide +13, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('dust_mephit','Dust Mephit','Dust Mephit','3','Small','Outsider (Air, Extraplanar)','Usually neutral','3d8 (13 hp)',13,'+7','30 ft. (6 squares), fly 50 ft. (perfect)','17 (+1 size, +3 Dex, +3 natural), touch 14, flat-footed 14','+3/–1','Claw +4 melee (1d3)','5 ft./5 ft.','+3','+6','+3',10,17,10,6,11,15,'Bluff +8, Escape Artist +9, Hide +13, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Dust mephits come from the Elemental Plane of Air.

A dust mephit is about 4 feet tall and weighs about 2 pounds.

Dust mephits speak Common and Auran.

#### Combat

**Breath Weapon (Su):** 10-foot cone of irritating particles, damage 1d4, Reflex DC 12 half. Living creatures that fail their saves are tormented by itching skin and burning eyes. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour, a dust mephit can surround itself with a plume of dust, duplicating the effect of a _blur_ spell (caster level 3rd). Once per day it can create a mass of roiling dust that duplicates the effect of _wind wall_ (DC 15, caster level 6th). The save DC is Charisma-based.

**Fast Healing (Ex):** A dust mephit heals only if in an arid, dusty environment.','{"full_attack":"2 claws +4 melee (1d3)","environment":"Elemental Plane of Air","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3)","full_attack":"2 claws +4 melee (1d3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +6, Will +3","abilities":{"str":"10","dex":"17","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +9, Hide +13, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('earth_mephit','Earth Mephit','Earth Mephit','3','Small','Outsider (Earth, Extraplanar)','Usually neutral','3d8+6 (19 hp)',19,'–1','30 ft. (6 squares), fly 40 ft. (average)','16 (+1 size, –1 Dex, +6 natural), touch 10, flat-footed 16','+3/+2','Claw +7 melee (1d3+3)','5 ft./5 ft.','+4','+2','+3',17,8,13,6,11,15,'Bluff +8, Escape Artist +5, Hide +9, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +5, Spot +6, Use Rope –1 (+1 with bindings)','Power Attack, Toughness','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Change size, damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Earth mephits come from the Elemental Plane of Earth.

An earth mephit is about 4 feet tall and weighs about 80 pounds.

Earth mephits speak Common and Terran.

#### Combat

**Breath Weapon (Su):** 15-foot cone of rock shards and pebbles, damage 1d8, Reflex DC 13 half. The save DC is Constitution-based and includes a +1 racial bonus.

Spell-Like Abilities: 1/day—_soften earth and stone_. Caster level 6th.

**_Change Size_ (Sp):** Once per hour, an earth mephit can magically change its size. This works just like an _enlarge person_ spell, except that the power works only on the earth mephit. This is the equivalent of a 2nd-level spell.

**Fast Healing (Ex):** An earth mephit heals only if it is underground or buried up to its waist in earth.','{"full_attack":"2 claws +7 melee (1d3+3)","environment":"Elemental Plane of Earth","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8+6 (19 hp)","hit_points":19,"base_attack_grapple":"+3/+2","attack":"Claw +7 melee (1d3+3)","full_attack":"2 claws +7 melee (1d3+3)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +2, Will +3","abilities":{"str":"17","dex":"8","con":"13","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +5, Hide +9, Diplomacy +4, Disguise +2 (+4 acting), Intimidate +4, Listen +6, Move Silently +5, Spot +6, Use Rope –1 (+1 with bindings)","feats":"Power Attack, Toughness","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Change size, damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('fire_mephit','Fire Mephit','Fire Mephit','3','Small','Outsider (Extraplanar, Fire)','Usually neutral','3d8 (13 hp)',13,'+5','30 ft. (6 squares), fly 50 ft. (average)','16 (+1 size, +1 Dex, +4 natural), touch 12, flat-footed 15','+3/–1','Claw +4 melee (1d3 and 1d4 fire)','5 ft./5 ft.','+3','+4','+3',10,13,10,6,11,15,'Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., immunity to fire, fast healing 2, vulnerability to cold"}'::jsonb,'Fire mephits come from the Elemental Plane of Fire.

A fire mephit is about 4 feet tall and weighs about 1 pound.

Fire mephits speak Common and Ignan.

#### Combat

**Breath Weapon (Su):** 15-foot cone, damage 1d8 fire, Reflex half DC 12. The save DC is Constitution-based and includes a +1 racial adjustment.

**Spell-Like Abilities:** 1/hour—_scorching ray_ (DC 14) as the spell cast by a 3rd-level sorcerer; 1/day—_heat metal_ (DC 14). Caster level 6th. The save DC is Charisma-based.

**Fast Healing (Ex):** A fire mephit heals only if it is touching a flame at least as large as a torch.','{"full_attack":"2 claws +4 melee (1d3 and 1d4 fire)","environment":"Elemental Plane of Fire","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3 and 1d4 fire)","full_attack":"2 claws +4 melee (1d3 and 1d4 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +3","abilities":{"str":"10","dex":"13","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., immunity to fire, fast healing 2, vulnerability to cold"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('ice_mephit','Ice Mephit','Ice Mephit','3','Small','Outsider (Air, Cold, Extraplanar)','Usually neutral','3d8 (13 hp)',13,'+7','30 ft. (6 squares), fly 50 ft. (perfect)','18 (+1 size, +3 Dex, +4 natural), touch 14, flat-footed 15','+3/–1','Claw +4 melee (1d3 plus 1d4 cold)','5 ft./5 ft.','+3','+6','+3',10,17,10,6,11,15,'Bluff +8, Escape Artist +9, Hide +13, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to cold, vulnerability to fire"}'::jsonb,'Ice mephits come from the Elemental Plane of Air.

Ice mephits have a cold, aloof demeanor. Each one is about 4 feet tall and weighs about 30 pounds.

Ice mephits speak Common and Auran.

#### Combat

**Breath Weapon (Su):** 10-foot cone of ice shards, damage 1d4 cold, Reflex DC 12 half. Living creatures that fail their saves are tormented by frostbitten skin and frozen eyes unless they have immunity to cold or are otherwise protected. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** 1/hour—_magic missile_ (caster level 3rd); 1/day—_chill metal_ (DC 14, caster level 6th). The save DC is Charisma-based.

**Fast Healing (Ex):** An ice mephit heals only if it is touching a piece of ice of at least Tiny size or if the ambient temperature is 32°F. or below.','{"full_attack":"2 claws +4 melee (1d3 plus 1d4 cold)","environment":"Elemental Plane of Air","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3 plus 1d4 cold)","full_attack":"2 claws +4 melee (1d3 plus 1d4 cold)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +6, Will +3","abilities":{"str":"10","dex":"17","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +9, Hide +13, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +9, Spot +6, Use Rope +3 (+5 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to cold, vulnerability to fire"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('magma_mephit','Magma Mephit','Magma Mephit','3','Small','Outsider (Fire, Extraplanar)','Usually neutral','3d8 (13 hp)',13,'+5','30 ft. (6 squares), fly 50 ft. (average)','16 (+1 size, +1 Dex, +4 natural), touch 12, flat-footed 15','+3/–1','Claw +4 melee (1d3 plus 1d4 fire)','5 ft./5 ft.','+3','+4','+3',10,13,10,6,11,15,'Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to fire, vulnerability to cold"}'::jsonb,'Magma mephits come from the Elemental Plane of Fire. Magma mephits are slow-witted and brutish. Each one is about 4 feet tall and weighs about 60 pounds.

Magma mephits speak Common and Ignan.

#### Combat

**Breath Weapon (Su):** 10-foot cone of magma, damage 1d4 fire, Reflex DC 12 half. Living creatures that fail their saves are tormented by burned skin and seared eyes unless they have immunity to fire or are otherwise protected. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is onstitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour, a magma mephit can use _shapechange_ to take the form of a pool of lava 3 feet in diameter and 6 inches deep. The mephit’s damage reduction improves to 20/magic when in this form. The mephit can’t attack while in lava form but can use other spell-like abilities. It can move at a speed of 10 feet, but it can’t run. In this form the mephit can pass through small holes or narrow openings, even mere cracks. The pool’s touch ignites flammable materials such as paper, straw, or dry wood.

Once per day a magma mephit can use _pyrotechnics_ (DC 14). It can use itself as the fire source without harm. Caster level 6th. The save DC is Charisma-based.

**Fast Healing (Ex):** A magma mephit heals only if it is touching magma, lava, or a flame at least as large as a torch.','{"full_attack":"2 claws +4 melee (1d3 plus 1d4 fire)","environment":"Elemental Plane of Fire","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3 plus 1d4 fire)","full_attack":"2 claws +4 melee (1d3 plus 1d4 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +3","abilities":{"str":"10","dex":"13","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to fire, vulnerability to cold"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('ooze_mephit','Ooze Mephit','Ooze Mephit','3','Small','Outsider (Extraplanar, Water)','Usually neutral','3d8+6 (19 hp)',19,'+0','30 ft. (6 squares), fly 40 ft. (average), swim 30 ft.','16 (+1 size, +5 natural), touch 11, flat-footed 16','+3/+1','Claw +6 melee (1d3+2)','5 ft./5 ft.','+4','+3','+3',14,10,13,6,11,15,'Bluff +8, Escape Artist +6, Hide +10, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +6, Spot +6, Swim +10, Use Rope +0 (+2 with bindings)','Power Attack, Toughness','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Ooze mephits come from the Elemental Plane of Water. An ooze mephit is about 4 feet tall and weighs about 30 pounds.

Ooze mephits speak Common and Aquan.

#### Combat

**Breath Weapon (Su):** 10-foot cone of caustic liquid, damage 1d4 acid, Reflex DC 13 half. Living creatures that fail their saves are tormented by itching skin and burning eyes unless they have immunity to acid or are otherwise protected. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour an ooze mephit can hurl an acidic blob that functions like _acid arrow_ (caster level 3rd). Once per day it can create a mass of smelly fog that duplicates the effect of _stinking cloud_ (DC 15, caster level 6th). The save DC is Charisma-based.

**Fast Healing (Ex):** An ooze mephit heals only if in a wet or muddy environment.

**Skills:** An ooze mephit has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +6 melee (1d3+2)","environment":"Elemental Plane of Water","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8+6 (19 hp)","hit_points":19,"base_attack_grapple":"+3/+1","attack":"Claw +6 melee (1d3+2)","full_attack":"2 claws +6 melee (1d3+2)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +3, Will +3","abilities":{"str":"14","dex":"10","con":"13","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +6, Hide +10, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +6, Spot +6, Swim +10, Use Rope +0 (+2 with bindings)","feats":"Power Attack, Toughness","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('salt_mephit','Salt Mephit','Salt Mephit','3','Small','Outsider (Earth, Extraplanar)','Usually neutral','3d8+6 (19 hp)',19,'–1','30 ft. (6 squares), fly 40 ft. (average)','16 (+1 size, –1 Dex, +6 natural), touch 10, flat-footed 16','+3/+2','Claw +7 melee (1d3+3)','5 ft./5 ft.','+4','+2','+3',17,8,13,6,11,15,'Bluff +8, Escape Artist +5, Hide +9, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +5, Spot +6, Use Rope –1 (+1 with bindings)','Power Attack, Toughness','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Salt mephits come from the Elemental Plane of Earth.

Salt mephits are sarcastic creatures who loathe water and moisture of any kind. Each one is about 4 feet tall and weighs about 80 pounds.

Salt mephits speak Common and Terran.

#### Combat

**Breath Weapon (Su):** 10-foot cone of salt crystals, damage 1d4, Reflex DC 13 half. Living creatures that fail their saves are tormented by itching skin and burning eyes. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour a salt mephit can use _glitterdust_ (DC 14, caster level 3rd).

Once per day it can draw the moisture from an area in a 20-foot radius centered on itself. Living creatures within range take 2d8 points of damage (Fortitude DC 14 half; caster level 6th). This effect is especially devastating to plant creatures and aquatic creatures, which take a –2 penalty on their saving throws. This ability is the equivalent of a 2nd-level spell. The save DCs are Charisma-based.

**Fast Healing (Ex):** A salt mephit heals only if in an arid environment.','{"full_attack":"2 claws +7 melee (1d3+3)","environment":"Elemental Plane of Earth","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8+6 (19 hp)","hit_points":19,"base_attack_grapple":"+3/+2","attack":"Claw +7 melee (1d3+3)","full_attack":"2 claws +7 melee (1d3+3)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +2, Will +3","abilities":{"str":"17","dex":"8","con":"13","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +5, Hide +9, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +5, Spot +6, Use Rope –1 (+1 with bindings)","feats":"Power Attack, Toughness","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('steam_mephit','Steam Mephit','Steam Mephit','3','Small','Outsider (Extraplanar, Fire)','Usually neutral','3d8 (13 hp)',13,'+5','30 ft. (6 squares), fly 50 ft. (average)','16 (+1 size, +1 Dex, +4 natural), touch 12, flat-footed 15','+3/–1','Claw +4 melee (1d3 plus 1d4 fire)','5 ft./5 ft.','+3','+4','+3',10,13,10,6,11,15,'Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)','Dodge, Improved Initiative','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to fire, vulnerability to cold"}'::jsonb,'Steam mephits come from the Elemental Plane of Fire.

Steam mephits are bossy creatures who consider themselves the lords of all their kind. Each one is about 4 feet tall and weighs about 2 pounds.

Steam mephits speak Common and Ignan.

#### Combat

Unlike other mephits, steam mephits rush into combat eagerly, driven by an oversized ego.

**Breath Weapon (Su):** 10-foot cone of steam, damage 1d4 fire, Reflex DC 12 half. Living creatures that fail their saves are tormented by burned skin and seared eyes unless they have immunity to fire or are otherwise protected. This effect imposes a –4 penalty to AC and a –2 penalty on attack rolls for 3 rounds. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour a steam mephit can surround itself with a plume of vapor, duplicating the effect of a _blur_ spell (caster level 3rd). Once per day it can create a rainstorm of boiling water that affects a 20-foot-square area. Living creatures caught in the storm take 2d6 points of fire damage (Reflex DC 14 half; caster level 6th). This ability is the equivalent of a 2nd-level spell. The save DCs are Charisma-based.

**Fast Healing (Ex):** A steam mephit heals only if it is touching boiling water or is in a hot, humid area.','{"full_attack":"2 claws +4 melee (1d3 plus 1d4 fire)","environment":"Elemental Plane of Fire","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–1","attack":"Claw +4 melee (1d3 plus 1d4 fire)","full_attack":"2 claws +4 melee (1d3 plus 1d4 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +3","abilities":{"str":"10","dex":"13","con":"10","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +7, Hide +11, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +7, Spot +6, Use Rope +1 (+3 with bindings)","feats":"Dodge, Improved Initiative","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2, immunity to fire, vulnerability to cold"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('water_mephit','Water Mephit','Water Mephit','3','Small','Outsider (Extraplanar, Water)','Usually neutral','3d8+6 (19 hp)',19,'+0','30 ft. (6 squares), fly 40 ft. (average) , swim 30 ft.','16 (+1 size, +5 natural), touch 11, flat-footed 16','+3/+1','Claw +6 melee (1d3+2)','5 ft./5 ft.','+4','+3','+3',14,10,13,6,11,15,'Bluff +8, Escape Artist +6, Hide +10, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +6, Spot +6, Swim +10, Use Rope +0 (+2 with bindings)','Power Attack, Toughness','{"special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"}'::jsonb,'Water mephits come from the Elemental Plane of Water.

Water mephits are jaunty creatures with an unflagging sense of humor who quickly get on the nerves of everyone around them. Each one is about 4 feet tall and weighs about 30 pounds.

Water mephits speak Common and Aquan.

#### Combat

**Breath Weapon (Su):** 15-foot cone of caustic liquid, damage 1d8 acid, Reflex DC 13 half. The save DC is Constitution-based and includes a +1 racial bonus.

**Spell-Like Abilities:** Once per hour a water mephit can hurl an acidic blob that functions like _acid arrow_ (caster level 3rd). Once per day it can create a mass of smelly fog that duplicates the effect of a _stinking cloud_ spell (DC 15, caster level 6th). The save DC is Charisma-based.

**Fast Healing (Ex):** A water mephit heals only if it is exposed to rain or submerged up to its waist in water.

**Skills:** A water mephit has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered.

It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +6 melee (1d3+2)","environment":"Elemental Plane of Water","organization":"Solitary (1), gang (2–4 mephits of mixed types), or mob (5–12 mephits of mixed types)","treasure":"Standard","advancement":"4–6 HD (Small); 7–9 HD (Medium)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"3d8+6 (19 hp)","hit_points":19,"base_attack_grapple":"+3/+1","attack":"Claw +6 melee (1d3+2)","full_attack":"2 claws +6 melee (1d3+2)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +3, Will +3","abilities":{"str":"14","dex":"10","con":"13","int":"6","wis":"11","cha":"15"},"skills":"Bluff +8, Escape Artist +6, Hide +10, Listen +6, Diplomacy +4, Disguise +2 (+4 acting), Move Silently +6, Spot +6, Swim +10, Use Rope +0 (+2 with bindings)","feats":"Power Attack, Toughness","special_attacks":"Breath weapon, spell-like abilities, summon mephit","special_qualities":"Damage reduction 5/magic, darkvision 60 ft., fast healing 2"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('merfolk_1st_level_warrior','Merfolk, 1st-Level Warrior','Merfolk, 1st-Level Warrior','1/2','Medium','Humanoid (Aquatic)','Usually neutral','1d8+2 (6 hp)',6,'+1','5 ft. (1 square), swim 50 ft.','13 (+1 Dex, +2 leather), touch 11, flat-footed 12','+1/+2','Trident +2 melee (1d8+1) or heavy crossbow +2 ranged (1d10/19–20)','5 ft./5 ft.','+4','+1','–1',13,13,14,10,9,10,'Listen +3, Spot +3, Swim +9','Alertness','{"special_attacks":"—","special_qualities":"Amphibious, low-light vision"}'::jsonb,'A merfolk is about 8 feet long from the top of the head to the end of the tail, and weighs about 400 pounds.

Merfolk speak Common and Aquan.

Most merfolk encountered outside their home are warriors; the information in the statistics block is for one of 1st level.

### Combat

Merfolk favor heavy crossbows of shell and coral that fire bolts fashioned from blowfish spines, with an underwater range increment of 30 feet. Merfolk often barrage their enemies before closing, when they resort to tridents.

**Amphibious (Ex):** Merfolk can breathe both air and water, although they rarely travel more than a few feet from the water’s edge.

**Skills:** A merfolk has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

The merfolk warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Merfolk Characters

A merfolk’s favored class is bard.','{"full_attack":"Trident +2 melee (1d8+1) or heavy crossbow +2 ranged (1d10/19–20)","environment":"Temperate aquatic","organization":"Company (2–4), patrol (11–20 plus 2 3rd-level lieutenants and 1 leader of 3rd–6th level), or band (30–60 plus 1 3rd-level sergeant per 20 adults, 5 5th-level lieutenants, 3 7th-level captains, and 10 porpoises)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"1d8+2 (6 hp)","hit_points":6,"base_attack_grapple":"+1/+2","attack":"Trident +2 melee (1d8+1) or heavy crossbow +2 ranged (1d10/19–20)","full_attack":"Trident +2 melee (1d8+1) or heavy crossbow +2 ranged (1d10/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +1, Will –1","abilities":{"str":"13","dex":"13","con":"14","int":"10","wis":"9","cha":"10"},"skills":"Listen +3, Spot +3, Swim +9","feats":"Alertness","special_attacks":"—","special_qualities":"Amphibious, low-light vision"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('mimic','Mimic','Mimic','4','Large','Aberration (Shapechanger)','Usually neutral','7d8+21 (52 hp)',52,'+1','10 ft. (2 squares)','15 (–1 size, +1 Dex, +5 natural), touch 10, flat-footed 15','+5/+13','Slam +9 melee (1d8+4)','10 ft./10 ft.','+5','+5','+6',19,12,17,10,13,10,'Climb +9, Disguise +13, Listen +8, Spot +8','Alertness, Lightning Reflexes, Weapon Focus (slam)','{"special_attacks":"Adhesive, crush","special_qualities":"Darkvision 60 ft., immunity to acid, mimic shape"}'::jsonb,'A mimic can have almost any dimensions, but usually is not more than 10 feet long. A typical mimic has a volume of 150 cubic feet (5 feet by 5 feet by 6 feet) and weighs about 4,500 pounds.

Mimics speak Common.

### Combat

A mimic often surprises an unsuspecting adventurer, lashing out with a heavy pseudopod. The creature does not necessarily fight to the death if it can succeed in extorting treasure or food from a party.

**Adhesive (Ex):** A mimic exudes a thick slime that acts as a powerful adhesive, holding fast any creatures or items that touch it. An adhesive-covered mimic automatically grapples any creature it hits with its slam attack. Opponents so grappled cannot get free while the mimic is alive without removing the adhesive first.

A weapon that strikes an adhesive-coated mimic is stuck fast unless the wielder succeeds on a DC 16 Reflex save. A successful DC 16 Strength check is needed to pry it off.

Strong alcohol dissolves the adhesive, but the mimic still can grapple normally. A mimic can dissolve its adhesive at will, and the substance breaks down 5 rounds after the creature dies.

**Crush (Ex):** A mimic deals 1d8+4 points of damage with a successful grapple check.

**Mimic Shape (Ex):** A mimic can assume the general shape of any object that fills roughly 150 cubic feet (5 feet by 5 feet by 6 feet), such as a massive chest, a stout bed, or a wide door frame. The creature cannot substantially alter its size, though. A mimic’s body is hard and has a rough texture, no matter what appearance it might present. Anyone who examines the mimic can detect the ruse with a successful Spot check opposed by the mimic’s Disguise check. Of course, by this time it is generally far too late.

**Skills:** A mimic has a +8 racial bonus on Disguise checks.','{"full_attack":"2 slams +9 melee (1d8+4)","environment":"Underground","organization":"Solitary","treasure":"1/10th coins; 50% goods; 50% items","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d8+21 (52 hp)","hit_points":52,"base_attack_grapple":"+5/+13","attack":"Slam +9 melee (1d8+4)","full_attack":"2 slams +9 melee (1d8+4)","space_reach":"10 ft./10 ft.","saves":"Fort +5, Ref +5, Will +6","abilities":{"str":"19","dex":"12","con":"17","int":"10","wis":"13","cha":"10"},"skills":"Climb +9, Disguise +13, Listen +8, Spot +8","feats":"Alertness, Lightning Reflexes, Weapon Focus (slam)","special_attacks":"Adhesive, crush","special_qualities":"Darkvision 60 ft., immunity to acid, mimic shape"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('minotaur','Minotaur','Minotaur','4','Large','Monstrous Humanoid','Usually chaotic Evil','6d8+12 (39 hp)',39,'+0','30 ft. (6 squares)','14 (–1 size, +5 natural), touch 9, flat-footed — (see text)','+6/+14','Greataxe +9 melee (3d6+6/x3) or gore +9 melee (1d8+4)','10 ft./10 ft.','+6','+5','+5',19,10,15,7,10,8,'Intimidate +2, Listen +7, Search +2, Spot +7','Great Fortitude, Power Attack, Track','{"special_attacks":"Powerful charge 4d6+6","special_qualities":"Darkvision 60 ft., natural cunning, scent"}'::jsonb,'A minotaur stands more than 7 feet tall and weighs about 700 pounds.

Minotaurs speak Giant.

### Combat

Minotaurs prefer melee combat, where their great strength serves them well.

**Powerful Charge (Ex):** A minotaur typically begins a battle by charging at an opponent, lowering its head to bring its mighty horns into play. In addition to the normal benefits and hazards of a charge, this allows the beast to make a single gore attack with a +9 attack bonus that deals 4d6+6 points of damage.

**Natural Cunning (Ex):** Although minotaurs are not especially intelligent, they possess innate cunning and logical ability. This gives them immunity to _maze_ spells, prevents them from ever becoming lost, and enables them to track enemies. Further, they are never caught flat-footed.

**Skills:** Minotaurs have a +4 racial bonus on Search, Spot, and Listen checks.

### Minotaurs as Characters

Minotaur characters possess the following racial traits.

— +8 Strength, +4 Constitution, –4 Intelligence (minimum 3), –2 Charisma.

—Large size. –1 penalty to Armor Class, –1 penalty on attack rolls, –4 penalty on Hide checks, +4 bonus on grapple checks, lifting and carrying limits double those of Medium characters.

—Space/Reach: 10 feet/10 feet.

—A minotaur’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: A minotaur begins with six levels of monstrous humanoid, which provide 6d8 Hit Dice, a base attack bonus of +6, and base saving throw bonuses of Fort +2, Ref +5, and Will +5.

—Racial Skills: A minotaur’s monstrous humanoid levels give it skill points equal to 9 x (2 + Int modifier, minimum 1). Its class skills are Intimidate, Jump, Listen, Search, and Spot. Minotaurs have a +4 racial bonus on Search, Spot, and Listen checks.

—Racial Feats: A minotaur’s monstrous humanoid levels give it three feats.

—Weapon Proficiency: A minotaur is proficient with the greataxe and all simple weapons.

— +5 natural armor bonus.

—Natural Weapons: Gore (1d8).

—Special Attacks (see above): Powerful charge.

—Special Qualities (see above): Natural cunning, scent.

—Automatic Languages: Common, Giant. Bonus Languages: Orc, Goblin, Terran.

—Favored Class: Barbarian.

—Level adjustment +2.','{"full_attack":"Greataxe +9/+4 melee (3d6+6/x3) and gore +4 melee (1d8+2)","environment":"Underground","organization":"Solitary, pair, or gang (3–4)","treasure":"Standard","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"6d8+12 (39 hp)","hit_points":39,"base_attack_grapple":"+6/+14","attack":"Greataxe +9 melee (3d6+6/x3) or gore +9 melee (1d8+4)","full_attack":"Greataxe +9/+4 melee (3d6+6/x3) and gore +4 melee (1d8+2)","space_reach":"10 ft./10 ft.","saves":"Fort +6, Ref +5, Will +5","abilities":{"str":"19","dex":"10","con":"15","int":"7","wis":"10","cha":"8"},"skills":"Intimidate +2, Listen +7, Search +2, Spot +7","feats":"Great Fortitude, Power Attack, Track","special_attacks":"Powerful charge 4d6+6","special_qualities":"Darkvision 60 ft., natural cunning, scent"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('mohrg','Mohrg','Mohrg','8','Medium','Undead','Always chaotic evil','14d12 (91 hp)',91,'+9','30 ft. (6 squares)','23 (+4 Dex, +9 natural), touch 14, flat-footed 14','+7/+12','Slam +12 melee (1d6+7) or tongue +12 melee touch (paralysis)','5 ft./5 ft.','+4','+10','+9',21,19,null,11,10,10,'Climb +13, Hide +21, Listen +11, Move Silently +21, Spot +15, Swim +9','Alertness, Dodge, Improved Initiative, Lightning Reflexes, Mobility','{"special_attacks":"Improved grab, paralyzing touch, create spawn","special_qualities":"Darkvision 60 ft., undead traits"}'::jsonb,'Mohrgs are the animated corpses of mass murderers or similar villains who died without atoning for their crimes. Most mohrgs are 5 to 6 feet tall and weigh about 120 pounds.

### Combat

Like zombies, mohrgs attack by slamming enemies with their fists. They often catch opponents flat-footed, for they move much faster than zombies.

**Improved Grab (Ex):** To use this ability, a mohrg must hit a creature of its size or smaller with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Paralyzing Touch (Su):** A mohrg lashes out with its tongue in combat. An opponent the tongue touches must succeed on a DC 17 Fortitude save or become paralyzed for 1d4 minutes. The save DC is Charisma-based.

**Create Spawn (Su):** Creatures killed by a mohrg rise after 1d4 days as zombies under the morhg’s control. They do not possess any of the abilities they had in life.','{"full_attack":"Slam +12 melee (1d6+7) and tongue +12 melee touch (paralysis)","environment":"Any","organization":"Solitary, gang (2–4), or mob (2–4 plus 5–10 zombies)","treasure":"None","advancement":"15–21 HD (Medium); 22–28 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"14d12 (91 hp)","hit_points":91,"base_attack_grapple":"+7/+12","attack":"Slam +12 melee (1d6+7) or tongue +12 melee touch (paralysis)","full_attack":"Slam +12 melee (1d6+7) and tongue +12 melee touch (paralysis)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +10, Will +9","abilities":{"str":"21","dex":"19","con":null,"int":"11","wis":"10","cha":"10"},"skills":"Climb +13, Hide +21, Listen +11, Move Silently +21, Spot +15, Swim +9","feats":"Alertness, Dodge, Improved Initiative, Lightning Reflexes, Mobility","special_attacks":"Improved grab, paralyzing touch, create spawn","special_qualities":"Darkvision 60 ft., undead traits"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('mummy','Mummy','Mummy','5','Medium','Undead','Usually lawful evil','8d12+3 (55 hp)',55,'+0','20 ft. (4 squares)','20 (+10 natural), touch 10, flat-footed 20','+4/+11','Slam +11 melee (1d6+10 plus mummy rot)','5 ft./5 ft.','+4','+2','+8',24,10,null,6,14,15,'Hide +7, Listen +8, Move Silently +7, Spot +8','Alertness, Great Fortitude, Toughness','{"special_attacks":"Despair, mummy rot","special_qualities":"Damage reduction 5/–, darkvision 60 ft., undead traits, vulnerability to fire"}'::jsonb,'Mummies are preserved corpses animated through the auspices of dark desert gods best forgotten.

Most mummies are 5 to 6 feet tall and weigh about 120 pounds.

Mummies can speak Common, but seldom bother to do so.

### Combat

**Despair (Su):** At the mere sight of a mummy, the viewer must succeed on a DC 16 Will save or be paralyzed with fear for 1d4 rounds. Whether or not the save is successful, that creature cannot be affected again by the same mummy’s despair ability for 24 hours. The save DC is Charisma-based.

**Mummy Rot (Su):** Supernatural disease—slam, Fortitude DC 16, incubation period 1 minute; damage 1d6 Con and 1d6 Cha. The save DC is Charisma-based.

Unlike normal diseases, mummy rot continues until the victim reaches Constitution 0 (and dies) or is cured as described below.

Mummy rot is a powerful curse, not a natural disease. A character attempting to cast any conjuration (healing) spell on a creature afflicted with mummy rot must succeed on a DC 20 caster level check, or the spell has no effect on the afflicted character.

To eliminate mummy rot, the curse must first be broken with _break enchantment_ or _remove curse_ (requiring a DC 20 caster level check for either spell), after which a caster level check is no longer necessary to cast healing spells on the victim, and the mummy rot can be magically cured as any normal disease.

An afflicted creature who dies of mummy rot shrivels away into sand and dust that blow away into nothing at the first wind.

### Mummy Lord

Unusually powerful or evil individuals preserved as mummies sometimes rise as greater mummies after death. A mummy lord resembles its lesser fellows, but often wears or carries equipment it used in life.

Mummy lords are often potent spellcasters. They are found as guardians of the tombs of high lords, priests, and mages. Most are sworn to defend for eternity the resting place of those whom they served in life, but in some cases a mummy lord’s unliving state is the result of a terrible curse or rite designed to punish treason, infidelity, or crimes of an even more abhorrent nature. A mummy lord of this sort is usually imprisoned in a tomb that is never meant to be opened again.

**Despair (Su):** The save DC against this mummy lord’s despair is 17.

**Mummy Rot (Su):** The save DC against this mummy lord’s mummy rot is 17.

_Typical Cleric Spells Prepared_ (6/7/6/5/5/4; save DC 15 + spell level): 0—_detect magic_ (2), _guidance, read magic, resistance, virtue;_ 1st—_bane, command, deathwatch, divine favor, doom, sanctuary\*, shield of faith;_ 2nd—_bull’s strength, death knell\*, hold person, resist energy, silence, spiritual weapon;_ 3rd—_animate dead\*, deeper darkness, dispel magic, invisibility purge, searing light;_ 4th—_air walk, dismissal, divine power, giant vermin, spell immunity\*;_ 5th—_insect plague, slay living\*, spell resistance, symbol of pain._

\*Domain Spell. Domains: Death and Protection.

Possessions: +2 half-plate armor, cloak of resistance +2, ring of minor elemental resistance (fire), brooch of shielding. (Different mummy lords may have different possessions.)','{"full_attack":"Slam +11 melee (1d6+10 plus mummy rot)","environment":"Any","organization":"Solitary, warden squad (2–4), or guardian detail (6–10)","treasure":"Standard","advancement":"9–16 HD (Medium); 17–24 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d12+3 (55 hp)","hit_points":55,"base_attack_grapple":"+4/+11","attack":"Slam +11 melee (1d6+10 plus mummy rot)","full_attack":"Slam +11 melee (1d6+10 plus mummy rot)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +2, Will +8","abilities":{"str":"24","dex":"10","con":null,"int":"6","wis":"14","cha":"15"},"skills":"Hide +7, Listen +8, Move Silently +7, Spot +8","feats":"Alertness, Great Fortitude, Toughness","special_attacks":"Despair, mummy rot","special_qualities":"Damage reduction 5/–, darkvision 60 ft., undead traits, vulnerability to fire"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('mummy_lord_10th_level_cleric','Mummy Lord, 10th-Level Cleric','Mummy Lord, 10th-Level Cleric','15','Medium','Undead','Usually lawful evil','8d12 plus 10d8 (97 hp)',97,'+5','15 ft. in half-plate armor (3 squares); base speed 20 ft.','30 (+1 Dex, +10 natural, +9 +2 half-plate armor), touch 11, flat-footed 29','+11/+19','Slam +20 melee (1d6+12/19–20 plus mummy rot)','5 ft./5 ft.','+13','+8','+20',26,12,null,8,20,17,'Concentration +8, Knowledge (religion) +4, Listen +18, Move Silently +5, Spot +18','Alertness, Combat Casting, Great Fortitude, Improved Critical (slam), Improved Initiative, Weapon Focus (slam)','{"special_attacks":"Despair, mummy rot, rebuke undead, spells","special_qualities":"Damage reduction 5/–, darkvision 60 ft., resistance to fire 10, undead traits, vulnerability to fire"}'::jsonb,'Mummies are preserved corpses animated through the auspices of dark desert gods best forgotten.

Most mummies are 5 to 6 feet tall and weigh about 120 pounds.

Mummies can speak Common, but seldom bother to do so.

### Combat

**Despair (Su):** At the mere sight of a mummy, the viewer must succeed on a DC 16 Will save or be paralyzed with fear for 1d4 rounds. Whether or not the save is successful, that creature cannot be affected again by the same mummy’s despair ability for 24 hours. The save DC is Charisma-based.

**Mummy Rot (Su):** Supernatural disease—slam, Fortitude DC 16, incubation period 1 minute; damage 1d6 Con and 1d6 Cha. The save DC is Charisma-based.

Unlike normal diseases, mummy rot continues until the victim reaches Constitution 0 (and dies) or is cured as described below.

Mummy rot is a powerful curse, not a natural disease. A character attempting to cast any conjuration (healing) spell on a creature afflicted with mummy rot must succeed on a DC 20 caster level check, or the spell has no effect on the afflicted character.

To eliminate mummy rot, the curse must first be broken with _break enchantment_ or _remove curse_ (requiring a DC 20 caster level check for either spell), after which a caster level check is no longer necessary to cast healing spells on the victim, and the mummy rot can be magically cured as any normal disease.

An afflicted creature who dies of mummy rot shrivels away into sand and dust that blow away into nothing at the first wind.

### Mummy Lord

Unusually powerful or evil individuals preserved as mummies sometimes rise as greater mummies after death. A mummy lord resembles its lesser fellows, but often wears or carries equipment it used in life.

Mummy lords are often potent spellcasters. They are found as guardians of the tombs of high lords, priests, and mages. Most are sworn to defend for eternity the resting place of those whom they served in life, but in some cases a mummy lord’s unliving state is the result of a terrible curse or rite designed to punish treason, infidelity, or crimes of an even more abhorrent nature. A mummy lord of this sort is usually imprisoned in a tomb that is never meant to be opened again.

**Despair (Su):** The save DC against this mummy lord’s despair is 17.

**Mummy Rot (Su):** The save DC against this mummy lord’s mummy rot is 17.

_Typical Cleric Spells Prepared_ (6/7/6/5/5/4; save DC 15 + spell level): 0—_detect magic_ (2), _guidance, read magic, resistance, virtue;_ 1st—_bane, command, deathwatch, divine favor, doom, sanctuary\*, shield of faith;_ 2nd—_bull’s strength, death knell\*, hold person, resist energy, silence, spiritual weapon;_ 3rd—_animate dead\*, deeper darkness, dispel magic, invisibility purge, searing light;_ 4th—_air walk, dismissal, divine power, giant vermin, spell immunity\*;_ 5th—_insect plague, slay living\*, spell resistance, symbol of pain._

\*Domain Spell. Domains: Death and Protection.

Possessions: +2 half-plate armor, cloak of resistance +2, ring of minor elemental resistance (fire), brooch of shielding. (Different mummy lords may have different possessions.)','{"full_attack":"Slam +20 melee (1d6+12/19–20 plus mummy rot)","environment":"Any","organization":"Solitary or tomb guard (1 mummy lord and 6–10 mummies)","treasure":"Standard plus possessions noted below","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"8d12 plus 10d8 (97 hp)","hit_points":97,"base_attack_grapple":"+11/+19","attack":"Slam +20 melee (1d6+12/19–20 plus mummy rot)","full_attack":"Slam +20 melee (1d6+12/19–20 plus mummy rot)","space_reach":"5 ft./5 ft.","saves":"Fort +13, Ref +8, Will +20","abilities":{"str":"26","dex":"12","con":null,"int":"8","wis":"20","cha":"17"},"skills":"Concentration +8, Knowledge (religion) +4, Listen +18, Move Silently +5, Spot +18","feats":"Alertness, Combat Casting, Great Fortitude, Improved Critical (slam), Improved Initiative, Weapon Focus (slam)","special_attacks":"Despair, mummy rot, rebuke undead, spells","special_qualities":"Damage reduction 5/–, darkvision 60 ft., resistance to fire 10, undead traits, vulnerability to fire"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('dark_naga','Dark Naga','Dark Naga','8','Large','Aberration','Usually lawful evil','9d8+18 (58 hp)',58,'+2','40 ft. (8 squares)','14 (–1 size, +2 Dex, +3 natural), touch 11, flat-footed 12','+6/+12','Sting +7 melee (2d4+2 plus poison)','10 ft./5 ft.','+5','+7','+8',14,15,14,16,15,17,'Bluff +9, Concentration +13, Diplomacy +7, Disguise +5 (+7 acting), Intimidate +5, Listen +11, Sense Motive +8, Spellcraft +12, Spot +11','Alertness, Combat Casting, Dodge, Eschew MaterialsB, Lightning Reflexes','{"special_attacks":"Poison, spells","special_qualities":"Darkvision 60 ft., detect thoughts, guarded thoughts, immunity to poison, resistance to charm"}'::jsonb,'Dark nagas speak Common and Infernal.

#### Combat

Dark nagas prefer to fight from an elevated position where they get a good view of the battlefield while also staying out of reach.

**Poison (Ex):** Injury, Fortitude DC 16 or lapse into a nightmare-haunted sleep for 2d4 minutes. The save DC is Constitution-based.

**Spells:** Dark nagas cast spells as 7th-level sorcerers.

_Typical Sorcerer Spells Known_ (6/7/7/5; save DC 13 + spell level): 0—_daze, detect magic, light, mage hand, open/close, ray of frost, read magic;_ 1st—_expeditious retreat, magic missile, ray of enfeeblement, shield, silent image;_ 2nd—_cat’s grace, invisibility, scorching ray;_ 3rd—_displacement, lightning bolt._

**Resistance to _Charm_:** Dark nagas have a +2 racial bonus on saving throws against all _charm_ effects (not included in the statistics block).

**Detect Thoughts (Su):** A dark naga can continuously use detect thoughts as the spell (caster level 9th; Will DC 15 negates). This ability is always active. The save DC is Charisma-based.

**Guarded Thoughts (Ex):** Dark nagas are immune to any form of mind reading.','{"full_attack":"Sting +7 melee (2d4+2 plus poison) and bite +2 melee (1d4+1)","environment":"Temperate hills","organization":"Solitary or nest (2–4)","treasure":"Standard","advancement":"10–13 HD (Large); 14–27 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"9d8+18 (58 hp)","hit_points":58,"base_attack_grapple":"+6/+12","attack":"Sting +7 melee (2d4+2 plus poison)","full_attack":"Sting +7 melee (2d4+2 plus poison) and bite +2 melee (1d4+1)","space_reach":"10 ft./5 ft.","saves":"Fort +5, Ref +7, Will +8","abilities":{"str":"14","dex":"15","con":"14","int":"16","wis":"15","cha":"17"},"skills":"Bluff +9, Concentration +13, Diplomacy +7, Disguise +5 (+7 acting), Intimidate +5, Listen +11, Sense Motive +8, Spellcraft +12, Spot +11","feats":"Alertness, Combat Casting, Dodge, Eschew MaterialsB, Lightning Reflexes","special_attacks":"Poison, spells","special_qualities":"Darkvision 60 ft., detect thoughts, guarded thoughts, immunity to poison, resistance to charm"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('guardian_naga','Guardian Naga','Guardian Naga','10','Large','Aberration','Usually lawful good','11d8+44 (93 hp)',93,'+2','40 ft. (8 squares)','18 (–1 size, +2 Dex, +7 natural), touch 11, flat-footed 16','+8/+17','Bite +12 melee (2d6+7 plus poison) or spit +9 ranged touch (poison)','10 ft./5 ft.','+7','+7','+11',21,14,19,16,19,18,'Bluff +18, Concentration +19, Listen +13, Diplomacy +8, Disguise +4 (+6 acting), Intimidate +6, Sense Motive +18, Spellcraft +17, Spot +13','Alertness, Combat Casting, Dodge, Eschew MaterialsB, Lightning Reflexes','{"special_attacks":"Poison, spit, spells","special_qualities":"Darkvision 60 ft."}'::jsonb,'Guardian nagas speak Celestial and Common.

#### Combat

Guardian nagas usually warn off intruders before attacking. If the warning is ignored, they may begin a spell assault or spit poison.

**Poison (Ex):** Injury or contact, Fortitude DC 19, initial and secondary damage 1d10 Con. The save DC is Constitution-based.

**Spit (Ex):** A guardian naga can spit its venom up to 30 feet as a standard action. This is a ranged touch attack with no range increment. Opponents hit by this attack must make successful saves (see above) to avoid the effect.

**Spells:** Guardian nagas cast spells as 9th-level sorcerers, and can also cast spells from the cleric list and from the Good and Law domains. The cleric spells and domain spells are considered arcane spells for a guardian naga, meaning that the creature does not need a divine focus to cast them.

_Typical Spells Known_ (6/7/7/7/5; save DC 14 + spell level): 0— _cure minor wounds, daze, detect magic, light, mage hand, open/close, ray of frost, read magic;_ 1st—_cure light wounds, divine favor, expeditious retreat, mage armor, magic missile;_ 2nd—_detect thoughts, lesser restoration, see invisibility, scorching ray;_ 3rd—_cure serious wounds, dispel magic, lightning bolt;_ 4th—_divine power, greater invisibility._','{"full_attack":"Bite +12 melee (2d6+7 plus poison) or spit +9 ranged touch (poison)","environment":"Temperate plains","organization":"Solitary or nest (2–4)","treasure":"Standard","advancement":"12–16 HD (Large); 17–33 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"11d8+44 (93 hp)","hit_points":93,"base_attack_grapple":"+8/+17","attack":"Bite +12 melee (2d6+7 plus poison) or spit +9 ranged touch (poison)","full_attack":"Bite +12 melee (2d6+7 plus poison) or spit +9 ranged touch (poison)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +7, Will +11","abilities":{"str":"21","dex":"14","con":"19","int":"16","wis":"19","cha":"18"},"skills":"Bluff +18, Concentration +19, Listen +13, Diplomacy +8, Disguise +4 (+6 acting), Intimidate +6, Sense Motive +18, Spellcraft +17, Spot +13","feats":"Alertness, Combat Casting, Dodge, Eschew MaterialsB, Lightning Reflexes","special_attacks":"Poison, spit, spells","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('spirit_naga','Spirit Naga','Spirit Naga','9','Large','Aberration','Usually chaotic evil','9d8+36 (76 hp)',76,'+1','40 ft. (8 squares)','16 (–1 size, +1 Dex, +6 natural), touch 10, flat-footed 15','+6/+14','Bite +9 melee (2d6+6 plus poison)','10 ft./5 ft.','+7','+6','+9',18,13,18,12,17,17,'Concentration +13, Listen +14, Spellcraft +10, Spot +14','Ability Focus (charming gaze), Alertness, Combat Casting, Eschew MaterialsB, Lightning Reflexes','{"special_attacks":"Charming gaze, poison, spells","special_qualities":"Darkvision 60 ft."}'::jsonb,'Spirit nagas speak Abyssal and Common.

#### Combat

Spirit nagas meet foes boldly so as to use their gaze attacks to best effect. They quickly slither forward to bite foes that avert their eyes.

**Charming Gaze (Su):** As _charm person,_ 30 feet, Will DC 19 negates. The save DC is Charisma-based.

**Poison (Ex):** Injury, Fortitude DC 18, initial and secondary damage 1d8 Con. The save DC is Constitution-based.

**Spells:** Spirit nagas cast spells as 7th-level sorcerers, and can also cast spells from the cleric spell list and from the Chaos and Evil domains as arcane spells. The cleric spells and domain spells are considered arcane spells for a spirit naga, meaning that the creature does not need a divine focus to cast them.

_Typical Spells Known_ (6/7/7/5; save DC 13 + spell level): 0—_cure minor wounds, daze, detect magic, mage hand, open/close, ray of frost, read magic;_ 1st—_charm person, cure light wounds, divine favor, magic missile, shield of faith;_ 2nd—_cat’s grace, invisibility, summon swarm_; 3rd—_displacement, fireball._','{"full_attack":"Bite +9 melee (2d6+6 plus poison)","environment":"Temperate marshes","organization":"Solitary or nest (2–4)","treasure":"Standard","advancement":"10–13 HD (Large); 14–27 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"9d8+36 (76 hp)","hit_points":76,"base_attack_grapple":"+6/+14","attack":"Bite +9 melee (2d6+6 plus poison)","full_attack":"Bite +9 melee (2d6+6 plus poison)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +6, Will +9","abilities":{"str":"18","dex":"13","con":"18","int":"12","wis":"17","cha":"17"},"skills":"Concentration +13, Listen +14, Spellcraft +10, Spot +14","feats":"Ability Focus (charming gaze), Alertness, Combat Casting, Eschew MaterialsB, Lightning Reflexes","special_attacks":"Charming gaze, poison, spells","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('water_naga','Water Naga','Water Naga','7','Large','Aberration (Aquatic)','Usually neutral','7d8+28 (59 hp)',59,'+1','30 ft. (6 squares), swim 50 ft.','15 (–1 size, +1 Dex, +5 natural), touch 10, flat-footed 14','+5/+12','Bite +7 melee (2d6+4 plus poison)','10 ft./5 ft.','+6','+5','+8',16,13,18,10,17,15,'Concentration +12, Listen +7, Spellcraft +8, Spot +7, Swim +11','Alertness, Combat Casting, Eschew MaterialsB, Lightning Reflexes','{"special_attacks":"Poison, spells","special_qualities":"Darkvision 60 ft."}'::jsonb,'Water nagas speak Aquan and Common.

#### Combat

Water nagas prefer to stay mostly concealed in a body of water while they launch a spell attack.

**Poison (Ex):** Injury, Fortitude DC 17, initial and secondary damage 1d8 Con. The save DC is Constitution-based.

**Spells:** Water nagas cast spells as 7th-level sorcerers but never use fire spells.

_Typical Sorcerer Spells Known_ (6/7/7/4; save DC 12 + spell level): 0—_acid splash, daze, detect magic, light, mage hand, open/close, read magic;_ 1st—_expeditious retreat, magic missile, obscuring mist, shield, true strike;_ 2nd—_invisibility, acid arrow, mirror image;_ 3rd—_protection from energy, suggestion._

**Skills:** A water naga has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"Bite +7 melee (2d6+4 plus poison)","environment":"Temperate aquatic","organization":"Solitary, pair, or nest (3–4)","treasure":"Standard","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d8+28 (59 hp)","hit_points":59,"base_attack_grapple":"+5/+12","attack":"Bite +7 melee (2d6+4 plus poison)","full_attack":"Bite +7 melee (2d6+4 plus poison)","space_reach":"10 ft./5 ft.","saves":"Fort +6, Ref +5, Will +8","abilities":{"str":"16","dex":"13","con":"18","int":"10","wis":"17","cha":"15"},"skills":"Concentration +12, Listen +7, Spellcraft +8, Spot +7, Swim +11","feats":"Alertness, Combat Casting, Eschew MaterialsB, Lightning Reflexes","special_attacks":"Poison, spells","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('night_hag','Night Hag','Night Hag','9','Medium','Outsider (Evil, Extraplanar)','Always neutral evil','8d8+32 (68 hp)',68,'+1','20 ft. (4 squares)','22 (+1 Dex, +11 natural), touch 11, flat-footed 21','+8/+12','Bite +12 melee (2d6+6 plus disease)','5 ft./5 ft.','+12','+9','+10',19,12,18,11,15,12,'Bluff +12, Concentration +15, Diplomacy +5, Disguise +1 (+3 acting), Intimidate +14, Listen +15, Ride +12, Sense Motive +13, Spellcraft +11, Spot +15','Alertness, Combat Casting, Mounted Combat','{"special_attacks":"Spell-like abilities, dream haunting","special_qualities":"Damage reduction 10/cold iron and magic, immunity to fire, cold, charm, sleep, and fear, spell resistance 25"}'::jsonb,'A night hag is about the same height and weight as a female human.

Night hags speak Abyssal, Celestial, Common, and Infernal.

### Combat

Night hags attack good creatures on sight if the odds of success seem favorable.

These creatures rip through armor and flesh with their deadly teeth. They love to use _sleep_ and then strangle those who are overcome by it.

A night hag’s natural weapons, as well as any weapons it wields, are treated as evil-aligned for the purpose of overcoming damage reduction. Its natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Disease (Ex):** Demon fever—bite, Fortitude DC 18, incubation period 1 day, damage 1d6 Con. Each day after the first, on a failed save, an afflicted creature must immediately succeed on another DC 18 Fortitude save or take 1 point of Constitution drain. The save DC is Constitution based.

**Spell-Like Abilities:** At will—_detect chaos, detect evil, detect good, detect law, detect magic, magic missile, polymorph_ (self only), _ray of enfeeblement_ (DC 12)_, sleep_ (DC 12). Caster level 8th. A night hag can use _etherealness_ at will (caster level 16th) so long as it possesses its _heartstone_ (see below). The save DCs are Charisma-based.

**Dream Haunting (Su):** Night hags can visit the dreams of chaotic or evil individuals by using a special periapt known as a _heartstone_ to become ethereal, then hovering over the creature. Once a hag invades someone’s dreams, it rides on the victim’s back until dawn. The sleeper suffers from tormenting dreams and takes 1 point of Constitution drain upon awakening. Only another ethereal being can stop these nocturnal intrusions, by confronting and defeating the night hag.

### Heartstone

All night hags carry a periapt known as a _heartstone,_ which instantly cures any disease contracted by the holder. In addition, a _heartstone_ provides a +2 resistance bonus on all saving throws (this bonus is included in the statistics block). A night hag that loses this charm can no longer use _etherealness_ until it can manufacture another (which takes one month). Creatures other than the hag can benefit from the _heartstone_’s powers, but the periapt shatters after ten uses (any disease cured or saving throw affected

counts as a use) and it does not bestow _etherealness_ to a bearer that is not a night hag. If sold, an intact _heartstone_ brings 1,800 gp.','{"full_attack":"Bite +12 melee (2d6+6 plus disease)","environment":"A evil-aligned plane","organization":"Solitary, mounted (1, on nightmare), or covey (3, on nightmares)","treasure":"Standard","advancement":"9–16 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"8d8+32 (68 hp)","hit_points":68,"base_attack_grapple":"+8/+12","attack":"Bite +12 melee (2d6+6 plus disease)","full_attack":"Bite +12 melee (2d6+6 plus disease)","space_reach":"5 ft./5 ft.","saves":"Fort +12*, Ref +9*, Will +10*","abilities":{"str":"19","dex":"12","con":"18","int":"11","wis":"15","cha":"12"},"skills":"Bluff +12, Concentration +15, Diplomacy +5, Disguise +1 (+3 acting), Intimidate +14, Listen +15, Ride +12, Sense Motive +13, Spellcraft +11, Spot +15","feats":"Alertness, Combat Casting, Mounted Combat","special_attacks":"Spell-like abilities, dream haunting","special_qualities":"Damage reduction 10/cold iron and magic, immunity to fire, cold, charm, sleep, and fear, spell resistance 25"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nightmare','Nightmare','Nightmare','5','Large','Outsider (Evil, Extraplanar)','Always neutral evil','6d8+18 (45 hp)',45,'+6','40 ft. (8 squares), fly 90 ft. (good)','24 (–1 size, +2 Dex, +13 natural), touch 11, flat-footed 22','+6/+14','Hoof +9 melee (1d8+4 plus 1d4 fire)','10 ft./5 ft.','+8','+7','+6',18,15,16,13,13,12,'Concentration +12, Diplomacy +3, Intimidate +10, Knowledge (the planes) +10, Listen +12, Move Silently +11, Search +10, Sense Motive +10, Spot +12, Survival +10 (+12 on other planes and following tracks)','Alertness, Improved Initiative, Run','{"special_attacks":"Flaming hooves, smoke","special_qualities":"Astral projection, darkvision 60 ft., etherealness"}'::jsonb,'A nightmare is about the size of a light war horse.

### Combat

A nightmare can fight while carrying a rider, but the rider cannot also fight unless he or she succeeds on a Ride check.

A nightmare’s natural weapons, as well as any weapons it wields, are treated as evil-aligned for the purpose of overcoming damage reduction.

**Flaming Hooves (Su):** A blow from a nightmare’s hooves sets combustible materials alight.

**Smoke (Su):** During the excitement of battle, a nightmare snorts and neighs with rage. This snorting fills a 15-foot cone with a hot, sulfurous smoke that chokes and blinds opponents. Anyone in the cone must succeed on a DC 16 Fortitude save or take a –2 penalty on all attack and damage rolls until 1d6 minutes after leaving the cone. The cone lasts 1 round, and the nightmare uses it once as a free action during its turn each round. The save DC is Constitution-based.

Because of the smoke it gives off, a nightmare has concealment against creatures 5 feet away and total concealment against creatures 10 feet or farther away. The smoke does not obscure the nightmare’s vision at all.

**Astral Projection and Etherealness (Su):** These abilities function just like the spells of the same names (caster level 20th); a nightmare can use either at will.

**Carrying Capacity:** A light load for a nightmare is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.

### Cauchemar

The cauchemar is a horrible, especially malevolent version of a nightmare. The sight of one of these great horrors bearing down is enough to shake the heart of the boldest champion.

#### Combat

The save DC for the cauchemar’s smoke attack (DC 24) is adjusted for its greater number of Hit Dice and higher Constitution score.

Carrying Capacity: A light load for a cauchemar is up to 612 pounds; a medium load, 613–1,224 pounds; and a heavy load, 1,225–1,840 pounds.','{"full_attack":"2 hooves +9 melee (1d8+4 plus 1d4 fire) and bite +4 melee (1d8+2)","environment":"A evil-aligned plane","organization":"Solitary Solitary","treasure":"None","advancement":"7–10 HD (Large); 11–18 HD (Huge)","level_adjustment":"+4 (cohort)","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+6/+14","attack":"Hoof +9 melee (1d8+4 plus 1d4 fire)","full_attack":"2 hooves +9 melee (1d8+4 plus 1d4 fire) and bite +4 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +7, Will +6","abilities":{"str":"18","dex":"15","con":"16","int":"13","wis":"13","cha":"12"},"skills":"Concentration +12, Diplomacy +3, Intimidate +10, Knowledge (the planes) +10, Listen +12, Move Silently +11, Search +10, Sense Motive +10, Spot +12, Survival +10 (+12 on other planes and following tracks)","feats":"Alertness, Improved Initiative, Run","special_attacks":"Flaming hooves, smoke","special_qualities":"Astral projection, darkvision 60 ft., etherealness"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nightmare_cauchemar','Nightmare, Cauchemar','Nightmare, Cauchemar','11','Huge','Outsider (Evil, Extraplanar)','Always neutral evil','15d8+105 (172 hp)',172,'+6','40 ft. (8 squares), fly 90 ft. (good)','26 (–2 size, +2 Dex, +16 natural), touch 10, flat-footed 24','+15/+33','Hoof +23 melee (2d6+10 plus 1d4 fire)','15 ft./10 ft.','+16','+11','+10',31,14,24,16,12,12,'Bluff +19, Concentration +25, Diplomacy +5, Disguise +1 (+3 acting), Intimidate +21, Knowledge (arcana) +21, Knowledge (the planes) +21, Listen +21, Move Silently +20, Search +21, Sense Motive +19, Spot +21, Survival +19 (+21 on other planes and following tracks)','Alertness, Cleave, Improved Initiative, Power Attack, Run, Track','{"special_attacks":"Flaming hooves, smoke","special_qualities":"Astral projection, darkvision 60 ft., etherealness"}'::jsonb,'A nightmare is about the size of a light war horse.

### Combat

A nightmare can fight while carrying a rider, but the rider cannot also fight unless he or she succeeds on a Ride check.

A nightmare’s natural weapons, as well as any weapons it wields, are treated as evil-aligned for the purpose of overcoming damage reduction.

**Flaming Hooves (Su):** A blow from a nightmare’s hooves sets combustible materials alight.

**Smoke (Su):** During the excitement of battle, a nightmare snorts and neighs with rage. This snorting fills a 15-foot cone with a hot, sulfurous smoke that chokes and blinds opponents. Anyone in the cone must succeed on a DC 16 Fortitude save or take a –2 penalty on all attack and damage rolls until 1d6 minutes after leaving the cone. The cone lasts 1 round, and the nightmare uses it once as a free action during its turn each round. The save DC is Constitution-based.

Because of the smoke it gives off, a nightmare has concealment against creatures 5 feet away and total concealment against creatures 10 feet or farther away. The smoke does not obscure the nightmare’s vision at all.

**Astral Projection and Etherealness (Su):** These abilities function just like the spells of the same names (caster level 20th); a nightmare can use either at will.

**Carrying Capacity:** A light load for a nightmare is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.

### Cauchemar

The cauchemar is a horrible, especially malevolent version of a nightmare. The sight of one of these great horrors bearing down is enough to shake the heart of the boldest champion.

#### Combat

The save DC for the cauchemar’s smoke attack (DC 24) is adjusted for its greater number of Hit Dice and higher Constitution score.

Carrying Capacity: A light load for a cauchemar is up to 612 pounds; a medium load, 613–1,224 pounds; and a heavy load, 1,225–1,840 pounds.','{"full_attack":"2 hooves +23 melee (2d6+10 plus 1d4 fire) and bite +18 melee (2d6+5)","environment":"A neutral evil plane","organization":"Solitary","treasure":"None","advancement":"—","level_adjustment":"+4 (cohort)","statblock":{"hit_dice":"15d8+105 (172 hp)","hit_points":172,"base_attack_grapple":"+15/+33","attack":"Hoof +23 melee (2d6+10 plus 1d4 fire)","full_attack":"2 hooves +23 melee (2d6+10 plus 1d4 fire) and bite +18 melee (2d6+5)","space_reach":"15 ft./10 ft.","saves":"Fort +16, Ref +11, Will +10","abilities":{"str":"31","dex":"14","con":"24","int":"16","wis":"12","cha":"12"},"skills":"Bluff +19, Concentration +25, Diplomacy +5, Disguise +1 (+3 acting), Intimidate +21, Knowledge (arcana) +21, Knowledge (the planes) +21, Listen +21, Move Silently +20, Search +21, Sense Motive +19, Spot +21, Survival +19 (+21 on other planes and following tracks)","feats":"Alertness, Cleave, Improved Initiative, Power Attack, Run, Track","special_attacks":"Flaming hooves, smoke","special_qualities":"Astral projection, darkvision 60 ft., etherealness"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nightcrawler','Nightcrawler','Nightcrawler','18','Gargantuan','Undead (Extraplanar)','Always chaotic evil','25d12+50 (212 hp)',212,'+4','30 ft. (6 squares), burrow 60 ft.','35 (–4 size, +29 natural), touch 6, flat-footed 35','+12/+45','Bite +29 melee (4d6+21)','20 ft./15 ft.','+12','+10','+23',48,10,null,20,20,18,'Concentration +32, Diplomacy +6, Hide +16, Knowledge (arcana) +33, Listen +33, Move Silently +28, Search +33, Sense Motive +23, Spellcraft +35, Spot +33, Survival +5 (+7 following tracks)','Blind-Fight, Combat Casting, Great Fortitude, Improved Critical (bite), Improved Critical (sting), Improved Initiative, Iron Will, Power Attack, Quicken Spell-Like Ability (cone of cold)','{"special_attacks":"Desecrating aura, energy drain, spell-like abilities, poison, summon undead, swallow whole","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 31, telepathy 100 ft, tremorsense 60 ft., undead traits"}'::jsonb,'A nightcrawler is a massive behemoth similar to a purple worm, though utterly black in color.

A nightcrawler measures about 7 feet in diameter and is 100 feet long from its toothy maw to the tip of its stinging tail. It weighs about 55,000 pounds.

#### Combat

A nightcrawler attacks by burrowing through the ground and emerging to strike.

A nightcrawler’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Energy Drain (Su):** Living creatures inside a nightcrawler’s gizzard gain one negative level each round. The DC is 26 for the Fortitude save to remove a negative level. The save DC is Charisma-based.

For each such negative level bestowed, the nightcrawler gains 5 temporary hit points.

**Improved Grab (Ex):** To use this ability, a nightcrawler must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can try to swallow the opponent in the following round.

**Poison (Ex):** Injury, Fortitude DC 22, initial and secondary damage 2d6 Str. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_contagion_ (DC 18), _deeper darkness, detect magic, greater dispel magic, haste, invisibility, see invisibility, unholy blight_ (DC 18); 3/day—_cone of cold_ (DC 19), _confusion_ (DC 18), _hold monster_ (DC 19); 1/day—_finger of death_ (DC 21), _mass hold monster_ (DC 23), _plane shift_ (DC 21). Caster level 25th. The save DCs are Charisma-based.

**Summon Undead (Su):** A nightcrawler can summon undead creatures once per night: 9–16 shadows, 3–6 greater shadows, or 2–4 dread wraiths. The undead arrive in 1d10 rounds and serve for 1 hour or until released.

**Swallow Whole (Ex):** A nightcrawler can try to swallow a grabbed opponent of Huge or smaller size by making a successful grapple check. Once inside, the opponent takes 2d8+12 points of bludgeoning damage plus 12 points of acid damage per round from the nightcrawler’s gizzard and is subject to the creature’s energy drain. A swallowed creature can cut its way out by using a light slashing or piercing weapon to deal 35 points of damage to the gizzard (AC 21). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out. A nightcrawler’s interior can hold 2 Huge, 8 Large, 32 Medium, 128 Small, 512 Tiny or smaller opponents.','{"full_attack":"Bite +29 melee (4d6+21/19–20) and sting +24 melee (2d8+11/19–20 plus poison)","environment":"Plane of Shadow","organization":"Solitary or pair","treasure":"Standard","advancement":"26–50 HD (Colossal)","level_adjustment":"—","statblock":{"hit_dice":"25d12+50 (212 hp)","hit_points":212,"base_attack_grapple":"+12/+45","attack":"Bite +29 melee (4d6+21)","full_attack":"Bite +29 melee (4d6+21/19–20) and sting +24 melee (2d8+11/19–20 plus poison)","space_reach":"20 ft./15 ft.","saves":"Fort +12, Ref +10, Will +23","abilities":{"str":"48","dex":"10","con":null,"int":"20","wis":"20","cha":"18"},"skills":"Concentration +32, Diplomacy +6, Hide +16, Knowledge (arcana) +33, Listen +33, Move Silently +28, Search +33, Sense Motive +23, Spellcraft +35, Spot +33, Survival +5 (+7 following tracks)","feats":"Blind-Fight, Combat Casting, Great Fortitude, Improved Critical (bite), Improved Critical (sting), Improved Initiative, Iron Will, Power Attack, Quicken Spell-Like Ability (cone of cold)","special_attacks":"Desecrating aura, energy drain, spell-like abilities, poison, summon undead, swallow whole","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 31, telepathy 100 ft, tremorsense 60 ft., undead traits"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nightwalker','Nightwalker','Nightwalker','16','Huge','Undead (Extraplanar)','Always chaotic evil','21d12+42 (178 hp)',178,'+6','40 ft (8 squares)., fly 20 ft. (poor)','32 (–2 size, +2 Dex, +22 natural), touch 10, flat-footed 30','+10/+34','Slam +24 melee (2d6+16)','15 ft./15 ft.','+11','+11','+19',38,14,null,20,20,18,'Concentration +28, Diplomacy +6, Hide +18*, Knowledge (arcana) +29, Listen +29, Move Silently +26, Search +29, Sense Motive +29, Spellcraft +31, Spot +29, Survival +5 (+7 following tracks)','Cleave, Combat Expertise, Combat Reflexes, Great Fortitude, Improved Disarm, Improved Initiative, Power Attack, Quicken Spell-Like Ability (unholy blight)','{"special_attacks":"Crush item, desecrating aura, evil gaze, spell-like abilities, summon undead","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 29, telepathy 100 ft., undead traits"}'::jsonb,'Nightwalkers are human-shaped horrors that haunt the darkness.

A nightwalker is about 20 feet tall and weighs about 12,000 pounds.

#### Combat

Nightwalkers lurk in dark areas where they can almost always surprise the unwary.

A nightwalker’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Crush Item (Su):** A nightwalker can destroy any weapon or item of Large size or smaller (even magic ones, but not artifacts) by picking it up and crushing it between its hands. The nightwalker must make a successful disarm attempt to grab an item held by an opponent. The item is entitled to a DC 34 Fortitude save to resist destruction. The save DC is Strength-based.

**Evil Gaze (Su):** Fear, 30 feet. A creature that meets the nightwalker’s gaze must succeed on a DC 24 Will save or be paralyzed with fear for 1d8 rounds. Whether or not the save is successful, that creature cannot be affected again by the same nightshade’s gaze for 24 hours. This is a mind-affecting fear effect. The save DC is Charisma-based.

**Spell-Like Abilities:** At will—_contagion_ (DC 18), _deeper darkness, detect magic, greater dispel magic, haste, see invisibility,_ and _unholy blight_ (DC 18); 3/day—_confusion_ (DC 18), _hold monster_ (DC 19), _invisibility;_ 1/day—_cone of cold_ (DC 19), _finger of death_ (DC 21), _plane shift_ (DC 21). Caster level 21st. The save DCs are Charisma-based.

**Summon Undead (Su):** A nightwalker can summon undead creatures once per night: 7–12 shadows, 2–5 greater shadows, or 1–2 dread wraiths. The undead arrive in 1d10 rounds and serve for 1 hour or until released.

**Skills:** \*When hiding in a dark area, a nightwalker gains a +8 racial bonus on Hide checks.

#### Tactics Round-by-Round

The nightwalker is an exceedingly intelligent foe that makes the best use of all its abilities. It favors using its spell-like abilities to divide and disable its enemies, then closing to melee with opponents it has isolated from their allies.

_Prior to combat:_ The nightwalker keeps its _see invisibility_ power active most of the time. It uses _haste_ and _invisibility_ to prepare for battle.

_Round 1:_ Move to within 30 feet to make use of gaze attack and strike with _confusion_ or _hold monster,_ coupled with a quickened _unholy blight._

_Round 2:_ Hit a spellcaster with _finger of death_ and another quickened _unholy blight._

_Round 3:_ Move up to engage the enemy and attempt to disarm an enemy fighter.

_Round 4:_ Crush the disarmed weapon (or use gaze attack if disarm attempt failed).

_Round 5:_ Full attack against the unarmed foe (or on a nearby spellcaster).','{"full_attack":"2 slams +24 melee (2d6+16)","environment":"Plane of Shadow","organization":"Solitary, pair, or gang (3–4)","treasure":"Standard","advancement":"22–31 HD (Huge); 32–42 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"21d12+42 (178 hp)","hit_points":178,"base_attack_grapple":"+10/+34","attack":"Slam +24 melee (2d6+16)","full_attack":"2 slams +24 melee (2d6+16)","space_reach":"15 ft./15 ft.","saves":"Fort +11, Ref +11, Will +19","abilities":{"str":"38","dex":"14","con":null,"int":"20","wis":"20","cha":"18"},"skills":"Concentration +28, Diplomacy +6, Hide +18*, Knowledge (arcana) +29, Listen +29, Move Silently +26, Search +29, Sense Motive +29, Spellcraft +31, Spot +29, Survival +5 (+7 following tracks)","feats":"Cleave, Combat Expertise, Combat Reflexes, Great Fortitude, Improved Disarm, Improved Initiative, Power Attack, Quicken Spell-Like Ability (unholy blight)","special_attacks":"Crush item, desecrating aura, evil gaze, spell-like abilities, summon undead","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 29, telepathy 100 ft., undead traits"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nightwing','Nightwing','Nightwing','14','Huge','Undead (Extraplanar)','Always chaotic evil','17d12+34 (144 hp)',144,'+8','20 ft. (4 squares), fly 60 ft. (good)','30 (–2 size, +4 Dex, +18 natural) touch 12, flat-footed 26','+8/+28','Bite +18 melee (2d6+17/19–20 plus magic drain)','15 ft./10 ft.','+9','+11','+17',31,18,null,18,20,18,'Concentration +24, Diplomacy +6, Hide +16*, Listen +25, Move Silently +24, Search +24, Sense Motive +25, Spellcraft +24, Spot +25, Survival +5 (+7 following tracks)','Combat Reflexes, Dodge, Flyby Attack, Great Fortitude, Improved Critical (bite), Improved Initiative','{"special_attacks":"Desecrating aura, magic drain, spell-like abilities, summon undead","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 27, telepathy 100 ft., undead traits"}'::jsonb,'Nightwings are batlike flyers that hunt on the wing.

A nightwing has a wingspan of about 40 feet and weighs about 4,000 pounds.

#### Combat

Nightwings prowl the night sky and dive onto their victims. They are all but invisible, detectable only because of the stars they obscure in their passing.

A nightwing’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Magic Drain (Su):** A nightwing can weaken magic armor, weapons, and shields by making a successful touch attack. The targeted item must succeed on a DC 22 Fortitude save or lose 1 point of its enhancement bonus. The save DC is Charisma-based. An item that loses its entire enhancement bonus becomes merely a masterwork item and loses any special abilities (such as flaming) as well. Casting _dispel evil_ upon the item reverses the effect of the magic drain, provided this occurs within a number of days after the attack equal to the caster’s level and the caster succeeds on a DC 29 caster level check.

**Spell-Like Abilities:** At will—_contagion_ (DC 18), _deeper darkness, detect magic, haste, see invisibility, unholy blight_ (DC 18); 3/day—_confusion_ (DC 18), _greater dispel magic, hold monster_ (DC 19), _invisibility;_ 1/day—_cone of cold_ (DC 19), _finger of death_ (DC 21), _plane shift_ (DC 21). Caster level 17th. The save DCs are Charisma-based.

**Summon Undead (Su):** A nightwing can summon undead creatures once per night: 5–12 shadows, 2–4 greater shadows, or 1 dread wraith. The undead arrive in 1d10 rounds and serve for 1 hour or until released.

**Skills:** \*When hiding in a dark area or flying in a dark sky, a nightwing gains a +8 racial bonus on Hide checks.','{"full_attack":"Bite +18 melee (2d6+17/19–20 plus magic drain)","environment":"Plane of Shadow","organization":"Solitary, pair, or flock (3–6)","treasure":"Standard","advancement":"18–25 HD (Huge); 26–34 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"17d12+34 (144 hp)","hit_points":144,"base_attack_grapple":"+8/+28","attack":"Bite +18 melee (2d6+17/19–20 plus magic drain)","full_attack":"Bite +18 melee (2d6+17/19–20 plus magic drain)","space_reach":"15 ft./10 ft.","saves":"Fort +9, Ref +11, Will +17","abilities":{"str":"31","dex":"18","con":null,"int":"18","wis":"20","cha":"18"},"skills":"Concentration +24, Diplomacy +6, Hide +16*, Listen +25, Move Silently +24, Search +24, Sense Motive +25, Spellcraft +24, Spot +25, Survival +5 (+7 following tracks)","feats":"Combat Reflexes, Dodge, Flyby Attack, Great Fortitude, Improved Critical (bite), Improved Initiative","special_attacks":"Desecrating aura, magic drain, spell-like abilities, summon undead","special_qualities":"Aversion to daylight, damage reduction 15/silver and magic, darkvision 60 ft., immunity to cold, spell resistance 27, telepathy 100 ft., undead traits"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('nymph','Nymph','Nymph','7','Medium','Fey','Usually chaotic good','6d6+6 (27 hp)',27,'+3','30 ft. (6 squares), swim 20 ft.','17 (+3 Dex, +4 deflection), touch 17, flat-footed 14','+3/+3','Dagger +6 melee (1d4/19–20)','5 ft./5 ft.','+7','+12','+12',10,17,12,16,17,19,'Concentration +10, Diplomacy +6, Escape Artist +12, Handle Animal +13, Heal +12, Hide +12, Listen +12, Move Silently +12, Ride +5, Sense Motive +12, Spot +12, Swim +8, Use Rope +3 (+5 with bindings)','Combat Casting, Dodge, Weapon Finesse','{"special_attacks":"Blinding beauty, spells, spell-like abilities, stunning glance","special_qualities":"Damage reduction 10/cold iron, low-light vision, unearthly grace, wild empathy"}'::jsonb,'A nymph is about the height and weight of a female elf.

Nymphs speak Sylvan and Common.

### Combat

**Blinding Beauty (Su):** This ability affects all humanoids within 30 feet of a nymph. Those who look directly at a nymph must succeed on a DC 17 Fortitude save or be blinded permanently as though by the _blindness_ spell. A nymph can suppress or resume this ability as a free action.

The save DC is Charisma-based.

**Spell-Like Abilities:** 1/day—_dimension door._ Caster level 7th.

**Spells:** A nymph casts divine spells as a 7th-level druid.

_Typical Druid Spells Prepared_ (6/5/4/3/1, save DC 13 + spell level): 0—_cure minor wounds, detect magic, flare, guidance, light, resistance;_ 1st—_calm animal, cure light wounds, entangle, longstrider, speak with animals;_ 2nd—_barkskin, heat metal, lesser restoration, tree shape;_ 3rd— _call lightning, cure moderate wounds, protection from energy;_ 4th—_rusting grasp._

**Stunning Glance (Su):** As a standard action, a wrathful nymph can stun a creature within 30 feet with a look. The target creature must succeed on a DC 17 Fortitude save or be stunned for 2d4 rounds. The save DC is Charisma-based.

**Unearthly Grace (Su):** A nymph adds her Charisma modifier as a bonus on all her saving throws, and as a deflection bonus to her Armor Class. (The statistics block already reflects these bonuses).

**Wild Empathy (Ex):** This power works like the druid’s wild empathy class feature, except that a nymph has a +6 racial bonus on the check.

**Skills:** A nymph has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. She can always choose to take 10 on a Swim check, even if distracted or endangered. She can use the run action while swimming, provided she swims in a straight line.','{"full_attack":"Dagger +6 melee (1d4/19–20)","environment":"Temperate forests","organization":"Solitary","treasure":"Standard","advancement":"7–12 HD (Medium)","level_adjustment":"+7","statblock":{"hit_dice":"6d6+6 (27 hp)","hit_points":27,"base_attack_grapple":"+3/+3","attack":"Dagger +6 melee (1d4/19–20)","full_attack":"Dagger +6 melee (1d4/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +12, Will +12","abilities":{"str":"10","dex":"17","con":"12","int":"16","wis":"17","cha":"19"},"skills":"Concentration +10, Diplomacy +6, Escape Artist +12, Handle Animal +13, Heal +12, Hide +12, Listen +12, Move Silently +12, Ride +5, Sense Motive +12, Spot +12, Swim +8, Use Rope +3 (+5 with bindings)","feats":"Combat Casting, Dodge, Weapon Finesse","special_attacks":"Blinding beauty, spells, spell-like abilities, stunning glance","special_qualities":"Damage reduction 10/cold iron, low-light vision, unearthly grace, wild empathy"},"source_file":"monsters-m-n.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-m-n.html',true),
('ogre','Ogre','Ogre','3','Large','Giant','Usually chaotic evil','4d8+11 (29 hp)',29,'–1','30 ft. in hide armor (6 squares); base speed 40 ft.','16 (–1 size, –1 Dex, +5 natural, +3 hide armor), touch 8, flat-footed 16','+3/+12','Greatclub +8 melee (2d8+7) or javelin +1 ranged (1d8+5)','10 ft./10 ft.','+6','+0','+1',21,8,15,6,10,7,'Climb +5, Listen +2, Spot +2','Toughness, Weapon Focus (greatclub)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision"}'::jsonb,'Adult ogres stand 9 to 10 feet tall and weigh 600 to 650 pounds. Their skin color ranges from dull yellow to dull brown. Their clothing consists of poorly cured furs and hides, which add to their naturally repellent odor.

Ogres speak Giant, and those specimens who boast Intelligence scores of at least 10 also speak Common.

### Combat

Ogres favor overwhelming odds, sneak attacks, and ambushes over a fair fight. They are intelligent enough to fire ranged weapons first to soften up their foes before closing, but ogre gangs and bands fight as unorganized individuals.

### Ogre Barbarian

Their inherent bent toward chaos combines with their size and strength to make ogres natural barbarians. Indeed, their leaders are almost always barbarians of low to middle level, monstrous brutes whose fury in battle is truly fearsome. A raging ogre barbarian is an inspiration to other ogres.

#### Combat

Marginally more intelligent than his brutish fellows, an ogre barbarian is slightly more likely to enter a fair fight, but in general prefers the brutish tactics common to all its kind.

**Rage (Ex):** Twice per day, an ogre barbarian can enter a state of fierce rage that last for 9 rounds. The following changes are in effect as long as he rages: AC 17 (touch 8, flat-footed 17); hp 95; Atk +18/+13 melee (2d6+16, _+1 greatclub_); SV Fort +14, Will +4; Str 30, Con 22; Climb +15, Jump +16. At the end of his rage, the ogre barbarian is fatigued for the duration of the encounter.

**Trap Sense (Ex):** An ogre barbarian has a +1 bonus on Reflex saves made to avoid traps. He also has a +1 bonus to his AC against attacks by traps.

**Uncanny Dodge (Ex):** An ogre barbarian retains his Dex bonus to AC regardless of being caught flat-footed or attacked by an invisible opponent. His Dex bonus to AC is +0, but this means that he is not subject to a rogue’s sneak attack in these circumstances.

### Merrow

These cousins of the ogre have the aquatic subtype.

They dwell in freshwater lakes and rivers. They have a base land speed of 30 feet and a swim speed of 40 feet and are found only in aquatic environments.

Instead of the typical ogre’s greatclub, they prefer to use longspears in melee (attack +8 melee, damage 1d8+7).

### Ogres as Characters

Ogre characters possess the following racial traits.

— +10 Strength, –2 Dexterity, +4 Constitution, –4 Intelligence, –4 Charisma.

—Large size. –1 penalty to Armor Class, –1 penalty on attack rolls, –4 penalty on Hide checks, +4 bonus on grapple checks, lifting and carrying limits double those of Medium characters.

—Space/Reach: 10 feet/10 feet.

—An ogre’s base land speed is 40 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: An ogre begins with four levels of giant, which provide 4d8 Hit Dice, a base attack bonus of +3, and base saving throw bonuses of Fort +4, Ref +1, and Will +1.

—Racial Skills: An ogre’s giant levels give it skill points equal to 7 x (2 + Int modifier, minimum 1). Its class skills are Climb, Listen, and Spot.

—Racial Feats: An ogre’s giant levels give it two feats.

—Weapon and Armor Proficiency: An ogre is automatically proficient with simple weapons, martial weapons, light and medium armor, and shields.

— +5 natural armor bonus.

—Automatic Languages: Common, Giant. Bonus Languages: Dwarven, Orc, Goblin, Terran.

—Favored Class: Barbarian.

—Level adjustment +2.','{"full_attack":"Greatclub +8 melee (2d8+7) or javelin +1 ranged (1d8+5)","environment":"Temperate hills (Merrow: Temperate aquatic)","organization":"Solitary, pair, gang (3–4), or band (5–8)","treasure":"Standard","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"4d8+11 (29 hp)","hit_points":29,"base_attack_grapple":"+3/+12","attack":"Greatclub +8 melee (2d8+7) or javelin +1 ranged (1d8+5)","full_attack":"Greatclub +8 melee (2d8+7) or javelin +1 ranged (1d8+5)","space_reach":"10 ft./10 ft.","saves":"Fort +6, Ref +0, Will +1","abilities":{"str":"21","dex":"8","con":"15","int":"6","wis":"10","cha":"7"},"skills":"Climb +5, Listen +2, Spot +2","feats":"Toughness, Weapon Focus (greatclub)","special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('ogre_4th_level_barbarian','Ogre, 4th-Level Barbarian','Ogre, 4th-Level Barbarian','7','Large','Giant','Usually chaotic evil','4d8+19 plus 4d12+16 (79 hp)',79,'+0','40 ft. in hide armor (8 squares); base speed 50 ft.','19 (–1 size, +5 natural, +4 +1 hide armor, ring of protection +1), touch 10, flat-footed 19','+7/+19','+1 greatclub +16 melee (2d8+13) or javelin +6 ranged (1d8+8)','10 ft./10 ft.','+12','+2','+2',26,11,18,8,10,4,'Climb +13, Hide –6, Jump +17, Listen +6, Spot +2','Power Attack, Toughness, Weapon Focus (greatclub)','{"special_attacks":"Rage 2/day","special_qualities":"Darkvision 60 ft., low-light vision, trap sense +1, uncanny dodge"}'::jsonb,'Adult ogres stand 9 to 10 feet tall and weigh 600 to 650 pounds. Their skin color ranges from dull yellow to dull brown. Their clothing consists of poorly cured furs and hides, which add to their naturally repellent odor.

Ogres speak Giant, and those specimens who boast Intelligence scores of at least 10 also speak Common.

### Combat

Ogres favor overwhelming odds, sneak attacks, and ambushes over a fair fight. They are intelligent enough to fire ranged weapons first to soften up their foes before closing, but ogre gangs and bands fight as unorganized individuals.

### Ogre Barbarian

Their inherent bent toward chaos combines with their size and strength to make ogres natural barbarians. Indeed, their leaders are almost always barbarians of low to middle level, monstrous brutes whose fury in battle is truly fearsome. A raging ogre barbarian is an inspiration to other ogres.

#### Combat

Marginally more intelligent than his brutish fellows, an ogre barbarian is slightly more likely to enter a fair fight, but in general prefers the brutish tactics common to all its kind.

**Rage (Ex):** Twice per day, an ogre barbarian can enter a state of fierce rage that last for 9 rounds. The following changes are in effect as long as he rages: AC 17 (touch 8, flat-footed 17); hp 95; Atk +18/+13 melee (2d6+16, _+1 greatclub_); SV Fort +14, Will +4; Str 30, Con 22; Climb +15, Jump +16. At the end of his rage, the ogre barbarian is fatigued for the duration of the encounter.

**Trap Sense (Ex):** An ogre barbarian has a +1 bonus on Reflex saves made to avoid traps. He also has a +1 bonus to his AC against attacks by traps.

**Uncanny Dodge (Ex):** An ogre barbarian retains his Dex bonus to AC regardless of being caught flat-footed or attacked by an invisible opponent. His Dex bonus to AC is +0, but this means that he is not subject to a rogue’s sneak attack in these circumstances.

### Merrow

These cousins of the ogre have the aquatic subtype.

They dwell in freshwater lakes and rivers. They have a base land speed of 30 feet and a swim speed of 40 feet and are found only in aquatic environments.

Instead of the typical ogre’s greatclub, they prefer to use longspears in melee (attack +8 melee, damage 1d8+7).

### Ogres as Characters

Ogre characters possess the following racial traits.

— +10 Strength, –2 Dexterity, +4 Constitution, –4 Intelligence, –4 Charisma.

—Large size. –1 penalty to Armor Class, –1 penalty on attack rolls, –4 penalty on Hide checks, +4 bonus on grapple checks, lifting and carrying limits double those of Medium characters.

—Space/Reach: 10 feet/10 feet.

—An ogre’s base land speed is 40 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: An ogre begins with four levels of giant, which provide 4d8 Hit Dice, a base attack bonus of +3, and base saving throw bonuses of Fort +4, Ref +1, and Will +1.

—Racial Skills: An ogre’s giant levels give it skill points equal to 7 x (2 + Int modifier, minimum 1). Its class skills are Climb, Listen, and Spot.

—Racial Feats: An ogre’s giant levels give it two feats.

—Weapon and Armor Proficiency: An ogre is automatically proficient with simple weapons, martial weapons, light and medium armor, and shields.

— +5 natural armor bonus.

—Automatic Languages: Common, Giant. Bonus Languages: Dwarven, Orc, Goblin, Terran.

—Favored Class: Barbarian.

—Level adjustment +2.','{"full_attack":"+1 greatclub +16/+11 melee (2d8+13) or javelin +6 ranged (1d8+8)","environment":"Temperate hills","organization":"Solitary, pair, gang (1 plus 1–3 ogres), or band (1 plus 4–7 ogres)","treasure":"Standard (including +1 hide armor, +1 greatclub, and ring of protection +1)","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"4d8+19 plus 4d12+16 (79 hp)","hit_points":79,"base_attack_grapple":"+7/+19","attack":"+1 greatclub +16 melee (2d8+13) or javelin +6 ranged (1d8+8)","full_attack":"+1 greatclub +16/+11 melee (2d8+13) or javelin +6 ranged (1d8+8)","space_reach":"10 ft./10 ft.","saves":"Fort +12, Ref +2, Will +2","abilities":{"str":"26","dex":"11","con":"18","int":"8","wis":"10","cha":"4"},"skills":"Climb +13, Hide –6, Jump +17, Listen +6, Spot +2","feats":"Power Attack, Toughness, Weapon Focus (greatclub)","special_attacks":"Rage 2/day","special_qualities":"Darkvision 60 ft., low-light vision, trap sense +1, uncanny dodge"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('ogre_mage','Ogre Mage','Ogre Mage','8','Large','Giant','Usually lawful evil','5d8+15 (37 hp)',37,'+4','40 ft. (8 squares), fly 40 ft. (good)','18 (–1 size, +5 natural, +4 chain shirt), touch 9, flat-footed 18','+3/+12','Greatsword +7 melee (3d6+7/19–20) or longbow +2 ranged (2d6/x3)','10 ft./10 ft.','+7','+1','+3',21,10,17,14,14,17,'Concentration +11, Listen +10, Spellcraft +10, Spot +10','Combat Expertise, Improved Initiative','{"special_attacks":"Spell-like abilities","special_qualities":"Darkvision 90 ft., low-light vision, regeneration 5, spell resistance 19"}'::jsonb,'The ogre mage is a more intelligent and dangerous variety of its mundane cousin.

An ogre mage stands about 10 feet tall and weighs up to 700 pounds. Its skin varies in color from light green to light blue, and its hair is black or very dark brown. Ogre mages favor loose, comfortable clothing and lightweight armor.

Ogre mages speak Giant and Common.

### Combat

Ogre mages rely on their spell-like abilities, resorting to physical combat only when necessary. When faced with obviously superior forces, they prefer to retreat using _gaseous form_ rather than fight a losing battle.

**Spell-Like Abilities:** At will—_darkness, invisibility;_ 1/day— _charm person_ (DC 14)_, cone of cold_ (DC 18)_, gaseous form, polymorph, sleep_ (DC 14). Caster level 9th. The save DCs are Charisma-based.

**Flight (Su):** An ogre mage can cease or resume flight as a free action. While using _gaseous form_ it can fly at its normal speed and has perfect maneuverability.

**Regeneration (Ex):** Fire and acid deal normal damage to an ogre mage.

An ogre mage that loses a limb or body part can reattach it by holding the severed member to the stump. Reattachment takes 1 minute. If the head or some other vital organ is severed, it must be reattached within 10 minutes or the creature dies. An ogre mage cannot regrow lost body parts.

### Ogre Mages as Characters

Ogre mage characters possess the following racial traits.

— +10 Strength, +6 Constitution, +4 Intelligence, +4 Wisdom, +6 Charisma.

—Large size. –1 penalty to Armor Class, –1 penalty on attack rolls, –4 penalty on Hide checks, +4 bonus on grapple checks, lifting and carrying limits double those of Medium characters.

—Space/Reach: 10 feet/10 feet.

—An ogre mage’s base land speed is 40 feet. It also has a fly speed of 40 feet (good).

—Darkvision: Ogre mages can see in the dark up to 60 feet.

—Racial Hit Dice: An ogre mage begins with five levels of giant, which provide 5d8 Hit Dice, a base attack bonus of +3, and base saving throw bonuses of Fort +4, Ref +1, and Will +1.

—Racial Skills: An ogre mage’s giant levels give it skill points equal to 8 x (2 + Int modifier \[minimum 1\]). Its class skills are Concentration, Listen, Spellcraft, and Spot.

—Racial Feats: An ogre mage’s giant levels give it two feats.

— +5 natural armor bonus.

—Special Attacks (see above): Spell-like abilities.

—Special Qualities (see above): Regeneration 5, spell resistance 19.

—Automatic Languages: Common, Giant. Bonus Languages: Dwarven, Goblin, Infernal, Orc.

—Favored Class: Sorcerer.

—Level adjustment +7.','{"full_attack":"Greatsword +7 melee (3d6+7/19–20) or longbow +2 ranged (2d6/x3)","environment":"Cold hills","organization":"Solitary, pair, or troupe (1–2 plus 2–4 ogres)","treasure":"Double standard","advancement":"By character class","level_adjustment":"+7","statblock":{"hit_dice":"5d8+15 (37 hp)","hit_points":37,"base_attack_grapple":"+3/+12","attack":"Greatsword +7 melee (3d6+7/19–20) or longbow +2 ranged (2d6/x3)","full_attack":"Greatsword +7 melee (3d6+7/19–20) or longbow +2 ranged (2d6/x3)","space_reach":"10 ft./10 ft.","saves":"Fort +7, Ref +1, Will +3","abilities":{"str":"21","dex":"10","con":"17","int":"14","wis":"14","cha":"17"},"skills":"Concentration +11, Listen +10, Spellcraft +10, Spot +10","feats":"Combat Expertise, Improved Initiative","special_attacks":"Spell-like abilities","special_qualities":"Darkvision 90 ft., low-light vision, regeneration 5, spell resistance 19"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('black_pudding','Black Pudding','Black Pudding','7','Huge','Ooze','Always neutral','10d10+60 (115 hp)',115,'–5','20 ft. (4 squares), climb 20 ft.','3 (–2 size, –5 Dex), touch 3, flat-footed 3','+7/+18','Slam +8 melee (2d6+4 plus 2d6 acid)','15 ft./10 ft.','+9','–2','–2',17,1,22,null,1,1,'Climb +11','—','{"special_attacks":"Acid, constrict 2d6+4 plus 2d6 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"}'::jsonb,'The typical black pudding measures 15 feet across and 2 feet thick. It weighs about 18,000 pounds.

#### Combat

A black pudding attacks by grabbing and squeezing their prey.

**Acid (Ex):** The creature secretes a digestive acid that dissolves organic material and metal quickly, but does not affect stone. Any melee hit or constrict attack deals acid damage, and the opponent’s armor and clothing dissolve and become useless immediately unless they succeed on DC 21 Reflex saves. A metal or wooden weapon that strikes a black pudding also dissolves immediately unless it succeeds on a DC 21 Reflex save. The save DCs are Constitution-based.

The pudding’s acidic touch deals 21 points of damage per round to wooden or metal objects, but the ooze must remain in contact with the object for 1 full round to deal this damage.

**Constrict (Ex):** A black pudding deals automatic slam and acid damage with a successful grapple check. The opponent’s clothing and armor take a –4 penalty on Reflex saves against the acid.

**Improved Grab (Ex):** To use this ability, a black pudding must hit with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Split (Ex):** Slashing and piercing weapons deal no damage to a black pudding. Instead the creature splits into two identical puddings, each with half of the original’s current hit points (round down). A pudding with 10 hit points or less cannot be further split and dies if reduced to 0 hit points.

**Skills:** A black pudding has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"Slam +8 melee (2d6+4 plus 2d6 acid)","environment":"Underground","organization":"Solitary","treasure":"None","advancement":"11–15 HD (Huge); 16–30 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"10d10+60 (115 hp)","hit_points":115,"base_attack_grapple":"+7/+18","attack":"Slam +8 melee (2d6+4 plus 2d6 acid)","full_attack":"Slam +8 melee (2d6+4 plus 2d6 acid)","space_reach":"15 ft./10 ft.","saves":"Fort +9, Ref –2, Will –2","abilities":{"str":"17","dex":"1","con":"22","int":null,"wis":"1","cha":"1"},"skills":"Climb +11","feats":"—","special_attacks":"Acid, constrict 2d6+4 plus 2d6 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('elder_black_pudding','Elder Black Pudding','Elder Black Pudding','12','Gargantuan','Ooze','Always neutral','20d10+180 (290 hp)',290,'–5','20 ft. (4 squares), climb 20 ft.','1 (–4 size, –5 Dex), touch 1, flat-footed 1','+15/+35','Slam +19 melee (3d6+12 plus 3d6 acid)','20 ft./20 ft.','+15','+1','+1',26,1,28,null,1,1,'Climb +16','—','{"special_attacks":"Acid, constrict 2d8+12 plus 2d6 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"}'::jsonb,'The typical black pudding measures 15 feet across and 2 feet thick. It weighs about 18,000 pounds.

#### Combat

A black pudding attacks by grabbing and squeezing their prey.

**Acid (Ex):** The creature secretes a digestive acid that dissolves organic material and metal quickly, but does not affect stone. Any melee hit or constrict attack deals acid damage, and the opponent’s armor and clothing dissolve and become useless immediately unless they succeed on DC 21 Reflex saves. A metal or wooden weapon that strikes a black pudding also dissolves immediately unless it succeeds on a DC 21 Reflex save. The save DCs are Constitution-based.

The pudding’s acidic touch deals 21 points of damage per round to wooden or metal objects, but the ooze must remain in contact with the object for 1 full round to deal this damage.

**Constrict (Ex):** A black pudding deals automatic slam and acid damage with a successful grapple check. The opponent’s clothing and armor take a –4 penalty on Reflex saves against the acid.

**Improved Grab (Ex):** To use this ability, a black pudding must hit with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Split (Ex):** Slashing and piercing weapons deal no damage to a black pudding. Instead the creature splits into two identical puddings, each with half of the original’s current hit points (round down). A pudding with 10 hit points or less cannot be further split and dies if reduced to 0 hit points.

**Skills:** A black pudding has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"Slam +19 melee (3d6+12 plus 3d6 acid)","environment":"Underground","organization":"Solitary","treasure":"None","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"20d10+180 (290 hp)","hit_points":290,"base_attack_grapple":"+15/+35","attack":"Slam +19 melee (3d6+12 plus 3d6 acid)","full_attack":"Slam +19 melee (3d6+12 plus 3d6 acid)","space_reach":"20 ft./20 ft.","saves":"Fort +15, Ref +1, Will +1","abilities":{"str":"26","dex":"1","con":"28","int":null,"wis":"1","cha":"1"},"skills":"Climb +16","feats":"—","special_attacks":"Acid, constrict 2d8+12 plus 2d6 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('gelatinous_cube','Gelatinous Cube','Gelatinous Cube','3','Huge','Ooze','Always neutral','4d10+32 (54 hp)',54,'–5','15 ft. (3 squares)','3 (–2 size, –5 Dex), touch 3, flat-footed 3','+3/+11','Slam +1 melee (1d6 plus 1d6 acid)','15 ft./10 ft.','+9','–4','–4',10,1,26,null,1,1,'—','—','{"special_attacks":"Acid, engulf, paralysis","special_qualities":"Blindsight 60 ft., immunity to electricity, ooze traits, transparent"}'::jsonb,'The nearly transparent gelatinous cube travels slowly along dungeon corridors and cave floors, absorbing carrion, creatures, and trash. Inorganic material remains trapped and visible inside the cube’s body.

A typical gelatinous cube is 15 feet on a side and weighs about 50,000 pounds, though much larger specimens are not unknown.

#### Combat

A gelatinous cube attacks by slamming its body into its prey. It is capable of lashing out with a pseudopod, but usually engulfs foes.

**Acid (Ex):** A gelatinous cube’s acid does not harm metal or stone.

**Engulf (Ex):** Although it moves slowly, a gelatinous cube can simply mow down Large or smaller creatures as a standard action. It cannot make a slam attack during a round in which it engulfs. The gelatinous cube merely has to move over the opponents, affecting as many as it can cover. Opponents can make opportunity attacks against the cube, but if they do so they are not entitled to a saving throw. Those who do not attempt attacks of opportunity must succeed on a DC 13 Reflex save or be engulfed; on a success, they are pushed back or aside (opponent’s choice) as the cube moves forward. Engulfed creatures are subject to the cube’s paralysis and acid, and are considered to be grappled and trapped within its body. The save DC is Strength-based and includes a +1 racial bonus.

**Paralysis (Ex):** A gelatinous cube secretes an anesthetizing slime. A target hit by a cube’s melee or engulf attack must succeed on a DC 20 Fortitude save or be paralyzed for 3d6 rounds. The cube can automatically engulf a paralyzed opponent. The save DC is Constitution-based.

**Transparent (Ex):** Gelatinous cubes are hard to see, even under ideal conditions, and it takes a DC 15 Spot check to notice one. Creatures who fail to notice a cube and walk into it are automatically engulfed.','{"full_attack":"Slam +1 melee (1d6 plus 1d6 acid)","environment":"Underground","organization":"Solitary","treasure":"1/10th coins, 50% goods (no nonmetal or nonstone), 50% items (no nonmetal or nonstone)","advancement":"5–12 HD (Huge); 13–24 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"4d10+32 (54 hp)","hit_points":54,"base_attack_grapple":"+3/+11","attack":"Slam +1 melee (1d6 plus 1d6 acid)","full_attack":"Slam +1 melee (1d6 plus 1d6 acid)","space_reach":"15 ft./10 ft.","saves":"Fort +9, Ref –4, Will –4","abilities":{"str":"10","dex":"1","con":"26","int":null,"wis":"1","cha":"1"},"skills":"—","feats":"—","special_attacks":"Acid, engulf, paralysis","special_qualities":"Blindsight 60 ft., immunity to electricity, ooze traits, transparent"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('gray_ooze','Gray Ooze','Gray Ooze','4','Medium','Ooze','Always neutral','3d10+15 (31 hp)',31,'–5','10 ft. (2 squares)','5 (–5 Dex), touch 5, flat-footed 5','+2/+3','Slam +3 melee (1d6+1 plus 1d6 acid)','5 ft./5 ft.','+6','–4','–4',12,1,21,null,1,1,'—','—','{"special_attacks":"Acid, constrict 1d6+1 plus 1d6 acid, improved grab","special_qualities":"Blindsight 60 ft., immunity to cold and fire, ooze traits, transparent"}'::jsonb,'A gray ooze can grow to a diameter of up to 10 feet and a thickness of about 6 inches. A typical specimen weighs about 700 pounds.

#### Combat

A gray ooze strikes like a snake, slamming opponents with its body.

**Acid (Ex):** A gray ooze secretes a digestive acid that quickly dissolves organic material and metal, but not stone. Any melee hit or constrict attack deals acid damage. Armor or clothing dissolves and becomes useless immediately unless it succeeds on a DC 16 Reflex save. A metal or wooden weapon that strikes a gray ooze also dissolves immediately unless it succeeds on a DC 16 Reflex save. The save DCs are Constitution-based.

The ooze’s acidic touch deals 16 points of damage per round to wooden or metal objects, but the ooze must remain in contact with the object for 1 full round to deal this damage.

**Constrict (Ex):** A gray ooze deals automatic slam and acid damage with a successful grapple check. The opponent’s clothing and armor take a –4 penalty on Reflex saves against the acid.

**Improved Grab (Ex):** To use this ability, a gray ooze must hit with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Transparent (Ex):** A gray ooze is hard to identify, even under ideal conditions, and it takes a DC 15 Spot check to notice one. Creatures who fail to notice a gray ooze and walk into it are automatically hit with a melee attack for slam and acid damage.','{"full_attack":"Slam +3 melee (1d6+1 plus 1d6 acid)","environment":"Cold marshes","organization":"Solitary","treasure":"None","advancement":"4–6 HD (Medium); 7–9 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"3d10+15 (31 hp)","hit_points":31,"base_attack_grapple":"+2/+3","attack":"Slam +3 melee (1d6+1 plus 1d6 acid)","full_attack":"Slam +3 melee (1d6+1 plus 1d6 acid)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref –4, Will –4","abilities":{"str":"12","dex":"1","con":"21","int":null,"wis":"1","cha":"1"},"skills":"—","feats":"—","special_attacks":"Acid, constrict 1d6+1 plus 1d6 acid, improved grab","special_qualities":"Blindsight 60 ft., immunity to cold and fire, ooze traits, transparent"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('ochre_jelly','Ochre Jelly','Ochre Jelly','5','Large','Ooze','Always neutral','6d10+36 (69 hp)',69,'–5','10 ft. (2 squares), climb 10 ft.','4 (–1 size, –5 Dex), touch 4, flat-footed 4','+4/+10','Slam +5 melee (2d4+3 plus 1d4 acid)','10 ft./5 ft.','+8','–3','–3',15,1,22,null,1,1,'Climb +10','—','{"special_attacks":"Acid, constrict 2d4+3 plus 1d4 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"}'::jsonb,'An ochre jelly can grow to a diameter of about 15 feet and a thickness of about 6 inches, but can compress its body to fit into cracks as small as 1 inch wide. A typical specimen weighs about 5,600 pounds.

#### Combat

An ochre jelly attempts to envelop and squeeze its prey.

**Acid (Ex):** An ochre jelly secretes a digestive acid that dissolves only flesh. Any melee hit or constrict attack deals acid damage.

**Constrict (Ex):** An ochre jelly deals automatic slam and acid damage with a successful grapple check.

**Improved Grab (Ex):** To use this ability, an ochre jelly must hit with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Split (Ex):** Slashing and piercing weapons and electricity attacks deal no damage to an ochre jelly. Instead the creature splits into two identical jellies, each with half of the original’s current hit points (round down). A jelly with 10 hit points or less cannot be further split and dies if reduced to 0 it points.

**Skills:** An ochre jelly has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"Slam +5 melee (2d4+3 plus 1d4 acid)","environment":"Temperate marshes","organization":"Solitary","treasure":"None","advancement":"7–9 HD (Large); 10–18 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"6d10+36 (69 hp)","hit_points":69,"base_attack_grapple":"+4/+10","attack":"Slam +5 melee (2d4+3 plus 1d4 acid)","full_attack":"Slam +5 melee (2d4+3 plus 1d4 acid)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref –3, Will –3","abilities":{"str":"15","dex":"1","con":"22","int":null,"wis":"1","cha":"1"},"skills":"Climb +10","feats":"—","special_attacks":"Acid, constrict 2d4+3 plus 1d4 acid, improved grab","special_qualities":"Blindsight 60 ft., split, ooze traits"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('orc','Orc','Orc, 1st-Level Warrior','1/2','Medium','Humanoid (Orc)','Often chaotic evil','1d8+1 (5 hp)',5,'+0','30 ft. (6 squares)','13 (+3 studded leather armor), touch 10, flat-footed 13','+1/+4','Falchion +4 melee (2d4+4/18–20) or javelin +1 ranged (1d6+3)','5 ft./5 ft.','+3','+0','–2',17,11,12,8,7,6,'Listen +1, Spot +1','Alertness','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., light sensitivity"}'::jsonb,'An orc’s hair usually is black. It has lupine ears and reddish eyes. Orcs prefer wearing vivid colors that many humans would consider unpleasant, such as blood red, mustard yellow, yellow-green, and deep purple. Their equipment is dirty and unkempt. An adult male orc is a little over 6 feet tall and weighs about 210 pounds.

Females are slightly smaller.

The language an orc speaks varies slightly from tribe to tribe, but any orc is understandable by someone else who speaks Orc. Some orcs know Goblin or Giant as well.

Most orcs encountered away from their homes are warriors; the information in the statistics block is for one of 1st level.

### Combat

Orcs are proficient with all simple weapons, preferring those that cause the most damage in the least time. Many orcs who take up the warrior or fighter class also gain proficiency with the falchion or the greataxe as a martial weapon. They enjoy attacking from concealment and setting ambushes, and they obey the rules of war (such as honoring a truce) only as long as it is convenient for them.

**Light Sensitivity (Ex):** Orcs are dazzled in bright sunlight or within the radius of a _daylight_ spell.

### Orcs as Characters

**Orc Traits (Ex):** Orcs possess the following racial traits.

— +4 Strength, –2 Intelligence, –2 Wisdom, –2 Charisma.

—An orc’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Light Sensitivity: Orcs are dazzled in bright sunlight or within the radius of a _daylight_ spell.

—Automatic Languages: Common, Orc. Bonus Languages: Dwarven, Giant, Gnoll, Goblin, Undercommon.

—Favored Class: Barbarian.

The orc warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Half-Orcs

These orc–human crossbreeds can be found in either orc or human society (where their status varies according to local sentiments), or in communities of their own. Half-orcs usually inherit a good blend of the physical characteristics of their parents. They are as tall as humans and a little heavier, thanks to their muscle. They have greenish pigmentation, sloping foreheads, jutting jaws, prominent teeth, and coarse body hair. Half-orcs who have lived among or near orcs have scars, in keeping with orcish tradition.

**Half-Orc Traits (Ex):** Half-orcs possess the following racial traits.

— +2 Strength, –2 Intelligence, –2 Charisma.

—Medium size.

—A half-orc’s base land speed is 30 feet.

—Darkvision: Half-orcs can see in the dark up to 60 feet.

—Orc Blood: For all effects related to race, a half-orc is considered an orc.

—Automatic Languages: Common, Orc. Bonus Languages: Draconic, Giant, Gnoll, Goblin, Abyssal.

—Favored Class: Barbarian.','{"full_attack":"Falchion +4 melee (2d4+4/18–20) or javelin +1 ranged (1d6+3)","environment":"Temperate hills","organization":"Gang (2–4), squad (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or band (30–100 plus 150% noncombatants plus 1 3rd-level sergeant per 10 adults, 5 5th-level lieutenants, and 3 7th-level captains)","treasure":"Standard","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/+4","attack":"Falchion +4 melee (2d4+4/18–20) or javelin +1 ranged (1d6+3)","full_attack":"Falchion +4 melee (2d4+4/18–20) or javelin +1 ranged (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +0, Will –2","abilities":{"str":"17","dex":"11","con":"12","int":"8","wis":"7","cha":"6"},"skills":"Listen +1, Spot +1","feats":"Alertness","special_attacks":"—","special_qualities":"Darkvision 60 ft., light sensitivity"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('otyugh','Otyugh','Otyugh','4','Large','Aberration','Usually neutral','6d8+9 (36 hp)',36,'+0','20 ft. (4 squares)','17 (–1 size, +8 natural), touch 9, flat-footed 17','+4/+8','Tentacle +4 melee (1d6)','10 ft./10 ft. (15 ft. with tentacle)','+3','+2','+6',11,10,13,5,12,6,'Hide –1*, Listen +6, Spot +6','Alertness, Toughness, Weapon Focus (tentacle)','{"special_attacks":"Constrict 1d6, disease, improved grab","special_qualities":"Darkvision 60 ft., scent"}'::jsonb,'A typical otyugh has a body 8 feet in diameter and weighs about 500 pounds.

Otyughs speak Common.

### Combat

An otyugh attacks living creatures if it feels threatened or if it is hungry; otherwise it is content to remain hidden. Otyughs slash and squeeze opponents with their tentacles, which they also use to drag prey into their mouths.

**Constrict (Ex):** An otyugh deals automatic tentacle damage with a successful grapple check.

**Disease (Ex):** Filth fever—bite, Fortitude DC 14, incubation period 1d3 days; damage 1d3 Dex and 1d3 Con. The save DC is Constitution-based.

**Improved Grab (Ex):** To use this ability, an otyugh must hit with a tentacle attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Skills:** \*An otyugh has a +8 racial bonus on Hide checks when in its lair, due to its natural coloration.','{"full_attack":"2 tentacles +4 melee (1d6) and bite –2 melee (1d4)","environment":"Underground","organization":"Solitary, pair, or cluster (3–4)","treasure":"Standard","advancement":"7–8 HD (Large); 9–18 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"6d8+9 (36 hp)","hit_points":36,"base_attack_grapple":"+4/+8","attack":"Tentacle +4 melee (1d6)","full_attack":"2 tentacles +4 melee (1d6) and bite –2 melee (1d4)","space_reach":"10 ft./10 ft. (15 ft. with tentacle)","saves":"Fort +3, Ref +2, Will +6","abilities":{"str":"11","dex":"10","con":"13","int":"5","wis":"12","cha":"6"},"skills":"Hide –1*, Listen +6, Spot +6","feats":"Alertness, Toughness, Weapon Focus (tentacle)","special_attacks":"Constrict 1d6, disease, improved grab","special_qualities":"Darkvision 60 ft., scent"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('owl_giant','Owl, Giant','Owl, Giant','3','Large','Magical Beast','Usually neutral good','4d10+4 (26 hp)',26,'+3','10 ft. (2 squares), fly 70 ft. (average)','15 (–1 size, +3 Dex, +3 natural), touch 12, flat-footed 12','+4/+12','Claw +7 melee (1d6+4)','10 ft./5 ft.','+5','+7','+3',18,17,12,10,14,10,'Knowledge (nature) +2, Listen +17, Move Silently +8*, Spot +10','Alertness, Wingover','{"special_attacks":"—","special_qualities":"Superior lowlight vision"}'::jsonb,'Giant owls are nocturnal birds of prey, feared for their ability to hunt and attack in near silence. They are intelligent, and though naturally suspicious, sometimes associate with good creatures. A typical giant owl stands about 9 feet tall, has a wingspan of up to 20 feet, and resembles its smaller cousins in nearly every way except size.

Giant owls speak Common and Sylvan.

### Combat

A giant owl attacks by gliding silently just a few feet above its prey and plunging to strike when directly overhead.

**Superior Low-Light Vision (Ex):** A giant owl can see five times as far as a human can in dim light.

**Skills:** Giant owls have a +8 racial bonus on Listen checks and a +4 racial bonus on Spot checks.

\*When in flight, giant owls gain a +8 bonus on Move Silently checks.

### Training a Giant Owl

Although intelligent, a giant owl requires training before it can bear a rider in combat. To be trained, a giant owl must have a friendly attitude toward the trainer (this can be achieved through a successful Diplomacy check). Training a friendly giant owl requires six weeks of work and a DC 25 Handle Animal check. Riding a giant owl requires an exotic saddle. A giant owl can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

Giant owl eggs are worth 2,500 gp apiece on the open market, while chicks are worth 4,000 gp each. Professional trainers charge 1,000 gp to rear or train a giant owl.

**Carrying Capacity:** A light load for a giant owl is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.','{"full_attack":"2 claws +7 melee (1d6+4) and bite +2 melee (1d8+2)","environment":"Temperate forests","organization":"Solitary, pair, or company (3–5)","treasure":"None","advancement":"5–8 HD (Large); 9–12 HD (Huge)","level_adjustment":"+2 (cohort)","statblock":{"hit_dice":"4d10+4 (26 hp)","hit_points":26,"base_attack_grapple":"+4/+12","attack":"Claw +7 melee (1d6+4)","full_attack":"2 claws +7 melee (1d6+4) and bite +2 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +5, Ref +7, Will +3","abilities":{"str":"18","dex":"17","con":"12","int":"10","wis":"14","cha":"10"},"skills":"Knowledge (nature) +2, Listen +17, Move Silently +8*, Spot +10","feats":"Alertness, Wingover","special_attacks":"—","special_qualities":"Superior lowlight vision"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('owlbear','Owlbear','Owlbear','4','Large','Magical Beast','Always neutral','5d10+25 (52 hp)',52,'+1','30 ft. (6 squares)','15 (–1 size, +1 Dex, +5 natural), touch 10, flat-footed 14','+5/+14','Claw +9 melee (1d6+5)','10 ft./5 ft.','+9','+5','+2',21,12,21,2,12,10,'Listen +8, Spot +8','Alertness, Track','{"special_attacks":"Improved grab","special_qualities":"Scent"}'::jsonb,'An owlbear’s coat ranges in color from brown-black to yellowish brown; its beak is a dull ivory color. A full-grown male can stand as tall as 8 feet and weigh up to 1,500 pounds. Adventurers who have survived encounters with the creature often speak of the bestial madness they glimpsed in its red-rimmed eyes.

### Combat

Owlbears attack prey—any creature bigger than a mouse—on sight, always fighting to the death. They slash with claws and beak, trying to grab their prey and rip it apart.

**Improved Grab (Ex):** To use this ability, an owlbear must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.','{"full_attack":"2 claws +9 melee (1d6+5) and bite +4 melee (1d8+2)","environment":"Temperate forests","organization":"Solitary, pair, or pack (3–8)","treasure":"None","advancement":"6–8 HD (Large); 9–15 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"5d10+25 (52 hp)","hit_points":52,"base_attack_grapple":"+5/+14","attack":"Claw +9 melee (1d6+5)","full_attack":"2 claws +9 melee (1d6+5) and bite +4 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +5, Will +2","abilities":{"str":"21","dex":"12","con":"21","int":"2","wis":"12","cha":"10"},"skills":"Listen +8, Spot +8","feats":"Alertness, Track","special_attacks":"Improved grab","special_qualities":"Scent"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('pegasus','Pegasus','Pegasus','3','Large','Magical Beast','Usually chaotic good','4d10+12 (34 hp)',34,'+2','60 ft. (12 squares), fly 120 ft. (average)','14 (–1 size, +2 Dex, +3 natural), touch 11, flat-footed 12','+4/+12','Hoof +7 melee (1d6+4)','10 ft./5 ft.','+7','+6','+4',18,15,16,10,13,13,'Diplomacy +3, Listen +8, Sense Motive +9, Spot +8','Flyby Attack, Iron Will','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision, scent, spell-like abilities"}'::jsonb,'The pegasus is a magnificent winged horse that sometimes serves the cause of good. Though highly prized as aerial steeds, pegasi are wild and shy creatures not easily tamed.

A typical pegasus stands 6 feet high at the shoulder, weighs 1,500 pounds, and has a wingspan of 20 feet. Pegasi cannot speak, but they understand Common.

### Combat

**Spell-Like Abilities:** At will—_detect good_ and _detect evil_ within a 60-foot radius. Caster level 5th.

**Skills:** Pegasi have a +4 racial bonus on Listen and Spot checks.

### Training a Pegasus

Although intelligent, a pegasus requires training before it can bear a rider in combat. To be trained, a pegasus must have a friendly attitude toward the trainer (this can be achieved through a successful Diplomacy check). Training a friendly pegasus requires six weeks of work and a DC 25 Handle Animal check. Riding a pegasus requires an exotic saddle. A pegasus can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

Pegasus eggs are worth 2,000 gp each on the open market, while young are worth 3,000 gp per head. Pegasi mature at the same rate as horses. Professional trainers charge 1,000 gp to rear or train a pegasus, which serves a good or neutral master with absolute faithfulness for life.

**Carrying Capacity:** A light load for a pegasus is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.','{"full_attack":"2 hooves +7 melee (1d6+4) and bite +2 melee (1d3+2)","environment":"Temperate forests","organization":"Solitary, pair, or herd (6–10)","treasure":"None","advancement":"5–8 HD (Large)","level_adjustment":"+2 (cohort)","statblock":{"hit_dice":"4d10+12 (34 hp)","hit_points":34,"base_attack_grapple":"+4/+12","attack":"Hoof +7 melee (1d6+4)","full_attack":"2 hooves +7 melee (1d6+4) and bite +2 melee (1d3+2)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +6, Will +4","abilities":{"str":"18","dex":"15","con":"16","int":"10","wis":"13","cha":"13"},"skills":"Diplomacy +3, Listen +8, Sense Motive +9, Spot +8","feats":"Flyby Attack, Iron Will","special_attacks":"—","special_qualities":"Darkvision 60 ft., low-light vision, scent, spell-like abilities"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('phantom_fungus','Phantom Fungus','Phantom Fungus','3','Medium','Plant','Always neutral','2d8+6 (15 hp)',15,'+0','20 ft. (4 squares)','14 (+4 natural), touch 10, flat-footed 14','+1/+3','Bite +3 melee (1d6+3)','5 ft./5 ft.','+6','+0','+0',14,10,16,2,11,9,'Listen +4, Move Silently +6, Spot +4','Alertness','{"special_attacks":"—","special_qualities":"Low-light vision, plant traits, greater invisibility"}'::jsonb,'This creature looks like a brown and greenish-brown mass with a cluster of nodules atop the main mass, though it is visible only when dead. A cluster of nodules atop the main mass serve as sensory organs. The creature feeds and attacks with a gaping maw lined with rows of teeth. Four stumpy legs support the creature and allow it to move about. This ambulatory fungus is naturally invisible, making it a feared predator among subterranean inhabitants.

### Combat

A phantom fungus usually roams quietly, hunting for prey. It attacks lone individuals almost anywhere, but when tackling groups it prefers an open space where it has a better chance .

**Greater Invisibility (Su):** This ability is constant, allowing a phantom fungus to remain invisible even when attacking. It works like _greater invisibility_ (caster level 12th) and lasts as long as the phantom fungus is alive. This ability is not subject to the _invisibility purge_ spell. A phantom fungus becomes visible 1 minute after it is killed.

**Skills:** A phantom fungus has a +5 racial bonus on Move Silently checks.','{"full_attack":"Bite +3 melee (1d6+3)","environment":"Underground","organization":"Solitary","treasure":"None","advancement":"3–4 HD (Medium); 5–6 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"2d8+6 (15 hp)","hit_points":15,"base_attack_grapple":"+1/+3","attack":"Bite +3 melee (1d6+3)","full_attack":"Bite +3 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +0, Will +0","abilities":{"str":"14","dex":"10","con":"16","int":"2","wis":"11","cha":"9"},"skills":"Listen +4, Move Silently +6, Spot +4","feats":"Alertness","special_attacks":"—","special_qualities":"Low-light vision, plant traits, greater invisibility"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('phase_spider','Phase Spider','Phase Spider','5','Large','Magical Beast','Always neutral','5d10+15 (42 hp)',42,'+7','40 ft. (8 squares), climb 20 ft.','15 (–1 size, +3 Dex, +3 natural), touch 12, flat-footed 12','+5/+12','Bite +7 melee (1d6+4 plus poison)','10 ft./5 ft.','+7','+7','+2',17,17,16,7,13,10,'Climb +11, Move Silently +11, Spot +4','Ability Focus (poison), Improved Initiative','{"special_attacks":"Poison","special_qualities":""}'::jsonb,'Phase spiders are aggressive predators that can move quickly from the Ethereal Plane to attack opponents on the Material Plane.

A typical phase spider’s body is 8 feet long. It weighs about 700 pounds.

Phase spiders cannot speak.

### Combat

Phase spiders dwell and hunt on the Material Plane. Once a spider locates prey, however, it shifts to the Ethereal Plane to attack, attempting to catch its victim flat-footed. The spider shifts in, bites its victim, and retreats quickly back to the Ethereal Plane.

**Ethereal Jaunt (Su):** A phase spider can shift from the Ethereal Plane to the Material Plane as a free action, and shift back again as a move action (or during a move action). The ability is otherwise identical with _ethereal jaunt_ (caster level 15th).

**Poison (Ex):** Injury, Fortitude DC 17, initial and secondary damage 1d8 Con. The save DC is Constitution-based.

**Skills:** A phase spider has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"Bite +7 melee (1d6+4 plus poison)","environment":"Warm hills","organization":"Solitary or cluster (2–5)","treasure":"None","advancement":"6–8 HD (Large); 9–15 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"5d10+15 (42 hp)","hit_points":42,"base_attack_grapple":"+5/+12","attack":"Bite +7 melee (1d6+4 plus poison)","full_attack":"Bite +7 melee (1d6+4 plus poison)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +7, Will +2","abilities":{"str":"17","dex":"17","con":"16","int":"7","wis":"13","cha":"10"},"skills":"Climb +11, Move Silently +11, Spot +4","feats":"Ability Focus (poison), Improved Initiative","special_attacks":"Poison","special_qualities":""},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('phasm','Phasm','Phasm','7','Medium','Aberration (Shapechanger)','Usually chaotic neutral','15d8+30 (97 hp)',97,'+6','30 ft. (6 squares)','17 (+2 Dex, +5 natural), touch 12, flat-footed 15','+11/+12','Slam +12 melee (1d3+1)','5 ft./5 ft.','+11','+11','+11',12,15,15,16,15,14,'Bluff +20, Climb +7, Craft (any one) +12, Diplomacy +12, Disguise +20 (+22 acting)*, Intimidate +4, Knowledge (any one) +18, Listen +12, Spot +12, Survival +8','Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative, Mobility','{"special_attacks":"—","special_qualities":"Alternate form, amorphous, resilient, scent, telepathy 100 ft., tremorsense 60 ft."}'::jsonb,'A phasm is an amorphous creature that can assume the guise of almost any other creature or object. A phasm in its natural form is about 5 feet in diameter and 2 feet high at the center. Swirls of color indicate sensory organs. In this form, a phasm slithers about like an ooze and can attack with a pseudopod. It weighs about 400 pounds.

Phasms can speak Common but prefer telepathic communication.

### Combat

When faced with potential danger, a phasm is equally likely to retreat, parley, or attack, as its fancy strikes.

If pursued or harassed, a phasm transforms into the most fearsome creature it knows and attacks. When seriously hurt, it changes to some fast or agile form and tries to escape.

**Amorphous (Ex):** A phasm in its natural form has immunity to poison, _sleep,_ paralysis, polymorph, and stunning effects. It is not subject to critical hits and, having no clear front or back, cannot be flanked.

**Resilient (Ex):** A phasm has a +4 racial bonus on Fortitude and Reflex saves (included in the statistics block).

Alternate Form (Su): A phasm can assume any form of Large size or smaller as a standard action. This ability functions as a _polymorph_ spell cast on itself (caster level 15th), except that the phasm does not regain hit points for changing form. A phasm can remain in its alternate form until it chooses to assume a new one or return to its natural form.

**Tremorsense (Ex):** A phasm can automatically sense the location of anything within 60 feet that is in contact with the ground, so long as it is touching the ground itself.

**Skills:** \*When using shapechange, a phasm gains a +10 circumstance bonus on Disguise checks.','{"full_attack":"Slam +12 melee (1d3+1)","environment":"Underground","organization":"Solitary","treasure":"Standard","advancement":"15–21 HD (Huge); 22–45 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"15d8+30 (97 hp)","hit_points":97,"base_attack_grapple":"+11/+12","attack":"Slam +12 melee (1d3+1)","full_attack":"Slam +12 melee (1d3+1)","space_reach":"5 ft./5 ft.","saves":"Fort +11, Ref +11, Will +11","abilities":{"str":"12","dex":"15","con":"15","int":"16","wis":"15","cha":"14"},"skills":"Bluff +20, Climb +7, Craft (any one) +12, Diplomacy +12, Disguise +20 (+22 acting)*, Intimidate +4, Knowledge (any one) +18, Listen +12, Spot +12, Survival +8","feats":"Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative, Mobility","special_attacks":"—","special_qualities":"Alternate form, amorphous, resilient, scent, telepathy 100 ft., tremorsense 60 ft."},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('aasimar_1st_level_warrior','Aasimar, 1st-Level Warrior','Aasimar, 1st-Level Warrior','1/2','Medium','Outsider (Native)','Usually good (any)','1d8+1 (5 hp)',5,'+4','20 ft. in scale mail (4 squares); base speed 30 ft.','16 (+4 scale mail, +2 heavy shield), touch 10, flat-footed 16','+1/+2','Longsword +2 melee (1d8+1/19–20) or light crossbow +1 ranged (1d8/19–20)','5 ft./5 ft.','+3','+0','+0',13,11,12,10,11,10,'Heal +4, Knowledge (religion) +1, Listen +3, Ride +1, Spot +3','Improved Initiative','{"special_attacks":"Daylight","special_qualities":"Darkvision 60 ft., resistance to acid 5, cold 5, and electricity 5"}'::jsonb,'Aasimars are usually tall, good-looking, and generally pleasant. Some have a minor physical trait suggesting their heritage, such as silver hair, golden eyes, or an unnaturally intense stare.

Most aasimars are decidedly good-aligned. They fight against evil causes and attempt to sway others to do the right thing. Occasionally they take on the vengeful, judgmental aspect of their celestial ancestor, but this is rare.

#### Combat

Aasimars usually like a fair, straightforward contest. Against a particularly evil foe, however, they fight with utter conviction and to the death.

**_Daylight_ (Sp):** An aasimar can use day*light* once per day as a 1<sup>st</sup>\-level caster or a caster of his class levels, whichever is higher.

**Skills:** An aasimar has a +2 racial bonus on Spot and Listen checks.

The aasimar warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

#### Aasimar as Characters

Aasimar characters possess the following racial traits.

— +2 Wisdom, +2 Charisma.

—Medium size.

—An aasimar’s base land speed is 30 feet.

—Darkvision: Aasimars can see in the dark up to 60 feet.

—Racial Skills: Aasimars have a +2 racial bonus on Spot and Listen checks.

—Racial Feats: An aasimar gains feats according to its class levels.

—Special Attacks (see above): _Daylight_.

—Special Qualities (see above): Resistance to acid 5, cold 5, and electricity 5.

—Automatic Languages: Common, Celestial. Bonus Languages: Draconic, Dwarven, Elven, Gnome, Halfling,

Sylvan.

—Favored Class: Paladin.

—Level adjustment +1.','{"full_attack":"Longsword +2 melee (1d8+1/19–20) or light crossbow +1 ranged (1d8/19–20)","environment":"Temperate plains","organization":"Solitary, pair, or team (3–4)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/+2","attack":"Longsword +2 melee (1d8+1/19–20) or light crossbow +1 ranged (1d8/19–20)","full_attack":"Longsword +2 melee (1d8+1/19–20) or light crossbow +1 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +0, Will +0","abilities":{"str":"13","dex":"11","con":"12","int":"10","wis":"11","cha":"10"},"skills":"Heal +4, Knowledge (religion) +1, Listen +3, Ride +1, Spot +3","feats":"Improved Initiative","special_attacks":"Daylight","special_qualities":"Darkvision 60 ft., resistance to acid 5, cold 5, and electricity 5"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('tiefling_1st_level_warrior','Tiefling, 1st-Level Warrior','Tiefling, 1st-Level Warrior','1/2','Medium','Outsider (Native)','Usually evil (any)','1d8+1 (5 hp)',5,'+1','30 ft. (6 squares)','15 (+1 Dex, +3 studded leather, +1 light shield), touch 11, flat-footed 14','+1/+2','Rapier +3 melee (1d6+1/18–20) or light crossbow +2 ranged (1d8/19–20)','5 ft./5 ft.','+3','+1','–1',13,13,12,12,9,6,'Bluff +4, Hide +5, Move Silently +1, Sleight of Hand +1','Weapon Focus (rapier)','{"special_attacks":"Darkness","special_qualities":"Darkvision 60 ft., resistance to cold 5, electricity 5, and fire 5"}'::jsonb,'Many tieflings are indistinguishable from humans. Others have small horns, pointed teeth, red eyes, a whiff of brimstone about them, or even cloven feet. No two tieflings are the same.

#### Combat

Tieflings are sneaky, subtle, and generally conniving. They prefer to strike from ambush and usually avoid a fair fight if they can.

**_Darkness_ (Sp):** A tiefling can use _darkness_ once per day (caster level equal to class levels).

**Skills:** A tiefling has a +2 racial bonus on Bluff and Hide checks.

The tiefling warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

#### Tieflings as Characters

Tiefling characters possess the following racial traits.

— +2 Dexterity, +2 Intelligence, –2 Charisma.

—Medium size.

—A tiefling’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Racial Skills: Tieflings have a +2 racial bonus on Bluff and Hide checks.

—Racial Feats: A tiefling gains feats according to its class levels.

—Special Attacks (see above): _Darkness_.

—Special Qualities (see above): Resistance to cold 5, electricity 5, and fire 5.

—Automatic Languages: Common, Infernal. Bonus Languages: Draconic, Dwarven, Elven, Gnome, Goblin, Halfling, Orc.

—Favored Class: Rogue.

—Level adjustment +1.','{"full_attack":"Rapier +3 melee (1d6+1/18–20) or light crossbow +2 ranged (1d8/19–20)","environment":"Temperate plains","organization":"Solitary, pair, or gang (3–4)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+1/+2","attack":"Rapier +3 melee (1d6+1/18–20) or light crossbow +2 ranged (1d8/19–20)","full_attack":"Rapier +3 melee (1d6+1/18–20) or light crossbow +2 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +1, Will –1","abilities":{"str":"13","dex":"13","con":"12","int":"12","wis":"9","cha":"6"},"skills":"Bluff +4, Hide +5, Move Silently +1, Sleight of Hand +1","feats":"Weapon Focus (rapier)","special_attacks":"Darkness","special_qualities":"Darkvision 60 ft., resistance to cold 5, electricity 5, and fire 5"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('pseudodragon','Pseudodragon','Pseudodragon','1','Tiny','Dragon','Always neutral good','2d12+2 (15 hp)',15,'+2','15 ft. (3 squares), fly 60 ft. (good)','18 (+2 size, +2 Dex, +4 natural), touch 14, flat-footed 16','+2/–8','Sting +4 melee (1d3–2 plus poison)','2-1/2 ft./0 ft. (5 ft. with tail)','+4','+5','+4',6,15,13,10,12,10,'Diplomacy +2, Hide +20*, Listen +7, Search +6, Sense Motive +7, Spot +7, Survival +1 (+3 following tracks)','Weapon Finesse','{"special_attacks":"Poison","special_qualities":"Blindsense 60 ft., darkvision 60 ft., immunity to sleep and paralysis, low-light vision, spell resistance 19, telepathy 60 ft."}'::jsonb,'A pseudodragon has a body about 1 foot long, with a 2-foot tail. It weights about 7 pounds.

A pseudodragon can communicate telepathically and can also vocalize animal noises.

### Combat

A pseudodragon can deliver a vicious bite, but its principal weapon is its sting-equipped tail.

**Poison (Ex):** Injury, Fortitude DC 14, initial damage sleep for 1 minute, secondary damage sleep for 1d3 hours. The save DC is Constitution-based and includes a +2 racial bonus.

**Blindsense (Ex):** A pseudodragon can locate creatures within 60 feet by nonvisual means (mostly hearing and scent, but also by noticing vibration and other environmental clues). Opponents the pseudodragon can’t actually see still have total concealment against the pseudodragon.

**Telepathy (Su):** Pseudodragons can communicate telepathically with creatures that speak Common or Sylvan, provided they are within 60 feet.

**Skills:** Pseudodragons have a chameleonlike ability that grants them a +4 racial bonus on Hide checks. \*In forests or overgrown areas, this bonus improves to +8.','{"full_attack":"Sting +4 melee (1d3–2 plus poison) and bite –1 melee (1)","environment":"Temperate forests","organization":"Solitary, pair, or clutch (3–5)","treasure":"None","advancement":"3–4 HD (Tiny)","level_adjustment":"+3","statblock":{"hit_dice":"2d12+2 (15 hp)","hit_points":15,"base_attack_grapple":"+2/–8","attack":"Sting +4 melee (1d3–2 plus poison)","full_attack":"Sting +4 melee (1d3–2 plus poison) and bite –1 melee (1)","space_reach":"2-1/2 ft./0 ft. (5 ft. with tail)","saves":"Fort +4, Ref +5, Will +4","abilities":{"str":"6","dex":"15","con":"13","int":"10","wis":"12","cha":"10"},"skills":"Diplomacy +2, Hide +20*, Listen +7, Search +6, Sense Motive +7, Spot +7, Survival +1 (+3 following tracks)","feats":"Weapon Finesse","special_attacks":"Poison","special_qualities":"Blindsense 60 ft., darkvision 60 ft., immunity to sleep and paralysis, low-light vision, spell resistance 19, telepathy 60 ft."},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('purple_worm','Purple Worm','Purple Worm','12','Gargantuan','Magical Beast','Always neutral','16d10+112 (200 hp)',200,'–2','20 ft. (4 squares), burrow 20 ft., swim 10 ft.','19 (–4 size, –2 Dex, +15 natural), touch 4, flat-footed 19','+16/+40','Bite +25 melee (2d8+12)','20 ft./15ft.','+17','+8','+4',35,6,25,1,8,8,'Listen +18, Swim +20','Awesome Blow, Cleave, Improved Bull Rush, Power Attack, Weapon Focus (bite), Weapon Focus (sting)','{"special_attacks":"Improved grab, swallow whole, poison","special_qualities":"Tremorsense 60 ft."}'::jsonb,'The body of a mature purple worm is 5 feet in diameter and 80 feet long, weighing about 40,000 pounds. The creature has a poisonous stinger in its tail.

### Combat

In battle, a purple worm forms into a coil 20 feet in diameter, biting and stinging anything within reach.

**Improved Grab (Ex):** To use this ability, a purple worm must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can attempt to swallow the foe the following round.

**Poison (Ex):** Injury, Fortitude DC 25, initial damage 1d6 Str, secondary damage 2d6 Str. The save DC is Constitution-based.

**Swallow Whole (Ex):** A purple worm can try to swallow a grabbed opponent of a smaller size than itself by making a successful grapple check. Once inside, the opponent takes 2d8+12 points of crushing damage plus 8 points of acid damage per round from the worm’s gizzard. A swallowed creature can cut its way out by using a light slashing or piercing weapon to deal 25 points of damage to the gizzard (AC 17). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out. A Gargantuan worm’s interior can hold 2 Large, 8 Medium, 32 Small, 128 Tiny, or 512 Diminutive or smaller opponents.

**Skills:** A purple worm has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"Bite +25 melee (2d8+12) and sting +20 melee (2d6+6 plus poison)","environment":"Underground","organization":"Solitary","treasure":"No coins, 50% goods (stone only), no items","advancement":"16–32 HD (Gargantuan); 33–48 HD (Colossal)","level_adjustment":"—","statblock":{"hit_dice":"16d10+112 (200 hp)","hit_points":200,"base_attack_grapple":"+16/+40","attack":"Bite +25 melee (2d8+12)","full_attack":"Bite +25 melee (2d8+12) and sting +20 melee (2d6+6 plus poison)","space_reach":"20 ft./15ft.","saves":"Fort +17, Ref +8, Will +4","abilities":{"str":"35","dex":"6","con":"25","int":"1","wis":"8","cha":"8"},"skills":"Listen +18, Swim +20","feats":"Awesome Blow, Cleave, Improved Bull Rush, Power Attack, Weapon Focus (bite), Weapon Focus (sting)","special_attacks":"Improved grab, swallow whole, poison","special_qualities":"Tremorsense 60 ft."},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('rakshasa','Rakshasa','Rakshasa','10','Medium','Outsider (Native)','Always lawful evil','7d8+21 (52 hp)',52,'+2','40 ft. (8 squares)','21 (+2 Dex, +9 natural), touch 12, flat-footed 19','+7/+8','Claw +8 melee (1d4+1)','5 ft./5 ft.','+8','+7','+6',12,14,16,13,13,17,'Bluff +17*, Concentration +13, Diplomacy +7, Disguise +17 (+19 acting)*, Intimidate +5, Listen +13, Move Silently +13, Perform (oratory) +13, Sense Motive +11, Spellcraft +11, Spot +11','Alertness, Combat Casting, Dodge','{"special_attacks":"Detect thoughts, spells","special_qualities":"Change shape, damage reduction 15/good and piercing, darkvision 60 ft., spell resistance 27"}'::jsonb,'A closer look at a rakshasa reveals that the palms of its hands are where the backs of the hands would be on a human.

A rakshasa is about the same height and weight as a human.

Rakshasas speak Common, Infernal, and Undercommon.

### Combat

In close combat, which a rakshasa disdains as ignoble, it employs its sharp claws and powerful bite. Whenever possible, it uses its other abilities to make such encounters unnecessary.

**Detect Thoughts (Su):** A rakshasa can continuously use detect thoughts as the spell (caster level 18th; Will DC 15 negates). It can suppress or resume this ability as a free action. The save DC is Charisma-based.

**Spells:** A rakshasa casts spells as a 7th-level sorcerer.

_Typical Sorcerer Spells Known_ (6/7/7/5; save DC 13 + spell level): 0—_detect magic, light, mage hand, message, read magic, resistance, touch of fatigue;_ 1st—_charm person, mage armor, magic missile, shield, silent image;_ 2nd—_bear’s endurance, invisibility, acid arrow;_ 3rd—_haste, suggestion._

**Change Shape (Su):** A rakshasa can assume any humanoid form, or revert to its own form, as a standard action. In humanoid form, a rakshasa loses its claw and bite attacks (although it often equips itself with weapons and armor instead). A rakshasa remains in one form until it chooses to assume a new one. A change in form cannot be dispelled, but the rakshasa reverts to its natural form when killed. A _true seeing_ spell reveals its natural form.

**Skills:** A rakshasa has a +4 racial bonus on Bluff and Disguise checks. \*When using change shape, a rakshasa gains an additional +10 circumstance bonus on Disguise checks. If reading an opponent’s mind, its circumstance bonus on Bluff and Disguise checks increases by a further +4.

### Rakshasas as Characters

Rakshasa characters possess the following racial traits.

— +2 Strength, +4 Dexterity, +6 Constitution, +2 Intelligence, +2 Wisdom, +6 Charisma.

—Medium size.

—A rakshasa’s base land speed is 40 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: A rakshasa begins with seven levels of outsider, which provide 7d8 Hit Dice, a base attack bonus of +7, and base saving throw bonuses of Fort +5, Ref +5, and Will +5.

—Racial Skills: A rakshasa’s outsider levels give it skill points equal to 10 x (8 + Int modifier). Its class skills are Bluff, Disguise, Listen, Move Silently, Perform, Sense Motive, and Spot. A rakshasa has a +4 racial bonus on Bluff and Disguise checks, and it can gain further bonuses by using change shape (+10 on Disguise checks) and detect thoughts (+4 on Bluff and Disguise checks).

—Racial Feats: A rakshasa’s outsider levels give it three feats.

— +9 natural armor bonus.

—Natural Weapons: Bite (1d6) and 2 claws (1d4).

—Detect Thoughts (Su): The save DC is 13 + the character’s Cha modifier.

—Spells: A rakshasa character casts spells as a 7th-level sorcerer. If the character takes additional levels of sorcerer, these levels stack with the rakshasa’s base spellcasting ability for spells known, spells per day, and other effects dependent on caster level. A rakshasa character likewise uses the sum of its

racial spellcasting levels and class levels to determine the abilities of its familiar.

—Special Qualities (see above): Change shape, damage reduction 15/good and piercing, spell resistance equal to 27 + class levels.

—Automatic Languages: Common, Infernal. Bonus Languages: Sylvan, Undercommon.

—Favored Class: Sorcerer.

—Level adjustment +7.','{"full_attack":"2 claws +8 melee (1d4+1) and bite +3 melee (1d6)","environment":"Warm marshes","organization":"Solitary","treasure":"Standard coins; double goods; standard items","advancement":"By character class","level_adjustment":"+7","statblock":{"hit_dice":"7d8+21 (52 hp)","hit_points":52,"base_attack_grapple":"+7/+8","attack":"Claw +8 melee (1d4+1)","full_attack":"2 claws +8 melee (1d4+1) and bite +3 melee (1d6)","space_reach":"5 ft./5 ft.","saves":"Fort +8, Ref +7, Will +6","abilities":{"str":"12","dex":"14","con":"16","int":"13","wis":"13","cha":"17"},"skills":"Bluff +17*, Concentration +13, Diplomacy +7, Disguise +17 (+19 acting)*, Intimidate +5, Listen +13, Move Silently +13, Perform (oratory) +13, Sense Motive +11, Spellcraft +11, Spot +11","feats":"Alertness, Combat Casting, Dodge","special_attacks":"Detect thoughts, spells","special_qualities":"Change shape, damage reduction 15/good and piercing, darkvision 60 ft., spell resistance 27"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('rast','Rast','Rast','5','Medium','Outsider (Extraplanar, Fire)','Usually neutral','4d8+7 (25 hp)',25,'+5','5 ft. (1 square), fly 60 ft. (good)','15 (+1 Dex, +4 natural), touch 11, flat-footed 14','+4/+6','Claw +6 melee (1d4+2) or bite +6 melee (1d8+3)','5 ft./5 ft.','+5','+5','+5',14,12,13,3,13,12,'Hide +8, Listen +8, Move Silently +8, Spot +8','Improved Initiative, Toughness','{"special_attacks":"Paralyzing gaze, improved grab, blood drain","special_qualities":"Darkvision 60 ft., flight, immunity to fire, vulnerability to cold"}'::jsonb,'A rast has anywhere from ten to fifteen claws, though it can only use four at once.

A rast has a body about the size of a large dog’s, with a head almost as large as the body. It weighs about 200 pounds.

### Combat

Rasts paralyze as many of their foes as possible, then attack any that are still moving. A rast can claw or bite, but cannot do both during the same round.

**Paralyzing Gaze (Su):** Paralysis for 1d6 rounds, 30 feet, Fortitude DC 13 negates. The save DC is Charisma-based.

**Improved Grab (Ex):** To use this ability, a rast must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Blood Drain (Ex):** A rast drains blood from a grabbed opponent, dealing 1 point of Constitution damage each round it maintains the hold.

**Flight (Su):** A rast can cease or resume flight as a free action. A rast that loses this ability falls and can perform only a single action (either a move action or an attack action) each round.','{"full_attack":"4 claws +6 melee (1d4+2) or bite +6 melee (1d8+3)","environment":"Elemental Plane of Fire","organization":"Solitary, pair, or cluster (3–6)","treasure":"None","advancement":"5–6 HD (Medium); 7–12 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"4d8+7 (25 hp)","hit_points":25,"base_attack_grapple":"+4/+6","attack":"Claw +6 melee (1d4+2) or bite +6 melee (1d8+3)","full_attack":"4 claws +6 melee (1d4+2) or bite +6 melee (1d8+3)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +5, Will +5","abilities":{"str":"14","dex":"12","con":"13","int":"3","wis":"13","cha":"12"},"skills":"Hide +8, Listen +8, Move Silently +8, Spot +8","feats":"Improved Initiative, Toughness","special_attacks":"Paralyzing gaze, improved grab, blood drain","special_qualities":"Darkvision 60 ft., flight, immunity to fire, vulnerability to cold"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('ravid','Ravid','Ravid','5','Medium','Outsider (Extraplanar)','Always neutral','3d8+3 (16 hp)',16,'+4','20 ft. (4 squares), fly 60 ft. (perfect)','25 (+15 natural), touch 10, flat-footed 25','+3/+4','Tail slap +4 melee (1d6+1 plus positive energy) or tail touch +4 melee touch (positive energy)','5 ft./5 ft.','+4','+3','+4',13,10,13,7,12,14,'Escape Artist +6, Hide +6, Listen +7, Move Silently +6, Spot +7, Survival +7, Use Rope +0 (+2 with bindings)','Improved Initiative, Multiattack','{"special_attacks":"Positive energy lash, animate objects","special_qualities":"Darkvision 60 ft., flight, immunity to fire"}'::jsonb,'Ravids are creatures from the Positive Energy Plane. These bizarre entities imbue creatures with energy by their touch and animate lifeless objects around them. Ravids that make their way to the Material Plane wander about aimlessly, followed by the objects to which they have given life.

A ravid is about 7 feet long and weighs about 75 pounds.

### Combat

Ravids fight only in self-defense. A ravid itself is not very powerful but is always accompanied by at least one animated object that defends it.

**Positive Energy Lash (Su):** A ravid can make a touch attack or hit with a claw or tail slap attack to infuse a target with positive energy. The energy produces an unpleasant tingle in living creatures, and against undead foes (even incorporeal ones) it deals 2d10 points of damage.

Animate Objects (Su): Once per round, a random object within 20 feet of a ravid animates as though by the spell _animate objects_ (caster level 20th). These objects defend the ravid to the best of their ability, but the ravid isn’t intelligent enough to employ elaborate tactics with them.

**Flight (Su):** A ravid can cease or resume flight as a free action. A rast that loses this ability falls and can perform only a single action (either a move action or an attack action) each round.

**Feats:** A ravid has the Multiattack feat even through it does not have the requisite three natural weapons.','{"full_attack":"Tail slap +4 melee (1d6+1 plus positive energy) and claw +2 melee (1d4 plus positive energy); or tail touch +4 melee touch (positive energy) and claw touch +2 melee touch (positive energy)","environment":"Positive Energy Plane","organization":"Solitary (1 plus at least 1 animated object)","treasure":"None","advancement":"4 HD (Medium); 5–9 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"3d8+3 (16 hp)","hit_points":16,"base_attack_grapple":"+3/+4","attack":"Tail slap +4 melee (1d6+1 plus positive energy) or tail touch +4 melee touch (positive energy)","full_attack":"Tail slap +4 melee (1d6+1 plus positive energy) and claw +2 melee (1d4 plus positive energy); or tail touch +4 melee touch (positive energy) and claw touch +2 melee touch (positive energy)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +3, Will +4","abilities":{"str":"13","dex":"10","con":"13","int":"7","wis":"12","cha":"14"},"skills":"Escape Artist +6, Hide +6, Listen +7, Move Silently +6, Spot +7, Survival +7, Use Rope +0 (+2 with bindings)","feats":"Improved Initiative, Multiattack","special_attacks":"Positive energy lash, animate objects","special_qualities":"Darkvision 60 ft., flight, immunity to fire"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('remorhaz','Remorhaz','Remorhaz','7','Huge','Magical Beast','Usually neutral','7d10+35 (73 hp)',73,'+1','30 ft. (6 squares), burrow 20 ft.','20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19','+7/+23','Bite +13 melee (2d8+12)','15 ft./10 ft.','+10','+6','+3',26,13,21,5,12,10,'Listen +8, Spot +8','Awesome Blow, Improved Bull Rush, Power Attack','{"special_attacks":"Improved grab, swallow whole","special_qualities":"Darkvision 60 ft., heat, low-light vision, tremorsense 60 ft."}'::jsonb,'A remorhaz is whitish-blue in color but pulses with a reddish glow from the heat its body produces. The creature is a little more than 20 feet long, with a body about 5 feet wide. It weighs about 10,000 pounds.

Remorhazes cannot speak.

### Combat

Remorhazes hide under the snow and ice until they hear movement above them, then attack from below and surprise prey.

**Improved Grab (Ex):** To use this ability, a remorhaz must hit an opponent least one size category smaller than itself with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can attempt to swallow the opponent the following round.

**Swallow Whole (Ex):** When a remorhaz begins its turn with a grappled opponent in its mouth, it can swallow that opponent with a successful grapple check. Once inside, the opponent takes 2d8+12 points of bludgeoning damage plus 8d6 points of fire damage per round from the remorhaz’s gizzard. A swallowed creature can cut its way out by using a light slashing or piercing weapon to deal 25 points of damage to the gizzard (AC 15). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out. A Huge remorhaz’s interior can hold 2 Large, 4 Medium, 8 Small, 32 Tiny, 128 Diminutive, or 512 Fine or smaller opponents.

**Heat (Ex):** An enraged remorhaz generates heat so intense that anything touching its body takes 8d6 points of fire damage. Creatures striking a remorhaz with natural attacks or unarmed attacks are subject to this damage, but creatures striking with melee weapons do not take damage from the remorhaz’s heat. This heat can melt or char weapons; any weapon that strikes a remorhaz is allowed a DC 18 Fortitude save to avoid destruction. The save DC is Constitution-based. Skills: Remorhazes have a +4 racial bonus on Listen checks.','{"full_attack":"Bite +13 melee (2d8+12)","environment":"Cold desert","organization":"Solitary","treasure":"None","advancement":"8–14 HD (Huge); 15–21 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"7d10+35 (73 hp)","hit_points":73,"base_attack_grapple":"+7/+23","attack":"Bite +13 melee (2d8+12)","full_attack":"Bite +13 melee (2d8+12)","space_reach":"15 ft./10 ft.","saves":"Fort +10, Ref +6, Will +3","abilities":{"str":"26","dex":"13","con":"21","int":"5","wis":"12","cha":"10"},"skills":"Listen +8, Spot +8","feats":"Awesome Blow, Improved Bull Rush, Power Attack","special_attacks":"Improved grab, swallow whole","special_qualities":"Darkvision 60 ft., heat, low-light vision, tremorsense 60 ft."},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('roc','Roc','Roc','9','Gargantuan','Animal','Always neutral','18d8+126 (207 hp)',207,'+2','20 ft. (4 squares), fly 80 ft. (average)','17 (–4 size, +2 Dex, +9 natural), touch 8, flatfooted 15','+13/+37','Talon +21 melee (2d6+12)','20 ft./15 ft.','+18','+13','+9',34,15,24,2,13,11,'Hide –3, Listen +10, Spot +14','Alertness, Flyby Attack, Iron Will, Multiattack, Power Attack, Snatch, Wingover','{"special_attacks":"—","special_qualities":"Low-light vision"}'::jsonb,'A roc’s plumage is either dark brown or golden from head to tail. These enormous creatures are 30 feet long from the beak to the base of the tail, with wingspans as wide as 80 feet. A roc weighs about 8,000 pounds.

### Combat

A roc attacks from the air, swooping earthward to snatch prey in its powerful talons and carry it off for itself and its young to devour. A solitary roc is typically hunting and will attack any Medium or larger creature that appears edible. A mated pair of rocs attack in concert, fighting to the death to defend their nests or hatchlings.

**Skills:** Rocs have a +4 racial bonus on Spot checks.','{"full_attack":"2 talons +21 melee (2d6+12) and bite +19 melee (2d8+6)","environment":"Warm mountains","organization":"Solitary or pair","treasure":"None","advancement":"19–32 HD (Gargantuan); 33–54 (Colossal)","level_adjustment":"—","statblock":{"hit_dice":"18d8+126 (207 hp)","hit_points":207,"base_attack_grapple":"+13/+37","attack":"Talon +21 melee (2d6+12)","full_attack":"2 talons +21 melee (2d6+12) and bite +19 melee (2d8+6)","space_reach":"20 ft./15 ft.","saves":"Fort +18, Ref +13, Will +9","abilities":{"str":"34","dex":"15","con":"24","int":"2","wis":"13","cha":"11"},"skills":"Hide –3, Listen +10, Spot +14","feats":"Alertness, Flyby Attack, Iron Will, Multiattack, Power Attack, Snatch, Wingover","special_attacks":"—","special_qualities":"Low-light vision"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('roper','Roper','Roper','12','Large','Magical Beast','Usually chaotic evil','10d10+30 (85 hp)',85,'+5','10 ft. (2 squares)','24 (–1 size, +1 Dex, +14 natural), touch 10, flat-footed 23','+10/+18','Strand +11 ranged touch (drag) or bite +13 melee (2d6+6)','10 ft./10 ft. (50 ft. with strand)','+10','+8','+8',19,13,17,12,16,12,'Climb +12, Hide +10*, Listen +13, Spot +13','Alertness, Improved Initiative, Iron Will, Weapon Focus (strand)','{"special_attacks":"Drag, strands, weakness","special_qualities":"Darkvision 60 ft., immunity to electricity, low-light vision, resistance to cold 10, spell resistance 30, vulnerability to fire"}'::jsonb,'A roper stands some 9 feet tall and tapers from 3 or 4 feet in diameter at the base to 1 foot across at the top. It weighs 2,200 pounds. A roper’s coloration and temperature change to match the features of the surrounding cave.

Ropers speak Terran and Undercommon.

### Combat

A roper hunts by standing very still and imitating a bit of rock. This tactic often allows it to attack with surprise. When prey comes within reach, it lashes out with its strands. In melee, it bites adjacent opponents with its powerful maw.

**Drag (Ex):** If a roper hits with a strand attack, the strand latches onto the opponent’s body. This deals no damage but drags the stuck opponent 10 feet closer each subsequent round (provoking no attack of opportunity) unless that creature breaks free, which requires a DC 23 Escape Artist check or a DC 19 Strength check. The check DCs are Strength-based, and the Escape Artist DC includes a +4 racial bonus. A roper can draw in a creature within 10 feet of itself and bite with a +4 attack bonus in the same round. A strand has 10 hit points and can be attacked by making a successful sunder attempt. However, attacking a roper’s strand does not provoke an attack of opportunity. If the strand is currently attached to a target, the roper takes a –4 penalty on its opposed attack roll to resist the sunder attempt. Severing a strand deals no damage to a roper.

**Strands (Ex):** Most encounters with a roper begin when it fires strong, sticky strands. The creature can have up to six strands at once, and they can strike up to 50 feet away (no range increment). If a strand is severed, the roper can extrude a new one on its next turn as a free action.

**Weakness (Ex):** A roper’s strands can sap an opponent’s strength. Anyone grabbed by a strand must succeed on a DC 18 Fortitude save or take 2d8 points of Strength damage. The save DC is Constitution-based.

**Skills:** \*Ropers have a +8 racial bonus on Hide checks in stony or icy areas.','{"full_attack":"6 strands +11 ranged touch (drag) and bite +13 melee (2d6+6)","environment":"Underground","organization":"Solitary, pair, or cluster (3–6)","treasure":"No coins; 50% goods (stone only); no items","advancement":"11–15 HD (Large); 16–30 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"10d10+30 (85 hp)","hit_points":85,"base_attack_grapple":"+10/+18","attack":"Strand +11 ranged touch (drag) or bite +13 melee (2d6+6)","full_attack":"6 strands +11 ranged touch (drag) and bite +13 melee (2d6+6)","space_reach":"10 ft./10 ft. (50 ft. with strand)","saves":"Fort +10, Ref +8, Will +8","abilities":{"str":"19","dex":"13","con":"17","int":"12","wis":"16","cha":"12"},"skills":"Climb +12, Hide +10*, Listen +13, Spot +13","feats":"Alertness, Improved Initiative, Iron Will, Weapon Focus (strand)","special_attacks":"Drag, strands, weakness","special_qualities":"Darkvision 60 ft., immunity to electricity, low-light vision, resistance to cold 10, spell resistance 30, vulnerability to fire"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('rust_monster','Rust Monster','Rust Monster','3','Medium','Aberration','Always neutral','5d8+5 (27 hp)',27,'+3','40 ft. (8 squares)','18 (+3 Dex, +5 natural), touch 13, flat-footed 15','+3/+3','Antennae touch +3 melee (rust)','5 ft./5 ft.','+2','+4','+5',10,17,13,2,13,8,'Listen +7, Spot +7','Alertness, Track','{"special_attacks":"Rust","special_qualities":"Darkvision, scent"}'::jsonb,'The hide of these creatures varies in color from a yellowish tan underside to a rust-red upper back. A rust monster’s prehensile antennae can rust metals on contact.

The typical rust monster measures 5 feet long and 3 feet high, weighing 200 pounds.

### Combat

A rust monster can scent a metal object from up to 90 feet away. When it detects one, it dashes toward the source and attempts to strike it with its antennae. The creature is relentless, chasing characters over long distances if they still possess intact metal objects but usually ceasing its attacks to devour a freshly rusted meal.

The creature targets the largest metal object available, striking first at armor, then at shields and smaller items. It prefers ferrous metals (steel or iron) over precious metals (such as gold or silver) but will devour the latter if given the opportunity.

**Rust (Ex):** A rust monster that makes a successful touch attack with its antennae causes the target metal to corrode, falling to pieces and becoming useless immediately. The touch can destroy up to a 10-foot cube of metal instantly. Magic armor and weapons, and other magic items made of metal, must succeed on a DC 17 Reflex save or be dissolved. The save DC is Constitution-based and includes a +4 racial bonus.

A metal weapon that deals damage to a rust monster corrodes immediately. Wooden, stone, and other nonmetallic weapons are unaffected.','{"full_attack":"Antennae touch +3 melee (rust) and bite –2 melee (1d3)","environment":"Underground","organization":"Solitary or pair","treasure":"None","advancement":"6–8 HD (Medium); 9–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"5d8+5 (27 hp)","hit_points":27,"base_attack_grapple":"+3/+3","attack":"Antennae touch +3 melee (rust)","full_attack":"Antennae touch +3 melee (rust) and bite –2 melee (1d3)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +4, Will +5","abilities":{"str":"10","dex":"17","con":"13","int":"2","wis":"13","cha":"8"},"skills":"Listen +7, Spot +7","feats":"Alertness, Track","special_attacks":"Rust","special_qualities":"Darkvision, scent"},"source_file":"monsters-o-r.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-o-r.html',true),
('sahuagin','Sahuagin','Sahuagin','2','Medium','Monstrous Humanoid (Aquatic)','Usually lawful evil','2d8+2 (11 hp)',11,'+1','30 ft. (6 squares), swim 60 ft.','16 (+1 Dex, +5 natural), touch 11, flat-footed 15','+2/+4','Talon +4 melee (1d4+2) or trident +4 melee (1d8+3) or heavy crossbow +3 ranged (1d10/19–20)','5 ft./5 ft.','+3','+4','+4',14,13,12,14,13,9,'Handle Animal +4*, Hide +6*, Listen +6*, Profession (hunter) +1*, Ride +3, Spot +6*, Survival +1*','Great Fortitude, MultiattackB','{"special_attacks":"Blood frenzy, rake 1d4+1","special_qualities":"Blindsense 30 ft., darkvision 60 ft., freshwater sensitivity, light blindness, speak with sharks, water dependent"}'::jsonb,'Most sahuagin feature green coloration, darker along the back and lighter on the belly. Many have dark stripes, bands, or spots, but these tend to fade with age. An adult male sahuagin stands roughly 6 feet tall and weighs about 200 pounds.

Sahuagin are the natural enemy of aquatic elves. The two cannot coexist peacefully: Wars between them are prolonged, bloody affairs that sometimes interfere with shipping and maritime trade. Sahuagin have an only slightly less vehement hatred for tritons.

Sahuagin speak their own language, Sahuagin. Thanks to their high Intelligence scores, most sahuagin also speak two bonus languages, usually Common and Aquan.

### Combat

Sahuagin are savage fighters, asking for and giving no quarter. When swimming, a sahuagin tears with its feet as it strikes with its talons or a weapon. About half of any group of sahuagin are also armed with nets.

**Blindsense (Ex):** A sahuagin can locate creatures underwater within a 30-foot radius. This ability works only when the sahuagin is underwater.

**Blood Frenzy:** Once per day a sahuagin that takes damage in combat can fly into a frenzy in the following round, clawing and biting madly until either it or its opponent is dead. It gains +2 Constitution and +2 Strength, and takes a –2 penalty to Armor Class. A sahuagin cannot end its frenzy voluntarily.

**Rake (Ex):** Attack bonus +2 melee, damage 1d4+1. A sahuagin also gains two rake attacks when it attacks while swimming.

**Freshwater Sensitivity (Ex):** A sahuagin fully immersed in fresh water must succeed on a DC 15 Fortitude save or become fatigued. Even on a success, it must repeat the save attempt every 10 minutes it remains immersed.

**Light Blindness (Ex):** Abrupt exposure to bright light (such as sunlight or a _daylight_ spell) blinds sahuagin for round. On subsequent rounds, they are dazzled while operating in bright light.

**Speak with Sharks (Ex):** Sahuagin can communicate telepathically with sharks up to 150 feet away. The communication is limited to fairly simple concepts such as “food,” “danger,” and “enemy.” Sahuagin can use the Handle Animal skill to befriend and train sharks.

**Water Dependent (Ex):** Sahuagin can survive out of the water for 1 hour per 2 points of Constitution (after that, refer to the drowning rules on page 304 of the _Dungeon Master ’s Guide_).

**Skills:** A sahuagin has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.

\*Underwater, a sahuagin has a +4 racial bonus on Hide, Listen, and Spot checks.

\*A sahuagin has a +4 racial bonus on Survival and Profession (hunter) checks within 50 miles of its home.

\*A sahuagin has a +4 racial bonus on Handle Animal checks when working with sharks.

### Sahuagin Mutants

About one in two hundred sahuagin has four arms. Such creatures can make four claw attacks or use extra weapons, in addition to the claw and bite attacks.

If a community of aquatic elves is located within 100 miles of a sahuagin community, about one in one hundred sahuagin looks just like an aquatic elf. These creatures, called malenti, have a swim speed of 40 feet, can remain out of water for 1 hour per point of Constitution, and have freshwater sensitivity and light sensitivity (dazzled in bright light). Malenti have no natural attacks. They are otherwise identical with sahuagin.','{"full_attack":"Trident +4 melee (1d8+3) and bite +2 melee (1d4+1); or 2 talons +4 melee (1d4+2) and bite +2 melee (1d4+1); or heavy crossbow +3 ranged (1d10/19–20)","environment":"Warm aquatic","organization":"Solitary, pair, team (5–8), patrol (11–20 plus 1 3rd-level lieutenant and 1–2 sharks), band (20–80 plus 100% noncombatants plus 1 3rd-level lieutenant and 1 4th-level chieftain per 20 adults plus 1–2 sharks), or tribe (70–160 plus 100% noncombatants plus 1 3rd-level lieutenant per 20 adults, 1 4th-level chieftain per 40 adults, 9 4th-level guards, 1–4 underpriestesses of 3rd–6th level, 1 7th-level priestess, and 1 baron of 6th–8th level plus 5–8 sharks)","treasure":"Standard","advancement":"3–5 HD (Medium), 6–10 HD (Large), or by character class","level_adjustment":"+2 (+3 if four-armed)","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+2/+4","attack":"Talon +4 melee (1d4+2) or trident +4 melee (1d8+3) or heavy crossbow +3 ranged (1d10/19–20)","full_attack":"Trident +4 melee (1d8+3) and bite +2 melee (1d4+1); or 2 talons +4 melee (1d4+2) and bite +2 melee (1d4+1); or heavy crossbow +3 ranged (1d10/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +4, Will +4","abilities":{"str":"14","dex":"13","con":"12","int":"14","wis":"13","cha":"9"},"skills":"Handle Animal +4*, Hide +6*, Listen +6*, Profession (hunter) +1*, Ride +3, Spot +6*, Survival +1*","feats":"Great Fortitude, MultiattackB","special_attacks":"Blood frenzy, rake 1d4+1","special_qualities":"Blindsense 30 ft., darkvision 60 ft., freshwater sensitivity, light blindness, speak with sharks, water dependent"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('flamebrother_salamander','Flamebrother Salamander','Flamebrother Salamander','3','Small','Outsider (Extraplanar, Fire)','Usually evil (any)','4d8+8 (26 hp)',26,'+1','20 ft. (4 squares)','19 (+1 size, +1 Dex, +7 natural), touch 12, flat-footed 18','+4/+1','Spear +6 melee (1d6+1/x3 plus 1d6 fire)','5 ft./5 ft.','+6','+5','+6',12,13,14,14,15,13,'Craft (blacksmithing) +8, Hide +12, Listen +11, Move Silently +6, Spot +11','Alertness, Multiattack','{"special_attacks":"Constrict 1d4 plus 1d6 fire, heat, improved grab","special_qualities":"Darkvision 60 ft., immunity to fire, vulnerability to cold"}'::jsonb,'Salamanders speak Ignan. Some average salamanders and all nobles also speak Common.

### Combat

If a salamander has damage reduction, its natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Constrict (Ex):** A salamander deals automatic tail slap damage (including fire damage) with a successful grapple check. A noble salamander can constrict multiple creatures simultaneously, provided they are all at least two sizes smaller than it.

**Heat (Ex):** A salamander generates so much heat that its mere touch deals additional fire damage. Salamanders’ metallic weapons also conduct this heat.

**Improved Grab (Ex):** To use this ability, a salamander must hit a creature of up to one size larger than itself with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Spell-Like Abilities:** (Noble salamanders only) 3/day—_burning hands_ (DC 13), _fireball_ (DC 15), _flaming sphere_ (DC 14), _wall of fire_ (DC 16); 1/day—_dispel magic, summon monster VII_ (Huge fire elemental). Caster level 15th. The save DCs are Charisma-based.

**Skills:** Salamanders have a +4 racial bonus on Craft (blacksmithing) checks.

**Feats:** Salamanders have the Multiattack feat even though they do not have the requisite three natural weapons.','{"full_attack":"Spear +6 melee (1d6+1/x3 plus 1d6 fire) and tail slap +4 melee (1d4 plus 1d6 fire)","environment":"Elemental Plane of Fire","organization":"Solitary, pair, or cluster (3–5)","treasure":"Standard (nonflammables only)","advancement":"4–6 HD (Small)","level_adjustment":"+4","statblock":{"hit_dice":"4d8+8 (26 hp)","hit_points":26,"base_attack_grapple":"+4/+1","attack":"Spear +6 melee (1d6+1/x3 plus 1d6 fire)","full_attack":"Spear +6 melee (1d6+1/x3 plus 1d6 fire) and tail slap +4 melee (1d4 plus 1d6 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +5, Will +6","abilities":{"str":"12","dex":"13","con":"14","int":"14","wis":"15","cha":"13"},"skills":"Craft (blacksmithing) +8, Hide +12, Listen +11, Move Silently +6, Spot +11","feats":"Alertness, Multiattack","special_attacks":"Constrict 1d4 plus 1d6 fire, heat, improved grab","special_qualities":"Darkvision 60 ft., immunity to fire, vulnerability to cold"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('average_salamander','Average Salamander','Average Salamander','6','Medium','Outsider (Extraplanar, Fire)','Usually evil (any)','9d8+18 (58 hp)',58,'+1','20 ft. (4 squares)','18 (+1 Dex, +7 natural), touch 11, flat-footed 17','+9/+11','Spear +11 melee (1d8+3/x3 plus 1d6 fire)','5 ft./5 ft. (10 ft. with tail)','+8','+7','+8',14,13,14,14,15,13,'Bluff +11, Craft (blacksmithing) +19, Diplomacy +3, Disguise +1 (+3 acting), Hide +11, Intimidate +3, Listen +8, Move Silently +11,Search +12, Spot +8','Alertness, Multiattack, Power Attack','{"special_attacks":"Constrict 2d6+1 plus 1d6 fire, heat, improved grab","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., immunity to fire, vulnerability to cold"}'::jsonb,'Salamanders speak Ignan. Some average salamanders and all nobles also speak Common.

### Combat

If a salamander has damage reduction, its natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Constrict (Ex):** A salamander deals automatic tail slap damage (including fire damage) with a successful grapple check. A noble salamander can constrict multiple creatures simultaneously, provided they are all at least two sizes smaller than it.

**Heat (Ex):** A salamander generates so much heat that its mere touch deals additional fire damage. Salamanders’ metallic weapons also conduct this heat.

**Improved Grab (Ex):** To use this ability, a salamander must hit a creature of up to one size larger than itself with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Spell-Like Abilities:** (Noble salamanders only) 3/day—_burning hands_ (DC 13), _fireball_ (DC 15), _flaming sphere_ (DC 14), _wall of fire_ (DC 16); 1/day—_dispel magic, summon monster VII_ (Huge fire elemental). Caster level 15th. The save DCs are Charisma-based.

**Skills:** Salamanders have a +4 racial bonus on Craft (blacksmithing) checks.

**Feats:** Salamanders have the Multiattack feat even though they do not have the requisite three natural weapons.','{"full_attack":"Spear +11/+6 melee (1d8+3/x3 plus 1d6 fire) and tail slap +9 melee (2d6+1 plus 1d6 fire)","environment":"Elemental Plane of Fire","organization":"Solitary, pair, or cluster (3–5)","treasure":"Standard (nonflammables only)","advancement":"8–14 HD (Medium)","level_adjustment":"+5","statblock":{"hit_dice":"9d8+18 (58 hp)","hit_points":58,"base_attack_grapple":"+9/+11","attack":"Spear +11 melee (1d8+3/x3 plus 1d6 fire)","full_attack":"Spear +11/+6 melee (1d8+3/x3 plus 1d6 fire) and tail slap +9 melee (2d6+1 plus 1d6 fire)","space_reach":"5 ft./5 ft. (10 ft. with tail)","saves":"Fort +8, Ref +7, Will +8","abilities":{"str":"14","dex":"13","con":"14","int":"14","wis":"15","cha":"13"},"skills":"Bluff +11, Craft (blacksmithing) +19, Diplomacy +3, Disguise +1 (+3 acting), Hide +11, Intimidate +3, Listen +8, Move Silently +11,Search +12, Spot +8","feats":"Alertness, Multiattack, Power Attack","special_attacks":"Constrict 2d6+1 plus 1d6 fire, heat, improved grab","special_qualities":"Damage reduction 10/magic, darkvision 60 ft., immunity to fire, vulnerability to cold"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('noble_salamander','Noble Salamander','Noble Salamander','10','Large','Outsider (Extraplanar, Fire)','Usually evil (any)','15d8+45 (112 hp)',112,'+1','20 ft. (4 squares)','18 (–1 size, +1 Dex, +8 natural), touch 10, flat-footed 17','+15/+25','+3 longspear +23 melee (1d8+9/x3 plus 1d8 fire)','10 ft./10 ft. (20 ft. with tail or longspear)','+12','+10','+11',22,13,16,16,15,15,'Bluff +19, Craft (blacksmithing) +25, Diplomacy +4, Hide +15, Intimidate +4, Listen +13, Move Silently +17, Spot +13','Alertness, Cleave, Great Cleave, Multiattack, Power Attack, Skill Focus (Craft [blacksmithing])','{"special_attacks":"Constrict 2d8+3 plus 1d8 fire, heat, improved grab, spell-like abilities","special_qualities":"Damage reduction 15/magic, darkvision 60 ft., immunity to fire, vulnerability to cold"}'::jsonb,'Salamanders speak Ignan. Some average salamanders and all nobles also speak Common.

### Combat

If a salamander has damage reduction, its natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Constrict (Ex):** A salamander deals automatic tail slap damage (including fire damage) with a successful grapple check. A noble salamander can constrict multiple creatures simultaneously, provided they are all at least two sizes smaller than it.

**Heat (Ex):** A salamander generates so much heat that its mere touch deals additional fire damage. Salamanders’ metallic weapons also conduct this heat.

**Improved Grab (Ex):** To use this ability, a salamander must hit a creature of up to one size larger than itself with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Spell-Like Abilities:** (Noble salamanders only) 3/day—_burning hands_ (DC 13), _fireball_ (DC 15), _flaming sphere_ (DC 14), _wall of fire_ (DC 16); 1/day—_dispel magic, summon monster VII_ (Huge fire elemental). Caster level 15th. The save DCs are Charisma-based.

**Skills:** Salamanders have a +4 racial bonus on Craft (blacksmithing) checks.

**Feats:** Salamanders have the Multiattack feat even though they do not have the requisite three natural weapons.','{"full_attack":"+3 longspear +23/+18/+13 melee (1d8+9/x3 plus 1d8 fire) and tail slap +18 melee (2d8+3 plus 1d8 fire)","environment":"Elemental Plane of Fire","organization":"Solitary, pair, or noble party (9–14)","treasure":"Double standard (nonflammables only) and +3 longspear","advancement":"16–21 HD (Large); 22–45 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"15d8+45 (112 hp)","hit_points":112,"base_attack_grapple":"+15/+25","attack":"+3 longspear +23 melee (1d8+9/x3 plus 1d8 fire)","full_attack":"+3 longspear +23/+18/+13 melee (1d8+9/x3 plus 1d8 fire) and tail slap +18 melee (2d8+3 plus 1d8 fire)","space_reach":"10 ft./10 ft. (20 ft. with tail or longspear)","saves":"Fort +12, Ref +10, Will +11","abilities":{"str":"22","dex":"13","con":"16","int":"16","wis":"15","cha":"15"},"skills":"Bluff +19, Craft (blacksmithing) +25, Diplomacy +4, Hide +15, Intimidate +4, Listen +13, Move Silently +17, Spot +13","feats":"Alertness, Cleave, Great Cleave, Multiattack, Power Attack, Skill Focus (Craft [blacksmithing])","special_attacks":"Constrict 2d8+3 plus 1d8 fire, heat, improved grab, spell-like abilities","special_qualities":"Damage reduction 15/magic, darkvision 60 ft., immunity to fire, vulnerability to cold"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('satyr','Satyr','Satyr','2 (without pipes) or 4 (with pipes)','Medium','Fey','Usually chaotic neutral','5d6+5 (22 hp)',22,'+1','40 ft. (8 squares)','15 (+1 Dex, +4 natural), touch 11, flat-footed 14','+2/+2','Head butt +2 melee (1d6) or shortbow +3 ranged (1d6/x3)','5 ft./5 ft.','+2','+5','+5',10,13,12,12,13,13,'Bluff +9, Diplomacy +3, Disguise +1 (+3 acting), Hide +13, Intimidate +3, Knowledge (nature) +9, Listen +15, Move Silently +13, Perform (wind instruments) +9, Spot +15, Survival +1 (+3 aboveground)','AlertnessB, Dodge, Mobility','{"special_attacks":"Pipes","special_qualities":"Damage reduction 5/cold iron, low-light vision"}'::jsonb,'A satyr’s hair is red or chestnut brown, while its hooves and horns are jet black. A satyr is about as tall and heavy as a half-elf.

Satyrs speak Sylvan, and most also speak Common.

### Combat

The keen senses of a satyr make it almost impossible to surprise one in the wild. Conversely, with their own natural grace and agility, satyrs can sneak up on travelers who are not carefully watching the surrounding wilderness. Once engaged in battle, an unarmed satyr attacks with a powerful head butt. A satyr expecting trouble is likely to be armed with a bow and a dagger and typically looses arrows from hiding, weakening an enemy before closing.

**Pipes (Su):** Satyrs can play a variety of magical tunes on their pan pipes. Usually, only one satyr in a group carries pipes. When it plays, all creatures within a 60-foot spread (except satyrs) must succeed on a DC 13 Will save or be affected by _charm person, sleep,_ or _fear_ (caster level 10th; the satyr chooses the tune and its effect).

In the hands of other beings, these pipes have no special powers. A creature that successfully saves against any of the pipe’s effects cannot be affected by the same set of pipes for 24 hours. The save DC is Charisma-based.

**Skills:** Satyrs have a +4 racial bonus on Hide, Listen, Move Silently, Perform, and Spot checks.

### Satyrs as Characters

Satyr characters possess the following racial traits.

— +2 Dexterity, +2 Constitution, +2 Intelligence, +2 Wisdom, +2 Charisma.

—Medium size.

—A satyr’s base land speed is 40 feet.

—Low-light vision.

—Racial Hit Dice: A satyr begins with five levels of fey, which provide 5d8 Hit Dice, a base attack bonus of +2, and base saving throw bonuses of Fort +1, Ref +4, and Will +4.

—Racial Skills: A satyr’s fey levels give it skill points equal to 8 x (6 + Int modifier). Its class skills are Bluff, Hide, Knowledge (nature), Listen, Move Silently, Perform, and Spot. Satyrs have a +4 racial bonus on Hide, Listen, Move Silently, Perform, and Spot checks.

—Racial Feats: A satyr’s fey levels give it two feats. A satyr receives Alertness as a bonus feat.

— +4 natural armor bonus.

—Natural Weapons: Head butt (1d6).

—Special Attacks (see above): Pipes.

—Special Qualities (see above): Damage reduction 5/cold iron.

—Automatic Languages: Sylvan. Bonus Languages: Common, Elven, Gnome.

—Favored Class: Bard.

—Level adjustment +2.','{"full_attack":"Head butt +2 melee (1d6) and dagger –3 melee (1d4/19–20); or shortbow +3 ranged (1d6/x3)","environment":"Temperate forests","organization":"Solitary, pair, band (3–5), or troop (6–11)","treasure":"Standard","advancement":"6–10 HD (Medium)","level_adjustment":"+2","statblock":{"hit_dice":"5d6+5 (22 hp)","hit_points":22,"base_attack_grapple":"+2/+2","attack":"Head butt +2 melee (1d6) or shortbow +3 ranged (1d6/x3)","full_attack":"Head butt +2 melee (1d6) and dagger –3 melee (1d4/19–20); or shortbow +3 ranged (1d6/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +5, Will +5","abilities":{"str":"10","dex":"13","con":"12","int":"12","wis":"13","cha":"13"},"skills":"Bluff +9, Diplomacy +3, Disguise +1 (+3 acting), Hide +13, Intimidate +3, Knowledge (nature) +9, Listen +15, Move Silently +13, Perform (wind instruments) +9, Spot +15, Survival +1 (+3 aboveground)","feats":"AlertnessB, Dodge, Mobility","special_attacks":"Pipes","special_qualities":"Damage reduction 5/cold iron, low-light vision"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('sea_cat','Sea Cat','Sea Cat','4','Large','Magical Beast','Always neutral','6d10+18 (51 hp)',51,'+1','10 ft. (2 squares), swim 40 ft.','18 (–1 size, +1 Dex, +8 natural), touch 10, flat-footed 17','+6/+14','Claw +9 melee (1d6+4)','10 ft./5 ft.','+8','+6','+5',19,12,17,2,13,10,'Listen +8, Spot +7, Swim +12','Alertness, Endurance, Iron Will','{"special_attacks":"Rend 2d6+6","special_qualities":"Darkvision 60 ft., hold breath, low-light vision, scent"}'::jsonb,'A typical sea cat is 12 feet long and weighs 800 pounds.

### Combat

Sea cats attack on sight, either for food or to defend their territory, and use both claws and teeth to grab and rend their prey. They display tremendous courage, always fighting to the death, even against creatures many times their size. Pairs and prides of sea cats attack in concert, trying to wear the opponent down until one beast can dispatch it.

**Hold Breath (Ex):** A sea cat can hold its breath for a number of rounds equal to 6  its Constitution score before it risks drowning.

**Rend (Ex):** A sea cat that hits with both claw attacks latches onto the opponent’s body and tears the flesh. This automatically deals an extra 2d6+6 points of damage.

**Skills:** A sea cat has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +9 melee (1d6+4) and bite +4 melee (1d8+2)","environment":"Temperate aquatic","organization":"Solitary, pair, or pride (5–12)","treasure":"None","advancement":"7–9 HD (Large); 10–18 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"6d10+18 (51 hp)","hit_points":51,"base_attack_grapple":"+6/+14","attack":"Claw +9 melee (1d6+4)","full_attack":"2 claws +9 melee (1d6+4) and bite +4 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +6, Will +5","abilities":{"str":"19","dex":"12","con":"17","int":"2","wis":"13","cha":"10"},"skills":"Listen +8, Spot +7, Swim +12","feats":"Alertness, Endurance, Iron Will","special_attacks":"Rend 2d6+6","special_qualities":"Darkvision 60 ft., hold breath, low-light vision, scent"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('shadow','Shadow','Shadow','3','Medium','Undead (Incorporeal)','Always chaotic evil','3d12 (19 hp)',19,'+2','Fly 40 ft. (good) (8 squares)','13 (+2 Dex, +1 deflection), touch 13, flat-footed 11','+1/—','Incorporeal touch +3 melee (1d6 Str)','5 ft./5 ft.','+1','+3','+4',null,14,null,6,12,13,'Hide +8*, Listen +7, Search +4, Spot +7','Alertness, Dodge','{"special_attacks":"Create spawn, strength damage","special_qualities":"Darkvision 60 ft., incorporeal traits, +2 turn resistance, undead traits"}'::jsonb,'A shadow can be difficult to see in dark or gloomy areas but stands out starkly in brightly illuminated places.

A shadow is 5 to 6 feet tall and is weightless. Shadows cannot speak intelligibly.

### Combat

Shadows lurk in dark places, waiting for living prey to happen by.

**Strength Damage (Su):** The touch of a shadow deals 1d6 points of Strength damage to a living foe. A creature reduced to Strength 0 by a shadow dies. This is a negative energy effect.

**Create Spawn (Su):** Any humanoid reduced to Strength 0 by a shadow becomes a shadow under the control of its killer within 1d4 rounds.

**Skills:** Shadows have a +2 racial bonus on Listen and Spot checks and a +4 racial bonus on Search checks. \*A shadow gains a +4 racial bonus on Hide checks in areas of shadowy illumination. In brightly lit areas, it takes a –4 penalty on Hide checks.

### Greater Shadow

Although no more intelligent than an average shadow, a greater shadow is more fearsome because of its increased damage and its hit-and-run tactics.

#### Combat

**Strength Damage (Su):** The touch of a greater shadow deals 1d8 points of Strength damage to a living foe.','{"full_attack":"Incorporeal touch +3 melee (1d6 Str)","environment":"Any","organization":"Solitary, gang (2–5), or swarm (6–11)","treasure":"None","advancement":"4–9 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"3d12 (19 hp)","hit_points":19,"base_attack_grapple":"+1/—","attack":"Incorporeal touch +3 melee (1d6 Str)","full_attack":"Incorporeal touch +3 melee (1d6 Str)","space_reach":"5 ft./5 ft.","saves":"Fort +1, Ref +3, Will +4","abilities":{"str":null,"dex":"14","con":null,"int":"6","wis":"12","cha":"13"},"skills":"Hide +8*, Listen +7, Search +4, Spot +7","feats":"Alertness, Dodge","special_attacks":"Create spawn, strength damage","special_qualities":"Darkvision 60 ft., incorporeal traits, +2 turn resistance, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('greater_shadow','Greater Shadow','Greater Shadow','8','Medium','Undead (Incorporeal)','Always chaotic evil','9d12 (58 hp)',58,'+2','Fly 40 ft. (good) (8 squares)','14 (+2 Dex, +2 deflection), touch 14, flat-footed 12','+4/—','Incorporeal touch +6 melee (1d8 Str)','5 ft./5 ft.','+3','+5','+7',null,15,null,6,12,14,'Hide +14*, Listen +9, Search +6, Spot +9','Alertness, Dodge, Mobility, Spring Attack','{"special_attacks":"Create spawn, strength damage","special_qualities":"Darkvision 60 ft., incorporeal traits, +2 turn resistance, undead traits"}'::jsonb,'A shadow can be difficult to see in dark or gloomy areas but stands out starkly in brightly illuminated places.

A shadow is 5 to 6 feet tall and is weightless. Shadows cannot speak intelligibly.

### Combat

Shadows lurk in dark places, waiting for living prey to happen by.

**Strength Damage (Su):** The touch of a shadow deals 1d6 points of Strength damage to a living foe. A creature reduced to Strength 0 by a shadow dies. This is a negative energy effect.

**Create Spawn (Su):** Any humanoid reduced to Strength 0 by a shadow becomes a shadow under the control of its killer within 1d4 rounds.

**Skills:** Shadows have a +2 racial bonus on Listen and Spot checks and a +4 racial bonus on Search checks. \*A shadow gains a +4 racial bonus on Hide checks in areas of shadowy illumination. In brightly lit areas, it takes a –4 penalty on Hide checks.

### Greater Shadow

Although no more intelligent than an average shadow, a greater shadow is more fearsome because of its increased damage and its hit-and-run tactics.

#### Combat

**Strength Damage (Su):** The touch of a greater shadow deals 1d8 points of Strength damage to a living foe.','{"full_attack":"Incorporeal touch +6 melee (1d8 Str)","environment":"Any","organization":"Solitary","treasure":"None","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"9d12 (58 hp)","hit_points":58,"base_attack_grapple":"+4/—","attack":"Incorporeal touch +6 melee (1d8 Str)","full_attack":"Incorporeal touch +6 melee (1d8 Str)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +5, Will +7","abilities":{"str":null,"dex":"15","con":null,"int":"6","wis":"12","cha":"14"},"skills":"Hide +14*, Listen +9, Search +6, Spot +9","feats":"Alertness, Dodge, Mobility, Spring Attack","special_attacks":"Create spawn, strength damage","special_qualities":"Darkvision 60 ft., incorporeal traits, +2 turn resistance, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('shadow_mastiff','Shadow Mastiff','Shadow Mastiff','5','Medium','Outsider (Extraplanar)','Always neutral evil','4d8+12 (30 hp)',30,'+5','50 ft. (10 squares)','14 (+1 Dex, +3 natural), touch 11, flat-footed 13','+4/+7','Bite +7 melee (1d6+4)','5 ft./5 ft.','+7','+5','+5',17,13,17,4,12,13,'Hide +8, Listen +8, Move Silently +8, Spot +8, Survival +8*','Dodge, Improved Initiative, TrackB','{"special_attacks":"Bay, trip","special_qualities":"Darkvision 60 ft., shadow blend, scent"}'::jsonb,'This creature has the body of a large dog, with a smooth black coat and a mouth full of sharp teeth.

A shadow mastiff is slightly more than 2 feet high at the shoulder and weighs about 200 pounds.

Shadow mastiffs cannot speak, but they understand Common.

### Combat

Shadow mastiffs prefer fighting in shadows or dark conditions, which gives them a great advantage.

If a magical light source negates the shadows around them, shadow mastiffs are cunning enough to either move out of the light or back off and break up the opposition with their baying. They have been known to seize and carry off items enspelled with _daylight_ spells.

**Bay (Su):** When a shadow mastiff howls or barks, all creatures except evil outsiders within a 300-foot spread must succeed on a DC 13 Will save or become panicked for 2d4 rounds. This is a sonic mind-affecting fear effect. Whether or not the save is successful, an affected creature is immune to the same mastiff ’s bay for 24 hours. The save DC is Charisma-based.

**Trip (Ex):** A shadow mastiff that hits with its bite attack can attempt to trip the opponent as a free action (+3 check modifier) without making a touch attack or provoking an attack of opportunity. If the attempt fails, the opponent cannot react to trip the shadow mastiff.

**Shadow Blend (Su):** In any condition of illumination other than full daylight, a shadow mastiff can disappear into the shadows, giving it total concealment. Artificial illumination, even a _light_ or _continual flame_ spell, does not negate this ability. A _daylight_ spell, however, will.

**Skills:** \*A shadow mastiff has a +4 racial bonus on Survival checks when tracking by scent.','{"full_attack":"Bite +7 melee (1d6+4)","environment":"Plane of Shadow","organization":"Solitary, pair, or pack (5–12)","treasure":"None","advancement":"5–6 HD (Medium); 7–12 HD (Large)","level_adjustment":"+3 (cohort)","statblock":{"hit_dice":"4d8+12 (30 hp)","hit_points":30,"base_attack_grapple":"+4/+7","attack":"Bite +7 melee (1d6+4)","full_attack":"Bite +7 melee (1d6+4)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +5, Will +5","abilities":{"str":"17","dex":"13","con":"17","int":"4","wis":"12","cha":"13"},"skills":"Hide +8, Listen +8, Move Silently +8, Spot +8, Survival +8*","feats":"Dodge, Improved Initiative, TrackB","special_attacks":"Bay, trip","special_qualities":"Darkvision 60 ft., shadow blend, scent"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('shambling_mound','Shambling Mound','Shambling Mound','6','Large','Plant','Usually neutral','8d8+24 (60 hp)',60,'+0','20 ft. (4 squares), swim 20 ft.','20 (–1 size, +11 natural), touch 9, flat-footed 20','+6/+15','Slam +11 melee (2d6+5)','10 ft./10 ft.','+9','+2','+4',21,10,17,7,10,9,'Hide +3*, Listen +8, Move Silently +8','Iron Will, Power Attack, Weapon Focus (slam)','{"special_attacks":"Improved grab, constrict 2d6+7","special_qualities":"Darkvision 60 ft., immunity to electricity, low-light vision, plant traits, resistance to fire 10"}'::jsonb,'Shambling mounds, also called shamblers, appear to be heaps of rotting vegetation. They are actually intelligent, carnivorous plants.

A shambler’s brain and sensory organs are located in its upper body.

A shambler’s body has an 8-foot girth and is about 6 feet tall when the creature stands erect. It weighs about 3,800 pounds.

### Combat

A shambling mound batters or constricts its opponents with two huge, armlike appendages.

**Improved Grab (Ex):** To use this ability, a shambler must hit with both slam attacks. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Constrict (Ex):** A shambler deals 2d6+7 points of damage with a successful grapple check.

**Immunity to Electricity (Ex):** Shamblers take no damage from electricity. Instead, any electricity attack used against a shambler temporarily grants it 1d4 points of Constitution. The shambler loses these points at the rate of 1 per hour.

Skills: Shamblers have a +4 racial bonus on Hide, Listen, and Move Silently checks. \*They have a +12 racial bonus on Hide checks when in a swampy or forested area.','{"full_attack":"2 slams +11 melee (2d6+5)","environment":"Temperate marshes","organization":"Solitary","treasure":"1/10th coins; 50% goods; 50% items","advancement":"9–12 HD (Large); 13–24 HD (Huge)","level_adjustment":"+6","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+6/+15","attack":"Slam +11 melee (2d6+5)","full_attack":"2 slams +11 melee (2d6+5)","space_reach":"10 ft./10 ft.","saves":"Fort +9, Ref +2, Will +4","abilities":{"str":"21","dex":"10","con":"17","int":"7","wis":"10","cha":"9"},"skills":"Hide +3*, Listen +8, Move Silently +8","feats":"Iron Will, Power Attack, Weapon Focus (slam)","special_attacks":"Improved grab, constrict 2d6+7","special_qualities":"Darkvision 60 ft., immunity to electricity, low-light vision, plant traits, resistance to fire 10"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('shield_guardian','Shield Guardian','Shield Guardian','8','Large','Construct','Always neutral','15d10+30 (112 hp)',112,'+0','30 ft. (6 squares)','24 (–1 size, +15 natural), touch 9, flat-footed 24','+11/+21','Slam +16 melee (1d8+6)','10 ft./10 ft.','+5','+5','+5',22,10,null,null,10,1,'','','{"special_attacks":"—","special_qualities":"Construct traits, darkvision 60 ft., fast healing 5, find master, guard, low-light vision, shield other, spell storing"}'::jsonb,'Created by spellcasters to be bodyguards, shield guardians are constructs that protect their masters with spells and stamina. When it is fashioned, a shield guardian is keyed to a particular magical amulet. Henceforth, it regards the wearer of that amulet to be its master, protecting and following that individual everywhere (unless specifically commanded not to do so).

A shield guardian obeys its master’s verbal commands to the best of its ability, although it is not good for much beyond combat and possibly simple manual labor. It can also be keyed to perform specific tasks at specific times or when certain conditions are met. The wearer of the amulet can call the shield guardian from any distance, and it will come as long as it is on the same plane.

A shield guardian is some 9 feet tall and weighs more than 1,200 pounds.

Shield guardians cannot speak, but they understand commands given in any language.

### Combat

Shield guardians are straightforward in battle, bashing with their heavy stone fists. They are made for defense and are not particularly impressive on offense.

**Find Master (Su):** As long as a shield guardian and its amulet are on the same plane, the shield guardian can find the amulet wearer (or just the amulet, if it is removed after the guardian is called).

**Guard (Ex):** If ordered to do so, a shield guardian moves swiftly to defend the wearer of its amulet, blocking blows and disrupting foes. All attacks against the amulet wearer take a –2 penalty when the shield guardian is adjacent to its master.

**_Shield Other_ (Sp):** The wearer of a shield guardian’s amulet can activate this defensive ability if within 100 feet of the shield guardian. Just as the spell of the same name, this ability transfers to the shield guardian half the damage that would be dealt to the amulet wearer (this ability does not provide the spell’s AC or save bonuses).

**_Spell Storing_ (Sp):** A shield guardian can store one spell of 4th level or lower that is cast into it by another creature. It “casts” this spell when commanded to do so or when a predefined situation arises. Once this spell is used, the shield guardian can store another spell (or the same spell again).

### Construction

A shield guardian is built from wood, bronze, stone, and steel. The materials cost 5,000 gp.

The creature’s master may assemble the body or hire someone else to do the job. Creating the body requires a DC 16 Craft (blacksmithing) or Craft (carpentry) check. The keyed amulet is fashioned at the same time, and its cost (20,000 gp) is included in the cost of the guardian. After the body is sculpted, the shield guardian is animated through an extended magical ritual that requires a specially prepared laboratory or workroom, similar to an alchemist’s laboratory and costing 500 gp to establish. If the creator is personally constructing the creature’s body, the building and the ritual can be performed together. A shield guardian with more than 15 Hit Dice can be created, but each additional Hit Die adds +5,000 gp to the market price, and the price increases by +20,000 gp if the creature’s size increases to Huge, modifying the cost to create accordingly.

CL 15th; Craft Construct, _limited wish, discern location, shield, shield other,_ caster must be at least 15th level; Price 120,000 gp; Cost 65,000 gp + 4,600 XP.

### Amulet

If a shield guardian’s amulet is destroyed, the guardian ceases to function until a new one is created. If the wearer dies but the amulet is intact, the shield guardian carries out the last command it was given.','{"full_attack":"2 slams +16 melee (1d8+6)","environment":"Any","organization":"Solitary","treasure":"None","advancement":"16–24 HD (Large); 25–45 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"15d10+30 (112 hp)","hit_points":112,"base_attack_grapple":"+11/+21","attack":"Slam +16 melee (1d8+6)","full_attack":"2 slams +16 melee (1d8+6)","space_reach":"10 ft./10 ft.","saves":"Fort +5, Ref +5, Will +5","abilities":{"str":"22","dex":"10","con":null,"int":null,"wis":"10","cha":"1"},"skills":"","feats":"","special_attacks":"—","special_qualities":"Construct traits, darkvision 60 ft., fast healing 5, find master, guard, low-light vision, shield other, spell storing"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('shocker_lizard','Shocker Lizard','Shocker Lizard','2','Small','Magical Beast','Always neutral','2d10+2 (13 hp)',13,'+6','40 ft. (8 squares), climb 20 ft., swim 20 ft.','16 (+1 size, +2 Dex, +3 natural), touch 13, flat-footed 14','+2/–2','Bite +3 melee (1d4)','5 ft./5 ft.','+4','+5','+1',10,15,13,2,12,6,'Climb +11, Hide +11, Jump +7, Listen +4, Spot +4, Swim +10','Improved Initiative','{"special_attacks":"Stunning shock, lethal shock","special_qualities":"Darkvision 60 ft., electricity sense, immunity to electricity, low-light vision"}'::jsonb,'A shocker lizard has a pale gray or blue underside, shading to a darker hue on its back. It has blue-black markings along its back and tail. A shocker lizard is about 1 foot tall at the shoulder and weighs about 25 pounds.

### Combat

A shocker lizard relies on its electricity abilities in combat. A lizard tends to bite only after its shock has rendered an opponent unconscious or when the shock seems to have no effect at all. A solitary lizard flees once it delivers its shocks, but if other shocker lizards are nearby, they all home in on their comrade’s discharges and attempt to administer their shocks to the foe.

**Stunning Shock (Su):** Once per round, a shocker lizard can deliver an electrical shock to a single opponent within 5 feet. This attack deals 2d8 points of nonlethal damage to living opponents (Reflex DC 12 half ). The save DC is Constitution-based.

**Lethal Shock (Su):** Whenever two or more shocker lizards are within 20 feet of each other, they can work together to create a lethal shock. This effect has a radius of 20 feet, centered on any one contributing lizard. The shock deals 2d8 points of electricity damage for each lizard contributing to it, to a maximum of 12d8. A Reflex save (DC 10 + number of lizards contributing) reduces the damage by half.

**Electricity Sense (Ex):** Shocker lizards automatically detect any electrical discharges within 100 feet.

**Skills:** Shocker lizards have a +4 racial bonus on Hide checks due to their coloration. Shocker lizards have a +2 racial bonus on Listen and Spot checks.

Shocker lizards use their Dexterity modifier instead of their Strength modifier for Climb and Jump checks.

A shocker lizard has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.

A shocker lizard has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"Bite +3 melee (1d4)","environment":"Warm marshes","organization":"Solitary, pair, clutch (3–5), or colony (6–11)","treasure":"1/10 coins; 50% goods; 50% items","advancement":"3–4 HD (Small); 5–6 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d10+2 (13 hp)","hit_points":13,"base_attack_grapple":"+2/–2","attack":"Bite +3 melee (1d4)","full_attack":"Bite +3 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +5, Will +1","abilities":{"str":"10","dex":"15","con":"13","int":"2","wis":"12","cha":"6"},"skills":"Climb +11, Hide +11, Jump +7, Listen +4, Spot +4, Swim +10","feats":"Improved Initiative","special_attacks":"Stunning shock, lethal shock","special_qualities":"Darkvision 60 ft., electricity sense, immunity to electricity, low-light vision"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('skeleton_human_warrior','Esqueleto humano (guerreiro 1)','Human Warrior Skeleton','1/3','Medium','Undead','Always neutral evil','1d12 (6 hp)',6,'+5','30 ft. (6 squares)','15 (+1 Dex, +2 natural, +2 heavy steel shield), touch 11, flat-footed 14','+0/+1','Scimitar +1 melee (1d6+1/18–20) or claw +1 melee (1d4+1)','5 ft./5 ft.','+0','+1','+2',null,null,null,null,null,null,'','Improved Initiative','{"special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Troll Skeleton</th><th>Chimera Skeleton</th><th>Ettin Skeleton</th></tr><tr><td></td><td>Large Undead</td><td>Large Undead</td><td>Large Undead</td></tr><tr><th>Hit Dice:</th><td>6d12 (39 hp)</td><td>9d12 (58 hp)</td><td>10d12 (65 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+4</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (+3 Dex, –1 size, +2 natural), touch 12, flat-footed 11</td><td>13 (+2 Dex., –1 size, +2 natural), touch 11, flat-footed 11</td><td>11 (–1 size, +2 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+3/+13</td><td>+4/+12</td><td>+5/+15</td></tr><tr><th>Attack:</th><td>Claw +8 melee (1d6+6)</td><td>Bite +7 melee (2d6+4)</td><td>Morningstar +10 melee (2d6+6) or claw +10 melee (1d6+6) or javelin +4 ranged (1d8+6)</td></tr><tr><th>Full Attack:</th><td>2 claws +8 melee (1d6+6) and bite +3 melee (1d6+3)</td><td>Bite +7 melee (2d6+4) and bite+7 melee (1d8+4) and gore +7 melee (1d8+4) and 2 claws +2 melee (1d6+2)</td><td>2 morningstars +10 melee (2d6+6) or 2 claws +10 melee (1d6+6) or 2 javelins +4 ranged (1d8+6)</td></tr><tr><th>Space/Reach:</th><td>10 ft./10 ft</td><td>10 ft./5 ft</td><td>10 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., darkvision 60 ft., immunity to cold, superior twoweapon</td></tr><tr><th>Saves:</th><td>Fort +2, Ref +5, Will +5</td><td>Fort +3, Ref +5, Will +6</td><td>Fort +3, Ref +3, Will +7</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 16, Con —, Int —, Wis 10, Cha 1</td><td>Str 19, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 23, Dex 10, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Cold mountains</td><td>Temperate hills</td><td>Cold hills</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>3</td><td>4</td><td>5</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>—</td><td>10–13 HD (Large); 14–27 HD (Huge)</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Advanced Megaraptor Skeleton</th><th>Cloud Giant Skeleton</th><th>Young Adult Red Dragon Skeleton</th></tr><tr><td></td><td>Huge Undead</td><td>Huge Undead</td><td>Huge Undead (Fire)</td></tr><tr><th>Hit Dice:</th><td>12d12 (78 hp)</td><td>17d12 (110 hp)</td><td>19d12 (123 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+5</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>50 ft. (10 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (–2 size, +3 Dex, +3 natural), touch 11, flat-footed 11</td><td>13 (–2 size, +2 Dex, +3 natural), touch 10, flat-footed 11</td><td>12 (–2 size, +1 Dex, +3 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+6/+19</td><td>+8/+28</td><td>+9/+27</td></tr><tr><th>Attack:</th><td>Talons +9 melee (2d8+5)</td><td>Gargantuan morningstar +18 melee (4d6+18) or claw +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10)</td></tr><tr><th>Full Attack:</th><td>Talons +9 melee (2d8+5) and 2 claws +4 melee (1d8+2) and bite +4 melee (2d6+2)</td><td>Gargantuan morningstar +18/+13 melee (4d6+18) or 2 claws +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10) and 2 claws +12 melee (2d6+5) and 2 wings +12 melee (1d8+5) and tail slap +12 melee (2d6+15)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./15 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, oversize weapon, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold and fire, undead traits</td></tr><tr><th>Saves:</th><td>Fort +4, Ref +7, Will +8</td><td>Fort +5, Ref +7, Will +10</td><td>Fort +6, Ref +7, Will +8</td></tr><tr><th>Abilities:</th><td>Str 21, Dex 17, Con —, Int —, Wis 10, Cha 1</td><td>Str 35, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 31, Dex 12, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Warm forests</td><td>Temperate mountains</td><td>Warm mountains</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>6</td><td>7</td><td>8</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>13–16 HD (Huge); 17–20 HD (Gargantuan)</td><td>—</td><td>20 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>','{"full_attack":"Scimitar +1 melee (1d6+1/18–20) or 2 claws +1 melee (1d4+1)","environment":"Temperate plains","organization":"Any","treasure":"None","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"1d12 (6 hp)","hit_points":6,"base_attack_grapple":"+0/+1","attack":"Scimitar +1 melee (1d6+1/18–20) or claw +1 melee (1d4+1)","full_attack":"Scimitar +1 melee (1d6+1/18–20) or 2 claws +1 melee (1d4+1)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +1, Will +2","abilities":{"str":null,"dex":null,"con":null,"int":null,"wis":null,"cha":null},"skills":"","feats":"Improved Initiative","special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('wolf_skeleton','Wolf Skeleton','Wolf Skeleton','1','Medium','Undead','Always neutral evil','2d12 (13 hp)',13,'+7','50 ft. (10 squares)','15 (+3 Dex, +2 natural), touch 13, flat-footed 12','+1/+2','Bite +2 melee (1d6+1)','5 ft./5 ft.','+0','+3','+3',null,null,null,null,null,null,'','Improved Initiative','{"special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Troll Skeleton</th><th>Chimera Skeleton</th><th>Ettin Skeleton</th></tr><tr><td></td><td>Large Undead</td><td>Large Undead</td><td>Large Undead</td></tr><tr><th>Hit Dice:</th><td>6d12 (39 hp)</td><td>9d12 (58 hp)</td><td>10d12 (65 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+4</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (+3 Dex, –1 size, +2 natural), touch 12, flat-footed 11</td><td>13 (+2 Dex., –1 size, +2 natural), touch 11, flat-footed 11</td><td>11 (–1 size, +2 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+3/+13</td><td>+4/+12</td><td>+5/+15</td></tr><tr><th>Attack:</th><td>Claw +8 melee (1d6+6)</td><td>Bite +7 melee (2d6+4)</td><td>Morningstar +10 melee (2d6+6) or claw +10 melee (1d6+6) or javelin +4 ranged (1d8+6)</td></tr><tr><th>Full Attack:</th><td>2 claws +8 melee (1d6+6) and bite +3 melee (1d6+3)</td><td>Bite +7 melee (2d6+4) and bite+7 melee (1d8+4) and gore +7 melee (1d8+4) and 2 claws +2 melee (1d6+2)</td><td>2 morningstars +10 melee (2d6+6) or 2 claws +10 melee (1d6+6) or 2 javelins +4 ranged (1d8+6)</td></tr><tr><th>Space/Reach:</th><td>10 ft./10 ft</td><td>10 ft./5 ft</td><td>10 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., darkvision 60 ft., immunity to cold, superior twoweapon</td></tr><tr><th>Saves:</th><td>Fort +2, Ref +5, Will +5</td><td>Fort +3, Ref +5, Will +6</td><td>Fort +3, Ref +3, Will +7</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 16, Con —, Int —, Wis 10, Cha 1</td><td>Str 19, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 23, Dex 10, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Cold mountains</td><td>Temperate hills</td><td>Cold hills</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>3</td><td>4</td><td>5</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>—</td><td>10–13 HD (Large); 14–27 HD (Huge)</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Advanced Megaraptor Skeleton</th><th>Cloud Giant Skeleton</th><th>Young Adult Red Dragon Skeleton</th></tr><tr><td></td><td>Huge Undead</td><td>Huge Undead</td><td>Huge Undead (Fire)</td></tr><tr><th>Hit Dice:</th><td>12d12 (78 hp)</td><td>17d12 (110 hp)</td><td>19d12 (123 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+5</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>50 ft. (10 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (–2 size, +3 Dex, +3 natural), touch 11, flat-footed 11</td><td>13 (–2 size, +2 Dex, +3 natural), touch 10, flat-footed 11</td><td>12 (–2 size, +1 Dex, +3 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+6/+19</td><td>+8/+28</td><td>+9/+27</td></tr><tr><th>Attack:</th><td>Talons +9 melee (2d8+5)</td><td>Gargantuan morningstar +18 melee (4d6+18) or claw +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10)</td></tr><tr><th>Full Attack:</th><td>Talons +9 melee (2d8+5) and 2 claws +4 melee (1d8+2) and bite +4 melee (2d6+2)</td><td>Gargantuan morningstar +18/+13 melee (4d6+18) or 2 claws +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10) and 2 claws +12 melee (2d6+5) and 2 wings +12 melee (1d8+5) and tail slap +12 melee (2d6+15)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./15 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, oversize weapon, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold and fire, undead traits</td></tr><tr><th>Saves:</th><td>Fort +4, Ref +7, Will +8</td><td>Fort +5, Ref +7, Will +10</td><td>Fort +6, Ref +7, Will +8</td></tr><tr><th>Abilities:</th><td>Str 21, Dex 17, Con —, Int —, Wis 10, Cha 1</td><td>Str 35, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 31, Dex 12, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Warm forests</td><td>Temperate mountains</td><td>Warm mountains</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>6</td><td>7</td><td>8</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>13–16 HD (Huge); 17–20 HD (Gargantuan)</td><td>—</td><td>20 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>','{"full_attack":"Bite +2 melee (1d6+1)","environment":"Temperate forests","organization":"Any","treasure":"None","advancement":"3 HD (Medium); 4–6 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"2d12 (13 hp)","hit_points":13,"base_attack_grapple":"+1/+2","attack":"Bite +2 melee (1d6+1)","full_attack":"Bite +2 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +3, Will +3","abilities":{"str":null,"dex":null,"con":null,"int":null,"wis":null,"cha":null},"skills":"","feats":"Improved Initiative","special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('owlbear_skeleton','Owlbear Skeleton','Owlbear Skeleton','2','Large','Undead','Always neutral evil','5d12 (32 hp)',32,'+6','30 ft. (6 squares)','13 (–1 size, +2 Dex, +2 natural), touch 11, flat-footed 11','+2/+11','Claw +6 melee (1d6+5)','10 ft./5 ft.','+1','+3','+4',null,null,null,null,null,null,'','Improved Initiative','{"special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Troll Skeleton</th><th>Chimera Skeleton</th><th>Ettin Skeleton</th></tr><tr><td></td><td>Large Undead</td><td>Large Undead</td><td>Large Undead</td></tr><tr><th>Hit Dice:</th><td>6d12 (39 hp)</td><td>9d12 (58 hp)</td><td>10d12 (65 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+4</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (+3 Dex, –1 size, +2 natural), touch 12, flat-footed 11</td><td>13 (+2 Dex., –1 size, +2 natural), touch 11, flat-footed 11</td><td>11 (–1 size, +2 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+3/+13</td><td>+4/+12</td><td>+5/+15</td></tr><tr><th>Attack:</th><td>Claw +8 melee (1d6+6)</td><td>Bite +7 melee (2d6+4)</td><td>Morningstar +10 melee (2d6+6) or claw +10 melee (1d6+6) or javelin +4 ranged (1d8+6)</td></tr><tr><th>Full Attack:</th><td>2 claws +8 melee (1d6+6) and bite +3 melee (1d6+3)</td><td>Bite +7 melee (2d6+4) and bite+7 melee (1d8+4) and gore +7 melee (1d8+4) and 2 claws +2 melee (1d6+2)</td><td>2 morningstars +10 melee (2d6+6) or 2 claws +10 melee (1d6+6) or 2 javelins +4 ranged (1d8+6)</td></tr><tr><th>Space/Reach:</th><td>10 ft./10 ft</td><td>10 ft./5 ft</td><td>10 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., darkvision 60 ft., immunity to cold, superior twoweapon</td></tr><tr><th>Saves:</th><td>Fort +2, Ref +5, Will +5</td><td>Fort +3, Ref +5, Will +6</td><td>Fort +3, Ref +3, Will +7</td></tr><tr><th>Abilities:</th><td>Str 23, Dex 16, Con —, Int —, Wis 10, Cha 1</td><td>Str 19, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 23, Dex 10, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Cold mountains</td><td>Temperate hills</td><td>Cold hills</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>3</td><td>4</td><td>5</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>—</td><td>10–13 HD (Large); 14–27 HD (Huge)</td><td>—</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Advanced Megaraptor Skeleton</th><th>Cloud Giant Skeleton</th><th>Young Adult Red Dragon Skeleton</th></tr><tr><td></td><td>Huge Undead</td><td>Huge Undead</td><td>Huge Undead (Fire)</td></tr><tr><th>Hit Dice:</th><td>12d12 (78 hp)</td><td>17d12 (110 hp)</td><td>19d12 (123 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+5</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>50 ft. (10 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (–2 size, +3 Dex, +3 natural), touch 11, flat-footed 11</td><td>13 (–2 size, +2 Dex, +3 natural), touch 10, flat-footed 11</td><td>12 (–2 size, +1 Dex, +3 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+6/+19</td><td>+8/+28</td><td>+9/+27</td></tr><tr><th>Attack:</th><td>Talons +9 melee (2d8+5)</td><td>Gargantuan morningstar +18 melee (4d6+18) or claw +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10)</td></tr><tr><th>Full Attack:</th><td>Talons +9 melee (2d8+5) and 2 claws +4 melee (1d8+2) and bite +4 melee (2d6+2)</td><td>Gargantuan morningstar +18/+13 melee (4d6+18) or 2 claws +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10) and 2 claws +12 melee (2d6+5) and 2 wings +12 melee (1d8+5) and tail slap +12 melee (2d6+15)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./15 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, oversize weapon, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold and fire, undead traits</td></tr><tr><th>Saves:</th><td>Fort +4, Ref +7, Will +8</td><td>Fort +5, Ref +7, Will +10</td><td>Fort +6, Ref +7, Will +8</td></tr><tr><th>Abilities:</th><td>Str 21, Dex 17, Con —, Int —, Wis 10, Cha 1</td><td>Str 35, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 31, Dex 12, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Warm forests</td><td>Temperate mountains</td><td>Warm mountains</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>6</td><td>7</td><td>8</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>13–16 HD (Huge); 17–20 HD (Gargantuan)</td><td>—</td><td>20 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>','{"full_attack":"2 claws +6 melee (1d6+5) and bite +1 melee (1d8+2)","environment":"Temperate forests","organization":"Any","treasure":"None","advancement":"6–8 HD (Large); 9–15 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"5d12 (32 hp)","hit_points":32,"base_attack_grapple":"+2/+11","attack":"Claw +6 melee (1d6+5)","full_attack":"2 claws +6 melee (1d6+5) and bite +1 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +1, Ref +3, Will +4","abilities":{"str":null,"dex":null,"con":null,"int":null,"wis":null,"cha":null},"skills":"","feats":"Improved Initiative","special_attacks":"","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true),
('troll_skeleton','Troll Skeleton','Troll Skeleton','3','Large','Undead','Always neutral evil','6d12 (39 hp)',39,'+7','30 ft. (6 squares)','14 (+3 Dex, –1 size, +2 natural), touch 12, flat-footed 11','+3/+13','Claw +8 melee (1d6+6)','10 ft./10 ft','+2','+5','+5',23,16,null,null,10,1,'','Improved Initiative','{"special_attacks":"—","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Advanced Megaraptor Skeleton</th><th>Cloud Giant Skeleton</th><th>Young Adult Red Dragon Skeleton</th></tr><tr><td></td><td>Huge Undead</td><td>Huge Undead</td><td>Huge Undead (Fire)</td></tr><tr><th>Hit Dice:</th><td>12d12 (78 hp)</td><td>17d12 (110 hp)</td><td>19d12 (123 hp)</td></tr><tr><th>Initiative:</th><td>+7</td><td>+6</td><td>+5</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>50 ft. (10 squares)</td><td>40 ft. (8 squares)</td></tr><tr><th>Armor Class:</th><td>14 (–2 size, +3 Dex, +3 natural), touch 11, flat-footed 11</td><td>13 (–2 size, +2 Dex, +3 natural), touch 10, flat-footed 11</td><td>12 (–2 size, +1 Dex, +3 natural), touch 9, flat-footed 11</td></tr><tr><th>Base Attack/Grapple:</th><td>+6/+19</td><td>+8/+28</td><td>+9/+27</td></tr><tr><th>Attack:</th><td>Talons +9 melee (2d8+5)</td><td>Gargantuan morningstar +18 melee (4d6+18) or claw +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10)</td></tr><tr><th>Full Attack:</th><td>Talons +9 melee (2d8+5) and 2 claws +4 melee (1d8+2) and bite +4 melee (2d6+2)</td><td>Gargantuan morningstar +18/+13 melee (4d6+18) or 2 claws +18 melee (1d8+12) or rock +8 ranged (2d8+12)</td><td>Bite +17 melee (2d8+10) and 2 claws +12 melee (2d6+5) and 2 wings +12 melee (1d8+5) and tail slap +12 melee (2d6+15)</td></tr><tr><th>Space/Reach:</th><td>15 ft./10 ft.</td><td>15 ft./15 ft.</td><td>15 ft./10 ft.</td></tr><tr><th>Special Attacks:</th><td>—</td><td>—</td><td>—</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, oversize weapon, undead traits</td><td>Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold and fire, undead traits</td></tr><tr><th>Saves:</th><td>Fort +4, Ref +7, Will +8</td><td>Fort +5, Ref +7, Will +10</td><td>Fort +6, Ref +7, Will +8</td></tr><tr><th>Abilities:</th><td>Str 21, Dex 17, Con —, Int —, Wis 10, Cha 1</td><td>Str 35, Dex 15, Con —, Int —, Wis 10, Cha 1</td><td>Str 31, Dex 12, Con —, Int —, Wis 10, Cha 1</td></tr><tr><th>Feats:</th><td>Improved Initiative</td><td>Improved Initiative</td><td>Improved Initiative</td></tr><tr><th>Environment:</th><td>Warm forests</td><td>Temperate mountains</td><td>Warm mountains</td></tr><tr><th>Organization:</th><td>Any</td><td>Any</td><td>Any</td></tr><tr><th>Challenge Rating:</th><td>6</td><td>7</td><td>8</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Always neutral evil</td><td>Always neutral evil</td><td>Always neutral evil</td></tr><tr><th>Advancement:</th><td>13–16 HD (Huge); 17–20 HD (Gargantuan)</td><td>—</td><td>20 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>','{"full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d6+3)","environment":"Cold mountains","organization":"Any","treasure":"None","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"6d12 (39 hp)","hit_points":39,"base_attack_grapple":"+3/+13","attack":"Claw +8 melee (1d6+6)","full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d6+3)","space_reach":"10 ft./10 ft","saves":"Fort +2, Ref +5, Will +5","abilities":{"str":"23","dex":"16","con":null,"int":null,"wis":"10","cha":"1"},"skills":"","feats":"Improved Initiative","special_attacks":"—","special_qualities":"Damage reduction 5/bludgeoning, darkvision 60 ft., immunity to cold, undead traits"},"source_file":"monsters-s.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-s.html',true)
on conflict(id) do update set nome=case when public.srd_monsters.srd_canonical then public.srd_monsters.nome else excluded.nome end,nome_original=excluded.nome_original,nd=excluded.nd,tamanho=excluded.tamanho,tipo=excluded.tipo,tendencia=excluded.tendencia,dados_vida=excluded.dados_vida,pv=excluded.pv,iniciativa=excluded.iniciativa,deslocamento=excluded.deslocamento,ca=excluded.ca,base_attack_grapple=excluded.base_attack_grapple,ataques=excluded.ataques,espaco_alcance=excluded.espaco_alcance,fortitude=excluded.fortitude,reflexos=excluded.reflexos,vontade=excluded.vontade,forca=excluded.forca,destreza=excluded.destreza,constituicao=excluded.constituicao,inteligencia=excluded.inteligencia,sabedoria=excluded.sabedoria,carisma=excluded.carisma,pericias=excluded.pericias,talentos=excluded.talentos,qualidades_especiais=excluded.qualidades_especiais,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,srd_canonical=true;