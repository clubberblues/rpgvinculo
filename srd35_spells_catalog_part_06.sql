-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_planar_binding','Planar Binding','Sor/Wiz 6',6,'Conjuration (Calling) [see text for _lesser planar binding_]',NULL,NULL,NULL,NULL,'V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Calling) \[see text for lesser planar binding\]

Level: Sor/Wiz 6

Components: V, S

Targets: Up to three elementals or outsiders, totaling no more than 12 HD, no two of which can be more than 30 ft. apart when they appear

This spell functions like lesser planar binding, except that you may call a single creature of 12 HD or less, or up to three creatures of the same kind whose Hit Dice total no more than 12. Each creature gets a save, makes an independent attempt to escape, and must be individually persuaded to aid you.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S","Targets":"Up to three elementals or outsiders, totaling no more than 12 HD, no two of which can be more than 30 ft. apart when they appear"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_planar_binding_greater','Planar Binding, Greater','Sor/Wiz 8',8,'Conjuration (Calling) [see text for _lesser planar binding_]',NULL,NULL,NULL,NULL,'V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Calling) \[see text for lesser planar binding\]

Level: Sor/Wiz 8

Components: V, S

Targets: Up to three elementals or outsiders, totaling no more than 18 HD, no two of which can be more than 30 ft. apart when they appear.

This spell functions like lesser planar binding, except that you may call a single creature of 18 HD or less, or up to three creatures of the same kind whose Hit Dice total no more than 18. Each creature gets a saving throw, makes independent attempts to escape, and must be persuaded to aid you individually.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S","Targets":"Up to three elementals or outsiders, totaling no more than 18 HD, no two of which can be more than 30 ft. apart when they appear."},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_planar_binding_lesser','Planar Binding, Lesser','Sor/Wiz 5',5,'Conjuration (Calling) [see text]','Close (25 ft. + 5 ft./2 levels); see text','One elemental or outsider with 6 HD or less',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Calling) \[see text\]

Level: Sor/Wiz 5

Components: V, S

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels); see text

Target: One elemental or outsider with 6 HD or less

Duration: Instantaneous

Saving Throw: Will negates

Spell Resistance: No and Yes; see text

Casting this spell attempts a dangerous act: to lure a creature from another plane to a specifically prepared trap, which must lie within the spell’s range. The called creature is held in the trap until it agrees to perform one service in return for its freedom.

To create the trap, you must use a magic circle spell, focused inward. The kind of creature to be bound must be known and stated. If you wish to call a specific individual, you must use that individual’s proper name in casting the spell.

The target creature is allowed a Will saving throw. If the saving throw succeeds, the creature resists the spell. If the saving throw fails, the creature is immediately drawn to the trap (spell resistance does not keep it from being called). The creature can escape from the trap with by successfully pitting its spell resistance against your caster level check, by dimensional travel, or with a successful Charisma check (DC 15 + 1/2 your caster level + your Cha modifier). It can try each method once per day. If it breaks loose, it can flee or attack you. A dimensional anchor cast on the creature prevents its escape via dimensional travel. You can also employ a calling diagram (see magic circle against evil) to make the trap more secure.

If the creature does not break free of the trap, you can keep it bound for as long as you dare. You can attempt to compel the creature to perform a service by describing the service and perhaps offering some sort of reward. You make a Charisma check opposed by the creature’s Charisma check. The check is assigned a bonus of +0 to +6 based on the nature of the service and the reward. If the creature wins the opposed check, it refuses service. New offers, bribes, and the like can be made or the old ones reoffered every 24 hours. This process can be repeated until the creature promises to serve, until it breaks free, or until you decide to get rid of it by means of some other spell. Impossible demands or unreasonable commands are never agreed to. If you roll a 1 on the Charisma check, the creature breaks free of the binding and can escape or attack you.

Once the requested service is completed, the creature need only so inform you to be instantly sent back whence it came. The creature might later seek revenge. If you assign some open-ended task that the creature cannot complete though its own actions the spell remains in effect for a maximum of one day per caster level, and the creature gains an immediate chance to break free. Note that a clever recipient can subvert some instructions.

When you use a calling spell to call an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels); see text","Target":"One elemental or outsider with 6 HD or less","Duration":"Instantaneous","Saving Throw":"Will negates","Spell Resistance":"No and Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_plane_shift','Plane Shift','Clr 5, Sor/Wiz 7',5,'Conjuration (Teleportation)','Touch','Creature touched, or up to eight willing creatures joining hands',NULL,'Instantaneous','V, S, F',ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Clr 5, Sor/Wiz 7

Components: V, S, F

Casting Time: 1 standard action

Range: Touch

Target: Creature touched, or up to eight willing creatures joining hands

Duration: Instantaneous

Saving Throw: Will negates

Spell Resistance: Yes

You move yourself or some other creature to another plane of existence or alternate dimension. If several willing persons link hands in a circle, as many as eight can be affected by the plane shift at the same time. Precise accuracy as to a particular arrival location on the intended plane is nigh impossible. From the Material Plane, you can reach any other plane, though you appear 5 to 500 miles (5d%) from your intended destination.

Note: Plane shift transports creatures instantaneously and then ends. The creatures need to find other means if they are to travel back.

