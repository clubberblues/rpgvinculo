-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_levitate','Levitate','Sor/Wiz 2',2,'Transmutation','Personal or close (25 ft. + 5 ft./2 levels)','You or one willing creature or one object (total weight up to 100 lb./level)',NULL,'1 min./level (D)','V, S, F',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 2

Components: V, S, F

Casting Time: 1 standard action

Range: Personal or close (25 ft. + 5 ft./2 levels)

Target: You or one willing creature or one object (total weight up to 100 lb./level)

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

Levitate allows you to move yourself, another creature, or an object up and down as you wish. A creature must be willing to be levitated, and an object must be unattended or possessed by a willing creature. You can mentally direct the recipient to move up or down as much as 20 feet each round; doing so is a move action. You cannot move the recipient horizontally, but the recipient could clamber along the face of a cliff, for example, or push against a ceiling to move laterally (generally at half its base land speed).

A levitating creature that attacks with a melee or ranged weapon finds itself increasingly unstable; the first attack has a –1 penalty on attack rolls, the second –2, and so on, to a maximum penalty of –5. A full round spent stabilizing allows the creature to begin again at –1.

Focus: Either a small leather loop or a piece of golden wire bent into a cup shape with a long shank on one end.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, F","Casting Time":"1 standard action","Range":"Personal or close (25 ft. + 5 ft./2 levels)","Target":"You or one willing creature or one object (total weight up to 100 lb./level)","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_light','Light','Brd 0, Clr 0, Drd 0, Sor/Wiz 0',0,'Evocation [Light]','Touch','Object touched',NULL,'10 min./level (D)','V, M/DF',ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Brd 0, Clr 0, Drd 0, Sor/Wiz 0

Components: V, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell causes an object to glow like a torch, shedding bright light in a 20-foot radius (and dim light for an additional 20 feet) from the point you touch. The effect is immobile, but it can be cast on a movable object. Light taken into an area of magical darkness does not function.

A light spell (one with the light descriptor) counters and dispels a darkness spell (one with the darkness descriptor) of an equal or lower level.

