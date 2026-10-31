-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_glibness','Glibness','Brd 3',3,'Transmutation','Personal','You',NULL,'10 min./level (D)','S',ARRAY['bard']::text[],'Transmutation

Level: Brd 3

Components: S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level (D)

Your speech becomes fluent and more believable. You gain a +30 bonus on Bluff checks made to convince another of the truth of your words. (This bonus doesn’t apply to other uses of the Bluff skill, such as feinting in combat, creating a diversion to hide, or communicating a hidden message via innuendo.)

If a magical effect is used against you that would detect your lies or force you to speak the truth the user of the effect must succeed on a caster level check (1d20 + caster level) against a DC of 15 + your caster level to succeed. Failure means the effect does not detect your lies or force you to speak only the truth.','{"class_levels":{"bard":3},"source_field_values":{"Level":"Brd 3","Components":"S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_glitterdust','Glitterdust','Brd 2, Sor/Wiz 2',2,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)',NULL,'Creatures and objects within 10-ft.-radius spread','1 round/level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Brd 2, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Creatures and objects within 10-ft.-radius spread

Duration: 1 round/level

Saving Throw: Will negates (blinding only)

Spell Resistance: No

A cloud of golden particles covers everyone and everything in the area, causing creatures to become blinded and visibly outlining invisible things for the duration of the spell. All within the area are covered by the dust, which cannot be removed and continues to sparkle until it fades.

Any creature covered by the dust takes a –40 penalty on Hide checks.

Material Component: Ground mica.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Creatures and objects within 10-ft.-radius spread","Duration":"1 round/level","Saving Throw":"Will negates (blinding only)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_globe_of_invulnerability','Globe of Invulnerability','Sor/Wiz 6',6,'Abjuration',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 6

This spell functions like lesser globe of invulnerability, except that it also excludes 4th-level spells and spell-like effects.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_globe_of_invulnerability_lesser','Globe of Invulnerability, Lesser','Sor/Wiz 4',4,'Abjuration','10 ft.',NULL,'10-ft.-radius spherical emanation, centered on you','1 round/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: 10 ft.

Area: 10-ft.-radius spherical emanation, centered on you

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: No

An immobile, faintly shimmering magical sphere surrounds you and excludes all spell effects of 3rd level or lower. The area or effect of any such spells does not include the area of the lesser globe of invulnerability. Such spells fail to affect any target located within the globe. Excluded effects include spell-like abilities and spells or spell-like effects from items. However, any type of spell can be cast through or out of the magical globe. Spells of 4th level and higher are not affected by the globe, nor are spells already in effect when the globe is cast. The globe can be brought down by a targeted dispel magic spell, but not by an area dispel magic. You can leave and return to the globe without penalty.

Note that spell effects are not disrupted unless their effects enter the globe, and even then they are merely suppressed, not dispelled.

If a given spell has more than one level depending on which character class is casting it, use the level appropriate to the caster to determine whether lesser globe of invulnerability stops it.

Material Component: A glass or crystal bead that shatters at the expiration of the spell.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"10 ft.","Area":"10-ft.-radius spherical emanation, centered on you","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_glyph_of_warding','Glyph of Warding','Clr 3',3,'Abjuration','Touch',NULL,NULL,'Permanent until discharged (D)','V, S, M',ARRAY['cleric']::text[],'Abjuration

Level: Clr 3

Components: V, S, M

Casting Time: 10 minutes

Range: Touch

Target or Area: Object touched or up to 5 sq. ft./level

Duration: Permanent until discharged (D)

Saving Throw: See text

Spell Resistance: No (object) and Yes; see text

This powerful inscription harms those who enter, pass, or open the warded area or object. A glyph of warding can guard a bridge or passage, ward a portal, trap a chest or box, and so on.

You set the conditions of the ward. Typically, any creature entering the warded area or opening the warded object without speaking a password (which you set when casting the spell) is subject to the magic it stores. Alternatively or in addition to a password trigger, glyphs can be set according to physical characteristics (such as height or weight) or creature type, subtype, or kind. Glyphs can also be set with respect to good, evil, law, or chaos, or to pass those of your religion. They cannot be set according to class, Hit Dice, or level. Glyphs respond to invisible creatures normally but are not triggered by those who travel past them ethereally. Multiple glyphs cannot be cast on the same area. However, if a cabinet has three drawers, each can be separately warded.

When casting the spell, you weave a tracery of faintly glowing lines around the warding sigil. A glyph can be placed to conform to any shape up to the limitations of your total square footage. When the spell is completed, the glyph and tracery become nearly invisible.

Glyphs cannot be affected or bypassed by such means as physical or magical probing, though they can be dispelled. Mislead, polymorph, and nondetection (and similar magical effects) can fool a glyph, though nonmagical disguises and the like can’t. Read magic allows you to identify a glyph of warding with a DC 13 Spellcraft check. Identifying the glyph does not discharge it and allows you to know the basic nature of the glyph (version, type of damage caused, what spell is stored).

Note: Magic traps such as glyph of warding are hard to detect and disable. A rogue (only) can use the Search skill to find the glyph and Disable Device to thwart it. The DC in each case is 25 + spell level, or 28 for glyph of warding.

Depending on the version selected, a glyph either blasts the intruder or activates a spell.

Blast Glyph: A blast glyph deals 1d8 points of damage per two caster levels (maximum 5d8) to the intruder and to all within 5 feet of him or her. This damage is acid, cold, fire, electricity, or sonic (caster’s choice, made at time of casting). Each creature affected can attempt a Reflex save to take half damage. Spell resistance applies against this effect.

Spell Glyph: You can store any harmful spell of 3rd level or lower that you know. All level-dependent features of the spell are based on your caster level at the time of casting the glyph. If the spell has a target, it targets the intruder. If the spell has an area or an amorphous effect the area or effect is centered on the intruder. If the spell summons creatures, they appear as close as possible to the intruder and attack. Saving throws and spell resistance operate as normal, except that the DC is based on the level of the spell stored in the glyph.

Material Component: You trace the glyph with incense, which must first be sprinkled with powdered diamond worth at least 200 gp.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Components":"V, S, M","Casting Time":"10 minutes","Range":"Touch","Target or Area":"Object touched or up to 5 sq. ft./level","Duration":"Permanent until discharged (D)","Saving Throw":"See text","Spell Resistance":"No (object) and Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_glyph_of_warding_greater','Glyph of Warding, Greater','Clr 6',6,'Abjuration',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Abjuration

Level: Clr 6

This spell functions like glyph of warding, except that a greater blast glyph deals up to 10d8 points of damage, and a greater spell glyph can store a spell of 6th level or lower.

Material Component: You trace the glyph with incense, which must first be sprinkled with powdered diamond worth at least 400 gp.','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_goodberry','Goodberry','Drd 1',1,'Transmutation','Touch',NULL,NULL,'One day/level','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: 2d4 fresh berries touched

Duration: One day/level

Saving Throw: None

Spell Resistance: Yes

Casting goodberry upon a handful of freshly picked berries makes 2d4 of them magical. You (as well as any other druid of 3rd or higher level) can immediately discern which berries are affected. Each transmuted berry provides nourishment as if it were a normal meal for a Medium creature. The berry also cures 1 point of damage when eaten, subject to a maximum of 8 points of such curing in any 24-hour period.','{"class_levels":{"druid":1},"source_field_values":{"Level":"Drd 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"2d4 fresh berries touched","Duration":"One day/level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_good_hope','Good Hope','Brd 3',3,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 min./level','V, S',ARRAY['bard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 3

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: One living creature/level, no two of which may be more than 30 ft. apart

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell instills powerful hope in the subjects. Each affected creature gains a +2 morale bonus on saving throws, attack rolls, ability checks, skill checks, and weapon damage rolls.

Good hope counters and dispels crushing despair.','{"class_levels":{"bard":3},"source_field_values":{"Level":"Brd 3","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One living creature/level, no two of which may be more than 30 ft. apart","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_grasping_hand','Grasping Hand','Sor/Wiz 7, Strength 7',7,'Evocation [Force]',NULL,NULL,NULL,NULL,'V, S, F/DF',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 7, Strength 7

Components: V, S, F/DF

This spell functions like interposing hand, except the hand can also grapple one opponent that you select. The grasping hand gets one grapple attack per round.

Its attack bonus to make contact equals your caster level + your Intelligence, Wisdom, or Charisma modifier (for wizards, clerics, and sorcerers, respectively), +10 for the hand’s Strength score (31), –1 for being Large. Its grapple bonus is this same figure, except with a +4 modifier for being Large instead of –1. The hand holds but does not harm creatures it grapples.

Directing the spell to a new target is a move action.

The grasping hand can also bull rush an opponent as forceful hand does, but at a +16 bonus on the Strength check (+10 for Strength 35, +4 for being Large, and a +2 bonus for charging, which it always gets), or interpose itself as interposing hand does.

Clerics who cast this spell name it for their deities.

Arcane Focus: A leather glove.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7, Strength 7","Components":"V, S, F/DF"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_grease','Grease','Brd 1, Sor/Wiz 1',1,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Brd 1, Sor/Wiz 1

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target or Area: One object or a 10-ft. square

Duration: 1 round/level (D)

Saving Throw: See text

Spell Resistance: No

A grease spell covers a solid surface with a layer of slippery grease. Any creature in the area when the spell is cast must make a successful Reflex save or fall. This save is repeated on your turn each round that the creature remains within the area. A creature can walk within or through the area of grease at half normal speed with a DC 10 Balance check. Failure means it can’t move that round (and must then make a Reflex save or fall), while failure by 5 or more means it falls (see the Balance skill for details).

The spell can also be used to create a greasy coating on an item. Material objects not in use are always affected by this spell, while an object wielded or employed by a creature receives a Reflex saving throw to avoid the effect. If the initial saving throw fails, the creature immediately drops the item. A saving throw must be made in each round that the creature attempts to pick up or use the greased item. A creature wearing greased armor or clothing gains a +10 circumstance bonus on Escape Artist checks and on grapple checks made to resist or escape a grapple or to escape a pin.

Material Component: A bit of pork rind or butter.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target or Area":"One object or a 10-ft. square","Duration":"1 round/level (D)","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_guards_and_wards','Guards and Wards','Sor/Wiz 6',6,'Abjuration','Anywhere within the area to be warded',NULL,'Up to 200 sq. ft./level (S)','2 hours/level (D)','V, S, M, F',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 6

Components: V, S, M, F

Casting Time: 30 minutes

Range: Anywhere within the area to be warded

Area: Up to 200 sq. ft./level (S)

Duration: 2 hours/level (D)

Saving Throw: See text

Spell Resistance: See text

This powerful spell is primarily used to defend your stronghold. The ward protects 200 square feet per caster level. The warded area can be as much as 20 feet high, and shaped as you desire. You can ward several stories of a stronghold by dividing the area among them; you must be somewhere within the area to be warded to cast the spell. The spell creates the following magical effects within the warded area.

Fog: Fog fills all corridors, obscuring all sight, including darkvision, beyond 5 feet. A creature within 5 feet has concealment (attacks have a 20% miss chance). Creatures farther away have total concealment (50% miss chance, and the attacker cannot use sight to locate the target). Saving Throw: None. Spell Resistance: No.

Arcane Locks: All doors in the warded area are arcane locked. Saving Throw: None. Spell Resistance: No.

Webs: Webs fill all stairs from top to bottom. These strands are identical with those created by the web spell, except that they regrow in 10 minutes if they are burned or torn away while the guards and wards spell lasts. Saving Throw: Reflex negates; see text for web. Spell Resistance: No.

Confusion: Where there are choices in direction—such as a corridor intersection or side passage—a minor confusion\-type effect functions so as to make it 50% probable that intruders believe they are going in the opposite direction from the one they actually chose. This is an enchantment, mind-affecting effect. Saving Throw: None. Spell Resistance: Yes.

Lost Doors: One door per caster level is covered by a silent image to appear as if it were a plain wall. Saving Throw: Will disbelief (if interacted with). Spell Resistance: No.

In addition, you can place your choice of one of the following five magical effects.

1\. Dancing lights in four corridors. You can designate a simple program that causes the lights to repeat as long as the guards and wards spell lasts. Saving Throw: None. Spell Resistance: No.

2\. A magic mouth in two places. Saving Throw: None. Spell Resistance: No.

3\. A stinking cloud in two places. The vapors appear in the places you designate; they return within 10 minutes if dispersed by wind while the guards and wards spell lasts. Saving Throw: Fortitude negates; see text for stinking cloud. Spell Resistance: No.

4\. A gust of wind in one corridor or room. Saving Throw: Fortitude negates. Spell Resistance: Yes.

5\. A suggestion in one place. You select an area of up to 5 feet square, and any creature who enters or passes through the area receives the suggestion mentally. Saving Throw: Will negates. Spell Resistance: Yes.

The whole warded area radiates strong magic of the abjuration school. A dispel magic cast on a specific effect, if successful, removes only that effect. A successful Mage’s disjunction destroys the entire guards and wards effect.

Material Component: Burning incense, a small measure of brimstone and oil, a knotted string, and a small amount of blood.

Focus: A small silver rod.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M, F","Casting Time":"30 minutes","Range":"Anywhere within the area to be warded","Area":"Up to 200 sq. ft./level (S)","Duration":"2 hours/level (D)","Saving Throw":"See text","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_guidance','Guidance','Clr 0, Drd 0',0,'Divination','Touch','Creature touched',NULL,'1 minute or until discharged','V, S',ARRAY['cleric','druid']::text[],'Divination

Level: Clr 0, Drd 0

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 minute or until discharged

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

This spell imbues the subject with a touch of divine guidance. The creature gets a +1 competence bonus on a single attack roll, saving throw, or skill check. It must choose to use the bonus before making the roll to which it applies.','{"class_levels":{"cleric":0,"druid":0},"source_field_values":{"Level":"Clr 0, Drd 0","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 minute or until discharged","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_gust_of_wind','Gust of Wind','Drd 2, Sor/Wiz 2',2,'Evocation [Air]','60 ft.','Line-shaped gust of severe wind emanating out from you to the extreme of the range',NULL,'1 round','V, S',ARRAY['druid','sorcerer','wizard']::text[],'Evocation \[Air\]

Level: Drd 2, Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Effect: Line-shaped gust of severe wind emanating out from you to the extreme of the range

Duration: 1 round

Saving Throw: Fortitude negates

Spell Resistance: Yes

This spell creates a severe blast of air (approximately 50 mph) that originates from you, affecting all creatures in its path.

A Tiny or smaller creature on the ground is knocked down and rolled 1d4x10 feet, taking 1d4 points of nonlethal damage per 10 feet. If flying, a Tiny or smaller creature is blown back 2d6x10 feet and takes 2d6 points of nonlethal damage due to battering and buffeting.

Small creatures are knocked prone by the force of the wind, or if flying are blown back 1d6x10 feet.

Medium creatures are unable to move forward against the force of the wind, or if flying are blown back 1d6x5 feet.

Large or larger creatures may move normally within a gust of wind effect.

A gust of wind can’t move a creature beyond the limit of its range.

Any creature, regardless of size, takes a –4 penalty on ranged attacks and Listen checks in the area of a gust of wind.

The force of the gust automatically extinguishes candles, torches, and similar unprotected flames. It causes protected flames, such as those of lanterns, to dance wildly and has a 50% chance to extinguish those lights.

In addition to the effects noted, a gust of wind can do anything that a sudden blast of wind would be expected to do. It can create a stinging spray of sand or dust, fan a large fire, overturn delicate awnings or hangings, heel over a small boat, and blow gases or vapors to the edge of its range.

Gust of wind can be made permanent with a permanency spell.','{"class_levels":{"druid":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Drd 2, Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Effect":"Line-shaped gust of severe wind emanating out from you to the extreme of the range","Duration":"1 round","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_hallow','Hallow','Clr 5, Drd 5',5,'Evocation [Good]','Touch',NULL,'40-ft. radius emanating from the touched point','Instantaneous','V, S, M, DF',ARRAY['cleric','druid']::text[],'Evocation \[Good\]

Level: Clr 5, Drd 5

Components: V, S, M, DF

Casting Time: 24 hours

Range: Touch

Area: 40-ft. radius emanating from the touched point

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: See text

Hallow makes a particular site, building, or structure a holy site. This has four major effects.

First, the site or structure is guarded by a magic circle against evil effect.

Second, all Charisma checks made to turn undead gain a +4 sacred bonus, and Charisma checks to command undead take a –4 penalty. Spell resistance does not apply to this effect. (This provision does not apply to the druid version of the spell.)

Third, any dead body interred in a hallowed site cannot be turned into an undead creature.

Finally, you may choose to fix a single spell effect to the hallowed site. The spell effect lasts for one year and functions throughout the entire site, regardless of the normal duration and area or effect. You may designate whether the effect applies to all creatures, creatures who share your faith or alignment, or creatures who adhere to another faith or alignment. At the end of the year, the chosen effect lapses, but it can be renewed or replaced simply by casting hallow again.

Spell effects that may be tied to a hallowed site include aid, bane, bless, cause fear, darkness, daylight, death ward, deeper darkness, detect evil, detect magic, dimensional anchor, discern lies, dispel magic, endure elements, freedom of movement, invisibility purge, protection from energy, remove fear, resist energy, silence, tongues, and zone of truth. Saving throws and spell resistance might apply to these spells’ effects. (See the individual spell descriptions for details.)

An area can receive only one hallow spell (and its associated spell effect) at a time. Hallow counters but does not dispel unhallow.

Material Component: Herbs, oils, and incense worth at least 1,000 gp, plus 1,000 gp per level of the spell to be included in the hallowed area.','{"class_levels":{"cleric":5,"druid":5},"source_field_values":{"Level":"Clr 5, Drd 5","Components":"V, S, M, DF","Casting Time":"24 hours","Range":"Touch","Area":"40-ft. radius emanating from the touched point","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hallucinatory_terrain','Hallucinatory Terrain','Brd 4, Sor/Wiz 4',4,'Illusion (Glamer)','Long (400 ft. + 40 ft./level)',NULL,'One 30-ft. cube/level (S)','2 hours/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 4, Sor/Wiz 4

Components: V, S, M

Casting Time: 10 minutes

Range: Long (400 ft. + 40 ft./level)

Area: One 30-ft. cube/level (S)

Duration: 2 hours/level (D)

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

You make natural terrain look, sound, and smell like some other sort of natural terrain. Structures, equipment, and creatures within the area are not hidden or changed in appearance.

Material Component: A stone, a twig, and a bit of green plant.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S, M","Casting Time":"10 minutes","Range":"Long (400 ft. + 40 ft./level)","Area":"One 30-ft. cube/level (S)","Duration":"2 hours/level (D)","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_halt_undead','Halt Undead','Sor/Wiz 3',3,'Necromancy','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 round/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: Up to three undead creatures, no two of which can be more than 30 ft. apart

Duration: 1 round/level

Saving Throw: Will negates (see text)

Spell Resistance: Yes

This spell renders as many as three undead creatures immobile. A nonintelligent undead creature gets no saving throw; an intelligent undead creature does. If the spell is successful, it renders the undead creature immobile for the duration of the spell (similar to the effect of hold person on a living creature). The effect is broken if the halted creatures are attacked or take damage.

Material Component: A pinch of sulfur and powdered garlic.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"Up to three undead creatures, no two of which can be more than 30 ft. apart","Duration":"1 round/level","Saving Throw":"Will negates (see text)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_harm','Harm','Clr 6, Destruction 6',6,'Necromancy','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric']::text[],'Necromancy

Level: Clr 6, Destruction 6

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will half; see text

Spell Resistance: Yes

Harm charges a subject with negative energy that deals 10 points of damage per caster level (to a maximum of 150 points at 15th level). If the creature successfully saves, harm deals half this amount, but it cannot reduce the target’s hit points to less than 1.

If used on an undead creature, harm acts like heal.','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6, Destruction 6","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_haste','Haste','Brd 3, Sor/Wiz 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

Duration: 1 round/level

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

The transmuted creatures move and act more quickly than normal. This extra speed has several effects.

When making a full attack action, a hasted creature may make one extra attack with any weapon he is holding. The attack is made using the creature’s full base attack bonus, plus any modifiers appropriate to the situation. (This effect is not cumulative with similar effects, such as that provided by a weapon of speed, nor does it actually grant an extra action, so you can’t use it to cast a second spell or otherwise take an extra action in the round.)

A hasted creature gains a +1 bonus on attack rolls and a +1 dodge bonus to AC and Reflex saves. Any condition that makes you lose your Dexterity bonus to Armor Class (if any) also makes you lose dodge bonuses.

All of the hasted creature’s modes of movement (including land movement, burrow, climb, fly, and swim) increase by 30 feet, to a maximum of twice the subject’s normal speed using that form of movement. This increase counts as an enhancement bonus, and it affects the creature’s jumping distance as normal for increased speed.

Multiple haste effects don’t stack. Haste dispels and counters slow.

Material Component: A shaving of licorice root.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"1 round/level","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heal','Heal','Clr 6, Drd 7, Healing 6',6,'Conjuration (Healing)','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric','druid']::text[],'Conjuration (Healing)

Level: Clr 6, Drd 7, Healing 6

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

Heal enables you to channel positive energy into a creature to wipe away injury and afflictions. It immediately ends any and all of the following adverse conditions affecting the Target: ability damage, blinded, confused, dazed, dazzled, deafened, diseased, exhausted, fatigued, feebleminded, insanity, nauseated, sickened, stunned, and poisoned. It also cures 10 hit points of damage per level of the caster, to a maximum of 150 points at 15th level.

Heal does not remove negative levels, restore permanently drained levels, or restore permanently drained ability score points.

If used against an undead creature, heal instead acts like harm.','{"class_levels":{"cleric":6,"druid":7},"source_field_values":{"Level":"Clr 6, Drd 7, Healing 6","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heal_mass','Heal, Mass','Clr 9, Healing 9',9,'Conjuration (Healing)','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Conjuration (Healing)

Level: Clr 9, Healing 9

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like heal, except as noted above. The maximum number of hit points restored to each creature is 250.','{"class_levels":{"cleric":9},"source_field_values":{"Level":"Clr 9, Healing 9","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heal_mount','Heal Mount','Pal 3',3,'Conjuration (Healing)','Touch','Your mount touched',NULL,'Instantaneous','V, S',ARRAY['paladin']::text[],'Conjuration (Healing)

Level: Pal 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Your mount touched

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell functions like heal, but it affects only the paladin’s special mount (typically a warhorse).','{"class_levels":{"paladin":3},"source_field_values":{"Level":"Pal 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Your mount touched","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heat_metal','Heat Metal','Drd 2, Sun 2',2,'Transmutation [Fire]','Close (25 ft. + 5 ft./2 levels)','Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, all of which must be within a 30-ft. circle',NULL,'7 rounds','V, S, DF',ARRAY['druid']::text[],'Transmutation \[Fire\]

Level: Drd 2, Sun 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, all of which must be within a 30-ft. circle

Duration: 7 rounds

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

Heat metal makes metal extremely warm. Unattended, nonmagical metal gets no saving throw. Magical metal is allowed a saving throw against the spell. An item in a creature’s possession uses the creature’s saving throw bonus unless its own is higher.

A creature takes fire damage if its equipment is heated. It takes full damage if its armor is affected or if it is holding, touching, wearing, or carrying metal weighing one-fifth of its weight. The creature takes minimum damage (1 point or 2 points; see the table) if it’s not wearing metal armor and the metal that it’s carrying weighs less than one-fifth of its weight.

On the first round of the spell, the metal becomes warm and uncomfortable to touch but deals no damage. The same effect also occurs on the last round of the spell’s duration. During the second (and also the next-to-last) round, intense heat causes pain and damage. In the third, fourth, and fifth rounds, the metal is searing hot, causing more damage, as shown on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Round</th><th>Metal Temperature</th><th>Damage</th></tr><tr><td>1</td><td>Warm</td><td>None</td></tr><tr><td>2</td><td>Hot</td><td>1d4 points</td></tr><tr><td>3–5</td><td>Searing</td><td>2d4 points</td></tr><tr><td>6</td><td>Hot</td><td>1d4 points</td></tr><tr><td>7</td><td>Warm</td><td>None</td></tr></tbody></table>

Any cold intense enough to damage the creature negates fire damage from the spell (and vice versa) on a point-for-point basis. If cast underwater, heat metal deals half damage and boils the surrounding water.

Heat metal counters and dispels chill metal.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2, Sun 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, all of which must be within a 30-ft. circle","Duration":"7 rounds","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_helping_hand','Helping Hand','Clr 3',3,'Evocation','5 miles','Ghostly hand',NULL,'1 hour/level','V, S, DF',ARRAY['cleric']::text[],'Evocation

Level: Clr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: 5 miles

Effect: Ghostly hand

Duration: 1 hour/level

Saving Throw: None

Spell Resistance: No

You create the ghostly image of a hand, which you can send to find a creature within 5 miles. The hand then beckons to that creature and leads it to you if the creature is willing to follow.

When the spell is cast, the hand appears in front of you. You then specify a person (or any creature) by physical description, which can include race, gender, and appearance but not ambiguous factors such as level, alignment, or class. When the description is complete, the hand streaks off in search of a subject that fits the description. The amount of time it takes to find the subject depends on how far away she is.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Distance</th><th>Time to Locate</th></tr><tr><td>100 ft. or less</td><td>1 round</td></tr><tr><td>1,000 ft.</td><td>1 minute</td></tr><tr><td>1 mile</td><td>10 minutes</td></tr><tr><td>2 miles</td><td>1 hour</td></tr><tr><td>3 miles</td><td>2 hours</td></tr><tr><td>4 miles</td><td>3 hours</td></tr><tr><td>5 miles</td><td>4 hours</td></tr></tbody></table>

Once the hand locates the subject, it beckons the creature to follow it. If the subject does so, the hand points in your direction, indicating the most direct feasible route. The hand hovers 10 feet in front of the subject, moving before it at a speed of as much as 240 feet per round. Once the hand leads the subject back to you, it disappears.

The subject is not compelled to follow the hand or act in any particular way toward you. If the subject chooses not to follow, the hand continues to beckon for the duration of the spell, then disappears. If the spell expires while the subject is en route to you, the hand disappears; the subject must then rely on her own devices to locate you.

If more than one subject in a 5-mile radius meets the description, the hand locates the closest creature. If that creature refuses to follow the hand, the hand does not seek out a second subject.

If, at the end of 4 hours of searching, the hand has found no subject that matches the description within 5 miles, it returns to you, displays an outstretched palm (indicating that no such creature was found), and disappears.

The ghostly hand has no physical form. It is invisible to anyone except you and a potential subject. It cannot engage in combat or execute any other task aside from locating a subject and leading it back to you. The hand can’t pass through solid objects but can ooze through small cracks and slits. The hand cannot travel more than 5 miles from the spot it appeared when you cast the spell.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"5 miles","Effect":"Ghostly hand","Duration":"1 hour/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heroes_feast','Heroes’ Feast','Brd 6, Clr 6',6,'Conjuration [Creation]','Close (25 ft. + 5 ft./2 levels)','Feast for one creature/level',NULL,'1 hour plus 12 hours; see text','V, S, DF',ARRAY['bard','cleric']::text[],'Conjuration \[Creation\]

Level: Brd 6, Clr 6

Components: V, S, DF

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Feast for one creature/level

Duration: 1 hour plus 12 hours; see text

Saving Throw: None

Spell Resistance: No

You bring forth a great feast, including a magnificent table, chairs, service, and food and drink. The feast takes 1 hour to consume, and the beneficial effects do not set in until this hour is over. Every creature partaking of the feast is cured of all diseases, sickness, and nausea; becomes immune to poison for 12 hours; and gains 1d8 temporary hit points +1 point per two caster levels (maximum +10) after imbibing the nectar-like beverage that is part of the feast. The ambrosial food that is consumed grants each creature that partakes a +1 morale bonus on attack rolls and Will saves and immunity to fear effects for 12 hours.

If the feast is interrupted for any reason, the spell is ruined and all effects of the spell are negated.','{"class_levels":{"bard":6,"cleric":6},"source_field_values":{"Level":"Brd 6, Clr 6","Components":"V, S, DF","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Feast for one creature/level","Duration":"1 hour plus 12 hours; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heroism','Heroism','Brd 2, Sor/Wiz 3',2,'Enchantment (Compulsion) [Mind-Affecting]','Touch','Creature touched',NULL,'10 min./level','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell imbues a single creature with great bravery and morale in battle. The target gains a +2 morale bonus on attack rolls, saves, and skill checks.','{"class_levels":{"bard":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 2, Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_heroism_greater','Heroism, Greater','Brd 5, Sor/Wiz 6',5,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,'1 min./level',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 5, Sor/Wiz 6

Duration: 1 min./level

This spell functions like heroism, except the creature gains a +4 morale bonus on attack rolls, saves, and skill checks, immunity to fear effects, and temporary hit points equal to your caster level (maximum 20).','{"class_levels":{"bard":5,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 5, Sor/Wiz 6","Duration":"1 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hide_from_animals','Hide From Animals','Drd 1, Rgr 1',1,'Abjuration','Touch',NULL,NULL,'10 min./level (D)','S, DF',ARRAY['druid','ranger']::text[],'Abjuration

Level: Drd 1, Rgr 1

Components: S, DF

Casting Time: 1 standard action

Range: Touch

Targets: One creature touched/level

Duration: 10 min./level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

Animals cannot see, hear, or smell the warded creatures. Even extraordinary or supernatural sensory capabilities, such as blindsense, blindsight, scent, and tremorsense, cannot detect or locate warded creatures. Animals simply act as though the warded creatures are not there. If a warded character touches an animal or attacks any creature, even with a spell, the spell ends for all recipients.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"One creature touched/level","Duration":"10 min./level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hide_from_undead','Hide From Undead','Clr 1',1,'Abjuration','Touch',NULL,NULL,'10 min./level (D)','V, S, DF',ARRAY['cleric']::text[],'Abjuration

Level: Clr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Targets: One touched creature/level

Duration: 10 min./level (D)

Saving Throw: Will negates (harmless); see text

Spell Resistance: Yes

Undead cannot see, hear, or smell the warded creatures. Even extraordinary or supernatural sensory capabilities, such as blindsense, blindsight, scent, and tremorsense, cannot detect or locate warded creatures. Nonintelligent undead creatures are automatically affected and act as though the warded creatures are not there. An intelligent undead creature gets a single Will saving throw. If it fails, the subject can’t see any of the warded creatures. However, if it has reason to believe unseen opponents are present, it can attempt to find or strike them. If a warded creature attempts to turn or command undead, touches an undead creature, or attacks any creature (even with a spell), the spell ends for all recipients.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Targets":"One touched creature/level","Duration":"10 min./level (D)","Saving Throw":"Will negates (harmless); see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hideous_laughter','Hideous Laughter','Brd 1, Sor/Wiz 2',1,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One creature; see text',NULL,'1 round/level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 1, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature; see text

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: Yes

This spell afflicts the subject with uncontrollable laughter. It collapses into gales of manic laughter, falling prone. The subject can take no actions while laughing, but is not considered helpless. After the spell ends, it can act normally.

A creature with an Intelligence score of 2 or lower is not affected. A creature whose type is different from the caster’s receives a +4 bonus on its saving throw, because humor doesn’t “translate” well.

Material Component: Tiny tarts that are thrown at the target and a feather that is waved in the air.','{"class_levels":{"bard":1,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 1, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature; see text","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_animal','Hold Animal','Animal 2, Drd 2, Rgr 2',2,'Enchantment (Compulsion) [Mind-Affecting]',NULL,'One animal',NULL,NULL,'V, S',ARRAY['druid','ranger']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Animal 2, Drd 2, Rgr 2

Components: V, S

Target: One animal

This spell functions like hold person, except that it affects an animal instead of a humanoid.','{"class_levels":{"druid":2,"ranger":2},"source_field_values":{"Level":"Animal 2, Drd 2, Rgr 2","Components":"V, S","Target":"One animal"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_monster','Hold Monster','Brd 4, Law 6, Sor/Wiz 5',4,'Enchantment (Compulsion) [Mind-Affecting]',NULL,'One living creature',NULL,NULL,'V, S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 4, Law 6, Sor/Wiz 5

Components: V, S, M/DF

Target: One living creature

This spell functions like hold person, except that it affects any living creature that fails its Will save.

Arcane Material Component: One hard metal bar or rod, which can be as small as a three-penny nail.','{"class_levels":{"bard":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 4, Law 6, Sor/Wiz 5","Components":"V, S, M/DF","Target":"One living creature"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_monster_mass','Hold Monster, Mass','Sor/Wiz 9',9,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 9

Targets: One or more creatures, no two of which can be more than 30 ft. apart

This spell functions like hold person, except that it affects multiple creatures and holds any living creature that fails its Will save.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Targets":"One or more creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_person','Hold Person','Brd 2, Clr 2, Sor/Wiz 3',2,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One humanoid creature',NULL,'1 round/level (D); see text','V, S, F/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Clr 2, Sor/Wiz 3

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One humanoid creature

Duration: 1 round/level (D); see text

Saving Throw: Will negates; see text

Spell Resistance: Yes

The subject becomes paralyzed and freezes in place. It is aware and breathes normally but cannot take any actions, even speech. Each round on its turn, the subject may attempt a new saving throw to end the effect. (This is a full-round action that does not provoke attacks of opportunity.)

A winged creature who is paralyzed cannot flap its wings and falls. A swimmer can’t swim and may drown.

Arcane Focus: A small, straight piece of iron.','{"class_levels":{"bard":2,"cleric":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 2, Clr 2, Sor/Wiz 3","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One humanoid creature","Duration":"1 round/level (D); see text","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_person_mass','Hold Person, Mass','Sor/Wiz 7',7,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 7

Targets: One or more humanoid creatures, no two of which can be more than 30 ft. apart

This spell functions like hold person, except as noted above.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Targets":"One or more humanoid creatures, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hold_portal','Hold Portal','Sor/Wiz 1',1,'Abjuration','Medium (100 ft. + 10 ft./level)','One portal, up to 20 sq. ft./level',NULL,'1 min./level (D)',NULL,ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 1

Component: V

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One portal, up to 20 sq. ft./level

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell magically holds shut a door, gate, window, or shutter of wood, metal, or stone. The magic affects the portal just as if it were securely closed and normally locked. A knock spell or a successful dispel magic spell can negate a hold portal spell.

For a portal affected by this spell, add 5 to the normal DC for forcing open the portal.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Component":"V","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One portal, up to 20 sq. ft./level","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_holy_aura','Holy Aura','Clr 8, Good 8',8,'Abjuration [Good]','20 ft.',NULL,NULL,'1 round/level (D)','V, S, F',ARRAY['cleric']::text[],'Abjuration \[Good\]

Level: Clr 8, Good 8

Components: V, S, F

Casting Time: 1 standard action

Range: 20 ft.

Targets: One creature/level in a 20-ft.-radius burst centered on you

Duration: 1 round/level (D)

Saving Throw: See text

Spell Resistance: Yes (harmless)

A brilliant divine radiance surrounds the subjects, protecting them from attacks, granting them resistance to spells cast by evil creatures, and causing evil creatures to become blinded when they strike the subjects. This abjuration has four effects.

First, each warded creature gains a +4 deflection bonus to AC and a +4 resistance bonus on saves. Unlike protection from evil, this benefit applies against all attacks, not just against attacks by evil creatures.

Second, each warded creature gains spell resistance 25 against evil spells and spells cast by evil creatures.

Third, the abjuration blocks possession and mental influence, just as protection from evil does.

Finally, if an evil creature succeeds on a melee attack against a warded creature, the offending attacker is blinded (Fortitude save negates, as blindness/deafness, but against holy aura’s save DC).

Focus: A tiny reliquary containing some sacred relic. The reliquary costs at least 500 gp.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8, Good 8","Components":"V, S, F","Casting Time":"1 standard action","Range":"20 ft.","Targets":"One creature/level in a 20-ft.-radius burst centered on you","Duration":"1 round/level (D)","Saving Throw":"See text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_holy_sword','Holy Sword','Pal 4',4,'Evocation [Good]','Touch','Melee weapon touched',NULL,'1 round/level','V, S',ARRAY['paladin']::text[],'Evocation \[Good\]

Level: Pal 4

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Melee weapon touched

Duration: 1 round/level

Saving Throw: None

Spell Resistance: No

This spell allows you to channel holy power into your sword, or any other melee weapon you choose. The weapon acts as a +5 holy weapon (+5 enhancement bonus on attack and damage rolls, extra 2d6 damage against evil opponents). It also emits a magic circle against evil effect (as the spell). If the magic circle ends, the sword creates a new one on your turn as a free action. The spell is automatically canceled 1 round after the weapon leaves your hand. You cannot have more than one holy sword at a time.

If this spell is cast on a magic weapon, the powers of the spell supersede any that the weapon normally has, rendering the normal enhancement bonus and powers of the weapon inoperative for the duration of the spell. This spell is not cumulative with bless weapon or any other spell that might modify the weapon in any way.

This spell does not work on artifacts.

Note: A masterwork weapon’s bonus to attack does not stack with an enhancement bonus to attack.','{"class_levels":{"paladin":4},"source_field_values":{"Level":"Pal 4","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Melee weapon touched","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_holy_word','Holy Word','Clr 7, Good 7',7,'Evocation [Good, Sonic]','40 ft.',NULL,'Nongood creatures in a 40-ft.-radius spread centered on you','Instantaneous','V',ARRAY['cleric']::text[],'Evocation \[Good, Sonic\]

Level: Clr 7, Good 7

Components: V

Casting Time: 1 standard action

Range: 40 ft.

Area: Nongood creatures in a 40-ft.-radius spread centered on you

Duration: Instantaneous

Saving Throw: None or Will negates; see text

Spell Resistance: Yes

Any nongood creature within the area that hears the holy word suffers the following ill effects.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Effect</th></tr><tr><td>Equal to caster level</td><td>Deafened</td></tr><tr><td>Up to caster level</td><td>–1 Blinded, deafened</td></tr><tr><td>Up to caster level</td><td>–5 Paralyzed, blinded, deafened</td></tr><tr><td>Up to caster level</td><td>–10 Killed, paralyzed, blinded, deafened</td></tr></tbody></table>

The effects are cumulative and concurrent. No saving throw is allowed against these effects.

Deafened: The creature is deafened for 1d4 rounds.

Blinded: The creature is blinded for 2d4 rounds.

Paralyzed: The creature is paralyzed and helpless for 1d10 minutes.

Killed: Living creatures die. Undead creatures are destroyed.

Furthermore, if you are on your home plane when you cast this spell, nongood extraplanar creatures within the area are instantly banished back to their home planes. Creatures so banished cannot return for at least 24 hours. This effect takes place regardless of whether the creatures hear the holy word. The banishment effect allows a Will save (at a –4 penalty) to negate.

Creatures whose HD exceed your caster level are unaffected by holy word.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7, Good 7","Components":"V","Casting Time":"1 standard action","Range":"40 ft.","Area":"Nongood creatures in a 40-ft.-radius spread centered on you","Duration":"Instantaneous","Saving Throw":"None or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_horrid_wilting','Horrid Wilting','Sor/Wiz 8, Water 8',8,'Necromancy','Long (400 ft. + 40 ft./level)',NULL,NULL,'Instantaneous','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 8, Water 8

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Targets: Living creatures, no two of which can be more than 60 ft. apart

Duration: Instantaneous

Saving Throw: Fortitude half

Spell Resistance: Yes

This spell evaporates moisture from the body of each subject living creature, dealing 1d6 points of damage per caster level (maximum 20d6). This spell is especially devastating to water elementals and plant creatures, which instead take 1d8 points of damage per caster level (maximum 20d8).

Arcane Material Component: A bit of sponge.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8, Water 8","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Targets":"Living creatures, no two of which can be more than 60 ft. apart","Duration":"Instantaneous","Saving Throw":"Fortitude half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hypnotic_pattern','Hypnotic Pattern','Brd 2, Sor/Wiz 2',2,'Illusion (Pattern) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','Colorful lights in a 10-ft.-radius spread',NULL,'Concentration + 2 rounds','V (Brd only), S, M; see text',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Pattern) \[Mind-Affecting\]

Level: Brd 2, Sor/Wiz 2

Components: V (Brd only), S, M; see text

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Colorful lights in a 10-ft.-radius spread

Duration: Concentration + 2 rounds

Saving Throw: Will negates

Spell Resistance: Yes

A twisting pattern of subtle, shifting colors weaves through the air, fascinating creatures within it. Roll 2d4 and add your caster level (maximum 10) to determine the total number of Hit Dice of creatures affected. Creatures with the fewest HD are affected first; and, among creatures with equal HD, those who are closest to the spell’s point of origin are affected first. Hit Dice that are not sufficient to affect a creature are wasted. Affected creatures become fascinated by the pattern of colors. Sightless creatures are not affected.

A wizard or sorcerer need not utter a sound to cast this spell, but a bard must sing, play music, or recite a rhyme as a verbal component.

Material Component: A glowing stick of incense or a crystal rod filled with phosphorescent material.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V (Brd only), S, M; see text","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Colorful lights in a 10-ft.-radius spread","Duration":"Concentration + 2 rounds","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_hypnotism','Hypnotism','Brd 1, Sor/Wiz 1',1,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)',NULL,'Several living creatures, no two of which may be more than 30 ft. apart','2d4 rounds (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Area: Several living creatures, no two of which may be more than 30 ft. apart

Duration: 2d4 rounds (D)

Saving Throw: Will negates

Spell Resistance: Yes

Your gestures and droning incantation fascinate nearby creatures, causing them to stop and stare blankly at you. In addition, you can use their rapt attention to make your suggestions and requests seem more plausible. Roll 2d4 to see how many total Hit Dice of creatures you affect. Creatures with fewer HD are affected before creatures with more HD. Only creatures that can see or hear you are affected, but they do not need to understand you to be fascinated.

If you use this spell in combat, each target gains a +2 bonus on its saving throw. If the spell affects only a single creature not in combat at the time, the saving throw has a penalty of –2.

While the subject is fascinated by this spell, it reacts as though it were two steps more friendly in attitude. This allows you to make a single request of the affected creature (provided you can communicate with it). The request must be brief and reasonable. Even after the spell ends, the creature retains its new attitude toward you, but only with respect to that particular request.

A creature that fails its saving throw does not remember that you enspelled it.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"Several living creatures, no two of which may be more than 30 ft. apart","Duration":"2d4 rounds (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_ice_storm','Ice Storm','Drd 4, Sor/Wiz 4, Water 5',4,'Evocation [Cold]','Long (400 ft. + 40 ft./level)',NULL,'Cylinder (20-ft. radius, 40 ft. high)','1 full round','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Drd 4, Sor/Wiz 4, Water 5

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Cylinder (20-ft. radius, 40 ft. high)

Duration: 1 full round

Saving Throw: None

Spell Resistance: Yes

Great magical hailstones pound down for 1 full round, dealing 3d6 points of bludgeoning damage and 2d6 points of cold damage to every creature in the area. A –4 penalty applies to each Listen check made within the ice storm’s effect, and all land movement within its area is at half speed. At the end of the duration, the hail disappears, leaving no aftereffects (other than the damage dealt).

Arcane Material Component: A pinch of dust and a few drops of water.','{"class_levels":{"druid":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Drd 4, Sor/Wiz 4, Water 5","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Cylinder (20-ft. radius, 40 ft. high)","Duration":"1 full round","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_identify','Identify','Brd 1, Magic 2, Sor/Wiz 1',1,'Divination','Touch',NULL,NULL,'Instantaneous','V, S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 1, Magic 2, Sor/Wiz 1

Components: V, S, M/DF

Casting Time: 1 hour

Range: Touch

Targets: One touched object

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

The spell determines all magic properties of a single magic item, including how to activate those functions (if appropriate), and how many charges are left (if any).

Identify does not function when used on an artifact.

Arcane Material Component: A pearl of at least 100 gp value, crushed and stirred into wine with an owl feather; the infusion must be drunk prior to spellcasting.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Magic 2, Sor/Wiz 1","Components":"V, S, M/DF","Casting Time":"1 hour","Range":"Touch","Targets":"One touched object","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_illusory_script','Illusory Script','Brd 3, Sor/Wiz 3',3,'Illusion (Phantasm) [Mind-Affecting]','Touch','One touched object weighing no more than 10 lb.',NULL,'One day/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Phantasm) \[Mind-Affecting\]

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Casting Time: 1 minute or longer; see text

Range: Touch

Target: One touched object weighing no more than 10 lb.

Duration: One day/level (D)

Saving Throw: Will negates; see text

Spell Resistance: Yes

You write instructions or other information on parchment, paper, or any suitable writing material. The illusory script appears to be some form of foreign or magical writing. Only the person (or people) designated by you at the time of the casting are able to read the writing; it’s unintelligible to any other character, although an illusionist recognizes it as illusory script.

Any unauthorized creature attempting to read the script triggers a potent illusory effect and must make a saving throw. A successful saving throw means the creature can look away with only a mild sense of disorientation. Failure means the creature is subject to a suggestion implanted in the script by you at the time the illusory script spell was cast. The suggestion lasts only 30 minutes. Typical suggestions include “Close the book and leave,” “Forget the existence of the book,” and so forth. If successfully dispelled by dispel magic, the illusory script and its secret message disappear. The hidden message can be read by a combination of the true seeing spell with the read magic or comprehend languages spell.

The casting time depends on how long a message you wish to write, but it is always at least 1 minute.

Material Component: A lead-based ink (cost of not less than 50 gp).','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 minute or longer; see text","Range":"Touch","Target":"One touched object weighing no more than 10 lb.","Duration":"One day/level (D)","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_illusory_wall','Illusory Wall','Sor/Wiz 4',4,'Illusion (Figment)','Close (25 ft. + 5 ft./2 levels)','Image 1 ft. by 10 ft. by 10 ft.',NULL,'Permanent','V, S',ARRAY['sorcerer','wizard']::text[],'Illusion (Figment)

Level: Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Image 1 ft. by 10 ft. by 10 ft.

Duration: Permanent

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

This spell creates the illusion of a wall, floor, ceiling, or similar surface. It appears absolutely real when viewed, but physical objects can pass through it without difficulty. When the spell is used to hide pits, traps, or normal doors, any detection abilities that do not require sight work normally. Touch or a probing search reveals the true nature of the surface, though such measures do not cause the illusion to disappear.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Image 1 ft. by 10 ft. by 10 ft.","Duration":"Permanent","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_imbue_with_spell_ability','Imbue with Spell Ability','Clr 4, Magic 4',4,'Evocation','Touch','Creature touched; see text',NULL,'Permanent until discharged (D)','V, S, DF',ARRAY['cleric']::text[],'Evocation

Level: Clr 4, Magic 4

Components: V, S, DF

Casting Time: 10 minutes

Range: Touch

Target: Creature touched; see text

Duration: Permanent until discharged (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

You transfer some of your currently prepared spells, and the ability to cast them, to another creature. Only a creature with an Intelligence score of at least 5 and a Wisdom score of at least 9 can receive this bestowal. Only cleric spells from the schools of abjuration, divination, and conjuration (healing) can be transferred. The number and level of spells that the subject can be granted depends on its Hit Dice; even multiple castings of imbue with spell ability can’t exceed this limit.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD of Recipient</th><th>Spells Imbued</th></tr><tr><td>2 or lower</td><td>One 1st-level spell</td></tr><tr><td>3–4</td><td>One or two 1st-level spells</td></tr><tr><td>5 or higher</td><td>One or two 1st-level spells and one 2nd-level spell</td></tr></tbody></table>

The transferred spell’s variable characteristics (range, duration, area, and the like) function according to your level, not the level of the recipient.

Once you cast imbue with spell ability, you cannot prepare a new 4th-level spell to replace it until the recipient uses the imbued spells or is slain, or until you dismiss the imbue with spell ability spell. In the meantime, you remain responsible to your deity or your principles for the use to which the spell is put. If the number of 4th-level spells you can cast decreases, and that number drops below your current number of active imbue with spell ability spells, the more recently cast imbued spells are dispelled.

To cast a spell with a verbal component, the subject must be able to speak. To cast a spell with a somatic component, it must have humanlike hands. To cast a spell with a material component or focus, it must have the materials or focus.','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4, Magic 4","Components":"V, S, DF","Casting Time":"10 minutes","Range":"Touch","Target":"Creature touched; see text","Duration":"Permanent until discharged (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_implosion','Implosion','Clr 9, Destruction 9',9,'Evocation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Concentration (up to 4 rounds)','V, S',ARRAY['cleric']::text[],'Evocation

Level: Clr 9, Destruction 9

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One corporeal creature/round

Duration: Concentration (up to 4 rounds)

Saving Throw: Fortitude negates

Spell Resistance: Yes

You create a destructive resonance in a corporeal creature’s body. For each round you concentrate, you cause one creature to collapse in on itself, killing it. (This effect, being instantaneous, cannot be dispelled.)

You can target a particular creature only once with each casting of the spell.

Implosion has no effect on creatures in gaseous form or on incorporeal creatures.','{"class_levels":{"cleric":9},"source_field_values":{"Level":"Clr 9, Destruction 9","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One corporeal creature/round","Duration":"Concentration (up to 4 rounds)","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_imprisonment','Imprisonment','Sor/Wiz 9',9,'Abjuration','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 9

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will negates; see text

Spell Resistance: Yes

When you cast imprisonment and touch a creature, it is entombed in a state of suspended animation (see the temporal stasis spell) in a small sphere far beneath the surface of the earth. The subject remains there unless a freedom spell is cast at the locale where the imprisonment took place. Magical search by a crystal ball, a locate object spell, or some other similar divination does not reveal the fact that a creature is imprisoned, but discern location does. A wish or miracle spell will not free the recipient, but will reveal where it is entombed. If you know the target’s name and some facts about its life, the target takes a –4 penalty on its save.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_incendiary_cloud','Incendiary Cloud','Fire 8, Sor/Wiz 8',8,'Conjuration (Creation) [Fire]','Medium (100 ft. + 10 ft./level)','Cloud spreads in 20-ft. radius, 20 ft. high',NULL,'1 round/level','V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation) \[Fire\]

Level: Fire 8, Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Cloud spreads in 20-ft. radius, 20 ft. high

Duration: 1 round/level

Saving Throw: Reflex half; see text

Spell Resistance: No

An incendiary cloud spell creates a cloud of roiling smoke shot through with white-hot embers. The smoke obscures all sight as a fog cloud does. In addition, the white-hot embers within the cloud deal 4d6 points of fire damage to everything within the cloud on your turn each round. All targets can make Reflex saves each round to take half damage.

As with a cloudkill spell, the smoke moves away from you at 10 feet per round. Figure out the smoke’s new spread each round based on its new point of origin, which is 10 feet farther away from where you were when you cast the spell. By concentrating, you can make the cloud (actually its point of origin) move as much as 60 feet each round. Any portion of the cloud that would extend beyond your maximum range dissipates harmlessly, reducing the remainder’s spread thereafter.

As with fog cloud, wind disperses the smoke, and the spell can’t be cast underwater.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Fire 8, Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Cloud spreads in 20-ft. radius, 20 ft. high","Duration":"1 round/level","Saving Throw":"Reflex half; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_critical_wounds','Inflict Critical Wounds','Clr 4, Destruction 4',4,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 4, Destruction 4

This spell functions like inflict light wounds, except that you deal 4d8 points of damage +1 point per caster level (maximum +20).','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4, Destruction 4"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_critical_wounds_mass','Inflict Critical Wounds, Mass','Clr 8',8,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 8

This spell functions like mass inflict light wounds, except that it deals 4d8 points of damage +1 point per caster level (maximum +40).','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Clr 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_light_wounds','Inflict Light Wounds','Clr 1, Destruction 1',1,'Necromancy','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric']::text[],'Necromancy

Level: Clr 1, Destruction 1

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will half

Spell Resistance: Yes

When laying your hand upon a creature, you channel negative energy that deals 1d8 points of damage +1 point per caster level (maximum +5).

Since undead are powered by negative energy, this spell cures such a creature of a like amount of damage, rather than harming it.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1, Destruction 1","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_light_wounds_mass','Inflict Light Wounds, Mass','Clr 5, Destruction 5',5,'Necromancy','Close (25 ft. + 5 ft./2 levels)','One creature/level, no two of which can be more than 30 ft. apart',NULL,'Instantaneous','V, S',ARRAY['cleric']::text[],'Necromancy

Level: Clr 5, Destruction 5

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature/level, no two of which can be more than 30 ft. apart

Duration: Instantaneous

Saving Throw: Will half

Spell Resistance: Yes

Negative energy spreads out in all directions from the point of origin, dealing 1d8 points of damage +1 point per caster level (maximum +25) to nearby living enemies.

Like other inflict spells, mass inflict light wounds cures undead in its area rather than damaging them. A cleric capable of spontaneously casting inflict spells can also spontaneously cast mass inflict spells.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5, Destruction 5","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"Instantaneous","Saving Throw":"Will half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_minor_wounds','Inflict Minor Wounds','Clr 0',0,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 0

Saving Throw: Will negates

This spell functions like inflict light wounds, except that you deal 1 point of damage and a Will save negates the damage instead of halving it.','{"class_levels":{"cleric":0},"source_field_values":{"Level":"Clr 0","Saving Throw":"Will negates"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_moderate_wounds','Inflict Moderate Wounds','Clr 2',2,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 2

This spell functions like inflict light wounds, except that you deal 2d8 points of damage +1 point per caster level (maximum +10).','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_moderate_wounds_mass','Inflict Moderate Wounds, Mass','Clr 6',6,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 6

This spell functions like mass inflict light wounds, except that it deals 2d8 points of damage +1 point per caster level (maximum +30).','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_serious_wounds','Inflict Serious Wounds','Clr 3',3,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 3

This spell functions like inflict light wounds, except that you deal 3d8 points of damage +1 point per caster level (maximum +15).','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_inflict_serious_wounds_mass','Inflict Serious Wounds, Mass','Clr 7',7,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Necromancy

Level: Clr 7

This spell functions like mass inflict light wounds, except that it deals 3d8 points of damage +1 point per caster level (maximum +35).','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_insanity','Insanity','Sor/Wiz 7',7,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One living creature',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One living creature

Duration: Instantaneous

Saving Throw: Will negates

Spell Resistance: Yes

The affected creature suffers from a continuous confusion effect, as the spell.

Remove curse does not remove insanity. Greater restoration, heal, limited wish, miracle, or wish can restore the creature.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One living creature","Duration":"Instantaneous","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_insect_plague','Insect Plague','Clr 5, Drd 5',5,'Conjuration (Summoning)','Long (400 ft. + 40 ft./level)','One swarm of locusts per three levels, each of which must be adjacent to at least one other swarm',NULL,'1 min./level','V, S, DF',ARRAY['cleric','druid']::text[],'Conjuration (Summoning)

Level: Clr 5, Drd 5

Components: V, S, DF

Casting Time: 1 round

Range: Long (400 ft. + 40 ft./level)

Effect: One swarm of locusts per three levels, each of which must be adjacent to at least one other swarm

Duration: 1 min./level

Saving Throw: None

Spell Resistance: No

You summon a number of swarms of locusts (one per three levels, to a maximum of six swarms at 18th level). The swarms must be summoned so that each one is adjacent to at least one other swarm (that is, the swarms must fill one contiguous area). You may summon the locust swarms so that they share the area of other creatures. Each swarm attacks any creatures occupying its area. The swarms are stationary after being summoned, and won’t pursue creatures that flee.','{"class_levels":{"cleric":5,"druid":5},"source_field_values":{"Level":"Clr 5, Drd 5","Components":"V, S, DF","Casting Time":"1 round","Range":"Long (400 ft. + 40 ft./level)","Effect":"One swarm of locusts per three levels, each of which must be adjacent to at least one other swarm","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_instant_summons','Instant Summons','Sor/Wiz 7',7,'Conjuration (Summoning)','See text','One object weighing 10 lb. or less whose longest dimension is 6 ft. or less',NULL,'Permanent until discharged','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Summoning)

Level: Sor/Wiz 7

Components: V, S, M

Casting Time: 1 standard action

Range: See text

Target: One object weighing 10 lb. or less whose longest dimension is 6 ft. or less

Duration: Permanent until discharged

Saving Throw: None

Spell Resistance: No

You call some nonliving item from virtually any location directly to your hand.

First, you must place your arcane mark on the item. Then you cast this spell, which magically and invisibly inscribes the name of the item on a sapphire worth at least 1,000 gp. Thereafter, you can summon the item by speaking a special word (set by you when the spell is cast) and crushing the gem. The item appears instantly in your hand. Only you can use the gem in this way.

If the item is in the possession of another creature, the spell does not work, but you know who the possessor is and roughly where that creature is located when the summons occurs.

The inscription on the gem is invisible. It is also unreadable, except by means of a read magic spell, to anyone but you.

The item can be summoned from another plane, but only if no other creature has claimed ownership of it.

Material Component: A sapphire worth at least 1,000 gp.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 standard action","Range":"See text","Target":"One object weighing 10 lb. or less whose longest dimension is 6 ft. or less","Duration":"Permanent until discharged","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_interposing_hand','Interposing Hand','Sor/Wiz 5',5,'Evocation [Force]','Medium (100 ft. + 10 ft./level)','10-ft. hand',NULL,'1 round/level (D)','V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 5

Components: V, S, F

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: 10-ft. hand

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: Yes

Interposing hand creates a Large magic hand that appears between you and one opponent. This floating, disembodied hand then moves to remain between the two of you, regardless of where you move or how the opponent tries to get around it, providing cover (+4 AC) for you against that opponent. Nothing can fool the hand—it sticks with the selected opponent in spite of darkness, invisibility, polymorphing, or any other attempt at hiding or disguise. The hand does not pursue an opponent, however.

An interposing hand is 10 feet long and about that wide with its fingers outstretched. It has as many hit points as you do when you’re undamaged, and its AC is 20 (–1 size, +11 natural). It takes damage as a normal creature, but most magical effects that don’t cause damage do not affect it.

The hand never provokes attacks of opportunity from opponents. It cannot push through a wall of force or enter an antimagic field, but it suffers the full effect of a prismatic wall or prismatic sphere. The hand makes saving throws as its caster.

Disintegrate or a successful dispel magic destroys it.

Any creature weighing 2,000 pounds or less that tries to push past the hand is slowed to half its normal speed. The hand cannot reduce the speed of a creature weighing more than 2,000 pounds, but it still affects the creature’s attacks.

Directing the spell to a new target is a move action.

Focus: A soft glove.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, F","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"10-ft. hand","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_invisibility','Invisibility','Brd 2, Sor/Wiz 2, Trickery 2',2,'Illusion (Glamer)','Personal or touch','You or a creature or object weighing no more than 100 lb./level',NULL,'1 min./level (D)','V, S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 2, Sor/Wiz 2, Trickery 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal or touch

Target: You or a creature or object weighing no more than 100 lb./level

Duration: 1 min./level (D)

Saving Throw: Will negates (harmless) or Will negates (harmless, object)

Spell Resistance: Yes (harmless) or Yes (harmless, object)

The creature or object touched becomes invisible, vanishing from sight, even from darkvision. If the recipient is a creature carrying gear, that vanishes, too. If you cast the spell on someone else, neither you nor your allies can see the subject, unless you can normally see invisible things or you employ magic to do so.

Items dropped or put down by an invisible creature become visible; items picked up disappear if tucked into the clothing or pouches worn by the creature. Light, however, never becomes invisible, although a source of light can become so (thus, the effect is that of a light with no visible source). Any part of an item that the subject carries but that extends more than 10 feet from it becomes visible.

Of course, the subject is not magically silenced, and certain other conditions can render the recipient detectable (such as stepping in a puddle). The spell ends if the subject attacks any creature. For purposes of this spell, an attack includes any spell targeting a foe or whose area or effect includes a foe. (Exactly who is a foe depends on the invisible character’s perceptions.) Actions directed at unattended objects do not break the spell. Causing harm indirectly is not an attack. Thus, an invisible being can open doors, talk, eat, climb stairs, summon monsters and have them attack, cut the ropes holding a rope bridge while enemies are on the bridge, remotely trigger traps, open a portcullis to release attack dogs, and so forth. If the subject attacks directly, however, it immediately becomes visible along with all its gear. Spells such as bless that specifically affect allies but not foes are not attacks for this purpose, even when they include foes in their area.

Invisibility can be made permanent (on objects only) with a permanency spell.

Arcane Material Component: An eyelash encased in a bit of gum arabic.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2, Trickery 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal or touch","Target":"You or a creature or object weighing no more than 100 lb./level","Duration":"1 min./level (D)","Saving Throw":"Will negates (harmless) or Will negates (harmless, object)","Spell Resistance":"Yes (harmless) or Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_invisibility_greater','Invisibility, Greater','Brd 4, Sor/Wiz 4',4,'Illusion (Glamer)',NULL,'You or creature touched',NULL,'1 round/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 4, Sor/Wiz 4

Components: V, S

Target: You or creature touched

Duration: 1 round/level (D)

Saving Throw: Will negates (harmless)

This spell functions like invisibility, except that it doesn’t end if the subject attacks.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S","Target":"You or creature touched","Duration":"1 round/level (D)","Saving Throw":"Will negates (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_invisibility_mass','Invisibility, Mass','Sor/Wiz 7',7,'Illusion (Glamer)','Long (400 ft. + 40 ft./level)',NULL,NULL,NULL,'V, S, M',ARRAY['sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Sor/Wiz 7

Components: V, S, M

Range: Long (400 ft. + 40 ft./level)

Targets: Any number of creatures, no two of which can be more than 180 ft. apart

This spell functions like invisibility, except that the effect is mobile with the group and is broken when anyone in the group attacks. Individuals in the group cannot see each other. The spell is broken for any individual who moves more than 180 feet from the nearest member of the group. (If only two individuals are affected, the one moving away from the other one loses its invisibility. If both are moving away from each other, they both become visible when the distance between them exceeds 180 feet.)

Material Component: An eyelash encased in a bit of gum arabic.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Range":"Long (400 ft. + 40 ft./level)","Targets":"Any number of creatures, no two of which can be more than 180 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_invisibility_purge','Invisibility Purge','Clr 3',3,'Evocation','Personal','You',NULL,'1 min./level (D)','V, S',ARRAY['cleric']::text[],'Evocation

Level: Clr 3

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

You surround yourself with a sphere of power with a radius of 5 feet per caster level that negates all forms of invisibility.

Anything invisible becomes visible while in the area.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_invisibility_sphere','Invisibility Sphere','Brd 3, Sor/Wiz 3',3,'Illusion (Glamer)',NULL,NULL,'10-ft.-radius emanation around the creature or object touched',NULL,'V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 3, Sor/Wiz 3

Components: V, S, M

Area: 10-ft.-radius emanation around the creature or object touched

This spell functions like invisibility, except that this spell confers invisibility upon all creatures within 10 feet of the recipient. The center of the effect is mobile with the recipient.

Those affected by this spell can see each other and themselves as if unaffected by the spell. Any affected creature moving out of the area becomes visible, but creatures moving into the area after the spell is cast do not become invisible. Affected creatures (other than the recipient) who attack negate the invisibility only for themselves. If the spell recipient attacks, the invisibility sphere ends.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S, M","Area":"10-ft.-radius emanation around the creature or object touched"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_iron_body','Iron Body','Earth 8, Sor/Wiz 8',8,'Transmutation','Personal','You',NULL,'1 min./level (D)','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Earth 8, Sor/Wiz 8

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

This spell transforms your body into living iron, which grants you several powerful resistances and abilities.

You gain damage reduction 15/adamantine. You are immune to blindness, critical hits, ability score damage, deafness, disease, drowning, electricity, poison, stunning, and all spells or attacks that affect your physiology or respiration, because you have no physiology or respiration while this spell is in effect. You take only half damage from acid and fire of all kinds. However, you also become vulnerable to all special attacks that affect iron golems.

You gain a +6 enhancement bonus to your Strength score, but you take a –6 penalty to Dexterity as well (to a minimum Dexterity score of 1), and your speed is reduced to half normal. You have an arcane spell failure chance of 50% and a –8 armor check penalty, just as if you were clad in full plate armor. You cannot drink (and thus can’t use potions) or play wind instruments.

Your unarmed attacks deal damage equal to a club sized for you (1d4 for Small characters or 1d6 for Medium characters), and you are considered armed when making unarmed attacks.

Your weight increases by a factor of ten, causing you to sink in water like a stone. However, you could survive the crushing pressure and lack of air at the bottom of the ocean—at least until the spell duration expires.

Arcane Material Component: A small piece of iron that was once part of either an iron golem, a hero’s armor, or a war machine.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Earth 8, Sor/Wiz 8","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_ironwood','Ironwood','Drd 6',6,'Transmutation','0 ft.','An _ironwood_ object weighing up to 5 lb./level',NULL,'One day/level (D)','V, S, M',ARRAY['druid']::text[],'Transmutation

Level: Drd 6

Components: V, S, M

Casting Time: 1 minute/lb. created

Range: 0 ft.

Effect: An ironwood object weighing up to 5 lb./level

Duration: One day/level (D)

Saving Throw: None

Spell Resistance: No

Ironwood is a magical substance created by druids from normal wood. While remaining natural wood in almost every way, ironwood is as strong, heavy, and resistant to fire as steel. Spells that affect metal or iron do not function on ironwood. Spells that affect wood do affect ironwood, although ironwood does not burn. Using this spell with wood shape or a wood-related Craft check, you can fashion wooden items that function as steel items. Thus, wooden plate armor and wooden swords can be created that are as durable as their normal steel counterparts. These items are freely usable by druids.

Further, if you make only half as much ironwood as the spell would normally allow, any weapon, shield, or suit of armor so created is treated as a magic item with a +1 enhancement bonus.

Material Component: Wood shaped into the form of the intended ironwood object.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6","Components":"V, S, M","Casting Time":"1 minute/lb. created","Range":"0 ft.","Effect":"An _ironwood_ object weighing up to 5 lb./level","Duration":"One day/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_irresistible_dance','Irresistible Dance','Brd 6, Sor/Wiz 8',6,'Enchantment (Compulsion) [Mind-Affecting]','Touch','Living creature touched',NULL,'1d4+1 rounds','V',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 6, Sor/Wiz 8

Components: V

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 1d4+1 rounds

Saving Throw: None

Spell Resistance: Yes

The subject feels an undeniable urge to dance and begins doing so, complete with foot shuffling and tapping. The spell effect makes it impossible for the subject to do anything other than caper and prance in place. The effect imposes a –4 penalty to Armor Class and a –10 penalty on Reflex saves, and it negates any AC bonus granted by a shield the target holds. The dancing subject provokes attacks of opportunity each round on its turn.','{"class_levels":{"bard":6,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Brd 6, Sor/Wiz 8","Components":"V","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"1d4+1 rounds","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_jump','Jump','Drd 1, Rgr 1, Sor/Wiz 1',1,'Transmutation','Touch','Creature touched',NULL,'1 min./level (D)','V, S, M',ARRAY['druid','ranger','sorcerer','wizard']::text[],'Transmutation

Level: Drd 1, Rgr 1, Sor/Wiz 1

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The subject gets a +10 enhancement bonus on Jump checks. The enhancement bonus increases to +20 at caster level 5th, and to +30 (the maximum) at caster level 9th.

Material Component: A grasshopper’s hind leg, which you break when the spell is cast.','{"class_levels":{"druid":1,"ranger":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Drd 1, Rgr 1, Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_keen_edge','Keen Edge','Sor/Wiz 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'10 min./level','V, S',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One weapon or fifty projectiles, all of which must be in contact with each other at the time of casting

Duration: 10 min./level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

This spell makes a weapon magically keen, improving its ability to deal telling blows. This transmutation doubles the threat range of the weapon. A threat range of 20 becomes 19–20, a threat range of 19–20 becomes 17–20, and a threat range of 18–20 becomes 15–20. The spell can be cast only on piercing or slashing weapons. If cast on arrows or crossbow bolts, the keen edge on a particular projectile ends after one use, whether or not the missile strikes its intended target. (Treat shuriken as arrows, rather than as thrown weapons, for the purpose of this spell.)

Multiple effects that increase a weapon’s threat range (such as the keen edge spell and the Improved Critical feat) don’t stack. You can’t cast this spell on a natural weapon, such as a claw.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One weapon or fifty projectiles, all of which must be in contact with each other at the time of casting","Duration":"10 min./level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_knock','Knock','Sor/Wiz 2',2,'Transmutation','Medium (100 ft. + 10 ft./level)','One door, box, or chest with an area of up to 10 sq. ft./level',NULL,'Instantaneous; see text','V',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 2

Components: V

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One door, box, or chest with an area of up to 10 sq. ft./level

Duration: Instantaneous; see text

Saving Throw: None

Spell Resistance: No

The knock spell opens stuck, barred, locked, held, or arcane locked doors. It opens secret doors, as well as locked or trick-opening boxes or chests. It also loosens welds, shackles, or chains (provided they serve to hold closures shut). If used to open a arcane locked door, the spell does not remove the arcane lock but simply suspends its functioning for 10 minutes. In all other cases, the door does not relock itself or become stuck again on its own. Knock does not raise barred gates or similar impediments (such as a portcullis), nor does it affect ropes, vines, and the like. The effect is limited by the area. Each spell can undo as many as two means of preventing egress.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One door, box, or chest with an area of up to 10 sq. ft./level","Duration":"Instantaneous; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_know_direction','Know Direction','Brd 0, Drd 0',0,'Divination','Personal','You',NULL,'Instantaneous','V, S',ARRAY['bard','druid']::text[],'Divination

Level: Brd 0, Drd 0

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: Instantaneous

You instantly know the direction of north from your current position. The spell is effective in any environment in which “north” exists, but it may not work in extraplanar settings. Your knowledge of north is correct at the moment of casting, but you can get lost again within moments if you don’t find some external reference point to help you keep track of direction.','{"class_levels":{"bard":0,"druid":0},"source_field_values":{"Level":"Brd 0, Drd 0","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md'),
('srd35_spell_legend_lore','Legend Lore','Brd 4, Knowledge 7, Sor/Wiz 6',4,'Divination','Personal','You',NULL,'See text','V, S, M, F',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 4, Knowledge 7, Sor/Wiz 6

Components: V, S, M, F

Casting Time: See text

Range: Personal

Target: You

Duration: See text

Legend lore brings to your mind legends about an important person, place, or thing. If the person or thing is at hand, or if you are in the place in question, the casting time is only 1d4x10 minutes. If you have only detailed information on the person, place, or thing, the casting time is 1d10 days, and the resulting lore is less complete and specific (though it often provides enough information to help you find the person, place, or thing, thus allowing a better legend lore result next time). If you know only rumors, the casting time is 2d6 weeks, and the resulting lore is vague and incomplete (though it often directs you to more detailed information, thus allowing a better legend lore result next time).

During the casting, you cannot engage in other than routine activities: eating, sleeping, and so forth. When completed, the divination brings legends (if any) about the person, place, or things to your mind. These may be legends that are still current, legends that have been forgotten, or even information that has never been generally known. If the person, place, or thing is not of legendary importance, you gain no information. As a rule of thumb, characters who are 11th level and higher are “legendary,” as are the sorts of creatures they contend with, the major magic items they wield, and the places where they perform their key deeds.

Material Component: Incense worth at least 250 gp.

Focus: Four strips of ivory (worth 50 gp each) formed into a rectangle.','{"class_levels":{"bard":4,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 4, Knowledge 7, Sor/Wiz 6","Components":"V, S, M, F","Casting Time":"See text","Range":"Personal","Target":"You","Duration":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-h-l.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