Focus: A small, forked metal rod. The size and metal type dictates to which plane of existence or alternate dimension the spell sends the affected creatures.','{"class_levels":{"cleric":5,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 5, Sor/Wiz 7","Components":"V, S, F","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched, or up to eight willing creatures joining hands","Duration":"Instantaneous","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_plant_growth','Plant Growth','Drd 3, Plant 3, Rgr 3',3,'Transmutation','See text',NULL,NULL,'Instantaneous','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 3, Plant 3, Rgr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: See text

Target or Area: See text

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

Plant growth has different effects depending on the version chosen.

Overgrowth: This effect causes normal vegetation (grasses, briars, bushes, creepers, thistles, trees, vines) within long range (400 feet + 40 feet per caster level) to become thick and overgrown. The plants entwine to form a thicket or jungle that creatures must hack or force a way through. Speed drops to 5 feet, or 10 feet for Large or larger creatures. The area must have brush and trees in it for this spell to take effect.

At your option, the area can be a 100-foot-radius circle, a 150-foot-radius semicircle, or a 200-foot-radius quarter circle.

You may designate places within the area that are not affected.

Enrichment: This effect targets plants within a range of one-half mile, raising their potential productivity over the course of the next year to one-third above normal.

Plant growth counters diminish plants.

This spell has no effect on plant creatures.','{"class_levels":{"druid":3,"ranger":3},"source_field_values":{"Level":"Drd 3, Plant 3, Rgr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"See text","Target or Area":"See text","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_poison','Poison','Clr 4, Drd 3',3,'Necromancy','Touch','Living creature touched',NULL,'Instantaneous; see text','V, S, DF',ARRAY['cleric','druid']::text[],'Necromancy

Level: Clr 4, Drd 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: Instantaneous; see text

Saving Throw: Fortitude negates; see text

Spell Resistance: Yes

Calling upon the venomous powers of natural predators, you infect the subject with a horrible poison by making a successful melee touch attack. The poison deals 1d10 points of temporary Constitution damage immediately and another 1d10 points of temporary Constitution damage 1 minute later. Each instance of damage can be negated by a Fortitude save (DC 10 + 1/2 your caster level + your Wis modifier).','{"class_levels":{"cleric":4,"druid":3},"source_field_values":{"Level":"Clr 4, Drd 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous; see text","Saving Throw":"Fortitude negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_polar_ray','Polar Ray','Sor/Wiz 8',8,'Evocation [Cold]','Close (25 ft. + 5 ft./2 levels)','Ray',NULL,'Instantaneous','V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Sor/Wiz 8

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

A blue-white ray of freezing air and ice springs from your hand. You must succeed on a ranged touch attack with the ray to deal damage to a target. The ray deals 1d6 points of cold damage per caster level (maximum 25d6).

Focus: A small, white ceramic cone or prism.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_polymorph','Polymorph','Sor/Wiz 4',4,'Transmutation','Touch','Willing living creature touched',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Willing living creature touched

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell functions like alter self, except that you change the willing subject into another form of living creature. The new form may be of the same type as the subject or any of the following types: aberration, animal, dragon, fey, giant, humanoid, magical beast, monstrous humanoid, ooze, plant, or vermin. The assumed form can’t have more Hit Dice than your caster level (or the subject’s HD, whichever is lower), to a maximum of 15 HD at 15th level. You can’t cause a subject to assume a form smaller than Fine, nor can you cause a subject to assume an incorporeal or gaseous form. The subject’s creature type and subtype (if any) change to match the new form.

Upon changing, the subject regains lost hit points as if it had rested for a night (though this healing does not restore temporary ability damage and provide other benefits of resting; and changing back does not heal the subject further). If slain, the subject reverts to its original form, though it remains dead.

The subject gains the Strength, Dexterity, and Constitution scores of the new form but retains its own Intelligence, Wisdom, and Charisma scores. It also gains all extraordinary special attacks possessed by the form but does not gain the extraordinary special qualities possessed by the new form or any supernatural or spell-like abilities.

Incorporeal or gaseous creatures are immune to being polymorphed, and a creature with the shapechanger subtype can revert to its natural form as a standard action.

Material Component: An empty cocoon.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Willing living creature touched","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_polymorph_any_object','Polymorph Any Object','Sor/Wiz 8, Trickery 8',8,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One creature, or one nonmagical object of up to 100 cu. ft./level',NULL,'See text','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 8, Trickery 8

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature, or one nonmagical object of up to 100 cu. ft./level

Duration: See text

Saving Throw: Fortitude negates (object); see text

Spell Resistance: Yes (object)

This spell functions like polymorph, except that it changes one object or creature into another. The duration of the spell depends on how radical a change is made from the original state to its enchanted state. The duration is determined by using the following guidelines.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Changed Subject Is:</th><th>Increase to Duration Factor<sup>1</sup></th></tr><tr><td>Same kingdom (animal, vegetable, mineral)</td><td>+5</td></tr><tr><td>Same class (mammals, fungi, metals, etc.)</td><td>+2</td></tr><tr><td>Same size</td><td>+2</td></tr><tr><td>Related (twig is to tree, wolf fur is to wolf, etc.)</td><td>+2</td></tr><tr><td>Same or lower Intelligence</td><td>+2</td></tr><tr><td colspan="2">1 Add all that apply. Look up the total on the next table.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Duration Factor</th><th>Duration</th><th>Example</th></tr><tr><td>0</td><td>20 minutes</td><td>Pebble to human</td></tr><tr><td>2</td><td>1 hour</td><td>Marionette to human</td></tr><tr><td>4</td><td>3 hours</td><td>Human to marionette</td></tr><tr><td>5</td><td>12 hours</td><td>Lizard to manticore</td></tr><tr><td>6</td><td>2 days</td><td>Sheep to wool coat</td></tr><tr><td>7</td><td>1 week</td><td>Shrew to manticore</td></tr><tr><td>9+</td><td>Permanent</td><td>Manticore to shrew</td></tr></tbody></table>

Unlike polymorph, polymorph any object does grant the creature the Intelligence score of its new form. If the original form didn’t have a Wisdom or Charisma score, it gains those scores as appropriate for the new form.

Damage taken by the new form can result in the injury or death of the polymorphed creature. In general, damage occurs when the new form is changed through physical force.

A nonmagical object cannot be made into a magic item with this spell. Magic items aren’t affected by this spell.

This spell cannot create material of great intrinsic value, such as copper, silver, gems, silk, gold, platinum, mithral, or adamantine. It also cannot reproduce the special properties of cold iron in order to overcome the damage reduction of certain creatures.

This spell can also be used to duplicate the effects of baleful polymorph, polymorph, flesh to stone, stone to flesh, transmute mud to rock, transmute metal to wood, or transmute rock to mud.

Arcane Material Component: Mercury, gum arabic, and smoke.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8, Trickery 8","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature, or one nonmagical object of up to 100 cu. ft./level","Duration":"See text","Saving Throw":"Fortitude negates (object); see text","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_power_word_blind','Power Word Blind','Sor/Wiz 7, War 7',7,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One creature with 200 hp or less',NULL,'See text','V',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 7, War 7

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature with 200 hp or less

Duration: See text

Saving Throw: None

Spell Resistance: Yes

You utter a single word of power that causes one creature of your choice to become blinded, whether the creature can hear the word or not. The duration of the spell depends on the target’s current hit point total. Any creature that currently has 201 or more hit points is unaffected by power word blind.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Hit Points</th><th>Duration</th></tr><tr><td>50 or less</td><td>Permanent</td></tr><tr><td>51–100</td><td>1d4+1 minutes</td></tr><tr><td>101–200</td><td>1d4+1 rounds</td></tr></tbody></table>','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7, War 7","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature with 200 hp or less","Duration":"See text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_power_word_kill','Power Word Kill','Sor/Wiz 9, War 9',9,'Enchantment (Compulsion) [Death, Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature with 100 hp or less',NULL,'Instantaneous','V',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Death, Mind-Affecting\]

Level: Sor/Wiz 9, War 9

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature with 100 hp or less

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

You utter a single word of power that instantly kills one creature of your choice, whether the creature can hear the word or not. Any creature that currently has 101 or more hit points is unaffected by power word kill.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9, War 9","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature with 100 hp or less","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_power_word_stun','Power Word Stun','Sor/Wiz 8, War 8',8,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One creature with 150 hp or less',NULL,'See text','V',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 8, War 8

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature with 150 hp or less

Duration: See text

Saving Throw: None

Spell Resistance: Yes

You utter a single word of power that instantly causes one creature of your choice to become stunned, whether the creature can hear the word or not. The duration of the spell depends on the target’s current hit point total. Any creature that currently has 151 or more hit points is unaffected by power word stun.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Hit Points</th><th>Duration</th></tr><tr><td>50 or less</td><td>4d4 rounds</td></tr><tr><td>51–100</td><td>2d4 rounds</td></tr><tr><td>101–150</td><td>1d4 rounds</td></tr></tbody></table>','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8, War 8","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature with 150 hp or less","Duration":"See text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prayer','Prayer','Clr 3, Pal 3',3,'Enchantment (Compulsion) [Mind-Affecting]','40 ft.',NULL,'All allies and foes within a 40-ft.-radius burst centered on you','1 round/level','V, S, DF',ARRAY['cleric','paladin']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 3, Pal 3

Components: V, S, DF

Casting Time: 1 standard action

Range: 40 ft.

Area: All allies and foes within a 40-ft.-radius burst centered on you

Duration: 1 round/level

Saving Throw: None

Spell Resistance: Yes

You bring special favor upon yourself and your allies while bringing disfavor to your enemies. You and your each of your allies gain a +1 luck bonus on attack rolls, weapon damage rolls, saves, and skill checks, while each of your foes takes a –1 penalty on such rolls.','{"class_levels":{"cleric":3,"paladin":3},"source_field_values":{"Level":"Clr 3, Pal 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"40 ft.","Area":"All allies and foes within a 40-ft.-radius burst centered on you","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prestidigitation','Prestidigitation','Brd 0, Sor/Wiz 0',0,'Universal','10 ft.',NULL,NULL,'1 hour','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Universal

Level: Brd 0, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: 10 ft.

Target, Effect, or Area: See text

Duration: 1 hour

Saving Throw: See text

Spell Resistance: No

Prestidigitations are minor tricks that novice spellcasters use for practice. Once cast, a prestidigitation spell enables you to perform simple magical effects for 1 hour. The effects are minor and have severe limitations. A prestidigitation can slowly lift 1 pound of material. It can color, clean, or soil items in a 1-foot cube each round. It can chill, warm, or flavor 1 pound of nonliving material. It cannot deal damage or affect the concentration of spellcasters. Prestidigitation can create small objects, but they look crude and artificial. The materials created by a prestidigitation spell are extremely fragile, and they cannot be used as tools, weapons, or spell components. Finally, a prestidigitation lacks the power to duplicate any other spell effects. Any actual change to an object (beyond just moving, cleaning, or soiling it) persists only 1 hour.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"10 ft.","Target, Effect, or Area":"See text","Duration":"1 hour","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prismatic_sphere','Prismatic Sphere','Protection 9, Sor/Wiz 9, Sun 9',9,'Abjuration','10 ft.','10-ft.-radius sphere centered on you',NULL,NULL,'V',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Protection 9, Sor/Wiz 9, Sun 9

Components: V

Range: 10 ft.

Effect: 10-ft.-radius sphere centered on you

This spell functions like prismatic wall, except you conjure up an immobile, opaque globe of shimmering, multicolored light that surrounds you and protects you from all forms of attack. The sphere flashes in all colors of the visible spectrum.

The sphere’s blindness effect on creatures with less than 8 HD lasts 2d4x10 minutes.

You can pass into and out of the prismatic sphere and remain near it without harm. However, when you’re inside it, the sphere blocks any attempt to project something through the sphere (including spells). Other creatures that attempt to attack you or pass through suffer the effects of each color, one at a time.

Typically, only the upper hemisphere of the globe will exist, since you are at the center of the sphere, so the lower half is usually excluded by the floor surface you are standing on.

The colors of the sphere have the same effects as the colors of a prismatic wall.

Prismatic sphere can be made permanent with a permanency spell.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Protection 9, Sor/Wiz 9, Sun 9","Components":"V","Range":"10 ft.","Effect":"10-ft.-radius sphere centered on you"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prismatic_spray','Prismatic Spray','Sor/Wiz 7',7,'Evocation','60 ft.',NULL,'Cone-shaped burst','Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation

Level: Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: Yes

This spell causes seven shimmering, intertwined, multicolored beams of light to spray from your hand. Each beam has a different power. Creatures in the area of the spell with 8 HD or less are automatically blinded for 2d4 rounds. Every creature in the area is randomly struck by one or more beams, which have additional effects.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>1d8</th><th>Color of Beam</th><th>Effect</th></tr><tr><td>1</td><td>Red</td><td>20 points fire damage (Reflex half)</td></tr><tr><td>2</td><td>Orange</td><td>40 points acid damage (Reflex half)</td></tr><tr><td>3</td><td>Yellow</td><td>80 points electricity damage (Reflex half)</td></tr><tr><td>4</td><td>Green</td><td>Poison (Kills; Fortitude partial, take 1d6 points of Con damage instead)</td></tr><tr><td>5</td><td>Blue</td><td>Turned to stone (Fortitude negates)</td></tr><tr><td>6</td><td>Indigo</td><td>Insane, as <i>insanity</i> spell (Will negates)</td></tr><tr><td>7</td><td>Violet</td><td>Sent to another plane (Will negates)</td></tr><tr><td>8</td><td colspan="2">Struck by two rays; roll twice more, ignoring any “8” results.</td></tr></tbody></table>','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prismatic_wall','Prismatic Wall','Sor/Wiz 8',8,'Abjuration','Close (25 ft. + 5 ft./2 levels)','Wall 4 ft./level wide, 2 ft./level high',NULL,'10 min./level (D)','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Wall 4 ft./level wide, 2 ft./level high

Duration: 10 min./level (D)

Saving Throw: See text

Spell Resistance: See text

Prismatic wall creates a vertical, opaque wall—a shimmering, multicolored plane of light that protects you from all forms of attack. The wall flashes with seven colors, each of which has a distinct power and purpose. The wall is immobile, and you can pass through and remain near the wall without harm. However, any other creature with less than 8 HD that is within 20 feet of the wall is blinded for 2d4 rounds by the colors if it looks at the wall.

The wall’s maximum proportions are 4 feet wide per caster level and 2 feet high per caster level. A prismatic wall spell cast to materialize in a space occupied by a creature is disrupted, and the spell is wasted.

Each color in the wall has a special effect. The accompanying table shows the seven colors of the wall, the order in which they appear, their effects on creatures trying to attack you or pass through the wall, and the magic needed to negate each color.

The wall can be destroyed, color by color, in consecutive order, by various magical effects; however, the first color must be brought down before the second can be affected, and so on. A rod of cancellation or a*mage’s disjunction* spell destroys a prismatic wall, but an antimagic field fails to penetrate it. Dispel magic and greater dispel magic cannot dispel the wall or anything beyond it. Spell resistance is effective against a prismatic wall, but the caster level check must be repeated for each color present.

Prismatic wall can be made permanent with a permanency spell.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Color</th><th>Order</th><th>Effect of Color</th><th>Negated By</th></tr><tr><td>Red</td><td>1st</td><td>Stops nonmagical ranged weapons.<br>Deals 20 points of fire damage (Reflex half).</td><td><i>Cone of cold</i></td></tr><tr><td>Orange</td><td>2nd</td><td>Stops magical ranged weapons.<br>Deals 40 points of acid damage (Reflex half).</td><td><i>Gust of wind</i></td></tr><tr><td>Yellow</td><td>3rd</td><td>Stops poisons, gases, and petrification.<br>Deals 80 points of electricity damage (Reflex half).</td><td><i>Disintegrate</i></td></tr><tr><td>Green</td><td>4th</td><td>Stops breath weapons.<br>Poison (Kills; Fortitude partial for 1d6 points of Con damage instead).</td><td><i>Passwall</i></td></tr><tr><td>Blue</td><td>5th</td><td>Stops divination and mental attacks.<br>Turned to stone (Fortitude negates).</td><td><i>Magic missile</i></td></tr><tr><td>Indigo</td><td>6th</td><td>Stops all spells.<br>Will save or become insane (as <i>insanity</i> spell).</td><td><i>Daylight</i></td></tr><tr><td>Violet</td><td>7th</td><td>Energy field destroys all objects and effects.<sup>1</sup><br>Creatures sent to another plane (Will negates).</td><td><i>Dispel magic</i></td></tr><tr><td colspan="4">1 The violet effect makes the special effects of the other six colors redundant, but these six effects are included here because certain magic items can create prismatic effects one color at a time, and spell resistance might render some colors ineffective (see above).</td></tr></tbody></table>','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Wall 4 ft./level wide, 2 ft./level high","Duration":"10 min./level (D)","Saving Throw":"See text","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_produce_flame','Produce Flame','Drd 1, Fire 2',1,'Evocation [Fire]','0 ft.','Flame in your palm',NULL,'1 min./level (D)','V, S',ARRAY['druid']::text[],'Evocation \[Fire\]

Level: Drd 1, Fire 2

Components: V, S

Casting Time: 1 standard action

Range: 0 ft.

Effect: Flame in your palm

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: Yes

Flames as bright as a torch appear in your open hand. The flames harm neither you nor your equipment.

In addition to providing illumination, the flames can be hurled or used to touch enemies. You can strike an opponent with a melee touch attack, dealing fire damage equal to 1d6 +1 point per caster level (maximum +5). Alternatively, you can hurl the flames up to 120 feet as a thrown weapon. When doing so, you attack with a ranged touch attack (with no range penalty) and deal the same damage as with the melee attack. No sooner do you hurl the flames than a new set appears in your hand. Each attack you make reduces the remaining duration by 1 minute. If an attack reduces the remaining duration to 0 minutes or less, the spell ends after the attack resolves.

This spell does not function underwater.','{"class_levels":{"druid":1},"source_field_values":{"Level":"Drd 1, Fire 2","Components":"V, S","Casting Time":"1 standard action","Range":"0 ft.","Effect":"Flame in your palm","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_programmed_image','Programmed Image','Brd 6, Sor/Wiz 6',6,'Illusion (Figment)',NULL,'Visual figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)',NULL,'Permanent until triggered, then 1 round/level',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 6, Sor/Wiz 6

Effect: Visual figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)

Duration: Permanent until triggered, then 1 round/level

This spell functions like silent image, except that this spell’s figment activates when a specific condition occurs. The figment includes visual, auditory, olfactory, and thermal elements, including intelligible speech.

You set the triggering condition (which may be a special word) when casting the spell. The event that triggers the illusion can be as general or as specific and detailed as desired but must be based on an audible, tactile, olfactory, or visual trigger. The trigger cannot be based on some quality not normally obvious to the senses, such as alignment. (See magic mouth for more details about such triggers.)

Material Component: A bit of fleece and jade dust worth 25 gp.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Effect":"Visual figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)","Duration":"Permanent until triggered, then 1 round/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_project_image','Project Image','Brd 6, Sor/Wiz 7',6,'Illusion (Shadow)','Medium (100 ft. + 10 ft./level)','One shadow duplicate',NULL,'1 round/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Brd 6, Sor/Wiz 7

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: One shadow duplicate

Duration: 1 round/level (D)

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

You tap energy from the Plane of Shadow to create a quasi-real, illusory version of yourself. The projected image looks, sounds, and smells like you but is intangible. The projected image mimics your actions (including speech) unless you direct it to act differently (which is a move action).

You can see through its eyes and hear through its ears as if you were standing where it is, and during your turn you can switch from using its senses to using your own, or back again, as a free action. While you are using its senses, your body is considered blinded and deafened.

If you desire, any spell you cast whose range is touch or greater can originate from the projected image instead of from you. The projected image can’t cast any spells on itself except for illusion spells. The spells affect other targets normally, despite originating from the projected image.

Objects are affected by the projected image as if they had succeeded on their Will save.

You must maintain line of effect to the projected image at all times. If your line of effect is obstructed, the spell ends. If you use dimension door, teleport, plane shift, or a similar spell that breaks your line of effect, even momentarily, the spell ends.

Material Component: A small replica of you (a doll), which costs 5 gp to create.','{"class_levels":{"bard":6,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Brd 6, Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"One shadow duplicate","Duration":"1 round/level (D)","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_arrows','Protection From Arrows','Sor/Wiz 2',2,'Abjuration','Touch','Creature touched',NULL,'1 hour/level or until discharged','V, S, F',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 2

Components: V, S, F

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 hour/level or until discharged

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The warded creature gains resistance to ranged weapons. The subject gains damage reduction 10/magic against ranged weapons. (This spell doesn’t grant you the ability to damage creatures with similar damage reduction.) Once the spell has prevented a total of 10 points of damage per caster level (maximum 100 points), it is discharged.

Focus: A piece of shell from a tortoise or a turtle.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, F","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 hour/level or until discharged","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_chaos','Protection From Chaos','Clr 1, Law 1, Pal 1, Sor/Wiz 1',1,'Abjuration [Lawful]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Abjuration \[Lawful\]

Level: Clr 1, Law 1, Pal 1, Sor/Wiz 1

This spell functions like protection from evil, except that the deflection and resistance bonuses apply to attacks from chaotic creatures, and chaotic summoned creatures cannot touch the subject.','{"class_levels":{"cleric":1,"paladin":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Law 1, Pal 1, Sor/Wiz 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_energy','Protection From Energy','Clr 3, Drd 3, Luck 3, Protection 3, Rgr 2, Sor/Wiz 3',2,'Abjuration','Touch','Creature touched',NULL,'10 min./level or until discharged','V, S, DF',ARRAY['cleric','druid','ranger','sorcerer','wizard']::text[],'Abjuration

Level: Clr 3, Drd 3, Luck 3, Protection 3, Rgr 2, Sor/Wiz 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level or until discharged

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

Protection from energy grants temporary immunity to the type of energy you specify when you cast it (acid, cold, electricity, fire, or sonic). When the spell absorbs 12 points per caster level of energy damage (to a maximum of 120 points at 10th level), it is discharged.

Note: Protection from energy overlaps (and does not stack with) resist energy. If a character is warded by protection from energy and resist energy, the protection spell absorbs damage until its power is exhausted.','{"class_levels":{"cleric":3,"druid":3,"ranger":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 3, Drd 3, Luck 3, Protection 3, Rgr 2, Sor/Wiz 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level or until discharged","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_evil','Protection From Evil','Clr 1, Good 1, Pal 1, Sor/Wiz 1',1,'Abjuration [Good]','Touch','Creature touched',NULL,'1 min./level (D)','V, S, M/DF',ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Abjuration \[Good\]

Level: Clr 1, Good 1, Pal 1, Sor/Wiz 1

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: No; see text

This spell wards a creature from attacks by evil creatures, from mental control, and from summoned creatures. It creates a magical barrier around the subject at a distance of 1 foot. The barrier moves with the subject and has three major effects.

First, the subject gains a +2 deflection bonus to AC and a +2 resistance bonus on saves. Both these bonuses apply against attacks made or effects created by evil creatures.

Second, the barrier blocks any attempt to possess the warded creature (by a magic jar attack, for example) or to exercise mental control over the creature (including enchantment (charm) effects and enchantment (compulsion) effects that grant the caster ongoing control over the subject, such as dominate person). The protection does not prevent such effects from targeting the protected creature, but it suppresses the effect for the duration of the protection from evil effect. If the protection from evil effect ends before the effect granting mental control does, the would-be controller would then be able to mentally command the controlled creature. Likewise, the barrier keeps out a possessing life force but does not expel one if it is in place before the spell is cast. This second effect works regardless of alignment.

Third, the spell prevents bodily contact by summoned creatures. This causes the natural weapon attacks of such creatures to fail and the creatures to recoil if such attacks require touching the warded creature. Good summoned creatures are immune to this effect. The protection against contact by summoned creatures ends if the warded creature makes an attack against or tries to force the barrier against the blocked creature. Spell resistance can allow a creature to overcome this protection and touch the warded creature.

Arcane Material Component: A little powdered silver with which you trace a 3-foot -diameter circle on the floor (or ground) around the creature to be warded.','{"class_levels":{"cleric":1,"paladin":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Good 1, Pal 1, Sor/Wiz 1","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"No; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_good','Protection From Good','Clr 1, Evil 1, Sor/Wiz 1',1,'Abjuration [Evil]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration \[Evil\]

Level: Clr 1, Evil 1, Sor/Wiz 1

This spell functions like protection from evil, except that the deflection and resistance bonuses apply to attacks from good creatures, and good summoned creatures cannot touch the subject.','{"class_levels":{"cleric":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Evil 1, Sor/Wiz 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_law','Protection From Law','Chaos 1, Clr 1, Sor/Wiz 1',1,'Abjuration [Chaotic]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration \[Chaotic\]

Level: Chaos 1, Clr 1, Sor/Wiz 1

This spell functions like protection from evil, except that the deflection and resistance bonuses apply to attacks from lawful creatures, and lawful summoned creatures cannot touch the subject.','{"class_levels":{"cleric":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Chaos 1, Clr 1, Sor/Wiz 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_protection_from_spells','Protection From Spells','Magic 8, Sor/Wiz 8',8,'Abjuration','Touch',NULL,NULL,'10 min./level','V, S, M, F',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Magic 8, Sor/Wiz 8

Components: V, S, M, F

Casting Time: 1 standard action

Range: Touch

Targets: Up to one creature touched per four levels

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject gains a +8 resistance bonus on saving throws against spells and spell-like abilities (but not against supernatural and extraordinary abilities).

Material Component: A diamond of at least 500 gp value, which must be crushed and sprinkled over the targets.

Focus: One 1,000 gp diamond per creature to be granted the protection. Each subject must carry one such gem for the duration of the spell. If a subject loses the gem, the spell ceases to affect him.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Magic 8, Sor/Wiz 8","Components":"V, S, M, F","Casting Time":"1 standard action","Range":"Touch","Targets":"Up to one creature touched per four levels","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prying_eyes','Prying Eyes','Sor/Wiz 5',5,'Divination','One mile','Ten or more levitating eyes',NULL,'1 hour/level; see text (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 minute

Range: One mile

Effect: Ten or more levitating eyes

Duration: 1 hour/level; see text (D)

Saving Throw: None

Spell Resistance: No

You create a number of semitangible, visible magical orbs (called “eyes”) equal to 1d4 + your caster level. These eyes move out, scout around, and return as you direct them when casting the spell. Each eye can see 120 feet (normal vision only) in all directions.

While the individual eyes are quite fragile, they’re small and difficult to spot. Each eye is a Fine construct, about the size of a small apple, that has 1 hit point, AC 18 (+8 bonus for its size), flies at a speed of 30 feet with perfect maneuverability, and has a +16 Hide modifier. It has a Spot modifier equal to your caster level (maximum +15) and is subject to illusions, darkness, fog, and any other factors that would affect your ability to receive visual information about your surroundings. An eye traveling through darkness must find its way by touch.

When you create the eyes, you specify instructions you want them to follow in a command of no more than twenty-five words. Any knowledge you possess is known by the eyes as well.

In order to report their findings, the eyes must return to your hand. Each replays in your mind all it has seen during its existence. It takes an eye 1 round to replay 1 hour of recorded images. After relaying its findings, an eye disappears.

If an eye ever gets more than 1 mile away from you, it instantly ceases to exist. However, your link with the eye is such that you won’t know if the eye was destroyed because it wandered out of range or because of some other event.

The eyes exist for up to 1 hour per caster level or until they return to you. Dispel magic can destroy eyes. Roll separately for each eye caught in an area dispel. Of course, if an eye is sent into darkness, it could hit a wall or similar obstacle and destroy itself.

Material Component: A handful of crystal marbles.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 minute","Range":"One mile","Effect":"Ten or more levitating eyes","Duration":"1 hour/level; see text (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_prying_eyes_greater','Prying Eyes, Greater','Sor/Wiz 8',8,'Divination',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 8

This spell functions like prying eyes, except that the eyes can see all things as they actually are, just as if they had true seeing with a range of 120 feet. Thus, they can navigate darkened areas at full normal speed. Also, a greater prying eye’s maximum Spot modifier is +25 instead of +15.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_purify_food_and_drink','Purify Food and Drink','Clr 0, Drd 0',0,'Transmutation','10 ft.','1 cu. ft./level of contaminated food and water',NULL,'Instantaneous','V, S',ARRAY['cleric','druid']::text[],'Transmutation

Level: Clr 0, Drd 0

Components: V, S

Casting Time: 1 standard action

Range: 10 ft.

Target: 1 cu. ft./level of contaminated food and water

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This spell makes spoiled, rotten, poisonous, or otherwise contaminated food and water pure and suitable for eating and drinking. This spell does not prevent subsequent natural decay or spoilage. Unholy water and similar food and drink of significance is spoiled by purify food and drink, but the spell has no effect on creatures of any type nor upon magic potions.

Note: Water weighs about 8 pounds per gallon. One cubic foot of water contains roughly 8 gallons and weighs about 60 pounds.','{"class_levels":{"cleric":0,"druid":0},"source_field_values":{"Level":"Clr 0, Drd 0","Components":"V, S","Casting Time":"1 standard action","Range":"10 ft.","Target":"1 cu. ft./level of contaminated food and water","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_pyrotechnics','Pyrotechnics','Brd 2, Sor/Wiz 2',2,'Transmutation','Long (400 ft. + 40 ft./level)','One fire source, up to a 20-ft. cube',NULL,'1d4+1 rounds, or 1d4+1 rounds after creatures leave the smoke cloud; see text','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 2, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Target: One fire source, up to a 20-ft. cube

Duration: 1d4+1 rounds, or 1d4+1 rounds after creatures leave the smoke cloud; see text

Saving Throw: Will negates or Fortitude negates; see text

Spell Resistance: Yes or No; see text

Pyrotechnics turns a fire into either a burst of blinding fireworks or a thick cloud of choking smoke, depending on the version you choose.

Fireworks: The fireworks are a flashing, fiery, momentary burst of glowing, colored aerial lights. This effect causes creatures within 120 feet of the fire source to become blinded for 1d4+1 rounds (Will negates). These creatures must have line of sight to the fire to be affected. Spell resistance can prevent blindness.

Smoke Cloud: A writhing stream of smoke billows out from the source, forming a choking cloud. The cloud spreads 20 feet in all directions and lasts for 1 round per caster level. All sight, even darkvision, is ineffective in or through the cloud. All within the cloud take –4 penalties to Strength and Dexterity (Fortitude negates). These effects last for 1d4+1 rounds after the cloud dissipates or after the creature leaves the area of the cloud. Spell resistance does not apply.

Material Component: The spell uses one fire source, which is immediately extinguished. A fire so large that it exceeds a 20-foot cube is only partly extinguished. Magical fires are not extinguished, although a fire-based creature used as a source takes 1 point of damage per caster level.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Target":"One fire source, up to a 20-ft. cube","Duration":"1d4+1 rounds, or 1d4+1 rounds after creatures leave the smoke cloud; see text","Saving Throw":"Will negates or Fortitude negates; see text","Spell Resistance":"Yes or No; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_quench','Quench','Drd 3',3,'Transmutation','Medium (100 ft. + 10 ft./level)',NULL,NULL,'Instantaneous','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area or Target: One 20-ft. cube/level (S) or one fire-based magic item

Duration: Instantaneous

Saving Throw: None or Will negates (object)

Spell Resistance: No or Yes (object)

Quench is often used to put out forest fires and other conflagrations. It extinguishes all nonmagical fires in its area. The spell also dispels any fire spells in its area, though you must succeed on a dispel check (1d20 +1 per caster level, maximum +15) against each spell to dispel it. The DC to dispel such spells is 11 + the caster level of the fire spell.

Each elemental (fire) creature within the area of a quench spell takes 1d6 points of damage per caster level (maximum 15d6, no save allowed).

Alternatively, you can target the spell on a single magic item that creates or controls flame. The item loses all its fire-based magical abilities for 1d4 hours unless it succeeds on a Will save. (Artifacts are immune to this effect.)','{"class_levels":{"druid":3},"source_field_values":{"Level":"Drd 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area or Target":"One 20-ft. cube/level (S) or one fire-based magic item","Duration":"Instantaneous","Saving Throw":"None or Will negates (object)","Spell Resistance":"No or Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_rage','Rage','Brd 2, Sor/Wiz 3',2,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'Concentration + 1 round/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: One willing living creature per three levels, no two of which may be more than 30 ft. apart

Duration: Concentration + 1 round/level (D)

Saving Throw: None

Spell Resistance: Yes

Each affected creature gains a +2 morale bonus to Strength and Constitution, a +1 morale bonus on Will saves, and a –2 penalty to AC. The effect is otherwise identical with a barbarian’s rage except that the subjects aren’t fatigued at the end of the rage.','{"class_levels":{"bard":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 2, Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One willing living creature per three levels, no two of which may be more than 30 ft. apart","Duration":"Concentration + 1 round/level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_rainbow_pattern','Rainbow Pattern','Brd 4, Sor/Wiz 4',4,'Illusion (Pattern) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','Colorful lights with a 20-ft.-radius spread',NULL,'Concentration +1 round/ level (D)','V (Brd only), S, M, F; see text',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Pattern) \[Mind-Affecting\]

Level: Brd 4, Sor/Wiz 4

Components: V (Brd only), S, M, F; see text

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Colorful lights with a 20-ft.-radius spread

Duration: Concentration +1 round/ level (D)

Saving Throw: Will negates

Spell Resistance: Yes

A glowing, rainbow-hued pattern of interweaving colors fascinates those within it. Rainbow pattern fascinates a maximum of 24 Hit Dice of creatures. Creatures with the fewest HD are affected first. Among creatures with equal HD, those who are closest to the spell’s point of origin are affected first. An affected creature that fails its saves is fascinated by the pattern.

With a simple gesture (a free action), you can make the rainbow pattern move up to 30 feet per round (moving its effective point of origin). All fascinated creatures follow the moving rainbow of light, trying to get or remain within the effect. Fascinated creatures who are restrained and removed from the pattern still try to follow it. If the pattern leads its subjects into a dangerous area each fascinated creature gets a second save. If the view of the lights is completely blocked creatures who can’t see them are no longer affected.

The spell does not affect sightless creatures.

Verbal Component: A wizard or sorcerer need not utter a sound to cast this spell, but a bard must sing, play music, or recite a rhyme as a verbal component.

Material Component: A piece of phosphor.

Focus: A crystal prism.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V (Brd only), S, M, F; see text","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Colorful lights with a 20-ft.-radius spread","Duration":"Concentration +1 round/ level (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_raise_dead','Raise Dead','Clr 5',5,'Conjuration (Healing)','Touch','Dead creature touched',NULL,'Instantaneous','V, S, M, DF',ARRAY['cleric']::text[],'Conjuration (Healing)

Level: Clr 5

Components: V, S, M, DF

Casting Time: 1 minute

Range: Touch

Target: Dead creature touched

Duration: Instantaneous

Saving Throw: None; see text

Spell Resistance: Yes (harmless)

You restore life to a deceased creature. You can raise a creature that has been dead for no longer than one day per caster level. In addition, the subject’s soul must be free and willing to return. If the subject’s soul is not willing to return, the spell does not work; therefore, a subject that wants to return receives no saving throw.

Coming back from the dead is an ordeal. The subject of the spell loses one level (or 1 Hit Die) when it is raised, just as if it had lost a level or a Hit Die to an energy-draining creature. If the subject is 1st level, it loses 2 points of Constitution instead (if this would reduce its Con to 0 or less, it can’t be raised). This level/HD loss or Constitution loss cannot be repaired by any means. A character who died with spells prepared has a 50% chance of losing any given spell upon being raised, in addition to losing spells for losing a level. A spellcasting creature that doesn’t prepare spells (such as a sorcerer) has a 50% chance of losing any given unused spell slot as if it had been used to cast a spell, in addition to losing spell slots for losing a level.

A raised creature has a number of hit points equal to its current Hit Dice. Any ability scores damaged to 0 are raised to 1. Normal poison and normal disease are cured in the process of raising the subject, but magical diseases and curses are not undone. While the spell closes mortal wounds and repairs lethal damage of most kinds, the body of the creature to be raised must be whole. Otherwise, missing parts are still missing when the creature is brought back to life. None of the dead creature’s equipment or possessions are affected in any way by this spell.

A creature who has been turned into an undead creature or killed by a death effect can’t be raised by this spell. Constructs, elementals, outsiders, and undead creatures can’t be raised. The spell cannot bring back a creature that has died of old age.

Material Component: Diamonds worth a total of least 5,000 gp.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5","Components":"V, S, M, DF","Casting Time":"1 minute","Range":"Touch","Target":"Dead creature touched","Duration":"Instantaneous","Saving Throw":"None; see text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_ray_of_enfeeblement','Ray of Enfeeblement','Sor/Wiz 1',1,'Necromancy','Close (25 ft. + 5 ft./2 levels)','Ray',NULL,'1 min./level','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray

Duration: 1 min./level

Saving Throw: None

Spell Resistance: Yes

A coruscating ray springs from your hand. You must succeed on a ranged touch attack to strike a target. The subject takes a penalty to Strength equal to 1d6+1 per two caster levels (maximum 1d6+5). The subject’s Strength score cannot drop below 1.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_ray_of_exhaustion','Ray of Exhaustion','Sor/Wiz 3',3,'Necromancy','Close (25 ft. + 5 ft./2 levels)','Ray',NULL,'1 min./level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray

Duration: 1 min./level

Saving Throw: Fortitude partial; see text

Spell Resistance: Yes

A black ray projects from your pointing finger. You must succeed on a ranged touch attack with the ray to strike a target.

The subject is immediately exhausted for the spell’s duration. A successful Fortitude save means the creature is only fatigued.

A character that is already fatigued instead becomes exhausted.

This spell has no effect on a creature that is already exhausted. Unlike normal exhaustion or fatigue, the effect ends as soon as the spell’s duration expires.

Material Component: A drop of sweat.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray","Duration":"1 min./level","Saving Throw":"Fortitude partial; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_ray_of_frost','Ray of Frost','Sor/Wiz 0',0,'Evocation [Cold]','Close (25 ft. + 5 ft./2 levels)','Ray',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

A ray of freezing air and ice projects from your pointing finger. You must succeed on a ranged touch attack with the ray to deal damage to a target. The ray deals 1d3 points of cold damage.','{"class_levels":{"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_read_magic','Read Magic','Brd 0, Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0',0,'Divination','Personal','You',NULL,'10 min./level','V, S, F',ARRAY['bard','cleric','druid','paladin','ranger','sorcerer','wizard']::text[],'Divination

Level: Brd 0, Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0

Components: V, S, F

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level

By means of read magic, you can decipher magical inscriptions on objects—books, scrolls, weapons, and the like—that would otherwise be unintelligible. This deciphering does not normally invoke the magic contained in the writing, although it may do so in the case of a cursed scroll. Furthermore, once the spell is cast and you have read the magical inscription, you are thereafter able to read that particular writing without recourse to the use of read magic. You can read at the rate of one page (250 words) per minute. The spell allows you to identify a glyph of warding with a DC 13 Spellcraft check, a greater glyph of warding with a DC 16 Spellcraft check, or any symbol spell with a Spellcraft check (DC 10 + spell level).

Read magic can be made permanent with a permanency spell.

Focus: A clear crystal or mineral prism.','{"class_levels":{"bard":0,"cleric":0,"druid":0,"paladin":1,"ranger":1,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0","Components":"V, S, F","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_reduce_animal','Reduce Animal','Drd 2, Rgr 3',2,'Transmutation','Touch','One willing animal of Small, Medium, Large, or Huge size',NULL,'1 hour/level (D)','V, S',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 2, Rgr 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: One willing animal of Small, Medium, Large, or Huge size

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

This spell functions like reduce person, except that it affects a single willing animal. Reduce the damage dealt by the animal’s natural attacks as appropriate for its new size.','{"class_levels":{"druid":2,"ranger":3},"source_field_values":{"Level":"Drd 2, Rgr 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"One willing animal of Small, Medium, Large, or Huge size","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_reduce_person','Reduce Person','Sor/Wiz 1',1,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One humanoid creature',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 1

Components: V, S, M

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Target: One humanoid creature

Duration: 1 min./level (D)

Saving Throw: Fortitude negates

Spell Resistance: Yes

This spell causes instant diminution of a humanoid creature, halving its height, length, and width and dividing its weight by 8. This decrease changes the creature’s size category to the next smaller one. The target gains a +2 size bonus to Dexterity, a –2 size penalty to Strength (to a minimum of 1), and a +1 bonus on attack rolls and AC due to its reduced size.

A Small humanoid creature whose size decreases to Tiny has a space of 2-1/2 feet and a natural reach of 0 feet (meaning that it must enter an opponent’s square to attack). A Large humanoid creature whose size decreases to Medium has a space of 5 feet and a natural reach of 5 feet. This spell doesn’t change the target’s speed.

All equipment worn or carried by a creature is similarly reduced by the spell.

Melee and projectile weapons deal less damage. Other magical properties are not affected by this spell. Any reduced item that leaves the reduced creature’s possession (including a projectile or thrown weapon) instantly returns to its normal size. This means that thrown weapons deal their normal damage (projectiles deal damage based on the size of the weapon that fired them).

Multiple magical effects that reduce size do not stack.

Reduce person counters and dispels enlarge person.

Reduce person can be made permanent with a permanency spell.

Material Component: A pinch of powdered iron.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One humanoid creature","Duration":"1 min./level (D)","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_reduce_person_mass','Reduce Person, Mass','Sor/Wiz 4',4,'Transmutation',NULL,'One humanoid creature/level, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 4

Target: One humanoid creature/level, no two of which can be more than 30 ft. apart

This spell functions like reduce person, except that it affects multiple creatures.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Target":"One humanoid creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_refuge','Refuge','Clr 7, Sor/Wiz 9',7,'Conjuration (Teleportation)','Touch','Object touched',NULL,'Permanent until discharged','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Clr 7, Sor/Wiz 9

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Duration: Permanent until discharged

Saving Throw: None

Spell Resistance: No

You create powerful magic in some specially prepared object. This object contains the power to instantly transport its possessor across any distance within the same plane to your abode. Once the item is transmuted, you must give it willingly to a creature and at the same time inform it of a command word to be spoken when the item is used. To make use of the item, the subject speaks the command word at the same time that it rends or breaks the item (a standard action). When this is done, the individual and all objects it is wearing and carrying (to a maximum of the character’s heavy load) are instantly transported to your abode. No other creatures are affected (aside from a familiar that is touching the subject).

You can alter the spell when casting it so that it transports you to within 10 feet of the possessor of the item when it is broken and the command word spoken. You will have a general idea of the location and situation of the item possessor at the time the refuge spell is discharged, but once you decide to alter the spell in this fashion, you have no choice whether or not to be transported.

Material Component: The specially prepared object, whose construction requires gems worth 1,500 gp.','{"class_levels":{"cleric":7,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 7, Sor/Wiz 9","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Duration":"Permanent until discharged","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_regenerate','Regenerate','Clr 7, Drd 9, Healing 7',7,'Conjuration (Healing)','Touch','Living creature touched',NULL,'Instantaneous','V, S, DF',ARRAY['cleric','druid']::text[],'Conjuration (Healing)

Level: Clr 7, Drd 9, Healing 7

Components: V, S, DF

Casting Time: 3 full rounds

Range: Touch

Target: Living creature touched

Duration: Instantaneous

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

The subject’s severed body members (fingers, toes, hands, feet, arms, legs, tails, or even heads of multiheaded creatures), broken bones, and ruined organs grow back. After the spell is cast, the physical regeneration is complete in 1 round if the severed members are present and touching the creature. It takes 2d10 rounds otherwise.

Regenerate also cures 4d8 points of damage +1 point per caster level (maximum +35), rids the subject of exhaustion and/or fatigue, and eliminates all nonlethal damage the subject has taken. It has no effect on nonliving creatures (including undead).','{"class_levels":{"cleric":7,"druid":9},"source_field_values":{"Level":"Clr 7, Drd 9, Healing 7","Components":"V, S, DF","Casting Time":"3 full rounds","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_reincarnate','Reincarnate','Drd 4',4,'Transmutation','Touch','Dead creature touched',NULL,'Instantaneous','V, S, M, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 4

Components: V, S, M, DF

Casting Time: 10 minutes

Range: Touch

Target: Dead creature touched

Duration: Instantaneous

Saving Throw: None; see text

Spell Resistance: Yes (harmless)

With this spell, you bring back a dead creature in another body, provided that its death occurred no more than one week before the casting of the spell and the subject’s soul is free and willing to return. If the subject’s soul is not willing to return, the spell does not work; therefore, a subject that wants to return receives no saving throw.

Since the dead creature is returning in a new body, all physical ills and afflictions are repaired. The condition of the remains is not a factor. So long as some small portion of the creature’s body still exists, it can be reincarnated, but the portion receiving the spell must have been part of the creature’s body at the time of death. The magic of the spell creates an entirely new young adult body for the soul to inhabit from the natural elements at hand. This process takes 1 hour to complete. When the body is ready, the subject is reincarnated.

A reincarnated creature recalls the majority of its former life and form. It retains any class abilities, feats, or skill ranks it formerly possessed. Its class, base attack bonus, base save bonuses, and hit points are unchanged. Strength, Dexterity, and Constitution scores depend partly on the new body. First eliminate the subject’s racial adjustments (since it is no longer of his previous race) and then apply the adjustments found below to its remaining ability scores. The subject’s level (or Hit Dice) is reduced by 1. If the subject was 1st level, its new Constitution score is reduced by 2. (If this reduction would put its Con at 0 or lower, it can’t be reincarnated). This level/HD loss or Constitution loss cannot be repaired by any means.

It’s possible for the change in the subject’s ability scores to make it difficult for it to pursue its previous character class. If this is the case, the subject is well advised to become a multiclass character.

For a humanoid creature, the new incarnation is determined using the following table. For nonhumanoid creatures, a similar table of creatures of the same type should be created.

A creature that has been turned into an undead creature or killed by a death effect can’t be returned to life by this spell. Constructs, elementals, outsiders, and undead creatures can’t be reincarnated. The spell cannot bring back a creature who has died of old age.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>d%</th><th>Incarnation</th><th>Str</th><th>Dex</th><th>Con</th></tr><tr><td>01</td><td>Bugbear</td><td>+4</td><td>+2</td><td>+2</td></tr><tr><td>02–13</td><td>Dwarf</td><td>+0</td><td>+0</td><td>+2</td></tr><tr><td>14–25</td><td>Elf</td><td>+0</td><td>+2</td><td>–2</td></tr><tr><td>26</td><td>Gnoll</td><td>+4</td><td>+0</td><td>+2</td></tr><tr><td>27–38</td><td>Gnome</td><td>–2</td><td>+0</td><td>+2</td></tr><tr><td>39–42</td><td>Goblin</td><td>–2</td><td>+2</td><td>+0</td></tr><tr><td>43–52</td><td>Half-elf</td><td>+0</td><td>+0</td><td>+0</td></tr><tr><td>53–62</td><td>Half-orc</td><td>+2</td><td>+0</td><td>+0</td></tr><tr><td>63–74</td><td>Halfling</td><td>–2</td><td>+2</td><td>+0</td></tr><tr><td>75–89</td><td>Human</td><td>+0</td><td>+0</td><td>+0</td></tr><tr><td>90–93</td><td>Kobold</td><td>–4</td><td>+2</td><td>–2</td></tr><tr><td>94</td><td>Lizardfolk</td><td>+2</td><td>+0</td><td>+2</td></tr><tr><td>95–98</td><td>Orc</td><td>+4</td><td>+0</td><td>+0</td></tr><tr><td>99</td><td>Troglodyte</td><td>+0</td><td>–2</td><td>+4</td></tr><tr><td>100</td><td>Other</td><td>?</td><td>?</td><td>?</td></tr></tbody></table>

The reincarnated creature gains all abilities associated with its new form, including forms of movement and speeds, natural armor, natural attacks, extraordinary abilities, and the like, but it doesn’t automatically speak the language of the new form.

A wish or a miracle spell can restore a reincarnated character to his or her original form.

Material Component: Rare oils and unguents worth a total of least 1,000 gp, spread over the remains.','{"class_levels":{"druid":4},"source_field_values":{"Level":"Drd 4","Components":"V, S, M, DF","Casting Time":"10 minutes","Range":"Touch","Target":"Dead creature touched","Duration":"Instantaneous","Saving Throw":"None; see text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_remove_blindness_deafness','Remove Blindness/Deafness','Clr 3, Pal 3',3,'Conjuration (Healing)','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric','paladin']::text[],'Conjuration (Healing)

Level: Clr 3, Pal 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

Remove blindness/deafness cures blindness or deafness (your choice), whether the effect is normal or magical in nature. The spell does not restore ears or eyes that have been lost, but it repairs them if they are damaged.

Remove blindness/deafness counters and dispels blindness/deafness.','{"class_levels":{"cleric":3,"paladin":3},"source_field_values":{"Level":"Clr 3, Pal 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_remove_curse','Remove Curse','Brd 3, Clr 3, Pal 3, Sor/Wiz 4',3,'Abjuration','Touch','Creature or item touched',NULL,'Instantaneous','V, S',ARRAY['bard','cleric','paladin','sorcerer','wizard']::text[],'Abjuration

Level: Brd 3, Clr 3, Pal 3, Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature or item touched

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

Remove curse instantaneously removes all curses on an object or a creature. Remove curse does not remove the curse from a cursed shield, weapon, or suit of armor, although the spell typically enables the creature afflicted with any such cursed item to remove and get rid of it. Certain special curses may not be countered by this spell or may be countered only by a caster of a certain level or higher.

Remove curse counters and dispels bestow curse.','{"class_levels":{"bard":3,"cleric":3,"paladin":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Clr 3, Pal 3, Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature or item touched","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_remove_disease','Remove Disease','Clr 3, Drd 3, Rgr 3',3,'Conjuration (Healing)','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric','druid','ranger']::text[],'Conjuration (Healing)

Level: Clr 3, Drd 3, Rgr 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

Remove disease cures all diseases that the subject is suffering from. The spell also kills parasites, including green slime and others. Certain special diseases may not be countered by this spell or may be countered only by a caster of a certain level or higher.

Note: Since the spell’s duration is instantaneous, it does not prevent reinfection after a new exposure to the same disease at a later date.','{"class_levels":{"cleric":3,"druid":3,"ranger":3},"source_field_values":{"Level":"Clr 3, Drd 3, Rgr 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_remove_fear','Remove Fear','Brd 1, Clr 1',1,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'10 minutes; see text','V, S',ARRAY['bard','cleric']::text[],'Abjuration

Level: Brd 1, Clr 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature plus one additional creature per four levels, no two of which can be more than 30 ft. apart

Duration: 10 minutes; see text

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

You instill courage in the subject, granting it a +4 morale bonus against fear effects for 10 minutes. If the subject is under the influence of a fear effect when receiving the spell, that effect is suppressed for the duration of the spell.

Remove fear counters and dispels cause fear.','{"class_levels":{"bard":1,"cleric":1},"source_field_values":{"Level":"Brd 1, Clr 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature plus one additional creature per four levels, no two of which can be more than 30 ft. apart","Duration":"10 minutes; see text","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_remove_paralysis','Remove Paralysis','Clr 2, Pal 2',2,'Conjuration (Healing)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Instantaneous','V, S',ARRAY['cleric','paladin']::text[],'Conjuration (Healing)

Level: Clr 2, Pal 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to four creatures, no two of which can be more than 30 ft. apart

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

You can free one or more creatures from the effects of any temporary paralysis or related magic, including a ghoul’s touch or a slow spell. If the spell is cast on one creature, the paralysis is negated. If cast on two creatures, each receives another save with a +4 resistance bonus against the effect that afflicts it. If cast on three or four creatures, each receives another save with a +2 resistance bonus.

The spell does not restore ability scores reduced by penalties, damage, or drain.','{"class_levels":{"cleric":2,"paladin":2},"source_field_values":{"Level":"Clr 2, Pal 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to four creatures, no two of which can be more than 30 ft. apart","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_repel_metal_or_stone','Repel Metal or Stone','Drd 8',8,'Abjuration [Earth]','60 ft.',NULL,'60-ft. line from you','1 round/level (D)','V, S',ARRAY['druid']::text[],'Abjuration \[Earth\]

Level: Drd 8

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: 60-ft. line from you

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: No

Like repel wood, this spell creates waves of invisible and intangible energy that roll forth from you. All metal or stone objects in the path of the spell are pushed away from you to the limit of the range. Fixed metal or stone objects larger than 3 inches in diameter and loose objects weighing more than 500 pounds are not affected. Anything else, including animated objects, small boulders, and creatures in metal armor, moves back. Fixed objects 3 inches in diameter or smaller bend or break, and the pieces move with the wave of energy. Objects affected by the spell are repelled at the rate of 40 feet per round.

Objects such as metal armor, swords, and the like are pushed back, dragging their bearers with them. Even magic items with metal components are repelled, although an antimagic field blocks the effects.

The waves of energy continue to sweep down the set path for the spell’s duration. After you cast the spell, the path is set, and you can then do other things or go elsewhere without affecting the spell’s power.','{"class_levels":{"druid":8},"source_field_values":{"Level":"Drd 8","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"60-ft. line from you","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_repel_vermin','Repel Vermin','Brd 4, Clr 4, Drd 4, Rgr 3',3,'Abjuration','10 ft.',NULL,'10-ft.-radius emanation centered on you','10 min./level (D)','V, S, DF',ARRAY['bard','cleric','druid','ranger']::text[],'Abjuration

Level: Brd 4, Clr 4, Drd 4, Rgr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: 10 ft.

Area: 10-ft.-radius emanation centered on you

Duration: 10 min./level (D)

Saving Throw: None or Will negates; see text

Spell Resistance: Yes

An invisible barrier holds back vermin. A vermin with Hit Dice of less than one-third your level cannot penetrate the barrier.

A vermin with Hit Dice of one-third your level or more can penetrate the barrier if it succeeds on a Will save. Even so, crossing the barrier deals the vermin 2d6 points of damage, and pressing against the barrier causes pain, which deters most vermin.','{"class_levels":{"bard":4,"cleric":4,"druid":4,"ranger":3},"source_field_values":{"Level":"Brd 4, Clr 4, Drd 4, Rgr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"10 ft.","Area":"10-ft.-radius emanation centered on you","Duration":"10 min./level (D)","Saving Throw":"None or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_repel_wood','Repel Wood','Drd 6, Plant 6',6,'Transmutation','60 ft.',NULL,'60-ft. line-shaped emanation from you','1 min./level (D)','V, S',ARRAY['druid']::text[],'Transmutation

Level: Drd 6, Plant 6

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: 60-ft. line-shaped emanation from you

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

Waves of energy roll forth from you, moving in the direction that you determine, causing all wooden objects in the path of the spell to be pushed away from you to the limit of the range. Wooden objects larger than 3 inches in diameter that are fixed firmly are not affected, but loose objects are. Objects 3 inches in diameter or smaller that are fixed in place splinter and break, and the pieces move with the wave of energy. Objects affected by the spell are repelled at the rate of 40 feet per round.

Objects such as wooden shields, spears, wooden weapon shafts and hafts, and arrows and bolts are pushed back, dragging those carrying them along. (A creature being dragged by an item it is carrying can let go. A creature being dragged by a shield can loose it as a move action and drop it as a free action.) If a spear is planted (set) to prevent this forced movement, it splinters. Even magic items with wooden sections are repelled, although an antimagic field blocks the effects.

The waves of energy continue to sweep down the set path for the spell’s duration. After you cast the spell, the path is set, and you can then do other things or go elsewhere without affecting the spell’s power.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6, Plant 6","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"60-ft. line-shaped emanation from you","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_repulsion','Repulsion','Clr 7, Protection 7, Sor/Wiz 6',6,'Abjuration','Up to 10 ft./level',NULL,'Up to 10-ft.-radius/level emanation centered on you','1 round/level (D)','V, S, F/DF',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 7, Protection 7, Sor/Wiz 6

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Up to 10 ft./level

Area: Up to 10-ft.-radius/level emanation centered on you

Duration: 1 round/level (D)

Saving Throw: Will negates

Spell Resistance: Yes

An invisible, mobile field surrounds you and prevents creatures from approaching you. You decide how big the field is at the time of casting (to the limit your level allows). Any creature within or entering the field must attempt a save. If it fails, it becomes unable to move toward you for the duration of the spell. Repelled creatures’ actions are not otherwise restricted.

They can fight other creatures and can cast spells and attack you with ranged weapons. If you move closer to an affected creature, nothing happens. (The creature is not forced back.) The creature is free to make melee attacks against you if you come within reach. If a repelled creature moves away from you and then tries to turn back toward you, it cannot move any closer if it is still within the spell’s area.

Arcane Focus: A pair of small iron bars attached to two small canine statuettes, one black and one white, the whole array worth 50 gp.','{"class_levels":{"cleric":7,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 7, Protection 7, Sor/Wiz 6","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Up to 10 ft./level","Area":"Up to 10-ft.-radius/level emanation centered on you","Duration":"1 round/level (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_resilient_sphere','Resilient Sphere','Sor/Wiz 4',4,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)','1-ft.-diameter/level sphere, centered around a creature',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: 1-ft.-diameter/level sphere, centered around a creature

Duration: 1 min./level (D)

Saving Throw: Reflex negates

Spell Resistance: Yes

A globe of shimmering force encloses a creature, provided the creature is small enough to fit within the diameter of the sphere. The sphere contains its subject for the spell’s duration. The sphere is not subject to damage of any sort except from a rod of cancellation, a rod of negation, a disintegrate spell, or a targeted dispel magic spell. These effects destroy the sphere without harm to the subject. Nothing can pass through the sphere, inside or out, though the subject can breathe normally.

The subject may struggle, but the sphere cannot be physically moved either by people outside it or by the struggles of those within.

Material Component: A hemispherical piece of clear crystal and a matching hemispherical piece of gum arabic.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"1-ft.-diameter/level sphere, centered around a creature","Duration":"1 min./level (D)","Saving Throw":"Reflex negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_resistance','Resistance','Brd 0, Clr 0, Drd 0, Pal 1, Sor/Wiz 0',0,'Abjuration','Touch','Creature touched',NULL,'1 minute','V, S, M/DF',ARRAY['bard','cleric','druid','paladin','sorcerer','wizard']::text[],'Abjuration

Level: Brd 0, Clr 0, Drd 0, Pal 1, Sor/Wiz 0

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 minute

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

You imbue the subject with magical energy that protects it from harm, granting it a +1 resistance bonus on saves.

Resistance can be made permanent with a permanency spell.

Arcane Material Component: A miniature cloak.','{"class_levels":{"bard":0,"cleric":0,"druid":0,"paladin":1,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Clr 0, Drd 0, Pal 1, Sor/Wiz 0","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 minute","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_resist_energy','Resist Energy','Clr 2, Drd 2, Fire 3, Pal 2, Rgr 1, Sor/Wiz 2',1,'Abjuration','Touch','Creature touched',NULL,'10 min./level','V, S, DF',ARRAY['cleric','druid','paladin','ranger','sorcerer','wizard']::text[],'Abjuration

Level: Clr 2, Drd 2, Fire 3, Pal 2, Rgr 1, Sor/Wiz 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

This abjuration grants a creature limited protection from damage of whichever one of five energy types you select: acid, cold, electricity, fire, or sonic. The subject gains energy resistance 10 against the energy type chosen, meaning that each time the creature is subjected to such damage (whether from a natural or magical source), that damage is reduced by 10 points before being applied to the creature’s hit points. The value of the energy resistance granted increases to 20 points at 7th level and to a maximum of 30 points at 11th level. The spell protects the recipient’s equipment as well.

Resist energy absorbs only damage. The subject could still suffer unfortunate side effects.

Note: Resist energy overlaps (and does not stack with) protection from energy. If a character is warded by protection from energy and resist energy, the protection spell absorbs damage until its power is exhausted.','{"class_levels":{"cleric":2,"druid":2,"paladin":2,"ranger":1,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Clr 2, Drd 2, Fire 3, Pal 2, Rgr 1, Sor/Wiz 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_restoration','Restoration','Clr 4, Pal 4',4,'Conjuration (Healing)',NULL,NULL,NULL,NULL,'V, S, M',ARRAY['cleric','paladin']::text[],'Conjuration (Healing)

Level: Clr 4, Pal 4

Components: V, S, M

This spell functions like lesser restoration, except that it also dispels negative levels and restores one experience level to a creature who has had a level drained. The drained level is restored only if the time since the creature lost the level is equal to or less than one day per caster level. A character who has a level restored by*restoration has* exactly the minimum number of experience points necessary to restore him or her to his or her previous level.

Restoration cures all temporary ability damage, and it restores all points permanently drained from a single ability score (your choice if more than one is drained). It also eliminates any fatigue or exhaustion suffered by the target.

Restoration does not restore levels or Constitution points lost due to death.

Material Component: Diamond dust worth 100 gp that is sprinkled over the target.','{"class_levels":{"cleric":4,"paladin":4},"source_field_values":{"Level":"Clr 4, Pal 4","Components":"V, S, M"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_restoration_greater','Restoration, Greater','Clr 7',7,'Conjuration (Healing)',NULL,NULL,NULL,NULL,'V, S, XP',ARRAY['cleric']::text[],'Conjuration (Healing)

Level: Clr 7

Components: V, S, XP

Casting Time: 10 minutes

This spell functions like lesser restoration, except that it dispels all negative levels afflicting the healed creature. This effect also reverses level drains by a force or creature, restoring the creature to the highest level it had previously attained. The drained levels are restored only if the time since the creature lost the level is no more than one week per caster level.

Greater restoration also dispels all magical effects penalizing the creature’s abilities, cures all temporary ability damage, and restores all points permanently drained from all ability scores. It also eliminates fatigue and exhaustion, and removes all forms of insanity, confusion, and similar mental effects. Greater restoration does not restore levels or Constitution points lost due to death.

XP Cost: 500 XP.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7","Components":"V, S, XP","Casting Time":"10 minutes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_restoration_lesser','Restoration, Lesser','Clr 2, Drd 2, Pal 1',1,'Conjuration (Healing)','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric','druid','paladin']::text[],'Conjuration (Healing)

Level: Clr 2, Drd 2, Pal 1

Components: V, S

Casting Time: 3 rounds

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

Lesser restoration dispels any magical effects reducing one of the subject’s ability scores or cures 1d4 points of temporary ability damage to one of the subject’s ability scores. It also eliminates any fatigue suffered by the character, and improves an exhausted condition to fatigued. It does not restore permanent ability drain.','{"class_levels":{"cleric":2,"druid":2,"paladin":1},"source_field_values":{"Level":"Clr 2, Drd 2, Pal 1","Components":"V, S","Casting Time":"3 rounds","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_resurrection','Resurrection','Clr 7',7,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Conjuration (Healing)

Level: Clr 7

Casting Time: 10 minutes

This spell functions like raise dead, except that you are able to restore life and complete strength to any deceased creature.

The condition of the remains is not a factor. So long as some small portion of the creature’s body still exists, it can be resurrected, but the portion receiving the spell must have been part of the creature’s body at the time of death. (The remains of a creature hit by a disintegrate spell count as a small portion of its body.) The creature can have been dead no longer than 10 years per caster level.

Upon completion of the spell, the creature is immediately restored to full hit points, vigor, and health, with no loss of prepared spells. However, the subject loses one level, or 2 points of Constitution if the subject was 1st level. (If this reduction would bring its Con to 0 or lower, it can’t be resurrected). This level loss or Constitution loss cannot be repaired by any means.

You can resurrect someone killed by a death effect or someone who has been turned into an undead creature and then destroyed. You cannot resurrect someone who has died of old age. Constructs, elementals, outsiders, and undead creatures can’t be resurrected.

Material Component: A sprinkle of holy water and diamonds worth a total of at least 10,000 gp.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7","Casting Time":"10 minutes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_reverse_gravity','Reverse Gravity','Drd 8, Sor/Wiz 7',7,'Transmutation','Medium (100 ft. + 10 ft./level)',NULL,'Up to one 10-ft. cube per two levels (S)','1 round/level (D)','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation

Level: Drd 8, Sor/Wiz 7

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Up to one 10-ft. cube per two levels (S)

Duration: 1 round/level (D)

Saving Throw: None; see text

Spell Resistance: No

This spell reverses gravity in an area, causing all unattached objects and creatures within that area to fall upward and reach the top of the area in 1 round. If some solid object (such as a ceiling) is encountered in this fall, falling objects and creatures strike it in the same manner as they would during a normal downward fall. If an object or creature reaches the top of the area without striking anything, it remains there, oscillating slightly, until the spell ends. At the end of the spell duration, affected objects and creatures fall downward.

Provided it has something to hold onto, a creature caught in the area can attempt a Reflex save to secure itself when the spell strikes. Creatures who can fly or levitate can keep themselves from falling.

Arcane Material Component: A lodestone and iron filings.','{"class_levels":{"druid":8,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Drd 8, Sor/Wiz 7","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Up to one 10-ft. cube per two levels (S)","Duration":"1 round/level (D)","Saving Throw":"None; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_righteous_might','Righteous Might','Clr 5, Strength 5',5,'Transmutation','Personal','You',NULL,'1 round/level (D)','V, S, DF',ARRAY['cleric']::text[],'Transmutation

Level: Clr 5, Strength 5

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level (D)

Your height immediately doubles, and your weight increases by a factor of eight. This increase changes your size category to the next larger one, and you gain a +8 size bonus to Strength and a +4 size bonus to Constitution. You gain a +4 enhancement bonus to your natural armor. You gain damage reduction 5/evil (if you normally channel positive energy) or damage reduction 5/good (if you normally channel negative energy). At 12th level this damage reduction becomes 10/evil or 10/good, and at 15th level it becomes 15/evil or 15/good (the maximum). Your size modifier for AC and attacks changes as appropriate to your new size category. This spell doesn’t change your speed. Determine space and reach as appropriate to your new size.

If insufficient room is available for the desired growth, you attain the maximum possible size and may make a Strength check (using your increased Strength) to burst any enclosures in the process. If you fail, you are constrained without harm by the materials enclosing you— the spell cannot crush you by increasing your size.

All equipment you wear or carry is similarly enlarged by the spell. Melee and projectile weapons deal more damage. Other magical properties are not affected by this spell. Any enlarged item that leaves your possession (including a projectile or thrown weapon) instantly returns to its normal size. This means that thrown weapons deal their normal damage (projectiles deal damage based on the size of the weapon that fired them).

Multiple magical effects that increase size do not stack.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5, Strength 5","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_rope_trick','Rope Trick','Sor/Wiz 2',2,'Transmutation','Touch','One touched piece of rope from 5 ft. to 30 ft. long',NULL,'1 hour/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: One touched piece of rope from 5 ft. to 30 ft. long

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

When this spell is cast upon a piece of rope from 5 to 30 feet long, one end of the rope rises into the air until the whole rope hangs perpendicular to the ground, as if affixed at the upper end. The upper end is, in fact, fastened to an extradimensional space that is outside the multiverse of extradimensional spaces (“planes”). Creatures in the extradimensional space are hidden, beyond the reach of spells (including divinations), unless those spells work across planes. The space holds as many as eight creatures (of any size). Creatures in the space can pull the rope up into the space, making the rope “disappear.” In that case, the rope counts as one of the eight creatures that can fit in the space. The rope can support up to 16,000 pounds. A weight greater than that can pull the rope free.

Spells cannot be cast across the extradimensional interface, nor can area effects cross it. Those in the extradimensional space can see out of it as if a 3-foot-by- 5-foot window were centered on the rope. The window is present on the Material Plane, but it’s invisible, and even creatures that can see the window can’t see through it. Anything inside the extradimensional space drops out when the spell ends. The rope can be climbed by only one person at a time. The rope trick spell enables climbers to reach a normal place if they do not climb all the way to the extradimensional space.

Note: It is hazardous to create an extradimensional space within an existing extradimensional space or to take an extradimensional space into an existing one.

Material Component: Powdered corn extract and a twisted loop of parchment.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"One touched piece of rope from 5 ft. to 30 ft. long","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_rusting_grasp','Rusting Grasp','Drd 4',4,'Transmutation','Touch','One nonmagical ferrous object (or the volume of the object within 3 ft. of the touched point) or one ferrous creature',NULL,'See text','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: One nonmagical ferrous object (or the volume of the object within 3 ft. of the touched point) or one ferrous creature

Duration: See text

Saving Throw: None

Spell Resistance: No

Any iron or iron alloy item you touch becomes instantaneously rusted, pitted, and worthless, effectively destroyed. If the item is so large that it cannot fit within a 3-foot radius a 3-foot-radius volume of the metal is rusted and destroyed. Magic items made of metal are immune to this spell.

You may employ rusting grasp in combat with a successful melee touch attack. Rusting grasp used in this way instantaneously destroys 1d6 points of Armor Class gained from metal armor (to the maximum amount of protection the armor offered) through corrosion.

Weapons in use by an opponent targeted by the spell are more difficult to grasp. You must succeed on a melee touch attack against the weapon. A metal weapon that is hit is destroyed.

Note: Striking at an opponent’s weapon provokes an attack of opportunity. Also, you must touch the weapon and not the other way around.

Against a ferrous creature, rusting grasp instantaneously deals 3d6 points of damage +1 per caster level (maximum +15) per successful attack. The spell lasts for 1 round per level, and you can make one melee touch attack per round.','{"class_levels":{"druid":4},"source_field_values":{"Level":"Drd 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"One nonmagical ferrous object (or the volume of the object within 3 ft. of the touched point) or one ferrous creature","Duration":"See text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_sanctuary','Sanctuary','Clr 1, Protection 1',1,'Abjuration','Touch','Creature touched',NULL,'1 round/level','V, S, DF',ARRAY['cleric']::text[],'Abjuration

Level: Clr 1, Protection 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: No

Any opponent attempting to strike or otherwise directly attack the warded creature, even with a targeted spell, must attempt a Will save. If the save succeeds, the opponent can attack normally and is unaffected by that casting of the spell. If the save fails, the opponent can’t follow through with the attack, that part of its action is lost, and it can’t directly attack the warded creature for the duration of the spell. Those not attempting to attack the subject remain unaffected. This spell does not prevent the warded creature from being attacked or affected by area or effect spells. The subject cannot attack without breaking the spell but may use nonattack spells or otherwise act.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1, Protection 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_scare','Scare','Brd 2, Sor/Wiz 2',2,'Necromancy [Fear, Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 round/level or 1 round; see text for _cause fear_','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Necromancy \[Fear, Mind-Affecting\]

Level: Brd 2, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: One living creature per three levels, no two of which can be more than 30 ft. apart

Duration: 1 round/level or 1 round; see text for cause fear

Saving Throw: Will partial

Spell Resistance: Yes

This spell functions like cause fear, except that it causes all targeted creatures of less than 6 HD to become frightened.

Material Component: A bit of bone from an undead skeleton, zombie, ghoul, ghast, or mummy.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One living creature per three levels, no two of which can be more than 30 ft. apart","Duration":"1 round/level or 1 round; see text for _cause fear_","Saving Throw":"Will partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_scintillating_pattern','Scintillating Pattern','Sor/Wiz 8',8,'Illusion (Pattern) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','Colorful lights in a 20-ft.-radius spread',NULL,'Concentration + 2 rounds','V, S, M',ARRAY['sorcerer','wizard']::text[],'Illusion (Pattern) \[Mind-Affecting\]

Level: Sor/Wiz 8

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Colorful lights in a 20-ft.-radius spread

Duration: Concentration + 2 rounds

Saving Throw: None

Spell Resistance: Yes

A twisting pattern of discordant, coruscating colors weaves through the air, affecting creatures within it. The spell affects a total number of Hit Dice of creatures equal to your caster level (maximum 20). Creatures with the fewest HD are affected first; and, among creatures with equal HD, those who are closest to the spell’s point of origin are affected first. Hit Dice that are not sufficient to affect a creature are wasted. The spell affects each subject according to its Hit Dice.

6 or less: Unconscious for 1d4 rounds, then stunned for 1d4 rounds, and then confused for 1d4 rounds. (Treat an unconscious result as stunned for nonliving creatures.)

7 to 12: Stunned for 1d4 rounds, then confused for 1d4 rounds.

13 or more: Confused for 1d4 rounds.

Sightless creatures are not affected by scintillating pattern.

Material Component: A small crystal prism.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Colorful lights in a 20-ft.-radius spread","Duration":"Concentration + 2 rounds","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_scorching_ray','Scorching Ray','Sor/Wiz 2',2,'Evocation [Fire]','Close (25 ft. + 5 ft./2 levels)','One or more rays',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One or more rays

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

You blast your enemies with fiery rays. You may fire one ray, plus one additional ray for every four levels beyond 3rd (to a maximum of three rays at 11th level). Each ray requires a ranged touch attack to hit and deals 4d6 points of fire damage.

The rays may be fired at the same or different targets, but all bolts must be aimed at targets within 30 feet of each other and fired simultaneously.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One or more rays","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_screen','Screen','Sor/Wiz 8, Trickery 7',8,'Illusion (Glamer)','Close (25 ft. + 5 ft./2 levels)',NULL,'30-ft. cube/level (S)','24 hours','V, S',ARRAY['sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Sor/Wiz 8, Trickery 7

Components: V, S

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Area: 30-ft. cube/level (S)

Duration: 24 hours

Saving Throw: None or Will disbelief (if interacted with); see text

Spell Resistance: No

This spell combines several elements to create a powerful protection from scrying and direct observation. When casting the spell, you dictate what will and will not be observed in the spell’s area. The illusion created must be stated in general terms. Once the conditions are set, they cannot be changed.

Attempts to scry the area automatically detect the image stated by you with no save allowed. Sight and sound are appropriate to the illusion created.

Direct observation may allow a save (as per a normal illusion), if there is cause to disbelieve what is seen. Even entering the area does not cancel the illusion or necessarily allow a save, assuming that hidden beings take care to stay out of the way of those affected by the illusion.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8, Trickery 7","Components":"V, S","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"30-ft. cube/level (S)","Duration":"24 hours","Saving Throw":"None or Will disbelief (if interacted with); see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_scrying','Scrying','Brd 3, Clr 5, Drd 4, Sor/Wiz 4',3,'Divination (Scrying)','See text','Magical sensor',NULL,'1 min./level','V, S, M/DF, F',ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Divination (Scrying)

Level: Brd 3, Clr 5, Drd 4, Sor/Wiz 4

Components: V, S, M/DF, F

Casting Time: 1 hour

Range: See text

Effect: Magical sensor

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

You can see and hear some creature, which may be at any distance. If the subject succeeds on a Will save, the scrying attempt simply fails. The difficulty of the save depends on how well you know the subject and what sort of physical connection (if any) you have to that creature. Furthermore, if the subject is on another plane, it gets a +5 bonus on its Will save.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Knowledge</th><th>Will Save Modifier</th></tr><tr><td>None<sup>1</sup></td><td>+10</td></tr><tr><td>Secondhand (you have heard of the subject)</td><td>+5</td></tr><tr><td>Firsthand (you have met the subject)</td><td>+0</td></tr><tr><td>Familiar (you know the subject well)</td><td>–5</td></tr><tr><td colspan="2">1 You must have some sort of connection to a creature you have no knowledge of.</td></tr><tr><th>Connection</th><th>Will Save Modifier</th></tr><tr><td>Likeness or picture</td><td>–2</td></tr><tr><td>Possession or garment</td><td>–4</td></tr><tr><td>Body part, lock of hair, bit of nail, etc.</td><td>–10</td></tr></tbody></table>

If the save fails, you can see and hear the subject and the subject’s immediate surroundings (approximately 10 feet in all directions of the subject). If the subject moves, the sensor follows at a speed of up to 150 feet.

As with all divination (scrying) spells, the sensor has your full visual acuity, including any magical effects. In addition, the following spells have a 5% chance per caster level of operating through the sensor: detect chaos, detect evil, detect good, detect law, detect magic, and message.

If the save succeeds, you can’t attempt to scry on that subject again for at least 24 hours.

Arcane Material Component: The eye of a hawk, an eagle, or a roc, plus nitric acid, copper, and zinc.

Wizard, Sorcerer, or Bard Focus: A mirror of finely wrought and highly polished silver costing not less than 1,000 gp. The mirror must be at least 2 feet by 4 feet.

Cleric Focus: A holy water font costing not less than 100 gp.

Druid Focus: A natural pool of water.','{"class_levels":{"bard":3,"cleric":5,"druid":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Clr 5, Drd 4, Sor/Wiz 4","Components":"V, S, M/DF, F","Casting Time":"1 hour","Range":"See text","Effect":"Magical sensor","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_scrying_greater','Scrying, Greater','Brd 6, Clr 7, Drd 7, Sor/Wiz 7',6,'Divination (Scrying)',NULL,NULL,NULL,'1 hour/level','V, S',ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Divination (Scrying)

Level: Brd 6, Clr 7, Drd 7, Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Duration: 1 hour/level

This spell functions like scrying, except as noted above. Additionally, all of the following spells function reliably through the sensor: detect chaos, detect evil, detect good, detect law, detect magic, message, read magic, and tongues.','{"class_levels":{"bard":6,"cleric":7,"druid":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Brd 6, Clr 7, Drd 7, Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Duration":"1 hour/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sculpt_sound','Sculpt Sound','Brd 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 hour/level (D)','V, S',ARRAY['bard']::text[],'Transmutation

Level: Brd 3

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature or object/level, no two of which can be more than 30 ft. apart

Duration: 1 hour/level (D)

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You change the sounds that creatures or objects make. You can create sounds where none exist, deaden sounds, or transform sounds into other sounds. All affected creatures or objects must be transmuted in the same way. Once the transmutation is made, you cannot change it.

You can change the qualities of sounds but cannot create words with which you are unfamiliar yourself.

A spellcaster whose voice is changed dramatically is unable to cast spells with verbal components.','{"class_levels":{"bard":3},"source_field_values":{"Level":"Brd 3","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature or object/level, no two of which can be more than 30 ft. apart","Duration":"1 hour/level (D)","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_searing_light','Searing Light','Clr 3, Sun 3',3,'Evocation','Medium (100 ft. + 10 ft./level)','Ray',NULL,'Instantaneous','V, S',ARRAY['cleric']::text[],'Evocation

Level: Clr 3, Sun 3

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Ray

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

Focusing divine power like a ray of the sun, you project a blast of light from your open palm. You must succeed on a ranged touch attack to strike your target. A creature struck by this ray of light takes 1d8 points of damage per two caster levels (maximum 5d8). An undead creature takes 1d6 points of damage per caster level (maximum 10d6), and an undead creature particularly vulnerable to bright light takes 1d8 points of damage per caster level (maximum 10d8). A construct or inanimate object takes only 1d6 points of damage per two caster levels (maximum 5d6).','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3, Sun 3","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Ray","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_secret_chest','Secret Chest','Sor/Wiz 5',5,'Conjuration (Summoning)','See text','One chest and up to 1 cu. ft. of goods/caster level',NULL,'Sixty days or until discharged','V, S, F',ARRAY['sorcerer','wizard']::text[],'Conjuration (Summoning)

Level: Sor/Wiz 5

Components: V, S, F

Casting Time: 10 minutes

Range: See text

Target: One chest and up to 1 cu. ft. of goods/caster level

Duration: Sixty days or until discharged

Saving Throw: None

Spell Resistance: No

You hide a chest on the Ethereal Plane for as long as sixty days and can retrieve it at will. The chest can contain up to 1 cubic foot of material per caster level (regardless of the chest’s actual size, which is about 3 feet by 2 feet by 2 feet). If any living creatures are in the chest, there is a 75% chance that the spell simply fails. Once the chest is hidden, you can retrieve it by concentrating (a standard action), and it appears next to you.

The chest must be exceptionally well crafted and expensive, constructed for you by master crafters. The cost of such a chest is never less than 5,000 gp. Once it is constructed, you must make a tiny replica (of the same materials and perfect in every detail), so that the miniature of the chest appears to be a perfect copy. (The replica costs 50 gp.) You can have but one pair of these chests at any given time—even a wish spell does not allow more. The chests are nonmagical and can be fitted with locks, wards, and so on, just as any normal chest can be.

To hide the chest, you cast the spell while touching both the chest and the replica. The chest vanishes into the Ethereal Plane. You need the replica to recall the chest. After sixty days, there is a cumulative chance of 5% per day that the chest is irretrievably lost. If the miniature of the chest is lost or destroyed, there is no way, not even with a wish spell, that the large chest can be summoned back, although an extraplanar expedition might be mounted to find it.

Living things in the chest eat, sleep, and age normally, and they die if they run out of food, air, water, or whatever they need to survive.

Focus: The chest and its replica.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, F","Casting Time":"10 minutes","Range":"See text","Target":"One chest and up to 1 cu. ft. of goods/caster level","Duration":"Sixty days or until discharged","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
