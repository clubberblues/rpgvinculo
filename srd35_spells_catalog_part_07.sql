-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_secret_page','Secret Page','Brd 3, Sor/Wiz 3',3,'Transmutation','Touch','Page touched, up to 3 sq. ft. in size',NULL,'Permanent','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 10 minutes

Range: Touch

Target: Page touched, up to 3 sq. ft. in size

Duration: Permanent

Saving Throw: None

Spell Resistance: No

Secret page alters the contents of a page so that they appear to be something entirely different. The text of a spell can be changed to show even another spell. Explosive runes or sepia snake sigil can be cast upon the secret page.

A comprehend languages spell alone cannot reveal a secret page’s contents. You are able to reveal the original contents by speaking a special word. You can then peruse the actual page, and return it to its secret page form at will. You can also remove the spell by double repetition of the special word. A detect magic spell reveals dim magic on the page in question but does not reveal its true contents.True seeing reveals the presence of the hidden material but does not reveal the contents unless cast in combination with comprehend languages. A secret page spell can be dispelled, and the hidden writings can be destroyed by means of an erase spell.

Material Component: Powdered herring scales and will-o’-wisp essence.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"10 minutes","Range":"Touch","Target":"Page touched, up to 3 sq. ft. in size","Duration":"Permanent","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_secure_shelter','Secure Shelter','Brd 4, Sor/Wiz 4',4,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)','20-ft.-square structure',NULL,'2 hours/level (D)','V, S, M, F; see text',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Brd 4, Sor/Wiz 4

Components: V, S, M, F; see text

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Effect: 20-ft.-square structure

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

You conjure a sturdy cottage or lodge made of material that is common in the area where the spell is cast. The floor is level, clean, and dry. In all respects the lodging resembles a normal cottage, with a sturdy door, two shuttered windows, and a small fireplace.

The shelter has no heating or cooling source (other than natural insulation qualities). Therefore, it must be heated as a normal dwelling, and extreme heat adversely affects it and its occupants. The dwelling does, however, provide considerable security otherwise—it is as strong as a normal stone building, regardless of its material composition. The dwelling resists flames and fire as if it were stone. It is impervious to normal missiles (but not the sort cast by siege engines or giants).

The door, shutters, and even chimney are secure against intrusion, the former two being arcane locked and the latter secured by an iron grate at the top and a narrow flue. In addition, these three areas are protected by an alarm spell. Finally, an unseen servant is conjured to provide service to you for the duration of the shelter.

The secure shelter contains rude furnishings —eight bunks, a trestle table, eight stools, and a writing desk.

Material Component: A square chip of stone, crushed lime, a few grains of sand, a sprinkling of water, and several splinters of wood. These must be augmented by the components of the unseen servant spell (string and a bit of wood) if this benefit is to be included.

Focus: The focus of the alarm spell (silver wire and a tiny bell) if this benefit is to be included.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S, M, F; see text","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"20-ft.-square structure","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_see_invisibility','See Invisibility','Brd 3, Sor/Wiz 2',2,'Divination','Personal','You',NULL,'10 min./level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 3, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level (D)

You can see any objects or beings that are invisible within your range of vision, as well as any that are ethereal, as if they were normally visible. Such creatures are visible to you as translucent shapes, allowing you easily to discern the difference between visible, invisible, and ethereal creatures.

The spell does not reveal the method used to obtain invisibility. It does not reveal illusions or enable you to see through opaque objects. It does not reveal creatures who are simply hiding, concealed, or otherwise hard to see.

See invisibility can be made permanent with a permanency spell.

