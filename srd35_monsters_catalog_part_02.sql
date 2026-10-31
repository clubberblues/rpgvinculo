-- D&D 3.5 SRD OGC monster stat blocks and full entry rules. Source: https://github.com/olimot/srd-v3.5-md/tree/main/monsters
-- Open Game License 1.0a; attribution retained in srd_source_url and dados_tecnicos.
insert into public.srd_monsters (id,nome,nome_original,nd,tamanho,tipo,tendencia,dados_vida,pv,iniciativa,deslocamento,ca,base_attack_grapple,ataques,espaco_alcance,fortitude,reflexos,vontade,forca,destreza,constituicao,inteligencia,sabedoria,carisma,pericias,talentos,qualidades_especiais,descricao,dados_tecnicos,srd_source_url,srd_canonical) values
('basilisk','Basilisk','Basilisk','5','Medium','Magical Beast','Always neutral','6d10+12 (45 hp)',45,'–1','20 ft. (4 squares)','16 (–1 Dex, +7 natural), touch 9, flat-footed 16','+6/+8','Bite +8 melee (1d8+3)','5 ft./5 ft.','+9','+4','+3',15,8,15,2,12,11,'Hide +0*, Listen +7, Spot +7','Alertness, Blind-Fight, Great Fortitude','{"special_attacks":"Petrifying gaze","special_qualities":"Darkvision 60 ft., low-light vision"}'::jsonb,'A basilisk is a reptilian monster that petrifies living creatures with a mere gaze. A basilisk usually has a dull brown body with a yellowish underbelly. Some specimens sport a short, curved horn atop the nose. An adult basilisk’s body grows to about 6 feet long, not including its tail, which can reach an additional length of 5 to 7 feet. The creature weighs about 300 pounds.

### Combat

A basilisk relies on its gaze attack, biting only when opponents come within reach. Though it has eight legs, its slow metabolism renders it relatively sluggish, so it does not expend energy unnecessarily. Intruders who flee a basilisk rather than fight can expect, at best, a halfhearted pursuit. These creatures tend to spend most of their time lying in wait for prey, which includes small mammals, birds, reptiles, and similar creatures.

**Petrifying Gaze (Su):** Turn to stone permanently, range 30 feet; Fortitude DC 13 negates. The save DC is Charisma-based.

**Skills:** \*The basilisk’s dull coloration and its ability to remain motionless for long periods of time grant it a +4 racial bonus on Hide checks in natural settings.

### Abyssal Greater Basilisk

#### Combat

The save DC for the abyssal greater basilisk’s petrifying gaze (DC 21) is adjusted for its greater Hit Dice and higher Charisma score.

An abyssal greater basilisk’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Smite Good (Su):** Once per day an abyssal greater basilisk can make a normal melee attack to deal an extra 18 points of damage against a good foe.','{"full_attack":"Bite +8 melee (1d8+3)","environment":"Warm deserts","organization":"Solitary or colony (3–6)","treasure":"None","advancement":"7–10 HD (Medium); 11–18 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"6d10+12 (45 hp)","hit_points":45,"base_attack_grapple":"+6/+8","attack":"Bite +8 melee (1d8+3)","full_attack":"Bite +8 melee (1d8+3)","space_reach":"5 ft./5 ft.","saves":"Fort +9, Ref +4, Will +3","abilities":{"str":"15","dex":"8","con":"15","int":"2","wis":"12","cha":"11"},"skills":"Hide +0*, Listen +7, Spot +7","feats":"Alertness, Blind-Fight, Great Fortitude","special_attacks":"Petrifying gaze","special_qualities":"Darkvision 60 ft., low-light vision"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('abyssal_greater_basilisk','Abyssal Greater Basilisk','Abyssal Greater Basilisk','12','Large','Outsider (Augmented Magical Beast, Extraplanar)','Always chaotic evil','18d10+90 (189 hp)',189,'–1','20 ft. (4 squares)','17 (–1 Dex, –1 size, +9 natural) touch 8, flat-footed 17','+18/+29','Bite +25 melee (2d8+10)','10 ft./5 ft.','+18','+12','+8',24,8,21,3,10,15,'Hide +0*, Listen +10, Spot +10','Alertness, Blind-Fight, Great Fortitude, Iron Will, Improved Natural Attack (bite), Lightning Reflexes, Weapon Focus (bite)','{"special_attacks":"Petrifying gaze, smite good","special_qualities":"Resistance to cold 10 and fire 10, damage reduction 10/magic, darkvision 60 ft., low-light vision, spell resistance 23"}'::jsonb,'A basilisk is a reptilian monster that petrifies living creatures with a mere gaze. A basilisk usually has a dull brown body with a yellowish underbelly. Some specimens sport a short, curved horn atop the nose. An adult basilisk’s body grows to about 6 feet long, not including its tail, which can reach an additional length of 5 to 7 feet. The creature weighs about 300 pounds.

### Combat

A basilisk relies on its gaze attack, biting only when opponents come within reach. Though it has eight legs, its slow metabolism renders it relatively sluggish, so it does not expend energy unnecessarily. Intruders who flee a basilisk rather than fight can expect, at best, a halfhearted pursuit. These creatures tend to spend most of their time lying in wait for prey, which includes small mammals, birds, reptiles, and similar creatures.

**Petrifying Gaze (Su):** Turn to stone permanently, range 30 feet; Fortitude DC 13 negates. The save DC is Charisma-based.

**Skills:** \*The basilisk’s dull coloration and its ability to remain motionless for long periods of time grant it a +4 racial bonus on Hide checks in natural settings.

### Abyssal Greater Basilisk

#### Combat

The save DC for the abyssal greater basilisk’s petrifying gaze (DC 21) is adjusted for its greater Hit Dice and higher Charisma score.

An abyssal greater basilisk’s natural weapons are treated as magic weapons for the purpose of overcoming damage reduction.

**Smite Good (Su):** Once per day an abyssal greater basilisk can make a normal melee attack to deal an extra 18 points of damage against a good foe.','{"full_attack":"Bite +25 melee (2d8+10)","environment":"A chaotic evil plane","organization":"Solitary or colony (3–6)","treasure":"Standard","advancement":"—","level_adjustment":"—","statblock":{"hit_dice":"18d10+90 (189 hp)","hit_points":189,"base_attack_grapple":"+18/+29","attack":"Bite +25 melee (2d8+10)","full_attack":"Bite +25 melee (2d8+10)","space_reach":"10 ft./5 ft.","saves":"Fort +18, Ref +12, Will +8","abilities":{"str":"24","dex":"8","con":"21","int":"3","wis":"10","cha":"15"},"skills":"Hide +0*, Listen +10, Spot +10","feats":"Alertness, Blind-Fight, Great Fortitude, Iron Will, Improved Natural Attack (bite), Lightning Reflexes, Weapon Focus (bite)","special_attacks":"Petrifying gaze, smite good","special_qualities":"Resistance to cold 10 and fire 10, damage reduction 10/magic, darkvision 60 ft., low-light vision, spell resistance 23"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('behir','Behir','Behir','8','Huge','Magical Beast','Often neutral','9d10+45 (94 hp)',94,'+1','40 ft. (8 squares), climb 15 ft.','20 (–2 size, +1 Dex, +11 natural), touch 9, flat-footed 19','+9/+25','Bite +15 melee (2d4+12)','15 ft./10 ft.','+11','+7','+5',26,13,21,7,14,12,'Climb +16, Hide +5, Listen +4, Spot +4, Survival +2','Alertness, Cleave, Power Attack, Track','{"special_attacks":"Breath weapon, constrict 2d8+8, improved grab, rake 1d4+4, swallow whole","special_qualities":"Can’t be tripped, darkvision 60 ft., immunity to electricity, low-light vision, scent"}'::jsonb,'The behir is a serpentine monster that can slither like a snake or use its dozen legs to move with considerable speed. A behir is about 40 feet long and weighs about 4,000 pounds. It can fold its limbs close to its long, narrow body and slither in snake fashion if it desires. The coloration of behirs ranges from ultramarine to deep blue with bands of gray-brown. The belly is pale blue. The two large horns curving back over the head look dangerous but are actually used for preening the creature’s scales, not for fighting.

Behirs speak Common.

### Combat

A behir usually bites and grabs its prey first, then either swallows or constricts the opponent. It can employ its claws only against foes caught in its coils. If beset by a large number of foes, it uses its breath weapon.

**Breath Weapon (Su):** 20-foot line, once every 10 rounds, damage 7d6 electricity, Reflex DC 19 half. The save DC is Constitution-based.

**Constrict (Ex):** A behir deals 2d8+8 points of damage with a successful grapple check. It can make six rake attacks against a grappled foe as well.

**Improved Grab (Ex):** To use this ability, a behir must hit a creature of any size with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

If it wins the grapple check, it it establishes a hold and can attempt to constrict the opponent or swallow the opponent in the following round.

**Rake (Ex):** Six claws, attack bonus +15 melee, damage 1d4+4.

**Swallow Whole (Ex):** A behir can try to swallow a grabbed Medium or smaller opponent by making a successful grapple check.

A behir that swallows an opponent can use its Cleave feat to bite and grab another opponent.

A swallowed creature takes 2d8+8 points of bludgeoning damage and 8 points of acid damage per round from the behir’s gizzard. A swallowed creature can cut its way out by using a light slashing or piercing weapon to deal 25 points of damage to the gizzard (AC 15). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out.

A behir’s gizzard can hold 2 Medium, 8 Small, 32 Tiny, or 128 Diminutive or smaller opponents.

**Skills:** Behirs have a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.','{"full_attack":"Bite +15 melee (2d4+12)","environment":"Warm hills","organization":"Solitary or pair","treasure":"Standard","advancement":"10–13 HD (Huge); 14–27 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"9d10+45 (94 hp)","hit_points":94,"base_attack_grapple":"+9/+25","attack":"Bite +15 melee (2d4+12)","full_attack":"Bite +15 melee (2d4+12)","space_reach":"15 ft./10 ft.","saves":"Fort +11, Ref +7, Will +5","abilities":{"str":"26","dex":"13","con":"21","int":"7","wis":"14","cha":"12"},"skills":"Climb +16, Hide +5, Listen +4, Spot +4, Survival +2","feats":"Alertness, Cleave, Power Attack, Track","special_attacks":"Breath weapon, constrict 2d8+8, improved grab, rake 1d4+4, swallow whole","special_qualities":"Can’t be tripped, darkvision 60 ft., immunity to electricity, low-light vision, scent"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('belker','Belker','Belker','6','Large','Elemental (Air, Extraplanar)','Usually neutral evil','7d8+7 (38 hp)',38,'+5','30 ft. (6 squares), fly 50 ft. (perfect)','22 (–1 size, +5 Dex, +8 natural), touch 14, flat-footed 17','+5/+11','Wing +9 melee (1d6+2)','10 ft./10 ft.','+3','+10','+2',14,21,13,6,11,11,'Listen +7, Move Silently +9, Spot +7','Alertness, Multiattack, Weapon Finesse','{"special_attacks":"Smoke claws","special_qualities":"Darkvision 60 ft., elemental traits, smoke form"}'::jsonb,'Belkers are creatures from the Plane of Air. They are composed primarily of smoke. Although undeniably evil, they are very reclusive and usually have no interest in the affairs of others. A belker’s winged shape makes it look distinctly demonic. It is about 7 feet long and weighs about 8 pounds.

Belkers speak Auran.

### Combat

In most cases, a belker fights with its nasty claws and painful bite.

**Smoke Claws (Ex):** A belker in smoke form (see below) can engulf opponents by moving on top of them. It fills the air around one Medium or smaller opponent without provoking an attack of opportunity. The target must succeed on a DC 14 Fortitude save or inhale part of the creature. The save DC is Constitution-based. Smoke inside the victim solidifies into a claw and begins to rip at the surrounding organs, dealing 3d4 points of damage per round. An affected creature can attempt another Fortitude save each subsequent round to cough out the semivaporous menace.

**Smoke Form (Su):** Most of the time a belker is more or less solid, but at will it can assume smoke form. It can switch forms once per round as a free action and can spend up to 20 rounds per day in smoke form. A belker in smoke form can fly at a speed of 50 feet (perfect). The ability is otherwise similar to a _gaseous form_ spell (caster level 7th).

**Skills:** Belkers have a +4 racial bonus on Move Silently checks.','{"full_attack":"2 wings +9 melee (1d6+2) and bite +4 melee (1d4+1) and 2 claws +4 melee (1d3+1)","environment":"Elemental Plane of Air","organization":"Solitary, pair, or clutch (3–4)","treasure":"None","advancement":"8–10 HD (Large); 11–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d8+7 (38 hp)","hit_points":38,"base_attack_grapple":"+5/+11","attack":"Wing +9 melee (1d6+2)","full_attack":"2 wings +9 melee (1d6+2) and bite +4 melee (1d4+1) and 2 claws +4 melee (1d3+1)","space_reach":"10 ft./10 ft.","saves":"Fort +3, Ref +10, Will +2","abilities":{"str":"14","dex":"21","con":"13","int":"6","wis":"11","cha":"11"},"skills":"Listen +7, Move Silently +9, Spot +7","feats":"Alertness, Multiattack, Weapon Finesse","special_attacks":"Smoke claws","special_qualities":"Darkvision 60 ft., elemental traits, smoke form"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('blink_dog','Blink Dog','Blink Dog','2','Medium','Magical Beast','Usually lawful good','4d10 (22 hp)',22,'+3','40 ft. (8 squares)','16 (+3 Dex, +3 natural), touch 13, flat-footed 13','+4/+4','Bite +4 melee (1d6)','5 ft./5 ft.','+4','+7','+4',10,17,10,10,13,11,'Hide +3, Listen +5, Sense Motive +3, Spot +5, Survival +4','Iron Will, Run, TrackB','{"special_attacks":"","special_qualities":"Blink, darkvision 60 ft., dimension door, low-light vision, scent"}'::jsonb,'The blink dog is an intelligent canine that has a limited teleportation ability.

Blink dogs have their own language, a mixture of barks, yaps, whines, and growls that can transmit complex information.

### Combat

Blink dogs hunt in packs, teleporting in a seemingly random fashion until they surround their prey, allowing some of them to take advantage of flanking.

**Blink (Su):** A blink dog can use _blink_ as the spell (caster level 8th), and can evoke or end the effect as a free action.

**Dimension Door (Su):** A blink dog can teleport, as _dimension door_ (caster level 8th), once per round as a free action. The ability affects only the blink dog, which never appears within a solid object and can act immediately after teleporting.','{"full_attack":"Bite +4 melee (1d6)","environment":"Temperate plains","organization":"Solitary, pair, or pack (7–16)","treasure":"None","advancement":"5–7 HD (Medium); 8–12 HD (Large)","level_adjustment":"+2 (cohort)","statblock":{"hit_dice":"4d10 (22 hp)","hit_points":22,"base_attack_grapple":"+4/+4","attack":"Bite +4 melee (1d6)","full_attack":"Bite +4 melee (1d6)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +7, Will +4","abilities":{"str":"10","dex":"17","con":"10","int":"10","wis":"13","cha":"11"},"skills":"Hide +3, Listen +5, Sense Motive +3, Spot +5, Survival +4","feats":"Iron Will, Run, TrackB","special_attacks":"","special_qualities":"Blink, darkvision 60 ft., dimension door, low-light vision, scent"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('bodak','Bodak','Bodak','8','Medium','Undead (Extraplanar)','Always chaotic evil','9d12 (58 hp)',58,'+6','20 ft. (4 squares)','20 (+2 Dex, +8 natural), touch 12, flat-footed 18','+4/+5','Slam +6 melee (1d8+1)','5 ft./5 ft.','+3','+5','+7',13,15,null,6,12,12,'Listen +11, Move Silently +10, Spot +11','Alertness, Dodge, Improved Initiative, Weapon Focus (slam)','{"special_attacks":"Death gaze","special_qualities":"Damage reduction 10/cold iron, darkvision 60 ft., immunity to electricity, resistance to acid 10 and fire 10, undead traits, vulnerability to sunlight"}'::jsonb,'Bodaks are the undead remnants of humanoids who have been destroyed by the touch of absolute evil.

A bodak retains fleeting memories of its past life and can speak Common (or some other humanoid language).

### Combat

**Death Gaze (Su):** Death, range 30 feet, Fortitude DC 15 negates. Humanoids who die from this attack are transformed into bodaks 24 hours later. The save DC is Charisma-based.

**Vulnerability to Sunlight (Ex):** Bodaks loathe sunlight, for its merest touch burns their impure flesh. Each round of exposure to the direct rays of the sun deals 1 point of damage to the creature.','{"full_attack":"Slam +6 melee (1d8+1)","environment":"A chaotic evil-aligned plane","organization":"Solitary or gang (2–4)","treasure":"None","advancement":"10–13 HD (Medium); 14–27 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"9d12 (58 hp)","hit_points":58,"base_attack_grapple":"+4/+5","attack":"Slam +6 melee (1d8+1)","full_attack":"Slam +6 melee (1d8+1)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +5, Will +7","abilities":{"str":"13","dex":"15","con":null,"int":"6","wis":"12","cha":"12"},"skills":"Listen +11, Move Silently +10, Spot +11","feats":"Alertness, Dodge, Improved Initiative, Weapon Focus (slam)","special_attacks":"Death gaze","special_qualities":"Damage reduction 10/cold iron, darkvision 60 ft., immunity to electricity, resistance to acid 10 and fire 10, undead traits, vulnerability to sunlight"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('bralani','Bralani','Bralani','6','Medium','Outsider (Chaotic, Extraplanar, Good)','Always chaotic good','6d8+18 (45 hp)',45,'+8','40 ft. (8 squares), fly 100 ft. (perfect)','20 (+4 Dex, +6 natural), touch 14, flat-footed 16','+6/+10','+1 holy scimitar +11 melee (1d6+4/18–20) or +1 holy composite longbow (+4 Str bonus) +11 ranged (1d8+5/x3) or slam +10 melee (1d6+4)','5 ft./5 ft.','+8','+9','+7',18,18,17,13,14,14,'Concentration +12, Diplomacy +4, Escape Artist +13, Handle Animal +11, Hide +13, Jump +10, Listen +13, Move Silently +13, Ride +6, Sense Motive +11, Spot +13, Tumble +13, Use Rope +4 (+6 with bindings)','Alertness, Blind-Fight, Improved Initiative','{"special_attacks":"Spell-like abilities, whirlwind blast","special_qualities":"Alternate form, damage reduction 10/cold iron or evil, darkvision 60 ft., immunity to electricity and petrification, low-light vision, resistance to cold 10 and fire 10, spell resistance 17, tongues"}'::jsonb,'In addition to their natural form, bralanis can assume the shape of a whirlwind or zephyr of dust, snow, or sand.

Bralanis speak Celestial, Infernal, and Draconic, but can communicate with almost any creature, thanks to their _tongues_ ability.

### Combat

Bralanis prefer the scimitar and bow, the weapons of the desert nomads they most closely resemble.

A bralani’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and good-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** At will— _blur, charm person_ (DC 13), _gust of wind_ (DC 14), _mirror image, wind wall;_ 2/day—_lightning bolt_ (DC 15), _cure serious wounds_ (DC 15). Caster level 6th. The save DCs are Charisma-based.

**Whirlwind Blast (Su):** When in whirlwind form, a bralani can attack with a scouring blast of wind, dealing 3d6 points of damage in a 20-foot line (Reflex DC 16 half ). The save DC is Constitution-based.

**Alternate Form (Su):** A bralani can shift between its humanoid and whirlwind forms as a standard action. In humanoid form, it cannot fly or use its whirlwind blast, but it can use its spell-like abilities and its weapons. In whirlwind form, it can fly, make slam attacks and whirlwind blast attacks, and use spell-like abilities.

A bralani remains in one form until it chooses to assume a new one. A change in form cannot be dispelled, nor does the bralani revert to any particular form when killed. A _true seeing_ spell, however, reveals both forms simultaneously.

**Tongues (Su):** Bralanis can speak with any creature that has a language, as though using a _tongues_ spell (caster level 14th). This ability is always active.','{"full_attack":"+1 holy scimitar +11/+6 melee (1d6+4/18–20) or +1 holy composite longbow (+4 Str bonus) +11/+6 ranged (1d8+5/x3) or slam +10 melee (1d6+4)","environment":"A chaotic good-aligned plane","organization":"Solitary, pair, or squad (3–5)","treasure":"No coins; double goods; standard items","advancement":"7–12 HD (Medium); 13–18 HD (Large)","level_adjustment":"+5","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+6/+10","attack":"+1 holy scimitar +11 melee (1d6+4/18–20) or +1 holy composite longbow (+4 Str bonus) +11 ranged (1d8+5/x3) or slam +10 melee (1d6+4)","full_attack":"+1 holy scimitar +11/+6 melee (1d6+4/18–20) or +1 holy composite longbow (+4 Str bonus) +11/+6 ranged (1d8+5/x3) or slam +10 melee (1d6+4)","space_reach":"5 ft./5 ft.","saves":"Fort +8, Ref +9, Will +7","abilities":{"str":"18","dex":"18","con":"17","int":"13","wis":"14","cha":"14"},"skills":"Concentration +12, Diplomacy +4, Escape Artist +13, Handle Animal +11, Hide +13, Jump +10, Listen +13, Move Silently +13, Ride +6, Sense Motive +11, Spot +13, Tumble +13, Use Rope +4 (+6 with bindings)","feats":"Alertness, Blind-Fight, Improved Initiative","special_attacks":"Spell-like abilities, whirlwind blast","special_qualities":"Alternate form, damage reduction 10/cold iron or evil, darkvision 60 ft., immunity to electricity and petrification, low-light vision, resistance to cold 10 and fire 10, spell resistance 17, tongues"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('bugbear','Bugbear','Bugbear','2','Medium','Humanoid (Goblinoid)','Usually chaotic evil','3d8+3 (16 hp)',16,'+1','30 ft. (6 squares)','17 (+1 Dex, +3 natural, +2 leather armor, +1 light wooden shield), touch 11, flat-footed 16','+2/+4','Morningstar +5 melee (1d8+2) or javelin +3 ranged (1d6+2)','5 ft./5 ft.','+2','+4','+1',15,12,13,10,10,9,'Climb +3, Hide +4, Listen +4, Move Silently +6, Spot +4','Alertness, Weapon Focus (morningstar)','{"special_attacks":"—","special_qualities":"Darkvision 60 ft., scent"}'::jsonb,'Bugbears speak Goblin and Common.

### Combat

Bugbears prefer to ambush opponents whenever possible. When hunting, they normally send scouts ahead of the main group that, if they spy prey, return to report and bring up reinforcements.

Bugbear attacks are coordinated, and their tactics are sound if not brilliant.

**Skills:** Bugbears have a +4 racial bonus on Move Silently checks.

### Bugbears as Characters

Bugbear characters possess the following racial traits.

— +4 Strength, +2 Dexterity, +2 Constitution, –2 Charisma.

—Medium size.

—A bugbear’s base land speed is 30 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: A bugbear begins with three levels of humanoid, which provide 3d8 Hit Dice, a base attack bonus of +2, and base saving throw bonuses of Fort +1, Ref +3, and Will +1.

—Racial Skills: A bugbear’s humanoid levels give it skill points equal to 6 x (2 + Int modifier). Its class skills are Climb, Hide, Listen, Move Silently, Search, and Spot.

—Racial Feats: A bugbear’s humanoid levels give it two feats.

— +3 natural armor bonus.

— +4 racial bonus on Move Silently checks.

—Automatic Languages: Common, Goblin. Bonus Languages: Draconic, Elven, Giant, Gnoll, Orc.

—Favored Class: Rogue.

—Level adjustment +1.','{"full_attack":"Morningstar +5 melee (1d8+2) or javelin +3 ranged (1d6+2)","environment":"Temperate mountains","organization":"Solitary, gang (2–4), or band (11–20 plus 150% noncombatants plus 2 2nd-level sergeants and 1 leader of 2nd–5th level)","treasure":"Standard","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"3d8+3 (16 hp)","hit_points":16,"base_attack_grapple":"+2/+4","attack":"Morningstar +5 melee (1d8+2) or javelin +3 ranged (1d6+2)","full_attack":"Morningstar +5 melee (1d8+2) or javelin +3 ranged (1d6+2)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +4, Will +1","abilities":{"str":"15","dex":"12","con":"13","int":"10","wis":"10","cha":"9"},"skills":"Climb +3, Hide +4, Listen +4, Move Silently +6, Spot +4","feats":"Alertness, Weapon Focus (morningstar)","special_attacks":"—","special_qualities":"Darkvision 60 ft., scent"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('bulette','Bulette','Bulette','7','Huge','Magical Beast','Always neutral','9d10+45 (94 hp)',94,'+2','40 ft. (8 squares), burrow 10 ft.','22 (–2 size, +2 Dex, +12 natural), touch 10, flat-footed 20','+9/+25','Bite +16 melee (2d8+8)','15 ft./10 ft.','+11','+8','+6',27,15,20,2,13,6,'Jump +18, Listen +9, Spot +3','Alertness, Iron Will, Track, Weapon Focus (bite)','{"special_attacks":"Leap","special_qualities":"Darkvision 60 ft., lowlight vision, scent, tremorsense 60 ft."}'::jsonb,'Also known as the landshark, the bulette is a terrifying predator that lives only to eat.

### Combat

A bulette attacks anything it regards as edible, choosing the easiest or closest prey first. The only creatures it refuses to eat are elves (and it dislikes the taste of dwarves). When burrowing underground, a landshark relies on its tremorsense ability to detect prey.

When it senses something edible (that is, senses movement), it breaks to the surface, crest first, and begins its attack.

**Leap (Ex):** A bulette can jump into the air during combat. This allows it to make four claw attacks instead of two, each with a +15 attack bonus, but it cannot bite.','{"full_attack":"Bite +16 melee (2d8+8) and 2 claws +10 melee (2d6+4)","environment":"Temperate hills","organization":"Solitary or pair","treasure":"None","advancement":"10–16 HD (Huge); 17–27 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"9d10+45 (94 hp)","hit_points":94,"base_attack_grapple":"+9/+25","attack":"Bite +16 melee (2d8+8)","full_attack":"Bite +16 melee (2d8+8) and 2 claws +10 melee (2d6+4)","space_reach":"15 ft./10 ft.","saves":"Fort +11, Ref +8, Will +6","abilities":{"str":"27","dex":"15","con":"20","int":"2","wis":"13","cha":"6"},"skills":"Jump +18, Listen +9, Spot +3","feats":"Alertness, Iron Will, Track, Weapon Focus (bite)","special_attacks":"Leap","special_qualities":"Darkvision 60 ft., lowlight vision, scent, tremorsense 60 ft."},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('centaur','Centaur','Centaur','3','Large','Monstrous Humanoid','Usually neutral good','4d8+8 (26 hp)',26,'+2','50 ft. (10 squares)','14 (–1 size, +2 Dex, +3 natural), touch 11, flat-footed 12','+4/+12','Longsword +7 melee (2d6+6/19–20) or composite longbow (+4 Str bonus) +5 ranged (2d6+4/x3)','10 ft./5 ft.','+3','+6','+5',18,14,15,8,13,11,'Listen +3, Move Silently +4, Spot +3, Survival +2','Dodge, Weapon Focus (hoof )','{"special_attacks":"—","special_qualities":"Darkvision 60 ft."}'::jsonb,'A centaur is as big as a heavy horse, but much taller and slightly heavier. A centaur is about 7 feet tall and weighs about 2,100 pounds.

Centaurs speak Sylvan and Elven.

### Combat

A centaur employing a lance deals double damage when it charges, just as a rider on a mount does.

### Centaurs as Characters

A centaur druid is usually a tribe’s designated leader and speaker. Centaur characters possess the following racial traits.

— +8 Strength, +4 Dexterity, +4 Constitution, –2 Intelligence, +2 Wisdom.

—Large size. –1 penalty to Armor Class, –1 penalty on attack rolls, –4 penalty on Hide checks, +4 bonus on grapple checks, lifting and carrying limits double those of Medium characters.

—Space/Reach: 10 feet/5 feet.

—A centaur’s base land speed is 50 feet.

—Darkvision out to 60 feet.

—Racial Hit Dice: A centaur begins with four levels of monstrous humanoid, which provide 4d8 Hit Dice, a base attack bonus of +4, and base saving throw bonuses of Fort +1, Ref +4, and Will +4.

—Racial Skills: A centaur’s monstrous humanoid levels give it skill points equal to 7 x (2 + Int modifier). Its class skills are Listen, Move Silently, Spot, and Survival.

—Racial Feats: A centaur’s monstrous humanoid levels give it two feats.

— +3 natural armor bonus.

— Automatic Languages: Sylvan, Elven. Bonus Languages: Common, Gnome, Halfling.

—Favored Class: Ranger.

—Level adjustment +2.','{"full_attack":"Longsword +7 melee (2d6+6/19–20) and 2 hooves +3 melee (1d6+2); or composite longbow (+4 Str bonus) +5 ranged (2d6+4/x3)","environment":"Temperate forests","organization":"Solitary, company (5–8), troop (8–18 plus 1 leader of 2nd–5th level), or tribe (20–150 plus 30% noncombatants plus 10 3rd-level sergeants, 5 5th-level lieutenants, and 1 leader of 5th–9th level)","treasure":"Standard","advancement":"By character class","level_adjustment":"+2","statblock":{"hit_dice":"4d8+8 (26 hp)","hit_points":26,"base_attack_grapple":"+4/+12","attack":"Longsword +7 melee (2d6+6/19–20) or composite longbow (+4 Str bonus) +5 ranged (2d6+4/x3)","full_attack":"Longsword +7 melee (2d6+6/19–20) and 2 hooves +3 melee (1d6+2); or composite longbow (+4 Str bonus) +5 ranged (2d6+4/x3)","space_reach":"10 ft./5 ft.","saves":"Fort +3, Ref +6, Will +5","abilities":{"str":"18","dex":"14","con":"15","int":"8","wis":"13","cha":"11"},"skills":"Listen +3, Move Silently +4, Spot +3, Survival +2","feats":"Dodge, Weapon Focus (hoof )","special_attacks":"—","special_qualities":"Darkvision 60 ft."},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('chaos_beast','Chaos Beast','Chaos Beast','7','Medium','Outsider (Chaotic, Extraplanar)','Always chaotic neutral','8d8+8 (44 hp)',44,'+5','20 ft. (4 squares)','16 (+1 Dex, +5 natural), touch 11, flat-footed 15','+8/+10','Claw +10 melee (1d3+2 plus corporeal instability)','5 ft./5 ft.','+7','+7','+6',14,13,13,10,10,10,'Climb +13, Escape Artist +12, Hide +12, Jump +9, Listen +11, Search +11, Spot +11, Survival +0 (+2 following tracks), Tumble +14, Use Rope +1 (+3 with bindings)','Dodge, Improved Initiative, Mobility','{"special_attacks":"Corporeal instability","special_qualities":"Darkvision 60 ft., immunity to critical hits and transformation, spell resistance 15"}'::jsonb,'The horrific creatures known as chaos beasts have mutable, ever-changing forms. A chaos beast’s dimensions vary, but it always weighs about 200 pounds.

Chaos beasts do not speak.

### Combat

For all its fearsome appearances, whether it has claws, fangs, pincers, tentacles, or spines, a chaos beast does little physical harm. Regardless of form, the creature seems unable to manage more than two attacks per round. Its continual transmutations prevent the coordination needed to do more.

A chaos beast’s claw attacks, as well as any weapons it wields, are treated as chaotic-aligned for the purpose of overcoming damage reduction.

**Corporeal Instability (Su):** A blow from a chaos beast against a living creature can cause a terrible transformation. The creature must succeed on a DC 15 Fortitude save or become a spongy, amorphous mass. Unless the victim manages to control the effect (see below), its shape melts, flows, writhes, and boils. The save DC is Constitution-based.

An affected creature is unable to hold or use any item. Clothing, armor, rings, and helmets become useless. Large items worn or carried—armor, backpacks, even shirts—hamper more than help, reducing the victim’s Dexterity score by 4. Soft or misshapen feet and legs reduce speed to 10 feet or one-quarter normal, whichever is less. Searing pain courses along the nerves, so strong that the victim cannot act coherently. The victim cannot cast spells or use magic items, and it attacks blindly, unable to distinguish friend from foe (–4 penalty on attack rolls and a 50% miss chance, regardless of the attack roll).

Each round the victim spends in an amorphous state causes 1 point of Wisdom drain from mental shock. If the victim’s Wisdom score falls to 0, it becomes a chaos beast.

A victim can regain its own shape by taking a standard action to attempt a DC 15 Charisma check (this check DC does not vary for a chaos beast with different Hit Dice or ability scores). A success reestablishes the creature’s normal form for 1 minute. On a failure, the victim can still repeat this check each round until successful.

Corporeal instability is not a disease or a curse and so is hard to remove. A _shapechange_ or _stoneskin_ spell does not cure an afflicted creature but fixes its form for the duration of the spell. A _restoration, heal,_ or _greater restoration_ spell removes the affliction (a separate _restoration_ is necessary to restore any drained points of Wisdom).

**Immunity to Transformation (Ex):** No mortal magic can permanently affect or fix a chaos beast’s form. Effects such as polymorphing or petrification force the creature into a new shape, but at the start of its next turn it immediately returns to its mutable form as a free action.','{"full_attack":"2 claws +10 melee (1d3+2 plus corporeal instability)","environment":"Ever-Changing Chaos of Limbo","organization":"Solitary","treasure":"None","advancement":"9–12 HD (Medium); 13–24 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d8+8 (44 hp)","hit_points":44,"base_attack_grapple":"+8/+10","attack":"Claw +10 melee (1d3+2 plus corporeal instability)","full_attack":"2 claws +10 melee (1d3+2 plus corporeal instability)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +7, Will +6","abilities":{"str":"14","dex":"13","con":"13","int":"10","wis":"10","cha":"10"},"skills":"Climb +13, Escape Artist +12, Hide +12, Jump +9, Listen +11, Search +11, Spot +11, Survival +0 (+2 following tracks), Tumble +14, Use Rope +1 (+3 with bindings)","feats":"Dodge, Improved Initiative, Mobility","special_attacks":"Corporeal instability","special_qualities":"Darkvision 60 ft., immunity to critical hits and transformation, spell resistance 15"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('chimera','Chimera','Chimera','7','Large','Magical Beast','Usually chaotic evil','9d10+27 (76 hp)',76,'+1','30 ft. (6 squares), fly 50 ft. (poor)','19 (–1 size, +1 Dex, +9 natural), touch 10, flat-footed 18','+9/+17','Bite +12 melee (2d6+4)','10 ft./5 ft.','+9','+7','+6',19,13,17,4,13,10,'Hide +1*, Listen +9, Spot +9','Alertness, Hover, Iron Will, Multiattack','{"special_attacks":"Breath weapon","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'A chimera is about 5 feet tall at the shoulder, nearly 10 feet long, and weighs about 4,000 pounds. A chimera’s dragon head might be black, blue, green, red, or white.

Chimeras can speak Draconic but seldom bother to do so, except when toadying to more powerful creatures.

### Combat

The chimera prefers to surprise prey. It often swoops down from the sky or lies concealed until it charges. The dragon head can loose a breath weapon instead of biting. Several chimeras attack in concert.

**Breath Weapon (Su):** A chimera’s breath weapon depends on the color of its dragon head, as summarized on the table below. Regardless of its type, a chimera’s breath weapon is usable once every 1d4 rounds, deals 3d8 points of damage, and allows a DC 17 Reflex save for half damage. The save DC is Constitution-based.

To determine a chimera’s head color and breath weapon randomly, roll 1d10 and consult the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>1d10</th><th>Head Color</th><th>Breath Weapon</th></tr><tr><td>1–2</td><td>Black</td><td>40-foot line of acid</td></tr><tr><td>3–4</td><td>Blue</td><td>40-foot line of lightning</td></tr><tr><td>5–6</td><td>Green</td><td>20-foot cone of gas (acid)</td></tr><tr><td>7–8</td><td>Red</td><td>20-foot cone of fire</td></tr><tr><td>9–10</td><td>White</td><td>20-foot cone of cold</td></tr></tbody></table>

**Skills:** A chimera’s three heads give it a +2 racial bonus on Spot and Listen checks.

\*In areas of scrubland or brush, a chimera gains a +4 racial bonus on Hide checks.

**Carrying Capacity:** A light load for a chimera is up to 348 pounds; a medium load, 349–699 pounds, and a heavy load, 700–1,050 pounds.','{"full_attack":"Bite +12 melee (2d6+4) and bite +12 melee (1d8+4) and gore +12 melee (1d8+4) and 2 claws +10 melee (1d6+2)","environment":"Temperate hills","organization":"Solitary, pride (3–5), or flight (6–13)","treasure":"Standard","advancement":"10–13 HD (Large); 14–27 HD (Huge)","level_adjustment":"+2 (cohort)","statblock":{"hit_dice":"9d10+27 (76 hp)","hit_points":76,"base_attack_grapple":"+9/+17","attack":"Bite +12 melee (2d6+4)","full_attack":"Bite +12 melee (2d6+4) and bite +12 melee (1d8+4) and gore +12 melee (1d8+4) and 2 claws +10 melee (1d6+2)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +7, Will +6","abilities":{"str":"19","dex":"13","con":"17","int":"4","wis":"13","cha":"10"},"skills":"Hide +1*, Listen +9, Spot +9","feats":"Alertness, Hover, Iron Will, Multiattack","special_attacks":"Breath weapon","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('choker','Choker','Choker','2','Small','Aberration','Usually chaotic evil','3d8+3 (16 hp)',16,'+6','20 ft. (4 squares), climb 10 ft.','17 (+1 size, +2 Dex, +4 natural), touch 13, flat-footed 15','+2/+5','Tentacle +6 melee (1d3+3)','5 ft./10 ft.','+2','+5','+4',16,14,13,4,13,7,'Climb +13, Hide +10, Move Silently +6','Improved InitiativeB, Lightning Reflexes, Stealthy','{"special_attacks":"Improved grab, constrict 1d3+3","special_qualities":"Darkvision 60 ft., quickness"}'::jsonb,'These vicious little predators lurk underground, grabbing whatever prey happens by. Its hands and feet have spiny pads that help the choker grip almost any surface. The creature weighs about 35 pounds.

Chokers speak Undercommon.

### Combat

A choker likes to perch near the ceiling, often at intersections, archways, wells, or staircases, and reach down to attack its prey. A choker attacks creatures of almost any size, but prefers lone prey of its size or larger. If one is very hungry, it may attack a group, but it waits to grab the last creature in line.

**Constrict (Ex):** A choker deals 1d3+3 points of damage with a successful grapple check against a Large or smaller creature. Because it seizes its victim by the neck, a creature in the choker’s grasp cannot speak or cast spells with verbal components.

**Improved Grab (Ex):** To use this ability, a choker must hit a Large or smaller opponent with a tentacle attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict. Chokers receive a +4 racial bonus on grapple checks, which is already included in the statistics block.

**Quickness (Su):** Although not particularly dexterous, a choker is supernaturally quick. It can take an extra standard action or move action during its turn each round.

**Skills:** A chokers has a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.','{"full_attack":"2 tentacles +6 melee (1d3+3)","environment":"Underground","organization":"Solitary","treasure":"1/10 coins; 50% goods; 50% items","advancement":"4–6 HD (Small); 7–12 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"3d8+3 (16 hp)","hit_points":16,"base_attack_grapple":"+2/+5","attack":"Tentacle +6 melee (1d3+3)","full_attack":"2 tentacles +6 melee (1d3+3)","space_reach":"5 ft./10 ft.","saves":"Fort +2, Ref +5, Will +4","abilities":{"str":"16","dex":"14","con":"13","int":"4","wis":"13","cha":"7"},"skills":"Climb +13, Hide +10, Move Silently +6","feats":"Improved InitiativeB, Lightning Reflexes, Stealthy","special_attacks":"Improved grab, constrict 1d3+3","special_qualities":"Darkvision 60 ft., quickness"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('chuul','Chuul','Chuul','7','Large','Aberration (Aquatic)','Usually chaotic evil','11d8+44 (93 hp)',93,'+7','30 ft. (6 squares), swim 20 ft.','22 (–1 size, +3 Dex, +10 natural), touch 12, flat-footed 19','+8/+17','Claw +12 melee (2d6+5)','10 ft./5 ft.','+7','+6','+9',20,16,18,10,14,5,'Hide +13, Listen +11, Spot +11, Swim +13','Alertness, Blind-Fight,Combat Reflexes, Improved Initiative','{"special_attacks":"Constrict 3d6+5, improved grab, paralytic tentacles","special_qualities":"Amphibious, darkvision 60 ft., immunity to poison"}'::jsonb,'A horrible mix of crustacean, insect, and serpent, the chuul is an abomination that lurks submerged or partially submerged, awaiting intelligent prey to devour. Although amphibious, chuuls are not good swimmers and actually prefer to be on land or in very shallow water when they attack. A chuul is about 8 feet long and weighs 650 pounds.

Chuuls speak Common (or Undercommon, for the underground variety).

### Combat

A chuul prefers to wait by the shore, submerged in murky water, until it hears nearby prey (in or out of the water) that it can attack with surprise. A chuul grabs with its claws and constricts its foe, then passes the opponent to its paralytic tentacles. It tries to always have one claw free, so if it faces a large number of opponents, it drops a paralyzed or dead victim and continues attempting to grab, constrict, and paralyze the rest.

**Constrict (Ex):** On a successful grapple check, a chuul deals 3d6+5 points of damage.

**Improved Grab (Ex):** To use this ability, a chuul must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict or on its next turn transfer a grabbed opponent to its tentacles.

**Paralytic Tentacles (Ex):** A chuul can transfer grabbed victims from a claw to its ten- tacles as a move action. The tentacles grapple with the same strength as the claw but deal no damage. However, they exude a paralytic secretion. Anyone held in the tentacles must succeed on a DC 19 Fortitude save each round on the chuul’s turn or be paralyzed for 6 rounds. The save DC is Constitution-based. While held in the tentacles, paralyzed or not, a victim automatically takes 1d8+2 points of damage each round from the creature’s mandibles.

**Amphibious (Ex):** Although chuuls are aquatic, they can survive indefinitely on land.

**Skills:** A chuul has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered. It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"2 claws +12 melee (2d6+5)","environment":"Temperate marshes","organization":"Solitary, pair, or pack (3–5)","treasure":"1/10th coins; 50% goods; standard items","advancement":"12–16 HD (Large); 17–33 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"11d8+44 (93 hp)","hit_points":93,"base_attack_grapple":"+8/+17","attack":"Claw +12 melee (2d6+5)","full_attack":"2 claws +12 melee (2d6+5)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +6, Will +9","abilities":{"str":"20","dex":"16","con":"18","int":"10","wis":"14","cha":"5"},"skills":"Hide +13, Listen +11, Spot +11, Swim +13","feats":"Alertness, Blind-Fight,Combat Reflexes, Improved Initiative","special_attacks":"Constrict 3d6+5, improved grab, paralytic tentacles","special_qualities":"Amphibious, darkvision 60 ft., immunity to poison"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('cloaker','Cloaker','Cloaker','5','Large','Aberration','Usually chaotic neutral','6d8+18 (45 hp)',45,'+7','10 ft. (2 squares), fly 40 ft. (average)','19 (–1 size, +3 Dex, +7 natural), touch 12, flat-footed 16','+4/+13','Tail slap +8 melee (1d6+5)','10 ft./10 ft. (5 ft. with bite)','+5','+5','+7',21,16,17,14,15,15,'Hide +8, Listen +13, Move Silently +12, Spot +13','Alertness, Combat Reflexes, Improved Initiative','{"special_attacks":"Moan, engulf","special_qualities":"Darkvision 60 ft., shadow shift"}'::jsonb,'When resting or lying in wait, these creatures are almost impossible to distinguish from common black cloaks (the cloaker’s ivory claws look very much like bone clasps). Only when it unfurls does the horrific nature of the creature become apparent.

A cloaker has a wingspan of about 8 feet. It weighs about 100 pounds.

Cloakers speak Undercommon.

### Combat

Cloakers usually lie still, watching and listening for prey. If facing a single opponent, a cloaker uses its engulf attack. Against multiple foes, it lashes with its tail in concert with its moan and shadow shift abilities to reduce the opposition’s numbers, then engulfs a survivor. Multiple cloakers usually split up, leaving one or two behind to use special abilities while the rest make melee attacks.

**Moan (Ex):** A cloaker can emit a dangerous subsonic moan as a standard action. By changing the frequency, the cloaker can cause one of four effects. Cloakers are immune to these sonic, mindaffecting attacks. Unless otherwise specified, a creature that successfully saves against one of these effects cannot be affected by the same moan effect from the same cloaker for 24 hours. All save DCs for moan effects are Charisma-based.

_Unnerve:_ Anyone within a 60-foot spread automatically takes a –2 penalty on attack and damage rolls. Those forced to hear the moan for more than 6 consecutive rounds must succeed on a DC 15 Will save or enter a trance, unable to attack or defend themselves until the moaning stops.

_Fear:_ Anyone within a 30-foot spread must succeed on a DC 15 Will save or become panicked for 2 rounds.

_Nausea:_ Anyone in a 30-foot cone must succeed on a DC 15 Fortitude save or be overcome by nausea and weakness.

Affected characters fall prone and become nauseated for 1d4+1 rounds.

_Stupor:_ A single creature within 30 feet of the cloaker must succeed on a DC 15 Fortitude save or be affected as though by a _hold monster_ spell for 5 rounds. Even after a successful save, the creature must repeat the save if the cloaker uses this effect again.

**Engulf (Ex):** A cloaker can try to wrap a Medium or smaller creature in its body as a standard action. The cloaker attempts a grapple that does not provoke an attack of opportunity. If it wins the grapple check, it establishes a hold and bites the engulfed victim with a +4 bonus on its attack roll. It can still use its whiplike tail to strike at other targets.

Attacks that hit an engulfing cloaker deal half their damage to the monster and half to the trapped victim.

**Shadow Shift (Su):** A cloaker can manipulate shadows. This ability is effective only in shadowy areas and has three possible effects.

_Obscure Vision:_ The cloaker gains concealment (20% miss chance) for 1d4 rounds.

_Dancing Images:_ This effect duplicates a _mirror image_ spell (caster level 6th).

_Silent Image:_ This effect duplicates a _silent image_ spell (DC 15, caster level 6th). The save DC is Charisma-based.','{"full_attack":"Tail slap +8 melee (1d6+5) and bite +3 melee (1d4+2)","environment":"Underground","organization":"Solitary, mob (3–6), or flock (7–12)","treasure":"Standard","advancement":"7–9 HD (Large); 10–18 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+4/+13","attack":"Tail slap +8 melee (1d6+5)","full_attack":"Tail slap +8 melee (1d6+5) and bite +3 melee (1d4+2)","space_reach":"10 ft./10 ft. (5 ft. with bite)","saves":"Fort +5, Ref +5, Will +7","abilities":{"str":"21","dex":"16","con":"17","int":"14","wis":"15","cha":"15"},"skills":"Hide +8, Listen +13, Move Silently +12, Spot +13","feats":"Alertness, Combat Reflexes, Improved Initiative","special_attacks":"Moan, engulf","special_qualities":"Darkvision 60 ft., shadow shift"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('cockatrice','Cockatrice','Cockatrice','3','Small','Magical Beast','Always neutral','5d10 (27 hp)',27,'+3','20 ft. (4 squares), fly 60 ft. (poor)','14 (+1 size, +3 Dex), touch 14, flat-footed 11','+5/–1','Bite +9 melee (1d4–2 plus petrification)','5 ft./5 ft.','+4','+7','+2',6,17,11,2,13,9,'Listen +7, Spot +7','Alertness, Dodge, Weapon FinesseB','{"special_attacks":"Petrification","special_qualities":"Darkvision 60 ft., low-light vision"}'::jsonb,'A male cockatrice has wattles and a comb, just like a rooster. Females, much rarer than males, differ only in that they have no wattles or comb. A cockatrice weighs about 25 pounds.

### Combat

A cockatrice fiercely attacks anything that it deems a threat to itself or its lair. Flocks of cockatrices do their utmost to overwhelm and confuse their foes, and sometimes fly directly into their opponents’ faces.

**Petrification (Su):** Creatures hit by a cockatrice’s bite attack must succeed on a DC 12 Fortitude save or instantly turn to stone. The save DC is Constitution-based. Cockatrices have immunity to the petrification ability of other cockatrices, but other petrification attacks affect them normally.','{"full_attack":"Bite +9 melee (1d4–2 plus petrification)","environment":"Temperate plains","organization":"Solitary, pair, flight (3–5), or flock (6–13)","treasure":"None","advancement":"6–8 HD (Small); 9–15 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"5d10 (27 hp)","hit_points":27,"base_attack_grapple":"+5/–1","attack":"Bite +9 melee (1d4–2 plus petrification)","full_attack":"Bite +9 melee (1d4–2 plus petrification)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +7, Will +2","abilities":{"str":"6","dex":"17","con":"11","int":"2","wis":"13","cha":"9"},"skills":"Listen +7, Spot +7","feats":"Alertness, Dodge, Weapon FinesseB","special_attacks":"Petrification","special_qualities":"Darkvision 60 ft., low-light vision"},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('couatl','Couatl','Couatl','10','Large','Outsider (Native)','Always lawful good','9d8+18 (58 hp)',58,'+7','20 ft. (4 squares), fly 60 ft. (good)','21 (–1 size, +3 Dex, +9 natural), touch 12, flat-footed 18','+9/+17','Bite +12 melee (1d3+6 plus poison)','10 ft./5 ft.','+8','+9','+10',18,16,14,17,19,17,'Concentration +14, Diplomacy +17, Jump +0, Knowledge (any two) +15, Listen +16, Search +15, Sense Motive +16, Spellcraft +15 (+17 scrolls), Spot +16, Survival +4 (+6 following tracks), Tumble +15, Use Magic Device +15 (+17 scrolls)','Dodge, Empower Spell, Eschew MaterialsB, Hover, Improved Initiative','{"special_attacks":"Constrict 2d8+6, improved grab, poison, psionics, spells","special_qualities":"Darkvision 60 ft., ethereal jaunt, telepathy 90 ft."}'::jsonb,'A couatl is about 12 feet long, with a wingspan of about 15 feet. It weighs about 1,800 pounds.

Couatls speak Celestial, Common, and Draconic, and also have the power of telepathy (see below).

### Combat

A couatl uses its _detect thoughts_ ability on any creature that arouses its suspicions. Since it is highly intelligent, a couatl usually casts spells from a distance before closing. If more than one couatl is involved, they discuss their strategy before a battle.

**Constrict (Ex):** A couatl deals 2d8+6 points of damage with a successful grapple check.

**Improved Grab (Ex):** To use this ability, a couatl must hit a creature of up to two size categories larger with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can constrict.

**Poison (Ex):** Injury, Fortitude DC 16, initial damage 2d4 Str, secondary damage 4d4 Str.

The save DC is Constitution-based.

**Psionics (Sp):** At will—_detect chaos, detect evil, detect good, detect law, detect thoughts_ (DC 15), _invisibility, plane shift_ (DC 20), _polymorph_ (self only). Effective caster level 9th. The save DCs are Charisma-based.

**Spells:** A couatl casts spells as a 9th-level sorcerer.

It can choose its spells known from the sorcerer list, the cleric list, and from the lists for the Air, Good, and Law domains. The cleric spells and domain spells are considered arcane spells for a couatl, meaning that the creature does not need a divine focus to cast them.

_Typical Spells Known_ (6/7/7/7/4; save DC 13 + spell level): 0—_cure minor wounds, daze, disrupt undead, light, obscuring mist, ray of frost, read magic, resistance;_ 1st—_endure elements, mage armor, protection from chaos, true strike, wind wall;_ 2nd—_cure moderate wounds, eagle’s splendor, scorching ray, silence;_ 3rd—_gaseous form, magic circle against evil, summon monster III;_ 4th— _charm monster, freedom of movement._

**Ethereal Jaunt (Su):** This ability works like the _ethereal jaunt_ spell (caster level 16th).

**Telepathy (Su):** A couatl can communicate telepathically with any creature within 90 feet that has an Intelligence score. The creature can respond to the couatl if it wishes—no common language is needed.','{"full_attack":"Bite +12 melee (1d3+6 plus poison)","environment":"Warm forests","organization":"Solitary, pair, or flight (3–6)","treasure":"Standard","advancement":"10–13 HD (Large); 14–27 HD (Huge)","level_adjustment":"+7","statblock":{"hit_dice":"9d8+18 (58 hp)","hit_points":58,"base_attack_grapple":"+9/+17","attack":"Bite +12 melee (1d3+6 plus poison)","full_attack":"Bite +12 melee (1d3+6 plus poison)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +9, Will +10","abilities":{"str":"18","dex":"16","con":"14","int":"17","wis":"19","cha":"17"},"skills":"Concentration +14, Diplomacy +17, Jump +0, Knowledge (any two) +15, Listen +16, Search +15, Sense Motive +16, Spellcraft +15 (+17 scrolls), Spot +16, Survival +4 (+6 following tracks), Tumble +15, Use Magic Device +15 (+17 scrolls)","feats":"Dodge, Empower Spell, Eschew MaterialsB, Hover, Improved Initiative","special_attacks":"Constrict 2d8+6, improved grab, poison, psionics, spells","special_qualities":"Darkvision 60 ft., ethereal jaunt, telepathy 90 ft."},"source_file":"monsters-b-c.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-b-c.html',true),
('darkmantle','Darkmantle','Darkmantle','1','Small','Magical Beast','Always neutral','1d10+1 (6 hp)',6,'+4','20 ft. (4 squares), fly 30 ft. (poor)','17 (+1 size, +6 natural), touch 11, flat-footed 17','+1/+0','Slam +5 melee (1d4+4)','5 ft./5 ft.','+3','+2','+0',16,10,13,2,10,10,'Hide +10, Listen +5*, Spot +5*','Improved Initiative','{"special_attacks":"Darkness, improved grab, constrict 1d4+4","special_qualities":"Blindsight 90 ft."}'::jsonb,'The darkmantle hangs from a ceiling by a muscular “foot” at the top of its body. It can look like a stalactite, by holding its tentacles stiffly under itself, or like a lump of rock, spreading its tentacles so the membrane between them covers its body. Its shell and skin usually resemble limestone, but a darkmantle can change its color to match almost any type of stony background.

A darkmantle is about 4 feet long from the tips of its tentacles to the top of its head. It weighs about 30 pounds.

### Combat

A darkmantle attacks by dropping onto its prey and wrapping its tentacles around the opponent’s head. Once attached, it squeezes and tries to suffocate the foe. A darkmantle that misses its initial attack often flies up and tries to drop on the opponent again.

**Darkness (Su):** Once per day a darkmantle can cause darkness as the _darkness_ spell (caster level 5th). It most often uses this ability just before attacking.

**Improved Grab (Ex):** To use this ability, a darkmantle must hit a Large or smaller creature with its slam attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

If it wins the grapple check, it attaches to the opponent’s head and can constrict.

**Constrict (Ex):** A darkmantle deals 1d4+4 points of damage with a successful grapple check.

**Blindsight (Ex):** A darkmantle can “see” by emitting high-frequency sounds, inaudible to most other creatures, that allows it to ascertain objects and creatures within 90 feet. A _silence_ spell negates this ability and effectively blinds the darkmantle.

**Skills:** A darkmantle has a +4 racial bonus on Listen and Spot checks.

These bonuses are lost if its blindsight is negated. The creature’s variable coloration gives it a +4 racial bonus on Hide checks.','{"full_attack":"Slam +5 melee (1d4+4)","environment":"Underground","organization":"Solitary, pair, clutch (3–9), or swarm (6–15)","treasure":"None","advancement":"2–3 HD (Small)","level_adjustment":"—","statblock":{"hit_dice":"1d10+1 (6 hp)","hit_points":6,"base_attack_grapple":"+1/+0","attack":"Slam +5 melee (1d4+4)","full_attack":"Slam +5 melee (1d4+4)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +2, Will +0","abilities":{"str":"16","dex":"10","con":"13","int":"2","wis":"10","cha":"10"},"skills":"Hide +10, Listen +5*, Spot +5*","feats":"Improved Initiative","special_attacks":"Darkness, improved grab, constrict 1d4+4","special_qualities":"Blindsight 90 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('delver','Delver','Delver','9','Huge','Aberration','Usually neutral','15d8+78 (145 hp)',145,'+5','30 ft. (6 squares), burrow 10 ft.','24 (–2 size, +1 Dex, +15 natural), touch 9, flat-footed 23','+11/+27','Slam +17 melee (1d6+8 plus 2d6 acid)','15 ft./10 ft.','+12','+6','+11',27,13,21,14,14,12,'Knowledge (dungeoneering) +14, Knowledge (nature) +4, Listen +20, Move Silently +17, Spot +20, Survival +14 (+16 underground)','Alertness, Blind-Fight, Great Fortitude, Improved Initiative, Power Attack, Toughness','{"special_attacks":"Corrosive slime","special_qualities":"Darkvision 60 ft., immunity to acid, stone shape, tremorsense 60 ft."}'::jsonb,'A delver is about 15 feet long and 10 feet wide. It weighs about 6,000 pounds.

Delvers speak Terran and Undercommon.

### Combat

A delver prefers to fight from its tunnel, which it uses to protect its flanks while lashing out with its flippers.

A delver expecting trouble may honeycomb an area with tunnels, leaving most closed with layers of stone 1 or 2 inches thick.

The delver can quickly dissolve the stone cover and pop up to attack unexpectedly.

**Corrosive Slime (Ex):** A delver produces a mucuslike slime that contains a highly corrosive substance. The slime is particularly effective against stone. A delver’s mere touch deals 2d6 points of acid damage to organic creatures or objects. Against metallic creatures or objects, a delver’s slime deals 4d8 points of damage, and against stony creatures (including earth elementals) or objects it deals 8d10 points of damage. A slam attack by a delver leaves a patch of slime that deals 2d6 points of damage on contact and another 2d6 points of damage in each of the next 2 rounds. A large quantity (at least a quart) of water or weak acid, such as vinegar, washes off the slime. An opponent’s armor and clothing dissolve and become useless immediately unless the wearer succeeds on a DC 22 Reflex save. Weapons that strike a delver also dissolve immediately unless the wielder succeeds on a DC 22 Reflex save. A creature attacking a delver with natural weapons takes damage from its slime each time an attack hits unless the creature succeeds on a DC 22 Reflex save. These save DCs are Constitution-based.

**Stone Shape (Ex):** A delver can alter its slime to temporarily soften stone instead of dissolving it. Once every 10 minutes, a delver can soften and shape up to 25 cubic feet of stone, as a _stone shape_ spell (caster level 15th).','{"full_attack":"2 slams +17 melee (1d6+8 plus 2d6 acid)","environment":"Underground","organization":"Solitary","treasure":"None","advancement":"16–30 HD (Huge); 31–45 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"15d8+78 (145 hp)","hit_points":145,"base_attack_grapple":"+11/+27","attack":"Slam +17 melee (1d6+8 plus 2d6 acid)","full_attack":"2 slams +17 melee (1d6+8 plus 2d6 acid)","space_reach":"15 ft./10 ft.","saves":"Fort +12, Ref +6, Will +11","abilities":{"str":"27","dex":"13","con":"21","int":"14","wis":"14","cha":"12"},"skills":"Knowledge (dungeoneering) +14, Knowledge (nature) +4, Listen +20, Move Silently +17, Spot +20, Survival +14 (+16 underground)","feats":"Alertness, Blind-Fight, Great Fortitude, Improved Initiative, Power Attack, Toughness","special_attacks":"Corrosive slime","special_qualities":"Darkvision 60 ft., immunity to acid, stone shape, tremorsense 60 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('babau','Babau','Babau','6','Medium','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','7d8+35 (66 hp)',66,'+1','30 ft. (6 squares)','19 (+1 Dex, +8 natural), touch 11, flat-footed 18','+7/+12','Claw +12 melee (1d6+5)','5 ft./5 ft.','+10','+6','+6',21,12,20,14,13,16,'Climb +15, Disable Device +12, Disguise +13, Escape Artist +11, Hide +19, Listen +19, Move Silently +19, Open Lock +11, Search +20, Sleight of Hand +11, Survival +1 (+3 following tracks), Use Rope +1 (+3 with bindings)','Cleave, Multiattack, Power Attack','{"special_attacks":"Sneak attack +2d6, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/cold iron or good, darkvision 60 ft., immunity to electricity and poison, protective slime, resistance to acid 10, cold 10, and fire 10, spell resistance 14, telepathy 100 ft."}'::jsonb,'A babau is about 6 feet tall and weighs about 140 pounds.

#### Combat

Babaus are sneaky and sly. They attack the most powerful foe first, hoping to eliminate the true threats quickly and then toy with the rest. When ambushing their opponents, they make excellent use of the combination of multiple attacks and sneak attacks.

A babau’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Sneak Attack (Ex):** A babau can make a sneak attack like a rogue, dealing an extra 2d6 points of damage whenever a foe is denied his or her Dexterity bonus, or when the babau is flanking.

**Spell-Like Abilities:** At will—_darkness, dispel magic, see invisibility_, _greater teleport_ (self plus 50 pounds of objects only). Caster level 7th.

**Protective Slime (Su):** A slimy red jelly coats the babau’s skin. Any weapon that touches it takes 1d8 points of acid damage from the corrosive goo, and the weapon’s hardness does not reduce this damage. A magic weapon may attempt a DC 18 Reflex save to avoid taking this damage. A creature who strikes the babau with an unarmed attack, unarmed strike, touch spell, or natural weapon takes this damage as well but can negate the damage with a DC 18 Reflex save. The save DCs are Constitution-based.

**_Summon Demon_ (Sp):** Once per day a babau can attempt to summon 1 babau with a 40% chance of success. This ability is the equivalent of a 3rd-level spell.

**Skills:** Babaus have a +8 racial bonus on Hide, Listen, Move Silently, and Search checks.','{"full_attack":"2 claws +12 melee (1d6+5) and bite +7 melee (1d6+2)","environment":"A chaotic evil-aligned plane","organization":"Solitary or gang (3–6)","treasure":"Standard","advancement":"8–14 HD (Large); 15–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d8+35 (66 hp)","hit_points":66,"base_attack_grapple":"+7/+12","attack":"Claw +12 melee (1d6+5)","full_attack":"2 claws +12 melee (1d6+5) and bite +7 melee (1d6+2)","space_reach":"5 ft./5 ft.","saves":"Fort +10, Ref +6, Will +6","abilities":{"str":"21","dex":"12","con":"20","int":"14","wis":"13","cha":"16"},"skills":"Climb +15, Disable Device +12, Disguise +13, Escape Artist +11, Hide +19, Listen +19, Move Silently +19, Open Lock +11, Search +20, Sleight of Hand +11, Survival +1 (+3 following tracks), Use Rope +1 (+3 with bindings)","feats":"Cleave, Multiattack, Power Attack","special_attacks":"Sneak attack +2d6, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/cold iron or good, darkvision 60 ft., immunity to electricity and poison, protective slime, resistance to acid 10, cold 10, and fire 10, spell resistance 14, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('balor','Balor','Balor','20','Large','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','20d8+200 (290 hp)',290,'+11','40 ft. (8 squares), fly 90 ft. (good)','35 (–1 size, +7 Dex, +19 natural), touch 16, flat-footed 28','+20/+36','+1 vorpal longsword +33 melee (2d6+8/19–20)','10 ft./10 ft. (20 ft. with +1 flaming whip)','+22','+19','+19',35,25,31,24,24,26,'Bluff +31, Concentration +33, Diplomacy +35, Disguise +8 (+10 acting), Hide +26, Intimidate +33, Knowledge (any two) +30, Listen +38, Move Silently +30, Search +30, Sense Motive +30, Spellcraft +30 (+32 scrolls), Spot +38, Survival +7 (+9 following tracks), Use Magic Device +31 (+33 scrolls)','Cleave, Improved Initiative, Improved Two-Weapon Fighting, Power Attack, Quicken Spell-Like Ability (telekinesis), Two-Weapon Fighting, Weapon Focus (longsword)','{"special_attacks":"Death throes, entangle, spell-like abilities, summon demon, vorpal sword","special_qualities":"Damage reduction 15/cold iron and good, darkvision 60 ft., flaming body, immunity to electricity, fire, and poison, resistance to acid 10 and cold 10, spell resistance 28, telepathy 100 ft., true seeing"}'::jsonb,'A balor stands about 12 feet tall. Its skin is usually dark red. It weighs about 4,500 pounds.

#### Combat

Balors love to join battle armed with their swords and whips. If they face stiff resistance, they may teleport away to loose a few spell-like effects at the foe.

A balor’s _+1 flaming whip_ is a long, flexible weapon with many tails tipped with hooks, spikes, and balls. The weapon deals bludgeoning and slashing damage, in addition to fire damage.

A balor’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Death Throes (Ex):** When killed, a balor explodes in a blinding flash of light that deals 100 points of damage to anything within 100 feet (Reflex DC 30 half ). This explosion automatically destroys any weapons the balor is holding. The save DC is Constitution-based.

**Entangle (Ex):** A balor’s _+1 flaming whip_ entangles foes much like an attack with a net. The whip has 20 hit points. The whip needs no folding. If it hits, the target and the balor immediately make opposed Strength checks; if the balor wins, it drags the target against its flaming body (see below). The target remains anchored against the balor’s body until it escapes the whip.

**Spell-Like Abilities:** At will— _blasphemy_ (DC 25), _dominate monster_ (DC 27), _greater dispel magic, greater teleport_ (self plus 50 pounds of objects only), _insanity_ (DC 25), _power word stun, telekinesis_ (DC 23), _unholy aura_ (DC 26); 1/day—_fire storm_ (DC 26), _implosion_ (DC 27). Caster level 20th. The save DCs are Charisma-based.

**Vorpal Sword (Su):** Every balor carries a _+1 vorpal longsword_ that looks like a flame or a bolt of lightning.

**_Summon Demon_ (Sp):** Once per day a balor can automatically summon 4d10 dretches, 1d4 hezrous, or one nalfeshnee, glabrezu, marilith, or balor. This ability is the equivalent of a 9th-level spell.

**Flaming Body (Su):** The body of a balor is wreathed in flame.

Anyone grappling a balor takes 6d6 points of fire damage each round.

**True Seeing (Su):** Balors have a continuous true seeing ability, as the spell (caster level 20th).

**Skills:** Balors have a +8 racial bonus on Listen and Spot checks.

#### Tactics Round-by-Round

The balor is most effective as a ranged combatant, using its spell-like abilities to attack from a distance.

_Prior to combat: Unholy aura._

_Round 1: Fire storm_ or _implosion_ and quickened _telekinesis,_ or summon additional demons. If the balor does not deem itself seriously threatened, it conserves abilities usable only once per day and uses _blasphemy_ instead.

_Round 2: Insanity_ or _power word stun._

_Round 3:_ Full melee attack with weapons, including entangle with whip.

_Round 4: Teleport_ or fly away with entangled foe to reestablish range; repeat round 1 and continue.

A balor who wants to drive off or neutralize a party without slaying its foes avoids lethal attacks.

_Prior to combat: Unholy aura._

_Round 1: Dominate monster._

_Round 2: Power word stun._

_Round 3: Insanity_ or _telekinesis_ to incapacitate or repel a dangerous opponent.

_Round 4: Teleport_ or fly away to reestablish range; repeat round 1 and continue.','{"full_attack":"+1 vorpal longsword +31/+26/+21/+16 melee (2d6+8/19–20) and +1 flaming whip +30/+25 melee (1d4+4 plus 1d6 fire plus entangle); or 2 slams +31 melee (1d10+7)","environment":"A chaotic evil-aligned plane","organization":"Solitary or troupe (1 balor, 1 marilith, and 2–5 hezrous)","treasure":"Standard coins; double goods; standard items, plus +1 vorpal greatsword and +1 flaming whip","advancement":"21–30 HD (Large); 31–60 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"20d8+200 (290 hp)","hit_points":290,"base_attack_grapple":"+20/+36","attack":"+1 vorpal longsword +33 melee (2d6+8/19–20)","full_attack":"+1 vorpal longsword +31/+26/+21/+16 melee (2d6+8/19–20) and +1 flaming whip +30/+25 melee (1d4+4 plus 1d6 fire plus entangle); or 2 slams +31 melee (1d10+7)","space_reach":"10 ft./10 ft. (20 ft. with +1 flaming whip)","saves":"Fort +22, Ref +19, Will +19","abilities":{"str":"35","dex":"25","con":"31","int":"24","wis":"24","cha":"26"},"skills":"Bluff +31, Concentration +33, Diplomacy +35, Disguise +8 (+10 acting), Hide +26, Intimidate +33, Knowledge (any two) +30, Listen +38, Move Silently +30, Search +30, Sense Motive +30, Spellcraft +30 (+32 scrolls), Spot +38, Survival +7 (+9 following tracks), Use Magic Device +31 (+33 scrolls)","feats":"Cleave, Improved Initiative, Improved Two-Weapon Fighting, Power Attack, Quicken Spell-Like Ability (telekinesis), Two-Weapon Fighting, Weapon Focus (longsword)","special_attacks":"Death throes, entangle, spell-like abilities, summon demon, vorpal sword","special_qualities":"Damage reduction 15/cold iron and good, darkvision 60 ft., flaming body, immunity to electricity, fire, and poison, resistance to acid 10 and cold 10, spell resistance 28, telepathy 100 ft., true seeing"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('bebilith','Bebilith','Bebilith','10','Huge','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','12d8+96 (150 hp)',150,'+5','40 ft. (8 squares), climb 20 ft.','22 (–2 size, +1 Dex, +13 natural), touch 9, flat-footed 21','+12/+29','Bite +19 melee (2d6+9 plus poison) or web +11 ranged','15 ft./10 ft.','+16','+9','+9',28,12,26,11,13,13,'Climb +24, Diplomacy +3, Hide +16, Jump +28, Listen +16, Move Silently +16, Search +15, Sense Motive +16, Spot +16, Survival +1 (+3 following tracks)','Cleave, Improved Initiative, Improved Grapple, Power Attack, Track','{"special_attacks":"Poison, rend armor, web","special_qualities":"Damage reduction 10/good, darkvision 60 ft., plane shift, scent, telepathy 100 ft."}'::jsonb,'Bebiliths are enormous, predatory, arachnid demons that hunt other demons. A bebilith has a body the size of a plow horse, with legs spanning more than 14 feet. It weighs more than two tons.

Bebiliths understand but do not speak Abyssal. Their telepathy allows them to communicate silently with one another.','{"full_attack":"Bite +19 melee (2d6+9 plus poison) and 2 claws +14 melee (2d4+4); or web +11 ranged","environment":"A chaotic evil-aligned plane","organization":"Solitary","treasure":"None","advancement":"13–18 HD (Huge); 19–36 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"12d8+96 (150 hp)","hit_points":150,"base_attack_grapple":"+12/+29","attack":"Bite +19 melee (2d6+9 plus poison) or web +11 ranged","full_attack":"Bite +19 melee (2d6+9 plus poison) and 2 claws +14 melee (2d4+4); or web +11 ranged","space_reach":"15 ft./10 ft.","saves":"Fort +16, Ref +9, Will +9","abilities":{"str":"28","dex":"12","con":"26","int":"11","wis":"13","cha":"13"},"skills":"Climb +24, Diplomacy +3, Hide +16, Jump +28, Listen +16, Move Silently +16, Search +15, Sense Motive +16, Spot +16, Survival +1 (+3 following tracks)","feats":"Cleave, Improved Initiative, Improved Grapple, Power Attack, Track","special_attacks":"Poison, rend armor, web","special_qualities":"Damage reduction 10/good, darkvision 60 ft., plane shift, scent, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('dretch','Dretch','Dretch','2','Small','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','2d8+4 (13 hp)',13,'+0','20 ft. (4 squares)','16 (+1 size, +5 natural), touch 11, flat-footed 16','+2/–1','Claw +4 melee (1d6+1)','5 ft./5 ft.','+5','+3','+3',12,10,14,5,11,11,'Hide +9, Listen +5, Move Silently +5, Spot +5, Search +2, Survival +0 (+2 following tracks)','Multiattack','{"special_attacks":"Spell-like abilities, summon demon","special_qualities":"Damage reduction 5/cold iron or good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, telepathy 100 ft."}'::jsonb,'A dretch is about 4 feet tall and weighs about 60 pounds.

Dretches cannot speak but can communicate telepathically.

#### Combat

Dretches are slow, stupid, and not very effective combatants. In one-on-one combat, they rely on their damage reduction to keep them alive. In groups, they depend on sheer numbers to overcome foes and immediately summon other dretches to improve the odds in battle. They flee at the first sign of adversity unless more powerful demons are present to intimidate them into fighting. Dretches’ fear of their greater kin is stronger then even their fear of death.

A dretch’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** 1/day—_scare_ (DC 12), _stinking cloud_ (DC 13). Caster level 2nd. The save DCs are Charisma-based.

**_Summon Demon_ (Sp):** Once per day a dretch can attempt to summon another dretch with a 35% chance of success. This ability is the equivalent of a 1st-level spell.

**Telepathy (Su):** Dretches can communicate telepathically with creatures within 100 feet that speak Abyssal.','{"full_attack":"2 claws +4 melee (1d6+1) and bite +2 melee (1d4)","environment":"A chaotic evil-aligned plane","organization":"Solitary, pair, gang (3–5), crowd (6–15), or mob (10–40)","treasure":"None","advancement":"3–6 HD (Small)","level_adjustment":"+2","statblock":{"hit_dice":"2d8+4 (13 hp)","hit_points":13,"base_attack_grapple":"+2/–1","attack":"Claw +4 melee (1d6+1)","full_attack":"2 claws +4 melee (1d6+1) and bite +2 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +5, Ref +3, Will +3","abilities":{"str":"12","dex":"10","con":"14","int":"5","wis":"11","cha":"11"},"skills":"Hide +9, Listen +5, Move Silently +5, Spot +5, Search +2, Survival +0 (+2 following tracks)","feats":"Multiattack","special_attacks":"Spell-like abilities, summon demon","special_qualities":"Damage reduction 5/cold iron or good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('glabrezu','Glabrezu','Glabrezu','13','Huge','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','12d8+120 (174 hp)',174,'+0','40 ft. (8 squares)','27 (–2 size, +19 natural) touch 8, flat-footed 27','+12/+30','Pincers +20 melee (2d8+10)','15 ft./15 ft.','+18','+8','+11',31,10,31,16,16,20,'Bluff +22, Concentration +25, Diplomacy +9, Disguise +5 (+7 acting), Intimidate +24, Knowledge (any two) +18, Listen +26, Move Silently +18, Search +18, Sense Motive +18, Spellcraft +18, Spot +26, Survival +3 (+5 following tracks)','Cleave, Great Cleave, Multiattack, Persuasive, Power Attack','{"special_attacks":"Improved grab, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 21, telepathy 100 ft., true seeing"}'::jsonb,'Like succubi, glabrezu tempt victims into ruin, but they lure their prey with power or wealth rather than passion.

Glabrezu have penetrating violet eyes, and their skin color ranges from deep russet to pitch black. A glabrezu stands about 15 feet tall and weighs about 5,500 pounds.

#### Combat

Glabrezu prefer subterfuge to combat. However, if their attempts to entice or deceive fail, these enormous demons attack with a vengeance. They follow a _confusion_ attack with melee attacks, hoping to finish off wounded foes with _chaos hammer_ or _unholy blight._

A glabrezu’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Improved Grab (Ex):** To use this ability, a glabrezu must hit a Medium or smaller opponent with a pincer attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Spell-Like Abilities:** At will—_chaos hammer_ (DC 19), _confusion_ (DC 19), _dispel magic, mirror image, reverse gravity_ (DC 22), _greater teleport_ (self plus 50 pounds of objects only), _unholy blight_ (DC 19); 1/day—_power word stun_. Caster level 14th. The save DCs are Charisma-based.

Once per month, a glabrezu can fulfill a _wish_ for a mortal humanoid. The demon can use this ability to offer a mortal whatever he or she desires—but unless the _wish_ is used to create pain and suffering in the world, the glabrezu demands either terrible evil acts or great sacrifice as compensation.

**_Summon Demon_ (Sp):** Once per day a glabrezu can attempt to summon 4d10 dretches or 1d2 vrocks with a 50% chance of success, or another glabrezu with a 20% chance of success. This ability is the equivalent of a 4th-level spell.

**True Seeing (Su):** Glabrezu continuously use true seeing as the spell (caster level 14th).

**Skills:** Glabrezu have a +8 racial bonus on Listen and Spot checks.','{"full_attack":"2 pincers +20 melee (2d8+10) and 2 claws +18 melee (1d6+5) and bite +18 melee (1d8+5)","environment":"A chaotic evil-aligned plane","organization":"Solitary or troupe (1 glabrezu, 1 succubus, and 2–5 vrocks)","treasure":"Standard coins; double goods; standard items","advancement":"13–18 HD (Huge); 19–36 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"12d8+120 (174 hp)","hit_points":174,"base_attack_grapple":"+12/+30","attack":"Pincers +20 melee (2d8+10)","full_attack":"2 pincers +20 melee (2d8+10) and 2 claws +18 melee (1d6+5) and bite +18 melee (1d8+5)","space_reach":"15 ft./15 ft.","saves":"Fort +18, Ref +8, Will +11","abilities":{"str":"31","dex":"10","con":"31","int":"16","wis":"16","cha":"20"},"skills":"Bluff +22, Concentration +25, Diplomacy +9, Disguise +5 (+7 acting), Intimidate +24, Knowledge (any two) +18, Listen +26, Move Silently +18, Search +18, Sense Motive +18, Spellcraft +18, Spot +26, Survival +3 (+5 following tracks)","feats":"Cleave, Great Cleave, Multiattack, Persuasive, Power Attack","special_attacks":"Improved grab, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 21, telepathy 100 ft., true seeing"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('hezrou','Hezrou','Hezrou','11','Large','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','10d8+93 (138 hp)',138,'+0','30 ft. (6 squares)','23 (–1 size, +14 natural) touch 9, flat-footed 23','+10/+19','Bite +14 melee (4d4+5)','10 ft./10 ft.','+16','+7','+9',21,10,29,14,14,18,'Climb +18, Concentration +22, Hide +13, Escape Artist +13, Intimidate +17, Listen +23, Move Silently +13, Search +15, Spellcraft +15, Spot +23, Survival +2 (+4 following tracks), Use Rope +0 (+2 with bindings)','Blind-Fight, Cleave, Power Attack, Toughness','{"special_attacks":"Spell-like abilities, stench, improved grab, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 19, telepathy 100 ft."}'::jsonb,'A hezrou can walk both upright and on all fours, but it always fights standing up

A hezrou is about 8 feet tall and weighs about 750 pounds.

#### Combat

Hezrous enjoy melee combat even more than vrocks do. They eagerly press an attack deep into the heart of enemy forces, so their stench can take effect as quickly as possible. They enter most battles by using _blasphemy,_ and follow it with an occasional _chaos hammer_ or _unholy blight,_ depending on the alignment of their opponents.

A hezrou’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Improved Grab (Ex):** To use this ability, a hezrou must hit with both claw attacks. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

**Spell-Like Abilities:** At will—_chaos hammer_ (DC 18), _greater teleport_ (self plus 50 pounds of objects only), _unholy blight_ (DC 18); 3/day—_blasphemy_ (DC 21), _gaseous form._ Caster level 13th. The save DCs are Charisma-based.

**Stench (Ex):** A hezrou’s skin produces a foul-smelling, toxic liquid whenever it fights. Any living creature (except other demons) within 10 feet must succeed on a DC 24 Fortitude save or be nauseated for as long as it remains within the affected area and for 1d4 rounds afterward. Creatures that successfully save are sickened for as long as they remain in the area. A creature that successfully saves cannot be affected again by the same hezrou’s stench for 24 hours. A _delay poison_ or _neutralize poison_ spell removes either condition from one creature. Creatures that have immunity to poison are unaffected, and creatures resistant to poison receive their normal bonus on their saving throws.. The save DC is Constitution-based.

**_Summon Demon_ (Sp):** Once per day a hezrou can attempt to summon 4d10 dretches or another hezrou with a 35% chance of success. This ability is the equivalent of a 4th-level spell.

**Skills:** Hezrous have a +8 racial bonus on Listen and Spot checks.','{"full_attack":"Bite +14 melee (4d4+5) and 2 claws +9 melee (1d8+2)","environment":"A chaotic evil-aligned plane","organization":"Solitary or gang (2–4)","treasure":"Standard","advancement":"11–15 HD (Large); 16–30 HD (Huge)","level_adjustment":"+9","statblock":{"hit_dice":"10d8+93 (138 hp)","hit_points":138,"base_attack_grapple":"+10/+19","attack":"Bite +14 melee (4d4+5)","full_attack":"Bite +14 melee (4d4+5) and 2 claws +9 melee (1d8+2)","space_reach":"10 ft./10 ft.","saves":"Fort +16, Ref +7, Will +9","abilities":{"str":"21","dex":"10","con":"29","int":"14","wis":"14","cha":"18"},"skills":"Climb +18, Concentration +22, Hide +13, Escape Artist +13, Intimidate +17, Listen +23, Move Silently +13, Search +15, Spellcraft +15, Spot +23, Survival +2 (+4 following tracks), Use Rope +0 (+2 with bindings)","feats":"Blind-Fight, Cleave, Power Attack, Toughness","special_attacks":"Spell-like abilities, stench, improved grab, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 19, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('marilith','Marilith','Marilith','17','Large','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','16d8+144 (216 hp)',216,'+4','40 ft. (8 squares)','29 (–1 size, +4 Dex, +16 natural), touch 13, flat-footed 25','+16/+29','Longsword +25 melee (2d6+9/19–20) or slam +24 melee (1d8+9) or tail slap +24 melee (4d6+9)','10 ft./10 ft.','+19','+14','+14',29,19,29,18,18,24,'Bluff +26, Concentration +28, Diplomacy +30, Disguise +7 (+9 acting), Hide +19, Intimidate +28, Listen +31, Move Silently +23, Search 23, Sense Motive +23, Spellcraft +23 (+25 scrolls), Spot +31, Survival +4 (+6 following tracks), Use Magic Device +26 (+28 scrolls)','Combat Expertise, Combat Reflexes, Multiattack, Multiweapon Fighting, Power Attack, Weapon Focus (longsword)','{"special_attacks":"Constrict 4d6+13, improved grab, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good and cold iron, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 25, telepathy 100 ft."}'::jsonb,'A marilith usually holds a longsword in each of its six hands and wears many bangles and jewels.

A marilith stands about 9 feet tall and measures about 20 feet from head to tip of tail. It weighs about 4,000 pounds.

#### Combat

Though mariliths thrive on grand strategy and army-level tactics, they love physical combat and never pass up an opportunity to fight. Each of a marilith’s six arms can wield a weapon, and the creature gets an additional three weapon attacks with its primary arm. Mariliths seldom rush headlong into battle, however, preferring to hang back and size up the situation first. They always seek to gain the best possible advantage from the local terrain, obstacles, and any vulnerability or weakness in their opponents.

A marilith’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Constrict (Ex):** A marilith deals 4d6+13 points of damage with a successful grapple check. The constricted creature must succeed on a DC 27 Fortitude save or lose consciousness for as long as it remains in the coils and for 2d4 rounds thereafter. The save DC is Strength-based.

**Improved Grab (Ex):** To use this ability, a marilith must hit with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it succeeds on the grapple check, it can constrict.

**Spell-Like Abilities:** At will—_align weapon, blade barrier_ (DC 23), _magic weapon, project image_ (DC 23), _polymorph, see invisibility, telekinesis_ (DC 22), _greater teleport_ (self plus 50 pounds of objects only), _unholy aura_ (DC 25). Caster level 16th. The save DCs are Charisma-based.

**_Summon Demon_ (Sp):** Once per day a marilith can attempt to summon 4d10 dretches, 1d4 hezrou, or one nalfeshnee with a 50% chance of success, or one glabrezu or another marilith with a 20% chance of success. This ability is the equivalent of a 5th-level spell.

**True Seeing (Su):** Mariliths continuously use this ability, as the spell (caster level 16th).

**Skills:** Mariliths have a +8 racial bonus on Listen and Spot checks.

**Feats:** In combination with its natural abilities, a marilith’s Multiweapon Fighting feat allows it to attack with all its arms at no penalty.','{"full_attack":"Primary longsword +25/+20/+15/+10 melee (2d6+9/19–20) and 5 longswords +25 melee (2d6+4/19–20) and tail slap +22 melee (4d6+4); or 6 slams +24 melee (1d8+9) and tail slap +22 melee (4d6+4)","environment":"A chaotic evil-aligned plane","organization":"Solitary or pair","treasure":"Standard coins; double goods; standard items, plus 1d4 magic weapons","advancement":"17–20 HD (Large); 21–48 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+144 (216 hp)","hit_points":216,"base_attack_grapple":"+16/+29","attack":"Longsword +25 melee (2d6+9/19–20) or slam +24 melee (1d8+9) or tail slap +24 melee (4d6+9)","full_attack":"Primary longsword +25/+20/+15/+10 melee (2d6+9/19–20) and 5 longswords +25 melee (2d6+4/19–20) and tail slap +22 melee (4d6+4); or 6 slams +24 melee (1d8+9) and tail slap +22 melee (4d6+4)","space_reach":"10 ft./10 ft.","saves":"Fort +19, Ref +14, Will +14","abilities":{"str":"29","dex":"19","con":"29","int":"18","wis":"18","cha":"24"},"skills":"Bluff +26, Concentration +28, Diplomacy +30, Disguise +7 (+9 acting), Hide +19, Intimidate +28, Listen +31, Move Silently +23, Search 23, Sense Motive +23, Spellcraft +23 (+25 scrolls), Spot +31, Survival +4 (+6 following tracks), Use Magic Device +26 (+28 scrolls)","feats":"Combat Expertise, Combat Reflexes, Multiattack, Multiweapon Fighting, Power Attack, Weapon Focus (longsword)","special_attacks":"Constrict 4d6+13, improved grab, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good and cold iron, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 25, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('nalfeshnee','Nalfeshnee','Nalfeshnee','14','Huge','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','14d8+112 (175 hp)',175,'+1','30 ft. (6 squares), fly 40 ft. (poor)','27 (–2 size, +1 Dex, +18 natural) touch 9, flat-footed 26','+14/+29','Bite +20 melee (2d8+7)','15 ft./15 ft.','+17','+10','+15',25,13,27,22,22,20,'Bluff +22, Concentration +25, Diplomacy +26, Disguise +5 (+7 acting), Hide +10, Intimidate +22, Knowledge (arcana) +23, Listen +31, Move Silently +18, Search +23, Sense Motive +23, Spellcraft +25 (+27 scrolls), Spot +31, Survival +6 (+8 following tracks), Use Magic Device +22 (+24 scrolls)','Cleave, Improved Bull Rush, Multiattack, Power Attack, Weapon Focus (bite)','{"special_attacks":"Smite, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 22, telepathy 100 ft., true seeing"}'::jsonb,'A nalfeshnee can fly despite its small wings.

A nalfeshnee is more than 20 feet tall and weighs 8,000 pounds.

#### Combat

When fulfilling their duties in the underworld, nalfeshnees usually disdain combat as being beneath them. Given the opportunity, they succumb to blood lust and do battle. They disable opponents with their smite ability and slaughter them while they can’t fight back.

A nalfeshnee’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Smite (Su):** Three times per day a nalfeshnee can create a nimbus of unholy light. When the demon triggers the ability, rainbow-colored beams play around its body. One round later they burst in a 60-foot radius. Any creature within this area must succeed on a DC 22 Will save or be dazed for 1d10 rounds as visions of its worst fears hound it. The creature receives its full Dexterity and shield bonuses to AC if attacked but can take no actions. Other demons are immune to this effect. The save DC is Charisma-based.

**Spell-Like Abilities:** At will—_call lightning_ (DC 18), _feeblemind_ (DC 20), _greater dispel magic, slow_ (DC 18), _greater teleport_ (self plus 50 pounds of objects only), _unholy aura_ (DC 23). Caster level 12th. The save DCs are Charisma-based.

**_Summon Demon_ (Sp):** Twice per day a nalfeshnee can attempt to summon 1d4 vrocks, 1d4 hezrous, or one glabrezu with a 50% chance of success, or another nalfeshnee with a 20% chance of success. This ability is the equivalent of a 5th-level spell.

**True Seeing (Su):** Nalfeshnees continuously use true seeing, as the spell (caster level 14th).

**Skills:** Nalfeshnees have a +8 racial bonus on Listen and Spot checks.','{"full_attack":"Bite +20 melee (2d8+7) and 2 claws +17 melee (1d8+3)","environment":"A chaotic evil-aligned plane","organization":"Solitary or troupe (1 nalfeshnee, 1 hezrou, and 2–5 vrocks)","treasure":"Standard coins; double goods; standard items","advancement":"15–20 HD (Huge); 21–42 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"14d8+112 (175 hp)","hit_points":175,"base_attack_grapple":"+14/+29","attack":"Bite +20 melee (2d8+7)","full_attack":"Bite +20 melee (2d8+7) and 2 claws +17 melee (1d8+3)","space_reach":"15 ft./15 ft.","saves":"Fort +17, Ref +10, Will +15","abilities":{"str":"25","dex":"13","con":"27","int":"22","wis":"22","cha":"20"},"skills":"Bluff +22, Concentration +25, Diplomacy +26, Disguise +5 (+7 acting), Hide +10, Intimidate +22, Knowledge (arcana) +23, Listen +31, Move Silently +18, Search +23, Sense Motive +23, Spellcraft +25 (+27 scrolls), Spot +31, Survival +6 (+8 following tracks), Use Magic Device +22 (+24 scrolls)","feats":"Cleave, Improved Bull Rush, Multiattack, Power Attack, Weapon Focus (bite)","special_attacks":"Smite, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 22, telepathy 100 ft., true seeing"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('quasit','Quasit','Quasit','2','Tiny','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','3d8 (13 hp)',13,'+7','20 ft. (4 squares), fly 50 ft. (perfect)','18 (+2 size, +3 Dex, +3 natural), touch 15, flat-footed 15','+3/–6','Claw +8 melee (1d3–1 plus poison)','2-1/2 ft./0 ft.','+3','+6','+4',8,17,10,10,12,10,'Bluff +6, Diplomacy +2, Disguise +0 (+2 acting), Hide +17, Intimidate +2, Knowledge (any one) +6, Listen +7, Move Silently +9, Search +6, Spellcraft +6, Spot +6','Improved Initiative, Weapon Finesse','{"special_attacks":"Poison, spell-like abilities","special_qualities":"Alternate form, damage reduction 5/cold iron or good, darkvision 60 ft., fast healing 2, immunity to poison, resistance to fire 10"}'::jsonb,'In its natural form, a quasit stands about 1-1/2 feet tall and weighs about 8 pounds.

Quasits speak Common and Abyssal.

#### Combat

Although quasits thirst for victory and power as other demons do, they are cowards at heart. They typically attack from ambush, using their alternate form ability and _invisibility_ to get within reach, then try to scuttle away. When retreating, they use their _cause fear_ ability to deter pursuit.

A quasit’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 13, initial damage 1d4 Dex, secondary damage 2d4 Dex. The save DC is Constitution-based and includes a +2 racial bonus.

**Spell-Like Abilities:** At will—_detect good, detect magic,_ and _invisibility_ (self only); 1/day—_cause fear_ (as the spell, except that its area is a 30-foot radius from the quasit, save DC 11). Caster level 6th.

The save DCs are Charisma-based.

Once per week a quasit can use _commune_ to ask six questions. The ability otherwise works as the spell (caster level 12th).

**Alternate Form (Su):** A quasit can assume other forms at will as a standard action. This ability functions as a _polymorph_ spell cast on itself (caster level 12th), except that a quasit does not regain hit points for changing form, and any individual quasit can assume only one or two forms no larger than Medium. Common forms include bat, monstrous centipede, toad, and wolf. A quasit in alternate form loses its poison attack.','{"full_attack":"2 claws +8 melee (1d3–1 plus poison) and bite +3 melee (1d4–1)","environment":"A chaotic evil-aligned plane","organization":"Solitary","treasure":"None","advancement":"4–6 HD (Tiny)","level_adjustment":"— (Improved Familiar)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–6","attack":"Claw +8 melee (1d3–1 plus poison)","full_attack":"2 claws +8 melee (1d3–1 plus poison) and bite +3 melee (1d4–1)","space_reach":"2-1/2 ft./0 ft.","saves":"Fort +3, Ref +6, Will +4","abilities":{"str":"8","dex":"17","con":"10","int":"10","wis":"12","cha":"10"},"skills":"Bluff +6, Diplomacy +2, Disguise +0 (+2 acting), Hide +17, Intimidate +2, Knowledge (any one) +6, Listen +7, Move Silently +9, Search +6, Spellcraft +6, Spot +6","feats":"Improved Initiative, Weapon Finesse","special_attacks":"Poison, spell-like abilities","special_qualities":"Alternate form, damage reduction 5/cold iron or good, darkvision 60 ft., fast healing 2, immunity to poison, resistance to fire 10"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('retriever','Retriever','Retriever','11','Huge','Construct (Extraplanar)','Always chaotic evil','10d10+80 (135 hp)',135,'+3','50 ft. (10 squares)','21 (–2 size, +3 Dex, +10 natural), touch 11, flat-footed 18','+7/+25','Claw +15 melee (2d6+10) and eye ray +8 ranged touch','15 ft./10 ft.','+3','+6','+3',31,17,null,null,11,1,'—','—','{"special_attacks":"Eye rays, find target, improved grab","special_qualities":"Construct traits, darkvision 60 ft., fast healing 5, low-light vision"}'::jsonb,'A retriever specializes in recovering lost or desired objects, runaway slaves, and enemies and bringing them back to its master. A retriever has a body the size of an ox, with legs spanning more than 14 feet. It weighs about 6,500 pounds.

#### Combat

Retrievers attack with four claws, but their eye rays are far more deadly.

**Eye Rays (Su):** A retriever’s eyes can produce four different magical rays with a range of 100 feet. Each round, it can fire one ray as a free action. A particular ray is usable only once every 4 rounds. A retriever can fire an eye ray in the same round that it makes physical attacks. The save DC for all rays is 18. The save DC is Dexterity-based.

The four eye effects are:

_Fire:_ Deals 12d6 points of fire damage to the target (Reflex half ).

_Cold:_ Deals 12d6 points of cold damage to the target (Reflex half ).

_Electricity:_ Deals 12d6 points of electricity damage to the target (Reflex half ).

_Petrification:_ The target must succeed on a Fortitude save or turn to stone permanently.

**_Find Target_ (Sp):** When ordered to find an item or a creature, a retriever does so unerringly, as though guided by _discern location._

The being giving the order must have seen (or must have an item belonging to) the creature to be found, or must have touched the object to be located. This ability is the equivalent of an 8th-level spell.

**Improved Grab (Ex):** To use this ability, a retriever must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and grips the opponent fast in its mouth. This is the method by which it usually “retrieves” things.','{"full_attack":"4 claws +15 melee (2d6+10) and bite +10 melee (1d8+5) and eye ray +8 ranged touch","environment":"A chaotic evil-aligned plane","organization":"Solitary","treasure":"None","advancement":"11–15 HD (Huge); 16–30 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"10d10+80 (135 hp)","hit_points":135,"base_attack_grapple":"+7/+25","attack":"Claw +15 melee (2d6+10) and eye ray +8 ranged touch","full_attack":"4 claws +15 melee (2d6+10) and bite +10 melee (1d8+5) and eye ray +8 ranged touch","space_reach":"15 ft./10 ft.","saves":"Fort +3, Ref +6, Will +3","abilities":{"str":"31","dex":"17","con":null,"int":null,"wis":"11","cha":"1"},"skills":"—","feats":"—","special_attacks":"Eye rays, find target, improved grab","special_qualities":"Construct traits, darkvision 60 ft., fast healing 5, low-light vision"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('succubus','Succubus','Succubus','7','Medium','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','6d8+6 (33 hp)',33,'+1','30 ft. (6 squares), fly 50 ft. (average)','20 (+1 Dex, +9 natural), touch 11, flat-footed 19','+6/+7','Claw +7 melee (1d6+1)','5 ft./5 ft.','+6','+6','+7',13,13,13,16,14,26,'Bluff +19, Concentration +10, Diplomacy +12, Disguise +17* (+19 acting), Escape Artist +10, Hide +10, Intimidate +19, Knowledge (any one) +12, Listen +19, Move Silently +10, Search +12, Spot +19, Survival +2 (+4 following tracks), Use Rope +1 (+3 with bindings)','Dodge, Mobility, Persuasive','{"special_attacks":"Energy drain, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/cold iron or good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 18, telepathy 100 ft., tongues"}'::jsonb,'A succubus is 6 feet tall in its natural form and weighs about 125 pounds.

#### Combat

Succubi are not warriors. They flee combat whenever they can. If forced to fight, they can attack with their claws, but they prefer to turn foes against one another. Succubi use their _polymorph_ ability to assume humanoid guise, and can maintain this deception indefinitely. Their preferred tactic when dealing with heroes is to feign friendship and create an opportunity to be alone with one of them, whereupon the succubus applies her life-draining kiss. Succubi are not above taking on the role of a damsel in distress when encountered within a dungeon.

A succubus’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Energy Drain (Su):** A succubus drains energy from a mortal it lures into some act of passion, or by simply planting a kiss on the victim. If the target is not willing to be kissed, the succubus must start a grapple, which provokes an attack of opportunity. The succubus’s kiss or embrace bestows one negative level. The kiss also has the effect of a _suggestion_ spell, asking the victim to accept another kiss from the succubus. The victim must succeed on a DC 21 Will save to negate the effect of the _suggestion_. The DC is 21 for the Fortitude save to remove a negative level. These save DCs are Charisma-based.

**Spell-Like Abilities:** At will—_charm monster_ (DC 22), _detect good, detect thoughts_ (DC 20), _ethereal jaunt_ (self plus 50 pounds of objects only), _polymorph_ (humanoid form only, no limit on duration), _suggestion_ (DC 21), _greater teleport_ (self plus 50 pounds of objects only). Caster level 12th. The save DCs are Charisma-based.

**_Summon Demon_ (Sp):** Once per day a succubus can attempt to summon 1 vrock with a 30% chance of success. This ability is the equivalent of a 3rd-level spell.

**Tongues (Su):** A succubus has a permanent tongues ability (as the spell, caster level 12th). Succubi usually use verbal communication with mortals.

**Skills:** Succubi have a +8 racial bonus on Listen and Spot checks.

\*While using her _polymorph_ ability, a succubus gains a +10 circumstance bonus on Disguise checks.','{"full_attack":"2 claws +7 melee (1d6+1)","environment":"A chaotic evil-aligned plane","organization":"Solitary","treasure":"Standard","advancement":"7–12 HD (Medium)","level_adjustment":"+6","statblock":{"hit_dice":"6d8+6 (33 hp)","hit_points":33,"base_attack_grapple":"+6/+7","attack":"Claw +7 melee (1d6+1)","full_attack":"2 claws +7 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +6, Ref +6, Will +7","abilities":{"str":"13","dex":"13","con":"13","int":"16","wis":"14","cha":"26"},"skills":"Bluff +19, Concentration +10, Diplomacy +12, Disguise +17* (+19 acting), Escape Artist +10, Hide +10, Intimidate +19, Knowledge (any one) +12, Listen +19, Move Silently +10, Search +12, Spot +19, Survival +2 (+4 following tracks), Use Rope +1 (+3 with bindings)","feats":"Dodge, Mobility, Persuasive","special_attacks":"Energy drain, spell-like abilities, summon demon","special_qualities":"Damage reduction 10/cold iron or good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 18, telepathy 100 ft., tongues"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('vrock','Vrock','Vrock','9','Large','Outsider (Chaotic, Extraplanar, Evil)','Always chaotic evil','10d8+70 (115 hp)',115,'+2','30 ft. (6 squares), fly 50 ft. (average)','22 (–1 size, +2 Dex, +11 natural), touch 11, flat-footed 20','+10/+20','Claw +15 melee (2d6+6)','10 ft./10 ft.','+14','+9','+10',23,15,25,14,16,16,'Concentration +20, Diplomacy +5, Hide +11, Intimidate +16, Knowledge (any one) +15, Listen +24, Move Silently +15, Search +15, Sense Motive +16, Spellcraft +15, Spot +24, Survival +3 (+5 following tracks)','Cleave, Combat Reflexes, Multiattack, Power Attack','{"special_attacks":"Dance of ruin, spell-like abilities, spores, stunning screech, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 17, telepathy 100 ft."}'::jsonb,'A vrock is about 8 feet tall and weighs about 500 pounds.

#### Combat

Vrocks are vicious fighters who like to fly down into the enemy and cause as much damage as possible. They prance about in battle, taking briefly to the air and bringing their clawed feet into play. Despite their advantage in mobility, the vrocks’ deep love of battle frequently leads them into melee combats against heavy odds.

A vrock’s natural weapons, as well as any weapons it wields, are treated as chaotic-aligned and evil-aligned for the purpose of overcoming damage reduction.

**Dance of Ruin (Su):** To use this ability, a group of at least three vrocks must join hands in a circle, dancing wildly and chanting.

At the end of 3 rounds of dancing, a wave of crackling energy flashes outward in a 100-foot radius. All creatures except for demons within the radius take 20d6 points of damage (Reflex DC 18 half ). Stunning, paralyzing, or slaying one of the vrocks stops the dance. The save DC is Charisma-based.

**Spell-Like Abilities:** At will—_mirror image, telekinesis_ (DC 18), _greater teleport_ (self plus 50 pounds of objects only); 1/day—_heroism._ Caster level 12th. The save DCs are Charisma-based.

**Spores (Ex):** A vrock can release masses of spores from its body once every 3 rounds as a free action. The spores automatically deal 1d8 points of damage to all creatures adjacent to the vrock. They then penetrate the skin and grow, dealing an additional 1d4 points of damage each round for 10 rounds. At the end of this time, the victim is covered with a tangle of viny growths. (The vines are harmless and wither away in 1d4 days.) A _delay poison_ spell stops the spores’ growth for its duration. _Bless, neutralize poison,_ or _remove disease_ kills the spores, as does sprinkling the victim with a vial of holy water.

**Stunning Screech (Su):** Once per hour a vrock can emit a piercing screech. All creatures except for demons within a 30-foot radius must succeed on a DC 22 Fortitude save or be stunned for 1 round. The save DC is Constitution-based.

**_Summon Demon_ (Sp):** Once per day a vrock can attempt to summon 2d10 dretches or another vrock with a 35% chance of success. This ability is the equivalent of a 3rd-level spell.

**Skills:** Vrocks have a +8 racial bonus on Listen and Spot checks.','{"full_attack":"2 claws +15 melee (2d6+6) and bite +13 melee (1d8+3) and 2 talons +13 melee (1d6+3)","environment":"A chaotic evil-aligned plane","organization":"Solitary, pair, gang (3–5), or squad (6–10)","treasure":"Standard","advancement":"11–14 HD (Large); 15–30 HD (Huge)","level_adjustment":"+8","statblock":{"hit_dice":"10d8+70 (115 hp)","hit_points":115,"base_attack_grapple":"+10/+20","attack":"Claw +15 melee (2d6+6)","full_attack":"2 claws +15 melee (2d6+6) and bite +13 melee (1d8+3) and 2 talons +13 melee (1d6+3)","space_reach":"10 ft./10 ft.","saves":"Fort +14, Ref +9, Will +10","abilities":{"str":"23","dex":"15","con":"25","int":"14","wis":"16","cha":"16"},"skills":"Concentration +20, Diplomacy +5, Hide +11, Intimidate +16, Knowledge (any one) +15, Listen +24, Move Silently +15, Search +15, Sense Motive +16, Spellcraft +15, Spot +24, Survival +3 (+5 following tracks)","feats":"Cleave, Combat Reflexes, Multiattack, Power Attack","special_attacks":"Dance of ruin, spell-like abilities, spores, stunning screech, summon demon","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to electricity and poison, resistance to acid 10, cold 10, and fire 10, spell resistance 17, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('derro','Derro','Derro','3','Small','Monstrous Humanoid','Usually chaotic evil','3d8+3 (16 hp)',16,'+6','20 ft. (4 squares)','19 (+1 size, +2 Dex, +2 natural, +3 studded leather armor, +1 buckler), touch 13, flat-footed 17','+3/–1','Short sword +4 melee (1d4/19–20) or repeating light crossbow +6 ranged (1d6/19–20 plus poison)','5 ft./5 ft.','+2','+5','+6',11,14,13,10,5,16,'Bluff +5, Hide +10, Listen +1, Move Silently +8','Blind-Fight, Improved Initiative','{"special_attacks":"Poison use, spell-like abilities, sneak attack +1d6","special_qualities":"Madness, spell resistance 15 vulnerability to sunlight"}'::jsonb,'Derro are afflicted by a form of racial madness, which most often manifests as delusions of grandeur coupled with an overpowering urge to inflict torment on other creatures. Derro are capable of holding their murderous impulses in check for short periods of time in order to cooperate with creatures of other races, but such arrangements rarely last more than a few weeks. Of course, no derro is capable of recognizing that he is out of his mind.

### Combat

Derro are stealthy and bloodthirsty. They like to carefully arrange cruel traps and deadly ambushes, and strike savagely from hiding. They delight in taking captives who can be tortured to death later, and favor traps and poisons that disable without killing.

**Madness (Ex):** Derro use their Charisma modifier on Will saves instead of their Wisdom modifier, and have immunity to _confusion_ and _insanity_ effects. A derro cannot be restored to sanity by any means short of a _miracle_ or _wish_ spell.

\*The racial madness of the derro provides a +6 bonus to their Charisma scores and a –6 penalty to their Wisdom scores. A derro restored to sanity gains 6 points of Wisdom and loses 6 points of Charisma.

**Poison Use (Ex):** Derro typically carry 2d4 doses of greenblood oil or Medium monstrous spider venom, applying it to their crossbow bolts. Derro are not at risk of poisoning themselves when handling poison.

**Sneak Attack (Ex):** Any time a derro’s opponent is denied his Dexterity bonus to AC, or if a derro flanks his opponent, he deals an extra 1d6 points of damage. This ability is just like the rogue’s sneak attack and subject to the same limitations.

**Spell-Like Abilities:** At will—_darkness, ghost sound;_ 1/day— _daze_ (DC 13)_, sound burst_ (DC 15). Caster level 3rd. The save DCs are Charisma-based.

**Vulnerability to Sunlight (Ex):** A derro takes 1 point of Constitution damage for every hour it is exposed to sunlight, and it dies if its Constitution score reaches 0. Lost Constitution points are recovered at the rate of 1 per every 24-hour period spent underground or otherwise sheltered from the sun.

**Skills:** Derro have a +4 racial bonus on Hide and Move Silently checks.','{"full_attack":"Short sword +4 melee (1d4/19–20) or repeating light crossbow +6 ranged (1d6/19–20 plus poison)","environment":"Underground","organization":"Team (2–4), squad (5–8 plus 1 3rd-level sorcerer), or band (11–20 plus 30% noncombatants plus 3 3rd-level sorcerers and 1 sorcerer of 5th–8th level)","treasure":"Standard coins; double goods; standard items","advancement":"By character class","level_adjustment":"— (+2 if sane)","statblock":{"hit_dice":"3d8+3 (16 hp)","hit_points":16,"base_attack_grapple":"+3/–1","attack":"Short sword +4 melee (1d4/19–20) or repeating light crossbow +6 ranged (1d6/19–20 plus poison)","full_attack":"Short sword +4 melee (1d4/19–20) or repeating light crossbow +6 ranged (1d6/19–20 plus poison)","space_reach":"5 ft./5 ft.","saves":"Fort +2, Ref +5, Will +6","abilities":{"str":"11","dex":"14","con":"13","int":"10","wis":"5","cha":"16"},"skills":"Bluff +5, Hide +10, Listen +1, Move Silently +8","feats":"Blind-Fight, Improved Initiative","special_attacks":"Poison use, spell-like abilities, sneak attack +1d6","special_qualities":"Madness, spell resistance 15 vulnerability to sunlight"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('destrachan','Destrachan','Destrachan','8','Large','Aberration','Usually neutral evil','8d8+24 (60 hp)',60,'+5','30 ft. (6 squares)','18 (–1 size, +1 Dex, +8 natural), touch 10, flat-footed 17','+6/+14','Claw +9 melee (1d6+4)','10 ft./5 ft.','+5','+5','+10',18,12,16,12,18,12,'Hide +8, Listen +25, Move Silently +7, Survival +9','Dodge, Improved Initiative, Lightning Reflexes','{"special_attacks":"Destructive harmonics","special_qualities":"Blindsight 100 ft., immunities, protection from sonics"}'::jsonb,'The dungeon-dwelling destrachan looks like some bizarre, nonintelligent beast, but it’s an incredibly evil and crafty sadist. A destrachan has a pair of complex, three-part ears that it can adjust to be more or less sensitive to various sounds. It is blind, yet hunts with a sense of hearing more precise than most creatures’ sight.

From its tubular mouth a destrachan emits carefully focused harmonics, producing sonic energy so powerful it can shatter a stone wall. So skilled is a destrachan at controlling the sounds it emits that it can choose what type of material to affect with its attack.

A destrachan is about 10 feet long from its mouth to the tip of the tail and weighs about 4,000 pounds.

A destrachan speaks no language but understands Common. If a destrachan must communicate, it does so through action.

### Combat

A destrachan uses its claws only as a last resort or to finish off foes weakened by its sonic attacks. It often enters battle with surprise if possible. It first focuses on destroying metal armor and weapons and then changes to harmonics that disrupt flesh.

**Destructive Harmonics (Su):** A destrachan can blast sonic energy in a cone up to 80 feet long. It can also use this attack to affect any creatures or objects within a 30-foot radius. It can tune the harmonics of this destructive power to affect different types of targets. All save DCs are Charisma-based.

_Flesh:_ Disrupting tissue and rending bone, this attack deals 4d6 points of damage to all within the area (Reflex DC 15 half ).

_Nerves:_ A destrachan can focus its harmonics to knock out foes rather than slay them. This attack deals 6d6 points of nonlethal damage to all within the area (Reflex DC 15 half ).

_Material:_ When using this form of harmonics, a destrachan chooses wood, stone, metal, or glass. All objects made of that material within the area must succeed on a DC 15 Fortitude save or shatter. Objects (or portions of objects) that have up to 30 hit points are potentially affected by this attack.

**Blindsight (Ex):** A destrachan can use hearing to ascertain all foes within 100 feet as a sighted creature would.

**Immunities:** Destrachans have immunity to gaze attacks, visual effects, illusions, and other attack forms that rely on sight.

**Protection from Sonics (Ex):** While they can be affected by loud noises and sonic spells (such as _ghost sound_ or _silence_), destrachans are less vulnerable to sonic attacks (+4 circumstance bonus on all saves) because they can protect their ears. A destrachan whose sense of hearing is impaired is effectively blinded, and all targets are treated as having total concealment.

**Skills:** A destrachan has a +10 racial bonus on Listen checks.','{"full_attack":"2 claws +9 melee (1d6+4)","environment":"Underground","organization":"Solitary or pack (3–5)","treasure":"None","advancement":"9–16 HD (Large); 17–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+6/+14","attack":"Claw +9 melee (1d6+4)","full_attack":"2 claws +9 melee (1d6+4)","space_reach":"10 ft./5 ft.","saves":"Fort +5, Ref +5, Will +10","abilities":{"str":"18","dex":"12","con":"16","int":"12","wis":"18","cha":"12"},"skills":"Hide +8, Listen +25, Move Silently +7, Survival +9","feats":"Dodge, Improved Initiative, Lightning Reflexes","special_attacks":"Destructive harmonics","special_qualities":"Blindsight 100 ft., immunities, protection from sonics"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('barbed_devil_hamatula','Barbed Devil (Hamatula)','Barbed Devil (Hamatula)','11','Medium','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','12d8+72 (126 hp)',126,'+6','30 ft. (6 squares)','29 (+6 Dex, +13 natural) touch 16, flat-footed 23','+12/+22','Claw +18 melee (2d8+6 plus fear)','5 ft./5 ft.','+14','+14','+12',23,23,23,12,14,18,'Concentration +21, Diplomacy +6, Hide +21, Intimidate +19, Knowledge (any one) +16, Listen +19, Move Silently +21, Search +16, Sense Motive +17, Spot +19, Survival +2 (+4 following tracks)','Alertness, Cleave, Improved Grapple, Iron Will, Power Attack','{"special_attacks":"Fear, improved grab, impale 3d8+9, summon devil","special_qualities":"Barbed defense, damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 23, spell-like abilities, telepathy 100 ft."}'::jsonb,'A barbed devil is about 7 feet tall and weighs about 300 pounds.

#### Combat

Barbed devils eagerly fight with their claws, trying to impale their opponents. They use _hold person_ to immobilize those who avoid their hug attacks.

A barbed devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Fear (Su):** A creature hit by a barbed devil must succeed on a DC 20 Will save or be affected as though by _fear_ (caster level 9th).

Whether or not the save is successful, that creature cannot be affected by that same barbed devil’s fear ability for 24 hours. The save DC is Charisma-based.

**Impale (Ex):** A barbed devil deals 3d8+9 points of piercing damage to a grabbed opponent with a successful grapple check.

**Improved Grab (Ex):** To use this ability, a barbed devil must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can impale the opponent on its barbed body.

**_Summon Devil_ (Sp):** Once per day a barbed devil can attempt to summon 1d6 bearded devils or another barbed devil with a 35% chance of success. This ability is the equivalent of a 4th-level spell.

**Barbed Defense (Su):** Any creature striking a barbed devil with handheld weapons or natural weapons takes 1d8+6 points of piercing and slashing damage from the devil’s barbs. Note that weapons with exceptional reach, such as longspears, do not endanger their users in this way.

**Spell-Like Abilities:** At will—_greater teleport_ (self plus 50 pounds of objects only), _hold person_ (DC 16), _major image_ (DC 17), _scorching ray_ (2 rays only). 1/day—_order’s wrath_ (DC 18), _unholy blight_ (DC 18). Caster level 12th. The save DCs are Charisma-based.','{"full_attack":"2 claws +18 melee (2d8+6 plus fear)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, team (3–5), or squad (6–10)","treasure":"Standard","advancement":"13–24 (Medium); 25–36 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"12d8+72 (126 hp)","hit_points":126,"base_attack_grapple":"+12/+22","attack":"Claw +18 melee (2d8+6 plus fear)","full_attack":"2 claws +18 melee (2d8+6 plus fear)","space_reach":"5 ft./5 ft.","saves":"Fort +14, Ref +14, Will +12","abilities":{"str":"23","dex":"23","con":"23","int":"12","wis":"14","cha":"18"},"skills":"Concentration +21, Diplomacy +6, Hide +21, Intimidate +19, Knowledge (any one) +16, Listen +19, Move Silently +21, Search +16, Sense Motive +17, Spot +19, Survival +2 (+4 following tracks)","feats":"Alertness, Cleave, Improved Grapple, Iron Will, Power Attack","special_attacks":"Fear, improved grab, impale 3d8+9, summon devil","special_qualities":"Barbed defense, damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 23, spell-like abilities, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('bearded_devil_barbazu','Bearded Devil (Barbazu)','Bearded Devil (Barbazu)','5','Medium','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','6d8+18 (45 hp)',45,'+6','40 ft. (8 squares)','19 (+2 Dex, +7 natural) touch 12, flat-footed 17','+6/+8','Glaive +9 melee (1d10+3 plus infernal wound) or claw +8 melee (1d6+2)','5 ft./5 ft. (10 ft. with glaive)','+8','+7','+5',15,15,17,6,10,10,'Climb +11, Diplomacy +2, Hide +11, Listen +9, Move Silently +9, Sense Motive +9, Spot +9','Improved Initiative, Power Attack, Weapon Focus (glaive)','{"special_attacks":"Infernal wound, beard, battle frenzy, summon devil","special_qualities":"Damage reduction 5/silver or good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 17, telepathy 100 ft."}'::jsonb,'Every bearded devil carries a sawtoothed glaive.

A bearded devil stands 6 feet tall and weighs about 225 pounds.

#### Combat

Bearded devils are aggressive and love to fight. They revel in their battle frenzy, spreading mayhem among their foes.

A bearded devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** At will— _greater teleport_ (self plus 50 pounds of objects only). Caster level 12th.

**Infernal Wound (Su):** The damage a bearded devil deals with its glaive causes a persistent wound. An injured creature loses 2 additional hit points each round. The wound does not heal naturally and resists healing spells. The continuing hit point loss can be stopped by a DC 16 Heal check, a _cure_ spell, or a _heal_ spell. However, a character attempting to cast a _cure_ spell or a _heal_ spell on a creature damaged by a bearded devil’s glaive must succeed on a DC 16 caster level check, or the spell has no effect on the injured character.

A successful Heal check automatically stops the continuing hit point loss as well as restoring hit points. The infernal wound is a supernatural ability of the bearded devil, not of the weapon. The check DC is Constitution-based.

**Beard (Ex):** If a bearded devil hits a single opponent with both claw attacks, it automatically hits with its beard. The affected creature takes 1d8+2 points of damage and must succeed on a DC 16 Fortitude save or be infected with a vile disease known as devil chills (incubation period 1d4 days, damage 1d4 Str). Damage is dealt each day until the afflicted creature succeeds on three consecutive Fortitude saves, the disease is cured magically, or the creature dies. The save DC is Constitution-based.

**Battle Frenzy (Ex):** Twice per day, a bearded devil can work itself into a battle frenzy similar to the barbarian’s rage (+4 Strength, +4 Constitution, +2 morale bonus on Will saves, –2 AC penalty). The frenzy lasts for 6 rounds, and the bearded devil suffers no ill effects afterward.

**_Summon Devil_ (Sp):** Once per day a bearded devil can attempt to summon 2d10 lemures with a 50% chance of success, or another bearded devil with a 35% chance of success. This ability is the equivalent of a 3rd-level spell.','{"full_attack":"Glaive +9/+4 melee (1d10+3 plus infernal wound) or 2 claws +8 melee (1d6+2)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, team (3–5), or squad (6–10)","treasure":"Standard","advancement":"7–9 HD (Medium); 10–18 HD (Large)","level_adjustment":"+6","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+6/+8","attack":"Glaive +9 melee (1d10+3 plus infernal wound) or claw +8 melee (1d6+2)","full_attack":"Glaive +9/+4 melee (1d10+3 plus infernal wound) or 2 claws +8 melee (1d6+2)","space_reach":"5 ft./5 ft. (10 ft. with glaive)","saves":"Fort +8, Ref +7, Will +5","abilities":{"str":"15","dex":"15","con":"17","int":"6","wis":"10","cha":"10"},"skills":"Climb +11, Diplomacy +2, Hide +11, Listen +9, Move Silently +9, Sense Motive +9, Spot +9","feats":"Improved Initiative, Power Attack, Weapon Focus (glaive)","special_attacks":"Infernal wound, beard, battle frenzy, summon devil","special_qualities":"Damage reduction 5/silver or good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 17, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('bone_devil_osyluth','Bone Devil (Osyluth)','Bone Devil (Osyluth)','9','Large','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','10d8+50 (95 hp)',95,'+9','40 ft. (8 squares)','25 (–1 size, +5 Dex, +11 natural) touch 14, flat-footed 20','+10/+19','Bite +14 melee (1d8+5)','10 ft./10 ft.','+12','+12','+11',21,21,21,14,14,14,'Bluff +15, Concentration +18, Diplomacy +6, Disguise +2 (+4 acting), Hide +14, Intimidate +17, Knowledge (any one) +15, Listen +17, Move Silently +18, Search +15, Sense Motive +15, Spot +17, Survival +2 (+4 following tracks)','Alertness, Improved Initiative, Iron Will, Multiattack','{"special_attacks":"Spell-like abilities, fear aura, poison, summon devil","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 21, telepathy 100 ft."}'::jsonb,'Bone devils stand about 9 feet tall and weigh about 500 pounds.

#### Combat

Bone devils hate all other creatures and attack ruthlessly. They freely use _wall of ice_ to keep the enemy divided.

A bone devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Fear Aura (Su):** Bone devils can radiate a 5-foot-radius fear aura as a free action. Affected creatures must succeed on a DC 17 Will save or be affected as though by a _fear_ spell (caster level 7th). A creature that successfully saves cannot be affected again by the same bone devil’s aura for 24 hours. Other devils are immune to the aura. The save DC is Charisma-based.

**Poison (Ex):** Injury, Fortitude DC 20, initial damage 1d6 Str, secondary damage 2d6 Str. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_greater teleport_ (self plus 50 pounds of objects only), _dimensional anchor, fly, invisibility_ (self only), _major image_ (DC 15), _wall of ice_. Caster level 12th. The save DC is Charisma-based.

**_Summon Devil_ (Sp):** Once per day a bone devil can attempt to summon 2d10 lemures with a 50% chance of success, or another bone devil with a 35% chance of success. This ability is the equivalent of a 4th-level spell.','{"full_attack":"Bite +14 melee (1d8+5) and 2 claws +12 melee (1d4+2) and sting +12 melee (3d4+2 plus poison)","environment":"A lawful evil-aligned plane","organization":"Solitary, team (2–4), or squad (6–10)","treasure":"Standard","advancement":"11–20 HD (Large); 21–30 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"10d8+50 (95 hp)","hit_points":95,"base_attack_grapple":"+10/+19","attack":"Bite +14 melee (1d8+5)","full_attack":"Bite +14 melee (1d8+5) and 2 claws +12 melee (1d4+2) and sting +12 melee (3d4+2 plus poison)","space_reach":"10 ft./10 ft.","saves":"Fort +12, Ref +12, Will +11","abilities":{"str":"21","dex":"21","con":"21","int":"14","wis":"14","cha":"14"},"skills":"Bluff +15, Concentration +18, Diplomacy +6, Disguise +2 (+4 acting), Hide +14, Intimidate +17, Knowledge (any one) +15, Listen +17, Move Silently +18, Search +15, Sense Motive +15, Spot +17, Survival +2 (+4 following tracks)","feats":"Alertness, Improved Initiative, Iron Will, Multiattack","special_attacks":"Spell-like abilities, fear aura, poison, summon devil","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 21, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('chain_devil_kyton','Chain Devil (Kyton)','Chain Devil (Kyton)','6','Medium','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','8d8+16 (52 hp)',52,'+6','30 ft. (6 squares)','20 (+2 Dex, +8 natural), touch 12, flat-footed 18','+8/+10','Chain +10 melee (2d4+2/19–20)','5 ft./5 ft. (10 ft. with chains)','+8','+8','+6',15,15,15,6,10,12,'Climb +13, Craft (blacksmithing) +17, Escape Artist +13, Intimidate +12, Listen +13, Spot +13, Use Rope +2 (+4 with bindings)','Alertness, Improved Critical (chain), Improved Initiative','{"special_attacks":"Dancing chains, unnerving gaze","special_qualities":"Damage reduction 5/silver or good, darkvision 60 ft., immunity to cold, regeneration 2, spell resistance 18"}'::jsonb,'Kytons are humanlike devils, wrapped in chains instead of clothing. A chain devil is 6 feet tall and weighs about 300 pounds, chains included.

Chain devils speak Infernal and Common.

#### Combat

A chain devil attacks by flailing away with the spiked chains that serve as its clothing, armor, and weapons.

A chain devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Dancing Chains (Su):** A chain devil’s most awesome attack is its ability to control up to four chains within 20 feet as a standard action, making the chains dance or move as it wishes. In addition, a chain devil can increase these chains’ length by up to 15 feet and cause them to sprout razor-edged barbs. These chains attack as effectively as the devil itself. If a chain is in another creature’s possession, the creature can attempt a DC 15 Will save to break the chain devil’s power over that chain. If the save is successful, the kyton cannot attempt to control that particular chain again for 24 hours or until the chain leaves the creature’s possession. The save DC is Charisma-based.

A chain devil can climb chains it controls at its normal speed without making Climb checks.

**Unnerving Gaze (Su):** Range 30 ft., Will DC 15 negates. A chain devil can make its face resemble one of an opponent’s departed loved ones or bitter enemies. Those who fail their saves take a –2 penalty on attack rolls for 1d3 rounds. The save DC is Charisma-based.

**Regeneration (Ex):** Chain devils take normal damage from silvered weapons, good-aligned weapons, and spells or effects with the good descriptor. A chain devil that loses a piece of its body regrows it in 2d6x10 minutes. Holding the severed member against the stump enables it to reattach instantly.

**Skills:** Chain devils have a +8 racial bonus on Craft checks involving metalwork.','{"full_attack":"2 chains +10 melee (2d4+2/19–20)","environment":"A lawful evil-aligned plane","organization":"Solitary, gang (2–4), band (6–10), or mob (11–20)","treasure":"Standard","advancement":"9–16 HD (Medium)","level_adjustment":"+6","statblock":{"hit_dice":"8d8+16 (52 hp)","hit_points":52,"base_attack_grapple":"+8/+10","attack":"Chain +10 melee (2d4+2/19–20)","full_attack":"2 chains +10 melee (2d4+2/19–20)","space_reach":"5 ft./5 ft. (10 ft. with chains)","saves":"Fort +8, Ref +8, Will +6","abilities":{"str":"15","dex":"15","con":"15","int":"6","wis":"10","cha":"12"},"skills":"Climb +13, Craft (blacksmithing) +17, Escape Artist +13, Intimidate +12, Listen +13, Spot +13, Use Rope +2 (+4 with bindings)","feats":"Alertness, Improved Critical (chain), Improved Initiative","special_attacks":"Dancing chains, unnerving gaze","special_qualities":"Damage reduction 5/silver or good, darkvision 60 ft., immunity to cold, regeneration 2, spell resistance 18"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('erinyes','Erinyes','Erinyes','8','Medium','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','9d8+45 (85 hp)',85,'+5','30 ft. (6 squares), fly 50 ft. (good)','23 (+5 Dex, +8 natural) touch 15, flat-footed 18','+9/+14','Longsword +14 melee (1d8+5/19–20) or +1 flaming composite longbow (+5 Str bonus) +15 ranged (1d8+6/x3 plus 1d6 fire) or rope +14 ranged (entangle)','5 ft./5 ft.','+11','+11','+10',21,21,21,14,18,20,'Concentration +17, Diplomacy +7, Escape Artist +17, Hide +17, Knowledge (any two) +14, Listen +16, Move Silently +17, Search +14, Sense Motive +16, Spot +16, Survival +4 (+6 following tracks), Use Rope +5 (+7 with bindings)','DodgeB, MobilityB, Point Blank Shot, Precise Shot, Rapid Shot, Shot on the Run','{"special_attacks":"Entangle, spell-like abilities, summon devil","special_qualities":"Damage reduction 5/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 20, telepathy 100 ft., true seeing"}'::jsonb,'Unlike other devils, erinyes appear attractive to humans, resembling very comely women or men. An erinyes stands about 6 feet tall and weighs about 150 pounds.

Erinyes speak Infernal, Celestial, and Draconic.

#### Combat

Erinyes prefer to engage in combat from a distance. They use _charm monster_ to distract or disorganize their opponents, then rain down fiery arrows from above.

An erinyes’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Entangle (Ex):** Each erinyes carries a stout rope some 50 feet long that entangles opponents of any size as an _animate rope_ spell (caster level 16th). An erinyes can hurl its rope 30 feet with no range penalty. Typically, an erinyes entangles a foe, lifts it into the air, and drops it from a great height.

**Spell-Like Abilities:** At will—_greater teleport_ (self plus 50 pounds of objects only), _charm monster_ (DC 19), _minor image_ (DC 17), _unholy blight_ (DC 19). Caster level 12th. The save DCs are Charisma-based.

**_Summon Devil_ (Sp):** Once per day an erinyes can attempt to summon 2d10 lemures or 1d4 bearded devils with a 50% chance of success. This ability is the equivalent of a 3rd-level spell.

**True Seeing (Su):** Erinyes continuously use true seeing, as the spell (caster level 14th).','{"full_attack":"Longsword +14/+9 melee (1d8+5/19–20) or +1 flaming composite longbow (+5 Str bonus) +15/+10 ranged (1d8+6/x3 plus 1d6 fire) or rope +14 ranged (entangle)","environment":"A lawful evil-aligned plane","organization":"Solitary","treasure":"Standard, plus rope and +1 flaming composite longbow (+5 Str bonus)","advancement":"10–18 HD (Medium)","level_adjustment":"+7","statblock":{"hit_dice":"9d8+45 (85 hp)","hit_points":85,"base_attack_grapple":"+9/+14","attack":"Longsword +14 melee (1d8+5/19–20) or +1 flaming composite longbow (+5 Str bonus) +15 ranged (1d8+6/x3 plus 1d6 fire) or rope +14 ranged (entangle)","full_attack":"Longsword +14/+9 melee (1d8+5/19–20) or +1 flaming composite longbow (+5 Str bonus) +15/+10 ranged (1d8+6/x3 plus 1d6 fire) or rope +14 ranged (entangle)","space_reach":"5 ft./5 ft.","saves":"Fort +11, Ref +11, Will +10","abilities":{"str":"21","dex":"21","con":"21","int":"14","wis":"18","cha":"20"},"skills":"Concentration +17, Diplomacy +7, Escape Artist +17, Hide +17, Knowledge (any two) +14, Listen +16, Move Silently +17, Search +14, Sense Motive +16, Spot +16, Survival +4 (+6 following tracks), Use Rope +5 (+7 with bindings)","feats":"DodgeB, MobilityB, Point Blank Shot, Precise Shot, Rapid Shot, Shot on the Run","special_attacks":"Entangle, spell-like abilities, summon devil","special_qualities":"Damage reduction 5/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, see in darkness, spell resistance 20, telepathy 100 ft., true seeing"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('hellcat_bezekira','Hellcat (Bezekira)','Hellcat (Bezekira)','7','Large','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','8d8+24 (60 hp)',60,'+9','40 ft. (8 squares)','21 (–1 size, +5 Dex, +7 natural), touch 14, flat-footed 16','+8/+18','Claw +13 melee (1d8+6)','10 ft./5 ft.','+9','+11','+8',23,21,17,10,14,10,'Balance +16, Climb +17, Hide +13, Jump +21, Listen +17, Move Silently +20, Spot +13, Swim +17','Dodge, Improved Initiative, Track','{"special_attacks":"Improved grab, pounce, rake 1d8+3","special_qualities":"Damage reduction 5/good, darkvision 60 ft., invisible in light, resistance to fire 10, scent, spell resistance 19, telepathy 100 ft."}'::jsonb,'While its appearance suggests it is incorporeal, a hellcats has a corporeal body and can be harmed by physical attacks.

Hellcats use a natural telepathy to communicate with one another and those they encounter. A hellcat measures about 9 feet long and weighs about 900 pounds.

#### Combat

A hellcat can hold its own in combat thanks to sharp claws and wicked fangs. It prefers to leap upon opponents, just as a lion does.

A hellcat’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Improved Grab (Ex):** To use this ability, a hellcat must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a hellcat charges, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +13 melee, damage 1d8+3.

**Invisible in Light (Ex):** A hellcat is invisible in any area lit well enough for a human to see. In a darkened area, it shows up as a faintly glowing outline visible up to 30 feet away (60 feet if the viewer has low-light vision). Magical darkness smothers the glow and conceals the outline.

**Skills:** Hellcats have a +4 racial bonus on Listen and Move Silently checks.','{"full_attack":"2 claws +13 melee (1d8+6) and bite +8 melee (2d8+3)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, or pride (6–10)","treasure":"None","advancement":"9–10 HD (Large); 11–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+8/+18","attack":"Claw +13 melee (1d8+6)","full_attack":"2 claws +13 melee (1d8+6) and bite +8 melee (2d8+3)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +11, Will +8","abilities":{"str":"23","dex":"21","con":"17","int":"10","wis":"14","cha":"10"},"skills":"Balance +16, Climb +17, Hide +13, Jump +21, Listen +17, Move Silently +20, Spot +13, Swim +17","feats":"Dodge, Improved Initiative, Track","special_attacks":"Improved grab, pounce, rake 1d8+3","special_qualities":"Damage reduction 5/good, darkvision 60 ft., invisible in light, resistance to fire 10, scent, spell resistance 19, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('horned_devil_cornugon','Horned Devil (Cornugon)','Horned Devil (Cornugon)','16','Large','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','15d8+105 (172 hp)',172,'+7','20 ft. (4 squares), fly 50 ft. (average)','35 (–1 size, +7 Dex, +19 natural) touch 16, flat-footed 28','+15/+29','Spiked chain +25 melee (2d6+15 plus stun) or claw +24 melee (2d6+10) or tail +24 melee (2d6+10 plus infernal wound)','10 ft./10 ft. (20 ft. with spiked chain)','+16','+16','+15',31,25,25,14,18,22,'Bluff +24, Climb +28, Concentration +24, Diplomacy +10, Disguise +6 (+8 acting), Hide +21, Intimidate +26, Listen +22, Move Silently +23, Search +20, Sense Motive +22, Spot +22, Survival +4 (+6 following tracks)','Cleave, Improved Sunder, Iron Will, Multiattack, Power Attack, Weapon Focus (spiked chain)','{"special_attacks":"Fear aura, infernal wound, spell-like abilities, stun, summon devil","special_qualities":"Damage reduction 10/good and silver, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 28, telepathy 100 ft."}'::jsonb,'A horned devil is 9 feet tall and weighs about 600 pounds.

#### Combat

Horned devils are bold fighters. They rarely retreat, even against overwhelming odds. They love to fight with their spiked chains, usually singling out the most powerful foes to stun and eliminate quickly.

A horned devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Spell-Like Abilities:** At will—_dispel chaos_ (DC 21), _dispel good_ (DC 21), _magic circle against good, greater teleport_ (self plus 50 pounds of objects only); _persistent image_ (DC 21) 3/day—_fireball_ (DC 19), _lightning bolt_ (DC 19). Caster level 15th. The save DCs are Charisma-based.

**Fear Aura (Su):** A horned devil can radiate a 5-foot-radius fear aura as a free action. A creature in the area must succeed on a DC 23 Will save or be affected as though by a _fear_ spell (caster level 15th). A creature that successfully saves cannot be affected again by the same horned devil’s aura for 24 hours. Other devils are immune to the aura. The save DC is Charisma-based.

**Stun (Su):** Whenever a horned devil hits with a spiked chain attack, the opponent must succeed on a DC 27 Fortitude save or be stunned for 1d4 rounds. The save DC is Strength-based. This ability is a function of the horned devil, not of the spiked chain.

**Infernal Wound (Su):** The damage a horned devil deals with its tail attack causes a persistent wound. An injured creature loses 2 additional hit points each round. The wound does not heal naturally and resists healing spells. The continuing hit point loss can be stopped by a DC 24 Heal check, a _cure_ spell, or a _heal_ spell. However, a character attempting to cast a _cure_ spell or a _heal_ spell on a creature damaged by a horned devil’s tail must succeed on a DC 24 caster level check, or the spell has no effect on the injured character. A successful Heal check automatically stops the continuing hit point loss as well as restoring hit points. The check DC is Constitution-based.

**_Summon Devil_ (Sp):** Once per day a horned devil can attempt to summon 2d10 lemures or 1d6 bearded devils with a 50% chance of success, 1d6 barbed devils with a 35% chance of success, or another horned devil with a 20% chance of success. This ability is the equivalent of a 6th-level spell.

**Regeneration (Ex):** A horned devil takes normal damage from good-aligned silvered weapons, and from spells or effects with the good descriptor.','{"full_attack":"Spiked chain +25/+20/+15 melee (2d6+15 plus stun) and bite +22 melee (2d8+5) and tail +22 melee (2d6+5 plus infernal wound); or 2 claws +24 melee (2d6+10) and bite + 22 melee (2d8+5) and tail +22 melee (2d6+5 plus infernal wound)","environment":"A lawful evil-aligned plane","organization":"Solitary, team (2–4), or squad (6–10)","treasure":"Standard coins; double goods; standard items","advancement":"16–20 HD (Large); 21–45 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"15d8+105 (172 hp)","hit_points":172,"base_attack_grapple":"+15/+29","attack":"Spiked chain +25 melee (2d6+15 plus stun) or claw +24 melee (2d6+10) or tail +24 melee (2d6+10 plus infernal wound)","full_attack":"Spiked chain +25/+20/+15 melee (2d6+15 plus stun) and bite +22 melee (2d8+5) and tail +22 melee (2d6+5 plus infernal wound); or 2 claws +24 melee (2d6+10) and bite + 22 melee (2d8+5) and tail +22 melee (2d6+5 plus infernal wound)","space_reach":"10 ft./10 ft. (20 ft. with spiked chain)","saves":"Fort +16, Ref +16, Will +15","abilities":{"str":"31","dex":"25","con":"25","int":"14","wis":"18","cha":"22"},"skills":"Bluff +24, Climb +28, Concentration +24, Diplomacy +10, Disguise +6 (+8 acting), Hide +21, Intimidate +26, Listen +22, Move Silently +23, Search +20, Sense Motive +22, Spot +22, Survival +4 (+6 following tracks)","feats":"Cleave, Improved Sunder, Iron Will, Multiattack, Power Attack, Weapon Focus (spiked chain)","special_attacks":"Fear aura, infernal wound, spell-like abilities, stun, summon devil","special_qualities":"Damage reduction 10/good and silver, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 28, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('ice_devil_gelugon','Ice Devil (Gelugon)','Ice Devil (Gelugon)','13','Large','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','14d8+84 (147 hp)',147,'+5','40 ft. (8 squares)','32 (–1 size, +5 Dex, +18 natural) touch 14, flat-footed 27','+14/+24','Spear +20 melee (2d6+9/x3 plus slow) or claw +19 melee (1d10+6)','10 ft./10 ft.','+15','+14','+15',23,21,23,22,22,20,'Bluff +22, Climb +23, Concentration +23, Diplomacy +9, Disguise +5 (+7 acting), Intimidate +24, Jump +27, Knowledge (any three) +23, Listen +25, Move Silently +22, Search +23, Sense Motive +23, Spellcraft +23, Spot +25, Survival +6 (+8 following tracks)','Alertness, Cleave, Combat Reflexes, Power Attack, Weapon Focus (spear)','{"special_attacks":"Fear aura, slow, spell-like abilities, summon devil","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 25, telepathy 100 ft."}'::jsonb,'An ice devil is about 12 feet tall and weighs about 700 pounds.

#### Combat

An ice devil prefers to fight only when doing so serves its mission, but it never hesitates to attack when it deems a battle necessary—or likely to end in its victory.

An ice devil’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Fear Aura (Su):** An ice devil can radiate a 10-foot-radius fear aura as a free action. A creature in the area must succeed on a DC 22 Will save or be affected as though by a _fear_ spell (caster level 13th). A creature that successfully saves cannot be affected again by the same ice devil’s aura for 24 hours. Other devils are immune to the aura. The save DC is Charisma-based.

**Slow (Su):** A hit from an ice devil’s tail or spear induces numbing cold. The opponent must succeed on a DC 23 Fortitude save or be affected as though by a _slow_ spell for 1d6 rounds. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_cone of cold_ (DC 20), _fly, ice storm_ (DC 19), _greater teleport_ (self plus 50 pounds of objects only), _persistent image_ (DC 20), _unholy aura_ (DC 23), _wall of ice_ (DC 19). Caster level 13th. The save DCs are Charisma-based.

**_Summon Devil_ (Sp):** Once per day an ice devil can attempt to summon 2d10 lemures or 1d6 bearded devils, 2d4 bone devils with a 50% chance of success, or another ice devil with a 20% chance of success. This ability is the equivalent of a 4th-level spell.

**Regeneration (Ex):** An ice devil takes normal damage from good-aligned weapons and from spells or effects with the good descriptor.','{"full_attack":"Spear +20/+15/+10 melee (2d6+9/x3 plus slow) and bite +14 melee (2d6+3) and tail +14 melee (3d6+3 plus slow); or 2 claws +19 melee (1d10+6) and bite +14 melee (2d6+3) and tail +14 melee (3d6+3 plus slow)","environment":"A lawful evil-aligned plane","organization":"Solitary, team (2–4), squad (6–10), or troupe (1–2 ice devils, 7–12 bearded devils, and 1–4 bone devils)","treasure":"Standard coins; double goods; standard items","advancement":"15–28 HD (Large); 29–42 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"14d8+84 (147 hp)","hit_points":147,"base_attack_grapple":"+14/+24","attack":"Spear +20 melee (2d6+9/x3 plus slow) or claw +19 melee (1d10+6)","full_attack":"Spear +20/+15/+10 melee (2d6+9/x3 plus slow) and bite +14 melee (2d6+3) and tail +14 melee (3d6+3 plus slow); or 2 claws +19 melee (1d10+6) and bite +14 melee (2d6+3) and tail +14 melee (3d6+3 plus slow)","space_reach":"10 ft./10 ft.","saves":"Fort +15, Ref +14, Will +15","abilities":{"str":"23","dex":"21","con":"23","int":"22","wis":"22","cha":"20"},"skills":"Bluff +22, Climb +23, Concentration +23, Diplomacy +9, Disguise +5 (+7 acting), Intimidate +24, Jump +27, Knowledge (any three) +23, Listen +25, Move Silently +22, Search +23, Sense Motive +23, Spellcraft +23, Spot +25, Survival +6 (+8 following tracks)","feats":"Alertness, Cleave, Combat Reflexes, Power Attack, Weapon Focus (spear)","special_attacks":"Fear aura, slow, spell-like abilities, summon devil","special_qualities":"Damage reduction 10/good, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 25, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('imp','Imp','Imp','2','Tiny','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','3d8 (13 hp)',13,'+3','20 ft. (4 squares), fly 50 ft. (perfect)','20 (+2 size, +3 Dex, +5 natural), touch 15, flat-footed 17','+3/–5','Sting +8 melee (1d4 plus poison)','2-1/2 ft./0 ft.','+3','+6','+4',10,17,10,10,12,14,'Diplomacy +8, Hide +17, Knowledge (any one) +6, Listen +7, Move Silently +9, Search +6, Spellcraft +6, Spot +7, Survival +1 (+3 following tracks)','Dodge, Weapon Finesse','{"special_attacks":"Poison, spell-like abilities","special_qualities":"Alternate form, damage reduction 5/good or silver, darkvision 60 ft., fast healing 2, immunity to poison, resistance to fire 5"}'::jsonb,'In its natural form, an imp stands almost 2 feet tall and weighs about 8 pounds.

#### Combat

Imps are craven, but not so timid as to pass up an opportunity for a surprise attack using their _invisibility_ and alternate form ability. In its natural form, an imp attacks with the wicked stinger on its tail. It quickly flies out of reach if a foe manages to strike back effectively.

An imp’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Poison (Ex):** Injury, Fortitude DC 13, initial damage 1d4 Dex, secondary damage 2d4 Dex. The save DC is Constitution-based and includes a +2 racial bonus.

**Spell-Like Abilities:** At will—_detect good, detect magic, invisibility_ (self only); 1/day—_suggestion_ (DC 15). Caster level 6th. The save DC is Charisma-based.

Once per week an imp can use _commune_ to ask six questions. The ability otherwise works as the spell (caster level 12th).

**Alternate Form (Su):** An imp can assume other forms at will as a standard action. This ability functions as a _polymorph_ spell cast on itself (caster level 12th), except that an imp does not regain hit points for changing form, and an individual imp can assume only one or two forms no larger than Medium. Common forms include monstrous spider, raven, rat, and boar.','{"full_attack":"Sting +8 melee (1d4 plus poison)","environment":"A lawful evil-aligned plane","organization":"Solitary","treasure":"None","advancement":"4–6 HD (Tiny)","level_adjustment":"— (Improved Familiar)","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+3/–5","attack":"Sting +8 melee (1d4 plus poison)","full_attack":"Sting +8 melee (1d4 plus poison)","space_reach":"2-1/2 ft./0 ft.","saves":"Fort +3, Ref +6, Will +4","abilities":{"str":"10","dex":"17","con":"10","int":"10","wis":"12","cha":"14"},"skills":"Diplomacy +8, Hide +17, Knowledge (any one) +6, Listen +7, Move Silently +9, Search +6, Spellcraft +6, Spot +7, Survival +1 (+3 following tracks)","feats":"Dodge, Weapon Finesse","special_attacks":"Poison, spell-like abilities","special_qualities":"Alternate form, damage reduction 5/good or silver, darkvision 60 ft., fast healing 2, immunity to poison, resistance to fire 5"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('lemure','Lemure','Lemure','1','Medium','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','2d8 (9 hp)',9,'+0','20 ft. (4 squares)','14 (+4 natural) touch 10, flat-footed 14','+2/+2','Claw +2 melee (1d4)','5 ft./5 ft.','+3','+3','+3',10,10,10,null,11,5,'','','{"special_attacks":"—","special_qualities":"Damage reduction 5/good or silver, darkvision 60 ft., immunity to fire and poison, mindless, resistance to acid 10 and cold 10, mindless, see in darkness"}'::jsonb,'A lemure is about 5 feet tall and weighs about 100 pounds.

Lemures are mindless and cannot communicate, but they are sensitive to telepathic messages from other devils, typically obeying a devil’s mental commands.

#### Combat

Lemures surge toward anything they meet and try to claw it apart. Only a telepathic command from other devils or the complete destruction of the lemures can make them stop.

A lemure’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Mindless (Ex):** Immunity to mind-affecting effects (charms, compulsions, phantasms, patterns, and morale effects).','{"full_attack":"2 claws +2 melee (1d4)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, gang (3–5), swarm (6–15), or mob (10–40)","treasure":"None","advancement":"3–6 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"2d8 (9 hp)","hit_points":9,"base_attack_grapple":"+2/+2","attack":"Claw +2 melee (1d4)","full_attack":"2 claws +2 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +3, Will +3","abilities":{"str":"10","dex":"10","con":"10","int":null,"wis":"11","cha":"5"},"skills":"","feats":"","special_attacks":"—","special_qualities":"Damage reduction 5/good or silver, darkvision 60 ft., immunity to fire and poison, mindless, resistance to acid 10 and cold 10, mindless, see in darkness"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('pit_fiend','Pit Fiend','Pit Fiend','20','Large','Outsider (Evil, Extraplanar, Lawful)','Always lawful evil','18d8+144 (225 hp)',225,'+12','40 ft. (8 squares), fly 60 ft. (average)','','+18/+35','Claw +30 melee (2d8+13)','10 ft./10 ft.','+19','+19','+21',37,27,27,26,26,26,'Balance +10, Bluff +29, Climb +34, Concentration +29, Diplomacy +10, Disguise +29 (+31 acting), Hide +25, Intimidate +31, Jump +40, Knowledge (arcana) +29, Knowledge (nature) +10, Knowledge (the planes) +29, Knowledge (religion) +29, Listen +29, Move Silently +29, Search +29, Spellcraft +31, Spot +29, Survival +8 (+10 on other planes, +10 when tracking), Tumble +31','Cleave, Great Cleave, Improved Initiative, Iron Will, Multiattack, Power Attack, Quicken Spell-Like Ability (fireball)','{"special_attacks":"Constrict 2d8+26, fear aura, improved grab, spell-like abilities, summon devil","special_qualities":"Damage reduction 15/good and silver, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 32, telepathy 100 ft."}'::jsonb,'A pit fiend often wraps its wings around itself like a grotesque cloak, and appears wreathed in flames.

A pit fiend is 12 feet tall and weighs 800 pounds.

#### Combat

Pit fiends are wily and resourceful fighters, using _invisibility_ to gain the upper hand and biting at foes seemingly able to see them. They don’t hesitate to blanket an area with _fireballs_, and can call down the wrath of an inferno with _meteor swarm._

A pit fiend’s natural weapons, as well as any weapons it wields, are treated as evil-aligned and lawful-aligned for the purpose of overcoming damage reduction.

**Constrict (Ex):** A pit fiend deals 2d8+26 points of damage with a successful grapple check.

**Disease (Su):** A creature struck by a pit fiend’s bite attack must succeed on a DC 27 Fortitude save or be infected with a vile disease known as devil chills (incubation period 1d4 days, damage 1d4 Str). The save DC is Constitution-based.

**Fear Aura (Su):** A pit fiend can radiate a 20-foot-radius fear aura as a free action. A creature in the area must succeed on a DC 27 Will save or be affected as though by a _fear_ spell (caster level 18th). A creature that successfully saves cannot be affected again by the same pit fiend’s aura for 24 hours. Other devils are immune to the aura. The save DC is Charisma-based.

**Improved Grab (Ex):** To use this ability, a pit fiend must hit with its tail slap attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.

If it wins the grapple check, it establishes a hold and can constrict.

**Poison (Ex):** Injury, Fortitude DC 27, initial damage 1d6 Con, secondary damage death. The save DC is Constitution-based.

**Spell-Like Abilities:** At will—_blasphemy_ (DC 25), _create undead, fireball_ (DC 21), _greater dispel magic, greater teleport_ (self plus 50 pounds of objects only), _invisibility, magic circle against good, mass hold monster_ (DC 27), _persistent image_ (DC 23), _power word stun, unholy aura_ (DC 26); 1/day—_meteor swarm_ (DC 27). Caster level 18th. The save DCs are Charisma-based.

Once per year a pit fiend can use _wish_ as the spell (caster level 20th).

**_Summon Devil_ (Sp):** Twice per day a pit fiend can automatically summon 2 lemures, bone devils, or bearded devils, or 1 erinyes, horned devil, or ice devil. This ability is the equivalent of an 8th-level spell.

**Regeneration (Ex):** A pit fiend takes normal damage from good-aligned silvered weapons, and from spells or effects with the good descriptor.

#### Tactics Round-by-Round

A pit fiend typically opens combat by using its spell-like abilities, attempting to neutralize dangerous opponents before entering melee.

_Prior to combat: Unholy aura_; activate fear aura, _summon devil_.

_Round 1:_ Quickened _fireball_ and _mass hold monster_ if facing three or more visible, active opponents; otherwise _power word stun_ against unarmored opponent (preferably a spellcaster).

_Round 2: Meteor swarm_ against as many foes as possible, approach worst-injured enemy.

_Round 3:_ Full attack against injured enemy.

_Round 4:_ Continue melee against injured enemy, or _power word stun_ against annoying spellcaster.

_Round 5:_ Repeat from round 1, or _greater teleport_ to safety if endangered.','{"full_attack":"2 claws +30 melee (2d8+13) and 2 wings +28 melee (2d6+6) and bite +28 melee (4d6+6 plus poison plus disease) and tail slap +28 melee (2d8+6)","environment":"A lawful evil-aligned plane","organization":"Solitary, pair, team (3–4), or troupe (1–2 pit fiends, 2–5 horned devils, and 2–5 barbed devils)","treasure":"Standard coins; double goods; standard items","advancement":"19–36 HD (Large); 37–54 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"18d8+144 (225 hp)","hit_points":225,"base_attack_grapple":"+18/+35","attack":"Claw +30 melee (2d8+13)","full_attack":"2 claws +30 melee (2d8+13) and 2 wings +28 melee (2d6+6) and bite +28 melee (4d6+6 plus poison plus disease) and tail slap +28 melee (2d8+6)","space_reach":"10 ft./10 ft.","saves":"Fort +19, Ref +19, Will +21","abilities":{"str":"37","dex":"27","con":"27","int":"26","wis":"26","cha":"26"},"skills":"Balance +10, Bluff +29, Climb +34, Concentration +29, Diplomacy +10, Disguise +29 (+31 acting), Hide +25, Intimidate +31, Jump +40, Knowledge (arcana) +29, Knowledge (nature) +10, Knowledge (the planes) +29, Knowledge (religion) +29, Listen +29, Move Silently +29, Search +29, Spellcraft +31, Spot +29, Survival +8 (+10 on other planes, +10 when tracking), Tumble +31","feats":"Cleave, Great Cleave, Improved Initiative, Iron Will, Multiattack, Power Attack, Quicken Spell-Like Ability (fireball)","special_attacks":"Constrict 2d8+26, fear aura, improved grab, spell-like abilities, summon devil","special_qualities":"Damage reduction 15/good and silver, darkvision 60 ft., immunity to fire and poison, resistance to acid 10 and cold 10, regeneration 5, see in darkness, spell resistance 32, telepathy 100 ft."},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('devourer','Devourer','Devourer','11','Large','Undead (Extraplanar)','Always neutral evil','12d12 (78 hp)',78,'+4','30 ft. (6 squares)','24 (–1 size, +15 natural), touch 9, flat-footed 24','+6/+19','Claw +15 melee (1d6+9)','10 ft./10 ft.','+4','+4','+11',28,10,null,16,16,17,'Climb +24, Concentration +18, Diplomacy +5, Jump +24, Listen +18, Move Silently +15, Search +10, Sense Motive +11, Spot +18, Survival +3 (+5 following tracks)','Blind-Fight, Combat Casting, Combat Expertise, Improved Initiative, Weapon Focus (claw)','{"special_attacks":"Energy drain, trap essence, spell-like abilities","special_qualities":"Darkvision 60 ft., spell deflection, spell resistance 21, undead traits"}'::jsonb,'Devourers lurk on the Ethereal Plane and the Astral Plane, stalking both natives and travelers with equal sadistic glee.

A devourer is about 9 feet tall and weighs 500 pounds.

Devourers speak Common.

### Combat

Even if it had no special abilities, a devourer would be a terrible opponent, for its bony claws can flay enemies alive.

**Energy Drain (Su):** Living creatures hit by a devourer’s claw attack or _spectral hand_ ability gain one negative level. The DC is 19 for the Fortitude save to remove a negative level. The save DC is Charisma-based.

**Trap Essence (Su):** The devourer is named for its ability to consume an enemy’s life essence. To do so, it must forgo its normal melee attacks and make a trap essence attack. This requires a normal attack roll but deals no damage. The he save DC is Charisma-based. A slain creature’s essence is trapped within the devourer’s ribs, and the tiny figure takes on that victim’s features. The trapped essence cannot be raised or resurrected, but a _limited wish, miracle,_ or _wish_ spell frees it, as does destroying the devourer. A devourer can hold only one essence at a time.

The trapped essence provides a devourer with enough power to use five spell-like abilities for each Hit Die or level of the trapped creature. As this energy is expended, the twisted soul fades away until it evaporates completely. The trapped essence gains one negative level for every five times the devourer uses one of its spell-like abilities. When the essence’s number of negative levels equals the creature’s total Hit Dice or level, the essence is destroyed. If an essence is freed, the restored creature must succeed on a DC 19 Fortitude save for each negative level or lose that level permanently.

**Spell-Like Abilities:** At the start of any encounter, the trapped essence within a devourer is assumed to have 3d4+3 levels (enough fuel for thirty to seventy-five uses). Once per round, a devourer can use one of the following abilities: _confusion_ (DC 17), _control undead_ (DC 20), _ghoul touch_ (DC 15), _lesser planar ally, ray of enfeeblement_ (DC 14), _spectral hand, suggestion_ (DC 16), _true seeing_. Caster level 18th. The save DCs are Charisma-based.

**Spell Deflection (Su):** The trapped essence provides a measure of magical protection. If any of the following spells are cast at the devourer and overcome its spell resistance, they affect the imprisoned essence instead: _banishment, chaos hammer, confusion, crushing despair, detect thoughts, dispel evil, dominate person, fear, geas/quest, holy word, hypnosis, imprisonment, magic jar, maze, suggestion, trap the soul,_ or any form of charm or compulsion. In many cases, this deflection effectively neutralizes the spell. Some of these effects might eliminate the trapped essence, depriving the devourer of its spell-like abilities until it can consume another victim.','{"full_attack":"2 claws +15 melee (1d6+9)","environment":"Any","organization":"Solitary","treasure":"None","advancement":"13–24 HD (Large); 25–36 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"12d12 (78 hp)","hit_points":78,"base_attack_grapple":"+6/+19","attack":"Claw +15 melee (1d6+9)","full_attack":"2 claws +15 melee (1d6+9)","space_reach":"10 ft./10 ft.","saves":"Fort +4, Ref +4, Will +11","abilities":{"str":"28","dex":"10","con":null,"int":"16","wis":"16","cha":"17"},"skills":"Climb +24, Concentration +18, Diplomacy +5, Jump +24, Listen +18, Move Silently +15, Search +10, Sense Motive +11, Spot +18, Survival +3 (+5 following tracks)","feats":"Blind-Fight, Combat Casting, Combat Expertise, Improved Initiative, Weapon Focus (claw)","special_attacks":"Energy drain, trap essence, spell-like abilities","special_qualities":"Darkvision 60 ft., spell deflection, spell resistance 21, undead traits"},"source_file":"monsters-d-de.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-d-de.html',true),
('digester','Digester','Digester','6','Medium','Magical Beast','Always neutral','8d10+24 (68 hp)',68,'+6','60 ft. (12 squares)','17 (+2 Dex, +5 natural), touch 12, flat-footed 15','+8/+11','Claw +11 melee (1d8+4)','5 ft./5 ft.','+9','+10','+3',17,15,17,2,12,10,'Hide +9, Listen +6, Jump +21, Spot +6','Alertness, Improved Initiative, Lightning Reflexes','{"special_attacks":"Acid spray","special_qualities":"Darkvision 60 ft., immunity to acid, low-light vision, scent"}'::jsonb,'A digester stands about 5 feet tall and is 7 feet long from snout to tail. It weighs about 350 pounds,

### Combat

A digester is a hunting and eating machine. When it is not hungry (which is rarely), it lies low and avoids most other creatures. When hunting, it looks about for a likely target, then charges forth and delivers a gout of acid. If the initial attack is insufficient to kill the prey, the digester attacks with its hind feet until it can spray acid again.

**Acid Spray (Ex):** A digester can spray acid in a 20-foot cone, dealing 4d8 points of damage to everything in the area. Once a digester uses this ability, it can’t use it again until 1d4 rounds later.

The creature can also produce a concentrated stream of acid that deals 8d8 points of damage to a single target within 5 feet. In either case, a DC 17 Reflex save halves the damage. The save DC is Constitution-based.

**Skills:** A digester’s coloration gives it a +4 racial bonus on Hide checks. It also has a +4 racial bonus on Jump checks.','{"full_attack":"Claw +11 melee (1d8+4)","environment":"Warm forests","organization":"Solitary or pack (3–6)","treasure":"None","advancement":"9–12 HD (Medium); 13–24 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d10+24 (68 hp)","hit_points":68,"base_attack_grapple":"+8/+11","attack":"Claw +11 melee (1d8+4)","full_attack":"Claw +11 melee (1d8+4)","space_reach":"5 ft./5 ft.","saves":"Fort +9, Ref +10, Will +3","abilities":{"str":"17","dex":"15","con":"17","int":"2","wis":"12","cha":"10"},"skills":"Hide +9, Listen +6, Jump +21, Spot +6","feats":"Alertness, Improved Initiative, Lightning Reflexes","special_attacks":"Acid spray","special_qualities":"Darkvision 60 ft., immunity to acid, low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('deinonychus','Deinonychus','Deinonychus','3','Large','Animal','Always neutral','4d8+16 (34 hp)',34,'+2','60 ft. (12 squares)','16 (–1 size, +2 Dex, +5 natural), touch 11, flat-footed 14','+3/+11','Talons +6 melee (2d6+4)','10 ft./5 ft.','+8','+6','+2',19,15,19,2,12,10,'Hide +8, Jump +26, Listen +10, Spot +10, Survival +10','Run, Track','{"special_attacks":"Pounce","special_qualities":"Low-light vision, scent"}'::jsonb,'A deinonychus is bright green along its back and flanks, with a much lighter shade of the same color on its underside. The body has darker spots or stripes. Its tail extends straight out behind itself, held aloft by an intricate structure of bony supports, thus allowing its weight to be carried entirely by the back legs. It weighs about 600 pounds.

#### Combat

A deinonychus uses a combination of speed, grasping forearms, large teeth, and hind legs with ripping talons. It hunts by running at prey, leaping, and ripping with its rear talons as it claws and bites. The talons count as one attack. A deinonychus has a relatively large brain for a dinosaur, and its pack hunts with cunning tactics.

**Pounce (Ex):** If a deinonychus charges, it can make a full attack.

**Skills:** A deinonychus has a +8 racial bonus on Hide, Jump, Listen, Spot, and Survival checks.','{"full_attack":"Talons +6 melee (2d6+4) and 2 foreclaws +1 melee (1d3+2) and bite +1 melee (2d4+2)","environment":"Warm forests","organization":"Solitary, pair, or pack (3–6)","treasure":"None","advancement":"5–8 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"4d8+16 (34 hp)","hit_points":34,"base_attack_grapple":"+3/+11","attack":"Talons +6 melee (2d6+4)","full_attack":"Talons +6 melee (2d6+4) and 2 foreclaws +1 melee (1d3+2) and bite +1 melee (2d4+2)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +6, Will +2","abilities":{"str":"19","dex":"15","con":"19","int":"2","wis":"12","cha":"10"},"skills":"Hide +8, Jump +26, Listen +10, Spot +10, Survival +10","feats":"Run, Track","special_attacks":"Pounce","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('elasmosaurus','Elasmosaurus','Elasmosaurus','7','Huge','Animal','Always neutral','10d8+66 (111 hp)',111,'+2','20 ft. (4 squares), swim 50 ft.','13 (–2 size, +2 Dex, +3 natural), touch 10, flat-footed 11','+7/+23','Bite +13 melee (2d8+12)','15 ft./10 ft.','+15','+9','+4',26,14,22,2,13,9,'Hide –4*, Listen +4, Spot +9, Swim +16','Dodge, Great Fortitude, Toughness (2)','{"special_attacks":"","special_qualities":"Low-light vision, scent"}'::jsonb,'Though it resides primarily in the water, an elasmosaurus only breathes air. An elasmosaurus has a total length of some 30 feet, including a tail half as long as its entire body, and weighs about 5,000 pounds. Observers who see only its head or tail might easily mistake it for a massive snake.

#### Combat

An elasmosaurus is aggressive and attacks anything it notices. The creature is strong, fast, and highly maneuverable, able to turn quickly and lunge at prey. When hunting, it travels with its head out of the water, snapping down quickly to seize prey.

**Skills:** \*An elasmosaurus has a +8 racial bonus on Hide checks in water.','{"full_attack":"Bite +13 melee (2d8+12)","environment":"Warm aquatic","organization":"Solitary, pair, or herd (5–8)","treasure":"None","advancement":"11–20 HD (Huge); 21–30 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"10d8+66 (111 hp)","hit_points":111,"base_attack_grapple":"+7/+23","attack":"Bite +13 melee (2d8+12)","full_attack":"Bite +13 melee (2d8+12)","space_reach":"15 ft./10 ft.","saves":"Fort +15, Ref +9, Will +4","abilities":{"str":"26","dex":"14","con":"22","int":"2","wis":"13","cha":"9"},"skills":"Hide –4*, Listen +4, Spot +9, Swim +16","feats":"Dodge, Great Fortitude, Toughness (2)","special_attacks":"","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('megaraptor','Megaraptor','Megaraptor','6','Huge','Animal','Always neutral','8d8+43 (79 hp)',79,'+2','60 ft. (12 squares)','16 (–2 size, +2 Dex, +6 natural), touch 10, flat-footed 14','+6/+19','Talons +9 melee (2d8+5)','15 ft./10 ft.','+10','+8','+4',21,15,21,2,15,10,'Hide +5, Jump +27, Listen +12, Spot +12, Survival +12','Run, Toughness, Track','{"special_attacks":"Pounce","special_qualities":"Low-light vision, scent"}'::jsonb,'This creature is a larger version of the deinonychus, standing about 12 feet tall with a total length of 24 feet. It has the same appearance, habits, and abilities of the smaller version.

**Pounce (Ex):** If a megaraptor charges, it can make a full attack.

**Skills:** A megaraptor has a +8 racial bonus on Hide, Jump, Listen, Spot, and Survival checks.','{"full_attack":"Talons +9 melee (2d8+5) and 2 foreclaws +4 melee (1d4+2) and bite +4 melee (2d6+2)","environment":"Warm forests","organization":"Solitary, pair, or pack (3–6)","treasure":"None","advancement":"9–16 HD (Huge); 17–24 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"8d8+43 (79 hp)","hit_points":79,"base_attack_grapple":"+6/+19","attack":"Talons +9 melee (2d8+5)","full_attack":"Talons +9 melee (2d8+5) and 2 foreclaws +4 melee (1d4+2) and bite +4 melee (2d6+2)","space_reach":"15 ft./10 ft.","saves":"Fort +10, Ref +8, Will +4","abilities":{"str":"21","dex":"15","con":"21","int":"2","wis":"15","cha":"10"},"skills":"Hide +5, Jump +27, Listen +12, Spot +12, Survival +12","feats":"Run, Toughness, Track","special_attacks":"Pounce","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('triceratops','Triceratops','Triceratops','9','Huge','Animal','Always neutral','16d8+124 (196 hp)',196,'–1','30 ft. (6 squares)','18 (–2 size, –1 Dex, +11 natural), touch 7, flat-footed 18','+12/+30','Gore +20 melee (2d8+15)','15 ft./10 ft.','+19','+9','+6',30,9,25,1,12,7,'Listen +13, Spot +12','Alertness, Great Fortitude, Toughness (4)','{"special_attacks":"Powerful charge, trample 2d12+15","special_qualities":"Low-light vision, scent"}'::jsonb,'A triceratops has a body about 25 feet long and weighs about 20,000 pounds.

#### Combat

These creatures are likely to charge and skewer any creature of at least Large size that infringes on their territory. A triceratops uses its trample attack on smaller opponents.

**Powerful Charge (Ex):** When a triceratops charges, its gore attack deals 4d8+20 points of damage.

**Trample (Ex):** Reflex half DC 28. The save DC is Strength-based.','{"full_attack":"Gore +20 melee (2d8+15)","environment":"Temperate plains","organization":"Solitary, pair, or herd (5–8)","treasure":"None","advancement":"17–32 HD (Huge); 33–48 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"16d8+124 (196 hp)","hit_points":196,"base_attack_grapple":"+12/+30","attack":"Gore +20 melee (2d8+15)","full_attack":"Gore +20 melee (2d8+15)","space_reach":"15 ft./10 ft.","saves":"Fort +19, Ref +9, Will +6","abilities":{"str":"30","dex":"9","con":"25","int":"1","wis":"12","cha":"7"},"skills":"Listen +13, Spot +12","feats":"Alertness, Great Fortitude, Toughness (4)","special_attacks":"Powerful charge, trample 2d12+15","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('tyrannosaurus','Tyrannosaurus','Tyrannosaurus','8','Huge','Animal','Always neutral','18d8+99 (180 hp)',180,'+1','40 ft. (8 squares)','14 (–2 size, +1 Dex, +5 natural) touch 9, flat-footed 13','+13/+30','Bite +20 melee (3d6+13)','15 ft./10 ft.','+16','+12','+8',28,12,21,2,15,10,'Hide –2, Listen +14, Spot +14','Alertness, Improved Natural Attack (bite), Run, Toughness (3), Track','{"special_attacks":"Improved grab, swallow whole","special_qualities":"Low-light vision, scent"}'::jsonb,'Despite its enormous size and 6-ton weight, a tyrannosaurus is a swift runner. Its head is nearly 6 feet long, and its teeth are from 3 to 6 inches in length. It is slightly more than 30 feet long from nose to tail.

#### Combat

A tyrannosaurus pursues and eats just about anything it sees. Its tactics are simple—charge in and bite.

**Improved Grab (Ex):** To use this ability, a tyrannosaurus must hit an opponent of up to one size smaller with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can try to swallow the foe the following round.

**Swallow Whole (Ex):** A tyrannosaurus can try to swallow a grabbed opponent of up to two sizes smaller by making a successful grapple check. The swallowed creature takes 2d8+8 points of bludgeoning damage and 8 points of acid damage per round from the tyrannosaurus’s gizzard. A swallowed creature can cut its way out by using a light slashing or piercing weapon to deal 25 points of damage to the gizzard (AC 12). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out.

A Huge tyrannosaurus’s gizzard can hold 2 Medium, 8 Small, 32 Tiny, or 128 Diminutive or smaller opponents.

**Skills:** A tyrannosaurus has a +2 racial bonus on Listen and Spot checks.','{"full_attack":"Bite +20 melee (3d6+13)","environment":"Warm plains","organization":"Solitary or pair","treasure":"None","advancement":"19–36 HD (Huge); 37–54 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"18d8+99 (180 hp)","hit_points":180,"base_attack_grapple":"+13/+30","attack":"Bite +20 melee (3d6+13)","full_attack":"Bite +20 melee (3d6+13)","space_reach":"15 ft./10 ft.","saves":"Fort +16, Ref +12, Will +8","abilities":{"str":"28","dex":"12","con":"21","int":"2","wis":"15","cha":"10"},"skills":"Hide –2, Listen +14, Spot +14","feats":"Alertness, Improved Natural Attack (bite), Run, Toughness (3), Track","special_attacks":"Improved grab, swallow whole","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_ape','Dire Ape','Dire Ape','3','Large','Animal','Always neutral','5d8+13 (35 hp)',35,'+2','30 ft. (6 squares), climb 15 ft.','15 (–1 size, +2 Dex, +4 natural), touch 11, flat-footed 13','+3/+13','Claw +8 melee (1d6+6)','10 ft./10 ft.','+6','+6','+5',22,15,14,2,12,7,'Climb +14, Listen +5, Move Silently +4, Spot +6','Alertness, Toughness','{"special_attacks":"Rend 2d6+9","special_qualities":"Low-light vision, scent"}'::jsonb,'A dire ape stands about 9 feet tall and weighs from 800 to 1,200 pounds.

#### Combat

Dire apes attack anything that enters their territory, even other dire apes. If an opponent’s armor foils a dire ape’s attacks, the creature will attempt to grapple and pin, then rend the prone opponent.

**Rend (Ex):** A dire ape that hits with both claw attacks latches onto the opponent’s body and tears the flesh. This attack automatically deals an extra 2d6+12 points of damage.

**Skills:** Dire apes have a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.','{"full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d8+3)","environment":"Warm forests","organization":"Solitary or company (5–8)","treasure":"None","advancement":"6–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"5d8+13 (35 hp)","hit_points":35,"base_attack_grapple":"+3/+13","attack":"Claw +8 melee (1d6+6)","full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d8+3)","space_reach":"10 ft./10 ft.","saves":"Fort +6, Ref +6, Will +5","abilities":{"str":"22","dex":"15","con":"14","int":"2","wis":"12","cha":"7"},"skills":"Climb +14, Listen +5, Move Silently +4, Spot +6","feats":"Alertness, Toughness","special_attacks":"Rend 2d6+9","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_badger','Dire Badger','Dire Badger','2','Medium','Animal','Always neutral','3d8+15 (28 hp)',28,'+3','30 ft. (6 squares), burrow 10 ft.','16 (+3 Dex, +3 natural), touch 13, flat-footed 13','+2/+4','Claw +4 melee (1d4+2)','5 ft./5 ft.','+7','+6','+4',14,17,19,2,12,10,'Listen +6, Spot +6','Alertness, Toughness, TrackB','{"special_attacks":"Rage","special_qualities":"Low-light vision, scent"}'::jsonb,'These vicious creatures tolerate no intrusions. They cannot burrow into solid rock, but can move through just about any material softer than that. A dire badger usually leaves behind a usable tunnel 5 feet in diameter when burrowing unless the material it’s moving through is very loose.

A dire badger is from 5 to 7 feet in length and can weigh up to 500 pounds.

#### Combat

Dire badgers attack with their sharp claws and teeth.

**Rage (Ex):** A dire badger that takes damage in combat flies into a berserk rage on its next turn, clawing and biting madly until either it or its opponent is dead. It gains +4 Strength, +4 Constitution, and –2 AC. The creature cannot end its rage voluntarily.','{"full_attack":"2 claws +4 melee (1d4+2) and bite –1 melee (1d6+1)","environment":"Temperate forests","organization":"Solitary or cete (2–5)","treasure":"None","advancement":"4–9 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"3d8+15 (28 hp)","hit_points":28,"base_attack_grapple":"+2/+4","attack":"Claw +4 melee (1d4+2)","full_attack":"2 claws +4 melee (1d4+2) and bite –1 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +6, Will +4","abilities":{"str":"14","dex":"17","con":"19","int":"2","wis":"12","cha":"10"},"skills":"Listen +6, Spot +6","feats":"Alertness, Toughness, TrackB","special_attacks":"Rage","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_bat','Dire Bat','Dire Bat','2','Large','Animal','Always neutral','4d8+12 (30 hp)',30,'+6','20 ft. (4 squares), fly 40 ft. (good)','20 (–1 size, +6 Dex, +5 natural), touch 15, flat-footed 14','+3/+10','Bite +5 melee (1d8+4)','10 ft./5 ft.','+7','+10','+6',17,22,17,2,14,6,'Hide +4, Listen +12*, Move Silently +11, Spot +8*','Alertness, Stealthy','{"special_attacks":"—","special_qualities":"Blindsense 40 ft."}'::jsonb,'A dire bat has a wingspan of 15 feet and weighs about 200 pounds.

#### Combat

Dire bats swoop down upon unsuspecting prey from above.

**Blindsense (Ex):** A dire bat uses echolocation to pinpoint creatures within 40 feet. Opponents still have total concealment against the bat unless it can actually see them.

**Skills:** Dire bats have a +4 racial bonus on Spot and Listen checks. These bonuses are lost if its blindsense is negated.','{"full_attack":"Bite +5 melee (1d8+4)","environment":"Temperate deserts","organization":"Solitary or colony (5–8)","treasure":"None","advancement":"5–12 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"4d8+12 (30 hp)","hit_points":30,"base_attack_grapple":"+3/+10","attack":"Bite +5 melee (1d8+4)","full_attack":"Bite +5 melee (1d8+4)","space_reach":"10 ft./5 ft.","saves":"Fort +7, Ref +10, Will +6","abilities":{"str":"17","dex":"22","con":"17","int":"2","wis":"14","cha":"6"},"skills":"Hide +4, Listen +12*, Move Silently +11, Spot +8*","feats":"Alertness, Stealthy","special_attacks":"—","special_qualities":"Blindsense 40 ft."},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_bear','Dire Bear','Dire Bear','7','Large','Animal','Always neutral','12d8+51 (105 hp)',105,'+1','40 ft. (8 squares)','17 (–1 size, +1 Dex, +7 natural), touch 10, flat-footed 16','+9/+23','Claw +19 melee (2d4+10)','10 ft./5 ft.','+12','+9','+9',31,13,19,2,12,10,'Listen +10, Spot +10, Swim +13','Alertness, Endurance, Run, Toughness, Weapon Focus (claw)','{"special_attacks":"Improved grab","special_qualities":"Low-light vision, scent"}'::jsonb,'The omnivorous dire bear usually does not bother creatures that try to avoid it, but will aggressively defend a kill or other source of food. It will not hesitate to rip apart anything that might contain something edible.

A typical dire bear is 12 feet long and weighs as much as 8,000 pounds.

#### Combat

A dire bear attacks by tearing at opponents with its claws.

**Improved Grab (Ex):** To use this ability, a dire bear must hit with a claw attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity.','{"full_attack":"2 claws +19 melee (2d4+10) and bite +13 melee (2d8+5)","environment":"Cold forests","organization":"Solitary or pair","treasure":"None","advancement":"13–16 HD (Large); 17–36 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"12d8+51 (105 hp)","hit_points":105,"base_attack_grapple":"+9/+23","attack":"Claw +19 melee (2d4+10)","full_attack":"2 claws +19 melee (2d4+10) and bite +13 melee (2d8+5)","space_reach":"10 ft./5 ft.","saves":"Fort +12, Ref +9, Will +9","abilities":{"str":"31","dex":"13","con":"19","int":"2","wis":"12","cha":"10"},"skills":"Listen +10, Spot +10, Swim +13","feats":"Alertness, Endurance, Run, Toughness, Weapon Focus (claw)","special_attacks":"Improved grab","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_boar','Dire Boar','Dire Boar','4','Large','Animal','Always neutral','7d8+21 (52 hp)',52,'+0','40 ft. (8 squares)','15 (–1 size, +6 natural), touch 9, flat-footed 15','+5/+17','Gore +12 melee (1d8+12)','10 ft./5 ft.','+8','+5','+8',27,10,17,2,13,8,'Listen +8, Spot +8','Alertness, Endurance, Iron Will','{"special_attacks":"Ferocity","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire boars are omnivorous and spend most of their time rooting around, much as ordinary pigs do. They viciously attack anything that approaches them, however.

Dire boars grow up to 12 feet long and weigh as much as 2,000 pounds.

#### Combat

A dire boar charges its opponent, trying to rip the target open with its tusks.

**Ferocity (Ex):** A dire boar is such a tenacious combatant that it continues to fight without penalty even while disabled or dying.','{"full_attack":"Gore +12 melee (1d8+12)","environment":"Temperate forests","organization":"Solitary or herd (5–8)","treasure":"None","advancement":"8–16 HD (Large); 17–21 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"7d8+21 (52 hp)","hit_points":52,"base_attack_grapple":"+5/+17","attack":"Gore +12 melee (1d8+12)","full_attack":"Gore +12 melee (1d8+12)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +5, Will +8","abilities":{"str":"27","dex":"10","con":"17","int":"2","wis":"13","cha":"8"},"skills":"Listen +8, Spot +8","feats":"Alertness, Endurance, Iron Will","special_attacks":"Ferocity","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_lion','Dire Lion','Dire Lion','5','Large','Animal','Always neutral','8d8+24 (60 hp)',60,'+2','40 ft. (8 squares)','15 (–1 size, +2 Dex, +4 natural), touch 11, flat-footed 13','+6/+17','Claw +13 melee (1d6+7)','10 ft./5 ft.','+9','+8','+7',25,15,17,2,12,10,'Hide +2*, Listen +7, Move Silently +5, Spot +7','Alertness, Run, Weapon Focus (claw)','{"special_attacks":"Improved grab, pounce, rake 1d6+3","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire lions are patient hunters, just like their smaller cousins, but apt to take on bigger prey.

Dire lions grow to be up to 15 feet long and weigh up to 3,500 pounds.

#### Combat

A dire lion attacks by running at prey, leaping, and clawing and biting as it rakes with its rear claws. It often jumps onto a creature larger than itself.

**Improved Grab (Ex):** To use this ability, a dire lion must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a dire lion charges, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +12 melee, damage 1d6+3.

**Skills:** Dire lions have a +4 racial bonus on Hide and Move Silently checks.

\*In areas of tall grass or heavy undergrowth, the Hide bonus improves to +8.','{"full_attack":"2 claws +13 melee (1d6+7) and bite +7 melee (1d8+3)","environment":"Warm plains","organization":"Solitary, pair, or pride (6–10)","treasure":"None","advancement":"9–16 HD (Large); 17–24 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+6/+17","attack":"Claw +13 melee (1d6+7)","full_attack":"2 claws +13 melee (1d6+7) and bite +7 melee (1d8+3)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +8, Will +7","abilities":{"str":"25","dex":"15","con":"17","int":"2","wis":"12","cha":"10"},"skills":"Hide +2*, Listen +7, Move Silently +5, Spot +7","feats":"Alertness, Run, Weapon Focus (claw)","special_attacks":"Improved grab, pounce, rake 1d6+3","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_rat','Rato atroz (rato gigante)','Dire Rat','1/3','Small','Animal','Always neutral','1d8+1 (5 hp)',5,'+3','40 ft. (8 squares), climb 20 ft.','15 (+1 size, +3 Dex, +1 natural), touch 14, flat-footed 12','+0/–4','Bite +4 melee (1d4 plus disease)','5 ft./5 ft.','+3','+5','+3',10,17,12,1,12,4,'Climb +11, Hide +8, Listen +4, Move Silently +4, Spot +4, Swim +11','Alertness, Weapon FinesseB','{"special_attacks":"Disease","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire rats are omnivorous scavengers, but will attack to defend their nests and territories.

A dire rat can grow to be up to 4 feet long and weigh over 50 pounds.

#### Combat

Dire rat packs attack fearlessly, biting and chewing with their sharp incisors.

**Disease (Ex):** Filth fever—bite, Fortitude DC 11, incubation period 1d3 days, damage 1d3 Dex and 1d3 Con. The save DC is Constitution-based.

**Skills:** Dire rats have a +8 racial bonus on Swim checks. Dire rats have a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.

Dire rats use their Dexterity modifier for Climb and Swim checks.','{"full_attack":"Bite +4 melee (1d4 plus disease)","environment":"Any","organization":"Solitary or pack (11–20)","treasure":"None","advancement":"2–3 HD (Small); 4–6 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"1d8+1 (5 hp)","hit_points":5,"base_attack_grapple":"+0/–4","attack":"Bite +4 melee (1d4 plus disease)","full_attack":"Bite +4 melee (1d4 plus disease)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +5, Will +3","abilities":{"str":"10","dex":"17","con":"12","int":"1","wis":"12","cha":"4"},"skills":"Climb +11, Hide +8, Listen +4, Move Silently +4, Spot +4, Swim +11","feats":"Alertness, Weapon FinesseB","special_attacks":"Disease","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_shark','Dire Shark','Dire Shark','9','Huge','Animal (Aquatic)','Always neutral','18d8+66 (147 hp)',147,'+2','Swim 60 ft. (12 squares)','17 (–2 size, +2 Dex, +7 natural), touch 10, flat-footed 15','+13/+27','Bite +18 melee (2d8+9)','15 ft./10 ft.','+14','+13','+12',23,15,17,1,12,10,'Listen +12, Spot +11, Swim +14','Improved Natural Attack (bite), Toughness (4), Weapon Focus (bite)','{"special_attacks":"Improved grab, swallow whole","special_qualities":"Keen scent"}'::jsonb,'Dire sharks attack anything they perceive to be edible, even larger creatures.

This monstrous fish can grow to a length of 25 feet and weigh more than 20,000 pounds.

#### Combat

Dire sharks bite with their powerful jaws, swallowing smaller creatures in one gulp.

**Improved Grab (Ex):** To use this ability, a dire shark must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can try to swallow the foe in the following round.

**Swallow Whole (Ex):** A dire shark can try to swallow a grabbed opponent of up to one size smaller by making a successful grapple check. Once inside, the opponent takes 2d6+6 points of bludgeoning damage plus 1d8+4 points of acid damage per round from the shark’s digestive juices. A swallowed creature can cut its way out using a light slashing or piercing weapon by dealing 25 points of damage to the shark’s digestive tract (AC 13). Once the creature exits, muscular action closes the hole; another swallowed opponent must cut its own way out.

A Huge dire shark’s gullet can hold 2 Large, 8 Medium or Small, 32 Tiny, 128 Diminutive, or 512 Fine or smaller opponents.

**Keen Scent (Ex):** A dire shark can notice creatures by scent in a 180-foot radius and can detect blood in the water at a range of up to 1 mile.

**Skills:** A dire shark has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered.

It can use the run action while swimming, provided it swims in a straight line.','{"full_attack":"Bite +18 melee (2d8+9)","environment":"Cold aquatic","organization":"Solitary or school (2–5)","treasure":"None","advancement":"19–32 (Huge); 33–54 (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"18d8+66 (147 hp)","hit_points":147,"base_attack_grapple":"+13/+27","attack":"Bite +18 melee (2d8+9)","full_attack":"Bite +18 melee (2d8+9)","space_reach":"15 ft./10 ft.","saves":"Fort +14, Ref +13, Will +12","abilities":{"str":"23","dex":"15","con":"17","int":"1","wis":"12","cha":"10"},"skills":"Listen +12, Spot +11, Swim +14","feats":"Improved Natural Attack (bite), Toughness (4), Weapon Focus (bite)","special_attacks":"Improved grab, swallow whole","special_qualities":"Keen scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_tiger','Dire Tiger','Dire Tiger','8','Large','Animal','Always neutral','16d8+48 (120 hp)',120,'+2','40 ft. (8 squares)','17 (–1 size, +2 Dex, +6 natural), touch 11, flat-footed 15','+12/+24','Claw +20 melee (2d4+8)','10 ft./5 ft.','+13','+12','+11',27,15,17,2,12,10,'Hide +7*, Jump +14, Listen +6, Move Silently +11, Spot +7, Swim +10','Alertness, Improved Natural Attack (claw), Improved Natural Attack (bite), Run, Stealthy, Weapon Focus (claw)','{"special_attacks":"Improved grab, pounce, rake 2d4+4","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire tigers prey on just about anything that moves. They will patiently stalk a potential meal, striking whenever the creature lets down its guard.

Dire tigers grow to be over 12 feet long and can weigh up to 6,000 pounds.

#### Combat

A dire tiger attacks by running at prey, leaping, and clawing and biting as it rakes with its rear claws.

**Improved Grab (Ex):** To use this ability, a dire tiger must hit with its bite attack. It can then attempt to start a grapple as a free action without provoking an attack of opportunity. If it wins the grapple check, it establishes a hold and can rake.

**Pounce (Ex):** If a dire tiger charges, it can make a full attack, including two rake attacks.

**Rake (Ex):** Attack bonus +18 melee, damage 2d4+4.

**Skills:** Dire tigers have a +4 racial bonus on Hide and Move Silently checks. \*In areas of tall grass or heavy undergrowth, the Hide bonus improves to +8.','{"full_attack":"2 claws +20 melee (2d4+8) and bite +14 melee (2d6+4)","environment":"Warm forests","organization":"Solitary or pair","treasure":"None","advancement":"17–32 HD (Large); 33–48 (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+48 (120 hp)","hit_points":120,"base_attack_grapple":"+12/+24","attack":"Claw +20 melee (2d4+8)","full_attack":"2 claws +20 melee (2d4+8) and bite +14 melee (2d6+4)","space_reach":"10 ft./5 ft.","saves":"Fort +13, Ref +12, Will +11","abilities":{"str":"27","dex":"15","con":"17","int":"2","wis":"12","cha":"10"},"skills":"Hide +7*, Jump +14, Listen +6, Move Silently +11, Spot +7, Swim +10","feats":"Alertness, Improved Natural Attack (claw), Improved Natural Attack (bite), Run, Stealthy, Weapon Focus (claw)","special_attacks":"Improved grab, pounce, rake 2d4+4","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_weasel','Dire Weasel','Dire Weasel','2','Medium','Animal','Always neutral','3d8 (13 hp)',13,'+4','40 ft. (8 squares)','16 (+4 Dex, +2 natural), touch 14, flat-footed 12','+2/+4','Bite +6 melee (1d6+3)','5 ft./5 ft.','+3','+7','+4',14,19,10,2,12,11,'Hide +8, Listen +3, Move Silently +8, Spot +5','Alertness, Stealthy , Weapon FinesseB','{"special_attacks":"Attach, blood drain","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire weasels grow to be up to 10 feet long and can reach a weight of 700 pounds.

#### Combat

Dire weasels stalk their prey in the dark and then leap on it, biting and clawing.

**Attach (Ex):** A dire weasel that hits with its bite attack latches onto the opponent’s body with its powerful jaws. An attached dire weasel loses its Dexterity bonus to AC and thus has an AC of 12. An attached dire weasel can be struck with a weapon or grappled itself. To remove an attached dire weasel through grappling, the opponent must achieve a pin against the creature.

**Blood Drain (Ex):** A dire weasel drains blood for 1d4 points of Constitution damage each round it remains attached.','{"full_attack":"Bite +6 melee (1d6+3)","environment":"Temperate hills","organization":"Solitary or pair","treasure":"None","advancement":"4–6 HD (Medium); 7–9 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"3d8 (13 hp)","hit_points":13,"base_attack_grapple":"+2/+4","attack":"Bite +6 melee (1d6+3)","full_attack":"Bite +6 melee (1d6+3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +7, Will +4","abilities":{"str":"14","dex":"19","con":"10","int":"2","wis":"12","cha":"11"},"skills":"Hide +8, Listen +3, Move Silently +8, Spot +5","feats":"Alertness, Stealthy , Weapon FinesseB","special_attacks":"Attach, blood drain","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_wolf','Dire Wolf','Dire Wolf','3','Large','Animal','Always neutral','6d8+18 (45 hp)',45,'+2','50 ft. (10 squares)','14 (–1 size, +2 Dex, +3 natural), touch 11, flat-footed 12','+4/+15','Bite +11 melee (1d8+10)','10 ft./5 ft.','+8','+7','+6',25,15,17,2,12,10,'Hide +0, Listen +7, Move Silently +4, Spot +7, Survival +2*','Alertness, Run, TrackB, Weapon Focus (bite)','{"special_attacks":"Trip","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire wolves are efficient pack hunters that will kill anything they can catch.

Dire wolves are mottled gray or black, about 9 feet long and weighing some 800 pounds.

#### Combat

Dire wolves prefer to attack in packs, surrounding and flanking a foe when they can.

**Trip (Ex):** A dire wolf that hits with a bite attack can attempt to trip its opponent (+11 check modifier) as a free action without making a touch attack or provoking an attack of opportunity. If the attempt fails, the opponent cannot react to trip the dire wolf.

**Skills:** A dire wolf has a +2 racial bonus on Hide, Listen, Move Silently, and Spot checks.

\*It also has a +4 racial bonus on Survival checks when tracking by scent.','{"full_attack":"Bite +11 melee (1d8+10)","environment":"Temperate forests","organization":"Solitary or pack (5–8)","treasure":"None","advancement":"7–18 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+4/+15","attack":"Bite +11 melee (1d8+10)","full_attack":"Bite +11 melee (1d8+10)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +7, Will +6","abilities":{"str":"25","dex":"15","con":"17","int":"2","wis":"12","cha":"10"},"skills":"Hide +0, Listen +7, Move Silently +4, Spot +7, Survival +2*","feats":"Alertness, Run, TrackB, Weapon Focus (bite)","special_attacks":"Trip","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dire_wolverine','Dire Wolverine','Dire Wolverine','4','Large','Animal','Always neutral','5d8+23 (45 hp)',45,'+3','30 ft. (6 squares), climb 10 ft.','16 (–1 size, +3 Dex, +4 natural), touch 12, flat-footed 13','+3/+13','Claw +8 melee (1d6+6)','10 ft./5 ft.','+8','+7','+5',22,17,19,2,12,10,'Climb +14, Listen +7, Spot +7','Alertness, Toughness, TrackB','{"special_attacks":"Rage","special_qualities":"Low-light vision, scent"}'::jsonb,'Dire wolverines grow to about 12 feet in length and can weigh as much as 2,000 pounds.

#### Combat

Dire wolverines attack opponents wantonly, fearing no other creatures.

**Rage (Ex):** A dire wolverine that takes damage in combat flies into a berserk rage on its next turn, clawing and biting madly until either it or its opponent is dead. An enraged dire wolverine gains +4 Strength, +4 Constitution, and –2 AC. The creature cannot end its rage voluntarily.

**Skills:** A dire wolverine has a +8 racial bonus on Climb checks and can always choose to take 10 on Climb checks, even if rushed or threatened.','{"full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d8+3)","environment":"Cold forests","organization":"Solitary or pair","treasure":"None","advancement":"6–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"5d8+23 (45 hp)","hit_points":45,"base_attack_grapple":"+3/+13","attack":"Claw +8 melee (1d6+6)","full_attack":"2 claws +8 melee (1d6+6) and bite +3 melee (1d8+3)","space_reach":"10 ft./5 ft.","saves":"Fort +8, Ref +7, Will +5","abilities":{"str":"22","dex":"17","con":"19","int":"2","wis":"12","cha":"10"},"skills":"Climb +14, Listen +7, Spot +7","feats":"Alertness, Toughness, TrackB","special_attacks":"Rage","special_qualities":"Low-light vision, scent"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('doppelganger','Doppelganger','Doppelganger','3','Medium','Monstrous Humanoid (Shapechanger)','Usually neutral','4d8+4 (22 hp)',22,'+1','30 ft. (6 squares)','15 (+1 Dex, +4 natural), touch 11, flat-footed 14','+4/+5','Slam +5 melee (1d6+1)','5 ft./5 ft.','+4','+5','+6',12,13,12,13,14,13,'Bluff +10*, Diplomacy +3, Disguise +9* (+11 acting), Intimidate +3, Listen +6, Sense Motive +6, Spot +6','Dodge, Great Fortitude','{"special_attacks":"Detect thoughts","special_qualities":"Change shape, immunity to sleep and charm effects"}'::jsonb,'Doppelgangers are strange beings that are able to take on the shapes of those they encounter. In its natural form, the creature looks more or less humanoid, but slender and frail, with gangly limbs and half-formed features. The flesh is pale and hairless. Its large, bulging eyes are yellow with slitted pupils. A doppelganger’s appearance is deceiving even when it’s in its true form. A doppelganger is hardy, with a natural agility not in keeping with its frail appearance.

Doppelgangers make excellent use of their natural mimicry to stage ambushes, bait traps, and infiltrate humanoid society. Although not usually evil, they are interested only in themselves and regard all others as playthings to be manipulated and deceived.

It is natural form a doppelganger is about 5-1/2 feet tall and weighs about 150 pounds.

### Combat

When in its natural form, a doppelganger strikes with its powerful fists. In the shape of a warrior or some other armed person, it attacks with whatever weapon is appropriate. In such cases, it uses its detect thoughts ability to employ the same tactics and strategies as the person it is impersonating.

**Detect Thoughts (Su):** A doppelganger can continuously use detect thoughts as the spell (caster level 18th; Will DC 13 negates). It can suppress or resume this ability as a free action. The save DC is Charisma-based.

**Change Shape (Su):** A doppelganger can assume the shape of any Small or Medium humanoid. In humanoid form, the doppelganger loses its natural attacks. A doppelganger can remain in its humanoid form until it chooses to assume a new one. A change in form cannot be dispelled, but a doppelganger reverts to its natural form when killed. A _true seeing_ spell or ability reveals its natural form.

**Skills:** A doppelganger has a +4 racial bonus on Bluff and Disguise checks.

\*When using its change shape ability, a doppelganger gets an additional +10 circumstance bonus on Disguise checks. If it can read an opponent’s mind, it gets a further +4 circumstance bonus on Bluff and Disguise checks.

### Doppelgangers as Characters

Doppelganger characters possess the following racial traits.

— +2 Strength, +2, Dexterity, +2 Constitution, +2 Intelligence, +4 Wisdom, +2 Charisma.

—Medium size.

—A doppelganger’s base land speed is 30 feet.

—Darkvision: Doppelgangers can see in the dark up to 60 feet.

—Racial Hit Dice: A doppelganger begins with four levels of monstrous humanoid, which provide 4d8 Hit Dice, a base attack bonus of +4, and base saving throw bonuses of Fort +1, Ref +4, and Will +4.

—Racial Skills: A doppelganger’s monstrous humanoid levels give it skill points equal to 7 x (2 + Int modifier). Its class skills are Bluff, Diplomacy, Disguise, Intimidate, Listen, Sense Motive, and Spot.

—Racial Feats: A doppelganger’s monstrous humanoid levels give it two feats.

— +4 natural armor bonus.

— +4 racial bonus on Bluff and Disguise checks. When using its change shape ability, a doppelganger gets an additional +10 circumstance bonus on Disguise checks. If it can read an opponent’s mind, it gets a further +4 circumstance bonus on Bluff and Disguise checks.

—Special Attacks (see above): Detect thoughts.

—Special Qualities (see above): Change shape, immunity to _sleep_ and charm effects.

—Automatic Languages: Common. Bonus Languages: Auran, Dwarven, Elven, Gnome, Halfling, Giant, Terran.

—Favored Class: Rogue.

—Level adjustment +4.','{"full_attack":"Slam +5 melee (1d6+1)","environment":"Any","organization":"Solitary, pair, or gang (3–6)","treasure":"Double standard","advancement":"By character class","level_adjustment":"+4","statblock":{"hit_dice":"4d8+4 (22 hp)","hit_points":22,"base_attack_grapple":"+4/+5","attack":"Slam +5 melee (1d6+1)","full_attack":"Slam +5 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref +5, Will +6","abilities":{"str":"12","dex":"13","con":"12","int":"13","wis":"14","cha":"13"},"skills":"Bluff +10*, Diplomacy +3, Disguise +9* (+11 acting), Intimidate +3, Listen +6, Sense Motive +6, Spot +6","feats":"Dodge, Great Fortitude","special_attacks":"Detect thoughts","special_qualities":"Change shape, immunity to sleep and charm effects"},"source_file":"monsters-di-do.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-di-do.html',true),
('dragon_turtle','Dragon Turtle','Dragon Turtle','9','Huge','Dragon (Aquatic)','Usually neutral','12d12+60 (138 hp)',138,'+0','20 ft. (4 squares), swim 30 ft.','25 (–2 size, +17 natural), touch 8, flat-footed 25','+12/+28','Bite +18 melee (4d6+8)','15 ft./10 ft.','+13','+8','+9',27,10,21,12,13,12,'Diplomacy +3, Hide +7*, Intimidate +16, Listen +16, Search +16, Sense Motive +16, Spot +16, Survival +16 (+18 following tracks), Swim +21','Blind-Fight, Cleave, Improved Bull Rush, Power Attack, Snatch','{"special_attacks":"Breath weapon, snatch, capsize","special_qualities":"Darkvision 60 ft., immunity to fire, sleep, and paralysis, low-light vision, scent"}'::jsonb,'Its rough, deep green shell is much the same color as the deep water the monster favors, and the silver highlights that line the shell resemble light dancing on open water. The turtle’s legs, tail, and head are a lighter green, flecked with golden highlights. An adult dragon turtle can measure from 20 to 30 feet from snout to tail, with a shell from 15 to 25 feet in diameter, and can weigh 8,000 to 32,000 pounds.

Dragon turtles speak Aquan, Draconic, and Common.

### Combat

Dragon turtles are fierce fighters and generally attack any creature that threatens their territory or looks like a potential meal.

**Breath Weapon (Su):** Cloud of superheated steam 20 feet high, 25 feet wide, and 50 feet long, once every 1d4 rounds, damage 12d6 fire, Reflex DC 21 half; effective both on the surface and underwater. The save DC is Constitution-based.

**Capsize (Ex):** A submerged dragon turtle that surfaces under a boat or ship less than 20 feet long capsizes the vessel 95% of the time. It has a 50% chance to capsize a vessel from 20 to 60 feet long and a 20% chance to capsize one over 60 feet long.

**Skills:** A dragon turtle has a +8 racial bonus on any Swim check to perform some special action or avoid a hazard. It can always choose to take 10 on a Swim check, even if distracted or endangered.

It can use the run action while swimming, provided it swims in a straight line.

\*Dragon turtles have a +8 racial bonus on Hide checks when submerged.','{"full_attack":"Bite +18 melee (4d6+8) and 2 claws +13 melee (2d8+4)","environment":"Temperate aquatic","organization":"Solitary","treasure":"Triple standard","advancement":"13–24 HD (Huge); 25–36 HD (Gargantuan)","level_adjustment":"—","statblock":{"hit_dice":"12d12+60 (138 hp)","hit_points":138,"base_attack_grapple":"+12/+28","attack":"Bite +18 melee (4d6+8)","full_attack":"Bite +18 melee (4d6+8) and 2 claws +13 melee (2d8+4)","space_reach":"15 ft./10 ft.","saves":"Fort +13, Ref +8, Will +9","abilities":{"str":"27","dex":"10","con":"21","int":"12","wis":"13","cha":"12"},"skills":"Diplomacy +3, Hide +7*, Intimidate +16, Listen +16, Search +16, Sense Motive +16, Spot +16, Survival +16 (+18 following tracks), Swim +21","feats":"Blind-Fight, Cleave, Improved Bull Rush, Power Attack, Snatch","special_attacks":"Breath weapon, snatch, capsize","special_qualities":"Darkvision 60 ft., immunity to fire, sleep, and paralysis, low-light vision, scent"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('dragonne','Dragonne','Dragonne','7','Large','Magical Beast','Usually neutral','9d10+27 (76 hp)',76,'+6','40 ft. (8 squares), fly 30 ft. (poor)','18 (–1 size, +2 Dex, +7 natural), touch 11, flat-footed 16','+9/+17','Bite +12 melee (2d6+4)','10 ft./5 ft.','+9','+8','+4',19,15,17,6,12,12,'Listen +11, Spot +11','Blind-Fight, Combat Reflexes, Improved Initiative, Track','{"special_attacks":"Pounce, roar","special_qualities":"Darkvision 60 ft., low-light vision, scent"}'::jsonb,'A dragonne possesses huge claws and fangs, and large eyes, usually the color of its scales. A dragonne is about 12 feet long and weighs about 700 pounds.

Dragonnes speak Draconic.

### Combat

A dragonne’s wings are useful only for short flights, carrying the creature for 10 to 30 minutes at a time. Nevertheless, it uses its wings effectively in battle. If opponents attempt to charge or encircle it, the dragonne simply takes to the air and finds a more defensible position.

**Pounce (Ex):** If a dragonne charges, it can make a full attack in the same round.

**Roar (Su):** A dragonne can loose a devastating roar every 1d4 rounds. All creatures except dragonnes within 120 feet must succeed on a DC 15 Will save or become fatigued. Those within 30 feet who fail their saves become exhausted. The save DC is Charisma-based.

**Skills:** Dragonnes have a +4 racial bonus on Listen and Spot checks.

**Carrying Capacity:** A light load for a dragonne is up to 348 pounds; a medium load, 349–699 pounds, and a heavy load, 700–1,050 pounds.','{"full_attack":"Bite +12 melee (2d6+4) and 2 claws +7 melee (2d4+2)","environment":"Temperate deserts","organization":"Solitary, pair, or pride (5–10)","treasure":"Double standard","advancement":"10–12 HD (Large); 13–27 HD (Huge)","level_adjustment":"+4 (cohort)","statblock":{"hit_dice":"9d10+27 (76 hp)","hit_points":76,"base_attack_grapple":"+9/+17","attack":"Bite +12 melee (2d6+4)","full_attack":"Bite +12 melee (2d6+4) and 2 claws +7 melee (2d4+2)","space_reach":"10 ft./5 ft.","saves":"Fort +9, Ref +8, Will +4","abilities":{"str":"19","dex":"15","con":"17","int":"6","wis":"12","cha":"12"},"skills":"Listen +11, Spot +11","feats":"Blind-Fight, Combat Reflexes, Improved Initiative, Track","special_attacks":"Pounce, roar","special_qualities":"Darkvision 60 ft., low-light vision, scent"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('drider','Drider','Drider','7','Large','Aberration','Always chaotic evil','6d8+18 (45 hp)',45,'+2','30 ft. (6 squares), climb 15 ft.','17 (–1 size, +2 Dex, +6 natural), touch 11, flat-footed 15','+4/+10','Dagger +5 melee (1d6+2/19–20) or bite +6 melee (1d4+1 plus poison) or shortbow +5 ranged (1d8/x3)','10 ft./5 ft.','+5','+4','+8',15,15,16,15,16,16,'Climb +14, Concentration +9, Hide +10, Listen +9, Move Silently +12, Spot +9','Combat Casting, Two-Weapon Fighting, Weapon Focus (bite)','{"special_attacks":"Spells, spell-like abilities, poison","special_qualities":"Darkvision 60 ft., spell resistance 17"}'::jsonb,'Driders speak Elven, Common, and Undercommon.

### Combat

Driders seldom pass up an opportunity to attack other creatures, especially from ambush. They usually begin with a spell assault and often levitate out of the enemy’s reach.

**Poison (Ex):** Injury, Fortitude DC 16, initial and secondary damage 1d6 Str. The save DC is Constitution based.

**Spell-Like Abilities:** 1/day—_dancing lights_ (DC 13), _clairaudience/clairvoyance, darkness, detect good, detect law, detect magic, dispel magic, faerie fire, levitate, suggestion_ (DC 16). Caster level 6th. The save DCs are Charisma-based.

**Spells:** Driders cast spells as 6th-level clerics, wizards, or sorcerers. Drider clerics can choose from the following domains: Chaos, Destruction, Evil, and Trickery. The typical spells prepared shown here are for a drider sorcerer.

_Typical Sorcerer Spells Known_ (6/7/6/4, base save DC 13 + spell level): 0—_daze, detect magic, ghost sound, mage hand, ray of frost, read magic, resistance;_ 1st—_mage armor, magic missile, ray of enfeeblement, silent image;_ 2nd— _invisibility, web;_ 3rd—_lightning bolt_.

**Skills:** A drider has a +4 racial bonus on Hide and Move Silently checks. It has a +8 racial bonus on Climb checks and can always choose to take 10 on a Climb check, even if rushed or threatened.','{"full_attack":"2 daggers +3 melee (1d6+2/19–20, 1d6+1/19–20) and bite +1 melee (1d4+1 plus poison); or shortbow +5 ranged (1d8/x3)","environment":"Underground","organization":"Solitary, pair, or troupe (1–2 plus 7–12 Medium monstrous spiders)","treasure":"Double standard","advancement":"By character class","level_adjustment":"+4","statblock":{"hit_dice":"6d8+18 (45 hp)","hit_points":45,"base_attack_grapple":"+4/+10","attack":"Dagger +5 melee (1d6+2/19–20) or bite +6 melee (1d4+1 plus poison) or shortbow +5 ranged (1d8/x3)","full_attack":"2 daggers +3 melee (1d6+2/19–20, 1d6+1/19–20) and bite +1 melee (1d4+1 plus poison); or shortbow +5 ranged (1d8/x3)","space_reach":"10 ft./5 ft.","saves":"Fort +5, Ref +4, Will +8","abilities":{"str":"15","dex":"15","con":"16","int":"15","wis":"16","cha":"16"},"skills":"Climb +14, Concentration +9, Hide +10, Listen +9, Move Silently +12, Spot +9","feats":"Combat Casting, Two-Weapon Fighting, Weapon Focus (bite)","special_attacks":"Spells, spell-like abilities, poison","special_qualities":"Darkvision 60 ft., spell resistance 17"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('dryad','Dryad','Dryad','3','Medium','Fey','Usually chaotic good','4d6 (14 hp)',14,'+4','30 ft. (6 squares)','17 (+4 Dex, +3 natural), touch 14, flat-footed 13','+2/+2','Dagger +6 melee (1d4/19–20) or masterwork longbow +7 ranged (1d8/x3)','5 ft./5 ft.','+3','+8','+6',10,19,11,14,15,18,'Escape Artist +11, Handle Animal +11, Hide +11, Knowledge (nature) +11, Listen +9, Move Silently +11, Ride +6, Spot +9, Survival +9, Use Rope +4 (+6 with bindings)','Great Fortitude, Weapon Finesse','{"special_attacks":"Spell-like abilities","special_qualities":"Damage reduction 5/cold iron, tree dependent, wild empathy"}'::jsonb,'A dryad’s delicate features are much like a female elf ’s, though her flesh is like bark or fine wood, and her hair is like a canopy of leaves that changes color with the seasons.

Although they are generally solitary, up to seven dryads have been encountered in one place on rare occasions.

Dryads speak Common, Elven, and Sylvan.

### Combat

Shy, intelligent, and resolute, dryads are as elusive as they are alluring—they avoid physical combat and are rarely seen unless they wish to be. If threatened, or in need of an ally, a dryad uses _charm person_ or _suggestion,_ attempting to gain control of the attacker(s) who could help the most against the rest. Any attack on her tree, however, provokes the dryad into a frenzied defense.

**Spell-Like Abilities:** At will—_entangle_ (DC 13), _speak with plants, tree shape;_ 3/day— _charm person_ (DC 13), _deep slumber_ (DC 15), _tree stride;_ 1/day—_suggestion_ (DC 15). Caster level 6th. The save DCs are Wisdom-based.

**Tree Dependent (Su):** Each dryad is mystically bound to a single, enormous oak tree and must never stray more than 300 yards from it. Any who do become ill and die within 4d6 hours. A dryad’s oak does not radiate magic.

**Wild Empathy (Ex):** This power works like the druid’s wild empathy class feature, except that the dryad has a +6 racial bonus on the check.','{"full_attack":"Dagger +6 melee (1d4/19–20) or masterwork longbow +7 ranged (1d8/x3)","environment":"Temperate forests","organization":"Solitary or grove (4–7)","treasure":"Standard","advancement":"By character class","level_adjustment":"—","statblock":{"hit_dice":"4d6 (14 hp)","hit_points":14,"base_attack_grapple":"+2/+2","attack":"Dagger +6 melee (1d4/19–20) or masterwork longbow +7 ranged (1d8/x3)","full_attack":"Dagger +6 melee (1d4/19–20) or masterwork longbow +7 ranged (1d8/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +8, Will +6","abilities":{"str":"10","dex":"19","con":"11","int":"14","wis":"15","cha":"18"},"skills":"Escape Artist +11, Handle Animal +11, Hide +11, Knowledge (nature) +11, Listen +9, Move Silently +11, Ride +6, Spot +9, Survival +9, Use Rope +4 (+6 with bindings)","feats":"Great Fortitude, Weapon Finesse","special_attacks":"Spell-like abilities","special_qualities":"Damage reduction 5/cold iron, tree dependent, wild empathy"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('dwarf_1st_level_warrior','Dwarf, 1st-Level Warrior','Dwarf, 1st-Level Warrior','½','Medium','Humanoid (Dwarf)','Often lawful good (Deep: Usually lawful neutral or neutral)','1d8+2 (6 hp)',6,'+0','20 ft. in scale mail (4 squares); base speed 20 ft.','16 (+4 scale mail, +2 heavy shield), touch 10, flat-footed 16','+1/+2','Dwarven waraxe +3 melee (1d10+1/x3) or shortbow +1 ranged (1d6/x3)','5 ft./5 ft.','+4','+0','–1',13,11,14,10,9,6,'Appraise +2, Craft (blacksmithing) +2, Craft (stonemasonry) +2, Listen +2, Spot +2','Weapon Focus (dwarven waraxe)','{"special_attacks":"Dwarf traits","special_qualities":"Darkvision 60 ft., dwarf traits"}'::jsonb,'Dwarves favor earth tones in their clothing and prefer simple and functional garb. The skin can be very dark, but it is always some shade of tan or brown. Hair color can be black, gray, or brown. Dwarves average 4 feet tall and weigh as much as adult humans.

Dwarves speak Dwarven. Most who travel outside dwarven lands (as traders, mercenaries, or adventurers) know the Common tongue, while warriors in the dwarven cities usually learn Goblin to better interrogate and spy on those evil denizens of the deep caves.

Most dwarves encountered outside their home are warriors.

### Combat

Dwarves are experts in combat, effectively using their environment and executing well-planned group attacks. They rarely use magic in fights, since they have few wizards or sorcerers (but dwarven clerics throw themselves into battle as heartily as their fellow warriors). If they have time to prepare, they may build deadfalls or other traps involving stone. In addition to the dwarven waraxe and thrown hammer, dwarves also use warhammers, picks, shortbows, heavy crossbows, and maces.

**Dwarf Traits (Ex):** Dwarves possess the following racial traits.

— +2 Constitution, –2 Charisma.

—Medium size.

—A dwarf ’s base land speed is 20 feet. However, dwarves can move at this speed even when wearing medium or heavy armor or when carrying a medium or heavy load.

—Darkvision out to to 60 feet.

—Stonecunning: This ability grants a dwarf a +2 racial bonus on Search checks to notice unusual stonework, such as sliding walls, stonework traps, new construction (even when built to match the old), unsafe stone surfaces, shaky stone ceilings, and the like. Something that isn’t stone but that is disguised as stone also counts as unusual stonework. A dwarf who merely comes within 10 feet of unusual stonework can make a Search check as if he were actively searching, and a dwarf can use the Search skill to find stonework traps as a rogue can. A dwarf can also intuit depth, sensing his approximate depth underground as naturally as a human can sense which way is up. Dwarves have a sixth sense about stonework, an innate ability that they get plenty of opportunity to practice and hone in their underground homes.

—Weapon Familiarity: Dwarves treat dwarven waraxes and dwarven urgroshes as martial weapons, rather than exotic weapons.

—Stability: Dwarves are exceptionally stable on their feet. A dwarf has a +4 bonus on ability checks made to resist being bull rushed or tripped when standing on the ground (but not when climbing, flying, riding, or otherwise not standing firmly on the ground).

— +2 racial bonus on saving throws against poison. \*Not reflected in the saving throw numbers given here.

— +2 racial bonus on saving throws against spells and spell-like effects. \*Not reflected in the saving throw numbers given here.

— +1 racial bonus on attack rolls against orcs (including halforcs) and goblinoids (including goblins, hobgoblins, and bugbears).

— +4 dodge bonus to Armor Class against creatures of the giant type (such as ogres, trolls, and hill giants).

— +2 racial bonus on Appraise checks that are related to stone or metal items.

— +2 racial bonus on Craft checks that are related to stone or metal.

—Automatic Languages: Common, Dwarven. Bonus Languages: Giant, Gnome, Goblin, Orc, Terran, Undercommon.

—Favored Class: Fighter.

The dwarf warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The information above is for hill dwarves, the most common variety.

There are three other major dwarven subraces, which differ from hill dwarves as follows.

#### Deep Dwarf

These dwarves live far underground and tend to be more standoffish with non-dwarves.

Deep dwarves are the same height as other dwarves, but leaner. Their skin sometimes has a reddish tinge, and their large eyes lack the brightness of those of their kindred, being a washed-out blue. Their hair color ranges from bright red to straw blond. They have little contact with surface dwellers, relying on hill dwarves or mountain dwarves to trade goods for them.

Deep dwarves speak Dwarven and Goblin, and occasionally Draconic or Undercommon.

**Deep Dwarf Traits (Ex):** These traits are in addition to the hill dwarf traits, except where noted.

—Racial bonus on saves against spells and spell-like abilities increases to +3.

—Racial bonus on Fortitude saves against poisons increases to +3.

—Darkvision out to 90 feet.

—Light Sensitivity: Deep dwarves are dazzled in bright sunlight or within the radius of a _daylight_ spell.

#### Duergar

Sometimes called gray dwarves, these evil beings dwell in the underground.

Most duergar are bald (even the females), and they dress in drab clothing that is designed to blend into stone. In their lairs they may wear jewelry, but it is always kept dull. They war with other dwarves, even allying with other underground creatures from time to time.

Duergar speak Dwarven and Undercommon.

**Duergar Traits (Ex):** These traits are in addition to the hill dwarf traits, except where noted.

— –4 Charisma instead of –2.

—Darkvision out to 120 feet.

—Immunity to paralysis, phantasms, and poison. This trait replaces the hill dwarf ’s +2 racial bonus on saving throws against poison.

— +2 racial bonus on saves against spells and spell-like abilities.

—Spell-Like Abilities: 1/day—_enlarge person_ and _invisibility_ as a wizard of twice the duergar’s class level (minimum caster level 3rd); these abilities affect only the duergar and whatever it carries.

—Light Sensitivity: Duergar are dazzled in bright sunlight or within the radius of a _daylight_ spell.

— +4 racial bonus on Move Silently checks.

— +1 racial bonus on Listen and Spot checks.

—Automatic Languages: Common, Dwarven, Undercommon.

Bonus Languages: Draconic, Giant, Goblin, Orc, Terran. This trait replaces the hill dwarf ’s automatic and bonus languages.

—Favored Class: Fighter.

—Level adjustment +1

—Unlike other dwarves, duergar do not have weapon familiarity with the dwarven waraxe and dwarven urgrosh.

The duergar warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

**Challenge Rating:** Duergar with levels in NPC classes have a CR equal to their character level. Duergar with levels in PC classes have a CR equal to their character level +1.

#### Mountain Dwarf

Mountain dwarves live deeper under the mountains than hill dwarves but generally not as far underground as deep dwarves. They average about 4-1/2 feet tall and have lighter skin and hair than hill dwarves, but the same general appearance.','{"full_attack":"Dwarven waraxe +3 melee (1d10+1/x3) or shortbow +1 ranged (1d6/x3)","environment":"Temperate mountains (Deep: Underground)","organization":"Team (2–4), squad (11–20 plus 2 3rd-level sergeants and 1 leader of 3rd–6th level), or clan (30–100 plus 30% noncombatants plus 1 3rd-level sergeant per 10 adults, 5 5th-level lieutenants, and 3 7th-level captains)","treasure":"Standard coins; double goods; standard items","advancement":"By character class","level_adjustment":"+0","statblock":{"hit_dice":"1d8+2 (6 hp)","hit_points":6,"base_attack_grapple":"+1/+2","attack":"Dwarven waraxe +3 melee (1d10+1/x3) or shortbow +1 ranged (1d6/x3)","full_attack":"Dwarven waraxe +3 melee (1d10+1/x3) or shortbow +1 ranged (1d6/x3)","space_reach":"5 ft./5 ft.","saves":"Fort +4*, Ref +0*, Will –1*","abilities":{"str":"13","dex":"11","con":"14","int":"10","wis":"9","cha":"6"},"skills":"Appraise +2, Craft (blacksmithing) +2, Craft (stonemasonry) +2, Listen +2, Spot +2","feats":"Weapon Focus (dwarven waraxe)","special_attacks":"Dwarf traits","special_qualities":"Darkvision 60 ft., dwarf traits"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('duergar_1st_level_warrior','Duergar, 1st-Level Warrior','Duergar, 1st-Level Warrior','1','Medium','Humanoid (Dwarf)','Often lawful evil','1d8+5 (9 hp)',9,'+0','20 ft. in chainmail (4 squares); base speed 20 ft.','17 (+5 chainmail, +2 heavy shield), touch 10, flat-footed 17','+1/+2','Warhammer +2 melee (1d8+1/x3) or light crossbow +1 ranged (1d8/19–20)','5 ft./5 ft.','+4','+0','–1',13,11,14,10,9,4,'Appraise +2, Craft (blacksmithing) +2, Craft (stonemasonry) +2, Listen +3, Move Silently –4, Spot +2','Toughness','{"special_attacks":"Duergar traits, spell-like abilities","special_qualities":"Darkvision 60 ft., duergar traits"}'::jsonb,'Dwarves favor earth tones in their clothing and prefer simple and functional garb. The skin can be very dark, but it is always some shade of tan or brown. Hair color can be black, gray, or brown. Dwarves average 4 feet tall and weigh as much as adult humans.

Dwarves speak Dwarven. Most who travel outside dwarven lands (as traders, mercenaries, or adventurers) know the Common tongue, while warriors in the dwarven cities usually learn Goblin to better interrogate and spy on those evil denizens of the deep caves.

Most dwarves encountered outside their home are warriors.

### Combat

Dwarves are experts in combat, effectively using their environment and executing well-planned group attacks. They rarely use magic in fights, since they have few wizards or sorcerers (but dwarven clerics throw themselves into battle as heartily as their fellow warriors). If they have time to prepare, they may build deadfalls or other traps involving stone. In addition to the dwarven waraxe and thrown hammer, dwarves also use warhammers, picks, shortbows, heavy crossbows, and maces.

**Dwarf Traits (Ex):** Dwarves possess the following racial traits.

— +2 Constitution, –2 Charisma.

—Medium size.

—A dwarf ’s base land speed is 20 feet. However, dwarves can move at this speed even when wearing medium or heavy armor or when carrying a medium or heavy load.

—Darkvision out to to 60 feet.

—Stonecunning: This ability grants a dwarf a +2 racial bonus on Search checks to notice unusual stonework, such as sliding walls, stonework traps, new construction (even when built to match the old), unsafe stone surfaces, shaky stone ceilings, and the like. Something that isn’t stone but that is disguised as stone also counts as unusual stonework. A dwarf who merely comes within 10 feet of unusual stonework can make a Search check as if he were actively searching, and a dwarf can use the Search skill to find stonework traps as a rogue can. A dwarf can also intuit depth, sensing his approximate depth underground as naturally as a human can sense which way is up. Dwarves have a sixth sense about stonework, an innate ability that they get plenty of opportunity to practice and hone in their underground homes.

—Weapon Familiarity: Dwarves treat dwarven waraxes and dwarven urgroshes as martial weapons, rather than exotic weapons.

—Stability: Dwarves are exceptionally stable on their feet. A dwarf has a +4 bonus on ability checks made to resist being bull rushed or tripped when standing on the ground (but not when climbing, flying, riding, or otherwise not standing firmly on the ground).

— +2 racial bonus on saving throws against poison. \*Not reflected in the saving throw numbers given here.

— +2 racial bonus on saving throws against spells and spell-like effects. \*Not reflected in the saving throw numbers given here.

— +1 racial bonus on attack rolls against orcs (including halforcs) and goblinoids (including goblins, hobgoblins, and bugbears).

— +4 dodge bonus to Armor Class against creatures of the giant type (such as ogres, trolls, and hill giants).

— +2 racial bonus on Appraise checks that are related to stone or metal items.

— +2 racial bonus on Craft checks that are related to stone or metal.

—Automatic Languages: Common, Dwarven. Bonus Languages: Giant, Gnome, Goblin, Orc, Terran, Undercommon.

—Favored Class: Fighter.

The dwarf warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

### Subraces

The information above is for hill dwarves, the most common variety.

There are three other major dwarven subraces, which differ from hill dwarves as follows.

#### Deep Dwarf

These dwarves live far underground and tend to be more standoffish with non-dwarves.

Deep dwarves are the same height as other dwarves, but leaner. Their skin sometimes has a reddish tinge, and their large eyes lack the brightness of those of their kindred, being a washed-out blue. Their hair color ranges from bright red to straw blond. They have little contact with surface dwellers, relying on hill dwarves or mountain dwarves to trade goods for them.

Deep dwarves speak Dwarven and Goblin, and occasionally Draconic or Undercommon.

**Deep Dwarf Traits (Ex):** These traits are in addition to the hill dwarf traits, except where noted.

—Racial bonus on saves against spells and spell-like abilities increases to +3.

—Racial bonus on Fortitude saves against poisons increases to +3.

—Darkvision out to 90 feet.

—Light Sensitivity: Deep dwarves are dazzled in bright sunlight or within the radius of a _daylight_ spell.

#### Duergar

Sometimes called gray dwarves, these evil beings dwell in the underground.

Most duergar are bald (even the females), and they dress in drab clothing that is designed to blend into stone. In their lairs they may wear jewelry, but it is always kept dull. They war with other dwarves, even allying with other underground creatures from time to time.

Duergar speak Dwarven and Undercommon.

**Duergar Traits (Ex):** These traits are in addition to the hill dwarf traits, except where noted.

— –4 Charisma instead of –2.

—Darkvision out to 120 feet.

—Immunity to paralysis, phantasms, and poison. This trait replaces the hill dwarf ’s +2 racial bonus on saving throws against poison.

— +2 racial bonus on saves against spells and spell-like abilities.

—Spell-Like Abilities: 1/day—_enlarge person_ and _invisibility_ as a wizard of twice the duergar’s class level (minimum caster level 3rd); these abilities affect only the duergar and whatever it carries.

—Light Sensitivity: Duergar are dazzled in bright sunlight or within the radius of a _daylight_ spell.

— +4 racial bonus on Move Silently checks.

— +1 racial bonus on Listen and Spot checks.

—Automatic Languages: Common, Dwarven, Undercommon.

Bonus Languages: Draconic, Giant, Goblin, Orc, Terran. This trait replaces the hill dwarf ’s automatic and bonus languages.

—Favored Class: Fighter.

—Level adjustment +1

—Unlike other dwarves, duergar do not have weapon familiarity with the dwarven waraxe and dwarven urgrosh.

The duergar warrior presented here had the following ability scores before racial adjustments: Str 13, Dex 11, Con 12, Int 10, Wis 9, Cha 8.

**Challenge Rating:** Duergar with levels in NPC classes have a CR equal to their character level. Duergar with levels in PC classes have a CR equal to their character level +1.

#### Mountain Dwarf

Mountain dwarves live deeper under the mountains than hill dwarves but generally not as far underground as deep dwarves. They average about 4-1/2 feet tall and have lighter skin and hair than hill dwarves, but the same general appearance.','{"full_attack":"Warhammer +2 melee (1d8+1/x3) or light crossbow +1 ranged (1d8/19–20)","environment":"Underground","organization":"Team (2–4), squad (9–16 plus 3 3rd-level sergeants and 1 leader of 3rd–8th level) or clan (20–80 plus 25% noncombatants plus 1 3rd-level sergeant per 5 adults, 3–6 6th-level lieutenants, and 1–4 9th-level captains)","treasure":"Standard coins, double goods, standard items","advancement":"By character class","level_adjustment":"+1","statblock":{"hit_dice":"1d8+5 (9 hp)","hit_points":9,"base_attack_grapple":"+1/+2","attack":"Warhammer +2 melee (1d8+1/x3) or light crossbow +1 ranged (1d8/19–20)","full_attack":"Warhammer +2 melee (1d8+1/x3) or light crossbow +1 ranged (1d8/19–20)","space_reach":"5 ft./5 ft.","saves":"Fort +4*, Ref +0*, Will –1*","abilities":{"str":"13","dex":"11","con":"14","int":"10","wis":"9","cha":"4"},"skills":"Appraise +2, Craft (blacksmithing) +2, Craft (stonemasonry) +2, Listen +3, Move Silently –4, Spot +2","feats":"Toughness","special_attacks":"Duergar traits, spell-like abilities","special_qualities":"Darkvision 60 ft., duergar traits"},"source_file":"monsters-dr-dw.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-dr-dw.html',true),
('eagle_giant','Eagle, Giant','Eagle, Giant','3','Large','Magical Beast','Usually neutral good','4d10+4 (26 hp)',26,'+3','10 ft. (2 squares), fly 80 ft. (average)','15 (–1 size, +3 Dex, +3 natural), touch 12, flat-footed 12','+4/+12','Claw +7 melee (1d6+4)','10 ft./5 ft.','+5','+7','+3',18,17,12,10,14,10,'Knowledge (nature) +2, Listen +6, Sense Motive +4, Spot +15, Survival +3','Alertness, Flyby Attack','{"special_attacks":"—","special_qualities":"Low-light vision, evasion"}'::jsonb,'A typical giant eagle stands about 10 feet tall, has a wingspan of up to 20 feet, and resembles its smaller cousins in nearly every way except size. It weighs about 500 pounds.

Giant eagles speak Common and Auran.

### Combat

A giant eagle typically attacks from a great height, diving earthward at tremendous speed. When it cannot dive, it uses its powerful talons and slashing beak to strike at its target’s head and eyes.

A solitary giant eagle is typically hunting or patrolling in the vicinity of its nest and generally ignores creatures that do not appear threatening. A mated pair attacks in concert, making repeated diving attacks to drive away intruders, and fights to the death to defend their nest or hatchlings.

**Evasion (Ex):** With a successful Reflex save against an attack that allows a Reflex save for half damage, a giant eagle takes no damage.

**Skills:** Giant eagles have a +4 racial bonus on Spot checks.

### Training a Giant Eagle

Although intelligent, a giant eagle requires training before it can bear a rider in combat. To be trained, a giant eagle must have a friendly attitude toward the trainer (this can be achieved through a successful Diplomacy check). Training a friendly giant eagle requires six weeks of work and a DC 25 Handle Animal check.

Riding a giant eagle requires an exotic saddle. A giant eagle can fight while carrying a rider, but the rider cannot also attack unless he or she succeeds on a Ride check.

Giant eagle eggs are worth 2,500 gp apiece on the open market, while chicks are worth 4,000 gp each. Professional trainers charge 1,000 gp to rear or train a giant eagle.

Carrying Capacity: A light load for a giant eagle is up to 300 pounds; a medium load, 301–600 pounds; and a heavy load, 601–900 pounds.','{"full_attack":"2 claws +7 melee (1d6+4) and bite +2 melee (1d8+2)","environment":"Temperate mountains","organization":"Solitary, pair, or eyrie (5–12)","treasure":"None","advancement":"5–8 HD (Large); 9–12 HD (Huge)","level_adjustment":"+2 (cohort)","statblock":{"hit_dice":"4d10+4 (26 hp)","hit_points":26,"base_attack_grapple":"+4/+12","attack":"Claw +7 melee (1d6+4)","full_attack":"2 claws +7 melee (1d6+4) and bite +2 melee (1d8+2)","space_reach":"10 ft./5 ft.","saves":"Fort +5, Ref +7, Will +3","abilities":{"str":"18","dex":"17","con":"12","int":"10","wis":"14","cha":"10"},"skills":"Knowledge (nature) +2, Listen +6, Sense Motive +4, Spot +15, Survival +3","feats":"Alertness, Flyby Attack","special_attacks":"—","special_qualities":"Low-light vision, evasion"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_small','Air Elemental, Small','Air Elemental, Small','1','Small','Elemental (Air, Extraplanar)','Usually neutral','2d8 (9 hp)',9,'+7','Fly 100 ft. (perfect) (20 squares)','17 (+1 size, +3 Dex, +3 natural), touch 14, flat-footed 14','+1/–3','Slam +5 melee (1d4)','5 ft./5 ft.','+0','+6','+0',10,17,10,4,11,11,'Listen +2, Spot +3','Flyby Attack, Improved InitiativeB, Weapon Finesse B','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Air Elemental, Huge</th><th>Air Elemental, Greater</th><th>Air Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+13</td><td>+14</td><td>+15</td></tr><tr><th>Speed:</th><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +9 Dex, +4 natural), touch 17, flat-footed 12</td><td>26 (–2 size, +10 Dex, +8 natural), touch 18, flat-footed 16</td><td>27 (–2 size, +11 Dex, +8 natural), touch 19, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d8+4)</td><td>Slam +23 melee (2d8+5)</td><td>Slam +27 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d8+4)</td><td>2 slams +23 melee (2d8+5)</td><td>2 slams +27 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +19, Will +5</td><td>Fort +11, Ref +22, Will +9</td><td>Fort +12, Ref +25, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 31, Con 18, Int 8, Wis 11, Cha 11</td><td>Str 22, Dex 33, Con 18, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Flyby Attack, Improved Initiative <sup>B</sup>, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Cleave, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td></tr><tr><th>Environment:</th><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"Slam +5 melee (1d4)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"3 HD (Small)","level_adjustment":"—","statblock":{"hit_dice":"2d8 (9 hp)","hit_points":9,"base_attack_grapple":"+1/–3","attack":"Slam +5 melee (1d4)","full_attack":"Slam +5 melee (1d4)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +6, Will +0","abilities":{"str":"10","dex":"17","con":"10","int":"4","wis":"11","cha":"11"},"skills":"Listen +2, Spot +3","feats":"Flyby Attack, Improved InitiativeB, Weapon Finesse B","special_attacks":"Air mastery, whirlwind","special_qualities":"Darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_medium','Air Elemental, Medium','Air Elemental, Medium','3','Medium','Elemental (Air, Extraplanar)','Usually neutral','4d8+8 (26 hp)',26,'+9','Fly 100 ft. (perfect) (20 squares)','18 (+5 Dex, +3 natural), touch 15, flat-footed 13','+3/+4','Slam +8 melee (1d6+1)','5 ft./5 ft.','+3','+9','+1',12,21,14,4,11,11,'Listen +3, Spot +4','Dodge, Flyby Attack, Improved Initiative B, Weapon FinesseB','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Air Elemental, Huge</th><th>Air Elemental, Greater</th><th>Air Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+13</td><td>+14</td><td>+15</td></tr><tr><th>Speed:</th><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +9 Dex, +4 natural), touch 17, flat-footed 12</td><td>26 (–2 size, +10 Dex, +8 natural), touch 18, flat-footed 16</td><td>27 (–2 size, +11 Dex, +8 natural), touch 19, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d8+4)</td><td>Slam +23 melee (2d8+5)</td><td>Slam +27 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d8+4)</td><td>2 slams +23 melee (2d8+5)</td><td>2 slams +27 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +19, Will +5</td><td>Fort +11, Ref +22, Will +9</td><td>Fort +12, Ref +25, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 31, Con 18, Int 8, Wis 11, Cha 11</td><td>Str 22, Dex 33, Con 18, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Flyby Attack, Improved Initiative <sup>B</sup>, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Cleave, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td></tr><tr><th>Environment:</th><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"Slam +8 melee (1d6+1)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"5–7 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"4d8+8 (26 hp)","hit_points":26,"base_attack_grapple":"+3/+4","attack":"Slam +8 melee (1d6+1)","full_attack":"Slam +8 melee (1d6+1)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +9, Will +1","abilities":{"str":"12","dex":"21","con":"14","int":"4","wis":"11","cha":"11"},"skills":"Listen +3, Spot +4","feats":"Dodge, Flyby Attack, Improved Initiative B, Weapon FinesseB","special_attacks":"Air mastery, whirlwind","special_qualities":"Darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_large','Air Elemental, Large','Air Elemental, Large','5','Large','Elemental (Air, Extraplanar)','Usually neutral','8d8+24 (60 hp)',60,'+11','Fly 100 ft. (perfect) (20 squares)','20 (–1 size, +7 Dex, +4 natural), touch 16, flat-footed 13','+6/+12','Slam +12 melee (2d6+2)','10 ft./10 ft.','+5','+13','+2',14,25,16,6,11,11,'Listen +5, Spot +6','Combat Reflexes, Dodge, Flyby Attack, Improved InitiativeB, Weapon FinesseB','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Air Elemental, Huge</th><th>Air Elemental, Greater</th><th>Air Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td><td>Huge Elemental <small>(Air, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+13</td><td>+14</td><td>+15</td></tr><tr><th>Speed:</th><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td><td>Fly 100 ft. (perfect) (20 squares)</td></tr><tr><th>Armor Class:</th><td>21 (–2 size, +9 Dex, +4 natural), touch 17, flat-footed 12</td><td>26 (–2 size, +10 Dex, +8 natural), touch 18, flat-footed 16</td><td>27 (–2 size, +11 Dex, +8 natural), touch 19, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d8+4)</td><td>Slam +23 melee (2d8+5)</td><td>Slam +27 melee (2d8+6)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d8+4)</td><td>2 slams +23 melee (2d8+5)</td><td>2 slams +27 melee (2d8+6)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td><td>Air mastery, whirlwind</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +19, Will +5</td><td>Fort +11, Ref +22, Will +9</td><td>Fort +12, Ref +25, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 31, Con 18, Int 8, Wis 11, Cha 11</td><td>Str 22, Dex 33, Con 18, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Flyby Attack, Improved Initiative <sup>B</sup>, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-fight, Cleave, Combat Reflexes, Flyby Attack, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Power Attack, Spring Attack, Weapon Finesse<sup>B</sup></td></tr><tr><th>Environment:</th><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td><td>Elemental Plane of Air</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +12 melee (2d6+2)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"9–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+6/+12","attack":"Slam +12 melee (2d6+2)","full_attack":"2 slams +12 melee (2d6+2)","space_reach":"10 ft./10 ft.","saves":"Fort +5, Ref +13, Will +2","abilities":{"str":"14","dex":"25","con":"16","int":"6","wis":"11","cha":"11"},"skills":"Listen +5, Spot +6","feats":"Combat Reflexes, Dodge, Flyby Attack, Improved InitiativeB, Weapon FinesseB","special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_huge','Air Elemental, Huge','Air Elemental, Huge','7','Huge','Elemental (Air, Extraplanar)','Usually neutral','16d8+64 (136 hp)',136,'+13','Fly 100 ft. (perfect) (20 squares)','21 (–2 size, +9 Dex, +4 natural), touch 17, flat-footed 12','+12/+24','Slam +19 melee (2d8+4)','15 ft./15 ft.','+9','+19','+5',18,29,18,6,11,11,'Listen +11, Spot +12','Alertness, Combat Reflexes, Dodge, Flyby Attack, Improved Initiative B, Mobility, Spring Attack, Weapon FinesseB','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"}'::jsonb,'Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +19 melee (2d8+4)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"17–20 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+64 (136 hp)","hit_points":136,"base_attack_grapple":"+12/+24","attack":"Slam +19 melee (2d8+4)","full_attack":"2 slams +19 melee (2d8+4)","space_reach":"15 ft./15 ft.","saves":"Fort +9, Ref +19, Will +5","abilities":{"str":"18","dex":"29","con":"18","int":"6","wis":"11","cha":"11"},"skills":"Listen +11, Spot +12","feats":"Alertness, Combat Reflexes, Dodge, Flyby Attack, Improved Initiative B, Mobility, Spring Attack, Weapon FinesseB","special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_greater','Air Elemental, Greater','Air Elemental, Greater','9','Huge','Elemental (Air, Extraplanar)','Usually neutral','21d8+84 (178 hp)',178,'+14','Fly 100 ft. (perfect) (20 squares)','26 (–2 size, +10 Dex, +8 natural), touch 18, flat-footed 16','+15/+28','Slam +23 melee (2d8+5)','15 ft./15 ft.','+11','+22','+9',20,31,18,8,11,11,'Listen +14, Spot +14','Alertness, Blind-fight, Combat Reflexes, Flyby Attack, Improved Initiative B, Iron Will, Mobility, Power Attack, Spring Attack, Weapon FinesseB','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"}'::jsonb,'Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +23 melee (2d8+5)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"22–23 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"21d8+84 (178 hp)","hit_points":178,"base_attack_grapple":"+15/+28","attack":"Slam +23 melee (2d8+5)","full_attack":"2 slams +23 melee (2d8+5)","space_reach":"15 ft./15 ft.","saves":"Fort +11, Ref +22, Will +9","abilities":{"str":"20","dex":"31","con":"18","int":"8","wis":"11","cha":"11"},"skills":"Listen +14, Spot +14","feats":"Alertness, Blind-fight, Combat Reflexes, Flyby Attack, Improved Initiative B, Iron Will, Mobility, Power Attack, Spring Attack, Weapon FinesseB","special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('air_elemental_elder','Air Elemental, Elder','Air Elemental, Elder','11','Huge','Elemental (Air, Extraplanar)','Usually neutral','24d8+96 (204 hp)',204,'+15','Fly 100 ft. (perfect) (20 squares)','27 (–2 size, +11 Dex, +8 natural), touch 19, flat-footed 16','+18/+32','Slam +27 melee (2d8+6)','15 ft./15 ft.','+12','+25','+10',22,33,18,10,11,11,'Listen +29, Spot +29','Alertness, Blind-fight, Cleave, Combat Reflexes, Flyby Attack, Improved Initiative B, Iron Will, Mobility, Power Attack, Spring Attack, Weapon FinesseB','{"special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"}'::jsonb,'Air elementals speak Auran, though they rarely choose to do so.

#### Combat

Their rapid speed makes air elementals useful on vast battlefields or in extended aerial combat.

**Air Mastery (Ex):** Airborne creatures take a –1 penalty on attack and damage rolls against an air elemental.

**Whirlwind (Su):** The elemental can transform itself into a whirlwind once every 10 minutes and remain in that form for up to 1 round for every 2 HD it has. In this form, the elemental can move through the air or along a surface at its fly speed.

The whirlwind is 5 feet wide at the base, up to 30 feet wide at the top, and up to 50 feet tall, depending on the elemental’s size. The elemental controls the exact height, but it must be at least 10 feet.

The elemental’s movement while in whirlwind form does not provoke attacks of opportunity, even if the elemental enters the space another creature occupies. Another creature might be caught in the whirlwind if it touches or enters the whirlwind, or if the elemental moves into or through the creature’s space.

Creatures one or more size categories smaller than the elemental might take damage when caught in the whirlwind (see the table below for details) and may be lifted into the air. An affected creature must succeed on a Reflex save when it comes into contact with the whirlwind or take the indicated damage. It must also succeed on a second Reflex save or be picked up bodily and held suspended in the powerful winds, automatically taking the indicated damage each round. A creature that can fly is allowed a Reflex save each round to escape the whirlwind. The creature still takes damage but can leave if the save is successful. The DC for saves against the whirlwind’s effects varies with the elemental’s size (see the table). The save DC is Strength based.

Creatures trapped in the whirlwind cannot move except to go where the elemental carries them or to escape the whirlwind.

Creatures caught in the whirlwind can otherwise act normally, but must succeed on a Concentration check (DC 15 + spell level) to cast a spell. Creatures caught in the whirlwind take a –4 penalty to Dexterity and a –2 penalty on attack rolls. The elemental can have only as many creatures trapped inside the whirlwind at one time as will fit inside the whirlwind’s volume.

The elemental can eject any carried creatures whenever it wishes, depositing them wherever the whirlwind happens to be. A summoned elemental always ejects trapped creatures before returning to its home plane.

If the whirlwind’s base touches the ground, it creates a swirling cloud of debris. This cloud is centered on the elemental and has a diameter equal to half the whirlwind’s height. The cloud obscures all vision, including darkvision, beyond 5 feet. Creatures 5 feet away have concealment, while those farther away have total concealment.

Those caught in the cloud must succeed on a Concentration check (DC 15 + spell level) to cast a spell.

An elemental in whirlwind form cannot make slam attacks and does not threaten the area around it.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Air Elemental Sizes</th></tr><tr><td></td><td></td><td></td><th colspan="3" class="middle-line">Whirlwind</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Save DC</th><th>Damage</th><th>Height</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td><td>1d4</td><td>10–20 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>13</td><td>1d6</td><td>10–30 ft.</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>16</td><td>2d6</td><td>10–40 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td><td>2d8</td><td>10–50 ft.</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>25</td><td>2d8</td><td>10–60 ft.</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>28</td><td>2d8</td><td>10–60 ft.</td></tr></tbody></table>','{"full_attack":"2 slams +27 melee (2d8+6)","environment":"Elemental Plane of Air","organization":"Solitary","treasure":"None","advancement":"25–48 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"24d8+96 (204 hp)","hit_points":204,"base_attack_grapple":"+18/+32","attack":"Slam +27 melee (2d8+6)","full_attack":"2 slams +27 melee (2d8+6)","space_reach":"15 ft./15 ft.","saves":"Fort +12, Ref +25, Will +10","abilities":{"str":"22","dex":"33","con":"18","int":"10","wis":"11","cha":"11"},"skills":"Listen +29, Spot +29","feats":"Alertness, Blind-fight, Cleave, Combat Reflexes, Flyby Attack, Improved Initiative B, Iron Will, Mobility, Power Attack, Spring Attack, Weapon FinesseB","special_attacks":"Air mastery, whirlwind","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_small','Earth Elemental, Small','Earth Elemental, Small','1','Small','Elemental (Earth, Extraplanar)','Usually neutral','2d8+2 (11 hp)',11,'–1','20 ft. (4 squares)','17 (+1 size, –1 Dex, +7 natural), touch 10, flat-footed 17','+1/+0','Slam +5 melee (1d6+4)','5 ft./5 ft.','+4','–1','+0',17,8,13,4,11,11,'Listen +3, Spot +2','Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Darkvision 60 ft., earth glide, elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Earth Elemental, Huge</th><th>Earth Elemental, Greater</th><th>Earth Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>–1</td><td>–1</td><td>–1</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, –1 Dex, +11 natural), touch 7, flat-footed 18</td><td>20 (–2 size, –1 Dex, +13 natural), touch 7, flat-footed 20</td><td>22 (–2 size, –1 Dex, +15 natural), touch 7, flat-footed 22</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+29</td><td>+15/+33</td><td>+18/+37</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d10+9)</td><td>Slam +23 melee (2d10+10)</td><td>Slam +27 melee (2d10+11/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d10+9)</td><td>2 slams +23 melee (2d10+10) 2</td><td>slams +27 melee (2d10+11/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Earth mastery, push</td><td>Earth mastery, push</td><td>Earth mastery, push</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +4, Will +7</td><td>Fort +17, Ref +6, Will +9</td><td>Fort +19, Ref +7, Will +10</td></tr><tr><th>Abilities:</th><td>Str 29, Dex 8, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 31, Dex 8, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 33, Dex 8, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +10, Spot +9</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Critical (slam), Improved Sunder, Iron Will, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"Slam +5 melee (1d6+4)","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"3 HD (Small)","level_adjustment":"—","statblock":{"hit_dice":"2d8+2 (11 hp)","hit_points":11,"base_attack_grapple":"+1/+0","attack":"Slam +5 melee (1d6+4)","full_attack":"Slam +5 melee (1d6+4)","space_reach":"5 ft./5 ft.","saves":"Fort +4, Ref –1, Will +0","abilities":{"str":"17","dex":"8","con":"13","int":"4","wis":"11","cha":"11"},"skills":"Listen +3, Spot +2","feats":"Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Darkvision 60 ft., earth glide, elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_medium','Earth Elemental, Medium','Earth Elemental, Medium','3','Medium','Elemental (Earth, Extraplanar)','Usually neutral','4d8+12 (30 hp)',30,'–1','20 ft. (4 squares)','18 (–1 Dex, +9 natural), touch 9, flat-footed 18','+3/+8','Slam +8 melee (1d8+7)','5 ft./5 ft.','+7','+0','+1',21,8,17,4,11,11,'Listen +4, Spot +3','Cleave, Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Darkvision 60 ft., earth glide, elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Earth Elemental, Huge</th><th>Earth Elemental, Greater</th><th>Earth Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>–1</td><td>–1</td><td>–1</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, –1 Dex, +11 natural), touch 7, flat-footed 18</td><td>20 (–2 size, –1 Dex, +13 natural), touch 7, flat-footed 20</td><td>22 (–2 size, –1 Dex, +15 natural), touch 7, flat-footed 22</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+29</td><td>+15/+33</td><td>+18/+37</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d10+9)</td><td>Slam +23 melee (2d10+10)</td><td>Slam +27 melee (2d10+11/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d10+9)</td><td>2 slams +23 melee (2d10+10) 2</td><td>slams +27 melee (2d10+11/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Earth mastery, push</td><td>Earth mastery, push</td><td>Earth mastery, push</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +4, Will +7</td><td>Fort +17, Ref +6, Will +9</td><td>Fort +19, Ref +7, Will +10</td></tr><tr><th>Abilities:</th><td>Str 29, Dex 8, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 31, Dex 8, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 33, Dex 8, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +10, Spot +9</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Critical (slam), Improved Sunder, Iron Will, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"Slam +8 melee (1d8+7)","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"5–7 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"4d8+12 (30 hp)","hit_points":30,"base_attack_grapple":"+3/+8","attack":"Slam +8 melee (1d8+7)","full_attack":"Slam +8 melee (1d8+7)","space_reach":"5 ft./5 ft.","saves":"Fort +7, Ref +0, Will +1","abilities":{"str":"21","dex":"8","con":"17","int":"4","wis":"11","cha":"11"},"skills":"Listen +4, Spot +3","feats":"Cleave, Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Darkvision 60 ft., earth glide, elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_large','Earth Elemental, Large','Earth Elemental, Large','5','Large','Elemental (Earth, Extraplanar)','Usually neutral','8d8+32 (68 hp)',68,'–1','20 ft. (4 squares)','18 (–1 size, –1 Dex, +10 natural), touch 8, flat-footed 18','+6/+17','Slam +12 melee (2d8+7)','10 ft./10 ft.','+10','+1','+2',25,8,19,6,11,11,'Listen +6, Spot +5','Cleave, Great Cleave, Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Earth Elemental, Huge</th><th>Earth Elemental, Greater</th><th>Earth Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td><td>Huge Elemental <small>(Earth, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+80 (152 hp)</td><td>21d8+105 (199 hp)</td><td>24d8+120 (228 hp)</td></tr><tr><th>Initiative:</th><td>–1</td><td>–1</td><td>–1</td></tr><tr><th>Speed:</th><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td><td>30 ft. (6 squares)</td></tr><tr><th>Armor Class:</th><td>18 (–2 size, –1 Dex, +11 natural), touch 7, flat-footed 18</td><td>20 (–2 size, –1 Dex, +13 natural), touch 7, flat-footed 20</td><td>22 (–2 size, –1 Dex, +15 natural), touch 7, flat-footed 22</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+29</td><td>+15/+33</td><td>+18/+37</td></tr><tr><th>Attack:</th><td>Slam +19 melee (2d10+9)</td><td>Slam +23 melee (2d10+10)</td><td>Slam +27 melee (2d10+11/19–20)</td></tr><tr><th>Full Attack:</th><td>2 slams +19 melee (2d10+9)</td><td>2 slams +23 melee (2d10+10) 2</td><td>slams +27 melee (2d10+11/19–20)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Earth mastery, push</td><td>Earth mastery, push</td><td>Earth mastery, push</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td><td>Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits</td></tr><tr><th>Saves:</th><td>Fort +15, Ref +4, Will +7</td><td>Fort +17, Ref +6, Will +9</td><td>Fort +19, Ref +7, Will +10</td></tr><tr><th>Abilities:</th><td>Str 29, Dex 8, Con 21, Int 6, Wis 11, Cha 11</td><td>Str 31, Dex 8, Con 21, Int 8, Wis 11, Cha 11</td><td>Str 33, Dex 8, Con 21, Int 10, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +10, Spot +9</td><td>Listen +14, Spot +14</td><td>Listen +29, Spot +29</td></tr><tr><th>Feats:</th><td>Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack</td><td>Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Critical (slam), Improved Sunder, Iron Will, Power Attack</td></tr><tr><th>Environment:</th><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td><td>Elemental Plane of Earth</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"2 slams +12 melee (2d8+7)","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"9–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d8+32 (68 hp)","hit_points":68,"base_attack_grapple":"+6/+17","attack":"Slam +12 melee (2d8+7)","full_attack":"2 slams +12 melee (2d8+7)","space_reach":"10 ft./10 ft.","saves":"Fort +10, Ref +1, Will +2","abilities":{"str":"25","dex":"8","con":"19","int":"6","wis":"11","cha":"11"},"skills":"Listen +6, Spot +5","feats":"Cleave, Great Cleave, Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_huge','Earth Elemental, Huge','Earth Elemental, Huge','7','Huge','Elemental (Earth, Extraplanar)','Usually neutral','16d8+80 (152 hp)',152,'–1','30 ft. (6 squares)','18 (–2 size, –1 Dex, +11 natural), touch 7, flat-footed 18','+12/+29','Slam +19 melee (2d10+9)','15 ft./15 ft.','+15','+4','+7',29,8,21,6,11,11,'Listen +10, Spot +9','Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Iron Will, Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits"}'::jsonb,'When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"2 slams +19 melee (2d10+9)","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"17–20 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+80 (152 hp)","hit_points":152,"base_attack_grapple":"+12/+29","attack":"Slam +19 melee (2d10+9)","full_attack":"2 slams +19 melee (2d10+9)","space_reach":"15 ft./15 ft.","saves":"Fort +15, Ref +4, Will +7","abilities":{"str":"29","dex":"8","con":"21","int":"6","wis":"11","cha":"11"},"skills":"Listen +10, Spot +9","feats":"Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Iron Will, Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 5/–, earth glide, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_greater','Earth Elemental, Greater','Earth Elemental, Greater','9','Huge','Elemental (Earth, Extraplanar)','Usually neutral','21d8+105 (199 hp)',199,'–1','30 ft. (6 squares)','20 (–2 size, –1 Dex, +13 natural), touch 7, flat-footed 20','+15/+33','Slam +23 melee (2d10+10)','15 ft./15 ft.','+17','+6','+9',31,8,21,8,11,11,'Listen +14, Spot +14','Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits"}'::jsonb,'When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"2 slams +23 melee (2d10+10) 2","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"22–23 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"21d8+105 (199 hp)","hit_points":199,"base_attack_grapple":"+15/+33","attack":"Slam +23 melee (2d10+10)","full_attack":"2 slams +23 melee (2d10+10) 2","space_reach":"15 ft./15 ft.","saves":"Fort +17, Ref +6, Will +9","abilities":{"str":"31","dex":"8","con":"21","int":"8","wis":"11","cha":"11"},"skills":"Listen +14, Spot +14","feats":"Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Sunder, Iron Will, Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('earth_elemental_elder','Earth Elemental, Elder','Earth Elemental, Elder','11','Huge','Elemental (Earth, Extraplanar)','Usually neutral','24d8+120 (228 hp)',228,'–1','30 ft. (6 squares)','22 (–2 size, –1 Dex, +15 natural), touch 7, flat-footed 22','+18/+37','Slam +27 melee (2d10+11/19–20)','15 ft./15 ft.','+19','+7','+10',33,8,21,10,11,11,'Listen +29, Spot +29','Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Critical (slam), Improved Sunder, Iron Will, Power Attack','{"special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits"}'::jsonb,'When summoned to the Material Plane, an earth elemental consists of whatever types of dirt, stones, precious metals, and gems it was conjured from.

Earth elementals speak Terran but rarely choose to do so.

#### Combat

Though an earth elemental moves slowly, it is a relentless opponent. It can travel though solid ground or stone as easily as humans walk on the earth’s surface. It cannot swim, however, and must either walk around a body of water or go through the ground under it. An earth elemental can move along the bottom of a body of water but prefers not to.

**Earth Mastery (Ex):** An earth elemental gains a +1 bonus on attack and damage rolls if both it and its foe are touching the ground. If an opponent is airborne or waterborne, the elemental takes a –4 penalty on attack and damage rolls. (These modifiers are not included in the statistics block.)

**Push (Ex):** An earth elemental can start a bull rush maneuver without provoking an attack of opportunity. The combat modifiers given in Earth Mastery, above, also apply to the elemental’s opposed Strength checks.

**Earth Glide (Ex):** An earth elemental can glide through stone, dirt, or almost any other sort of earth except metal as easily as a fish swims through water. Its burrowing leaves behind no tunnel or hole, nor does it create any ripple or other signs of its presence. A _move earth_ spell cast on an area containing a burrowing earth elemental flings the elemental back 30 feet, stunning the creature for 1 round unless it succeeds on a DC 15 Fortitude save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="6">Earth Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Elemental</th><th>Height</th><th>Weight</th></tr><tr><td>Small</td><td>4 ft.</td><td>80 lb.</td><td>Huge</td><td>32 ft.</td><td>48,000 lb.</td></tr><tr><td>Medium</td><td>8 ft.</td><td>750 lb.</td><td>Greater</td><td>36 ft.</td><td>54,000 lb.</td></tr><tr><td>Large</td><td>16 ft.</td><td>6,000 lb.</td><td>Elder</td><td>40 ft.</td><td>60,000 lb.</td></tr></tbody></table>','{"full_attack":"slams +27 melee (2d10+11/19–20)","environment":"Elemental Plane of Earth","organization":"Solitary","treasure":"None","advancement":"25–48 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"24d8+120 (228 hp)","hit_points":228,"base_attack_grapple":"+18/+37","attack":"Slam +27 melee (2d10+11/19–20)","full_attack":"slams +27 melee (2d10+11/19–20)","space_reach":"15 ft./15 ft.","saves":"Fort +19, Ref +7, Will +10","abilities":{"str":"33","dex":"8","con":"21","int":"10","wis":"11","cha":"11"},"skills":"Listen +29, Spot +29","feats":"Alertness, Awesome Blow, Cleave, Great Cleave, Improved Bull Rush, Improved Critical (slam), Improved Sunder, Iron Will, Power Attack","special_attacks":"Earth mastery, push","special_qualities":"Damage reduction 10/–, earth glide, darkvision 60 ft., elemental traits"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_small','Fire Elemental, Small','Fire Elemental, Small','1','Small','Elemental (Fire, Extraplanar)','Usually neutral','2d8 (9 hp)',9,'+5','50 ft. (10 squares)','15 (+1 size, +1 Dex, +3 natural), touch 12, flat-footed 14','+1/–3','Slam +3 melee (1d4 plus 1d4 fire)','5 ft./5 ft.','+0','+4','+0',10,13,10,4,11,11,'Listen +2, Spot +3','Dodge, Improved InitiativeB, Weapon FinesseB','{"special_attacks":"Burn","special_qualities":"Darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Fire Elemental, Huge</th><th>Fire Elemental, Greater</th><th>Fire Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+11</td><td>+12</td><td>+13</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td></tr><tr><th>Armor Class:</th><td>19 (–2 size, +7 Dex, +4 natural), touch 15, flat-footed 12</td><td>24 (–2 size, +8 Dex, +8 natural), touch 16, flat-footed 16</td><td>25 (–2 size, +9 Dex, +8 natural), touch 17, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d8+4 plus 2d8 fire)</td><td>Slam +22 melee (2d8+5 plus 2d8 fire)</td><td>Slam +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d8+4 plus 2d8 fire)</td><td>2 slams +22 melee (2d8+5 plus 2d8 fire)</td><td>2 slams +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Burn</td><td>Burn</td><td>Burn</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +17, Will +7</td><td>Fort +11, Ref +20, Will +9</td><td>Fort +14, Ref +23, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 25, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 27, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 22, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +28, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Great Fortitude, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td></tr><tr><th>Environment:</th><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"Slam +3 melee (1d4 plus 1d4 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"3 HD (Small)","level_adjustment":"—","statblock":{"hit_dice":"2d8 (9 hp)","hit_points":9,"base_attack_grapple":"+1/–3","attack":"Slam +3 melee (1d4 plus 1d4 fire)","full_attack":"Slam +3 melee (1d4 plus 1d4 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +0, Ref +4, Will +0","abilities":{"str":"10","dex":"13","con":"10","int":"4","wis":"11","cha":"11"},"skills":"Listen +2, Spot +3","feats":"Dodge, Improved InitiativeB, Weapon FinesseB","special_attacks":"Burn","special_qualities":"Darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_medium','Fire Elemental, Medium','Fire Elemental, Medium','3','Medium','Elemental (Fire, Extraplanar)','Usually neutral','4d8+8 (26 hp)',26,'+7','50 ft. (10 squares)','16 (+3 Dex, +3 natural), touch 13, flat-footed 13','+3/+4','Slam +6 melee (1d6+1 plus 1d6 fire)','5 ft./5 ft.','+3','+7','+1',12,17,14,4,11,11,'Listen +3, Spot +4','Dodge, Improved InitiativeB, Mobility, Weapon FinesseB','{"special_attacks":"Burn","special_qualities":"Darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Fire Elemental, Huge</th><th>Fire Elemental, Greater</th><th>Fire Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+11</td><td>+12</td><td>+13</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td></tr><tr><th>Armor Class:</th><td>19 (–2 size, +7 Dex, +4 natural), touch 15, flat-footed 12</td><td>24 (–2 size, +8 Dex, +8 natural), touch 16, flat-footed 16</td><td>25 (–2 size, +9 Dex, +8 natural), touch 17, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d8+4 plus 2d8 fire)</td><td>Slam +22 melee (2d8+5 plus 2d8 fire)</td><td>Slam +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d8+4 plus 2d8 fire)</td><td>2 slams +22 melee (2d8+5 plus 2d8 fire)</td><td>2 slams +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Burn</td><td>Burn</td><td>Burn</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +17, Will +7</td><td>Fort +11, Ref +20, Will +9</td><td>Fort +14, Ref +23, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 25, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 27, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 22, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +28, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Great Fortitude, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td></tr><tr><th>Environment:</th><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"Slam +6 melee (1d6+1 plus 1d6 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"5–7 HD (Medium)","level_adjustment":"—","statblock":{"hit_dice":"4d8+8 (26 hp)","hit_points":26,"base_attack_grapple":"+3/+4","attack":"Slam +6 melee (1d6+1 plus 1d6 fire)","full_attack":"Slam +6 melee (1d6+1 plus 1d6 fire)","space_reach":"5 ft./5 ft.","saves":"Fort +3, Ref +7, Will +1","abilities":{"str":"12","dex":"17","con":"14","int":"4","wis":"11","cha":"11"},"skills":"Listen +3, Spot +4","feats":"Dodge, Improved InitiativeB, Mobility, Weapon FinesseB","special_attacks":"Burn","special_qualities":"Darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_large','Fire Elemental, Large','Fire Elemental, Large','5','Large','Elemental (Fire, Extraplanar)','Usually neutral','8d8+24 (60 hp)',60,'+9','50 ft. (10 squares)','18 (–1 size, +5 Dex, +4 natural), touch 14, flat-footed 13','+6/+12','Slam +10 melee (2d6+2 plus 2d6 fire)','10 ft./10 ft.','+5','+11','+2',14,21,16,6,11,11,'Listen +5, Spot +6','Dodge, Improved Initiative B,Mobility, Spring Attack, Weapon FinesseB','{"special_attacks":"Burn","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'<table data-debug="no-caption" class="full-width-table"><tbody><tr><td></td><th>Fire Elemental, Huge</th><th>Fire Elemental, Greater</th><th>Fire Elemental, Elder</th></tr><tr><td></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td><td>Huge Elemental <small>(Fire, Extraplanar)</small></td></tr><tr><th>Hit Dice:</th><td>16d8+64 (136 hp)</td><td>21d8+84 (178 hp)</td><td>24d8+96 (204 hp)</td></tr><tr><th>Initiative:</th><td>+11</td><td>+12</td><td>+13</td></tr><tr><th>Speed:</th><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td><td>60 ft. (12 squares)</td></tr><tr><th>Armor Class:</th><td>19 (–2 size, +7 Dex, +4 natural), touch 15, flat-footed 12</td><td>24 (–2 size, +8 Dex, +8 natural), touch 16, flat-footed 16</td><td>25 (–2 size, +9 Dex, +8 natural), touch 17, flat-footed 16</td></tr><tr><th>Base Attack/Grapple:</th><td>+12/+24</td><td>+15/+28</td><td>+18/+32</td></tr><tr><th>Attack:</th><td>Slam +17 melee (2d8+4 plus 2d8 fire)</td><td>Slam +22 melee (2d8+5 plus 2d8 fire)</td><td>Slam +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Full Attack:</th><td>2 slams +17 melee (2d8+4 plus 2d8 fire)</td><td>2 slams +22 melee (2d8+5 plus 2d8 fire)</td><td>2 slams +26 melee (2d8+6 plus 2d8 fire)</td></tr><tr><th>Space/Reach:</th><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td><td>15 ft./15 ft.</td></tr><tr><th>Special Attacks:</th><td>Burn</td><td>Burn</td><td>Burn</td></tr><tr><th>Special Qualities:</th><td>Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td><td>Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold</td></tr><tr><th>Saves:</th><td>Fort +9, Ref +17, Will +7</td><td>Fort +11, Ref +20, Will +9</td><td>Fort +14, Ref +23, Will +10</td></tr><tr><th>Abilities:</th><td>Str 18, Dex 25, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 20, Dex 27, Con 18, Int 6, Wis 11, Cha 11</td><td>Str 22, Dex 29, Con 18, Int 6, Wis 11, Cha 11</td></tr><tr><th>Skills:</th><td>Listen +11, Spot +12</td><td>Listen +14, Spot +14</td><td>Listen +28, Spot +29</td></tr><tr><th>Feats:</th><td>Alertness, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup></td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td><td>Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative <sup>B</sup>, Great Fortitude, Iron Will, Mobility, Spring Attack, Weapon Finesse<sup>B</sup>, Weapon Focus (slam)</td></tr><tr><th>Environment:</th><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td><td>Elemental Plane of Fire</td></tr><tr><th>Organization:</th><td>Solitary</td><td>Solitary</td><td>Solitary</td></tr><tr><th>Challenge Rating:</th><td>7</td><td>9</td><td>11</td></tr><tr><th>Treasure:</th><td>None</td><td>None</td><td>None</td></tr><tr><th>Alignment:</th><td>Usually neutral</td><td>Usually neutral</td><td>Usually neutral</td></tr><tr><th>Advancement:</th><td>17–20 HD (Huge)</td><td>22–23 HD (Huge)</td><td>25–48 HD (Huge)</td></tr><tr><th>Level Adjustment:</th><td>—</td><td>—</td><td>—</td></tr></tbody></table>

A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"2 slams +10 melee (2d6+2 plus 2d6 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"9–15 HD (Large)","level_adjustment":"—","statblock":{"hit_dice":"8d8+24 (60 hp)","hit_points":60,"base_attack_grapple":"+6/+12","attack":"Slam +10 melee (2d6+2 plus 2d6 fire)","full_attack":"2 slams +10 melee (2d6+2 plus 2d6 fire)","space_reach":"10 ft./10 ft.","saves":"Fort +5, Ref +11, Will +2","abilities":{"str":"14","dex":"21","con":"16","int":"6","wis":"11","cha":"11"},"skills":"Listen +5, Spot +6","feats":"Dodge, Improved Initiative B,Mobility, Spring Attack, Weapon FinesseB","special_attacks":"Burn","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_huge','Fire Elemental, Huge','Fire Elemental, Huge','7','Huge','Elemental (Fire, Extraplanar)','Usually neutral','16d8+64 (136 hp)',136,'+11','60 ft. (12 squares)','19 (–2 size, +7 Dex, +4 natural), touch 15, flat-footed 12','+12/+24','Slam +17 melee (2d8+4 plus 2d8 fire)','15 ft./15 ft.','+9','+17','+7',18,25,18,6,11,11,'Listen +11, Spot +12','Alertness, Combat Reflexes, Dodge, Improved Initiative B, Iron Will, Mobility, Spring Attack, Weapon FinesseB','{"special_attacks":"Burn","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"2 slams +17 melee (2d8+4 plus 2d8 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"17–20 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"16d8+64 (136 hp)","hit_points":136,"base_attack_grapple":"+12/+24","attack":"Slam +17 melee (2d8+4 plus 2d8 fire)","full_attack":"2 slams +17 melee (2d8+4 plus 2d8 fire)","space_reach":"15 ft./15 ft.","saves":"Fort +9, Ref +17, Will +7","abilities":{"str":"18","dex":"25","con":"18","int":"6","wis":"11","cha":"11"},"skills":"Listen +11, Spot +12","feats":"Alertness, Combat Reflexes, Dodge, Improved Initiative B, Iron Will, Mobility, Spring Attack, Weapon FinesseB","special_attacks":"Burn","special_qualities":"Damage reduction 5/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_greater','Fire Elemental, Greater','Fire Elemental, Greater','9','Huge','Elemental (Fire, Extraplanar)','Usually neutral','21d8+84 (178 hp)',178,'+12','60 ft. (12 squares)','24 (–2 size, +8 Dex, +8 natural), touch 16, flat-footed 16','+15/+28','Slam +22 melee (2d8+5 plus 2d8 fire)','15 ft./15 ft.','+11','+20','+9',20,27,18,6,11,11,'Listen +14, Spot +14','Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative B, Iron Will, Mobility, Spring Attack, Weapon FinesseB, Weapon Focus (slam)','{"special_attacks":"Burn","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"2 slams +22 melee (2d8+5 plus 2d8 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"22–23 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"21d8+84 (178 hp)","hit_points":178,"base_attack_grapple":"+15/+28","attack":"Slam +22 melee (2d8+5 plus 2d8 fire)","full_attack":"2 slams +22 melee (2d8+5 plus 2d8 fire)","space_reach":"15 ft./15 ft.","saves":"Fort +11, Ref +20, Will +9","abilities":{"str":"20","dex":"27","con":"18","int":"6","wis":"11","cha":"11"},"skills":"Listen +14, Spot +14","feats":"Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative B, Iron Will, Mobility, Spring Attack, Weapon FinesseB, Weapon Focus (slam)","special_attacks":"Burn","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true),
('fire_elemental_elder','Fire Elemental, Elder','Fire Elemental, Elder','11','Huge','Elemental (Fire, Extraplanar)','Usually neutral','24d8+96 (204 hp)',204,'+13','60 ft. (12 squares)','25 (–2 size, +9 Dex, +8 natural), touch 17, flat-footed 16','+18/+32','Slam +26 melee (2d8+6 plus 2d8 fire)','15 ft./15 ft.','+14','+23','+10',22,29,18,6,11,11,'Listen +28, Spot +29','Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative B, Great Fortitude, Iron Will, Mobility, Spring Attack, Weapon FinesseB, Weapon Focus (slam)','{"special_attacks":"Burn","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"}'::jsonb,'A fire elemental cannot enter water or any other nonflammable liquid. A body of water is an impassible barrier unless the fire elemental can step or jump over it.

Fire elementals speak Ignan, though they rarely choose to do so.

#### Combat

A fire elemental is a fierce opponent that attacks its enemies directly and savagely. It takes joy in burning the creatures and objects of the Material Plane to ashes.

**Burn (Ex):** A fire elemental’s slam attack deals bludgeoning damage plus fire damage from the elemental’s flaming body. Those hit by a fire elemental‘s slam attack also must succeed on a Reflex save or catch on fire. The flame burns for 1d4 rounds. The save DC varies with the elemental’s size (see the table below). A burning creature can take a move action to put out the flame. The save DC is Constitution- based.

Creatures hitting a fire elemental with natural weapons or unarmed attacks take fire damage as though hit by the elemental’s attack, and also catch on fire unless they succeed on a Reflex save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="4">Fire Elemental Sizes</th></tr><tr><th>Elemental</th><th>Height</th><th>Weight</th><th>Burn Save DC</th></tr><tr><td>Small</td><td>4 ft.</td><td>1 lb.</td><td>11</td></tr><tr><td>Medium</td><td>8 ft.</td><td>2 lb.</td><td>14</td></tr><tr><td>Large</td><td>16 ft.</td><td>4 lb.</td><td>17</td></tr><tr><td>Huge</td><td>32 ft.</td><td>8 lb.</td><td>22</td></tr><tr><td>Greater</td><td>36 ft.</td><td>10 lb.</td><td>24</td></tr><tr><td>Elder</td><td>40 ft.</td><td>12 lb.</td><td>26</td></tr></tbody></table>','{"full_attack":"2 slams +26 melee (2d8+6 plus 2d8 fire)","environment":"Elemental Plane of Fire","organization":"Solitary","treasure":"None","advancement":"25–48 HD (Huge)","level_adjustment":"—","statblock":{"hit_dice":"24d8+96 (204 hp)","hit_points":204,"base_attack_grapple":"+18/+32","attack":"Slam +26 melee (2d8+6 plus 2d8 fire)","full_attack":"2 slams +26 melee (2d8+6 plus 2d8 fire)","space_reach":"15 ft./15 ft.","saves":"Fort +14, Ref +23, Will +10","abilities":{"str":"22","dex":"29","con":"18","int":"6","wis":"11","cha":"11"},"skills":"Listen +28, Spot +29","feats":"Alertness, Blind-Fight, Combat Reflexes, Dodge, Improved Initiative B, Great Fortitude, Iron Will, Mobility, Spring Attack, Weapon FinesseB, Weapon Focus (slam)","special_attacks":"Burn","special_qualities":"Damage reduction 10/–, darkvision 60 ft., elemental traits, immunity to fire, vulnerability to cold"},"source_file":"monsters-e-f.md","source_dataset":"olimot/srd-v3.5-md"}'::jsonb,'https://olimot.github.io/srd-v3.5/monsters/monsters-e-f.html',true)
on conflict(id) do update set nome=case when public.srd_monsters.srd_canonical then public.srd_monsters.nome else excluded.nome end,nome_original=excluded.nome_original,nd=excluded.nd,tamanho=excluded.tamanho,tipo=excluded.tipo,tendencia=excluded.tendencia,dados_vida=excluded.dados_vida,pv=excluded.pv,iniciativa=excluded.iniciativa,deslocamento=excluded.deslocamento,ca=excluded.ca,base_attack_grapple=excluded.base_attack_grapple,ataques=excluded.ataques,espaco_alcance=excluded.espaco_alcance,fortitude=excluded.fortitude,reflexos=excluded.reflexos,vontade=excluded.vontade,forca=excluded.forca,destreza=excluded.destreza,constituicao=excluded.constituicao,inteligencia=excluded.inteligencia,sabedoria=excluded.sabedoria,carisma=excluded.carisma,pericias=excluded.pericias,talentos=excluded.talentos,qualidades_especiais=excluded.qualidades_especiais,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,srd_canonical=true;