Arcane Material Component: A firefly or a piece of phosphorescent moss.','{"class_levels":{"bard":0,"cleric":0,"druid":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Clr 0, Drd 0, Sor/Wiz 0","Components":"V, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_lightning_bolt','Lightning Bolt','Sor/Wiz 3',3,'Evocation [Electricity]','120 ft.',NULL,'120-ft. line','Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Electricity\]

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: 120 ft.

Area: 120-ft. line

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

You release a powerful stroke of electrical energy that deals 1d6 points of electricity damage per caster level (maximum 10d6) to each creature within its area. The bolt begins at your fingertips.

The lightning bolt sets fire to combustibles and damages objects in its path. It can melt metals with a low melting point, such as lead, gold, copper, silver, or bronze. If the damage caused to an interposing barrier shatters or breaks through it, the bolt may continue beyond the barrier if the spell’s range permits; otherwise, it stops at the barrier just as any other spell effect does.

Material Component: A bit of fur and an amber, crystal, or glass rod.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"120 ft.","Area":"120-ft. line","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_limited_wish','Limited Wish','Sor/Wiz 7',7,'Universal','See text',NULL,NULL,'See text','V, S, XP',ARRAY['sorcerer','wizard']::text[],'Universal

Level: Sor/Wiz 7

Components: V, S, XP

Casting Time: 1 standard action

Range: See text

Target, Effect, or Area: See text

Duration: See text

Saving Throw: None; see text

Spell Resistance: Yes

A limited wish lets you create nearly any type of effect. For example, a limited wish can do any of the following things.

- Duplicate any sorcerer/wizard spell of 6th level or lower, provided the spell is not of a school prohibited to you.
- Duplicate any other spell of 5th level or lower, provided the spell is not of a school prohibited to you.
- Duplicate any sorcerer/wizard spell of 5th level or lower, even if it’s of a prohibited school.
- Duplicate any other spell of 4th level or lower, even if it’s of a prohibited school.
- Undo the harmful effects of many spells, such as geas/quest or insanity.
- Produce any other effect whose power level is in line with the above effects, such as a single creature automatically hitting on its next attack or taking a –7 penalty on its next saving throw.

A duplicated spell allows saving throws and spell resistance as normal (but the save DC is for a 7th-level spell). When a limited wish duplicates a spell that has an XP cost, you must pay that cost or 300 XP, whichever is more. When a limited wish spell duplicates a spell with a material component that costs more than 1,000 gp, you must provide that component.

XP Cost: 300 XP or more (see above).','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, XP","Casting Time":"1 standard action","Range":"See text","Target, Effect, or Area":"See text","Duration":"See text","Saving Throw":"None; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_liveoak','Liveoak','Drd 6',6,'Transmutation','Touch','Tree touched',NULL,'One day/level (D)','V, S',ARRAY['druid']::text[],'Transmutation

Level: Drd 6

Components: V, S

Casting Time: 10 minutes

Range: Touch

Target: Tree touched

Duration: One day/level (D)

Saving Throw: None

Spell Resistance: No

This spell turns an oak tree into a protector or guardian. The spell can be cast on only a single tree at a time; while liveoak is in effect, you can’t cast it again on another tree. The tree on which the spell is cast must be within 10 feet of your dwelling place, within a place sacred to you, or within 300 feet of something that you wish to guard or protect.

Liveoak must be cast on a healthy, Huge oak. A triggering phrase of up to one word per caster level is placed on the targeted oak. The liveoak spell triggers the tree into animating as a treant.

If liveoak is dispelled, the tree takes root immediately, wherever it happens to be. If released by you, the tree tries to return to its original location before taking root.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Components":"V, S","Casting Time":"10 minutes","Range":"Touch","Target":"Tree touched","Duration":"One day/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_locate_creature','Locate Creature','Brd 4, Sor/Wiz 4',4,'Divination',NULL,NULL,NULL,'10 min./level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 4, Sor/Wiz 4

Components: V, S, M

Duration: 10 min./level

This spell functions like locate object, except this spell locates a known or familiar creature.

You slowly turn and sense when you are facing in the direction of the creature to be located, provided it is within range. You also know in which direction the creature is moving, if any.

The spell can locate a creature of a specific kind or a specific creature known to you. It cannot find a creature of a certain type. To find a kind of creature, you must have seen such a creature up close (within 30 feet) at least once.

Running water blocks the spell. It cannot detect objects. It can be fooled by mislead, nondetection, and polymorph spells.

Material Component: A bit of fur from a bloodhound.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S, M","Duration":"10 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_locate_object','Locate Object','Brd 2, Clr 3, Sor/Wiz 2, Travel 2',2,'Divination','Long (400 ft. + 40 ft./level)',NULL,'Circle, centered on you, with a radius of 400 ft. + 40 ft./level','1 min./level','V, S, F/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Divination

Level: Brd 2, Clr 3, Sor/Wiz 2, Travel 2

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Circle, centered on you, with a radius of 400 ft. + 40 ft./level

Duration: 1 min./level

Saving Throw: None

Spell Resistance: No

You sense the direction of a well-known or clearly visualized object. You can search for general items, in which case you locate the nearest one of its kind if more than one is within range. Attempting to find a certain item requires a specific and accurate mental image; if the image is not close enough to the actual object, the spell fails. You cannot specify a unique item unless you have observed that particular item firsthand (not through divination).

The spell is blocked by even a thin sheet of lead. Creatures cannot be found by this spell. Polymorph any object fools it.

Arcane Focus: A forked twig.','{"class_levels":{"bard":2,"cleric":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Clr 3, Sor/Wiz 2, Travel 2","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Circle, centered on you, with a radius of 400 ft. + 40 ft./level","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_longstrider','Longstrider','Drd 1, Rgr 1, Travel 1',1,'Transmutation','Personal','You',NULL,'1 hour/level (D)','V, S, M',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 1, Rgr 1, Travel 1

Components: V, S, M

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 hour/level (D)

This spell increases your base land speed by 10 feet. (This adjustment counts as an enhancement bonus.) It has no effect on other modes of movement, such as burrow, climb, fly, or swim.

Material Component: A pinch of dirt.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1, Travel 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 hour/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_lullaby','Lullaby','Brd 0',0,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,'Living creatures within a 10-ft.-radius burst','Concentration + 1 round/level (D)','V, S',ARRAY['bard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 0

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Living creatures within a 10-ft.-radius burst

Duration: Concentration + 1 round/level (D)

Saving Throw: Will negates

Spell Resistance: Yes

Any creature within the area that fails a Will save becomes drowsy and inattentive, taking a –5 penalty on Listen and Spot checks and a –2 penalty on Will saves against sleep effects while the lullaby is in effect. Lullaby lasts for as long as the caster concentrates, plus up to 1 round per caster level thereafter.','{"class_levels":{"bard":0},"source_field_values":{"Level":"Brd 0","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Living creatures within a 10-ft.-radius burst","Duration":"Concentration + 1 round/level (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_mage_armor','Mage Armor','Sor/Wiz 1',1,'Conjuration (Creation) [Force]','Touch','Creature touched',NULL,'1 hour/level (D)','V, S, F',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation) \[Force\]

Level: Sor/Wiz 1

Components: V, S, F

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 hour/level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: No

An invisible but tangible field of force surrounds the subject of a mage armor spell, providing a +4 armor bonus to AC.

Unlike mundane armor, mage armor entails no armor check penalty, arcane spell failure chance, or speed reduction. Since mage armor is made of force, incorporeal creatures can’t bypass it the way they do normal armor.

Focus: A piece of cured leather.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S, F","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 hour/level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_mage_hand','Mage Hand','Brd 0, Sor/Wiz 0',0,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One nonmagical, unattended object weighing up to 5 lb.',NULL,'Concentration','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 0, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One nonmagical, unattended object weighing up to 5 lb.

Duration: Concentration

Saving Throw: None

Spell Resistance: No

You point your finger at an object and can lift it and move it at will from a distance. As a move action, you can propel the object as far as 15 feet in any direction, though the spell ends if the distance between you and the object ever exceeds the spell’s range.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One nonmagical, unattended object weighing up to 5 lb.","Duration":"Concentration","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_disjunction','Mage’s Disjunction','Magic 9, Sor/Wiz 9',9,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,'All magical effects and magic items within a 40-ft.-radius burst','Instantaneous','V',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Magic 9, Sor/Wiz 9

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: All magical effects and magic items within a 40-ft.-radius burst

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: No

All magical effects and magic items within the radius of the spell, except for those that you carry or touch, are disjoined. That is, spells and spell-like effects are separated into their individual components (ending the effect as a dispel magic spell does), and each permanent magic item must make a successful Will save or be turned into a normal item. An item in a creature’s possession uses its own Will save bonus or its possessor’s Will save bonus, whichever is higher.

You also have a 1% chance per caster level of destroying an antimagic field. If the antimagic field survives the disjunction, no items within it are disjoined.

Even artifacts are subject to disjunction, though there is only a 1% chance per caster level of actually affecting such powerful items. Additionally, if an artifact is destroyed, you must make a DC 25 Will save or permanently lose all spellcasting abilities. (These abilities cannot be recovered by mortal magic, not even miracle or wish.)

Note: Destroying artifacts is a dangerous business, and it is 95% likely to attract the attention of some powerful being who has an interest in or connection with the device.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Magic 9, Sor/Wiz 9","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"All magical effects and magic items within a 40-ft.-radius burst","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_faithful_hound','Mage’s Faithful Hound','Sor/Wiz 5',5,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)','Phantom watchdog',NULL,'1 hour/caster level or until discharged, then 1 round/caster level; see text','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Phantom watchdog

Duration: 1 hour/caster level or until discharged, then 1 round/caster level; see text

Saving Throw: None

Spell Resistance: No

You conjure up a phantom watchdog that is invisible to everyone but yourself. It then guards the area where it was conjured (it does not move). The hound immediately starts barking loudly if any Small or larger creature approaches within 30 feet of it. (Those within 30 feet of the hound when it is conjured may move about in the area, but if they leave and return, they activate the barking.) The hound sees invisible and ethereal creatures. It does not react to figments, but it does react to shadow illusions.

If an intruder approaches to within 5 feet of the hound, the dog stops barking and delivers a vicious bite (+10 attack bonus, 2d6+3 points of piercing damage) once per round. The dog also gets the bonuses appropriate to an invisible creature.

The dog is considered ready to bite intruders, so it delivers its first bite on the intruder’s turn. Its bite is the equivalent of a magic weapon for the purpose of damage reduction. The hound cannot be attacked, but it can be dispelled.

The spell lasts for 1 hour per caster level, but once the hound begins barking, it lasts only 1 round per caster level. If you are ever more than 100 feet distant from the hound, the spell ends.

Material Component: A tiny silver whistle, a piece of bone, and a thread.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Phantom watchdog","Duration":"1 hour/caster level or until discharged, then 1 round/caster level; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_lucubration','Mage’s Lucubration','Wiz 6',6,'Transmutation','Personal','You',NULL,'Instantaneous','V, S',ARRAY['wizard']::text[],'Transmutation

Level: Wiz 6

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: Instantaneous

You instantly recall any one spell of 5th level or lower that you have used during the past 24 hours. The spell must have been actually cast during that period. The recalled spell is stored in your mind as through prepared in the normal fashion.

If the recalled spell requires material components, you must provide them. The recovered spell is not usable until the material components are available.','{"class_levels":{"wizard":6},"source_field_values":{"Level":"Wiz 6","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_magnificent_mansion','Mage’s Magnificent Mansion','Sor/Wiz 7',7,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)','Extradimensional mansion, up to three 10-ft. cubes/level (S)',NULL,'2 hours/level (D)','V, S, F',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 7

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Extradimensional mansion, up to three 10-ft. cubes/level (S)

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

You conjure up an extradimensional dwelling that has a single entrance on the plane from which the spell was cast. The entry point looks like a faint shimmering in the air that is 4 feet wide and 8 feet high. Only those you designate may enter the mansion, and the portal is shut and made invisible behind you when you enter. You may open it again from your own side at will. Once observers have passed beyond the entrance, they are in a magnificent foyer with numerous chambers beyond. The atmosphere is clean, fresh, and warm.

You can create any floor plan you desire to the limit of the spell’s effect. The place is furnished and contains sufficient foodstuffs to serve a nine-course banquet to a dozen people per caster level. A staff of near-transparent servants (as many as two per caster level), liveried and obedient, wait upon all who enter. The servants function as unseen servant spells except that they are visible and can go anywhere in the mansion.

Since the place can be entered only through its special portal, outside conditions do not affect the mansion, nor do conditions inside it pass to the plane beyond.

Focus: A miniature portal carved from ivory, a small piece of polished marble, and a tiny silver spoon (each item worth 5 gp).','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Extradimensional mansion, up to three 10-ft. cubes/level (S)","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_private_sanctum','Mage’s Private Sanctum','Sor/Wiz 5',5,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,'30-ft. cube/level (S)','24 hours (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Area: 30-ft. cube/level (S)

Duration: 24 hours (D)

Saving Throw: None

Spell Resistance: No

This spell ensures privacy. Anyone looking into the area from outside sees only a dark, foggy mass. Darkvision cannot penetrate it. No sounds, no matter how loud, can escape the area, so nobody can eavesdrop from outside. Those inside can see out normally.

Divination (scrying) spells cannot perceive anything within the area, and those within are immune to detect thoughts. The ward prevents speech between those inside and those outside (because it blocks sound), but it does not prevent other communication, such as a sending or message spell, or telepathic communication, such as that between a wizard and her familiar.

The spell does not prevent creatures or objects from moving into and out of the area.

Mage’s private sanctum can be made permanent with a permanency spell.

Material Component: A thin sheet of lead, a piece of opaque glass, a wad of cotton or cloth, and powdered chrysolite.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"30-ft. cube/level (S)","Duration":"24 hours (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mage_s_sword','Mage’s Sword','Sor/Wiz 7',7,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)','One sword',NULL,'1 round/level (D)','V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 7

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One sword

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: Yes

This spell brings into being a shimmering, swordlike plane of force. The sword strikes at any opponent within its range, as you desire, starting in the round that you cast the spell. The sword attacks its designated target once each round on your turn. Its attack bonus is equal to your caster level + your Int bonus or your Cha bonus (for wizards or sorcerers, respectively) with an additional +3 enhancement bonus. As a force effect, it can strike ethereal and incorporeal creatures. It deals 4d6+3 points of force damage, with a threat range of 19–20 and a critical multiplier of x2.

The sword always strikes from your direction. It does not get a bonus for flanking or help a combatant get one. If the sword goes beyond the spell range from you, if it goes out of your sight, or if you are not directing it, the sword returns to you and hovers.

Each round after the first, you can use a standard action to switch the sword to a new target. If you do not, the sword continues to attack the previous round’s target.

The sword cannot be attacked or harmed by physical attacks, but dispel magic, disintegrate, a sphere of annihilation, or a rod of cancellation affects it. The sword’s AC is 13 (10, +0 size bonus for Medium object, +3 deflection bonus).

If an attacked creature has spell resistance, the resistance is checked the first time Mage’s sword strikes it. If the sword is successfully resisted, the spell is dispelled. If not, the sword has its normal full effect on that creature for the duration of the spell.

Focus: A miniature platinum sword with a grip and pommel of copper and zinc. It costs 250 gp to construct.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One sword","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_aura','Magic Aura','Brd 1, Magic 1, Sor/Wiz 1',1,'Illusion (Glamer)','Touch','One touched object weighing up to 5 lb./level',NULL,'One day/level (D)','V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 1, Magic 1, Sor/Wiz 1

Components: V, S, F

Casting Time: 1 standard action

Range: Touch

Target: One touched object weighing up to 5 lb./level

Duration: One day/level (D)

Saving Throw: None; see text

Spell Resistance: No

You alter an item’s aura so that it registers to detect spells (and spells with similar capabilities) as though it were nonmagical, or a magic item of a kind you specify, or the subject of a spell you specify.

If the object bearing magic aura has identify cast on it or is similarly examined, the examiner recognizes that the aura is false and detects the object’s actual qualities if he succeeds on a Will save. Otherwise, he believes the aura and no amount of testing reveals what the true magic is.

If the targeted item’s own aura is exceptionally powerful (if it is an artifact, for instance), magic aura doesn’t work.

Note: A magic weapon, shield, or suit of armor must be a masterwork item, so a sword of average make, for example, looks suspicious if it has a magical aura.

Focus: A small square of silk that must be passed over the object that receives the aura.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Magic 1, Sor/Wiz 1","Components":"V, S, F","Casting Time":"1 standard action","Range":"Touch","Target":"One touched object weighing up to 5 lb./level","Duration":"One day/level (D)","Saving Throw":"None; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_circle_against_chaos','Magic Circle Against Chaos','Clr 3, Law 3, Pal 3, Sor/Wiz 3',3,'Abjuration [Lawful]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Abjuration \[Lawful\]

Level: Clr 3, Law 3, Pal 3, Sor/Wiz 3

This spell functions like magic circle against evil, except that it is similar to protection from chaos instead of protection from evil, and it can imprison a nonlawful called creature.','{"class_levels":{"cleric":3,"paladin":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 3, Law 3, Pal 3, Sor/Wiz 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_circle_against_evil','Magic Circle Against Evil','Clr 3, Good 3, Pal 3, Sor/Wiz 3',3,'Abjuration [Good]','Touch',NULL,'10-ft.-radius emanation from touched creature','10 min./level','V, S, M/DF',ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Abjuration \[Good\]

Level: Clr 3, Good 3, Pal 3, Sor/Wiz 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Area: 10-ft.-radius emanation from touched creature

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: No; see text

All creatures within the area gain the effects of a protection from evil spell, and no nongood summoned creatures can enter the area either. You must overcome a creature’s spell resistance in order to keep it at bay (as in the third function of protection from evil), but the deflection and resistance bonuses and the protection from mental control apply regardless of enemies’ spell resistance.

This spell has an alternative version that you may choose when casting it. A magic circle against evil can be focused inward rather than outward. When focused inward, the spell binds a nongood called creature (such as those called by the lesser planar binding, planar binding, and greater planar binding spells) for a maximum of 24 hours per caster level, provided that you cast the spell that calls the creature within 1 round of casting the magic circle. The creature cannot cross the circle’s boundaries. If a creature too large to fit into the spell’s area is the subject of the spell, the spell acts as a normal protection from evil spell for that creature only.

A magic circle leaves much to be desired as a trap. If the circle of powdered silver laid down in the process of spellcasting is broken, the effect immediately ends. The trapped creature can do nothing that disturbs the circle, directly or indirectly, but other creatures can. If the called creature has spell resistance, it can test the trap once a day. If you fail to overcome its spell resistance, the creature breaks free, destroying the circle. A creature capable of any form of dimensional travel (astral projection, blink, dimension door, etherealness, gate, plane shift, shadow walk, teleport, and similar abilities) can simply leave the circle through that means. You can prevent the creature’s extradimensional escape by casting a dimensional anchor spell on it, but you must cast the spell before the creature acts. If you are successful, the anchor effect lasts as long as the magic circle does. The creature cannot reach across the magic circle, but its ranged attacks (ranged weapons, spells, magical abilities, and the like) can. The creature can attack any target it can reach with its ranged attacks except for the circle itself.

You can add a special diagram (a two-dimensional bounded figure with no gaps along its circumference, augmented with various magical sigils) to make the magic circle more secure. Drawing the diagram by hand takes 10 minutes and requires a DC 20 Spellcraft check. You do not know the result of this check. If the check fails, the diagram is ineffective. You can take 10 when drawing the diagram if you are under no particular time pressure to complete the task. This task also takes 10 full minutes. If time is no factor at all, and you devote 3 hours and 20 minutes to the task, you can take 20.

A successful diagram allows you to cast a dimensional anchor spell on the magic circle during the round before casting any summoning spell. The anchor holds any called creatures in the magic circle for 24 hours per caster level. A creature cannot use its spell resistance against a magic circle prepared with a diagram, and none of its abilities or attacks can cross the diagram. If the creature tries a Charisma check to break free of the trap (see the lesser planar binding spell), the DC increases by 5. The creature is immediately released if anything disturbs the diagram—even a straw laid across it. However, the creature itself cannot disturb the diagram either directly or indirectly, as noted above.

This spell is not cumulative with protection from evil and vice versa.

Arcane Material Component: A little powdered silver with which you trace a 3-footdiameter circle on the floor (or ground) around the creature to be warded.','{"class_levels":{"cleric":3,"paladin":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 3, Good 3, Pal 3, Sor/Wiz 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Area":"10-ft.-radius emanation from touched creature","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"No; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_circle_against_good','Magic Circle Against Good','Clr 3, Evil 3, Sor/Wiz 3',3,'Abjuration [Evil]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration \[Evil\]

Level: Clr 3, Evil 3, Sor/Wiz 3

This spell functions like magic circle against evil, except that it is similar to protection from good instead of protection from evil, and it can imprison a nonevil called creature.','{"class_levels":{"cleric":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 3, Evil 3, Sor/Wiz 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_circle_against_law','Magic Circle Against Law','Chaos 3, Clr 3, Sor/Wiz 3',3,'Abjuration [Chaotic]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration \[Chaotic\]

Level: Chaos 3, Clr 3, Sor/Wiz 3

This spell functions like magic circle against evil, except that it is similar to protection from law instead of protection from evil, and it can imprison a nonchaotic called creature.','{"class_levels":{"cleric":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Chaos 3, Clr 3, Sor/Wiz 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_fang','Magic Fang','Drd 1, Rgr 1',1,'Transmutation','Touch','Living creature touched',NULL,'1 min./level','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 1, Rgr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

Magic fang gives one natural weapon of the subject a +1 enhancement bonus on attack and damage rolls. The spell can affect a slam attack, fist, bite, or other natural weapon. (The spell does not change an unarmed strike’s damage from nonlethal damage to lethal damage.)

Magic fang can be made permanent with a permanency spell.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_fang_greater','Magic Fang, Greater','Drd 3, Rgr 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'1 hour/level',NULL,ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 3, Rgr 3

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: 1 hour/level

This spell functions like magic fang, except that the enhancement bonus on attack and damage rolls is +1 per four caster levels (maximum +5).

Alternatively, you may imbue all of the creature’s natural weapons with a +1 enhancement bonus (regardless of your caster level).

Greater magic fang can be made permanent with a permanency spell.','{"class_levels":{"druid":3,"ranger":3},"source_field_values":{"Level":"Drd 3, Rgr 3","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"1 hour/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_jar','Magic Jar','Sor/Wiz 5',5,'Necromancy','Medium (100 ft. + 10 ft./level)','One creature',NULL,'1 hour/level or until you return to your body','V, S, F',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 5

Components: V, S, F

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One creature

Duration: 1 hour/level or until you return to your body

Saving Throw: Will negates; see text

Spell Resistance: Yes

By casting magic jar, you place your soul in a gem or large crystal (known as the magic jar), leaving your body lifeless. Then you can attempt to take control of a nearby body, forcing its soul into the magic jar. You may move back to the jar (thereby returning the trapped soul to its body) and attempt to possess another body. The spell ends when you send your soul back to your own body, leaving the receptacle empty.

To cast the spell, the magic jar must be within spell range and you must know where it is, though you do not need line of sight or line of effect to it. When you transfer your soul upon casting, your body is, as near as anyone can tell, dead.

While in the magic jar, you can sense and attack any life force within 10 feet per caster level (and on the same plane of existence). You do need line of effect from the jar to the creatures. You cannot determine the exact creature types or positions of these creatures. In a group of life forces, you can sense a difference of 4 or more Hit Dice between one creature and another and can determine whether a life force is powered by positive or negative energy. (Undead creatures are powered by negative energy. Only sentient undead creatures have, or are, souls.)

You could choose to take over either a stronger or a weaker creature, but which particular stronger or weaker creature you attempt to possess is determined randomly.

Attempting to possess a body is a full-round action. It is blocked by protection from evil or a similar ward. You possess the body and force the creature’s soul into the magic jar unless the subject succeeds on a Will save. Failure to take over the host leaves your life force in the magic jar, and the target automatically succeeds on further saving throws if you attempt to possess its body again.

If you are successful, your life force occupies the host body, and the host’s life force is imprisoned in the magic jar. You keep your Intelligence, Wisdom, Charisma, level, class, base attack bonus, base save bonuses, alignment, and mental abilities. The body retains its Strength, Dexterity, Constitution, hit points, natural abilities, and automatic abilities. A body with extra limbs does not allow you to make more attacks (or more advantageous two-weapon attacks) than normal. You can’t choose to activate the body’s extraordinary or supernatural abilities. The creature’s spells and spell-like abilities do not stay with the body.

As a standard action, you can shift freely from a host to the magic jar if within range, sending the trapped soul back to its body. The spell ends when you shift from the jar to your own body.

If the host body is slain, you return to the magic jar, if within range, and the life force of the host departs (it is dead). If the host body is slain beyond the range of the spell, both you and the host die. Any life force with nowhere to go is treated as slain.

If the spell ends while you are in the magic jar, you return to your body (or die if your body is out of range or destroyed). If the spell ends while you are in a host, you return to your body (or die, if it is out of range of your current position), and the soul in the magic jar returns to its body (or dies if it is out of range). Destroying the receptacle ends the spell, and the spell can be dispelled at either the magic jar or at the host’s location.

Focus: A gem or crystal worth at least 100 gp.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, F","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One creature","Duration":"1 hour/level or until you return to your body","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_magic_missile','Magic Missile','Sor/Wiz 1',1,'Evocation [Force]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: Up to five creatures, no two of which can be more than 15 ft. apart

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

A missile of magical energy darts forth from your fingertip and strikes its target, dealing 1d4+1 points of force damage.

The missile strikes unerringly, even if the target is in melee combat or has less than total cover or total concealment. Specific parts of a creature can’t be singled out. Inanimate objects are not damaged by the spell.

For every two caster levels beyond 1st, you gain an additional missile—two at 3rd level, three at 5th, four at 7th, and the maximum of five missiles at 9th level or higher. If you shoot multiple missiles, you can have them strike a single creature or several creatures. A single missile can strike only one creature. You must designate targets before you check for spell resistance or roll damage.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"Up to five creatures, no two of which can be more than 15 ft. apart","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_mouth','Magic Mouth','Brd 1, Sor/Wiz 2',1,'Illusion (Glamer)','Close (25 ft. + 5 ft./2 levels)','One creature or object',NULL,'Permanent until discharged','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 1, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature or object

Duration: Permanent until discharged

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This spell imbues the chosen object or creature with an enchanted mouth that suddenly appears and speaks its message the next time a specified event occurs. The message, which must be twenty-five or fewer words long, can be in any language known by you and can be delivered over a period of 10 minutes. The mouth cannot utter verbal components, use command words, or activate magical effects. It does, however, move according to the words articulated; if it were placed upon a statue, the mouth of the statue would move and appear to speak. Of course, magic mouth can be placed upon a tree, rock, or any other object or creature.

The spell functions when specific conditions are fulfilled according to your command as set in the spell. Commands can be as general or as detailed as desired, although only visual and audible triggers can be used. Triggers react to what appears to be the case. Disguises and illusions can fool them. Normal darkness does not defeat a visual trigger, but magical darkness or invisibility does. Silent movement or magical silence defeats audible triggers. Audible triggers can be keyed to general types of noises or to a specific noise or spoken word. Actions can serve as triggers if they are visible or audible. A magic mouth cannot distinguish alignment, level, Hit Dice, or class except by external garb.

The range limit of a trigger is 15 feet per caster level, so a 6th-level caster can command a magic mouth to respond to triggers as far as 90 feet away. Regardless of range, the mouth can respond only to visible or audible triggers and actions in line of sight or within hearing distance.

Magic mouth can be made permanent with a permanency spell.

Material Component: A small bit of honeycomb and jade dust worth 10 gp.','{"class_levels":{"bard":1,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 1, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature or object","Duration":"Permanent until discharged","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_stone','Magic Stone','Clr 1, Drd 1, Earth 1',1,'Transmutation','Touch',NULL,NULL,'30 minutes or until discharged','V, S, DF',ARRAY['cleric','druid']::text[],'Transmutation

Level: Clr 1, Drd 1, Earth 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: Up to three pebbles touched

Duration: 30 minutes or until discharged

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

You transmute as many as three pebbles, which can be no larger than sling bullets, so that they strike with great force when thrown or slung. If hurled, they have a range increment of 20 feet. If slung, treat them as sling bullets (range increment 50 feet). The spell gives them a +1 enhancement bonus on attack and damage rolls. The user of the stones makes a normal ranged attack. Each stone that hits deals 1d6+1 points of damage (including the spell’s enhancement bonus), or 2d6+2 points against undead.','{"class_levels":{"cleric":1,"druid":1},"source_field_values":{"Level":"Clr 1, Drd 1, Earth 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"Up to three pebbles touched","Duration":"30 minutes or until discharged","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_vestment','Magic Vestment','Clr 3, Strength 3, War 3',3,'Transmutation','Touch','Armor or shield touched',NULL,'1 hour/level','V, S, DF',ARRAY['cleric']::text[],'Transmutation

Level: Clr 3, Strength 3, War 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Armor or shield touched

Duration: 1 hour/level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

You imbue a suit of armor or a shield with an enhancement bonus of +1 per four caster levels (maximum +5 at 20th level).

An outfit of regular clothing counts as armor that grants no AC bonus for the purpose of this spell.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3, Strength 3, War 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Armor or shield touched","Duration":"1 hour/level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_weapon','Magic Weapon','Clr 1, Pal 1, Sor/Wiz 1, War 1',1,'Transmutation','Touch','Weapon touched',NULL,'1 min./level','V, S, DF',ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Transmutation

Level: Clr 1, Pal 1, Sor/Wiz 1, War 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Weapon touched

Duration: 1 min./level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

Magic weapon gives a weapon a +1 enhancement bonus on attack and damage rolls. (An enhancement bonus does not stack with a masterwork weapon’s +1 bonus on attack rolls.)

You can’t cast this spell on a natural weapon, such as an unarmed strike (instead, see magic fang). A monk’s unarmed strike is considered a weapon, and thus it can be enhanced by this spell.','{"class_levels":{"cleric":1,"paladin":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Pal 1, Sor/Wiz 1, War 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Weapon touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_magic_weapon_greater','Magic Weapon, Greater','Clr 4, Pal 3, Sor/Wiz 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One weapon or fifty projectiles (all of which must be in contact with each other at the time of casting)',NULL,'1 hour/level','V, S, M/DF',ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Transmutation

Level: Clr 4, Pal 3, Sor/Wiz 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One weapon or fifty projectiles (all of which must be in contact with each other at the time of casting)

Duration: 1 hour/level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

This spell functions like magic weapon, except that it gives a weapon an enhancement bonus on attack and damage rolls of +1 per four caster levels (maximum +5).

Alternatively, you can affect as many as fifty arrows, bolts, or bullets. The projectiles must be of the same kind, and they have to be together (in the same quiver or other container). Projectiles, but not thrown weapons, lose their transmutation when used. (Treat shuriken as projectiles, rather than as thrown weapons, for the purpose of this spell.)

Arcane Material Component: Powdered lime and carbon.','{"class_levels":{"cleric":4,"paladin":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 4, Pal 3, Sor/Wiz 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One weapon or fifty projectiles (all of which must be in contact with each other at the time of casting)","Duration":"1 hour/level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_major_creation','Major Creation','Sor/Wiz 5',5,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'See text',NULL,ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 5

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Duration: See text

This spell functions like minor creation, except that you can also create an object of mineral nature: stone, crystal, metal, or the like. The duration of the created item varies with its relative hardness and rarity, as indicated on the following table.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Hardness and Rarity Examples</th><th>Duration</th></tr><tr><td>Vegetable matter</td><td>2 hr./level</td></tr><tr><td>Stone, crystal, base metals</td><td>1 hr./level</td></tr><tr><td>Precious metals</td><td>20 min./level</td></tr><tr><td>Gems</td><td>10 min./level</td></tr><tr><td>Rare metal<sup>1</sup></td><td>1 round/level</td></tr><tr><td colspan="2">1 Includes adamantine, alchemical silver, and mithral. You can’t use major creation to create a cold iron item.</td></tr></tbody></table>','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Duration":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_major_image','Major Image','Brd 3, Sor/Wiz 3',3,'Illusion (Figment)',NULL,NULL,NULL,'Concentration + 3 rounds',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 3, Sor/Wiz 3

Duration: Concentration + 3 rounds

This spell functions like silent image, except that sound, smell, and thermal illusions are included in the spell effect. While concentrating, you can move the image within the range.

The image disappears when struck by an opponent unless you cause the illusion to react appropriately.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Duration":"Concentration + 3 rounds"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_make_whole','Make Whole','Clr 2',2,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One object of up to 10 cu. ft./ level',NULL,NULL,NULL,ARRAY['cleric']::text[],'Transmutation

Level: Clr 2

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One object of up to 10 cu. ft./ level

This spell functions like mending, except that make whole completely repairs an object made of any substance, even one with multiple breaks, to be as strong as new. The spell does not restore the magical abilities of a broken magic item made whole, and it cannot mend broken magic rods, staffs, or wands. The spell does not repair items that have been warped, burned, disintegrated, ground to powder, melted, or vaporized, nor does it affect creatures (including constructs).','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One object of up to 10 cu. ft./ level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mark_of_justice','Mark of Justice','Clr 5, Pal 4',4,'Necromancy','Touch','Creature touched',NULL,'Permanent; see text','V, S, DF',ARRAY['cleric','paladin']::text[],'Necromancy

Level: Clr 5, Pal 4

Components: V, S, DF

Casting Time: 10 minutes

Range: Touch

Target: Creature touched

Duration: Permanent; see text

Saving Throw: None

Spell Resistance: Yes

You draw an indelible mark on the subject and state some behavior on the part of the subject that will activate the mark. When activated, the mark curses the subject. Typically, you designate some sort of criminal behavior that activates the mark, but you can pick any act you please. The effect of the mark is identical with the effect of bestow curse.

Since this spell takes 10 minutes to cast and involves writing on the target, you can cast it only on a creature that is willing or restrained.

Like the effect of bestow curse, a mark of justice cannot be dispelled, but it can be removed with a break enchantment, limited wish, miracle, remove curse, or wish spell. Remove curse works only if its caster level is equal to or higher than your mark of justice caster level. These restrictions apply regardless of whether the mark has activated.','{"class_levels":{"cleric":5,"paladin":4},"source_field_values":{"Level":"Clr 5, Pal 4","Components":"V, S, DF","Casting Time":"10 minutes","Range":"Touch","Target":"Creature touched","Duration":"Permanent; see text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_maze','Maze','Sor/Wiz 8',8,'Conjuration (Teleportation)','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'See text','V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: See text

Saving Throw: None

Spell Resistance: Yes

You banish the subject into an extradimensional labyrinth of force planes. Each round on its turn, it may attempt a DC 20 Intelligence check to escape the labyrinth as a full-round action. If the subject doesn’t escape, the maze disappears after 10 minutes, forcing the subject to leave.

On escaping or leaving the maze, the subject reappears where it had been when the maze spell was cast. If this location is filled with a solid object, the subject appears in the nearest open space. Spells and abilities that move a creature within a plane, such as teleport and dimension door, do not help a creature escape a maze spell, although a plane shift spell allows it to exit to whatever plane is designated in that spell. Minotaurs are not affected by this spell.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"See text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_meld_into_stone','Meld Into Stone','Clr 3, Drd 3',3,'Transmutation [Earth]','Personal','You',NULL,'10 min./level','V, S, DF',ARRAY['cleric','druid']::text[],'Transmutation \[Earth\]

Level: Clr 3, Drd 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level

Meld into stone enables you to meld your body and possessions into a single block of stone. The stone must be large enough to accommodate your body in all three dimensions. When the casting is complete, you and not more than 100 pounds of nonliving gear merge with the stone. If either condition is violated, the spell fails and is wasted.

While in the stone, you remain in contact, however tenuous, with the face of the stone through which you melded. You remain aware of the passage of time and can cast spells on yourself while hiding in the stone. Nothing that goes on outside the stone can be seen, but you can still hear what happens around you. Minor physical damage to the stone does not harm you, but its partial destruction (to the extent that you no longer fit within it) expels you and deals you 5d6 points of damage. The stone’s complete destruction expels you and slays you instantly unless you make a DC 18 Fortitude save.

Any time before the duration expires, you can step out of the stone through the surface that you entered. If the spell’s duration expires or the effect is dispelled before you voluntarily exit the stone, you are violently expelled and take 5d6 points of damage.

The following spells harm you if cast upon the stone that you are occupying: Stone to flesh expels you and deals you 5d6 points of damage. Stone shape deals you 3d6 points of damage but does not expel you. Transmute rock to mud expels you and then slays you instantly unless you make a DC 18 Fortitude save, in which case you are merely expelled. Finally, passwall expels you without damage.','{"class_levels":{"cleric":3,"druid":3},"source_field_values":{"Level":"Clr 3, Drd 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mending','Mending','Brd 0, Clr 0, Drd 0, Sor/Wiz 0',0,'Transmutation','10 ft.','One object of up to 1 lb.',NULL,'Instantaneous','V, S',ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Brd 0, Clr 0, Drd 0, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: 10 ft.

Target: One object of up to 1 lb.

Duration: Instantaneous

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

Mending repairs small breaks or tears in objects (but not warps, such as might be caused by a warp wood spell). It will weld broken metallic objects such as a ring, a chain link, a medallion, or a slender dagger, providing but one break exists.

Ceramic or wooden objects with multiple breaks can be invisibly rejoined to be as strong as new. A hole in a leather sack or a wineskin is completely healed over by mending. The spell can repair a magic item, but the item’s magical abilities are not restored. The spell cannot mend broken magic rods, staffs, or wands, nor does it affect creatures (including constructs).','{"class_levels":{"bard":0,"cleric":0,"druid":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Clr 0, Drd 0, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"10 ft.","Target":"One object of up to 1 lb.","Duration":"Instantaneous","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_message','Message','Brd 0, Sor/Wiz 0',0,'Transmutation [Language-Dependent]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'10 min./level','V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation \[Language-Dependent\]

Level: Brd 0, Sor/Wiz 0

Components: V, S, F

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: One creature/level

Duration: 10 min./level

Saving Throw: None

Spell Resistance: No

You can whisper messages and receive whispered replies with little chance of being overheard. You point your finger at each creature you want to receive the message. When you whisper, the whispered message is audible to all targeted creatures within range. Magical silence, 1 foot of stone, 1 inch of common metal (or a thin sheet of lead), or 3 feet of wood or dirt blocks the spell. The message does not have to travel in a straight line. It can circumvent a barrier if there is an open path between you and the subject, and the path’s entire length lies within the spell’s range. The creatures that receive the message can whisper a reply that you hear. The spell transmits sound, not meaning. It doesn’t transcend language barriers.

Note: To speak a message, you must mouth the words and whisper, possibly allowing observers the opportunity to read your lips.

Focus: A short piece of copper wire.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S, F","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One creature/level","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_meteor_swarm','Meteor Swarm','Sor/Wiz 9',9,'Evocation [Fire]','Long (400 ft. + 40 ft./level)',NULL,'Four 40-ft.-radius spreads; see text','Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Sor/Wiz 9

Components: V, S

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Four 40-ft.-radius spreads; see text

Duration: Instantaneous

Saving Throw: None or Reflex half; see text

Spell Resistance: Yes

Meteor swarm is a very powerful and spectacular spell that is similar to fireball in many aspects. When you cast it, four 2- foot-diameter spheres spring from your outstretched hand and streak in straight lines to the spots you select. The meteor spheres leave a fiery trail of sparks.

If you aim a sphere at a specific creature, you may make a ranged touch attack to strike the target with the meteor. Any creature struck by one of these spheres takes 2d6 points of bludgeoning damage (no save) and receives no saving throw against the sphere’s fire damage (see below). If a targeted sphere misses its target, it simply explodes at the nearest corner of the target’s space. You may aim more than one meteor at the same target.

Once a sphere reaches its destination, it explodes in a 40-foot-radius spread, dealing 6d6 points of fire damage to each creature in the area. If a creature is within the area of more than one sphere, it must save separately against each. (Fire resistance applies to each sphere’s damage individually.)','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Components":"V, S","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Four 40-ft.-radius spreads; see text","Duration":"Instantaneous","Saving Throw":"None or Reflex half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mind_blank','Mind Blank','Protection 8, Sor/Wiz 8',8,'Abjuration','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'24 hours','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Protection 8, Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: 24 hours

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject is protected from all devices and spells that detect, influence, or read emotions or thoughts. This spell protects against all mind-affecting spells and effects as well as information gathering by divination spells or effects. Mind blank even foils limited wish, miracle, and wish spells when they are used in such a way as to affect the subject’s mind or to gain information about it. In the case of scrying that scans an area the creature is in, such as arcane eye, the spell works but the creature simply isn’t detected. Scrying attempts that are targeted specifically at the subject do not work at all.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Protection 8, Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"24 hours","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mind_fog','Mind Fog','Brd 5, Sor/Wiz 5',5,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','Fog spreads in 20-ft. radius, 20 ft. high',NULL,'30 minutes and 2d6 rounds; see text','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Fog spreads in 20-ft. radius, 20 ft. high

Duration: 30 minutes and 2d6 rounds; see text

Saving Throw: Will negates

Spell Resistance: Yes

Mind fog produces a bank of thin mist that weakens the mental resistance of those caught in it. Creatures in the mind fog take a –10 competence penalty on Wisdom checks and Will saves. (A creature that successfully saves against the fog is not affected and need not make further saves even if it remains in the fog.) Affected creatures take the penalty as long as they remain in the fog and for 2d6 rounds thereafter. The fog is stationary and lasts for 30 minutes (or until dispersed by wind).

A moderate wind (11+ mph) disperses the fog in four rounds; a strong wind (21+ mph) disperses the fog in 1 round.

The fog is thin and does not significantly hamper vision.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Fog spreads in 20-ft. radius, 20 ft. high","Duration":"30 minutes and 2d6 rounds; see text","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_minor_creation','Minor Creation','Sor/Wiz 4',4,'Conjuration (Creation)','0 ft.','Unattended, nonmagical object of nonliving plant matter, up to 1 cu. ft./level',NULL,'1 hour/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 minute

Range: 0 ft.

Effect: Unattended, nonmagical object of nonliving plant matter, up to 1 cu. ft./level

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

You create a nonmagical, unattended object of nonliving, vegetable matter. The volume of the item created cannot exceed 1 cubic foot per caster level. You must succeed on an appropriate skill check to make a complex item.

Attempting to use any created object as a material component causes the spell to fail.

Material Component: A tiny piece of matter of the same sort of item you plan to create with minor creation.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 minute","Range":"0 ft.","Effect":"Unattended, nonmagical object of nonliving plant matter, up to 1 cu. ft./level","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_minor_image','Minor Image','Brd 2, Sor/Wiz 2',2,'Illusion (Figment)',NULL,NULL,NULL,'Concentration +2 rounds',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 2, Sor/Wiz 2

Duration: Concentration +2 rounds

This spell functions like silent image, except that minor image includes some minor sounds but not understandable speech.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Duration":"Concentration +2 rounds"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_miracle','Miracle','Clr 9, Luck 9',9,'Evocation','See text',NULL,NULL,'See text','V, S, XP; see text',ARRAY['cleric']::text[],'Evocation

Level: Clr 9, Luck 9

Components: V, S, XP; see text

Casting Time: 1 standard action

Range: See text

Target, Effect, or Area: See text

Duration: See text

Saving Throw: See text

Spell Resistance: Yes

You don’t so much cast a miracle as request one. You state what you would like to have happen and request that your deity (or the power you pray to for spells) intercede.

A miracle can do any of the following things.

- Duplicate any cleric spell of 8th level or lower (including spells to which you have access because of your domains).
- Duplicate any other spell of 7th level or lower.
- Undo the harmful effects of certain spells, such as feeblemind or insanity.
- Have any effect whose power level is in line with the above effects.  
  If the miracle has any of the above effects, casting it has no experience point cost.  
  Alternatively, a cleric can make a very powerful request. Casting such a miracle costs the cleric 5,000 XP because of the powerful divine energies involved. Examples of especially powerful miracles of this sort could include the following.
- Swinging the tide of a battle in your favor by raising fallen allies to continue fighting.
- Moving you and your allies, with all your and their gear, from one plane to another through planar barriers to a specific locale with no chance of error.
- Protecting a city from an earthquake, volcanic eruption, flood, or other major natural disaster.

In any event, a request that is out of line with the deity’s (or alignment’s) nature is refused.

A duplicated spell allows saving throws and spell resistance as normal, but the save DCs are as for a 9th-level spell. When a miracle duplicates a spell that has an XP cost, you must pay that cost. When a miracle spell duplicates a spell with a material component that costs more than 100 gp, you must provide that component.

XP Cost: 5,000 XP (for some uses of the miracle spell; see above).','{"class_levels":{"cleric":9},"source_field_values":{"Level":"Clr 9, Luck 9","Components":"V, S, XP; see text","Casting Time":"1 standard action","Range":"See text","Target, Effect, or Area":"See text","Duration":"See text","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mirage_arcana','Mirage Arcana','Brd 5, Sor/Wiz 5',5,'Illusion (Glamer)',NULL,NULL,'One 20-ft. cube/level (S)','Concentration +1 hour/ level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Area: One 20-ft. cube/level (S)

Duration: Concentration +1 hour/ level (D)

This spell functions like hallucinatory terrain, except that it enables you to make any area appear to be something other than it is. The illusion includes audible, visual, tactile, and olfactory elements. Unlike hallucinatory terrain, the spell can alter the appearance of structures (or add them where none are present). Still, it can’t disguise, conceal, or add creatures (though creatures within the area might hide themselves within the illusion just as they can hide themselves within a real location).','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Area":"One 20-ft. cube/level (S)","Duration":"Concentration +1 hour/ level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mirror_image','Mirror Image','Brd 2, Sor/Wiz 2',2,'Illusion (Figment)','Personal; see text','You',NULL,'1 min./level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 2, Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Personal; see text

Target: You

Duration: 1 min./level (D)

Several illusory duplicates of you pop into being, making it difficult for enemies to know which target to attack. The figments stay near you and disappear when struck.

Mirror image creates 1d4 images plus one image per three caster levels (maximum eight images total). These figments separate from you and remain in a cluster, each within 5 feet of at least one other figment or you. You can move into and through a mirror image. When you and the mirror image separate, observers can’t use vision or hearing to tell which one is you and which the image. The figments may also move through each other. The figments mimic your actions, pretending to cast spells when you cast a spell, drink potions when you drink a potion, levitate when you levitate, and so on.

Enemies attempting to attack you or cast spells at you must select from among indistinguishable targets. Generally, roll randomly to see whether the selected target is real or a figment. Any successful attack against an image destroys it. An image’s AC is 10 + your size modifier + your Dex modifier. Figments seem to react normally to area spells (such as looking like they’re burned or dead after being hit by a fireball).

While moving, you can merge with and split off from figments so that enemies who have learned which image is real are again confounded.

An attacker must be able to see the images to be fooled. If you are invisible or an attacker shuts his or her eyes, the spell has no effect. (Being unable to see carries the same penalties as being blinded.)','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Personal; see text","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_misdirection','Misdirection','Brd 2, Sor/Wiz 2',2,'Illusion (Glamer)','Close (25 ft. + 5 ft./2 levels)','One creature or object, up to a 10-ft. cube in size',NULL,'1 hour/level','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 2, Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature or object, up to a 10-ft. cube in size

Duration: 1 hour/level

Saving Throw: None or Will negates; see text

Spell Resistance: No

By means of this spell, you misdirect the information from divination spells that reveal auras (detect evil, detect magic, discern lies, and the like). On casting the spell, you choose another object within range. For the duration of the spell, the subject of misdirection is detected as if it were the other object. (Neither the subject nor the other object gets a saving throw against this effect.) Detection spells provide information based on the second object rather than on the actual target of the detection unless the caster of the detection succeeds on a Will save. For instance, you could make yourself detect as a tree if one were within range at casting: not evil, not lying, not magical, neutral in alignment, and so forth. This spell does not affect other types of divination magic (augury, detect thoughts, clairaudience/clairvoyance, and the like).','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature or object, up to a 10-ft. cube in size","Duration":"1 hour/level","Saving Throw":"None or Will negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mislead','Mislead','Brd 5, Luck 6, Sor/Wiz 6, Trickery 6',5,'Illusion (Figment, Glamer)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level (D) and concentration + 3 rounds; see text','S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment, Glamer)

Level: Brd 5, Luck 6, Sor/Wiz 6, Trickery 6

Components: S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target/Effect: You/one illusory double

Duration: 1 round/level (D) and concentration + 3 rounds; see text

Saving Throw: None or Will disbelief (if interacted with); see text

Spell Resistance: No

You become invisible (as improved invisibility, a glamer), and at the same time, an illusory double of you (as major image, a figment) appears. You are then free to go elsewhere while your double moves away. The double appears within range but thereafter moves as you direct it (which requires concentration beginning on the first round after the casting). You can make the figment appear superimposed perfectly over your own body so that observers don’t notice an image appearing and you turning invisible. You and the figment can then move in different directions. The double moves at your speed and can talk and gesture as if it were real, but it cannot attack or cast spells, though it can pretend to do so.

The illusory double lasts as long as you concentrate upon it, plus 3 additional rounds. After you cease concentration, the illusory double continues to carry out the same activity until the duration expires. The improved invisibility lasts for 1 round per level, regardless of concentration.','{"class_levels":{"bard":5,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 5, Luck 6, Sor/Wiz 6, Trickery 6","Components":"S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target/Effect":"You/one illusory double","Duration":"1 round/level (D) and concentration + 3 rounds; see text","Saving Throw":"None or Will disbelief (if interacted with); see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mnemonic_enhancer','Mnemonic Enhancer','Wiz 4',4,'Transmutation','Personal','You',NULL,'Instantaneous','V, S, M, F',ARRAY['wizard']::text[],'Transmutation

Level: Wiz 4

Components: V, S, M, F

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: Instantaneous

Casting this spell allows you to prepare additional spells or retain spells recently cast. Pick one of these two versions when the spell is cast.

Prepare: You prepare up to three additional levels of spells. A cantrip counts as 1/2 level for this purpose. You prepare and cast these spells normally.

Retain: You retain any spell of 3rd level or lower that you had cast up to 1 round before you started casting the mnemonic enhancer. This restores the previously cast spell to your mind.

In either event, the spell or spells prepared or retained fade after 24 hours (if not cast).

Material Component: A piece of string, and ink consisting of squid secretion with black dragon’s blood.

Focus: An ivory plaque of at least 50 gp value.','{"class_levels":{"wizard":4},"source_field_values":{"Level":"Wiz 4","Components":"V, S, M, F","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_modify_memory','Modify Memory','Brd 4',4,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'Permanent','V, S',ARRAY['bard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 4

Components: V, S

Casting Time: 1 round; see text

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: Permanent

Saving Throw: Will negates

Spell Resistance: Yes

You reach into the subject’s mind and modify as many as 5 minutes of its memories in one of the following ways.

- Eliminate all memory of an event the subject actually experienced. This spell cannot negate charm, geas/quest, suggestion, or similar spells.
- Allow the subject to recall with perfect clarity an event it actually experienced.
- Change the details of an event the subject actually experienced.
- Implant a memory of an event the subject never experienced.

Casting the spell takes 1 round. If the subject fails to save, you proceed with the spell by spending as much as 5 minutes (a period of time equal to the amount of memory time you want to modify) visualizing the memory you wish to modify in the subject. If your concentration is disturbed before the visualization is complete, or if the subject is ever beyond the spell’s range during this time, the spell is lost.

A modified memory does not necessarily affect the subject’s actions, particularly if it contradicts the creature’s natural inclinations. An illogical modified memory is dismissed by the creature as a bad dream or a memory muddied by too much wine.','{"class_levels":{"bard":4},"source_field_values":{"Level":"Brd 4","Components":"V, S","Casting Time":"1 round; see text","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"Permanent","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_moment_of_prescience','Moment of Prescience','Luck 8, Sor/Wiz 8',8,'Divination','Personal','You',NULL,'1 hour/level or until discharged','V, S',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Luck 8, Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 hour/level or until discharged

This spell grants you a powerful sixth sense in relation to yourself. Once during the spell’s duration, you may choose to use its effect. This spell grants you an insight bonus equal to your caster level (maximum +25) on any single attack roll, opposed ability or skill check, or saving throw. Alternatively, you can apply the insight bonus to your AC against a single attack (even if flatfooted). Activating the effect doesn’t take an action; you can even activate it on another character’s turn if needed. You must choose to use the moment of prescience before you make the roll it is to modify. Once used, the spell ends.

You can’t have more than one moment of prescience active on you at the same time.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Luck 8, Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 hour/level or until discharged"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_mount','Mount','Sor/Wiz 1',1,'Conjuration (Summoning)','Close (25 ft. + 5 ft./2 levels)','One mount',NULL,'2 hours/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Summoning)

Level: Sor/Wiz 1

Components: V, S, M

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One mount

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

You summon a light horse or a pony (your choice) to serve you as a mount. The steed serves willingly and well. The mount comes with a bit and bridle and a riding saddle.

Material Component: A bit of horse hair.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One mount","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_move_earth','Move Earth','Drd 6, Sor/Wiz 6',6,'Transmutation [Earth]','Long (400 ft. + 40 ft./level)',NULL,'Dirt in an area up to 750 ft. square and up to 10 ft. deep (S)','Instantaneous','V, S, M',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation \[Earth\]

Level: Drd 6, Sor/Wiz 6

Components: V, S, M

Casting Time: See text

Range: Long (400 ft. + 40 ft./level)

Area: Dirt in an area up to 750 ft. square and up to 10 ft. deep (S)

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

Move earth moves dirt (clay, loam, sand), possibly collapsing embankments, moving hillocks, shifting dunes, and so forth.

However, in no event can rock formations be collapsed or moved. The area to be affected determines the casting time. For every 150-foot square (up to 10 feet deep), casting takes 10 minutes. The maximum area, 750 feet by 750 feet, takes 4 hours and 10 minutes to move.

This spell does not violently break the surface of the ground. Instead, it creates wavelike crests and troughs, with the earth reacting with glacierlike fluidity until the desired result is achieved. Trees, structures, rock formations, and such are mostly unaffected except for changes in elevation and relative topography.

The spell cannot be used for tunneling and is generally too slow to trap or bury creatures. Its primary use is for digging or filling moats or for adjusting terrain contours before a battle.

This spell has no effect on earth creatures.

Material Component: A mixture of soils (clay, loam, and sand) in a small bag, and an iron blade.','{"class_levels":{"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Drd 6, Sor/Wiz 6","Components":"V, S, M","Casting Time":"See text","Range":"Long (400 ft. + 40 ft./level)","Area":"Dirt in an area up to 750 ft. square and up to 10 ft. deep (S)","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_neutralize_poison','Neutralize Poison','Brd 4, Clr 4, Drd 3, Pal 4, Rgr 3',3,'Conjuration (Healing)','Touch','Creature or object of up to 1 cu. ft./level touched',NULL,'10 min./level','V, S, M/DF',ARRAY['bard','cleric','druid','paladin','ranger']::text[],'Conjuration (Healing)

Level: Brd 4, Clr 4, Drd 3, Pal 4, Rgr 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature or object of up to 1 cu. ft./level touched

Duration: 10 min./level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

You detoxify any sort of venom in the creature or object touched. A poisoned creature suffers no additional effects from the poison, and any temporary effects are ended, but the spell does not reverse instantaneous effects, such as hit point damage, temporary ability damage, or effects that don’t go away on their own.

The creature is immune to any poison it is exposed to during the duration of the spell. Unlike with delay poison, such effects aren’t postponed until after the duration —the creature need not make any saves against poison effects applied to it during the length of the spell.

This spell can instead neutralize the poison in a poisonous creature or object for the duration of the spell, at the caster’s option.

Arcane Material Component: A bit of charcoal.','{"class_levels":{"bard":4,"cleric":4,"druid":3,"paladin":4,"ranger":3},"source_field_values":{"Level":"Brd 4, Clr 4, Drd 3, Pal 4, Rgr 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature or object of up to 1 cu. ft./level touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_nightmare','Nightmare','Brd 5, Sor/Wiz 5',5,'Illusion (Phantasm) [Mind-Affecting, Evil]','Unlimited','One living creature',NULL,'Instantaneous','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Phantasm) \[Mind-Affecting, Evil\]

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 10 minutes

Range: Unlimited

Target: One living creature

Duration: Instantaneous

Saving Throw: Will negates; see text

Spell Resistance: Yes

You send a hideous and unsettling phantasmal vision to a specific creature that you name or otherwise specifically designate.

The nightmare prevents restful sleep and causes 1d10 points of damage. The nightmare leaves the subject fatigued and unable to regain arcane spells for the next 24 hours.

The difficulty of the save depends on how well you know the subject and what sort of physical connection (if any) you have to that creature.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Knowledge</th><th>Will Save Modifier</th></tr><tr><td>None<sup>1</sup></td><td>+10</td></tr><tr><td>Secondhand (you have heard of the subject)</td><td>+5</td></tr><tr><td>Firsthand (you have met the subject)</td><td>+0</td></tr><tr><td>Familiar (you know the subject well)</td><td>–5</td></tr><tr><td colspan="2">1 You must have some sort of connection to a creature you have no knowledge of.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Connection</th><th>Will Save Modifier</th></tr><tr><td>Likeness or picture</td><td>–2</td></tr><tr><td>Possession or garment</td><td>–4</td></tr><tr><td>Body part, lock of hair, bit of nail, etc.</td><td>–10</td></tr></tbody></table>

Dispel evil cast on the subject while you are casting the spell dispels the nightmare and causes you to be stunned for 10 minutes per caster level of the dispel evil.

If the recipient is awake when the spell begins, you can choose to cease casting (ending the spell) or to enter a trance until the recipient goes to sleep, whereupon you become alert again and complete the casting. If you are disturbed during the trance, you must succeed on a Concentration check as if you were in the midst of casting a spell or the spell ends.

If you choose to enter a trance, you are not aware of your surroundings or the activities around you while in the trance.

You are defenseless, both physically and mentally, while in the trance. (You always fail any saving throw, for example.)

Creatures who don’t sleep (such as elves, but not half-elves) or dream are immune to this spell.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"10 minutes","Range":"Unlimited","Target":"One living creature","Duration":"Instantaneous","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_nondetection','Nondetection','Rgr 4, Sor/Wiz 3, Trickery 3',3,'Abjuration','Touch','Creature or object touched',NULL,'1 hour/level','V, S, M',ARRAY['ranger','sorcerer','wizard']::text[],'Abjuration

Level: Rgr 4, Sor/Wiz 3, Trickery 3

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature or object touched

Duration: 1 hour/level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

The warded creature or object becomes difficult to detect by divination spells such as clairaudience/clairvoyance, locate object, and detect spells. Nondetection also prevents location by such magic items as crystal balls.\If a divination is attempted against the warded creature or item, the caster of the divination must succeed on a caster level check (1d20 + caster level) against a DC of 11 + the caster level of the spellcaster who cast \_nondetection. If you cast nondetection on yourself or on an item currently in your possession, the DC is 15 + your caster level.

If cast on a creature, nondetection wards the creature’s gear as well as the creature itself.

Material Component:_ A pinch of diamond dust worth 50 gp.','{"class_levels":{"ranger":4,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Rgr 4, Sor/Wiz 3, Trickery 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature or object touched","Duration":"1 hour/level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_obscure_object','Obscure Object','Brd 1, Clr 3, Sor/Wiz 2',1,'Abjuration','Touch','One object touched of up to 100 lb./level',NULL,'8 hours (D)','V, S, M/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Abjuration

Level: Brd 1, Clr 3, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: One object touched of up to 100 lb./level

Duration: 8 hours (D)

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This spell hides an object from location by divination (scrying) effects, such as the scrying spell or a crystal ball. Such an attempt automatically fails (if the divination is targeted on the object) or fails to perceive the object (if the divination is targeted on a nearby location, object, or person).

Arcane Material Component: A piece of chameleon skin.','{"class_levels":{"bard":1,"cleric":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 1, Clr 3, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"One object touched of up to 100 lb./level","Duration":"8 hours (D)","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_obscuring_mist','Obscuring Mist','Air 1, Clr 1, Drd 1, Sor/Wiz 1, Water 1',1,'Conjuration (Creation)','20 ft.','Cloud spreads in 20-ft. radius from you, 20 ft. high',NULL,'1 min./level','V, S',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Air 1, Clr 1, Drd 1, Sor/Wiz 1, Water 1

Components: V, S

Casting Time: 1 standard action

Range: 20 ft.

Effect: Cloud spreads in 20-ft. radius from you, 20 ft. high

Duration: 1 min./level

Saving Throw: None

Spell Resistance: No

A misty vapor arises around you. It is stationary once created. The vapor obscures all sight, including darkvision, beyond 5 feet. A creature 5 feet away has concealment (attacks have a 20% miss chance). Creatures farther away have total concealment (50% miss chance, and the attacker cannot use sight to locate the target).

A moderate wind (11+ mph), such as from a gust of wind spell, disperses the fog in 4 rounds. A strong wind (21+ mph) disperses the fog in 1 round. A fireball, flame strike, or similar spell burns away the fog in the explosive or fiery spell’s area. A wall of fire burns away the fog in the area into which it deals damage.

This spell does not function underwater.','{"class_levels":{"cleric":1,"druid":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Air 1, Clr 1, Drd 1, Sor/Wiz 1, Water 1","Components":"V, S","Casting Time":"1 standard action","Range":"20 ft.","Effect":"Cloud spreads in 20-ft. radius from you, 20 ft. high","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_open_close','Open/Close','Brd 0, Sor/Wiz 0',0,'Transmutation','Close (25 ft. + 5 ft./2 levels)','Object weighing up to 30 lb. or portal that can be opened or closed',NULL,'Instantaneous','V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 0, Sor/Wiz 0

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: Object weighing up to 30 lb. or portal that can be opened or closed

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You can open or close (your choice) a door, chest, box, window, bag, pouch, bottle, barrel, or other container. If anything resists this activity (such as a bar on a door or a lock on a chest), the spell fails. In addition, the spell can only open and close things weighing 30 pounds or less. Thus, doors, chests, and similar objects sized for enormous creatures may be beyond this spell’s ability to affect.

Focus: A brass key.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Object weighing up to 30 lb. or portal that can be opened or closed","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_overland_flight','Overland Flight','Sor/Wiz 5',5,'Transmutation','Personal','You',NULL,'1 hour/level','V, S',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 5

Components: V, S

Range: Personal

Target: You

Duration: 1 hour/level

This spell functions like a fly spell, except you can fly at a speed of 40 feet (30 feet if wearing medium or heavy armor, or if carrying a medium or heavy load) with average maneuverability. When using this spell for long-distance movement, you can hustle without taking nonlethal damage (a forced march still requires Constitution checks). This means you can cover 64 miles in an eight-hour period of flight (or 48 miles at a speed of 30 feet).','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S","Range":"Personal","Target":"You","Duration":"1 hour/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_owl_s_wisdom','Owl’s Wisdom','Clr 2, Drd 2, Pal 2, Rgr 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, M/DF',ARRAY['cleric','druid','paladin','ranger','sorcerer','wizard']::text[],'Transmutation

Level: Clr 2, Drd 2, Pal 2, Rgr 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The transmuted creature becomes wiser. The spell grants a +4 enhancement bonus to Wisdom, adding the usual benefit to Wisdom-related skills. Clerics, druids, paladins, and rangers (and other Wisdom-based spellcasters) who receive owl’s wisdom do not gain any additional bonus spells for the increased Wisdom, but the save DCs for their spells increase.

Arcane Material Component: A few feathers, or a pinch of droppings, from an owl.','{"class_levels":{"cleric":2,"druid":2,"paladin":2,"ranger":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Clr 2, Drd 2, Pal 2, Rgr 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_owl_s_wisdom_mass','Owl’s Wisdom, Mass','Clr 6, Drd 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One creature/level, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Clr 6, Drd 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like owl’s wisdom, except that it affects multiple creatures.','{"class_levels":{"cleric":6,"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Drd 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-m-o.md'),
('srd35_spell_passwall','Passwall','Sor/Wiz 5',5,'Transmutation','Touch','5 ft. by 8 ft. opening, 10 ft. deep plus 5 ft. deep per three additional levels',NULL,'1 hour/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Effect: 5 ft. by 8 ft. opening, 10 ft. deep plus 5 ft. deep per three additional levels

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

You create a passage through wooden, plaster, or stone walls, but not through metal or other harder materials. The passage is 10 feet deep plus an additional 5 feet deep per three caster levels above 9th (15 feet at 12th, 20 feet at 15th, and a maximum of 25 feet deep at 18th level). If the wall’s thickness is more than the depth of the passage created, then a single passwall simply makes a niche or short tunnel. Several passwall spells can then form a continuing passage to breach very thick walls. When passwall ends, creatures within the passage are ejected out the nearest exit. If someone dispels the passwall or you dismiss it, creatures in the passage are ejected out the far exit, if there is one, or out the sole exit if there is only one.

Material Component: A pinch of sesame seeds.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Effect":"5 ft. by 8 ft. opening, 10 ft. deep plus 5 ft. deep per three additional levels","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_pass_without_trace','Pass Without Trace','Drd 1, Rgr 1',1,'Transmutation','Touch',NULL,NULL,'1 hour/level (D)','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 1, Rgr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: One creature/level touched

Duration: 1 hour/level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject or subjects can move through any type of terrain and leave neither footprints nor scent. Tracking the subjects is impossible by nonmagical means.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"One creature/level touched","Duration":"1 hour/level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_permanency','Permanency','Sor/Wiz 5',5,'Universal','See text',NULL,NULL,'Permanent; see text','V, S, XP',ARRAY['sorcerer','wizard']::text[],'Universal

Level: Sor/Wiz 5

Components: V, S, XP

Casting Time: 2 rounds

Range: See text

Target, Effect, or Area: See text

Duration: Permanent; see text

Saving Throw: None

Spell Resistance: No

This spell makes certain other spells permanent.

Depending on the spell, you must be of a minimum caster level and must expend a number of XP.

You can make the following spells permanent in regard to yourself.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Spell</th><th>Minimum Caster Level</th><th>XP Cost</th></tr><tr><td><i>Arcane sight</i></td><td>11th</td><td>1,500 XP</td></tr><tr><td><i>Comprehend languages</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Darkvision</i></td><td>10th</td><td>1,000 XP</td></tr><tr><td><i>Detect magic</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Read magic</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>See invisibility</i></td><td>10th</td><td>1,000 XP</td></tr><tr><td><i>Tongues</i></td><td>11th</td><td>1,500 XP</td></tr></tbody></table>

You cast the desired spell and then follow it with the permanency spell. You cannot cast these spells on other creatures. This application of permanency can be dispelled only by a caster of higher level than you were when you cast the spell.

In addition to personal use, permanency can be used to make the following spells permanent on yourself, another creature, or an object (as appropriate).

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Spell</th><th>Minimum Caster Level</th><th>XP Cost</th></tr><tr><td><i>Enlarge person</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Magic fang</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Magic fang, greater</i></td><td>11th</td><td>1,500 XP</td></tr><tr><td><i>Reduce person</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Resistance</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Telepathic bond</i><sup>1</sup></td><td>13th</td><td>2,500 XP</td></tr><tr><td colspan="3">1 Only bonds two creatures per casting of <i>permanency</i>.</td></tr></tbody></table>

Additionally, the following spells can be cast upon objects or areas only and rendered permanent.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Spell</th><th>Minimum Caster Level</th><th>XP Cost</th></tr><tr><td><i>Alarm</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Animate objects</i></td><td>14th</td><td>3,000 XP</td></tr><tr><td><i>Dancing lights</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Ghost sound</i></td><td>9th</td><td>500 XP</td></tr><tr><td><i>Gust of wind</i></td><td>11th</td><td>1,500 XP</td></tr><tr><td><i>Invisibility</i></td><td>10th</td><td>1,000 XP</td></tr><tr><td><i>Mage’s private sanctum</i></td><td>13th</td><td>2,500 XP</td></tr><tr><td><i>Magic mouth</i></td><td>10th</td><td>1,000 XP</td></tr><tr><td><i>Phase door</i></td><td>15th</td><td>3,500 XP</td></tr><tr><td><i>Prismatic sphere</i></td><td>17th</td><td>4,500 XP</td></tr><tr><td><i>Prismatic wall</i></td><td>16th</td><td>4,000 XP</td></tr><tr><td><i>Shrink item</i></td><td>11th</td><td>1,500 XP</td></tr><tr><td><i>Solid fog</i></td><td>12th</td><td>2,000 XP</td></tr><tr><td><i>Stinking cloud</i></td><td>11th</td><td>1,500 XP</td></tr><tr><td><i>Symbol of death</i></td><td>16th</td><td>4,000 XP</td></tr><tr><td><i>Symbol of fear</i></td><td>14th</td><td>3,000 XP</td></tr><tr><td><i>Symbol of insanity</i></td><td>16th</td><td>4,000 XP</td></tr><tr><td><i>Symbol of pain</i></td><td>13th</td><td>2,500 XP</td></tr><tr><td><i>Symbol of persuasion</i></td><td>14th</td><td>3,000 XP</td></tr><tr><td><i>Symbol of sleep</i></td><td>16th</td><td>4,000 XP</td></tr><tr><td><i>Symbol of stunning</i></td><td>15th</td><td>3,500 XP</td></tr><tr><td><i>Symbol of weakness</i></td><td>15th</td><td>3,500 XP</td></tr><tr><td><i>Teleportation circle</i></td><td>17th</td><td>4,500 XP</td></tr><tr><td><i>Wall of fire</i></td><td>12th</td><td>2,000 XP</td></tr><tr><td><i>Wall of force</i></td><td>13th</td><td>2,500 XP</td></tr><tr><td><i>Web</i></td><td>10th</td><td>1,000 XP</td></tr></tbody></table>

Spells cast on other creatures, objects, or locations (not on you) are vulnerable to dispel magic as normal.

XP Cost: See tables above.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, XP","Casting Time":"2 rounds","Range":"See text","Target, Effect, or Area":"See text","Duration":"Permanent; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_permanent_image','Permanent Image','Brd 6, Sor/Wiz 6',6,'Illusion (Figment)',NULL,'Figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)',NULL,'Permanent (D)',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 6, Sor/Wiz 6

Effect: Figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)

Duration: Permanent (D)

This spell functions like silent image, except that the figment includes visual, auditory, olfactory, and thermal elements, and the spell is permanent. By concentrating, you can move the image within the limits of the range, but it is static while you are not concentrating.

Material Component: A bit of fleece plus powdered jade worth 100 gp.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Effect":"Figment that cannot extend beyond a 20-ft. cube + one 10-ft. cube/level (S)","Duration":"Permanent (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_persistent_image','Persistent Image','Brd 5, Sor/Wiz 5',5,'Illusion (Figment)',NULL,NULL,NULL,'1 min./level (D)',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 5, Sor/Wiz 5

Duration: 1 min./level (D)

This spell functions like silent image, except that the figment includes visual, auditory, olfactory, and thermal components, and the figment follows a script determined by you. The figment follows that script without your having to concentrate on it. The illusion can include intelligible speech if you wish.

Material Component: A bit of fleece and several grains of sand.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_phantasmal_killer','Phantasmal Killer','Sor/Wiz 4',4,'Illusion (Phantasm) [Fear, Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One living creature',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Illusion (Phantasm) \[Fear, Mind-Affecting\]

Level: Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One living creature

Duration: Instantaneous

Saving Throw: Will disbelief (if interacted with), then Fortitude partial; see text

Spell Resistance: Yes

You create a phantasmal image of the most fearsome creature imaginable to the subject simply by forming the fears of the subject’s subconscious mind into something that its conscious mind can visualize: this most horrible beast. Only the spell’s subject can see the phantasmal killer. You see only a vague shape. The target first gets a Will save to recognize the image as unreal. If that save fails, the phantasm touches the subject, and the subject must succeed on a Fortitude save or die from fear. Even if the Fortitude save is successful, the subject takes 3d6 points of damage.

If the subject of a phantasmal killer attack succeeds in disbelieving and is wearing a helm of telepathy, the beast can be turned upon you. You must then disbelieve it or become subject to its deadly fear attack.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One living creature","Duration":"Instantaneous","Saving Throw":"Will disbelief (if interacted with), then Fortitude partial; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_phantom_steed','Phantom Steed','Brd 3, Sor/Wiz 3',3,'Conjuration (Creation)','0 ft.','One quasi-real, horselike creature',NULL,'1 hour/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Brd 3, Sor/Wiz 3

Components: V, S

Casting Time: 10 minutes

Range: 0 ft.

Effect: One quasi-real, horselike creature

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

You conjure a Large, quasi-real, horselike creature. The steed can be ridden only by you or by the one person for whom you specifically created the mount. A phantom steed has a black head and body, gray mane and tail, and smoke-colored, insubstantial hooves that make no sound. It has what seems to be a saddle, bit, and bridle. It does not fight, but animals shun it and refuse to attack it.

The mount has an AC of 18 (–1 size, +4 natural armor, +5 Dex) and 7 hit points +1 hit point per caster level. If it loses all its hit points, the phantom steed disappears. A phantom steed has a speed of 20 feet per caster level, to a maximum of 240 feet. It can bear its rider’s weight plus up to 10 pounds per caster level.

These mounts gain certain powers according to caster level. A mount’s abilities include those of mounts of lower caster levels.

8th Level: The mount can ride over sandy, muddy, or even swampy ground without difficulty or decrease in speed.

10th Level: The mount can use water walk at will (as the spell, no action required to activate this ability).

12th Level: The mount can use air walk at will (as the spell, no action required to activate this ability) for up to 1 round at a time, after which it falls to the ground.

14th Level: The mount can fly at its speed (average maneuverability).','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S","Casting Time":"10 minutes","Range":"0 ft.","Effect":"One quasi-real, horselike creature","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_phantom_trap','Phantom Trap','Sor/Wiz 2',2,'Illusion (Glamer)','Touch','Object touched',NULL,'Permanent (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Duration: Permanent (D)

Saving Throw: None

Spell Resistance: No

This spell makes a lock or other small mechanism seem to be trapped to anyone who can detect traps. You place the spell upon any small mechanism or device, such as a lock, hinge, hasp, cork, cap, or ratchet. Any character able to detect traps, or who uses any spell or device enabling trap detection, is 100% certain a real trap exists. Of course, the effect is illusory and nothing happens if the trap is “sprung”; its primary purpose is to frighten away thieves or make them waste precious time.

If another phantom trap is active within 50 feet when the spell is cast, the casting fails.

Material Component: A piece of iron pyrite touched to the object to be trapped while the object is sprinkled with a special dust requiring 50 gp to prepare.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Duration":"Permanent (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_phase_door','Phase Door','Sor/Wiz 7, Travel 8',7,'Conjuration (Creation)','0 ft.','Ethereal 5 ft. by 8 ft. opening, 10 ft. deep + 5 ft. deep per three levels',NULL,'One usage per two levels','V',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 7, Travel 8

Components: V

Casting Time: 1 standard action

Range: 0 ft.

Effect: Ethereal 5 ft. by 8 ft. opening, 10 ft. deep + 5 ft. deep per three levels

Duration: One usage per two levels

Saving Throw: None

Spell Resistance: No

This spell creates an ethereal passage through wooden, plaster, or stone walls, but not other materials. The phase door is invisible and inaccessible to all creatures except you, and only you can use the passage. You disappear when you enter the phase door and appear when you exit. If you desire, you can take one other creature (Medium or smaller) through the door. This counts as two uses of the door. The door does not allow light, sound, or spell effects through it, nor can you see through it without using it. Thus, the spell can provide an escape route, though certain creatures, such as phase spiders, can follow with ease. A gem of true seeing or similar magic reveals the presence of a phase door but does not allow its use.

A phase door is subject to dispel magic. If anyone is within the passage when it is dispelled, he is harmlessly ejected just as if he were inside a passwall effect.

You can allow other creatures to use the phase door by setting some triggering condition for the door. Such conditions can be as simple or elaborate as you desire. They can be based on a creature’s name, identity, or alignment, but otherwise must be based on observable actions or qualities. Intangibles such as level, class, Hit Dice, and hit points don’t qualify.

Phase door can be made permanent with a permanency spell.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7, Travel 8","Components":"V","Casting Time":"1 standard action","Range":"0 ft.","Effect":"Ethereal 5 ft. by 8 ft. opening, 10 ft. deep + 5 ft. deep per three levels","Duration":"One usage per two levels","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_planar_ally','Planar Ally','Clr 6',6,'Conjuration (Calling) [see text for _lesser planar ally_]',NULL,'One or two called elementals or outsiders, totaling no more than 12 HD, which cannot be more than 30 ft. apart when they appear',NULL,NULL,NULL,ARRAY['cleric']::text[],'Conjuration (Calling) \[see text for lesser planar ally\]

Level: Clr 6

Effect: One or two called elementals or outsiders, totaling no more than 12 HD, which cannot be more than 30 ft. apart when they appear

This spell functions like lesser planar ally, except you may call a single creature of 12 HD or less, or two creatures of the same kind whose Hit Dice total no more than 12. The creatures agree to help you and request your return payment together.

XP Cost: 250 XP.','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6","Effect":"One or two called elementals or outsiders, totaling no more than 12 HD, which cannot be more than 30 ft. apart when they appear"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_planar_ally_greater','Planar Ally, Greater','Clr 8',8,'Conjuration (Calling) [see text for _lesser planar ally_]',NULL,'Up to three called elementals or outsiders, totaling no more than 18 HD, no two of which can be more than 30 ft. apart when they appear.',NULL,NULL,NULL,ARRAY['cleric']::text[],'Conjuration (Calling) \[see text for lesser planar ally\]

Level: Clr 8

Effect: Up to three called elementals or outsiders, totaling no more than 18 HD, no two of which can be more than 30 ft. apart when they appear.

This spell functions like lesser planar ally, except that you may call a single creature of 18 HD or less, or up to three creatures of the same kind whose Hit Dice total no more than 18. The creatures agree to help you and request your return payment together.

XP Cost: 500 XP.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8","Effect":"Up to three called elementals or outsiders, totaling no more than 18 HD, no two of which can be more than 30 ft. apart when they appear."},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md'),
('srd35_spell_planar_ally_lesser','Planar Ally, Lesser','Clr 4',4,'Conjuration (Calling) [see text]','Close (25 ft. + 5 ft./2 levels)','One called elemental or outsider of 6 HD or less',NULL,'Instantaneous','V, S, DF, XP',ARRAY['cleric']::text[],'Conjuration (Calling) \[see text\]

Level: Clr 4

Components: V, S, DF, XP

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One called elemental or outsider of 6 HD or less

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

By casting this spell, you request your deity to send you an elemental or outsider (of 6 HD or less) of the deity’s choice. If you serve no particular deity, the spell is a general plea answered by a creature sharing your philosophical alignment. If you know an individual creature’s name, you may request that individual by speaking the name during the spell (though you might get a different creature anyway).

You may ask the creature to perform one task in exchange for a payment from you. Tasks might range from the simple to the complex. You must be able to communicate with the creature called in order to bargain for its services.

The creature called requires a payment for its services. This payment can take a variety of forms, from donating gold or magic items to an allied temple, to a gift given directly to the creature, to some other action on your part that matches the creature’s alignment and goals. Regardless, this payment must be made before the creature agrees to perform any services. The bargaining takes at least 1 round, so any actions by the creature begin in the round after it arrives.

A task taking up to 1 minute per caster level requires a payment of 100 gp per HD of the creature called. For a task taking up to 1 hour per caster level, the creature requires a payment of 500 gp per HD. A long-term task, one requiring up to one day per caster level, requires a payment of 1,000 gp per HD.

A nonhazardous task requires only half the indicated payment, while an especially hazardous task might require a greater gift. Few if any creatures will accept a task that seems suicidal (remember, a called creature actually dies when it is killed, unlike a summoned creature). However, if the task is strongly aligned with the creature’s ethos, it may halve or even waive the payment.

At the end of its task, or when the duration bargained for expires, the creature returns to its home plane (after reporting back to you, if appropriate and possible).

Note: When you use a calling spell that calls an air, chaotic, earth, evil, fire, good, lawful, or water creature, it is a spell of that type.

XP Cost: 100 XP.','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4","Components":"V, S, DF, XP","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One called elemental or outsider of 6 HD or less","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-p-r.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