Material Component: A pinch of talc and a small sprinkling of powdered silver.','{"class_levels":{"bard":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 3, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_seeming','Seeming','Brd 5, Sor/Wiz 5',5,'Illusion (Glamer)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'12 hours (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature per two levels, no two of which can be more than 30 ft. apart

Duration: 12 hours (D)

Saving Throw: Will negates or Will disbelief (if interacted with)

Spell Resistance: Yes or No; see text

This spell functions like disguise self, except that you can change the appearance of other people as well. Affected creatures resume their normal appearances if slain.

Unwilling targets can negate the spell’s effect on them by making Will saves or with spell resistance.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature per two levels, no two of which can be more than 30 ft. apart","Duration":"12 hours (D)","Saving Throw":"Will negates or Will disbelief (if interacted with)","Spell Resistance":"Yes or No; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sending','Sending','Clr 4, Sor/Wiz 5',4,'Evocation','See text','One creature',NULL,'1 round; see text','V, S, M/DF',ARRAY['cleric','sorcerer','wizard']::text[],'Evocation

Level: Clr 4, Sor/Wiz 5

Components: V, S, M/DF

Casting Time: 10 minutes

Range: See text

Target: One creature

Duration: 1 round; see text

Saving Throw: None

Spell Resistance: No

You contact a particular creature with which you are familiar and send a short message of twenty-five words or less to the subject. The subject recognizes you if it knows you. It can answer in like manner immediately. A creature with an Intelligence score as low as 1 can understand the sending, though the subject’s ability to react is limited as normal by its Intelligence score. Even if the sending is received, the subject is not obligated to act upon it in any manner.

If the creature in question is not on the same plane of existence as you are, there is a 5% chance that the sending does not arrive. (Local conditions on other planes may worsen this chance considerably.)

Arcane Material Component: A short piece of fine copper wire.','{"class_levels":{"cleric":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Clr 4, Sor/Wiz 5","Components":"V, S, M/DF","Casting Time":"10 minutes","Range":"See text","Target":"One creature","Duration":"1 round; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sepia_snake_sigil','Sepia Snake Sigil','Brd 3, Sor/Wiz 3',3,'Conjuration (Creation) [Force]','Touch','One touched book or written work',NULL,'Permanent or until discharged; until released or 1d4 days + one day/level; see text','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation) \[Force\]

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 10 minutes

Range: Touch

Target: One touched book or written work

Duration: Permanent or until discharged; until released or 1d4 days + one day/level; see text

Saving Throw: Reflex negates

Spell Resistance: No

When you cast sepia snake sigil, a small symbol appears in the text of one written work such as a book, scroll, or map. The text containing the symbol must be at least twenty-five words long. When anyone reads the text containing the symbol, the sepia snake springs into being and strikes the reader, provided there is line of effect between the symbol and the reader.

Simply seeing the enspelled text is not sufficient to trigger the spell; the subject must deliberately read it. The target is entitled to a save to evade the snake’s strike. If it succeeds, the sepia snake dissipates in a flash of brown light accompanied by a puff of dun-colored smoke and a loud noise. If the target fails its save, it is engulfed in a shimmering amber field of force and immobilized until released, either at your command or when 1d4 days + one day per caster level have elapsed.

While trapped in the amber field of force, the subject does not age, breathe, grow hungry, sleep, or regain spells. It is preserved in a state of suspended animation, unaware of its surroundings. It can be damaged by outside forces (and perhaps even killed), since the field provides no protection against physical injury. However, a dying subject does not lose hit points or become stable until the spell ends.

The hidden sigil cannot be detected by normal observation, and detect magic reveals only that the entire text is magical.

A dispel magic can remove the sigil. An erase spell destroys the entire page of text.

Sepia snake sigil can be cast in combination with other spells that hide or garble text, such as secret page.

Material Component: 500 gp worth of powdered amber, a scale from any snake, and a pinch of mushroom spores.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"10 minutes","Range":"Touch","Target":"One touched book or written work","Duration":"Permanent or until discharged; until released or 1d4 days + one day/level; see text","Saving Throw":"Reflex negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sequester','Sequester','Sor/Wiz 7',7,'Abjuration','Touch','One willing creature or object (up to a 2-ft. cube/level) touched',NULL,'One day/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 7

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: One willing creature or object (up to a 2-ft. cube/level) touched

Duration: One day/level (D)

Saving Throw: None or Will negates (object)

Spell Resistance: No or Yes (object)

When cast, this spell not only prevents divination spells from working to detect or locate the creature or object affected by sequester, it also renders the affected creature or object invisible to any form of sight or seeing (as the invisibility spell). The spell does not prevent the subject from being discovered through tactile means or through the use of devices. Creatures affected by sequester become comatose and are effectively in a state of suspended animation until the spell wears off or is dispelled.

Note: The Will save prevents an attended or magical object from being sequestered. There is no save to see the sequestered creature or object or to detect it with a divination spell.

Material Component: A basilisk eyelash, gum arabic, and a dram of whitewash.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"One willing creature or object (up to a 2-ft. cube/level) touched","Duration":"One day/level (D)","Saving Throw":"None or Will negates (object)","Spell Resistance":"No or Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shades','Shades','Sor/Wiz 9',9,'Illusion (Shadow)',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Sor/Wiz 9

This spell functions like shadow conjuration, except that it mimics sorcerer and wizard conjuration spells of 8th level or lower. The illusory conjurations created deal four-fifths (80%) damage to nonbelievers, and nondamaging effects are 80% likely to work against nonbelievers.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shadow_conjuration','Shadow Conjuration','Brd 4, Sor/Wiz 4',4,'Illusion (Shadow)','See text','See text',NULL,'See text','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Brd 4, Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: See text

Effect: See text

Duration: See text

Saving Throw: Will disbelief (if interacted with); varies; see text

Spell Resistance: Yes; see text

You use material from the Plane of Shadow to shape quasi-real illusions of one or more creatures, objects, or forces. Shadow conjuration can mimic any sorcerer or wizard conjuration (summoning) or conjuration (creation) spell of 3rd level or lower.

Shadow conjurations are actually one-fifth (20%) as strong as the real things, though creatures who believe the shadow conjurations to be real are affected by them at full strength.

Any creature that interacts with the conjured object, force, or creature can make a Will save to recognize its true nature.

Spells that deal damage have normal effects unless the affected creature succeeds on a Will save. Each disbelieving creature takes only one-fifth (20%) damage from the attack. If the disbelieved attack has a special effect other than damage, that effect is only 20% likely to occur. Regardless of the result of the save to disbelieve, an affected creature is also allowed any save that the spell being simulated allows, but the save DC is set according to shadow conjuration’s level (4th) rather than the spell’s normal level. In addition, any effect created by shadow conjuration allows spell resistance, even if the spell it is simulating does not. Shadow objects or substances have normal effects except against those who disbelieve them.

Against disbelievers, they are 20% likely to work.

A shadow creature has one-fifth the hit points of a normal creature of its kind (regardless of whether it’s recognized as shadowy). It deals normal damage and has all normal abilities and weaknesses. Against a creature that recognizes it as a shadow creature, however, the shadow creature’s damage is one-fifth (20%) normal, and all special abilities that do not deal lethal damage are only 20% likely to work. (Roll for each use and each affected character separately.) Furthermore, the shadow creature’s AC bonuses are one-fifth as large.

A creature that succeeds on its save sees the shadow conjurations as transparent images superimposed on vague, shadowy forms.

Objects automatically succeed on their Will saves against this spell.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"See text","Effect":"See text","Duration":"See text","Saving Throw":"Will disbelief (if interacted with); varies; see text","Spell Resistance":"Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shadow_conjuration_greater','Shadow Conjuration, Greater','Sor/Wiz 7',7,'Illusion (Shadow)',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Sor/Wiz 7

This spell functions like shadow conjuration, except that it can duplicate any sorcerer or wizard conjuration (summoning) or conjuration (creation) spell of 6th level or lower. The illusory conjurations created deal three-fifths (60%) damage to nonbelievers, and nondamaging effects are 60% likely to work against nonbelievers.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shadow_evocation','Shadow Evocation','Brd 5, Sor/Wiz 5',5,'Illusion (Shadow)','See text','See text',NULL,'See text','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: See text

Effect: See text

Duration: See text

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: Yes

You tap energy from the Plane of Shadow to cast a quasi-real, illusory version of a sorcerer or wizard evocation spell of 4th level or lower. (For a spell with more than one level, use the best one applicable to you.)

Spells that deal damage have normal effects unless an affected creature succeeds on a Will save. Each disbelieving creature takes only one-fifth damage from the attack. If the disbelieved attack has a special effect other than damage, that effect is one-fifth as strong (if applicable) or only 20% likely to occur. If recognized as a shadow evocation, a damaging spell deals only one-fifth (20%) damage. Regardless of the result of the save to disbelieve, an affected creature is also allowed any save (or spell resistance) that the spell being simulated allows, but the save DC is set according to \_shadow evocation’s_level (5th) rather than the spell’s normal level.

Nondamaging effects have normal effects except against those who disbelieve them. Against disbelievers, they have no effect.

Objects automatically succeed on their Will saves against this spell.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"See text","Effect":"See text","Duration":"See text","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shadow_evocation_greater','Shadow Evocation, Greater','Sor/Wiz 8',8,'Illusion (Shadow)',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Sor/Wiz 8

This spell functions like shadow evocation, except that it enables you to create partially real, illusory versions of sorcerer or wizard evocation spells of 7th level or lower. If recognized as a greater shadow evocation, a damaging spell deals only three-fifths (60%) damage.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shadow_walk','Shadow Walk','Brd 5, Sor/Wiz 6',5,'Illusion (Shadow)','Touch',NULL,NULL,'1 hour/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Brd 5, Sor/Wiz 6

Components: V, S

Casting Time: 1 standard action

Range: Touch

Targets: Up to one touched creature/ level

Duration: 1 hour/level (D)

Saving Throw: Will negates

Spell Resistance: Yes

To use the shadow walk spell, you must be in an area of shadowy illumination. You and any creature you touch are then transported along a coiling path of shadowstuff to the edge of the Material Plane where it borders the Plane of Shadow. The effect is largely illusory, but the path is quasi-real. You can take more than one creature along with you (subject to your level limit), but all must be touching each other.

In the region of shadow, you move at a rate of 50 miles per hour, moving normally on the borders of the Plane of Shadow but much more rapidly relative to the Material Plane. Thus, you can use this spell to travel rapidly by stepping onto the Plane of Shadow, moving the desired distance, and then stepping back onto the Material Plane.

Because of the blurring of reality between the Plane of Shadow and the Material Plane, you can’t make out details of the terrain or areas you pass over during transit, nor can you predict perfectly where your travel will end. It’s impossible to judge distances accurately, making the spell virtually useless for scouting or spying. Furthermore, when the spell effect ends, you are shunted 1d10x100 feet in a random horizontal direction from your desired endpoint. If this would place you within a solid object, you are shunted 1d10x1,000 feet in the same direction. If this would still place you within a solid object, you (and any creatures with you) are shunted to the nearest empty space available, but the strain of this activity renders each creature fatigued (no save).

Shadow walk can also be used to travel to other planes that border on the Plane of Shadow, but this usage requires the transit of the Plane of Shadow to arrive at a border with another plane of reality. The transit of the Plane of Shadow requires 1d4 hours.

Any creatures touched by you when shadow walk is cast also make the transition to the borders of the Plane of Shadow.

They may opt to follow you, wander off through the plane, or stumble back into the Material Plane (50% chance for either of the latter results if they are lost or abandoned by you). Creatures unwilling to accompany you into the Plane of Shadow receive a Will saving throw, negating the effect if successful.','{"class_levels":{"bard":5,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 5, Sor/Wiz 6","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Targets":"Up to one touched creature/ level","Duration":"1 hour/level (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shambler','Shambler','Drd 9, Plant 9',9,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Three or more shambling mounds, no two of which can be more than 30 ft. apart; see text',NULL,'Seven days or seven months (D); see text','V, S',ARRAY['druid']::text[],'Conjuration (Creation)

Level: Drd 9, Plant 9

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Three or more shambling mounds, no two of which can be more than 30 ft. apart; see text

Duration: Seven days or seven months (D); see text

Saving Throw: None

Spell Resistance: No

The shambler spell creates 1d4+2 shambling mounds with 11 HD each. The creatures willingly aid you in combat or battle, perform a specific mission, or serve as bodyguards. The creatures remain with you for seven days unless you dismiss them. If the shamblers are created only for guard duty, however, the duration of the spell is seven months. In this case, the shamblers can only be ordered to guard a specific site or location. Shamblers summoned to guard duty cannot move outside the spell’s range, which is measured from the point where each first appeared.

The shamblers have resistance to fire as normal shambling mounds do only if the terrain is rainy, marshy, or damp.','{"class_levels":{"druid":9},"source_field_values":{"Level":"Drd 9, Plant 9","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Three or more shambling mounds, no two of which can be more than 30 ft. apart; see text","Duration":"Seven days or seven months (D); see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shapechange','Shapechange','Animal 9, Drd 9, Sor/Wiz 9',9,'Transmutation','Personal','You',NULL,'10 min./level (D)','V, S, F',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation

Level: Animal 9, Drd 9, Sor/Wiz 9

Components: V, S, F

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level (D)

This spell functions like polymorph, except that it enables you to assume the form of any single nonunique creature (of any type) from Fine to Colossal size. The assumed form cannot have more than your caster level in Hit Dice (to a maximum of 25 HD). Unlike polymorph, this spell allows incorporeal or gaseous forms to be assumed.

You gain all extraordinary and supernatural abilities (both attacks and qualities) of the assumed form, but you lose your own supernatural abilities. You also gain the type of the new form in place of your own. The new form does not disorient you. Parts of your body or pieces of equipment that are separated from you do not revert to their original forms.

You can become just about anything you are familiar with. You can change form once each round as a free action. The change takes place either immediately before your regular action or immediately after it, but not during the action. If you use this spell to create a disguise, you get a +10 bonus on your Disguise check.

Focus: A jade circlet worth no less than 1,500 gp, which you must place on your head when casting the spell. (The focus melds into your new form when you change shape.)','{"class_levels":{"druid":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Animal 9, Drd 9, Sor/Wiz 9","Components":"V, S, F","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shatter','Shatter','Brd 2, Chaos 2, Clr 2, Destruction 2, Sor/Wiz 2',2,'Evocation [Sonic]','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Instantaneous','V, S, M/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Evocation \[Sonic\]

Level: Brd 2, Chaos 2, Clr 2, Destruction 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area or Target: 5-ft.-radius spread; or one solid object or one crystalline creature

Duration: Instantaneous

Saving Throw: Will negates (object); Will negates (object) or Fortitude half; see text

Spell Resistance: Yes (object)

Shatter creates a loud, ringing noise that breaks brittle, nonmagical objects; sunders a single solid, nonmagical object; or damages a crystalline creature.

Used as an area attack, shatter destroys nonmagical objects of crystal, glass, ceramic, or porcelain. All such objects within a 5-foot radius of the point of origin are smashed into dozens of pieces by the spell. Objects weighing more than 1 pound per your level are not affected, but all other objects of the appropriate composition are shattered.

Alternatively, you can target shatter against a single solid object, regardless of composition, weighing up to 10 pounds per caster level. Targeted against a crystalline creature (of any weight), shatter deals 1d6 points of sonic damage per caster level (maximum 10d6), with a Fortitude save for half damage.

Arcane Material Component: A chip of mica.','{"class_levels":{"bard":2,"cleric":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Chaos 2, Clr 2, Destruction 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area or Target":"5-ft.-radius spread; or one solid object or one crystalline creature","Duration":"Instantaneous","Saving Throw":"Will negates (object); Will negates (object) or Fortitude half; see text","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_shield','Shield','Sor/Wiz 1',1,'Abjuration [Force]','Personal','You',NULL,'1 min./level (D)','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration \[Force\]

Level: Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

Shield creates an invisible, tower shield-sized mobile disk of force that hovers in front of you. It negates magic missile attacks directed at you. The disk also provides a +4 shield bonus to AC. This bonus applies against incorporeal touch attacks, since it is a force effect. The shield has no armor check penalty or arcane spell failure chance. Unlike with a normal tower shield, you can’t use the shield spell for cover.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shield_of_faith','Shield of Faith','Clr 1',1,'Abjuration','Touch','Creature touched',NULL,'1 min./level','V, S, M',ARRAY['cleric']::text[],'Abjuration

Level: Clr 1

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell creates a shimmering, magical field around the touched creature that averts attacks. The spell grants the subject a +2 deflection bonus to AC, with an additional +1 to the bonus for every six levels you have (maximum +5 deflection bonus at 18th level).

Material Component: A small parchment with a bit of holy text written upon it.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shield_of_law','Shield of Law','Clr 8, Law 8',8,'Abjuration [Lawful]','20 ft.',NULL,NULL,'1 round/level (D)','V, S, F',ARRAY['cleric']::text[],'Abjuration \[Lawful\]

Level: Clr 8, Law 8

Components: V, S, F

Casting Time: 1 standard action

Range: 20 ft.

Targets: One creature/level in a 20-ft.-radius burst centered on you

Duration: 1 round/level (D)

Saving Throw: See text

Spell Resistance: Yes (harmless)

A dim, blue glow surrounds the subjects, protecting them from attacks, granting them resistance to spells cast by chaotic creatures, and slowing chaotic creatures when they strike the subjects. This abjuration has four effects.

First, each warded creature gains a +4 deflection bonus to AC and a +4 resistance bonus on saves. Unlike protection from chaos, this benefit applies against all attacks, not just against attacks by chaotic creatures.

Second, a warded creature gains spell resistance 25 against chaotic spells and spells cast by chaotic creatures.

Third, the abjuration blocks possession and mental influence, just as protection from chaos does.

Finally, if a chaotic creature succeeds on a melee attack against a warded creature, the attacker is slowed (Will save negates, as the slow spell, but against shield of law’s save DC).

Focus: A tiny reliquary containing some sacred relic, such as a scrap of parchment from a lawful text. The reliquary costs at least 500 gp.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8, Law 8","Components":"V, S, F","Casting Time":"1 standard action","Range":"20 ft.","Targets":"One creature/level in a 20-ft.-radius burst centered on you","Duration":"1 round/level (D)","Saving Throw":"See text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shield_other','Shield Other','Clr 2, Pal 2, Protection 2',2,'Abjuration','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'1 hour/level (D)','V, S, F',ARRAY['cleric','paladin']::text[],'Abjuration

Level: Clr 2, Pal 2, Protection 2

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: 1 hour/level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell wards the subject and creates a mystic connection between you and the subject so that some of its wounds are transferred to you. The subject gains a +1 deflection bonus to AC and a +1 resistance bonus on saves. Additionally, the subject takes only half damage from all wounds and attacks (including that dealt by special abilities) that deal hit point damage. The amount of damage not taken by the warded creature is taken by you. Forms of harm that do not involve hit points, such as charm effects, temporary ability damage, level draining, and death effects, are not affected. If the subject suffers a reduction of hit points from a lowered Constitution score, the reduction is not split with you because it is not hit point damage. When the spell ends, subsequent damage is no longer divided between the subject and you, but damage already split is not reassigned to the subject.

If you and the subject of the spell move out of range of each other, the spell ends.

Focus: A pair of platinum rings (worth at least 50 gp each) worn by both you and the warded creature.','{"class_levels":{"cleric":2,"paladin":2},"source_field_values":{"Level":"Clr 2, Pal 2, Protection 2","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"1 hour/level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shillelagh','Shillelagh','Drd 1',1,'Transmutation','Touch','One touched nonmagical oak club or quarterstaff',NULL,'1 min./level','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: One touched nonmagical oak club or quarterstaff

Duration: 1 min./level

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

Your own nonmagical club or quarterstaff becomes a weapon with a +1 enhancement bonus on attack and damage rolls. (A quarterstaff gains this enhancement for both ends of the weapon.) It deals damage as if it were two size categories larger (a Small club or quarterstaff so transmuted deals 1d8 points of damage, a Medium 2d6, and a Large 3d6), +1 for its enhancement bonus. These effects only occur when the weapon is wielded by you. If you do not wield it, the weapon behaves as if unaffected by this spell.','{"class_levels":{"druid":1},"source_field_values":{"Level":"Drd 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"One touched nonmagical oak club or quarterstaff","Duration":"1 min./level","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shocking_grasp','Shocking Grasp','Sor/Wiz 1',1,'Evocation [Electricity]','Touch','Creature or object touched',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Electricity\]

Level: Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature or object touched

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

Your successful melee touch attack deals 1d6 points of electricity damage per caster level (maximum 5d6). When delivering the jolt, you gain a +3 bonus on attack rolls if the opponent is wearing metal armor (or made out of metal, carrying a lot of metal, or the like).','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature or object touched","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shout','Shout','Brd 4, Sor/Wiz 4',4,'Evocation [Sonic]','30 ft.',NULL,'Cone-shaped burst','Instantaneous','V',ARRAY['bard','sorcerer','wizard']::text[],'Evocation \[Sonic\]

Level: Brd 4, Sor/Wiz 4

Components: V

Casting Time: 1 standard action

Range: 30 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: Fortitude partial or Reflex negates (object); see text

Spell Resistance: Yes (object)

You emit an ear-splitting yell that deafens and damages creatures in its path. Any creature within the area is deafened for 2d6 rounds and takes 5d6 points of sonic damage. A successful save negates the deafness and reduces the damage by half. Any exposed brittle or crystalline object or crystalline creature takes 1d6 points of sonic damage per caster level (maximum 15d6). An affected creature is allowed a Fortitude save to reduce the damage by half, and a creature holding fragile objects can negate damage to them with a successful Reflex save.

A shout spell cannot penetrate a silence spell.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V","Casting Time":"1 standard action","Range":"30 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"Fortitude partial or Reflex negates (object); see text","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shout_greater','Shout, Greater','Brd 6, Sor/Wiz 8',6,'Evocation [Sonic]','60 ft.',NULL,NULL,NULL,'V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Evocation \[Sonic\]

Level: Brd 6, Sor/Wiz 8

Components: V, S, F

Range: 60 ft.

Saving Throw: Fortitude partial or Reflex negates (object); see text

This spell functions like shout, except that the cone deals 10d6 points of sonic damage (or 1d6 points of sonic damage per caster level, maximum 20d6, against exposed brittle or crystalline objects or crystalline creatures). It also causes creatures to be stunned for 1 round and deafened for 4d6 rounds. A creature in the area of the cone can negate the stunning and halve both the damage and the duration of the deafness with a successful Fortitude save. A creature holding vulnerable objects can attempt a Reflex save to negate the damage to those objects.

Arcane Focus: A small metal or ivory horn.','{"class_levels":{"bard":6,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Brd 6, Sor/Wiz 8","Components":"V, S, F","Range":"60 ft.","Saving Throw":"Fortitude partial or Reflex negates (object); see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_shrink_item','Shrink Item','Sor/Wiz 3',3,'Transmutation','Touch','One touched object of up to 2 cu. ft./level',NULL,'One day/level; see text','V, S',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: One touched object of up to 2 cu. ft./level

Duration: One day/level; see text

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You are able to shrink one nonmagical item (if it is within the size limit) to 1/16 of its normal size in each dimension (to about 1/4,000 the original volume and mass). This change effectively reduces the object’s size by four categories. Optionally, you can also change its now shrunken composition to a clothlike one. Objects changed by a shrink item spell can be returned to normal composition and size merely by tossing them onto any solid surface or by a word of command from the original caster. Even a burning fire and its fuel can be shrunk by this spell. Restoring the shrunken object to its normal size and composition ends the spell.

Shrink item can be made permanent with a permanency spell, in which case the affected object can be shrunk and expanded an indefinite number of times, but only by the original caster.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"One touched object of up to 2 cu. ft./level","Duration":"One day/level; see text","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_silence','Silence','Brd 2, Clr 2',2,'Illusion (Glamer)','Long (400 ft. + 40 ft./level)',NULL,'20-ft.-radius emanation centered on a creature, object, or point in space','1 min./level (D)','V, S',ARRAY['bard','cleric']::text[],'Illusion (Glamer)

Level: Brd 2, Clr 2

Components: V, S

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: 20-ft.-radius emanation centered on a creature, object, or point in space

Duration: 1 min./level (D)

Saving Throw: Will negates; see text or none (object)

Spell Resistance: Yes; see text or no (object)

Upon the casting of this spell, complete silence prevails in the affected area. All sound is stopped: Conversation is impossible, spells with verbal components cannot be cast, and no noise whatsoever issues from, enters, or passes through the area. The spell can be cast on a point in space, but the effect is stationary unless cast on a mobile object. The spell can be centered on a creature, and the effect then radiates from the creature and moves as it moves. An unwilling creature can attempt a Will save to negate the spell and can use spell resistance, if any. Items in a creature’s possession or magic items that emit sound receive the benefits of saves and spell resistance, but unattended objects and points in space do not. This spell provides a defense against sonic or language-based attacks.','{"class_levels":{"bard":2,"cleric":2},"source_field_values":{"Level":"Brd 2, Clr 2","Components":"V, S","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"20-ft.-radius emanation centered on a creature, object, or point in space","Duration":"1 min./level (D)","Saving Throw":"Will negates; see text or none (object)","Spell Resistance":"Yes; see text or no (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_silent_image','Silent Image','Brd 1, Sor/Wiz 1',1,'Illusion (Figment)','Long (400 ft. + 40 ft./level)','Visual figment that cannot extend beyond four 10-ft. cubes + one 10-ft. cube/level (S)',NULL,'Concentration','V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 1, Sor/Wiz 1

Components: V, S, F

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Effect: Visual figment that cannot extend beyond four 10-ft. cubes + one 10-ft. cube/level (S)

Duration: Concentration

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

This spell creates the visual illusion of an object, creature, or force, as visualized by you. The illusion does not create sound, smell, texture, or temperature. You can move the image within the limits of the size of the effect.

Focus: A bit of fleece.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S, F","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Effect":"Visual figment that cannot extend beyond four 10-ft. cubes + one 10-ft. cube/level (S)","Duration":"Concentration","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_simulacrum','Simulacrum','Sor/Wiz 7',7,'Illusion (Shadow)','0 ft.','One duplicate creature',NULL,'Instantaneous','V, S, M, XP',ARRAY['sorcerer','wizard']::text[],'Illusion (Shadow)

Level: Sor/Wiz 7

Components: V, S, M, XP

Casting Time: 12 hours

Range: 0 ft.

Effect: One duplicate creature

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

Simulacrum creates an illusory duplicate of any creature. The duplicate creature is partially real and formed from ice or snow. It appears to be the same as the original, but it has only one-half of the real creature’s levels or Hit Dice (and the appropriate hit points, feats, skill ranks, and special abilities for a creature of that level or HD). You can’t create a simulacrum of a creature whose Hit Dice or levels exceed twice your caster level. You must make a Disguise check when you cast the spell to determine how good the likeness is. A creature familiar with the original might detect the ruse with a successful Spot check (opposed by the caster’s Disguise check) or a DC 20 Sense Motive check.

At all times the simulacrum remains under your absolute command. No special telepathic link exists, so command must be exercised in some other manner. A simulacrum has no ability to become more powerful. It cannot increase its level or abilities. If reduced to 0 hit points or otherwise destroyed, it reverts to snow and melts instantly into nothingness. A complex process requiring at least 24 hours, 100 gp per hit point, and a fully equipped magical laboratory can repair damage to a simulacrum.

Material Component: The spell is cast over the rough snow or ice form, and some piece of the creature to be duplicated (hair, nail, or the like) must be placed inside the snow or ice. Additionally, the spell requires powdered ruby worth 100 gp per HD of the simulacrum to be created.

XP Cost: 100 XP per HD of the simulacrum to be created (minimum 1,000 XP).','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M, XP","Casting Time":"12 hours","Range":"0 ft.","Effect":"One duplicate creature","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_slay_living','Slay Living','Clr 5, Death 5',5,'Necromancy [Death]','Touch','Living creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric']::text[],'Necromancy \[Death\]

Level: Clr 5, Death 5

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: Instantaneous

Saving Throw: Fortitude partial

Spell Resistance: Yes

You can slay any one living creature. You must succeed on a melee touch attack to touch the subject, and it can avoid death with a successful Fortitude save. If it succeeds, it instead takes 3d6 points of damage +1 point per caster level.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5, Death 5","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous","Saving Throw":"Fortitude partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sleep','Sleep','Brd 1, Sor/Wiz 1',1,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,'One or more living creatures within a 10-ft.-radius burst','1 min./level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 1, Sor/Wiz 1

Components: V, S, M

Casting Time: 1 round

Range: Medium (100 ft. + 10 ft./level)

Area: One or more living creatures within a 10-ft.-radius burst

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

A sleep spell causes a magical slumber to come upon 4 Hit Dice of creatures. Creatures with the fewest HD are affected first.

Among creatures with equal HD, those who are closest to the spell’s point of origin are affected first. Hit Dice that are not sufficient to affect a creature are wasted.

Sleeping creatures are helpless. Slapping or wounding awakens an affected creature, but normal noise does not. Awakening a creature is a standard action (an application of the aid another action).

Sleep does not target unconscious creatures, constructs, or undead creatures.

Material Component: A pinch of fine sand, rose petals, or a live cricket.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 round","Range":"Medium (100 ft. + 10 ft./level)","Area":"One or more living creatures within a 10-ft.-radius burst","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sleet_storm','Sleet Storm','Drd 3, Sor/Wiz 3',3,'Conjuration (Creation) [Cold]','Long (400 ft. + 40 ft./level)',NULL,'Cylinder (40-ft. radius, 20 ft. high)','1 round/level','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Conjuration (Creation) \[Cold\]

Level: Drd 3, Sor/Wiz 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Cylinder (40-ft. radius, 20 ft. high)

Duration: 1 round/level

Saving Throw: None

Spell Resistance: No

Driving sleet blocks all sight (even darkvision) within it and causes the ground in the area to be icy. A creature can walk within or through the area of sleet at half normal speed with a DC 10 Balance check. Failure means it can’t move in that round, while failure by 5 or more means it falls (see the Balance skill for details).

The sleet extinguishes torches and small fires.

Arcane Material Component: A pinch of dust and a few drops of water.','{"class_levels":{"druid":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Drd 3, Sor/Wiz 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Cylinder (40-ft. radius, 20 ft. high)","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_slow','Slow','Brd 3, Sor/Wiz 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: Yes

An affected creature moves and attacks at a drastically slowed rate. A slowed creature can take only a single move action or standard action each turn, but not both (nor may it take full-round actions). Additionally, it takes a –1 penalty on attack rolls, AC, and Reflex saves. A slowed creature moves at half its normal speed (round down to the next 5-foot increment), which affects the creature’s jumping distance as normal for decreased speed.

Multiple slow effects don’t stack. Slow counters and dispels haste.

Material Component: A drop of molasses.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_snare','Snare','Rgr 2, Drd 3',2,'Transmutation','Touch','Touched nonmagical circle of vine, rope, or thong with a 2 ft. diameter + 2 ft./level',NULL,'Until triggered or broken','V, S, DF',ARRAY['ranger','druid']::text[],'Transmutation

Level: Rgr 2, Drd 3

Components: V, S, DF

Casting Time: 3 rounds

Range: Touch

Target: Touched nonmagical circle of vine, rope, or thong with a 2 ft. diameter + 2 ft./level

Duration: Until triggered or broken

Saving Throw: None

Spell Resistance: No

This spell enables you to make a snare that functions as a magic trap. The snare can be made from any supple vine, a thong, or a rope. When you cast snare upon it, the cordlike object blends with its surroundings (Search DC 23 for a character with the trapfinding ability to locate). One end of the snare is tied in a loop that contracts around one or more of the limbs of any creature stepping inside the circle.

If a strong and supple tree is nearby, the snare can be fastened to it. The spell causes the tree to bend and then straighten when the loop is triggered, dealing 1d6 points of damage to the creature trapped and lifting it off the ground by the trapped limb or limbs. If no such tree is available, the cordlike object tightens around the creature, dealing no damage but causing it to be entangled.

The snare is magical. To escape, a trapped creature must make a DC 23 Escape Artist check or a DC 23 Strength check that is a full-round action. The snare has AC 7 and 5 hit points. A successful escape from the snare breaks the loop and ends the spell.','{"class_levels":{"ranger":2,"druid":3},"source_field_values":{"Level":"Rgr 2, Drd 3","Components":"V, S, DF","Casting Time":"3 rounds","Range":"Touch","Target":"Touched nonmagical circle of vine, rope, or thong with a 2 ft. diameter + 2 ft./level","Duration":"Until triggered or broken","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_soften_earth_and_stone','Soften Earth and Stone','Drd 2, Earth 2',2,'Transmutation [Earth]','Close (25 ft. + 5 ft./2 levels)',NULL,'10-ft. square/level; see text','Instantaneous','V, S, DF',ARRAY['druid']::text[],'Transmutation \[Earth\]

Level: Drd 2, Earth 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 10-ft. square/level; see text

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

When this spell is cast, all natural, undressed earth or stone in the spell’s area is softened. Wet earth becomes thick mud, dry earth becomes loose sand or dirt, and stone becomes soft clay that is easily molded or chopped. You affect a 10-footsquare area to a depth of 1 to 4 feet, depending on the toughness or resilience of the ground at that spot. Magical, enchanted, dressed, or worked stone cannot be affected. Earth or stone creatures are not affected.

A creature in mud must succeed on a Reflex save or be caught for 1d2 rounds and unable to move, attack, or cast spells. A creature that succeeds on its save can move through the mud at half speed, and it can’t run or charge.

Loose dirt is not as troublesome as mud, but all creatures in the area can move at only half their normal speed and can’t run or charge over the surface.

Stone softened into clay does not hinder movement, but it does allow characters to cut, shape, or excavate areas they may not have been able to affect before.

While soften earth and stone does not affect dressed or worked stone, cavern ceilings or vertical surfaces such as cliff faces can be affected. Usually, this causes a moderate collapse or landslide as the loosened material peels away from the face of the wall or roof and falls.

A moderate amount of structural damage can be dealt to a manufactured structure by softening the ground beneath it, causing it to settle. However, most well-built structures will only be damaged by this spell, not destroyed.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2, Earth 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"10-ft. square/level; see text","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_solid_fog','Solid Fog','Sor/Wiz 4',4,'Conjuration (Creation)',NULL,NULL,NULL,'1 min./level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 4

Components: V, S, M

Duration: 1 min./level

Spell Resistance: No

This spell functions like fog cloud, but in addition to obscuring sight, the solid fog is so thick that any creature attempting to move through it progresses at a speed of 5 feet, regardless of its normal speed, and it takes a –2 penalty on all melee attack and melee damage rolls. The vapors prevent effective ranged weapon attacks (except for magic rays and the like). A creature or object that falls into solid fog is slowed, so that each 10 feet of vapor that it passes through reduces falling damage by 1d6. A creature can’t take a 5-foot step while in solid fog.

However, unlike normal fog, only a severe wind (31+ mph) disperses these vapors, and it does so in 1 round.

Solid fog can be made permanent with a permanency spell. A permanent solid fog dispersed by wind reforms in 10 minutes.

Material Component: A pinch of dried, powdered peas combined with powdered animal hoof.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Duration":"1 min./level","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_song_of_discord','Song of Discord','Brd 5',5,'Enchantment (Compulsion) [Mind-Affecting, Sonic]','Medium (100 ft. + 10 ft./level)',NULL,'Creatures within a 20-ft.-radius spread','1 round/level','V, S',ARRAY['bard']::text[],'Enchantment (Compulsion) \[Mind-Affecting, Sonic\]

Level: Brd 5

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Creatures within a 20-ft.-radius spread

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: Yes

This spell causes those within the area to turn on each other rather than attack their foes. Each affected creature has a 50% chance to attack the nearest target each round. (Roll to determine each creature’s behavior every round at the beginning of its turn.) A creature that does not attack its nearest neighbor is free to act normally for that round.

Creatures forced by a song of discord to attack their fellows employ all methods at their disposal, choosing their deadliest spells and most advantageous combat tactics. They do not, however, harm targets that have fallen unconscious.','{"class_levels":{"bard":5},"source_field_values":{"Level":"Brd 5","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Creatures within a 20-ft.-radius spread","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_soul_bind','Soul Bind','Clr 9, Sor/Wiz 9',9,'Necromancy','Close (25 ft. + 5 ft./2 levels)','Corpse',NULL,'Permanent','V, S, F',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 9, Sor/Wiz 9

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: Corpse

Duration: Permanent

Saving Throw: Will negates

Spell Resistance: No

You draw the soul from a newly dead body and imprison it in a black sapphire gem. The subject must have been dead no more than 1 round per caster level. The soul, once trapped in the gem, cannot be returned through clone, raise dead, reincarnation, resurrection, true resurrection, or even a miracle or a wish. Only by destroying the gem or dispelling the spell on the gem can one free the soul (which is then still dead).

Focus: A black sapphire of at least 1,000 gp value for every Hit Die possessed by the creature whose soul is to be bound. If the gem is not valuable enough, it shatters when the binding is attempted. (While creatures have no concept of level or Hit Dice as such, the value of the gem needed to trap an individual can be researched. Remember that this value can change over time as creatures gain more Hit Dice.)','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 9, Sor/Wiz 9","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Corpse","Duration":"Permanent","Saving Throw":"Will negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_sound_burst','Sound Burst','Brd 2, Clr 2',2,'Evocation [Sonic]','Close (25 ft. + 5 ft./2 levels)',NULL,'10-ft.-radius spread','Instantaneous','V, S, F/DF',ARRAY['bard','cleric']::text[],'Evocation \[Sonic\]

Level: Brd 2, Clr 2

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 10-ft.-radius spread

Duration: Instantaneous

Saving Throw: Fortitude partial

Spell Resistance: Yes

You blast an area with a tremendous cacophony. Every creature in the area takes 1d8 points of sonic damage and must succeed on a Fortitude save to avoid being stunned for 1 round.

Creatures that cannot hear are not stunned but are still damaged.

Arcane Focus: A musical instrument.','{"class_levels":{"bard":2,"cleric":2},"source_field_values":{"Level":"Brd 2, Clr 2","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"10-ft.-radius spread","Duration":"Instantaneous","Saving Throw":"Fortitude partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_speak_with_animals','Speak with Animals','Brd 3, Drd 1, Rgr 1',1,'Divination','Personal','You',NULL,'1 min./level','V, S',ARRAY['bard','druid','ranger']::text[],'Divination

Level: Brd 3, Drd 1, Rgr 1

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level

You can comprehend and communicate with animals. You are able to ask questions of and receive answers from animals, although the spell doesn’t make them any more friendly or cooperative than normal. Furthermore, wary and cunning animals are likely to be terse and evasive, while the more stupid ones make inane comments. If an animal is friendly toward you, it may do some favor or service for you.','{"class_levels":{"bard":3,"druid":1,"ranger":1},"source_field_values":{"Level":"Brd 3, Drd 1, Rgr 1","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_speak_with_dead','Speak with Dead','Clr 3',3,'Necromancy [Language-Dependent]','10 ft.','One dead creature',NULL,'1 min./level','V, S, DF',ARRAY['cleric']::text[],'Necromancy \[Language-Dependent\]

Level: Clr 3

Components: V, S, DF

Casting Time: 10 minutes

Range: 10 ft.

Target: One dead creature

Duration: 1 min./level

Saving Throw: Will negates; see text

Spell Resistance: No

You grant the semblance of life and intellect to a corpse, allowing it to answer several questions that you put to it. You may ask one question per two caster levels. Unasked questions are wasted if the duration expires. The corpse’s knowledge is limited to what the creature knew during life, including the languages it spoke (if any). Answers are usually brief, cryptic, or repetitive. If the creature’s alignment was different from yours, the corpse gets a Will save to resist the spell as if it were alive.

If the corpse has been subject to speak with dead within the past week, the new spell fails. You can cast this spell on a corpse that has been deceased for any amount of time, but the body must be mostly intact to be able to respond. A damaged corpse may be able to give partial answers or partially correct answers, but it must at least have a mouth in order to speak at all.

This spell does not let you actually speak to the person (whose soul has departed). It instead draws on the imprinted knowledge stored in the corpse. The partially animated body retains the imprint of the soul that once inhabited it, and thus it can speak with all the knowledge that the creature had while alive. The corpse, however, cannot learn new information.

Indeed, it can’t even remember being questioned.

This spell does not affect a corpse that has been turned into an undead creature.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Components":"V, S, DF","Casting Time":"10 minutes","Range":"10 ft.","Target":"One dead creature","Duration":"1 min./level","Saving Throw":"Will negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_speak_with_plants','Speak with Plants','Brd 4, Drd 3, Rgr 2',2,'Divination','Personal','You',NULL,'1 min./level','V, S',ARRAY['bard','druid','ranger']::text[],'Divination

Level: Brd 4, Drd 3, Rgr 2

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level

You can comprehend and communicate with plants, including both normal plants and plant creatures. You are able to ask questions of and receive answers from plants. A regular plant’s sense of its surroundings is limited, so it won’t be able to give (or recognize) detailed descriptions of creatures or answer questions about events outside its immediate vicinity.

The spell doesn’t make plant creatures any more friendly or cooperative than normal. Furthermore, wary and cunning plant creatures are likely to be terse and evasive, while the more stupid ones may make inane comments. If a plant creature is friendly toward you, it may do some favor or service for you.','{"class_levels":{"bard":4,"druid":3,"ranger":2},"source_field_values":{"Level":"Brd 4, Drd 3, Rgr 2","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spectral_hand','Spectral Hand','Sor/Wiz 2',2,'Necromancy','Medium (100 ft. + 10 ft./level)','One spectral hand',NULL,'1 min./level (D)','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: One spectral hand

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

A ghostly, glowing hand shaped from your life force materializes and moves as you desire, allowing you to deliver low-level, touch range spells at a distance. On casting the spell, you lose 1d4 hit points that return when the spell ends (even if it is dispelled), but not if the hand is destroyed. (The hit points can be healed as normal.) For as long as the spell lasts, any touch range spell of 4th level or lower that you cast can be delivered by the spectral hand. The spell gives you a +2 bonus on your melee touch attack roll, and attacking with the hand counts normally as an attack. The hand always strikes from your direction. The hand cannot flank targets like a creature can. After it delivers a spell, or if the hand goes beyond the spell range, goes out of your sight, the hand returns to you and hovers.

The hand is incorporeal and thus cannot be harmed by normal weapons. It has improved evasion (half damage on a failed Reflex save and no damage on a successful save), your save bonuses, and an AC of at least 22. Your Intelligence modifier applies to the hand’s AC as if it were the hand’s Dexterity modifier. The hand has 1 to 4 hit points, the same number that you lost in creating it.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"One spectral hand","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spell_immunity','Spell Immunity','Clr 4, Protection 4, Strength 4',4,'Abjuration','Touch','Creature touched',NULL,'10 min./level','V, S, DF',ARRAY['cleric']::text[],'Abjuration

Level: Clr 4, Protection 4, Strength 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The warded creature is immune to the effects of one specified spell for every four levels you have. The spells must be of 4th level or lower. The warded creature effectively has unbeatable spell resistance regarding the specified spell or spells. Naturally, that immunity doesn’t protect a creature from spells for which spell resistance doesn’t apply. Spell immunity protects against spells, spell-like effects of magic items, and innate spell-like abilities of creatures. It does not protect against supernatural or extraordinary abilities, such as breath weapons or gaze attacks.

Only a particular spell can be protected against, not a certain domain or school of spells or a group of spells that are similar in effect.

A creature can have only one spell immunity or greater spell immunity spell in effect on it at a time.','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4, Protection 4, Strength 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spell_immunity_greater','Spell Immunity, Greater','Clr 8',8,'Abjuration',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Abjuration

Level: Clr 8

This spell functions like spell immunity, except the immunity applies to spells of 8th level or lower.

A creature can have only one spell immunity or greater spell immunity spell in effect on it at a time.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spell_resistance','Spell Resistance','Clr 5, Magic 5, Protection 5',5,'Abjuration','Touch','Creature touched',NULL,'1 min./level','V, S, DF',ARRAY['cleric']::text[],'Abjuration

Level: Clr 5, Magic 5, Protection 5

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The creature gains spell resistance equal to 12 + your caster level.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5, Magic 5, Protection 5","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spellstaff','Spellstaff','Drd 6',6,'Transmutation','Touch','Wooden quarterstaff touched',NULL,'Permanent until discharged (D)','V, S, F',ARRAY['druid']::text[],'Transmutation

Level: Drd 6

Components: V, S, F

Casting Time: 10 minutes

Range: Touch

Target: Wooden quarterstaff touched

Duration: Permanent until discharged (D)

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You store one spell that you can normally cast in a wooden quarterstaff. Only one such spell can be stored in a staff at a given time, and you cannot have more than one spellstaff at any given time. You can cast a spell stored within a staff just as though it were among those you had prepared, but it does not count against your normal allotment for a given day. You use up any applicable material components required to cast the spell when you store it in the spellstaff.

Focus: The staff that stores the spell.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Components":"V, S, F","Casting Time":"10 minutes","Range":"Touch","Target":"Wooden quarterstaff touched","Duration":"Permanent until discharged (D)","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spell_turning','Spell Turning','Luck 7, Magic 7, Sor/Wiz 7',7,'Abjuration','Personal','You',NULL,'Until expended or 10 min./level','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Luck 7, Magic 7, Sor/Wiz 7

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: Until expended or 10 min./level

Spells and spell-like effects targeted on you are turned back upon the original caster. The abjuration turns only spells that have you as a target. Effect and area spells are not affected. Spell turning also fails to stop touch range spells.

From seven to ten (1d4+6) spell levels are affected by the turning. The exact number is rolled secretly.

When you are targeted by a spell of higher level than the amount of spell turning you have left, that spell is partially turned. The subtract the amount of spell turning left from the spell level of the incoming spell, then divide the result by the spell level of the incoming spell to see what fraction of the effect gets through. For damaging spells, you and the caster each take a fraction of the damage. For nondamaging spells, each of you has a proportional chance to be affected.

If you and a spellcasting attacker are both warded by spell turning effects in operation, a resonating field is created.

Roll randomly to determine the result.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>d%</th><th>Effect</th></tr><tr><td>01–70</td><td>Spell drains away without effect.</td></tr><tr><td>71–80</td><td>Spell affects both of you equally at full effect.</td></tr><tr><td>81–97</td><td>Both turning effects are rendered nonfunctional for 1d4 minutes.</td></tr><tr><td>98–100</td><td>Both of you go through a rift into another plane.</td></tr></tbody></table>

Arcane Material Component: A small silver mirror.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Luck 7, Magic 7, Sor/Wiz 7","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"Until expended or 10 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spider_climb','Spider Climb','Drd 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'10 min./level','V, S, M',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation

Level: Drd 2, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject can climb and travel on vertical surfaces or even traverse ceilings as well as a spider does. The affected creature must have its hands free to climb in this manner. The subject gains a climb speed of 20 feet; furthermore, it need not make Climb checks to traverse a vertical or horizontal surface (even upside down). A spider climbing creature retains its Dexterity bonus to Armor Class (if any) while climbing, and opponents get no special bonus to their attacks against it. It cannot, however, use the run action while climbing.

Material Component: A drop of bitumen and a live spider, both of which must be eaten by the subject.','{"class_levels":{"druid":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Drd 2, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spike_growth','Spike Growth','Drd 3, Rgr 2',2,'Transmutation','Medium (100 ft. + 10 ft./level)',NULL,'One 20-ft. square/level','1 hour/level (D)','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 3, Rgr 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: One 20-ft. square/level

Duration: 1 hour/level (D)

Saving Throw: Reflex partial

Spell Resistance: Yes

Any ground-covering vegetation in the spell’s area becomes very hard and sharply pointed without changing its appearance.

In areas of bare earth, roots and rootlets act in the same way. Typically, spike growth can be cast in any outdoor setting except open water, ice, heavy snow, sandy desert, or bare stone. Any creature moving on foot into or through the spell’s area takes 1d4 points of piercing damage for each 5 feet of movement through the spiked area.

Any creature that takes damage from this spell must also succeed on a Reflex save or suffer injuries to its feet and legs that slow its land speed by one-half. This speed penalty lasts for 24 hours or until the injured creature receives a cure spell (which also restores lost hit points). Another character can remove the penalty by taking 10 minutes to dress the injuries and succeeding on a Heal check against the spell’s save DC.

Spike growth can’t be disabled with the Disable Device skill.

Note: Magic traps such as spike growth are hard to detect. A rogue (only) can use the Search skill to find a spike growth. The DC is 25 + spell level, or DC 28 for spike growth (or DC 27 for spike growth cast by a ranger).','{"class_levels":{"druid":3,"ranger":2},"source_field_values":{"Level":"Drd 3, Rgr 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"One 20-ft. square/level","Duration":"1 hour/level (D)","Saving Throw":"Reflex partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spike_stones','Spike Stones','Drd 4, Earth 4',4,'Transmutation [Earth]','Medium (100 ft. + 10 ft./level)',NULL,'One 20-ft. square/level','1 hour/level (D)','V, S, DF',ARRAY['druid']::text[],'Transmutation \[Earth\]

Level: Drd 4, Earth 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: One 20-ft. square/level

Duration: 1 hour/level (D)

Saving Throw: Reflex partial

Spell Resistance: Yes

Rocky ground, stone floors, and similar surfaces shape themselves into long, sharp points that blend into the background.

Spike stones impede progress through an area and deal damage. Any creature moving on foot into or through the spell’s area moves at half speed.

In addition, each creature moving through the area takes 1d8 points of piercing damage for each 5 feet of movement through the spiked area.

Any creature that takes damage from this spell must also succeed on a Reflex save to avoid injuries to its feet and legs. A failed save causes the creature’s speed to be reduced to half normal for 24 hours or until the injured creature receives a cure spell (which also restores lost hit points). Another character can remove the penalty by taking 10 minutes to dress the injuries and succeeding on a Heal check against the spell’s save DC.

Spike stones is a magic trap that can’t be disabled with the Disable Device skill.

Note: Magic traps such as spike stones are hard to detect. A rogue (only) can use the Search skill to find spike stones. The DC is 25 + spell level, or DC 29 for spike stones.','{"class_levels":{"druid":4},"source_field_values":{"Level":"Drd 4, Earth 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"One 20-ft. square/level","Duration":"1 hour/level (D)","Saving Throw":"Reflex partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_spiritual_weapon','Spiritual Weapon','Clr 2, War 2',2,'Evocation [Force]','Medium (100 ft. + 10 ft./level)','Magic weapon of force',NULL,'1 round/level (D)','V, S, DF',ARRAY['cleric']::text[],'Evocation \[Force\]

Level: Clr 2, War 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Magic weapon of force

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: Yes

A weapon made of pure force springs into existence and attacks opponents at a distance, as you direct it, dealing 1d8 force damage per hit, +1 point per three caster levels (maximum +5 at 15th level). The weapon takes the shape of a weapon favored by your deity or a weapon with some spiritual significance or symbolism to you (see below) and has the same threat range and critical multipliers as a real weapon of its form. It strikes the opponent you designate, starting with one attack in the round the spell is cast and continuing each round thereafter on your turn. It uses your base attack bonus (possibly allowing it multiple attacks per round in subsequent rounds) plus your Wisdom modifier as its attack bonus. It strikes as a spell, not as a weapon, so, for example, it can damage creatures that have damage reduction. As a force effect, it can strike incorporeal creatures without the normal miss chance associated with incorporeality. The weapon always strikes from your direction. It does not get a flanking bonus or help a combatant get one. Your feats or combat actions do not affect the weapon. If the weapon goes beyond the spell range, if it goes out of your sight, or if you are not directing it, the weapon returns to you and hovers.

Each round after the first, you can use a move action to redirect the weapon to a new target. If you do not, the weapon continues to attack the previous round’s target. On any round that the weapon switches targets, it gets one attack. Subsequent rounds of attacking that target allow the weapon to make multiple attacks if your base attack bonus would allow it to. Even if the spiritual weapon is a ranged weapon, use the spell’s range, not the weapon’s normal range increment, and switching targets still is a move action.

A spiritual weapon cannot be attacked or harmed by physical attacks, but dispel magic, disintegrate, a sphere of annihilation, or a rod of cancellation affects it. A spiritual weapon’s AC against touch attacks is 12 (10 + size bonus for Tiny object).

If an attacked creature has spell resistance, you make a caster level check (1d20 + caster level) against that spell resistance the first time the spiritual weapon strikes it. If the weapon is successfully resisted, the spell is dispelled. If not, the weapon has its normal full effect on that creature for the duration of the spell.

The weapon that you get is often a force replica of your deity’s own personal weapon. A cleric without a deity gets a weapon based on his alignment. A neutral cleric without a deity can create a spiritual weapon of any alignment, provided he is acting at least generally in accord with that alignment at the time. The weapons associated with each alignment are as follows.

Chaos: Battleaxe

Evil: Light flail

Good: Warhammer

Law: Longsword,','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2, War 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Magic weapon of force","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_statue','Statue','Sor/Wiz 7',7,'Transmutation','Touch','Creature touched',NULL,'1 hour/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 7

Components: V, S, M

Casting Time: 1 round

Range: Touch

Target: Creature touched

Duration: 1 hour/level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

A statue spell turns the subject to solid stone, along with any garments and equipment worn or carried. In statue form, the subject gains hardness 8. The subject retains its own hit points.

The subject can see, hear, and smell normally, but it does not need to eat or breathe. Feeling is limited to those sensations that can affect the granite-hard substance of the individual’s body. Chipping is equal to a mere scratch, but breaking off one of the statue’s arms constitutes serious damage.

The subject of a statue spell can return to its normal state, act, and then return instantly to the statue state (a free action) if it so desires, as long as the spell duration is in effect.

Material Component: Lime, sand, and a drop of water stirred by an iron bar, such as a nail or spike.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 round","Range":"Touch","Target":"Creature touched","Duration":"1 hour/level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_status','Status','Clr 2',2,'Divination','Touch',NULL,NULL,'1 hour/level','V, S',ARRAY['cleric']::text[],'Divination

Level: Clr 2

Components: V, S

Casting Time: 1 standard action

Range: Touch

Targets: One living creature touched per three levels

Duration: 1 hour/level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

When you need to keep track of comrades who may get separated, status allows you to mentally monitor their relative positions and general condition. You are aware of direction and distance to the creatures and any conditions affecting them: unharmed, wounded, disabled, staggered, unconscious, dying, nauseated, panicked, stunned, poisoned, diseased, confused, or the like. Once the spell has been cast upon the subjects, the distance between them and the caster does not affect the spell as long as they are on the same plane of existence. If a subject leaves the plane, or if it dies, the spell ceases to function for it.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Targets":"One living creature touched per three levels","Duration":"1 hour/level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_stinking_cloud','Stinking Cloud','Sor/Wiz 3',3,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Cloud spreads in 20-ft. radius, 20 ft. high',NULL,'1 round/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Cloud spreads in 20-ft. radius, 20 ft. high

Duration: 1 round/level

Saving Throw: Fortitude negates; see text

Spell Resistance: No

Stinking cloud creates a bank of fog like that created by fog cloud, except that the vapors are nauseating. Living creatures in the cloud become nauseated. This condition lasts as long as the creature is in the cloud and for 1d4+1 rounds after it leaves. (Roll separately for each nauseated character.) Any creature that succeeds on its save but remains in the cloud must continue to save each round on your turn.

Stinking cloud can be made permanent with a permanency spell. A permanent stinking cloud dispersed by wind reforms in 10 minutes.

Material Component: A rotten egg or several skunk cabbage leaves.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Cloud spreads in 20-ft. radius, 20 ft. high","Duration":"1 round/level","Saving Throw":"Fortitude negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_stone_shape','Stone Shape','Clr 3, Drd 3, Earth 3, Sor/Wiz 4',3,'Transmutation [Earth]','Touch','Stone or stone object touched, up to 10 cu. ft. + 1 cu. ft./level',NULL,'Instantaneous','V, S, M/DF',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation \[Earth\]

Level: Clr 3, Drd 3, Earth 3, Sor/Wiz 4

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Stone or stone object touched, up to 10 cu. ft. + 1 cu. ft./level

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

You can form an existing piece of stone into any shape that suits your purpose. While it’s possible to make crude coffers, doors, and so forth with stone shape, fine detail isn’t possible. There is a 30% chance that any shape including moving parts simply doesn’t work.

Arcane Material Component: Soft clay, which must be worked into roughly the desired shape of the stone object and then touched to the stone while the verbal component is uttered.','{"class_levels":{"cleric":3,"druid":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Clr 3, Drd 3, Earth 3, Sor/Wiz 4","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Stone or stone object touched, up to 10 cu. ft. + 1 cu. ft./level","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_stoneskin','Stoneskin','Drd 5, Earth 6, Sor/Wiz 4, Strength 6',4,'Abjuration','Touch','Creature touched',NULL,'10 min./level or until discharged','V, S, M',ARRAY['druid','sorcerer','wizard']::text[],'Abjuration

Level: Drd 5, Earth 6, Sor/Wiz 4, Strength 6

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level or until discharged

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The warded creature gains resistance to blows, cuts, stabs, and slashes. The subject gains damage reduction 10/adamantine. (It ignores the first 10 points of damage each time it takes damage from a weapon, though an adamantine weapon bypasses the reduction.) Once the spell has prevented a total of 10 points of damage per caster level (maximum 150 points), it is discharged.

Material Component: Granite and 250 gp worth of diamond dust sprinkled on the target’s skin.','{"class_levels":{"druid":5,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Drd 5, Earth 6, Sor/Wiz 4, Strength 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level or until discharged","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_stone_tell','Stone Tell','Drd 6',6,'Divination','Personal','You',NULL,'1 min./level','V, S, DF',ARRAY['druid']::text[],'Divination

Level: Drd 6

Components: V, S, DF

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: 1 min./level

You gain the ability to speak with stones, which relate to you who or what has touched them as well as revealing what is covered or concealed behind or under them. The stones relate complete descriptions if asked. A stone’s perspective, perception, and knowledge may prevent the stone from providing the details you are looking for.

You can speak with natural or worked stone.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Components":"V, S, DF","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"1 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_stone_to_flesh','Stone to Flesh','Sor/Wiz 6',6,'Transmutation','Medium (100 ft. + 10 ft./level)','One petrified creature or a cylinder of stone from 1 ft. to 3 ft. in diameter and up to 10 ft. long',NULL,'Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One petrified creature or a cylinder of stone from 1 ft. to 3 ft. in diameter and up to 10 ft. long

Duration: Instantaneous

Saving Throw: Fortitude negates (object); see text

Spell Resistance: Yes

This spell restores a petrified creature to its normal state, restoring life and goods. The creature must make a DC 15 Fortitude save to survive the process. Any petrified creature, regardless of size, can be restored.

The spell also can convert a mass of stone into a fleshy substance. Such flesh is inert and lacking a vital life force unless a life force or magical energy is available. (For example, this spell would turn a stone golem into a flesh golem, but an ordinary statue would become a corpse.) You can affect an object that fits within a cylinder from 1 foot to 3 feet in diameter and up to 10 feet long or a cylinder of up to those dimensions in a larger mass of stone.

Material Component: A pinch of earth and a drop of blood.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One petrified creature or a cylinder of stone from 1 ft. to 3 ft. in diameter and up to 10 ft. long","Duration":"Instantaneous","Saving Throw":"Fortitude negates (object); see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_storm_of_vengeance','Storm of Vengeance','Drd 9, Clr 9',9,'Conjuration (Summoning)','Long (400 ft. + 40 ft./level)','360-ft.-radius storm cloud',NULL,'Concentration (maximum 10 rounds) (D)','V, S',ARRAY['druid','cleric']::text[],'Conjuration (Summoning)

Level: Drd 9, Clr 9

Components: V, S

Casting Time: 1 round

Range: Long (400 ft. + 40 ft./level)

Effect: 360-ft.-radius storm cloud

Duration: Concentration (maximum 10 rounds) (D)

Saving Throw: See text

Spell Resistance: Yes

This spell creates an enormous black storm cloud. Lightning and crashing claps of thunder appear within the storm. Each creature beneath the cloud must succeed on a Fortitude save or be deafened for 1d4x10 minutes.

If you do not maintain concentration on the spell after casting it, the spell ends. If you continue to concentrate, the spell generates additional effects in each following round, as noted below. Each effect occurs during your turn.

2nd Round: Acid rains down in the area, dealing 1d6 points of acid damage (no save).

3rd Round: You call six bolts of lightning down from the cloud. You decide where the bolts strike. No two bolts may be directed at the same target. Each bolt deals 10d6 points of electricity damage. A creature struck can attempt a Reflex save for half damage.

4th Round: Hailstones rain down in the area, dealing 5d6 points of bludgeoning damage (no save).

5th through 10th Rounds: Violent rain and wind gusts reduce visibility. The rain obscures all sight, including darkvision, beyond 5 feet. A creature 5 feet away has concealment (attacks have a 20% miss chance). Creatures farther away have total concealment (50% miss chance, and the attacker cannot use sight to locate the target). Speed is reduced by three-quarters.

Ranged attacks within the area of the storm are impossible. Spells cast within the area are disrupted unless the caster succeeds on a Concentration check against a DC equal to the storm of vengeance’s save DC + the level of the spell the caster is trying to cast.','{"class_levels":{"druid":9,"cleric":9},"source_field_values":{"Level":"Drd 9, Clr 9","Components":"V, S","Casting Time":"1 round","Range":"Long (400 ft. + 40 ft./level)","Effect":"360-ft.-radius storm cloud","Duration":"Concentration (maximum 10 rounds) (D)","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_suggestion','Suggestion','Brd 2, Sor/Wiz 3',2,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'1 hour/level or until completed','V, M',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Brd 2, Sor/Wiz 3

Components: V, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: 1 hour/level or until completed

Saving Throw: Will negates

Spell Resistance: Yes

You influence the actions of the target creature by suggesting a course of activity (limited to a sentence or two). The suggestion must be worded in such a manner as to make the activity sound reasonable. Asking the creature to do some obviously harmful act automatically negates the effect of the spell.

The suggested course of activity can continue for the entire duration. If the suggested activity can be completed in a shorter time, the spell ends when the subject finishes what it was asked to do. You can instead specify conditions that will trigger a special activity during the duration. If the condition is not met before the spell duration expires, the activity is not performed.

A very reasonable suggestion causes the save to be made with a penalty (such as –1 or –2).

Material Component: A snake’s tongue and either a bit of honeycomb or a drop of sweet oil.','{"class_levels":{"bard":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 2, Sor/Wiz 3","Components":"V, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"1 hour/level or until completed","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_suggestion_mass','Suggestion, Mass','Brd 5, Sor/Wiz 6',5,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,NULL,NULL,NULL,ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Brd 5, Sor/Wiz 6

Range: Medium (100 ft. + 10 ft./level)

Targets: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like suggestion, except that it can affect more creatures. The same suggestion applies to all these creatures.','{"class_levels":{"bard":5,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 5, Sor/Wiz 6","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_instrument','Summon Instrument','Brd 0',0,'Conjuration (Summoning)','0 ft.','One summoned handheld musical instrument',NULL,'1 min./level (D)','V, S',ARRAY['bard']::text[],'Conjuration (Summoning)

Level: Brd 0

Components: V, S

Casting Time: 1 round

Range: 0 ft.

Effect: One summoned handheld musical instrument

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell summons one handheld musical instrument of your choice. This instrument appears in your hands or at your feet (your choice). The instrument is typical for its type. Only one instrument appears per casting, and it will play only for you. You can’t summon an instrument too large to be held in two hands.','{"class_levels":{"bard":0},"source_field_values":{"Level":"Brd 0","Components":"V, S","Casting Time":"1 round","Range":"0 ft.","Effect":"One summoned handheld musical instrument","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_i','Summon Monster I','Brd 1, Clr 1, Sor/Wiz 1',1,'Conjuration (Summoning) [see text]','Close (25 ft. + 5 ft./2 levels)','One summoned creature',NULL,'1 round/level (D)','V, S, F/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text\]

Level: Brd 1, Clr 1, Sor/Wiz 1

Components: V, S, F/DF

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One summoned creature

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: No

This spell summons an extraplanar creature (typically an outsider, elemental, or magical beast native to another plane). It appears where you designate and acts immediately, on your turn. It attacks your opponents to the best of its ability. If you can communicate with the creature, you can direct it not to attack, to attack particular enemies, or to perform other actions.

The spell conjures one of the creatures from the 1st-level list on the accompanying Summon Monster table. You choose which kind of creature to summon, and you can change that choice each time you cast the spell.

A summoned monster cannot summon or otherwise conjure another creature, nor can it use any teleportation or planar travel abilities. Creatures cannot be summoned into an environment that cannot support them.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.

Arcane Focus: A tiny bag and a small (not necessarily lit) candle.','{"class_levels":{"bard":1,"cleric":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Clr 1, Sor/Wiz 1","Components":"V, S, F/DF","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One summoned creature","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_ii','Summon Monster II','Brd 2, Clr 2, Sor/Wiz 2',2,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,'One or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Brd 2, Clr 2, Sor/Wiz 2

Effect: One or more summoned creatures, no two of which can be more than 30 ft. apart

This spell functions like summon monster I, except that you can summon one creature from the 2nd-level list or 1d3 creatures of the same kind from the 1st-level list.','{"class_levels":{"bard":2,"cleric":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Clr 2, Sor/Wiz 2","Effect":"One or more summoned creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_iii','Summon Monster III','Brd 3, Clr 3, Sor/Wiz 3',3,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,'One or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Brd 3, Clr 3, Sor/Wiz 3

Effect: One or more summoned creatures, no two of which can be more than 30 ft. apart

This spell functions like summon monster I, except that you can summon one creature from the 3rd-level list, 1d3 creatures of the same kind from the 2nd-level list, or 1d4+1 creatures of the same kind from the 1st-level list.','{"class_levels":{"bard":3,"cleric":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Clr 3, Sor/Wiz 3","Effect":"One or more summoned creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_iv','Summon Monster IV','Brd 4, Clr 4, Sor/Wiz 4',4,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,'One or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Brd 4, Clr 4, Sor/Wiz 4

Effect: One or more summoned creatures, no two of which can be more than 30 ft. apart

This spell functions like summon monster I, except that you can summon one creature from the 4th-level list, 1d3 creatures of the same kind from the 3rd-level list, or 1d4+1 creatures of the same kind from a lower-level list.','{"class_levels":{"bard":4,"cleric":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Clr 4, Sor/Wiz 4","Effect":"One or more summoned creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_v','Summon Monster V','Brd 5, Clr 5, Sor/Wiz 5',5,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,'One or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Brd 5, Clr 5, Sor/Wiz 5

Effect: One or more summoned creatures, no two of which can be more than 30 ft. apart

This spell functions like summon monster I, except that you can summon one creature from the 5th-level list, 1d3 creatures of the same kind from the 4th-level list, or 1d4+1 creatures of the same kind from a lower-level list.','{"class_levels":{"bard":5,"cleric":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Clr 5, Sor/Wiz 5","Effect":"One or more summoned creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_vi','Summon Monster VI','Brd 6, Clr 6, Sor/Wiz 6',6,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,'One or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Brd 6, Clr 6, Sor/Wiz 6

Effect: One or more summoned creatures, no two of which can be more than 30 ft. apart

This spell functions like summon monster I, except you can summon one creature from the 6th-level list, 1d3 creatures of the same kind from the 5th-level list, or 1d4+1 creatures of the same kind from a lower-level list.','{"class_levels":{"bard":6,"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Clr 6, Sor/Wiz 6","Effect":"One or more summoned creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_vii','Summon Monster VII','Clr 7, Sor/Wiz 7',7,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Clr 7, Sor/Wiz 7

This spell functions like summon monster I, except that you can summon one creature from the 7th-level list, 1d3 creatures of the same kind from the 6th-level list, or 1d4+1 creatures of the same kind from a lower-level list.','{"class_levels":{"cleric":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 7, Sor/Wiz 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_viii','Summon Monster VIII','Clr 8, Sor/Wiz 8',8,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Clr 8, Sor/Wiz 8

This spell functions like summon monster I, except that you can summon one creature from the 8th-level list, 1d3 creatures of the same kind from the 7th-level list, or 1d4+1 creatures of the same kind from a lower-level list.','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Sor/Wiz 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_monster_ix','Summon Monster IX','Chaos 9, Clr 9, Evil 9, Good 9, Law 9, Sor/Wiz 9',9,'Conjuration (Summoning) [see text for _summon monster I_]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Summoning) \[see text for summon monster I\]

Level: Chaos 9, Clr 9, Evil 9, Good 9, Law 9, Sor/Wiz 9

This spell functions like summon monster I, except that you can summon one creature from the 9th-level list, 1d3 creatures of the same kind from the 8th-level list, or 1d4+1 creatures of the same kind from a lower-level list.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Summon Monster</th><td></td></tr><tr><th>1st Level</th><td></td></tr><tr><td>Celestial dog</td><td>LG</td></tr><tr><td>Celestial owl</td><td>LG</td></tr><tr><td>Celestial giant fire beetle</td><td>NG</td></tr><tr><td>Celestial porpoise<sup>1</sup></td><td>NG</td></tr><tr><td>Celestial badger</td><td>CG</td></tr><tr><td>Celestial monkey</td><td>CG</td></tr><tr><td>Fiendish dire rat</td><td>LE</td></tr><tr><td>Fiendish raven</td><td>LE</td></tr><tr><td>Fiendish monstrous centipede, Medium</td><td>NE</td></tr><tr><td>Fiendish monstrous scorpion, Small</td><td>NE</td></tr><tr><td>Fiendish hawk</td><td>CE</td></tr><tr><td>Fiendish monstrous spider, Small</td><td>CE</td></tr><tr><td>Fiendish octopus<sup>1</sup></td><td>CE</td></tr><tr><td>Fiendish snake, Small viper</td><td>CE</td></tr><tr><th>2nd Level</th><td></td></tr><tr><td>Celestial giant bee</td><td>LG</td></tr><tr><td>Celestial giant bombardier beetle</td><td>NG</td></tr><tr><td>Celestial riding dog</td><td>NG</td></tr><tr><td>Celestial eagle</td><td>CG</td></tr><tr><td>Lemure (devil)</td><td>LE</td></tr><tr><td>Fiendish squid<sup>1</sup></td><td>LE</td></tr><tr><td>Fiendish wolf</td><td>LE</td></tr><tr><td>Fiendish monstrous centipede, Large</td><td>NE</td></tr><tr><td>Fiendish monstrous scorpion, Medium</td><td>NE</td></tr><tr><td>Fiendish shark, Medium<sup>1</sup></td><td>NE</td></tr><tr><td>Fiendish monstrous spider, Medium</td><td>CE</td></tr><tr><td>Fiendish snake, Medium viper</td><td>CE</td></tr><tr><th>3rd Level</th><td></td></tr><tr><td>Celestial black bear</td><td>LG</td></tr><tr><td>Celestial bison</td><td>NG</td></tr><tr><td>Celestial dire badger</td><td>CG</td></tr><tr><td>Celestial hippogriff</td><td>CG</td></tr><tr><td>Elemental, Small (any)</td><td>N</td></tr><tr><td>Fiendish ape</td><td>LE</td></tr><tr><td>Fiendish dire weasel</td><td>LE</td></tr><tr><td>Hell hound</td><td>LE</td></tr><tr><td>Fiendish snake, constrictor</td><td>LE</td></tr><tr><td>Fiendish boar</td><td>NE</td></tr><tr><td>Fiendish dire bat</td><td>NE</td></tr><tr><td>Fiendish monstrous centipede, Huge</td><td>NE</td></tr><tr><td>Fiendish crocodile</td><td>CE</td></tr><tr><td>Dretch (demon)</td><td>CE</td></tr><tr><td>Fiendish snake, Large viper</td><td>CE</td></tr><tr><td>Fiendish wolverine</td><td>CE</td></tr><tr><th>4th Level</th><td></td></tr><tr><td>Archon, lantern</td><td>LG</td></tr><tr><td>Celestial giant owl</td><td>LG</td></tr><tr><td>Celestial giant eagle</td><td>CG</td></tr><tr><td>Celestial lion</td><td>CG</td></tr><tr><td>Mephit (any)</td><td>N</td></tr><tr><td>Fiendish dire wolf</td><td>LE</td></tr><tr><td>Fiendish giant wasp</td><td>LE</td></tr><tr><td>Fiendish giant praying mantis</td><td>NE</td></tr><tr><td>Fiendish shark, Large<sup>1</sup></td><td>NE</td></tr><tr><td>Yeth hound</td><td>NE</td></tr><tr><td>Fiendish monstrous spider, Large</td><td>CE</td></tr><tr><td>Fiendish snake, Huge viper</td><td>CE</td></tr><tr><td>Howler</td><td>CE</td></tr><tr><th>5th Level</th><td></td></tr><tr><td>Archon, hound</td><td>LG</td></tr><tr><td>Celestial brown bear</td><td>LG</td></tr><tr><td>Celestial giant stag beetle</td><td>NG</td></tr><tr><td>Celestial sea cat<sup>1</sup></td><td>NG</td></tr><tr><td>Celestial griffon</td><td>CG</td></tr><tr><td>Elemental, Medium (any)</td><td>N</td></tr><tr><td>Achaierai</td><td>LE</td></tr><tr><td>Devil, bearded</td><td>LE</td></tr><tr><td>Fiendish deinonychus</td><td>LE</td></tr><tr><td>Fiendish dire ape</td><td>LE</td></tr><tr><td>Fiendish dire boar</td><td>NE</td></tr><tr><td>Fiendish shark, Huge</td><td>NE</td></tr><tr><td>Fiendish monstrous scorpion, Large</td><td>NE</td></tr><tr><td>Shadow mastiff</td><td>NE</td></tr><tr><td>Fiendish dire wolverine</td><td>CE</td></tr><tr><td>Fiendish giant crocodile</td><td>CE</td></tr><tr><td>Fiendish tiger</td><td>CE</td></tr><tr><th>6th Level</th><td></td></tr><tr><td>Celestial polar bear</td><td>LG</td></tr><tr><td>Celestial orca whale<sup>1</sup></td><td>NG</td></tr><tr><td>Bralani (eladrin)</td><td>CG</td></tr><tr><td>Celestial dire lion</td><td>CG</td></tr><tr><td>Elemental, Large (any)</td><td>N</td></tr><tr><td>Janni (genie)</td><td>N</td></tr><tr><td>Chaos beast</td><td>CN</td></tr><tr><td>Devil, chain</td><td>LE</td></tr><tr><td>Xill</td><td>LE</td></tr><tr><td>Fiendish monstrous centipede, Gargantuan</td><td>NE</td></tr><tr><td>Fiendish rhinoceros</td><td>NE</td></tr><tr><td>Fiendish elasmosaurus<sup>1</sup></td><td>CE</td></tr><tr><td>Fiendish monstrous spider, Huge</td><td>CE</td></tr><tr><td>Fiendish snake, giant constrictor</td><td>CE</td></tr><tr><th>7th Level</th><td></td></tr><tr><td>Celestial elephant</td><td>LG</td></tr><tr><td>Avoral (guardinal)</td><td>NG</td></tr><tr><td>Celestial baleen whale<sup>1</sup></td><td>NG</td></tr><tr><td>Djinni (genie)</td><td>CG</td></tr><tr><td>Elemental, Huge (any)</td><td>N</td></tr><tr><td>Invisible stalker</td><td>N</td></tr><tr><td>Devil, bone</td><td>LE</td></tr><tr><td>Fiendish megaraptor</td><td>LE</td></tr><tr><td>Fiendish monstrous scorpion, Huge</td><td>NE</td></tr><tr><td>Babau (demon)</td><td>CE</td></tr><tr><td>Fiendish giant octopus<sup>1</sup></td><td>CE</td></tr><tr><td>Fiendish girallon</td><td>CE</td></tr><tr><th>8th Level</th><td></td></tr><tr><td>Celestial dire bear</td><td>LG</td></tr><tr><td>Celestial cachalot whale<sup>1</sup></td><td>NG</td></tr><tr><td>Celestial triceratops</td><td>NG</td></tr><tr><td>Lillend</td><td>CG</td></tr><tr><td>Elemental, greater (any)</td><td>N</td></tr><tr><td>Fiendish giant squid<sup>1</sup></td><td>LE</td></tr><tr><td>Hellcat</td><td>LE</td></tr><tr><td>Fiendish monstrous centipede, Colossal</td><td>NE</td></tr><tr><td>Fiendish dire tiger</td><td>CE</td></tr><tr><td>Fiendish monstrous spider, Gargantuan</td><td>CE</td></tr><tr><td>Fiendish tyrannosaurus</td><td>CE</td></tr><tr><td>Vrock (demon)</td><td>CE</td></tr><tr><th>9th Level</th><td></td></tr><tr><td>Couatl</td><td>LG</td></tr><tr><td>Leonal (guardinal)</td><td>NG</td></tr><tr><td>Celestial roc</td><td>CG</td></tr><tr><td>Elemental, elder (any)</td><td>N</td></tr><tr><td>Devil, barbed</td><td>LE</td></tr><tr><td>Fiendish dire shark<sup>1</sup></td><td>NE</td></tr><tr><td>Fiendish monstrous scorpion, Gargantuan</td><td>NE</td></tr><tr><td>Night hag</td><td>NE</td></tr><tr><td>Bebilith (demon)</td><td>CE</td></tr><tr><td>Fiendish monstrous spider, Colossal</td><td>CE</td></tr><tr><td>Hezrou (demon)</td><td>CE</td></tr><tr><td colspan="2">1 May be summoned only into an aquatic or watery environment.</td></tr></tbody></table>','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Chaos 9, Clr 9, Evil 9, Good 9, Law 9, Sor/Wiz 9"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_i','Summon Nature’s Ally I','Drd 1, Rgr 1',1,'Conjuration (Summoning)','Close (25 ft. + 5 ft./2 levels)','One summoned creature',NULL,'1 round/level (D)','V, S, DF',ARRAY['druid','ranger']::text[],'Conjuration (Summoning)

Level: Drd 1, Rgr 1

Components: V, S, DF

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One summoned creature

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: No

This spell summons a natural creature. It appears where you designate and acts immediately, on your turn. It attacks your opponents to the best of its ability. If you can communicate with the creature, you can direct it not to attack, to attack particular enemies, or to perform other actions.

A summoned monster cannot summon or otherwise conjure another creature, nor can it use any teleportation or planar travel abilities. Creatures cannot be summoned into an environment that cannot support them.

The spell conjures one of the creatures from the 1st-level list on the accompanying Summon Nature’s Ally table. You choose which kind of creature to summon, and you can change that choice each time you cast the spell. All the creatures on the table are neutral unless otherwise noted.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"V, S, DF","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One summoned creature","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_ii','Summon Nature’s Ally II','Drd 2, Rgr 2',2,'Conjuration (Summoning)',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid','ranger']::text[],'Conjuration (Summoning)

Level: Drd 2, Rgr 2

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 2nd-level creature or 1d3 1st-level creatures of the same kind.','{"class_levels":{"druid":2,"ranger":2},"source_field_values":{"Level":"Drd 2, Rgr 2","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_iii','Summon Nature’s Ally III','Drd 3, Rgr 3',3,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid','ranger']::text[],'Conjuration (Summoning) \[see text\]

Level: Drd 3, Rgr 3

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 3rd-level creature, 1d3 2nd-level creatures of the same kind, or 1d4+1 1st-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":3,"ranger":3},"source_field_values":{"Level":"Drd 3, Rgr 3","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md'),
('srd35_spell_summon_nature_s_ally_iv','Summon Nature’s Ally IV','Animal 4, Drd 4, Rgr 4',4,'Conjuration (Summoning) [see text]',NULL,'One or more creatures, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['druid','ranger']::text[],'Conjuration (Summoning) \[see text\]

Level: Animal 4, Drd 4, Rgr 4

Effect: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like summon nature’s ally I, except that you can summon one 4th-level creature, 1d3 3rd-level creatures of the same kind, or 1d4+1 lower-level creatures of the same kind.

When you use a summoning spell to summon an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.','{"class_levels":{"druid":4,"ranger":4},"source_field_values":{"Level":"Animal 4, Drd 4, Rgr 4","Effect":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-s.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
