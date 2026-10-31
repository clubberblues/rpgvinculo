-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_summon_nature_s_ally_v','Summon Nature’s Ally V','Drd 5',5,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Drd 5

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 5th-level creature, 1d3 4th-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":5},"source_field_values":{"Level":"Drd 5","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_vi','Summon Nature’s Ally VI','Drd 6',6,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Drd 6

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 6th-level creature, 1d3 5th-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_vii','Summon Nature’s Ally VII','Drd 7',7,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Drd 7

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 7th-level creature, 1d3 6th-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_viii','Summon Nature’s Ally VIII','Animal 8, Drd 8',8,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Animal 8, Drd 8

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 8th-level creature, 1d3 7th-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":8},"source_field_values":{"Level":"Animal 8, Drd 8","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_ix','Summon Nature’s Ally IX','Drd 9',9,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Drd 9

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 9th-level creature, 1d3 8th-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Summon Nature’s Ally</th></tr><tr><th>1st Level</th></tr><tr><td>Dire rat</td></tr><tr><td>Eagle (animal)</td></tr><tr><td>Monkey (animal)</td></tr><tr><td>Octopus<sup>1</sup>(animal)</td></tr><tr><td>Owl (animal)</td></tr><tr><td>Porpoise<sup>1</sup>(animal)</td></tr><tr><td>Snake, Small viper (animal)</td></tr><tr><td>Wolf (animal)</td></tr><tr><th>2nd Level</th></tr><tr><td>Bear, black (animal)</td></tr><tr><td>Crocodile (animal)</td></tr><tr><td>Dire badger</td></tr><tr><td>Dire bat</td></tr><tr><td>Elemental, Small (any)</td></tr><tr><td>Hippogriff</td></tr><tr><td>Shark, Medium<sup>1</sup>(animal)</td></tr><tr><td>Snake, Medium viper (animal)</td></tr><tr><td>Squid<sup>1</sup>(animal)</td></tr><tr><td>Wolverine (animal)</td></tr><tr><th>3rd Level</th></tr><tr><td>Ape (animal)</td></tr><tr><td>Dire weasel</td></tr><tr><td>Dire wolf</td></tr><tr><td>Eagle, giant [NG]</td></tr><tr><td>Lion</td></tr><tr><td>Owl, giant [NG]</td></tr><tr><td>Satyr [CN; without pipes]</td></tr><tr><td>Shark, Large<sup>1</sup>(animal)</td></tr><tr><td>Snake, constrictor (animal)</td></tr><tr><td>Snake, Large viper (animal)</td></tr><tr><td>Thoqqua</td></tr><tr><th>4th Level</th></tr><tr><td>Arrowhawk, juvenile</td></tr><tr><td>Bear, brown (animal)</td></tr><tr><td>Crocodile, giant (animal)</td></tr><tr><td>Deinonychus (dinosaur)</td></tr><tr><td>Dire ape</td></tr><tr><td>Dire boar</td></tr><tr><td>Dire wolverine</td></tr><tr><td>Elemental, Medium (any)</td></tr><tr><td>Salamander, flamebrother [NE]</td></tr><tr><td>Sea cat<sup>1</sup></td></tr><tr><td>Shark, Huge<sup>1</sup>(animal)</td></tr><tr><td>Snake, Huge viper (animal)</td></tr><tr><td>Tiger (animal)</td></tr><tr><td>Tojanida, juvenile<sup>1</sup></td></tr><tr><td>Unicorn [CG]</td></tr><tr><td>Xorn, minor</td></tr><tr><th>5th Level</th></tr><tr><td>Arrowhawk, adult</td></tr><tr><td>Bear, polar (animal)</td></tr><tr><td>Dire lion</td></tr><tr><td>Elasmosaurus<sup>1</sup>(dinosaur)</td></tr><tr><td>Elemental, Large (any)</td></tr><tr><td>Griffon</td></tr><tr><td>Janni (genie)</td></tr><tr><td>Rhinoceros (animal)</td></tr><tr><td>Satyr [CN; with pipes]</td></tr><tr><td>Snake, giant constrictor (animal)</td></tr><tr><td>Nixie (sprite)</td></tr><tr><td>Tojanida, adult<sup>1</sup></td></tr><tr><td>Whale, orca<sup>1</sup>(animal)</td></tr><tr><th>6th Level</th></tr><tr><td>Dire bear</td></tr><tr><td>Elemental, Huge (any)</td></tr><tr><td>Elephant (animal)</td></tr><tr><td>Girallon</td></tr><tr><td>Megaraptor (dinosaur)</td></tr><tr><td>Octopus, giant<sup>1</sup>(animal)</td></tr><tr><td>Pixie* (sprite) [NG; no special arrows]</td></tr><tr><td>Salamander, average [NE]</td></tr><tr><td>Whale, baleen<sup>1</sup></td></tr><tr><td>Xorn, average</td></tr><tr><td>*Can’t cast <i>irresistible dance</i></td></tr><tr><th>7th Level</th></tr><tr><td>Arrowhawk, elder</td></tr><tr><td>Dire tiger</td></tr><tr><td>Elemental, greater (any)</td></tr><tr><td>Djinni (genie) [NG]</td></tr><tr><td>Invisible stalker</td></tr><tr><td>Pixie* (sprite) [NG; with sleep arrows]</td></tr><tr><td>Squid, giant<sup>1</sup>(animal)</td></tr><tr><td>Triceratops (dinosaur)</td></tr><tr><td>Tyrannosaurus (dinosaur)</td></tr><tr><td>Whale, cachalot<sup>1</sup>(animal)</td></tr><tr><td>Xorn, elder</td></tr><tr><td>*Can’t cast <i>irresistible dance</i></td></tr><tr><th>8th Level</th></tr><tr><td>Dire shark<sup>1</sup></td></tr><tr><td>Roc</td></tr><tr><td>Salamander, noble [NE]</td></tr><tr><td>Tojanida, elder</td></tr><tr><th>9th Level</th></tr><tr><td>Elemental, elder</td></tr><tr><td>Grig [NG; with fiddle] (sprite)</td></tr><tr><td>Pixie* (sprite) [NG; with sleep and memory loss arrows]</td></tr><tr><td>Unicorn, celestial charger</td></tr><tr><td>*Can cast <i>irresistible dance</i></td></tr><tr><td>1 May be summoned only into an aquatic or watery environment.</td></tr></tbody></table>','{"class_levels":{"druid":9},"source_field_values":{"Level":"Drd 9","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_swarm','Summon Swarm','Brd 2, Drd 2, Sor/Wiz 2',2,'Conjuration (Summoning)','Close (25 ft. + 5 ft./2 levels)','One swarm of bats, rats, or spiders',NULL,'Concentration + 2 rounds','V, S, M/DF',ARRAY['bard','druid','sorcerer','wizard']::text[],'Conjuration (Summoning)

Level: Brd 2, Drd 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One swarm of bats, rats, or spiders

Duration: Concentration + 2 rounds

Saving Throw: None

Spell Resistance: No

You summon a swarm of bats, rats, or spiders (your choice), which attacks all other creatures within its area. (You may summon the swarm so that it shares the area of other creatures.) If no living creatures are within its area, the swarm attacks or pursues the nearest creature as best it can. The caster has no control over its target or direction of travel.

Arcane Material Component: A square of red cloth.','{"class_levels":{"bard":2,"druid":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Drd 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One swarm of bats, rats, or spiders","Duration":"Concentration + 2 rounds","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sunbeam','Sunbeam','Drd 7, Sun 7',7,'Evocation [Light]','60 ft.',NULL,'Line from your hand','1 round/level or until all beams are exhausted','V, S, DF',ARRAY['druid']::text[],'Evocation \[Light\]

Level: Drd 7, Sun 7

Components: V, S, DF

Casting Time: 1 standard action

Range: 60 ft.

Area: Line from your hand

Duration: 1 round/level or until all beams are exhausted

Saving Throw: Reflex negates and Reflex half; see text

Spell Resistance: Yes

For the duration of this spell, you can use a standard action to evoke a dazzling beam of intense light each round. You can call forth one beam per three caster levels (maximum six beams at 18th level). The spell ends when its duration runs out or your allotment of beams is exhausted.

Each creature in the beam is blinded and takes 4d6 points of damage. Any creatures to which sunlight is harmful or unnatural take double damage. A successful Reflex save negates the blindness and reduces the damage by half.

An undead creature caught within the beam takes 1d6 points of damage per caster level (maximum 20d6), or half damage if a Reflex save is successful. In addition, the beam results in the destruction of any undead creature specifically harmed by bright light if it fails its save.

The ultraviolet light generated by the spell deals damage to fungi, mold, oozes, and slimes just as if they were undead creatures.','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7, Sun 7","Components":"V, S, DF","Casting Time":"1 standard action","Range":"60 ft.","Area":"Line from your hand","Duration":"1 round/level or until all beams are exhausted","Saving Throw":"Reflex negates and Reflex half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sunburst','Sunburst','Drd 8, Sor/Wiz 8, Sun 8',8,'Evocation [Light]','Long (400 ft. + 40 ft./level)',NULL,'80-ft.-radius burst','Instantaneous','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Drd 8, Sor/Wiz 8, Sun 8

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: 80-ft.-radius burst

Duration: Instantaneous

Saving Throw: Reflex partial; see text

Spell Resistance: Yes

Sunburst causes a globe of searing radiance to explode silently from a point you select. All creatures in the globe are blinded and take 6d6 points of damage. A creature to which sunlight is harmful or unnatural takes double damage. A successful Reflex save negates the blindness and reduces the damage by half.

An undead creature caught within the globe takes 1d6 points of damage per caster level (maximum 25d6), or half damage if a Reflex save is successful. In addition, the burst results in the destruction of any undead creature specifically harmed by bright light if it fail its save.

The ultraviolet light generated by the spell deals damage to fungi, mold, oozes, and slimes just as if they were undead creatures.

Sunburst dispels any darkness spells of lower than 9th level within its area.

Arcane Material Component: A piece of sunstone and a naked flame.','{"class_levels":{"druid":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Drd 8, Sor/Wiz 8, Sun 8","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"80-ft.-radius burst","Duration":"Instantaneous","Saving Throw":"Reflex partial; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_death','Symbol of Death','Clr 8, Sor/Wiz 8',8,'Necromancy [Death]','0 ft.; see text','One symbol',NULL,'See text','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Death\]

Level: Clr 8, Sor/Wiz 8

Components: V, S, M

Casting Time: 10 minutes

Range: 0 ft.; see text

Effect: One symbol

Duration: See text

Saving Throw: Fortitude negates

Spell Resistance: Yes

This spell allows you to scribe a potent rune of power upon a surface. When triggered, a symbol of death slays one or more creatures within 60 feet of the symbol (treat as a burst) whose combined total current hit points do not exceed 150. The symbol of death affects the closest creatures first, skipping creatures with too many hit points to affect. Once triggered, the symbol becomes active and glows, lasting for 10 minutes per caster level or until it has affected 150 hit points’ worth of creatures, whichever comes first. Any creature that enters the area while the symbol of death is active is subject to its effect, whether or not that creature was in the area when it was triggered. A creature need save against the symbol only once as long as it remains within the area, though if it leaves the area and returns while the symbol is still active, it must save again.

Until it is triggered, the symbol of death is inactive (though visible and legible at a distance of 60 feet). To be effective, a symbol of death must always be placed in plain sight and in a prominent location. Covering or hiding the rune renders the symbol of death ineffective, unless a creature removes the covering, in which case the symbol of death works normally.

As a default, a symbol of death is triggered whenever a creature does one or more of the following, as you select: looks at the rune; reads the rune; touches the rune; passes over the rune; or passes through a portal bearing the rune. Regardless of the trigger method or methods chosen, a creature more than 60 feet from a symbol of death can’t trigger it (even if it meets one or more of the triggering conditions, such as reading the rune). Once the spell is cast, a symbol of death’s triggering conditions cannot be changed.

In this case, “reading” the rune means any attempt to study it, identify it, or fathom its meaning. Throwing a cover over a symbol of death to render it inoperative triggers it if the symbol reacts to touch. You can’t use a symbol of death offensively; for instance, a touch-triggered symbol of death remains untriggered if an item bearing the symbol of death is used to touch a creature. Likewise, a symbol of death cannot be placed on a weapon and set to activate when the weapon strikes a foe.

You can also set special triggering limitations of your own. These can be as simple or elaborate as you desire. Special conditions for triggering a symbol of death can be based on a creature’s name, identity, or alignment, but otherwise must be based on observable actions or qualities. Intangibles such as level, class, Hit Dice, and hit points don’t qualify.

When scribing a symbol of death, you can specify a password or phrase that prevents a creature using it from triggering the effect. Anyone using the password remains immune to that particular rune’s effects so long as the creature remains within 60 feet of the rune. If the creature leaves the radius and returns later, it must use the password again.

You also can attune any number of creatures to the symbol of death, but doing this can extend the casting time. Attuning one or two creatures takes negligible time, and attuning a small group (as many as ten creatures) extends the casting time to 1 hour. Attuning a large group (as many as twenty-five creatures) takes 24 hours. Attuning larger groups takes proportionately longer. Any creature attuned to a symbol of death cannot trigger it and is immune to its effects, even if within its radius when triggered. You are automatically considered attuned to your own symbols of death, and thus always ignore the effects and cannot inadvertently trigger them.

Read magic allows you to identify a symbol of death with a DC 19 Spellcraft check. Of course, if the symbol of death is set to be triggered by reading it, this will trigger the symbol.

A symbol of death can be removed by a successful dispel magic targeted solely on the rune. An erase spell has no effect on a symbol of death. Destruction of the surface where a symbol of death is inscribed destroys the symbol but also triggers it.

Symbol of death can be made permanent with a permanency spell. A permanent symbol of death that is disabled or that has affected its maximum number of hit points becomes inactive for 10 minutes, then can be triggered again as normal.

Note: Magic traps such as symbol of death are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of death and Disable Device to thwart it. The DC in each case is 25 + spell level, or 33 for symbol of death.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 5,000 gp each.','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Sor/Wiz 8","Components":"V, S, M","Casting Time":"10 minutes","Range":"0 ft.; see text","Effect":"One symbol","Duration":"See text","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_fear','Symbol of Fear','Clr 6, Sor/Wiz 6',6,'Necromancy [Fear, Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Fear, Mind-Affecting\]

Level: Clr 6, Sor/Wiz 6

Saving Throw: Will negates

This spell functions like symbol of death, except that all creatures within 60 feet of the symbol of fear instead become panicked for 1 round per caster level.

Note: Magic traps such as symbol of fear are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of fear and Disable Device to thwart it. The DC in each case is 25 + spell level, or 31 for symbol of fear.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 1,000 gp.','{"class_levels":{"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Sor/Wiz 6","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_insanity','Symbol of Insanity','Clr 8, Sor/Wiz 8',8,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 8, Sor/Wiz 8

Saving Throw: Will negates

This spell functions like symbol of death, except that all creatures within the radius of the symbol of insanity instead become permanently insane (as the insanity spell).

Unlike symbol of death, symbol of insanity has no hit point limit; once triggered, a symbol of insanity simply remains active for 10 minutes per caster level.

Note: Magic traps such as symbol of insanity are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of insanity and Disable Device to thwart it. The DC in each case is 25 + spell level, or 33 for symbol of insanity.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 5,000 gp.','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Sor/Wiz 8","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_pain','Symbol of Pain','Clr 5, Sor/Wiz 5',5,'Necromancy [Evil]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Clr 5, Sor/Wiz 5

This spell functions like symbol of death, except that each creature within the radius of a symbol of pain instead suffers wracking pains that impose a –4 penalty on attack rolls, skill checks, and ability checks. These effects last for 1 hour after the creature moves farther than 60 feet from the symbol.

Unlike symbol of death, symbol of pain has no hit point limit; once triggered, a symbol of pain simply remains active for 10 minutes per caster level.

Note: Magic traps such as symbol of pain are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of pain and Disable Device to thwart it. The DC in each case is 25 + spell level, or 30 for symbol of pain.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 1,000 gp.','{"class_levels":{"cleric":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Clr 5, Sor/Wiz 5"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_persuasion','Symbol of Persuasion','Clr 6, Sor/Wiz 6',6,'Enchantment (Charm) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Enchantment (Charm) \[Mind-Affecting\]

Level: Clr 6, Sor/Wiz 6

Saving Throw: Will negates

This spell functions like symbol of death, except that all creatures within the radius of a symbol of persuasion instead become charmed by the caster (as the charm monster spell) for 1 hour per caster level.

Unlike symbol of death, symbol of persuasion has no hit point limit; once triggered, a symbol of persuasion simply remains active for 10 minutes per caster level.

Note: Magic traps such as symbol of persuasion are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of persuasion and Disable Device to thwart it. The DC in each case is 25 + spell level, or 31 for symbol of persuasion.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 5,000 gp.','{"class_levels":{"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Sor/Wiz 6","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_sleep','Symbol of Sleep','Clr 5, Sor/Wiz 5',5,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 5, Sor/Wiz 5

Saving Throw: Will negates

This spell functions like symbol of death, except that all creatures of 10 HD or less within 60 feet of the symbol of sleep instead fall into a catatonic slumber for 3d6x10 minutes. Unlike with the sleep spell, sleeping creatures cannot be awakened by nonmagical means before this time expires.

Unlike symbol of death, symbol of sleep has no hit point limit; once triggered, a symbol of sleep simply remains active for 10 minutes per caster level.

Note: Magic traps such as symbol of sleep are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of sleep and Disable Device to thwart it. The DC in each case is 25 + spell level, or 30 for symbol of sleep.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 1,000 gp.','{"class_levels":{"cleric":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Clr 5, Sor/Wiz 5","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_stunning','Symbol of Stunning','Clr 7, Sor/Wiz 7',7,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 7, Sor/Wiz 7

Saving Throw: Will negates

This spell functions like symbol of death, except that all creatures within 60 feet of a symbol of stunning instead become stunned for 1d6 rounds.

Note: Magic traps such as symbol of stunning are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of stunning and Disable Device to thwart it. The DC in each case is 25 + spell level, or 32 for symbol of stunning.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 5,000 gp.','{"class_levels":{"cleric":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 7, Sor/Wiz 7","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_symbol_of_weakness','Symbol of Weakness','Clr 7, Sor/Wiz 7',7,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 7, Sor/Wiz 7

This spell functions like symbol of death, except that every creature within 60 feet of a symbol of weakness instead suffers crippling weakness that deals 3d6 points of Strength damage.

Unlike symbol of death, symbol of weakness has no hit point limit; once triggered, a symbol of weakness simply remains active for 10 minutes per caster level.

Note: Magic traps such as symbol of weakness are hard to detect and disable. A rogue (only) can use the Search skill to find a symbol of weakness and Disable Device to thwart it. The DC in each case is 25 + spell level, or 32 for symbol of weakness.

Material Component: Mercury and phosphorus, plus powdered diamond and opal with a total value of at least 5,000 gp.','{"class_levels":{"cleric":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 7, Sor/Wiz 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sympathetic_vibration','Sympathetic Vibration','Brd 6',6,'Evocation [Sonic]','Touch','One freestanding structure',NULL,'Up to 1 round/level','V, S, F',ARRAY['bard']::text[],'Evocation \[Sonic\]

Level: Brd 6

Components: V, S, F

Casting Time: 10 minutes

Range: Touch

Target: One freestanding structure

Duration: Up to 1 round/level

Saving Throw: None; see text

Spell Resistance: Yes

By attuning yourself to a freestanding structure such you can create a damaging vibration within it. Once it begins, the vibration deals 2d10 points of damage per round to the target structure. (Hardness has no effect on the spell’s damage.) You can choose at the time of casting to limit the duration of the spell; otherwise it lasts for 1 round/ level. If the spell is cast upon a target that is not freestanding the surrounding stone dissipates the effect and no damage occurs.

Sympathetic vibration cannot affect creatures (including constructs). Since a structure is an unattended object, it gets no saving throw to resist the effect.

Focus: A tuning fork.','{"class_levels":{"bard":6},"source_field_values":{"Level":"Brd 6","Components":"V, S, F","Casting Time":"10 minutes","Range":"Touch","Target":"One freestanding structure","Duration":"Up to 1 round/level","Saving Throw":"None; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sympathy','Sympathy','Drd 9, Sor/Wiz 8',8,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One location (up to a 10-ft. cube/level) or one object',NULL,'2 hours/level (D)','V, S, M',ARRAY['druid','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Drd 9, Sor/Wiz 8

Components: V, S, M

Casting Time: 1 hour

Range: Close (25 ft. + 5 ft./2 levels)

Target: One location (up to a 10-ft. cube/level) or one object

Duration: 2 hours/level (D)

Saving Throw: Will negates; see text

Spell Resistance: Yes

You cause an object or location to emanate magical vibrations that attract either a specific kind of intelligent creature or creatures of a particular alignment, as defined by you. The particular kind of creature to be affected must be named specifically. A creature subtype is not specific enough. Likewise, the specific alignment must be named.

Creatures of the specified kind or alignment feel elated and pleased to be in the area or desire to touch or to possess the object. The compulsion to stay in the area or touch the object is overpowering. If the save is successful, the creature is released from the enchantment, but a subsequent save must be made 1d6x10 minutes later. If this save fails, the affected creature attempts to return to the area or object.

Sympathy counters and dispels antipathy.

Material Component: 1,500 gp worth of crushed pearls and a drop of honey.','{"class_levels":{"druid":9,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Drd 9, Sor/Wiz 8","Components":"V, S, M","Casting Time":"1 hour","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One location (up to a 10-ft. cube/level) or one object","Duration":"2 hours/level (D)","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_telekinesis','Telekinesis','Sor/Wiz 5',5,'Transmutation','Long (400 ft. + 40 ft./level)',NULL,NULL,'Concentration (up to 1 round/ level) or instantaneous; see text','V, S',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Target or Targets: See text

Duration: Concentration (up to 1 round/ level) or instantaneous; see text

Saving Throw: Will negates (object) or None; see text

Spell Resistance: Yes (object); see text

You move objects or creatures by concentrating on them. Depending on the version selected, the spell can provide a gentle, sustained force, perform a variety of combat maneuvers, or exert a single short, violent thrust.

Sustained Force: A sustained force moves an object weighing no more than 25 pounds per caster level (maximum 375 pounds at 15th level) up to 20 feet per round. A creature can negate the effect on an object it possesses with a successful Will save or with spell resistance.

This version of the spell can last 1 round per caster level, but it ends if you cease concentration. The weight can be moved vertically, horizontally, or in both directions. An object cannot be moved beyond your range. The spell ends if the object is forced beyond the range. If you cease concentration for any reason, the object falls or stops.

An object can be telekinetically manipulated as if with one hand. For example, a lever or rope can be pulled, a key can be turned, an object rotated, and so on, if the force required is within the weight limitation. You might even be able to untie simple knots, though delicate activities such as these require Intelligence checks.

Combat Maneuver: Alternatively, once per round, you can use telekinesis to perform a bull rush, disarm, grapple (including pin), or trip. Resolve these attempts as normal, except that they don’t provoke attacks of opportunity, you use your caster level in place of your base attack bonus (for disarm and grapple), you use your Intelligence modifier (if a wizard) or Charisma modifier (if a sorcerer) in place of your Strength or Dexterity modifier, and a failed attempt doesn’t allow a reactive attempt by the target (such as for disarm or trip). No save is allowed against these attempts, but spell resistance applies normally. This version of the spell can last 1 round per caster level, but it ends if you cease concentration.

Violent Thrust: Alternatively, the spell energy can be spent in a single round. You can hurl one object or creature per caster level (maximum 15) that are within range and all within 10 feet of each other toward any target within 10 feet per level of all the objects. You can hurl up to a total weight of 25 pounds per caster level (maximum 375 pounds at 15th level).

You must succeed on attack rolls (one per creature or object thrown) to hit the target with the items, using your base attack bonus + your Intelligence modifier (if a wizard) or Charisma modifier (if a sorcerer). Weapons cause standard damage (with no Strength bonus; note that arrows or bolts deal damage as daggers of their size when used in this manner). Other objects cause damage ranging from 1 point per 25 pounds (for less dangerous objects) to 1d6 points of damage per 25 pounds (for hard, dense objects).

Creatures who fall within the weight capacity of the spell can be hurled, but they are allowed Will saves (and spell resistance) to negate the effect, as are those whose held possessions are targeted by the spell. If a telekinesed creature is hurled against a solid surface, it takes damage as if it had fallen 10 feet (1d6 points).','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Target or Targets":"See text","Duration":"Concentration (up to 1 round/ level) or instantaneous; see text","Saving Throw":"Will negates (object) or None; see text","Spell Resistance":"Yes (object); see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_telekinetic_sphere','Telekinetic Sphere','Sor/Wiz 8',8,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)','1-ft.-diameter/level sphere, centered around creatures or objects',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 8

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: 1-ft.-diameter/level sphere, centered around creatures or objects

Duration: 1 min./level (D)

Saving Throw: Reflex negates (object)

Spell Resistance: Yes (object)

This spell functions like resilient sphere, with the addition that the creatures or objects inside the globe are nearly weightless. Anything contained within an telekinetic sphere weighs only one-sixteenth of its normal weight. You can telekinetically lift anything in the sphere that normally weighs 5,000 pounds or less. The telekinetic control extends from you out to medium range (100 feet + 10 feet per caster level) after the sphere has succeeded in encapsulating its contents.

You can move objects or creatures in the sphere that weigh a total of 5,000 pounds or less by concentrating on the sphere. You can begin moving a sphere in the round after casting the spell. If you concentrate on doing so (a standard action), you can move the sphere as much as 30 feet in a round. If you cease concentrating, the sphere does not move in that round (if on a level surface) or descends at its falling rate (if aloft) until it reaches a level surface, or the spell’s duration expires, or you begin concentrating again. If you cease concentrating (voluntarily or due to failing a Concentration check), you can resume concentrating on your next turn or any later turn during the spell’s duration.

The sphere falls at a rate of only 60 feet per round, which is not fast enough to cause damage to the contents of the sphere.

You can move the sphere telekinetically even if you are in it.

Material Component: A hemispherical piece of clear crystal, a matching hemispherical piece of gum arabic, and a pair of small bar magnets.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"1-ft.-diameter/level sphere, centered around creatures or objects","Duration":"1 min./level (D)","Saving Throw":"Reflex negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_telepathic_bond','Telepathic Bond','Sor/Wiz 5',5,'Divination','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'10 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: You plus one willing creature per three levels, no two of which can be more than 30 ft. apart

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

You forge a telepathic bond among yourself and a number of willing creatures, each of which must have an Intelligence score of 3 or higher. Each creature included in the link is linked to all the others. The creatures can communicate telepathically through the bond regardless of language. No special power or influence is established as a result of the bond. Once the bond is formed, it works over any distance (although not from one plane to another).

If desired, you may leave yourself out of the telepathic bond forged. This decision must be made at the time of casting.

Telepathic bond can be made permanent with a permanency spell, though it only bonds two creatures per casting of permanency.

Material Component: Pieces of eggshell from two different kinds of creatures.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"You plus one willing creature per three levels, no two of which can be more than 30 ft. apart","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_teleport','Teleport','Sor/Wiz 5, Travel 5',5,'Conjuration (Teleportation)','Personal and touch','You and touched objects or other touched willing creatures',NULL,'Instantaneous','V',ARRAY['sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Sor/Wiz 5, Travel 5

Components: V

Casting Time: 1 standard action

Range: Personal and touch

Target: You and touched objects or other touched willing creatures

Duration: Instantaneous

Saving Throw: None and Will negates (object)

Spell Resistance: No and Yes (object)

This spell instantly transports you to a designated destination, which may be as distant as 100 miles per caster level. Interplanar travel is not possible. You can bring along objects as long as their weight doesn’t exceed your maximum load. You may also bring one additional willing Medium or smaller creature (carrying gear or objects up to its maximum load) or its equivalent (see below) per three caster levels. A Large creature counts as two Medium creatures, a Huge creature counts as two Large creatures, and so forth. All creatures to be transported must be in contact with one another, and at least one of those creatures must be in contact with you. As with all spells where the range is personal and the target is you, you need not make a saving throw, nor is spell resistance applicable to you. Only objects held or in use (attended) by another person receive saving throws and spell resistance.

You must have some clear idea of the location and layout of the destination. The clearer your mental image, the more likely the teleportation works. Areas of strong physical or magical energy may make teleportation more hazardous or even impossible.

To see how well the teleportation works, roll d% and consult the Teleport table. Refer to the following information for definitions of the terms on the table.

Familiarity: “Very familiar” is a place where you have been very often and where you feel at home. “Studied carefully” is a place you know well, either because you can currently see it, you’ve been there often, or you have used other means (such as scrying) to study the place for at least one hour. “Seen casually” is a place that you have seen more than once but with which you are not very familiar. “Viewed once” is a place that you have seen once, possibly using magic.

“False destination” is a place that does not truly exist or if you are teleporting to an otherwise familiar location that no longer exists as such or has been so completely altered as to no longer be familiar to you. When traveling to a false destination, roll 1d20+80 to obtain results on the table, rather than rolling d%, since there is no real destination for you to hope to arrive at or even be off target from.

On Target: You appear where you want to be.

Off Target: You appear safely a random distance away from the destination in a random direction. Distance off target is 1d10x1d10% of the distance that was to be traveled. The direction off target is determined randomly

Similar Area: You wind up in an area that’s visually or thematically similar to the target area.

Generally, you appear in the closest similar place within range. If no such area exists within the spell’s range, the spell simply fails instead.

Mishap: You and anyone else teleporting with you have gotten “scrambled.” You each take 1d10 points of damage, and you reroll on the chart to see where you wind up. For these rerolls, roll 1d20+80. Each time “Mishap” comes up, the characters take more damage and must reroll.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Familiarity</th><th>On Target</th><th>Off Target</th><th>Similar Area</th><th>Mishap</th></tr><tr><td>Very familiar</td><td>01–97</td><td>98–99</td><td>100</td><td>—</td></tr><tr><td>Studied carefully</td><td>01–94</td><td>95–97</td><td>98–99</td><td>100</td></tr><tr><td>Seen casually</td><td>01–88</td><td>89–94</td><td>95–98</td><td>99–100</td></tr><tr><td>Viewed once</td><td>01–76</td><td>77–88</td><td>89–96</td><td>97–100</td></tr><tr><td>False destination (1d20+80)</td><td>—</td><td>—</td><td>81–92</td><td>93–100</td></tr></tbody></table>','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5, Travel 5","Components":"V","Casting Time":"1 standard action","Range":"Personal and touch","Target":"You and touched objects or other touched willing creatures","Duration":"Instantaneous","Saving Throw":"None and Will negates (object)","Spell Resistance":"No and Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_teleport_object','Teleport Object','Sor/Wiz 7',7,'Conjuration (Teleportation)','Touch','One touched object of up to 50 lb./level and 3 cu. ft./level',NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Sor/Wiz 7

Range: Touch

Target: One touched object of up to 50 lb./level and 3 cu. ft./level

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This spell functions like teleport, except that it teleports an object, not you. Creatures and magical forces cannot be teleported.

If desired, the target object can be sent to a distant location on the Ethereal Plane. In this case, the point from which the object was teleported remains faintly magical until the item is retrieved. A successful targeted dispel magic spell cast on that point brings the vanished item back from the Ethereal Plane.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Range":"Touch","Target":"One touched object of up to 50 lb./level and 3 cu. ft./level","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_teleport_greater','Teleport, Greater','Sor/Wiz 7, Travel 7',7,'Conjuration (Teleportation)',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Sor/Wiz 7, Travel 7

This spell functions like teleport, except that there is no range limit and there is no chance you arrive off target. In addition, you need not have seen the destination, but in that case you must have at least a reliable description of the place to which you are teleporting. If you attempt to teleport with insufficient information (or with misleading information), you disappear and simply reappear in your original location. Interplanar travel is not possible.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7, Travel 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_teleportation_circle','Teleportation Circle','Sor/Wiz 9',9,'Conjuration (Teleportation)','0 ft.','5-ft.-radius circle that teleports those who activate it',NULL,'10 min./level (D)','V, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Sor/Wiz 9

Components: V, M

Casting Time: 10 minutes

Range: 0 ft.

Effect: 5-ft.-radius circle that teleports those who activate it

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: Yes

You create a circle on the floor or other horizontal surface that teleports, as greater teleport, any creature who stands on it to a designated spot. Once you designate the destination for the circle, you can’t change it. The spell fails if you attempt to set the circle to teleport creatures into a solid object, to a place with which you are not familiar and have no clear description, or to another plane.

The circle itself is subtle and nearly impossible to notice. If you intend to keep creatures from activating it accidentally, you need to mark the circle in some way.

Teleportation circle can be made permanent with a permanency spell. A permanent teleportation circle that is disabled becomes inactive for 10 minutes, then can be triggered again as normal.

Note: Magic traps such as teleportation circle are hard to detect and disable. A rogue (only) can use the Search skill to find the circle and Disable Device to thwart it. The DC in each case is 25 + spell level, or 34 in the case of teleportation circle.

Material Component: Amber dust to cover the area of the circle (cost 1,000 gp).','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Components":"V, M","Casting Time":"10 minutes","Range":"0 ft.","Effect":"5-ft.-radius circle that teleports those who activate it","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_temporal_stasis','Temporal Stasis','Sor/Wiz 8',8,'Transmutation','Touch','Creature touched',NULL,'Permanent','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 8

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Permanent

Saving Throw: Fortitude negates

Spell Resistance: Yes

You must succeed on a melee touch attack. You place the subject into a state of suspended animation. For the creature, time ceases to flow and its condition becomes fixed. The creature does not grow older. Its body functions virtually cease, and no force or effect can harm it. This state persists until the magic is removed (such as by a successful dispel magic spell or a freedom spell).

Material Component: A powder composed of diamond, emerald, ruby, and sapphire dust with a total value of at least 5,000 gp.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Permanent","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_time_stop','Time Stop','Sor/Wiz 9, Trickery 9',9,'Transmutation','Personal','You',NULL,'1d4+1 rounds (apparent time); see text','V',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 9, Trickery 9

Components: V

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1d4+1 rounds (apparent time); see text

This spell seems to make time cease to flow for everyone but you. In fact, you speed up so greatly that all other creatures seem frozen, though they are actually still moving at their normal speeds. You are free to act for 1d4+1 rounds of apparent time. Normal and magical fire, cold, gas, and the like can still harm you. While the time stop is in effect, other creatures are invulnerable to your attacks and spells; you cannot target such creatures with any attack or spell. A spell that affects an area and has a duration longer than the remaining duration of the time stop have their normal effects on other creatures once the time stop ends. Most spellcasters use the additional time to improve their defenses, summon allies, or flee from combat.

You cannot move or harm items held, carried, or worn by a creature stuck in normal time, but you can affect any item that is not in another creature’s possession.

You are undetectable while time stop lasts. You cannot enter an area protected by an antimagic field while under the effect of time stop.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9, Trickery 9","Components":"V","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1d4+1 rounds (apparent time); see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_tiny_hut','Tiny Hut','Brd 3, Sor/Wiz 3',3,'Evocation [Force]','20 ft.','20-ft.-radius sphere centered on your location',NULL,'2 hours/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: 20 ft.

Effect: 20-ft.-radius sphere centered on your location

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

You create an unmoving, opaque sphere of force of any color you desire around yourself. Half the sphere projects above the ground, and the lower hemisphere passes through the ground. As many as nine other Medium creatures can fit into the field with you; they can freely pass into and out of the hut without harming it. However, if you remove yourself from the hut, the spell ends.

The temperature inside the hut is 70° F if the exterior temperature is between 0° and 100° F. An exterior temperature below 0° or above 100° lowers or raises the interior temperature on a 1-degree-for-1 basis. The hut also provides protection against the elements, such as rain, dust, and sandstorms. The hut withstands any wind of less than hurricane force, but a hurricane (75+ mph wind speed) or greater force destroys it.

The interior of the hut is a hemisphere. You can illuminate it dimly upon command or extinguish the light as desired. Although the force field is opaque from the outside, it is transparent from within. Missiles, weapons, and most spell effects can pass through the hut without affecting it, although the occupants cannot be seen from outside the hut (they have total concealment).

Material Component: A small crystal bead that shatters when the spell duration expires or the hut is dispelled.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"20 ft.","Effect":"20-ft.-radius sphere centered on your location","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_tongues','Tongues','Brd 2, Clr 4, Sor/Wiz 3',2,'Divination','Touch','Creature touched',NULL,'10 min./level','V, M/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Divination

Level: Brd 2, Clr 4, Sor/Wiz 3

Components: V, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: No

This spell grants the creature touched the ability to speak and understand the language of any intelligent creature, whether it is a racial tongue or a regional dialect. The subject can speak only one language at a time, although it may be able to understand several languages. Tongues does not enable the subject to speak with creatures who don’t speak. The subject can make itself understood as far as its voice carries. This spell does not predispose any creature addressed toward the subject in any way.

Tongues can be made permanent with a permanency spell.

Arcane Material Component: A small clay model of a ziggurat, which shatters when the verbal component is pronounced.','{"class_levels":{"bard":2,"cleric":4,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 2, Clr 4, Sor/Wiz 3","Components":"V, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_touch_of_fatigue','Touch of Fatigue','Sor/Wiz 0',0,'Necromancy','Touch','Creature touched',NULL,'1 round/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 0

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 round/level

Saving Throw: Fortitude negates

Spell Resistance: Yes

You channel negative energy through your touch, fatiguing the target. You must succeed on a touch attack to strike a target.

The subject is immediately fatigued for the spell’s duration.

This spell has no effect on a creature that is already fatigued. Unlike with normal fatigue, the effect ends as soon as the spell’s duration expires.

Material Component: A drop of sweat.','{"class_levels":{"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Sor/Wiz 0","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 round/level","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_touch_of_idiocy','Touch of Idiocy','Sor/Wiz 2',2,'Enchantment (Compulsion) [Mind-Affecting]','Touch','Living creature touched',NULL,'10 min./level','V, S',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 10 min./level

Saving Throw: No

Spell Resistance: Yes

With a touch, you reduce the target’s mental faculties. Your successful melee touch attack applies a 1d6 penalty to the target’s Intelligence, Wisdom, and Charisma scores. This penalty can’t reduce any of these scores below 1.

This spell’s effect may make it impossible for the target to cast some or all of its spells, if the requisite ability score drops below the minimum required to cast spells of that level.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"10 min./level","Saving Throw":"No","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_transformation','Transformation','Sor/Wiz 6',6,'Transmutation','Personal','You',NULL,'1 round/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level

You become a virtual fighting machine— stronger, tougher, faster, and more skilled in combat. Your mind-set changes so that you relish combat and you can’t cast spells, even from magic items.

You gain a +4 enhancement bonus to Strength, Dexterity, and Constitution, a +4 natural armor bonus to AC, a +5 competence bonus on Fortitude saves, and proficiency with all simple and martial weapons. Your base attack bonus equals your character level (which may give you multiple attacks).

You lose your spellcasting ability, including your ability to use spell activation or spell completion magic items, just as if the spells were no longer on your class list.

Material Component: A potion of bull’s strength, which you drink (and whose effects are subsumed by the spell effects).','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_transmute_metal_to_wood','Transmute Metal to Wood','Drd 7',7,'Transmutation','Long (400 ft. + 40 ft./level)',NULL,'All metal objects within a 40-ft.-radius burst','Instantaneous','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 7

Components: V, S, DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: All metal objects within a 40-ft.-radius burst

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes (object; see text)

This spell enables you to change all metal objects within its area to wood. Weapons, armor, and other metal objects carried by creatures are affected as well. A magic object made of metal effectively has spell resistance equal to 20 + its caster level against this spell. Artifacts cannot be transmuted. Weapons converted from metal to wood take a –2 penalty on attack and damage rolls. The armor bonus of any armor converted from metal to wood is reduced by 2. Weapons changed by this spell splinter and break on any natural attack roll of 1 or 2, and armor changed by this spell loses an additional point of armor bonus every time it is struck with a natural attack roll of 19 or 20.

Only limited wish, miracle, wish, or similar magic can restore a transmuted object to its metallic state.','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"All metal objects within a 40-ft.-radius burst","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes (object; see text)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_transmute_mud_to_rock','Transmute Mud to Rock','Drd 5, Sor/Wiz 5',5,'Transmutation [Earth]','Medium (100 ft. + 10 ft./level)',NULL,'Up to two 10-ft. cubes/level (S)','Permanent','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation \[Earth\]

Level: Drd 5, Sor/Wiz 5

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Up to two 10-ft. cubes/level (S)

Duration: Permanent

Saving Throw: See text

Spell Resistance: No

This spell transforms normal mud or quicksand of any depth into soft stone (sandstone or a similar mineral) permanently.

Any creature in the mud is allowed a Reflex save to escape before the area is hardened to stone.

Transmute mud to rock counters and dispels transmute rock to mud.

Arcane Material Component: Sand, lime, and water.','{"class_levels":{"druid":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Drd 5, Sor/Wiz 5","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Up to two 10-ft. cubes/level (S)","Duration":"Permanent","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_transmute_rock_to_mud','Transmute Rock to Mud','Drd 5, Sor/Wiz 5',5,'Transmutation [Earth]','Medium (100 ft. + 10 ft./level)',NULL,'Up to two 10-ft. cubes/level (S)','Permanent; see text','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation \[Earth\]

Level: Drd 5, Sor/Wiz 5

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Up to two 10-ft. cubes/level (S)

Duration: Permanent; see text

Saving Throw: See text

Spell Resistance: No

This spell turns natural, uncut or unworked rock of any sort into an equal volume of mud. Magical stone is not affected by the spell. The depth of the mud created cannot exceed 10 feet. A creature unable to levitate, fly, or otherwise free itself from the mud sinks until hip- or chest-deep, reducing its speed to 5 feet and causing a –2 penalty on attack rolls and AC. Brush thrown atop the mud can support creatures able to climb on top of it. Creatures large enough to walk on the bottom can wade through the area at a speed of 5 feet.

If transmute rock to mud is cast upon the ceiling of a cavern or tunnel, the mud falls to the floor and spreads out in a pool at a depth of 5 feet. The falling mud and the ensuing cave-in deal 8d6 points of bludgeoning damage to anyone caught directly beneath the area, or half damage to those who succeed on Reflex saves.

Castles and large stone buildings are generally immune to the effect of the spell, since transmute rock to mud can’t affect worked stone and doesn’t reach deep enough to undermine such buildings’ foundations. However, small buildings or structures often rest upon foundations shallow enough to be damaged or even partially toppled by this spell.

The mud remains until a successful dispel magic or transmute mud to rock spell restores its substance—but not necessarily its form. Evaporation turns the mud to normal dirt over a period of days. The exact time depends on exposure to the sun, wind, and normal drainage.

Arcane Material Component: Clay and water.','{"class_levels":{"druid":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Drd 5, Sor/Wiz 5","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Up to two 10-ft. cubes/level (S)","Duration":"Permanent; see text","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_transport_via_plants','Transport via Plants','Drd 6',6,'Conjuration (Teleportation)','Unlimited','You and touched objects or other touched willing creatures',NULL,'1 round','V, S',ARRAY['druid']::text[],'Conjuration (Teleportation)

Level: Drd 6

Components: V, S

Casting Time: 1 standard action

Range: Unlimited

Target: You and touched objects or other touched willing creatures

Duration: 1 round

Saving Throw: None

Spell Resistance: No

You can enter any normal plant (Medium or larger) and pass any distance to a plant of the same kind in a single round, regardless of the distance separating the two. The entry plant must be alive. The destination plant need not be familiar to you, but it also must be alive. If you are uncertain of the location of a particular kind of destination plant, you need merely designate direction and distance and the transport via plants spell moves you as close as possible to the desired location. If a particular destination plant is desired but the plant is not living, the spell fails and you are ejected from the entry plant.

You can bring along objects as long as their weight doesn’t exceed your maximum load. You may also bring one additional willing Medium or smaller creature (carrying gear or objects up to its maximum load) or its equivalent per three caster levels. Use the following equivalents to determine the maximum number of larger creatures you can bring along: A Large creature counts as two Medium creatures, a Huge creature counts as two Large creatures, and so forth. All creatures to be transported must be in contact with one another, and at least one of those creatures must be in contact with you.

You can’t use this spell to travel through plant creatures.

The destruction of an occupied plant slays you and any creatures you have brought along, and ejects the bodies and all carried objects from the tree.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Components":"V, S","Casting Time":"1 standard action","Range":"Unlimited","Target":"You and touched objects or other touched willing creatures","Duration":"1 round","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_trap_the_soul','Trap the Soul','Sor/Wiz 8',8,'Conjuration (Summoning)','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'Permanent; see text','V, S, M, (F); see text',ARRAY['sorcerer','wizard']::text[],'Conjuration (Summoning)

Level: Sor/Wiz 8

Components: V, S, M, (F); see text

Casting Time: 1 standard action or see text

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: Permanent; see text

Saving Throw: See text

Spell Resistance: Yes; see text

Trap the soul forces a creature’s life force (and its material body) into a gem. The gem holds the trapped entity indefinitely or until the gem is broken and the life force is released, which allows the material body to reform. If the trapped creature is a powerful creature from another plane it can be required to perform a service immediately upon being freed. Otherwise, the creature can go free once the gem imprisoning it is broken.

Depending on the version selected, the spell can be triggered in one of two ways.

Spell Completion: First, the spell can be completed by speaking its final word as a standard action as if you were casting a regular spell at the subject. This allows spell resistance (if any) and a Will save to avoid the effect. If the creature’s name is spoken as well, any spell resistance is ignored and the save DC increases by 2. If the save or spell resistance is successful, the gem shatters.

Trigger Object: The second method is far more insidious, for it tricks the subject into accepting a trigger object inscribed with the final spell word, automatically placing the creature’s soul in the trap. To use this method, both the creature’s name and the trigger word must be inscribed on the trigger object when the gem is enspelled. A sympathy spell can also be placed on the trigger object. As soon as the subject picks up or accepts the trigger object, its life force is automatically transferred to the gem without the benefit of spell resistance or a save.

Material Component: Before the actual casting of trap the soul, you must procure a gem of at least 1,000 gp value for every Hit Die possessed by the creature to be trapped. If the gem is not valuable enough, it shatters when the entrapment is attempted. (While creatures have no concept of level or Hit Dice as such, the value of the gem needed to trap an individual can be researched. Remember that this value can change over time as creatures gain more Hit Dice.)

Focus (Trigger Object Only): If the trigger object method is used, a special trigger object, prepared as described above, is needed.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M, (F); see text","Casting Time":"1 standard action or see text","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"Permanent; see text","Saving Throw":"See text","Spell Resistance":"Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_tree_shape','Tree Shape','Drd 2, Rgr 3',2,'Transmutation','Personal','You',NULL,'1 hour/level (D)','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 2, Rgr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 hour/level (D)

By means of this spell, you are able to assume the form of a Large living tree or shrub or a Large dead tree trunk with a small number of limbs. The closest inspection cannot reveal that the tree in question is actually a magically concealed creature. To all normal tests you are, in fact, a tree or shrub, although a detect magic spell reveals a faint transmutation on the tree. While in tree form, you can observe all that transpires around you just as if you were in your normal form, and your hit points and save bonuses remain unaffected. You gain a +10 natural armor bonus to AC but have an effective Dexterity score of 0 and a speed of 0 feet. You are immune to critical hits while in tree form. All clothing and gear carried or worn changes with you.

You can dismiss tree shape as a free action (instead of as a standard action).','{"class_levels":{"druid":2,"ranger":3},"source_field_values":{"Level":"Drd 2, Rgr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 hour/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_tree_stride','Tree Stride','Drd 5, Rgr 4',4,'Conjuration (Teleportation)','Personal','You',NULL,'1 hour/level or until expended; see text','V, S, DF',ARRAY['druid','ranger']::text[],'Conjuration (Teleportation)

Level: Drd 5, Rgr 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 hour/level or until expended; see text

You gain the ability to enter trees and move from inside one tree to inside another tree. The first tree you enter and all others you enter must be of the same kind, must be living, and must have girth at least equal to yours. By moving into an oak tree (for example), you instantly know the location of all other oak trees within transport range (see below) and may choose whether you want to pass into one or simply step back out of the tree you moved into. You may choose to pass to any tree of the appropriate kind within the transport range as shown on the following table.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Type of Tree</th><th>Transport Range</th></tr><tr><td>Oak, ash, yew</td><td>3,000 feet</td></tr><tr><td>Elm, linden</td><td>2,000 feet</td></tr><tr><td>Other deciduous</td><td>1,500 feet</td></tr><tr><td>Any coniferous</td><td>1,000 feet</td></tr><tr><td>All other trees</td><td>500 feet</td></tr></tbody></table>

You may move into a tree up to one time per caster level (passing from one tree to another counts only as moving into one tree). The spell lasts until the duration expires or you exit a tree. Each transport is a full-round action.

You can, at your option, remain within a tree without transporting yourself, but you are forced out when the spell ends. If the tree in which you are concealed is chopped down or burned, you are slain if you do not exit before the process is complete.','{"class_levels":{"druid":5,"ranger":4},"source_field_values":{"Level":"Drd 5, Rgr 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 hour/level or until expended; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_true_resurrection','True Resurrection','Clr 9',9,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Conjuration (Healing)

Level: Clr 9

Casting Time: 10 minutes

This spell functions like raise dead, except that you can resurrect a creature that has been dead for as long as 10 years per caster level. This spell can even bring back creatures whose bodies have been destroyed, provided that you unambiguously identify the deceased in some fashion (reciting the deceased’s time and place of birth or death is the most common method).

Upon completion of the spell, the creature is immediately restored to full hit points, vigor, and health, with no loss of level (or Constitution points) or prepared spells.

You can revive someone killed by a death effect or someone who has been turned into an undead creature and then destroyed. This spell can also resurrect elementals or outsiders, but it can’t resurrect constructs or undead creatures.

Even true resurrection can’t restore to life a creature who has died of old age.

Material Component: A sprinkle of holy water and diamonds worth a total of at least 25,000 gp.','{"class_levels":{"cleric":9},"source_field_values":{"Level":"Clr 9","Casting Time":"10 minutes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_true_seeing','True Seeing','Clr 5, Drd 7, Knowledge 5, Sor/Wiz 6',5,'Divination','Touch','Creature touched',NULL,'1 min./level','V, S, M',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Divination

Level: Clr 5, Drd 7, Knowledge 5, Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

You confer on the subject the ability to see all things as they actually are. The subject sees through normal and magical darkness, notices secret doors hidden by magic, sees the exact locations of creatures or objects under blur or displacement effects, sees invisible creatures or objects normally, sees through illusions, and sees the true form of polymorphed, changed, or transmuted things. Further, the subject can focus its vision to see into the Ethereal Plane (but not into extradimensional spaces). The range of true seeing conferred is 120 feet.

True seeing, however, does not penetrate solid objects. It in no way confers X-ray vision or its equivalent. It does not negate concealment, including that caused by fog and the like. True seeing does not help the viewer see through mundane disguises, spot creatures who are simply hiding, or notice secret doors hidden by mundane means. In addition, the spell effects cannot be further enhanced with known magic, so one cannot use true seeing through a crystal ball or in conjunction with clairaudience/clairvoyance.

Material Component: An ointment for the eyes that costs 250 gp and is made from mushroom powder, saffron, and fat.','{"class_levels":{"cleric":5,"druid":7,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 5, Drd 7, Knowledge 5, Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_true_strike','True Strike','Sor/Wiz 1',1,'Divination','Personal','You',NULL,'See text','V, F',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 1

Components: V, F

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: See text

You gain temporary, intuitive insight into the immediate future during your next attack. Your next single attack roll (if it is made before the end of the next round) gains a +20 insight bonus. Additionally, you are not affected by the miss chance that applies to attackers trying to strike a concealed target.

Focus: A small wooden replica of an archery target.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, F","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_undeath_to_death','Undeath to Death','Clr 6, Sor/Wiz 6',6,'Necromancy',NULL,NULL,'Several undead creatures within a 40-ft.-radius burst',NULL,'V, S, M/DF',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 6, Sor/Wiz 6

Components: V, S, M/DF

Area: Several undead creatures within a 40-ft.-radius burst

Saving Throw: Will negates

This spell functions like circle of death, except that it destroys undead creatures as noted above.

Material Component: The powder of a crushed diamond worth at least 500 gp.','{"class_levels":{"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Sor/Wiz 6","Components":"V, S, M/DF","Area":"Several undead creatures within a 40-ft.-radius burst","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_undetectable_alignment','Undetectable Alignment','Brd 1, Clr 2, Pal 2',1,'Abjuration','Close (25 ft. + 5 ft./2 levels)','One creature or object',NULL,'24 hours','V, S',ARRAY['bard','cleric','paladin']::text[],'Abjuration

Level: Brd 1, Clr 2, Pal 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature or object

Duration: 24 hours

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

An undetectable alignment spell conceals the alignment of an object or a creature from all forms of divination.','{"class_levels":{"bard":1,"cleric":2,"paladin":2},"source_field_values":{"Level":"Brd 1, Clr 2, Pal 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature or object","Duration":"24 hours","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_unhallow','Unhallow','Clr 5, Drd 5',5,'Evocation [Evil]','Touch',NULL,'40-ft. radius emanating from the touched point','Instantaneous','V, S, M',ARRAY['cleric','druid']::text[],'Evocation \[Evil\]

Level: Clr 5, Drd 5

Components: V, S, M

Casting Time: 24 hours

Range: Touch

Area: 40-ft. radius emanating from the touched point

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: See text

Unhallow makes a particular site, building, or structure an unholy site. This has three major effects.

First, the site or structure is guarded by a magic circle against good effect.

Second, all turning checks made to turn undead take a –4 penalty, and turning checks to rebuke undead gain a +4 profane bonus. Spell resistance does not apply to this effect. (This provision does not apply to the druid version of the spell.)

Finally, you may choose to fix a single spell effect to the unhallowed site. The spell effect lasts for one year and functions throughout the entire site, regardless of its normal duration and area or effect. You may designate whether the effect applies to all creatures, creatures that share your faith or alignment, or creatures that adhere to another faith or alignment. At the end of the year, the chosen effect lapses, but it can be renewed or replaced simply by casting unhallow again.

Spell effects that may be tied to an unhallowed site include aid, bane, bless, cause fear, darkness, daylight, death ward, deeper darkness, detect magic, detect good, dimensional anchor, discern lies, dispel magic, endure elements, freedom of movement, invisibility purge, protection from energy, remove fear, resist energy, silence, tongues, and zone of truth.

Saving throws and spell resistance might apply to these spells’ effects. (See the individual spell descriptions for details.)

An area can receive only one unhallow spell (and its associated spell effect) at a time.

Unhallow counters but does not dispel hallow.

Material Component: Herbs, oils, and incense worth at least 1,000 gp, plus 1,000 gp per level of the spell to be tied to the unhallowed area.','{"class_levels":{"cleric":5,"druid":5},"source_field_values":{"Level":"Clr 5, Drd 5","Components":"V, S, M","Casting Time":"24 hours","Range":"Touch","Area":"40-ft. radius emanating from the touched point","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_unholy_aura','Unholy Aura','Clr 8, Evil 8',8,'Abjuration [Evil]','20 ft.',NULL,NULL,'1 round/level (D)','V, S, F',ARRAY['cleric']::text[],'Abjuration \[Evil\]

Level: Clr 8, Evil 8

Components: V, S, F

Casting Time: 1 standard action

Range: 20 ft.

Targets: One creature/level in a 20-ft.-radius burst centered on you

Duration: 1 round/level (D)

Saving Throw: See text

Spell Resistance: Yes (harmless)

A malevolent darkness surrounds the subjects, protecting them from attacks, granting them resistance to spells cast by good creatures, and weakening good creatures when they strike the subjects. This abjuration has four effects.

First, each warded creature gains a +4 deflection bonus to AC and a +4 resistance bonus on saves. Unlike the effect of protection from good, this benefit applies against all attacks, not just against attacks by good creatures.

Second, a warded creature gains spell resistance 25 against good spells and spells cast by good creatures.

Third, the abjuration blocks possession and mental influence, just as protection from good does.

Finally, if a good creature succeeds on a melee attack against a warded creature, the offending attacker takes 1d6 points of temporary Strength damage (Fortitude negates).

Focus: A tiny reliquary containing some sacred relic, such as a piece of parchment from an unholy text. The reliquary costs at least 500 gp.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8, Evil 8","Components":"V, S, F","Casting Time":"1 standard action","Range":"20 ft.","Targets":"One creature/level in a 20-ft.-radius burst centered on you","Duration":"1 round/level (D)","Saving Throw":"See text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_unseen_servant','Unseen Servant','Brd 1, Sor/Wiz 1',1,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)','One invisible, mindless, shapeless servant',NULL,'1 hour/level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Brd 1, Sor/Wiz 1

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One invisible, mindless, shapeless servant

Duration: 1 hour/level

Saving Throw: None

Spell Resistance: No

An unseen servant is an invisible, mindless, shapeless force that performs simple tasks at your command. It can run and fetch things, open unstuck doors, and hold chairs, as well as clean and mend. The servant can perform only one activity at a time, but it repeats the same activity over and over again if told to do so as long as you remain within range. It can open only normal doors, drawers, lids, and the like. It has an effective Strength score of 2 (so it can lift 20 pounds or drag 100 pounds). It can trigger traps and such, but it can exert only 20 pounds of force, which is not enough to activate certain pressure plates and other devices. It can’t perform any task that requires a skill check with a DC higher than 10 or that requires a check using a skill that can’t be used untrained. Its speed is 15 feet.

The servant cannot attack in any way; it is never allowed an attack roll. It cannot be killed, but it dissipates if it takes 6 points of damage from area attacks. (It gets no saves against attacks.) If you attempt to send it beyond the spell’s range (measured from your current position), the servant ceases to exist.

Material Component: A piece of string and a bit of wood.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One invisible, mindless, shapeless servant","Duration":"1 hour/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_vampiric_touch','Vampiric Touch','Sor/Wiz 3',3,'Necromancy','Touch','Living creature touched',NULL,'Instantaneous/1 hour; see text','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: Instantaneous/1 hour; see text

Saving Throw: None

Spell Resistance: Yes

You must succeed on a melee touch attack. Your touch deals 1d6 points of damage per two caster levels (maximum 10d6). You gain temporary hit points equal to the damage you deal. However, you can’t gain more than the subject’s current hit points +10, which is enough to kill the subject. The temporary hit points disappear 1 hour later.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous/1 hour; see text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_veil','Veil','Brd 6, Sor/Wiz 6',6,'Illusion (Glamer)','Long (400 ft. + 40 ft./level)',NULL,NULL,'Concentration + 1 hour/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 6, Sor/Wiz 6

Components: V, S

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Targets: One or more creatures, no two of which can be more than 30 ft. apart

Duration: Concentration + 1 hour/level (D)

Saving Throw: Will negates; see text

Spell Resistance: Yes; see text

You instantly change the appearance of the subjects and then maintain that appearance for the spell’s duration. You can make the subjects appear to be anything you wish. The subjects look, feel, and smell just like the creatures the spell makes them resemble. Affected creatures resume their normal appearances if slain. You must succeed on a Disguise check to duplicate the appearance of a specific individual. This spell gives you a +10 bonus on the check.

Unwilling targets can negate the spell’s effect on them by making Will saves or with spell resistance. Those who interact with the subjects can attempt Will disbelief saves to see through the glamer, but spell resistance doesn’t help.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Components":"V, S","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Targets":"One or more creatures, no two of which can be more than 30 ft. apart","Duration":"Concentration + 1 hour/level (D)","Saving Throw":"Will negates; see text","Spell Resistance":"Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_ventriloquism','Ventriloquism','Brd 1, Sor/Wiz 1',1,'Illusion (Figment)','Close (25 ft. + 5 ft./2 levels)','Intelligible sound, usually speech',NULL,'1 min./level (D)','V, F',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 1, Sor/Wiz 1

Components: V, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Intelligible sound, usually speech

Duration: 1 min./level (D)

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

You can make your voice (or any sound that you can normally make vocally) seem to issue from someplace else. You can speak in any language you know. With respect to such voices and sounds, anyone who hears the sound and rolls a successful save recognizes it as illusory (but still hears it).

Focus: A parchment rolled up into a small cone.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Intelligible sound, usually speech","Duration":"1 min./level (D)","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_virtue','Virtue','Clr 0, Drd 0, Pal 1',0,'Transmutation','Touch','Creature touched',NULL,'1 min.','V, S, DF',ARRAY['cleric','druid','paladin']::text[],'Transmutation

Level: Clr 0, Drd 0, Pal 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min.

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

The subject gains 1 temporary hit point.','{"class_levels":{"cleric":0,"druid":0,"paladin":1},"source_field_values":{"Level":"Clr 0, Drd 0, Pal 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min.","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_vision','Vision','Sor/Wiz 7',7,'Divination',NULL,NULL,NULL,NULL,'V, S, M, XP',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 7

Components: V, S, M, XP

Casting Time: 1 standard action

This spell functions like legend lore, except that it works more quickly but produces some strain on you. You pose a question about some person, place, or object, then cast the spell. If the person or object is at hand or if you are in the place in question, you receive a vision about it by succeeding on a caster level check (1d20 +1 per caster level; maximum +25) against DC 20. If only detailed information on the person, place, or object is known, the DC is 25, and the information gained is incomplete. If only rumors are known, the DC is 30, and the information gained is vague.

XP Cost: 100 XP.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M, XP","Casting Time":"1 standard action"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wail_of_the_banshee','Wail of the Banshee','Death 9, Sor/Wiz 9',9,'Necromancy [Death, Sonic]','Close (25 ft. + 5 ft./2 levels)',NULL,'One living creature/level within a 40-ft.-radius spread','Instantaneous','V',ARRAY['sorcerer','wizard']::text[],'Necromancy \[Death, Sonic\]

Level: Death 9, Sor/Wiz 9

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: One living creature/level within a 40-ft.-radius spread

Duration: Instantaneous

Saving Throw: Fortitude negates

Spell Resistance: Yes

You emit a terrible scream that kills creatures that hear it (except for yourself ). Creatures closest to the point of origin are affected first.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Death 9, Sor/Wiz 9","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"One living creature/level within a 40-ft.-radius spread","Duration":"Instantaneous","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_fire','Wall of Fire','Drd 5, Fire 4, Sor/Wiz 4',4,'Evocation [Fire]','Medium (100 ft. + 10 ft./level)','Opaque sheet of flame up to 20 ft. long/level or a ring of fire with a radius of up to 5 ft. per two levels; either form 20 ft. high',NULL,'Concentration + 1 round/level','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Drd 5, Fire 4, Sor/Wiz 4

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Opaque sheet of flame up to 20 ft. long/level or a ring of fire with a radius of up to 5 ft. per two levels; either form 20 ft. high

Duration: Concentration + 1 round/level

Saving Throw: None

Spell Resistance: Yes

An immobile, blazing curtain of shimmering violet fire springs into existence. One side of the wall, selected by you, sends forth waves of heat, dealing 2d4 points of fire damage to creatures within 10 feet and 1d4 points of fire damage to those past 10 feet but within 20 feet. The wall deals this damage when it appears and on your turn each round to all creatures in the area. In addition, the wall deals 2d6 points of fire damage +1 point of fire damage per caster level (maximum +20) to any creature passing through it. The wall deals double damage to undead creatures.

If you evoke the wall so that it appears where creatures are, each creature takes damage as if passing through the wall. If any 5-foot length of wall takes 20 points of cold damage or more in 1 round, that length goes out. (Do not divide cold damage by 4, as normal for objects.)

Wall of fire can be made permanent with a permanency spell. A permanent wall of fire that is extinguished by cold damage becomes inactive for 10 minutes, then reforms at normal strength.

Arcane Material Component: A small piece of phosphorus.','{"class_levels":{"druid":5,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Drd 5, Fire 4, Sor/Wiz 4","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Opaque sheet of flame up to 20 ft. long/level or a ring of fire with a radius of up to 5 ft. per two levels; either form 20 ft. high","Duration":"Concentration + 1 round/level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_force','Wall of Force','Sor/Wiz 5',5,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)','Wall whose area is up to one 10-ft. square/level',NULL,'1 round /level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Wall whose area is up to one 10-ft. square/level

Duration: 1 round /level (D)

Saving Throw: None

Spell Resistance: No

A wall of force spell creates an invisible wall of force. The wall cannot move, it is immune to damage of all kinds, and it is unaffected by most spells, including dispel magic. However, disintegrate immediately destroys it, as does a rod of cancellation, a sphere of annihilation, or a mage’s disjunction spell. Breath weapons and spells cannot pass through the wall in either direction, although dimension door, teleport, and similar effects can bypass the barrier. It blocks ethereal creatures as well as material ones (though ethereal creatures can usually get around the wall by floating under or over it through material floors and ceilings). Gaze attacks can operate through a wall of force.

The caster can form the wall into a flat, vertical plane whose area is up to one 10- foot square per level. The wall must be continuous and unbroken when formed. If its surface is broken by any object or creature, the spell fails.

Wall of force can be made permanent with a permanency spell.

Material Component: A pinch of powder made from a clear gem.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Wall whose area is up to one 10-ft. square/level","Duration":"1 round /level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_ice','Wall of Ice','Sor/Wiz 4',4,'Evocation [Cold]','Medium (100 ft. + 10 ft./level)','Anchored plane of ice, up to one 10-ft. square/level, or hemisphere of ice with a radius of up to 3 ft. + 1 ft./level',NULL,'1 min./level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Anchored plane of ice, up to one 10-ft. square/level, or hemisphere of ice with a radius of up to 3 ft. + 1 ft./level

Duration: 1 min./level

Saving Throw: Reflex negates; see text

Spell Resistance: Yes

This spell creates an anchored plane of ice or a hemisphere of ice, depending on the version selected. A wall of ice cannot form in an area occupied by physical objects or creatures. Its surface must be smooth and unbroken when created. Any creature adjacent to the wall when it is created may attempt a Reflex save to disrupt the wall as it is being formed. A successful save indicates that the spell automatically fails. Fire can melt a wall of ice, and it deals full damage to the wall (instead of the normal half damage taken by objects). Suddenly melting a wall of ice creates a great cloud of steamy fog that lasts for 10 minutes.

Ice Plane: A sheet of strong, hard ice appears. The wall is 1 inch thick per caster level. It covers up to a 10-foot-square area per caster level (so a 10th-level wizard can create a wall of ice 100 feet long and 10 feet high, a wall 50 feet long and 20 feet high, or some other combination of length and height that does not exceed 1,000 square feet). The plane can be oriented in any fashion as long as it is anchored. A vertical wall need only be anchored on the floor, while a horizontal or slanting wall must be anchored on two opposite sides.

Each 10-foot square of wall has 3 hit points per inch of thickness. Creatures can hit the wall automatically. A section of wall whose hit points drop to 0 is breached. If a creature tries to break through the wall with a single attack, the DC for the Strength check is 15 + caster level.

Even when the ice has been broken through, a sheet of frigid air remains. Any creature stepping through it (including the one who broke through the wall) takes 1d6 points of cold damage +1 point per caster level (no save).

Hemisphere: The wall takes the form of a hemisphere whose maximum radius is 3 feet + 1 foot per caster level. The hemisphere is as hard to break through as the ice plane form, but it does not deal damage to those who go through a breach.

Material Component: A small piece of quartz or similar rock crystal.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Anchored plane of ice, up to one 10-ft. square/level, or hemisphere of ice with a radius of up to 3 ft. + 1 ft./level","Duration":"1 min./level","Saving Throw":"Reflex negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_iron','Wall of Iron','Sor/Wiz 6',6,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Iron wall whose area is up to one 5-ft. square/level; see text',NULL,'Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Iron wall whose area is up to one 5-ft. square/level; see text

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: No

You cause a flat, vertical iron wall to spring into being. The wall inserts itself into any surrounding nonliving material if its area is sufficient to do so. The wall cannot be conjured so that it occupies the same space as a creature or another object. It must always be a flat plane, though you can shape its edges to fit the available space.

A wall of iron is 1 inch thick per four caster levels. You can double the wall’s area by halving its thickness. Each 5- foot square of the wall has 30 hit points per inch of thickness and hardness 10. A section of wall whose hit points drop to 0 is breached. If a creature tries to break through the wall with a single attack, the DC for the Strength check is 25 + 2 per inch of thickness.

If you desire, the wall can be created vertically resting on a flat surface but not attached to the surface, so that it can be tipped over to fall on and crush creatures beneath it. The wall is 50% likely to tip in either direction if left unpushed. Creatures can push the wall in one direction rather than letting it fall randomly. A creature must make a DC 40 Strength check to push the wall over. Creatures with room to flee the falling wall may do so by making successful Reflex saves. Any Large or smaller creature that fails takes 10d6 points of damage. The wall cannot crush Huge and larger creatures.

Like any iron wall, this wall is subject to rust, perforation, and other natural phenomena.

Material Component: A small piece of sheet iron plus gold dust worth 50 gp (1 pound of gold dust).','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Iron wall whose area is up to one 5-ft. square/level; see text","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_stone','Wall of Stone','Clr 5, Drd 6, Earth 5, Sor/Wiz 5',5,'Conjuration (Creation) [Earth]','Medium (100 ft. + 10 ft./level)','Stone wall whose area is up to one 5-ft. square/level (S)',NULL,'Instantaneous','V, S, M/DF',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Conjuration (Creation) \[Earth\]

Level: Clr 5, Drd 6, Earth 5, Sor/Wiz 5

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Stone wall whose area is up to one 5-ft. square/level (S)

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: No

This spell creates a wall of rock that merges into adjoining rock surfaces. A wall of stone is 1 inch thick per four caster levels and composed of up to one 5-foot square per level. You can double the wall’s area by halving its thickness. The wall cannot be conjured so that it occupies the same space as a creature or another object.

Unlike a wall of iron, you can create a wall of stone in almost any shape you desire. The wall created need not be vertical, nor rest upon any firm foundation; however, it must merge with and be solidly supported by existing stone. It can be used to bridge a chasm, for instance, or as a ramp. For this use, if the span is more than 20 feet, the wall must be arched and buttressed. This requirement reduces the spell’s area by half. The wall can be crudely shaped to allow crenellations, battlements, and so forth by likewise reducing the area.

Like any other stone wall, this one can be destroyed by a disintegrate spell or by normal means such as breaking and chipping. Each 5-foot square of the wall has 15 hit points per inch of thickness and hardness 8. A section of wall whose hit points drop to 0 is breached. If a creature tries to break through the wall with a single attack, the DC for the Strength check is 20 + 2 per inch of thickness.

It is possible, but difficult, to trap mobile opponents within or under a wall of stone, provided the wall is shaped so it can hold the creatures. Creatures can avoid entrapment with successful Reflex saves.

Arcane Material Component: A small block of granite.','{"class_levels":{"cleric":5,"druid":6,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Clr 5, Drd 6, Earth 5, Sor/Wiz 5","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Stone wall whose area is up to one 5-ft. square/level (S)","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wall_of_thorns','Wall of Thorns','Drd 5, Plant 5',5,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Wall of thorny brush, up to one 10-ft. cube/level (S)',NULL,'10 min./level (D)','V, S',ARRAY['druid']::text[],'Conjuration (Creation)

Level: Drd 5, Plant 5

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Wall of thorny brush, up to one 10-ft. cube/level (S)

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

A wall of thorns spell creates a barrier of very tough, pliable, tangled brush bearing needle-sharp thorns as long as a human’s finger. Any creature forced into or attempting to move through a wall of thorns takes slashing damage per round of movement equal to 25 minus the creature’s AC. Dexterity and dodge bonuses to AC do not count for this calculation. (Creatures with an Armor Class of 25 or higher, without considering Dexterity and dodge bonuses, take no damage from contact with the wall.)

You can make the wall as thin as 5 feet thick, which allows you to shape the wall as a number of 10-by-10-by-5-foot blocks equal to twice your caster level. This has no effect on the damage dealt by the thorns, but any creature attempting to break through takes that much less time to force its way through the barrier.

Creatures can force their way slowly through the wall by making a Strength check as a full-round action. For every 5 points by which the check exceeds 20, a creature moves 5 feet (up to a maximum distance equal to its normal land speed). Of course, moving or attempting to move through the thorns incurs damage as described above. A creature trapped in the thorns can choose to remain motionless in order to avoid taking any more damage.

Any creature within the area of the spell when it is cast takes damage as if it had moved into the wall and is caught inside. In order to escape, it must attempt to push its way free, or it can wait until the spell ends. Creatures with the ability to pass through overgrown areas unhindered can pass through a wall of thorns at normal speed without taking damage.

A wall of thorns can be breached by slow work with edged weapons. Chopping away at the wall creates a safe passage 1 foot deep for every 10 minutes of work. Normal fire cannot harm the barrier, but magical fire burns it away in 10 minutes.

Despite its appearance, a wall of thorns is not actually a living plant, and thus is unaffected by spells that affect plants.','{"class_levels":{"druid":5},"source_field_values":{"Level":"Drd 5, Plant 5","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Wall of thorny brush, up to one 10-ft. cube/level (S)","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_warp_wood','Warp Wood','Drd 2',2,'Transmutation','Close (25 ft. + 5 ft./2 levels)','1 Small wooden object/level, all within a 20-ft. radius',NULL,'Instantaneous','V, S',ARRAY['druid']::text[],'Transmutation

Level: Drd 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: 1 Small wooden object/level, all within a 20-ft. radius

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You cause wood to bend and warp, permanently destroying its straightness, form, and strength. A warped door springs open (or becomes stuck, requiring a Strength check to open, at your option). A boat or ship springs a leak. Warped ranged weapons are useless. A warped melee weapon causes a –4 penalty on attack rolls.

You may warp one Small or smaller object or its equivalent per caster level. A Medium object counts as two Small objects, a Large object as four, a Huge object as eight, a Gargantuan object as sixteen, and a Colossal object as thirty-two.

Alternatively, you can unwarp wood (effectively warping it back to normal) with this spell, straightening wood that has been warped by this spell or by other means. Make whole, on the other hand, does no good in repairing a warped item.

You can combine multiple consecutive warp wood spells to warp (or unwarp) an object that is too large for you to warp with a single spell.

Until the object is completely warped, it suffers no ill effects.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"1 Small wooden object/level, all within a 20-ft. radius","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_water_breathing','Water Breathing','Clr 3, Drd 3, Sor/Wiz 3, Water 3',3,'Transmutation','Touch','Living creatures touched',NULL,'2 hours/level; see text','V, S, M/DF',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Clr 3, Drd 3, Sor/Wiz 3, Water 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Living creatures touched

Duration: 2 hours/level; see text

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The transmuted creatures can breathe water freely. Divide the duration evenly among all the creatures you touch.

The spell does not make creatures unable to breathe air.

Arcane Material Component: A short reed or piece of straw.','{"class_levels":{"cleric":3,"druid":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 3, Drd 3, Sor/Wiz 3, Water 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creatures touched","Duration":"2 hours/level; see text","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_water_walk','Water Walk','Clr 3, Rgr 3',3,'Transmutation [Water]','Touch',NULL,NULL,'10 min./level (D)','V, S, DF',ARRAY['cleric','ranger']::text[],'Transmutation \[Water\]

Level: Clr 3, Rgr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: One touched creature/level

Duration: 10 min./level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The transmuted creatures can tread on any liquid as if it were firm ground. Mud, oil, snow, quicksand, running water, ice, and even lava can be traversed easily, since the subjects’ feet hover an inch or two above the surface. (Creatures crossing molten lava still take damage from the heat because they are near it.) The subjects can walk, run, charge, or otherwise move across the surface as if it were normal ground.

If the spell is cast underwater (or while the subjects are partially or wholly submerged in whatever liquid they are in), the subjects are borne toward the surface at 60 feet per round until they can stand on it.','{"class_levels":{"cleric":3,"ranger":3},"source_field_values":{"Level":"Clr 3, Rgr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"One touched creature/level","Duration":"10 min./level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_waves_of_exhaustion','Waves of Exhaustion','Sor/Wiz 7',7,'Necromancy','60 ft.',NULL,'Cone-shaped burst','Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: No

Spell Resistance: Yes

Waves of negative energy cause all living creatures in the spell’s area to become exhausted. This spell has no effect on a creature that is already exhausted.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"No","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_waves_of_fatigue','Waves of Fatigue','Sor/Wiz 5',5,'Necromancy','30 ft.',NULL,'Cone-shaped burst','Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: 30 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: No

Spell Resistance: Yes

Waves of negative energy render all living creatures in the spell’s area fatigued. This spell has no effect on a creature that is already fatigued.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"30 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"No","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_web','Web','Sor/Wiz 2',2,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Webs in a 20-ft.-radius spread',NULL,'10 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Webs in a 20-ft.-radius spread

Duration: 10 min./level (D)

Saving Throw: Reflex negates; see text

Spell Resistance: No

Web creates a many-layered mass of strong, sticky strands. These strands trap those caught in them. The strands are similar to spider webs but far larger and tougher. These masses must be anchored to two or more solid and diametrically opposed points or else the web collapses upon itself and disappears. Creatures caught within a web become entangled among the gluey fibers. Attacking a creature in a web won’t cause you to become entangled.

Anyone in the effect’s area when the spell is cast must make a Reflex save. If this save succeeds, the creature is entangled, but not prevented from moving, though moving is more difficult than normal for being entangled (see below). If the save fails, the creature is entangled and can’t move from its space, but can break loose by spending 1 round and making a DC 20 Strength check or a DC 25 Escape Artist check. Once loose (either by making the initial Reflex save or a later Strength check or Escape Artist check), a creature remains entangled, but may move through the web very slowly. Each round devoted to moving allows the creature to make a new Strength check or Escape Artist check. The creature moves 5 feet for each full 5 points by which the check result exceeds 10.

If you have at least 5 feet of web between you and an opponent, it provides cover. If you have at least 20 feet of web between you, it provides total cover.

The strands of a web spell are flammable. A magic flaming sword can slash them away as easily as a hand brushes away cobwebs. Any fire can set the webs alight and burn away 5 square feet in 1 round. All creatures within flaming webs take 2d4 points of fire damage from the flames.

Web can be made permanent with a permanency spell. A permanent web that is damaged (but not destroyed) regrows in 10 minutes.

Material Component: A bit of spider web.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Webs in a 20-ft.-radius spread","Duration":"10 min./level (D)","Saving Throw":"Reflex negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_weird','Weird','Sor/Wiz 9',9,'Illusion (Phantasm) [Fear, Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Illusion (Phantasm) \[Fear, Mind-Affecting\]

Level: Sor/Wiz 9

Targets: Any number of creatures, no two of which can be more than 30 ft. apart

This spell functions like phantasmal killer, except it can affect more than one creature. Only the affected creatures see the phantasmal creatures attacking them, though you see the attackers as shadowy shapes.

If a subject’s Fortitude save succeeds, it still takes 3d6 points of damage and is stunned for 1 round. The subject also takes 1d4 points of temporary Strength damage.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Targets":"Any number of creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_whirlwind','Whirlwind','Air 8, Drd 8',8,'Evocation [Air]','Long (400 ft. + 40 ft./level)','Cyclone 10 ft. wide at base, 30 ft. wide at top, and 30 ft. tall',NULL,'1 round/level (D)','V, S, DF',ARRAY['druid']::text[],'Evocation \[Air\]

Level: Air 8, Drd 8

Components: V, S, DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Effect: Cyclone 10 ft. wide at base, 30 ft. wide at top, and 30 ft. tall

Duration: 1 round/level (D)

Saving Throw: Reflex negates; see text

Spell Resistance: Yes

This spell creates a powerful cyclone of raging wind that moves through the air, along the ground, or over water at a speed of 60 feet per round. You can concentrate on controlling the cyclone’s every movement or specify a simple program. Directing the cyclone’s movement or changing its programmed movement is a standard action for you. The cyclone always moves during your turn. If the cyclone exceeds the spell’s range, it moves in a random, uncontrolled fashion for 1d3 rounds and then dissipates. (You can’t regain control of the cyclone, even if comes back within range.)

Any Large or smaller creature that comes in contact with the spell effect must succeed on a Reflex save or take 3d6 points of damage. A Medium or smaller creature that fails its first save must succeed on a second one or be picked up bodily by the cyclone and held suspended in its powerful winds, taking 1d8 points of damage each round on your turn with no save allowed. You may direct the cyclone to eject any carried creatures whenever you wish, depositing the hapless souls wherever the cyclone happens to be when they are released.','{"class_levels":{"druid":8},"source_field_values":{"Level":"Air 8, Drd 8","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Effect":"Cyclone 10 ft. wide at base, 30 ft. wide at top, and 30 ft. tall","Duration":"1 round/level (D)","Saving Throw":"Reflex negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_whispering_wind','Whispering Wind','Brd 2, Sor/Wiz 2',2,'Transmutation [Air]','1 mile/level',NULL,'10-ft.-radius spread','No more than 1 hour/level or until discharged (destination is reached)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation \[Air\]

Level: Brd 2, Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: 1 mile/level

Area: 10-ft.-radius spread

Duration: No more than 1 hour/level or until discharged (destination is reached)

Saving Throw: None

Spell Resistance: No

You send a message or sound on the wind to a designated spot. The whispering wind travels to a specific location within range that is familiar to you, provided that it can find a way to the location. A whispering wind is as gentle and unnoticed as a zephyr until it reaches the location. It then delivers its whisper-quiet message or other sound. Note that the message is delivered regardless of whether anyone is present to hear it. The wind then dissipates.

You can prepare the spell to bear a message of no more than twenty-five words, cause the spell to deliver other sounds for 1 round, or merely have the whispering wind seem to be a faint stirring of the air. You can likewise cause the whispering wind to move as slowly as 1 mile per hour or as quickly as 1 mile per 10 minutes.

When the spell reaches its objective, it swirls and remains in place until the message is delivered. As with magic mouth, whispering wind cannot speak verbal components, use command words, or activate magical effects.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"1 mile/level","Area":"10-ft.-radius spread","Duration":"No more than 1 hour/level or until discharged (destination is reached)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wind_walk','Wind Walk','Clr 6, Drd 7',6,'Transmutation [Air]','Touch',NULL,NULL,'1 hour/level (D); see text','V, S, DF',ARRAY['cleric','druid']::text[],'Transmutation \[Air\]

Level: Clr 6, Drd 7

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: You and one touched creature per three levels

Duration: 1 hour/level (D); see text

Saving Throw: No and Will negates (harmless)

Spell Resistance: No and Yes (harmless)

You alter the substance of your body to a cloudlike vapor (as the gaseous form spell) and move through the air, possibly at great speed. You can take other creatures with you, each of which acts independently.

Normally, a wind walker flies at a speed of 10 feet with perfect maneuverability. If desired by the subject, a magical wind wafts a wind walker along at up to 600 feet per round (60 mph) with poor maneuverability. Wind walkers are not invisible but rather appear misty and translucent. If fully clothed in white, they are 80% likely to be mistaken for clouds, fog, vapors, or the like.

A wind walker can regain its physical form as desired and later resume the cloud form. Each change to and from vaporous form takes 5 rounds, which counts toward the duration of the spell (as does any time spent in physical form). As noted above, you can dismiss the spell, and you can even dismiss it for individual wind walkers and not others.

For the last minute of the spell’s duration, a wind walker in cloud form automatically descends 60 feet per round (for a total of 600 feet), though it may descend faster if it wishes. This descent serves as a warning that the spell is about to end.','{"class_levels":{"cleric":6,"druid":7},"source_field_values":{"Level":"Clr 6, Drd 7","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"You and one touched creature per three levels","Duration":"1 hour/level (D); see text","Saving Throw":"No and Will negates (harmless)","Spell Resistance":"No and Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wind_wall','Wind Wall','Air 2, Clr 3, Drd 3, Rgr 2, Sor/Wiz 3',2,'Evocation [Air]','Medium (100 ft. + 10 ft./level)','Wall up to 10 ft./level long and 5 ft./level high (S)',NULL,'1 round/level','V, S, M/DF',ARRAY['cleric','druid','ranger','sorcerer','wizard']::text[],'Evocation \[Air\]

Level: Air 2, Clr 3, Drd 3, Rgr 2, Sor/Wiz 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Wall up to 10 ft./level long and 5 ft./level high (S)

Duration: 1 round/level

Saving Throw: None; see text

Spell Resistance: Yes

An invisible vertical curtain of wind appears. It is 2 feet thick and of considerable strength. It is a roaring blast sufficient to blow away any bird smaller than an eagle, or tear papers and similar materials from unsuspecting hands. (A Reflex save allows a creature to maintain its grasp on an object.) Tiny and Small flying creatures cannot pass through the barrier. Loose materials and cloth garments fly upward when caught in a wind wall. Arrows and bolts are deflected upward and miss, while any other normal ranged weapon passing through the wall has a 30% miss chance. (A giant-thrown boulder, a siege engine projectile, and other massive ranged weapons are not affected.) Gases, most gaseous breath weapons, and creatures in gaseous form cannot pass through the wall (although it is no barrier to incorporeal creatures).

While the wall must be vertical, you can shape it in any continuous path along the ground that you like. It is possible to create cylindrical or square wind walls to enclose specific points.

Arcane Material Component: A tiny fan and a feather of exotic origin.','{"class_levels":{"cleric":3,"druid":3,"ranger":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Air 2, Clr 3, Drd 3, Rgr 2, Sor/Wiz 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Wall up to 10 ft./level long and 5 ft./level high (S)","Duration":"1 round/level","Saving Throw":"None; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wish','Wish','Sor/Wiz 9',9,'Universal','See text',NULL,NULL,'See text','V, XP',ARRAY['sorcerer','wizard']::text[],'Universal

Level: Sor/Wiz 9

Components: V, XP

Casting Time: 1 standard action

Range: See text

Target, Effect, or Area: See text

Duration: See text

Saving Throw: See text

Spell Resistance: Yes

Wish is the mightiest spell a wizard or sorcerer can cast. By simply speaking aloud, you can alter reality to better suit you.

Even wish, however, has its limits.

A wish can produce any one of the following effects.

- Duplicate any wizard or sorcerer spell of 8th level or lower, provided the spell is not of a school prohibited to you.
- Duplicate any other spell of 6th level or lower, provided the spell is not of a school prohibited to you.
- Duplicate any wizard or sorcerer spell of 7th level or lower even if it’s of a prohibited school.
- Duplicate any other spell of 5th level or lower even if it’s of a prohibited school.
- Undo the harmful effects of many other spells, such as geas/quest or insanity.
- Create a nonmagical item of up to 25,000 gp in value.
- Create a magic item, or add to the powers of an existing magic item.
- Grant a creature a +1 inherent bonus to an ability score. Two to five wish spells cast in immediate succession can grant a creature a +2 to +5 inherent bonus to an ability score (two wishes for a +2 inherent bonus, three for a +3 inherent bonus, and so on). Inherent bonuses are instantaneous, so they cannot be dispelled. Note: An inherent bonus may not exceed +5 for a single ability score, and inherent bonuses to a particular ability score do not stack, so only the best one applies.
- Remove injuries and afflictions. A single wish can aid one creature per caster level, and all subjects are cured of the same kind of affliction. For example, you could heal all the damage you and your companions have taken, or remove all poison effects from everyone in the party, but not do both with the same wish. A wish can never restore the experience point loss from casting a spell or the level or Constitution loss from being raised from the dead.
- Revive the dead. A wish can bring a dead creature back to life by duplicating a resurrection spell. A wish can revive a dead creature whose body has been destroyed, but the task takes two wishes, one to recreate the body and another to infuse the body with life again. A wish cannot prevent a character who was brought back to life from losing an experience level.
- Transport travelers. A wish can lift one creature per caster level from anywhere on any plane and place those creatures anywhere else on any plane regardless of local conditions. An unwilling target gets a Will save to negate the effect, and spell resistance (if any) applies.
- Undo misfortune. A wish can undo a single recent event. The wish forces a reroll of any roll made within the last round (including your last turn). Reality reshapes itself to accommodate the new result. For example, a wish could undo an opponent’s successful save, a foe’s successful critical hit (either the attack roll or the critical roll), a friend’s failed save, and so on. The reroll, however, may be as bad as or worse than the original roll. An unwilling target gets a Will save to negate the effect, and spell resistance (if any) applies.

You may try to use a wish to produce greater effects than these, but doing so is dangerous. (The wish may pervert your intent into a literal but undesirable fulfillment or only a partial fulfillment.)

Duplicated spells allow saves and spell resistance as normal (but save DCs are for 9th-level spells).

Material Component: When a wish duplicates a spell with a material component that costs more than 10,000 gp, you must provide that component.

XP Cost: The minimum XP cost for casting wish is 5,000 XP. When a wish duplicates a spell that has an XP cost, you must pay 5,000 XP or that cost, whichever is more. When a wish creates or improves a magic item, you must pay twice the normal XP cost for crafting or improving the item, plus an additional 5,000 XP.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Components":"V, XP","Casting Time":"1 standard action","Range":"See text","Target, Effect, or Area":"See text","Duration":"See text","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_wood_shape','Wood Shape','Drd 2',2,'Transmutation','Touch','One touched piece of wood no larger than 10 cu. ft. + 1 cu. ft./level',NULL,'Instantaneous','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: One touched piece of wood no larger than 10 cu. ft. + 1 cu. ft./level

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

Wood shape enables you to form one existing piece of wood into any shape that suits your purpose. While it is possible to make crude coffers, doors, and so forth, fine detail isn’t possible. There is a 30% chance that any shape that includes moving parts simply doesn’t work.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"One touched piece of wood no larger than 10 cu. ft. + 1 cu. ft./level","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_word_of_chaos','Word of Chaos','Chaos 7, Clr 7',7,'Evocation [Chaotic, Sonic]','40 ft.',NULL,'Nonchaotic creatures in a 40-ft.- radius spread centered on you','Instantaneous','V',ARRAY['cleric']::text[],'Evocation \[Chaotic, Sonic\]

Level: Chaos 7, Clr 7

Components: V

Casting Time: 1 standard action

Range: 40 ft.

Area: Nonchaotic creatures in a 40-ft.- radius spread centered on you

Duration: Instantaneous

Saving Throw: None or Will negates; see text

Spell Resistance: Yes

Any nonchaotic creature within the area who hears the word of chaos suffers the following ill effects.

The effects are cumulative and concurrent. No saving throw is allowed against these effects.

Deafened: The creature is deafened for 1d4 rounds.

Stunned: The creature is stunned for 1 round.

Confused: The creature is confused, as by the confusion spell, for 1d10 minutes. This is a mind-affecting enchantment effect.

Killed: Living creatures die. Undead creatures are destroyed.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Effect</th></tr><tr><td>Equal to caster level</td><td>Deafened</td></tr><tr><td>Up to caster level –1</td><td>Stunned, deafened</td></tr><tr><td>Up to caster level –5</td><td><i>Confused</i>, stunned, deafened</td></tr><tr><td>Up to caster level –10</td><td>Killed, <i>confused</i>, stunned, deafened</td></tr></tbody></table>

Furthermore, if you are on your home plane when you cast this spell, nonchaotic extraplanar creatures within the area are instantly banished back to their home planes. Creatures so banished cannot return for at least 24 hours. This effect takes place regardless of whether the creatures hear the word of chaos. The banishment effect allows a Will save (at a –4 penalty) to negate.

Creatures whose HD exceed your caster level are unaffected by word of chaos.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Chaos 7, Clr 7","Components":"V","Casting Time":"1 standard action","Range":"40 ft.","Area":"Nonchaotic creatures in a 40-ft.- radius spread centered on you","Duration":"Instantaneous","Saving Throw":"None or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_word_of_recall','Word of Recall','Clr 6, Drd 8',6,'Conjuration (Teleportation)','Unlimited','You and touched objects or other willing creatures',NULL,'Instantaneous','V',ARRAY['cleric','druid']::text[],'Conjuration (Teleportation)

Level: Clr 6, Drd 8

Components: V

Casting Time: 1 standard action

Range: Unlimited

Target: You and touched objects or other willing creatures

Duration: Instantaneous

Saving Throw: None or Will negates (harmless, object)

Spell Resistance: No or Yes (harmless, object)

Word of recall teleports you instantly back to your sanctuary when the word is uttered. You must designate the sanctuary when you prepare the spell, and it must be a very familiar place. The actual point of arrival is a designated area no larger than 10 feet by 10 feet. You can be transported any distance within a plane but cannot travel between planes. You can transport, in addition to yourself, any objects you carry, as long as their weight doesn’t exceed your maximum load. You may also bring one additional willing Medium or smaller creature (carrying gear or objects up to its maximum load) or its equivalent per three caster levels. A Large creature counts as two Medium creatures, a Huge creature counts as two Large creatures, and so forth. All creatures to be transported must be in contact with one another, and at least one of those creatures must be in contact with you. Exceeding this limit causes the spell to fail.

An unwilling creature can’t be teleported by word of recall. Likewise, a creature’s Will save (or spell resistance) prevents items in its possession from being teleported. Unattended, nonmagical objects receive no saving throw.','{"class_levels":{"cleric":6,"druid":8},"source_field_values":{"Level":"Clr 6, Drd 8","Components":"V","Casting Time":"1 standard action","Range":"Unlimited","Target":"You and touched objects or other willing creatures","Duration":"Instantaneous","Saving Throw":"None or Will negates (harmless, object)","Spell Resistance":"No or Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md'),
('srd35_spell_zone_of_silence','Zone of Silence','Brd 4',4,'Illusion (Glamer)','Personal',NULL,'5-ft.-radius emanation centered on you','1 hour/level (D)','V, S',ARRAY['bard']::text[],'Illusion (Glamer)

Level: Brd 4

Components: V, S

Casting Time: 1 round

Range: Personal

Area: 5-ft.-radius emanation centered on you

Duration: 1 hour/level (D)

By casting zone of silence, you manipulate sound waves in your immediate vicinity so that you and those within the spell’s area can converse normally, yet no one outside can hear your voices or any other noises from within, including language-dependent or sonic spell effects. This effect is centered on you and moves with you. Anyone who enters the zone immediately becomes subject to its effects, but those who leave are no longer affected. Note, however, that a successful Spot check to read lips can still reveal what’s said inside a zone of silence.','{"class_levels":{"bard":4},"source_field_values":{"Level":"Brd 4","Components":"V, S","Casting Time":"1 round","Range":"Personal","Area":"5-ft.-radius emanation centered on you","Duration":"1 hour/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
