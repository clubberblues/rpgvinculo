-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_dispel_evil','Dispel Evil','Clr 5, Good 5, Pal 4',4,'Abjuration [Good]','Touch',NULL,NULL,'1 round/level or until discharged, whichever comes first','V, S, DF',ARRAY['cleric','paladin']::text[],'Abjuration \[Good\]

Level: Clr 5, Good 5, Pal 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target or Targets: You and a touched evil creature from another plane; or you and an enchantment or evil spell on a touched creature or object

Duration: 1 round/level or until discharged, whichever comes first

Saving Throw: See text

Spell Resistance: See text

Shimmering, white, holy energy surrounds you. This power has three effects.

First, you gain a +4 deflection bonus to AC against attacks by evil creatures.

Second, on making a successful melee touch attack against an evil creature from another plane, you can choose to drive that creature back to its home plane. The creature can negate the effects with a successful Will save (spell resistance applies). This use discharges and ends the spell.

Third, with a touch you can automatically dispel any one enchantment spell cast by an evil creature or any one evil spell. Exception: Spells that can’t be dispelled by dispel magic also can’t be dispelled by dispel evil. Saving throws and spell resistance do not apply to this effect. This use discharges and ends the spell.','{"class_levels":{"cleric":5,"paladin":4},"source_field_values":{"Level":"Clr 5, Good 5, Pal 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target or Targets":"You and a touched evil creature from another plane; or you and an enchantment or evil spell on a touched creature or object","Duration":"1 round/level or until discharged, whichever comes first","Saving Throw":"See text","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dispel_good','Dispel Good','Clr 5, Evil 5',5,'Abjuration [Evil]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Abjuration \[Evil\]

Level: Clr 5, Evil 5

This spell functions like dispel evil, except that you are surrounded by dark, wavering, unholy energy, and the spell affects good creatures and spells rather than evil ones.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5, Evil 5"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dispel_law','Dispel Law','Chaos 5, Clr 5',5,'Abjuration [Chaotic]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Abjuration \[Chaotic\]

Level: Chaos 5, Clr 5

This spell functions like dispel evil, except that you are surrounded by flickering, yellow, chaotic energy, and the spell affects lawful creatures and spells rather than evil ones.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Chaos 5, Clr 5"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dispel_magic','Dispel Magic','Brd 3, Clr 3, Drd 4, Magic 3, Pal 3, Sor/Wiz 3',3,'Abjuration','Medium (100 ft. + 10 ft./level)',NULL,NULL,'Instantaneous','V, S',ARRAY['bard','cleric','druid','paladin','sorcerer','wizard']::text[],'Abjuration

Level: Brd 3, Clr 3, Drd 4, Magic 3, Pal 3, Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target or Area: One spellcaster, creature, or object; or 20-ft.-radius burst

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

You can use dispel magic to end ongoing spells that have been cast on a creature or object, to temporarily suppress the magical abilities of a magic item, to end ongoing spells (or at least their effects) within an area, or to counter another spellcaster’s spell. A dispelled spell ends as if its duration had expired. Some spells, as detailed in their descriptions, can’t be defeated by dispel magic. Dispel magic can dispel (but not counter) spell-like effects just as it does spells.

Note: The effect of a spell with an instantaneous duration can’t be dispelled, because the magical effect is already over before the dispel magic can take effect.

You choose to use dispel magic in one of three ways: a targeted dispel, an area dispel, or a counterspell:

Targeted Dispel: One object, creature, or spell is the target of the dispel magic spell. You make a dispel check (1d20 + your caster level, maximum +10) against the spell or against each ongoing spell currently in effect on the object or creature. The DC for this dispel check is 11 + the spell’s caster level. If you succeed on a particular check, that spell is dispelled; if you fail, that spell remains in effect.

If you target an object or creature that is the effect of an ongoing spell (such as a monster summoned by monster summoning), you make a dispel check to end the spell that conjured the object or creature.

If the object that you target is a magic item, you make a dispel check against the item’s caster level. If you succeed, all the item’s magical properties are suppressed for 1d4 rounds, after which the item recovers on its own. A suppressed item becomes nonmagical for the duration of the effect. An interdimensional interface (such as a bag of holding) is temporarily closed. A magic item’s physical properties are unchanged: A suppressed magic sword is still a sword (a masterwork sword, in fact). Artifacts and deities are unaffected by mortal magic such as this.

You automatically succeed on your dispel check against any spell that you cast yourself.

Area Dispel: When dispel magic is used in this way, the spell affects everything within a 20-foot radius.

For each creature within the area that is the subject of one or more spells, you make a dispel check against the spell with the highest caster level. If that check fails, you make dispel checks against progressively weaker spells until you dispel one spell (which discharges the dispel magic spell so far as that target is concerned) or until you fail all your checks. The creature’s magic items are not affected.

For each object within the area that is the target of one or more spells, you make dispel checks as with creatures. Magic items are not affected by an area dispel.

For each ongoing area or effect spell whose point of origin is within the area of the dispel magic spell, you can make a dispel check to dispel the spell.

For each ongoing spell whose area overlaps that of the dispel magic spell, you can make a dispel check to end the effect, but only within the overlapping area.

If an object or creature that is the effect of an ongoing spell (such as a monster summoned by monster summoning) is in the area, you can make a dispel check to end the spell that conjured that object or creature (returning it whence it came) in addition to attempting to dispel spells targeting the creature or object.

You may choose to automatically succeed on dispel checks against any spell that you have cast.

Counterspell: When dispel magic is used in this way, the spell targets a spellcaster and is cast as a counterspell. Unlike a true counterspell, however, dispel magic may not work; you must make a dispel check to counter the other spellcaster’s spell.','{"class_levels":{"bard":3,"cleric":3,"druid":4,"paladin":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Clr 3, Drd 4, Magic 3, Pal 3, Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target or Area":"One spellcaster, creature, or object; or 20-ft.-radius burst","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dispel_magic_greater','Dispel Magic, Greater','Brd 5, Clr 6, Drd 6, Sor/Wiz 6',5,'Abjuration',NULL,NULL,NULL,NULL,NULL,ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Abjuration

Level: Brd 5, Clr 6, Drd 6, Sor/Wiz 6

This spell functions like dispel magic, except that the maximum caster level on your dispel check is +20 instead of +10.

Additionally, greater dispel magic has a chance to dispel any effect that remove curse can remove, even if dispel magic can’t dispel that effect.','{"class_levels":{"bard":5,"cleric":6,"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 5, Clr 6, Drd 6, Sor/Wiz 6"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_displacement','Displacement','Brd 3, Sor/Wiz 3',3,'Illusion (Glamer)','Touch','Creature touched',NULL,'1 round/level (D)','V, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 3, Sor/Wiz 3

Components: V, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 round/level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject of this spell appears to be about 2 feet away from its true location. The creature benefits from a 50% miss chance as if it had total concealment. However, unlike actual total concealment, displacement does not prevent enemies from targeting the creature normally. True seeing reveals its true location.

Material Component: A small strip of leather twisted into a loop.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 round/level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_disrupt_undead','Disrupt Undead','Sor/Wiz 0',0,'Necromancy','Close (25 ft. + 5 ft./2 levels)','Ray',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

You direct a ray of positive energy. You must make a ranged touch attack to hit, and if the ray hits an undead creature, it deals 1d6 points of damage to it.','{"class_levels":{"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_disrupting_weapon','Disrupting Weapon','Clr 5',5,'Transmutation','Touch',NULL,NULL,'1 round/level','V, S',ARRAY['cleric']::text[],'Transmutation

Level: Clr 5

Components: V, S

Casting Time: 1 standard action

Range: Touch

Targets: One melee weapon

Duration: 1 round/level

Saving Throw: Will negates (harmless, object); see text

Spell Resistance: Yes (harmless, object)

This spell makes a melee weapon deadly to undead. Any undead creature with HD equal to or less than your caster level must succeed on a Will save or be destroyed utterly if struck in combat with this weapon. Spell resistance does not apply against the destruction effect.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Targets":"One melee weapon","Duration":"1 round/level","Saving Throw":"Will negates (harmless, object); see text","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_divination','Divination','Clr 4, Knowledge 4',4,'Divination','Personal','You',NULL,'Instantaneous','V, S, M',ARRAY['cleric']::text[],'Divination

Level: Clr 4, Knowledge 4

Components: V, S, M

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: Instantaneous

Similar to augury but more powerful, a divination spell can provide you with a useful piece of advice in reply to a question concerning a specific goal, event, or activity that is to occur within one week. The advice can be as simple as a short phrase, or it might take the form of a cryptic rhyme or omen. If your party doesn’t act on the information, the conditions may change so that the information is no longer useful. The base chance for a correct divination is 70% + 1% per caster level, to a maximum of 90%. If the dice roll fails, you know the spell failed, unless specific magic yielding false information is at work.

As with augury, multiple divinations about the same topic by the same caster use the same dice result as the first divination spell and yield the same answer each time.

Material Component: Incense and a sacrificial offering appropriate to your religion, together worth at least 25 gp.','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4, Knowledge 4","Components":"V, S, M","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_divine_favor','Divine Favor','Clr 1, Pal 1',1,'Evocation','Personal','You',NULL,'1 minute','V, S, DF',ARRAY['cleric','paladin']::text[],'Evocation

Level: Clr 1, Pal 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 minute

Calling upon the strength and wisdom of a deity, you gain a +1 luck bonus on attack and weapon damage rolls for every three caster levels you have (at least +1, maximum +6). The bonus doesn’t apply to spell damage.','{"class_levels":{"cleric":1,"paladin":1},"source_field_values":{"Level":"Clr 1, Pal 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 minute"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_divine_power','Divine Power','Clr 4, War 4',4,'Evocation','Personal','You',NULL,'1 round/level','V, S, DF',ARRAY['cleric']::text[],'Evocation

Level: Clr 4, War 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level

Calling upon the divine power of your patron, you imbue yourself with strength and skill in combat. Your base attack bonus becomes equal to your character level (which may give you additional attacks), you gain a +6 enhancement bonus to Strength, and you gain 1 temporary hit point per caster level.','{"class_levels":{"cleric":4},"source_field_values":{"Level":"Clr 4, War 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dominate_animal','Dominate Animal','Animal 3, Drd 3',3,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One animal',NULL,'1 round/level','V, S',ARRAY['druid']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Animal 3, Drd 3

Components: V, S

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Target: One animal

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: Yes

You can enchant an animal and direct it with simple commands such as “Attack,” “Run,” and “Fetch.” Suicidal or self-destructive commands (including an order to attack a creature two or more size categories larger than the dominated animal) are simply ignored.

Dominate animal establishes a mental link between you and the subject creature. The animal can be directed by silent mental command as long as it remains in range. You need not see the creature to control it. You do not receive direct sensory input from the creature, but you know what it is experiencing. Because you are directing the animal with your own intelligence, it may be able to undertake actions normally beyond its own comprehension. You need not concentrate exclusively on controlling the creature unless you are trying to direct it to do something it normally couldn’t do. Changing your instructions or giving a dominated creature a new command is the equivalent of redirecting a spell, so it is a move action.','{"class_levels":{"druid":3},"source_field_values":{"Level":"Animal 3, Drd 3","Components":"V, S","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One animal","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dominate_monster','Dominate Monster','Sor/Wiz 9',9,'Enchantment (Compulsion) [Mind-Affecting]',NULL,'One creature',NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 9

Target: One creature

This spell functions like dominate person, except that the spell is not restricted by creature type.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Target":"One creature"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dominate_person','Dominate Person','Brd 4, Sor/Wiz 5',4,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One humanoid',NULL,'One day/level','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 4, Sor/Wiz 5

Components: V, S

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Target: One humanoid

Duration: One day/level

Saving Throw: Will negates

Spell Resistance: Yes

You can control the actions of any humanoid creature through a telepathic link that you establish with the subject’s mind.

If you and the subject have a common language, you can generally force the subject to perform as you desire, within the limits of its abilities. If no common language exists, you can communicate only basic commands, such as “Come here,” “Go there,” “Fight,” and “Stand still.” You know what the subject is experiencing, but you do not receive direct sensory input from it, nor can it communicate with you telepathically.

Once you have given a dominated creature a command, it continues to attempt to carry out that command to the exclusion of all other activities except those necessary for day-to-day survival (such as sleeping, eating, and so forth). Because of this limited range of activity, a Sense Motive check against DC 15 (rather than DC 25) can determine that the subject’s behavior is being influenced by an enchantment effect (see the Sense Motive skill description).

Changing your instructions or giving a dominated creature a new command is the equivalent of redirecting a spell, so it is a move action.

By concentrating fully on the spell (a standard action), you can receive full sensory input as interpreted by the mind of the subject, though it still can’t communicate with you. You can’t actually see through the subject’s eyes, so it’s not as good as being there yourself, but you still get a good idea of what’s going on.

Subjects resist this control, and any subject forced to take actions against its nature receives a new saving throw with a +2 bonus. Obviously self-destructive orders are not carried out. Once control is established, the range at which it can be exercised is unlimited, as long as you and the subject are on the same plane. You need not see the subject to control it.

If you don’t spend at least 1 round concentrating on the spell each day, the subject receives a new saving throw to throw off the domination.

Protection from evil or a similar spell can prevent you from exercising control or using the telepathic link while the subject is so warded, but such an effect neither prevents the establishment of domination nor dispels it.','{"class_levels":{"bard":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 4, Sor/Wiz 5","Components":"V, S","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One humanoid","Duration":"One day/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_doom','Doom','Clr 1',1,'Necromancy [Fear, Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One living creature',NULL,'1 min./level','V, S, DF',ARRAY['cleric']::text[],'Necromancy \[Fear, Mind-Affecting\]

Level: Clr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One living creature

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

This spell fills a single subject with a feeling of horrible dread that causes it to become shaken.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One living creature","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dream','Dream','Brd 5, Sor/Wiz 5',5,'Illusion (Phantasm) [Mind-Affecting]','Unlimited','One living creature touched',NULL,'See text','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Phantasm) \[Mind-Affecting\]

Level: Brd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 minute

Range: Unlimited

Target: One living creature touched

Duration: See text

Saving Throw: None

Spell Resistance: Yes

You, or a messenger touched by you, sends a phantasmal message to others in the form of a dream. At the beginning of the spell, you must name the recipient or identify him or her by some title that leaves no doubt as to identity. The messenger then enters a trance, appears in the intended recipient’s dream, and delivers the message. The message can be of any length, and the recipient remembers it perfectly upon waking. The communication is one-way. The recipient cannot ask questions or offer information, nor can the messenger gain any information by observing the dreams of the recipient.

Once the message is delivered, the messenger’s mind returns instantly to its body. The duration of the spell is the time required for the messenger to enter the recipient’s dream and deliver the message.

If the recipient is awake when the spell begins, the messenger can choose to wake up (ending the spell) or remain in the trance. The messenger can remain in the trance until the recipient goes to sleep, then enter the recipient’s dream and deliver the message as normal. A messenger that is disturbed during the trance comes awake, ending the spell.

Creatures who don’t sleep (such as elves, but not half-elves) or don’t dream cannot be contacted by this spell.

The messenger is unaware of its own surroundings or of the activities around it while in the trance. It is defenseless both physically and mentally (always fails any saving throw) while in the trance.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 minute","Range":"Unlimited","Target":"One living creature touched","Duration":"See text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_eagle_s_splendor','Eagle’s Splendor','Brd 2, Clr 2, Pal 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, M/DF',ARRAY['bard','cleric','paladin','sorcerer','wizard']::text[],'Transmutation

Level: Brd 2, Clr 2, Pal 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The transmuted creature becomes more poised, articulate, and personally forceful. The spell grants a +4 enhancement bonus to Charisma, adding the usual benefits to Charisma-based skill checks and other uses of the Charisma modifier. Sorcerers and bards (and other spellcasters who rely on Charisma) affected by this spell do not gain any additional bonus spells for the increased Charisma, but the save DCs for spells they cast while under this spell’s effect do increase.

Arcane Material Component: A few feathers or a pinch of droppings from an eagle.','{"class_levels":{"bard":2,"cleric":2,"paladin":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Clr 2, Pal 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_eagle_s_splendor_mass','Eagle’s Splendor, Mass','Brd 6, Clr 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One creature/level, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Transmutation

Level: Brd 6, Clr 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like eagle’s splendor, except that it affects multiple creatures.','{"class_levels":{"bard":6,"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Clr 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_earthquake','Earthquake','Clr 8, Destruction 8, Drd 8, Earth 7',8,'Evocation [Earth]','Long (400 ft. + 40 ft./level)',NULL,'80-ft.-radius spread (S)','1 round','V, S, DF',ARRAY['cleric','druid']::text[],'Evocation \[Earth\]

Level: Clr 8, Destruction 8, Drd 8, Earth 7

Components: V, S, DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: 80-ft.-radius spread (S)

Duration: 1 round

Saving Throw: See text

Spell Resistance: No

When you cast earthquake, an intense but highly localized tremor rips the ground. The shock knocks creatures down, collapses structures, opens cracks in the ground, and more. The effect lasts for 1 round, during which time creatures on the ground can’t move or attack. A spellcaster on the ground must make a Concentration check (DC 20 + spell level) or lose any spell he or she tries to cast. The earthquake affects all terrain, vegetation, structures, and creatures in the area. The specific effect of an earthquake spell depends on the nature of the terrain where it is cast.

Cave, Cavern, or Tunnel: The spell collapses the roof, dealing 8d6 points of bludgeoning damage to any creature caught under the cave-in (Reflex DC 15 half ) and pinning that creature beneath the rubble (see below). An earthquake cast on the roof of a very large cavern could also endanger those outside the actual area but below the falling debris.

Cliffs: Earthquake causes a cliff to crumble, creating a landslide that travels horizontally as far as it fell vertically. Any creature in the path takes 8d6 points of bludgeoning damage (Reflex DC 15 half ) and is pinned beneath the rubble (see below).

Open Ground: Each creature standing in the area must make a DC 15 Reflex save or fall down. Fissures open in the earth, and every creature on the ground has a 25% chance to fall into one (Reflex DC 20 to avoid a fissure). At the end of the spell, all fissures grind shut, killing any creatures still trapped within.

Structure: Any structure standing on open ground takes 100 points of damage, enough to collapse a typical wooden or masonry building, but not a structure built of stone or reinforced masonry. Hardness does not reduce this damage, nor is it halved as damage dealt to objects normally is. Any creature caught inside a collapsing structure takes 8d6 points of bludgeoning damage (Reflex DC 15 half ) and is pinned beneath the rubble (see below).

River, Lake, or Marsh: Fissures open underneath the water, draining away the water from that area and forming muddy ground. Soggy marsh or swampland becomes quicksand for the duration of the spell, sucking down creatures and structures. Each creature in the area must make a DC 15 Reflex save or sink down in the mud and quicksand. At the end of the spell, the rest of the body of water rushes in to replace the drained water, possibly drowning those caught in the mud.

Pinned beneath Rubble: Any creature pinned beneath rubble takes 1d6 points of nonlethal damage per minute while pinned. If a pinned character falls unconscious, he or she must make a DC 15 Constitution check or take 1d6 points of lethal damage each minute thereafter until freed or dead.','{"class_levels":{"cleric":8,"druid":8},"source_field_values":{"Level":"Clr 8, Destruction 8, Drd 8, Earth 7","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"80-ft.-radius spread (S)","Duration":"1 round","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_elemental_swarm','Elemental Swarm','Air 9, Drd 9, Earth 9, Fire 9, Water 9',9,'Conjuration (Summoning) [see text]','Medium (100 ft. + 10 ft./level)','Two or more summoned creatures, no two of which can be more than 30 ft. apart',NULL,'10 min./level (D)','V, S',ARRAY['druid']::text[],'Conjuration (Summoning) \[see text\]

Level: Air 9, Drd 9, Earth 9, Fire 9, Water 9

Components: V, S

Casting Time: 10 minutes

Range: Medium (100 ft. + 10 ft./level)

Effect: Two or more summoned creatures, no two of which can be more than 30 ft. apart

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell opens a portal to an Elemental Plane and summons elementals from it. A druid can choose the plane (Air, Earth, Fire, or Water); a cleric opens a portal to the plane matching his domain.

When the spell is complete, 2d4 Large elementals appear. Ten minutes later, 1d4 Huge elementals appear. Ten minutes after that, one greater elemental appears. Each elemental has maximum hit points per HD. Once these creatures appear, they serve you for the duration of the spell.

The elementals obey you explicitly and never attack you, even if someone else manages to gain control over them. You do not need to concentrate to maintain control over the elementals. You can dismiss them singly or in groups at any time.

When you use a summoning spell to summon an air, earth, fire, or water creature, it is a spell of that type.','{"class_levels":{"druid":9},"source_field_values":{"Level":"Air 9, Drd 9, Earth 9, Fire 9, Water 9","Components":"V, S","Casting Time":"10 minutes","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Two or more summoned creatures, no two of which can be more than 30 ft. apart","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_endure_elements','Endure Elements','Clr 1, Drd 1, Pal 1, Rgr 1, Sor/Wiz 1, Sun 1',1,'Abjuration','Touch','Creature touched',NULL,'24 hours','V, S',ARRAY['cleric','druid','paladin','ranger','sorcerer','wizard']::text[],'Abjuration

Level: Clr 1, Drd 1, Pal 1, Rgr 1, Sor/Wiz 1, Sun 1

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 24 hours

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

A creature protected by endure elements suffers no harm from being in a hot or cold environment. It can exist comfortably in conditions between –50 and 140 degrees Fahrenheit without having to make Fortitude saves). The creature’s equipment is likewise protected.

Endure elements doesn’t provide any protection from fire or cold damage, nor does it protect against other environmental hazards such as smoke, lack of air, and so forth.','{"class_levels":{"cleric":1,"druid":1,"paladin":1,"ranger":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Drd 1, Pal 1, Rgr 1, Sor/Wiz 1, Sun 1","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"24 hours","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_energy_drain','Energy Drain','Clr 9, Sor/Wiz 9',9,'Necromancy',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 9, Sor/Wiz 9

Saving Throw: Fortitude partial; see text for enervation

This spell functions like enervation, except that the creature struck gains 2d4 negative levels, and the negative levels last longer.

There is no saving throw to avoid gaining the negative levels, but 24 hours after gaining them, the subject must make a Fortitude saving throw (DC = energy drain spell’s save DC) for each negative level. If the save succeeds, that negative level is removed. If it fails, the negative level also goes away, but one of the subject’s character levels is permanently drained.

An undead creature struck by the ray gains 2d4x5 temporary hit points for 1 hour.','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 9, Sor/Wiz 9","Saving Throw":"Fortitude partial; see text for _enervation_"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_enervation','Enervation','Sor/Wiz 4',4,'Necromancy','Close (25 ft. + 5 ft./2 levels)','Ray of negative energy',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Ray of negative energy

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

You point your finger and utter the incantation, releasing a black ray of crackling negative energy that suppresses the life force of any living creature it strikes. You must make a ranged touch attack to hit. If the attack succeeds, the subject gains 1d4 negative levels.

If the subject has at least as many negative levels as HD, it dies. Each negative level gives a creature a –1 penalty on attack rolls, saving throws, skill checks, ability checks, and effective level (for determining the power, duration, DC, and other details of spells or special abilities).

Additionally, a spellcaster loses one spell or spell slot from his or her highest available level. Negative levels stack.

Assuming the subject survives, it regains lost levels after a number of hours equal to your caster level (maximum 15 hours). Usually, negative levels have a chance of permanently draining the victim’s levels, but the negative levels from enervation don’t last long enough to do so.

An undead creature struck by the ray gains 1d4x5 temporary hit points for 1 hour.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Ray of negative energy","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_enlarge_person','Enlarge Person','Sor/Wiz 1, Strength 1',1,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One humanoid creature',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 1, Strength 1

Components: V, S, M

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Target: One humanoid creature

Duration: 1 min./level (D)

Saving Throw: Fortitude negates

Spell Resistance: Yes

This spell causes instant growth of a humanoid creature, doubling its height and multiplying its weight by 8. This increase changes the creature’s size category to the next larger one. The target gains a +2 size bonus to Strength, a –2 size penalty to Dexterity (to a minimum of 1), and a –1 penalty on attack rolls and AC due to its increased size.

A humanoid creature whose size increases to Large has a space of 10 feet and a natural reach of 10 feet. This spell does not change the target’s speed.

If insufficient room is available for the desired growth, the creature attains the maximum possible size and may make a Strength check (using its increased Strength) to burst any enclosures in the process. If it fails, it is constrained without harm by the materials enclosing it— the spell cannot be used to crush a creature by increasing its size.

All equipment worn or carried by a creature is similarly enlarged by the spell. Melee and projectile weapons affected by this spell deal more damage. Other magical properties are not affected by this spell. Any enlarged item that leaves an enlarged creature’s possession (including a projectile or thrown weapon) instantly returns to its normal size. This means that thrown weapons deal their normal damage, and projectiles deal damage based on the size of the weapon that fired them. Magical properties of enlarged items are not increased by this spell.

Multiple magical effects that increase size do not stack,.

Enlarge person counters and dispels reduce person.

Enlarge person can be made permanent with a permanency spell.

Material Component: A pinch of powdered iron.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1, Strength 1","Components":"V, S, M","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One humanoid creature","Duration":"1 min./level (D)","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_enlarge_person_mass','Enlarge Person, Mass','Sor/Wiz 4',4,'Transmutation',NULL,'One humanoid creature/level, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 4

Target: One humanoid creature/level, no two of which can be more than 30 ft. apart

This spell functions like enlarge person, except that it affects multiple creatures.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Target":"One humanoid creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_entangle','Entangle','Drd 1, Plant 1, Rgr 1',1,'Transmutation','Long (400 ft. + 40 ft./level)',NULL,'Plants in a 40-ft.-radius spread','1 min./level (D)','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 1, Plant 1, Rgr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Plants in a 40-ft.-radius spread

Duration: 1 min./level (D)

Saving Throw: Reflex partial; see text

Spell Resistance: No

Grasses, weeds, bushes, and even trees wrap, twist, and entwine about creatures in the area or those that enter the area, holding them fast and causing them to become entangled. The creature can break free and move half its normal speed by using a full-round action to make a DC 20 Strength check or a DC 20 Escape Artist check. A creature that succeeds on a Reflex save is not entangled but can still move at only half speed through the area. Each round on your turn, the plants once again attempt to entangle all creatures that have avoided or escaped entanglement.

Note: The effects of the spell may be altered somewhat, based on the nature of the entangling plants.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Plant 1, Rgr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Plants in a 40-ft.-radius spread","Duration":"1 min./level (D)","Saving Throw":"Reflex partial; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_enthrall','Enthrall','Brd 2, Clr 2',2,'Enchantment (Charm) [Language Dependent, Mind-Affecting, Sonic]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 hour or less','V, S',ARRAY['bard','cleric']::text[],'Enchantment (Charm) \[Language Dependent, Mind-Affecting, Sonic\]

Level: Brd 2, Clr 2

Components: V, S

Casting Time: 1 round

Range: Medium (100 ft. + 10 ft./level)

Targets: Any number of creatures

Duration: 1 hour or less

Saving Throw: Will negates; see text

Spell Resistance: Yes

If you have the attention of a group of creatures, you can use this spell to hold them spellbound. To cast the spell, you must speak or sing without interruption for 1 full round. Thereafter, those affected give you their undivided attention, ignoring their surroundings. They are considered to have an attitude of friendly while under the effect of the spell. Any potentially affected creature of a race or religion unfriendly to yours gets a +4 bonus on the saving throw.

A creature with 4 or more HD or with a Wisdom score of 16 or higher remains aware of its surroundings and has an attitude of indifferent. It gains a new saving throw if it witnesses actions that it opposes.

The effect lasts as long as you speak or sing, to a maximum of 1 hour. Those enthralled by your words take no action while you speak or sing and for 1d3 rounds thereafter while they discuss the topic or performance. Those entering the area during the performance must also successfully save or become enthralled. The speech ends (but the 1d3-round delay still applies) if you lose concentration or do anything other than speak or sing.

If those not enthralled have unfriendly or hostile attitudes toward you, they can collectively make a Charisma check to try to end the spell by jeering and heckling. For this check, use the Charisma bonus of the creature with the highest Charisma in the group; others may make Charisma checks to assist. The heckling ends the spell if this check result beats your Charisma check result. Only one such challenge is allowed per use of the spell.

If any member of the audience is attacked or subjected to some other overtly hostile act, the spell ends and the previously enthralled members become immediately unfriendly toward you. Each creature with 4 or more HD or with a Wisdom score of 16 or higher becomes hostile.','{"class_levels":{"bard":2,"cleric":2},"source_field_values":{"Level":"Brd 2, Clr 2","Components":"V, S","Casting Time":"1 round","Range":"Medium (100 ft. + 10 ft./level)","Targets":"Any number of creatures","Duration":"1 hour or less","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_entropic_shield','Entropic Shield','Clr 1, Luck 1',1,'Abjuration','Personal','You',NULL,'1 min./level (D)','V, S',ARRAY['cleric']::text[],'Abjuration

Level: Clr 1, Luck 1

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

A magical field appears around you, glowing with a chaotic blast of multicolored hues. This field deflects incoming arrows, rays, and other ranged attacks. Each ranged attack directed at you for which the attacker must make an attack roll has a 20% miss chance (similar to the effects of concealment). Other attacks that simply work at a distance are not affected.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1, Luck 1","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_erase','Erase','Brd 1, Sor/Wiz 1',1,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One scroll or two pages',NULL,'Instantaneous','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One scroll or two pages

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: No

Erase removes writings of either magical or mundane nature from a scroll or from one or two pages of paper, parchment, or similar surfaces. With this spell, you can remove explosive runes, a glyph of warding, a sepia snake sigil, or an arcane mark, but not illusory script or a symbol spell. Nonmagical writing is automatically erased if you touch it and no one else is holding it. Otherwise, the chance of erasing nonmagical writing is 90%.

Magic writing must be touched to be erased, and you also must succeed on a caster level check (1d20 + caster level) against DC 15. (A natural 1 or 2 is always a failure on this check.) If you fail to erase explosive runes, a glyph of warding, or a sepia snake sigil, you accidentally activate that writing instead.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One scroll or two pages","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_ethereal_jaunt','Ethereal Jaunt','Clr 7, Sor/Wiz 7',7,'Transmutation','Personal','You',NULL,'1 round/level (D)','V, S',ARRAY['cleric','sorcerer','wizard']::text[],'Transmutation

Level: Clr 7, Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level (D)

You become ethereal, along with your equipment. For the duration of the spell, you are in a place called the Ethereal Plane, which overlaps the normal, physical, Material Plane. When the spell expires, you return to material existence.

An ethereal creature is invisible, insubstantial, and capable of moving in any direction, even up or down, albeit at half normal speed. As an insubstantial creature, you can move through solid objects, including living creatures. An ethereal creature can see and hear on the Material Plane, but everything looks gray and ephemeral. Sight and hearing onto the Material Plane are limited to 60 feet.

Force effects and abjurations affect an ethereal creature normally. Their effects extend onto the Ethereal Plane from the Material Plane, but not vice versa. An ethereal creature can’t attack material creatures, and spells you cast while ethereal affect only other ethereal things. Certain material creatures or objects have attacks or effects that work on the Ethereal Plane.

Treat other ethereal creatures and ethereal objects as if they were material.

If you end the spell and become material while inside a material object (such as a solid wall), you are shunted off to the nearest open space and take 1d6 points of damage per 5 feet that you so travel.','{"class_levels":{"cleric":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 7, Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_etherealness','Etherealness','Clr 9, Sor/Wiz 9',9,'Transmutation','Touch; see text',NULL,NULL,'1 min./level (D)',NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Transmutation

Level: Clr 9, Sor/Wiz 9

Range: Touch; see text

Targets: You and one other touched creature per three levels

Duration: 1 min./level (D)

Spell Resistance: Yes

This spell functions like ethereal jaunt, except that you and other willing creatures joined by linked hands (along with their equipment) become ethereal. Besides yourself, you can bring one creature per three caster levels to the Ethereal Plane. Once ethereal, the subjects need not stay together.

When the spell expires, all affected creatures on the Ethereal Plane return to material existence.','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 9, Sor/Wiz 9","Range":"Touch; see text","Targets":"You and one other touched creature per three levels","Duration":"1 min./level (D)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_expeditious_retreat','Expeditious Retreat','Brd 1, Sor/Wiz 1',1,'Transmutation','Personal','You',NULL,'1 min./level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

This spell increases your base land speed by 30 feet. (This adjustment is treated as an enhancement bonus.) There is no effect on other modes of movement, such as burrow, climb, fly, or swim. As with any effect that increases your speed, this spell affects your jumping distance (see the Jump skill).','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_explosive_runes','Explosive Runes','Sor/Wiz 3',3,'Abjuration [Force]','Touch','One touched object weighing no more than 10 lb.',NULL,'Permanent until discharged (D)','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration \[Force\]

Level: Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: One touched object weighing no more than 10 lb.

Duration: Permanent until discharged (D)

Saving Throw: See text

Spell Resistance: Yes

You trace these mystic runes upon a book, map, scroll, or similar object bearing written information. The runes detonate when read, dealing 6d6 points of force damage. Anyone next to the runes (close enough to read them) takes the full damage with no saving throw; any other creature within 10 feet of the runes is entitled to a Reflex save for half damage. The object on which the runes were written also takes full damage (no saving throw).

You and any characters you specifically instruct can read the protected writing without triggering the runes. Likewise, you can remove the runes whenever desired. Another creature can remove them with a successful dispel magic or erase spell, but attempting to dispel or erase the runes and failing to do so triggers the explosion.

Note: Magic traps such as explosive runes are hard to detect and disable. A rogue (only) can use the Search skill to find the runes and Disable Device to thwart them. The DC in each case is 25 + spell level, or 28 for explosive runes.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"One touched object weighing no more than 10 lb.","Duration":"Permanent until discharged (D)","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_eyebite','Eyebite','Brd 6, Sor/Wiz 6',6,'Necromancy [Evil]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'1 round per three levels; see text','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Brd 6, Sor/Wiz 6

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: 1 round per three levels; see text

Saving Throw: Fortitude negates

Spell Resistance: Yes

Each round, you may target a single living creature, striking it with waves of evil power. Depending on the target’s HD, this attack has as many as three effects.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Effect</th></tr><tr><td>10 or more</td><td>Sickened</td></tr><tr><td>5–9</td><td>Panicked, sickened</td></tr><tr><td>4 or less</td><td>Comatose, panicked, sickened</td></tr></tbody></table>

The effects are cumulative and concurrent.

Sickened: Sudden pain and fever sweeps over the subject’s body. A sickened creature takes a –2 penalty on attack rolls, weapon damage rolls, saving throws, skill checks, and ability checks. A creature affected by this spell remains sickened for 10 minutes per caster level. The effects cannot be negated by a remove disease or heal spell, but a remove curse is effective.

Panicked: The subject becomes panicked for 1d4 rounds. Even after the panic ends, the creature remains shaken for 10 minutes per caster level, and it automatically becomes panicked again if it comes within sight of you during that time. This is a fear effect.

Comatose: The subject falls into a catatonic coma for 10 minutes per caster level. During this time, it cannot be awakened by any means short of dispelling the effect. This is not a sleep effect, and thus elves are not immune to it.

The spell lasts for 1 round per three caster levels. You must spend a move action each round after the first to target a foe.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"1 round per three levels; see text","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_fabricate','Fabricate','Sor/Wiz 5',5,'Transmutation','Close (25 ft. + 5 ft./2 levels)','Up to 10 cu. ft./level; see text',NULL,'Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: See text

Range: Close (25 ft. + 5 ft./2 levels)

Target: Up to 10 cu. ft./level; see text

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

You convert material of one sort into a product that is of the same material. Creatures or magic items cannot be created or transmuted by the fabricate spell. The quality of items made by this spell is commensurate with the quality of material used as the basis for the new fabrication. If you work with a mineral, the target is reduced to 1 cubic foot per level instead of 10 cubic feet.

You must make an appropriate Craft check to fabricate articles requiring a high degree of craftsmanship.

Casting requires 1 round per 10 cubic feet (or 1 cubic foot) of material to be affected by the spell.

Material Component: The original material, which costs the same amount as the raw materials required to craft the item to be created.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"See text","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Up to 10 cu. ft./level; see text","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_faerie_fire','Faerie Fire','Drd 1',1,'Evocation [Light]','Long (400 ft. + 40 ft./level)',NULL,'Creatures and objects within a 5-ft.-radius burst','1 min./level (D)','V, S, DF',ARRAY['druid']::text[],'Evocation \[Light\]

Level: Drd 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Creatures and objects within a 5-ft.-radius burst

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: Yes

A pale glow surrounds and outlines the subjects. Outlined subjects shed light as candles. Outlined creatures do not benefit from the concealment normally provided by darkness (though a 2nd-level or higher magical darkness effect functions normally), blur, displacement, invisibility, or similar effects. The light is too dim to have any special effect on undead or dark-dwelling creatures vulnerable to light. The faerie fire can be blue, green, or violet, according to your choice at the time of casting. The faerie fire does not cause any harm to the objects or creatures thus outlined.','{"class_levels":{"druid":1},"source_field_values":{"Level":"Drd 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Creatures and objects within a 5-ft.-radius burst","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_false_life','False Life','Sor/Wiz 2',2,'Necromancy','Personal','You',NULL,'1 hour/level or until discharged; see text','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 hour/level or until discharged; see text

You harness the power of unlife to grant yourself a limited ability to avoid death. While this spell is in effect, you gain temporary hit points equal to 1d10 +1 per caster level (maximum +10).

Material Component: A small amount of alcohol or distilled spirits, which you use to trace certain sigils on your body during casting. These sigils cannot be seen once the alcohol or spirits evaporate.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 hour/level or until discharged; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_false_vision','False Vision','Brd 5, Sor/Wiz 5, Trickery 5',5,'Illusion (Glamer)','Touch',NULL,'40-ft.-radius emanation','1 hour/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 5, Sor/Wiz 5, Trickery 5

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Area: 40-ft.-radius emanation

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

Any divination (scrying) spell used to view anything within the area of this spell instead receives a false image (as the major image spell), as defined by you at the time of casting. As long as the duration lasts, you can concentrate to change the image as desired. While you aren’t concentrating, the image remains static.

Arcane Material Component: The ground dust of a piece of jade worth at least 250 gp, which is sprinkled into the air when the spell is cast.','{"class_levels":{"bard":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 5, Sor/Wiz 5, Trickery 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Area":"40-ft.-radius emanation","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fear','Fear','Brd 3, Sor/Wiz 4',3,'Necromancy [Fear, Mind-Affecting]','30 ft.',NULL,'Cone-shaped burst','1 round/level or 1 round; see text','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Necromancy \[Fear, Mind-Affecting\]

Level: Brd 3, Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: 30 ft.

Area: Cone-shaped burst

Duration: 1 round/level or 1 round; see text

Saving Throw: Will partial

Spell Resistance: Yes

An invisible cone of terror causes each living creature in the area to become panicked unless it succeeds on a Will save. If cornered, a panicked creature begins cowering. If the Will save succeeds, the creature is shaken for 1 round.

Material Component: Either the heart of a hen or a white feather.','{"class_levels":{"bard":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"30 ft.","Area":"Cone-shaped burst","Duration":"1 round/level or 1 round; see text","Saving Throw":"Will partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_feather_fall','Feather Fall','Brd 1, Sor/Wiz 1',1,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Until landing or 1 round/level','V',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 1, Sor/Wiz 1

Components: V

Casting Time: 1 free action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One Medium or smaller freefalling object or creature/level, no two of which may be more than 20 ft. apart

Duration: Until landing or 1 round/level

Saving Throw: Will negates (harmless) or Will negates (object)

Spell Resistance: Yes (object)

The affected creatures or objects fall slowly. Feather fall instantly changes the rate at which the targets fall to a mere 60 feet per round (equivalent to the end of a fall from a few feet), and the subjects take no damage upon landing while the spell is in effect. However, when the spell duration expires, a normal rate of falling resumes.

The spell affects one or more Medium or smaller creatures (including gear and carried objects up to each creature’s maximum load) or objects, or the equivalent in larger creatures: A Large creature or object counts as two Medium creatures or objects, a Huge creature or object counts as two Large creatures or objects, and so forth.

You can cast this spell with an instant utterance, quickly enough to save yourself if you unexpectedly fall. Casting the spell is a free action, like casting a quickened spell, and it counts toward the normal limit of one quickened spell per round. You may even cast this spell when it isn’t your turn.

This spell has no special effect on ranged weapons unless they are falling quite a distance. If the spell is cast on a falling item the object does half normal damage based on its weight, with no bonus for the height of the drop.

Feather fall works only upon free-falling objects. It does not affect a sword blow or a charging or flying creature.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V","Casting Time":"1 free action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One Medium or smaller freefalling object or creature/level, no two of which may be more than 20 ft. apart","Duration":"Until landing or 1 round/level","Saving Throw":"Will negates (harmless) or Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_feeblemind','Feeblemind','Sor/Wiz 5',5,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One creature',NULL,'Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 5

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One creature

Duration: Instantaneous

Saving Throw: Will negates; see text

Spell Resistance: Yes

If the target creature fails a Will saving throw, its Intelligence and Charisma scores each drop to 1. The affected creature is unable to use Intelligence- or Charisma-based skills, cast spells, understand language, or communicate coherently. Still, it knows who its friends are and can follow them and even protect them. The subject remains in this state until a heal, limited wish, miracle, or wish spell is used to cancel the effect of the feeblemind. A creature that can cast arcane spells, such as a sorcerer or a wizard, takes a –4 penalty on its saving throw.

Material Component: A handful of clay, crystal, glass, or mineral spheres.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One creature","Duration":"Instantaneous","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_find_the_path','Find the Path','Brd 6, Clr 6, Drd 6, Knowledge 6, Travel 6',6,'Divination','Personal or touch','You or creature touched',NULL,'10 min./level','V, S, F',ARRAY['bard','cleric','druid']::text[],'Divination

Level: Brd 6, Clr 6, Drd 6, Knowledge 6, Travel 6

Components: V, S, F

Casting Time: 3 rounds

Range: Personal or touch

Target: You or creature touched

Duration: 10 min./level

Saving Throw: None or Will negates (harmless)

Spell Resistance: No or Yes (harmless)

The recipient of this spell can find the shortest, most direct physical route to a specified destination, be it the way into or out of a locale. The locale can be outdoors, underground, or even inside a maze spell. Find the path works with respect to locations, not objects or creatures at a locale. The location must be on the same plane as you are at the time of casting.

The spell enables the subject to sense the correct direction that will eventually lead it to its destination, indicating at appropriate times the exact path to follow or physical actions to take. For example, the spell enables the subject to sense trip wires or the proper word to bypass a glyph of warding. The spell ends when the destination is reached or the duration expires, whichever comes first. Find the path can be used to remove the subject and its companions from the effect of a maze spell in a single round.

This divination is keyed to the recipient, not its companions, and its effect does not predict or allow for the actions of creatures (including guardians).

Focus: A set of divination counters of the sort you favor.','{"class_levels":{"bard":6,"cleric":6,"druid":6},"source_field_values":{"Level":"Brd 6, Clr 6, Drd 6, Knowledge 6, Travel 6","Components":"V, S, F","Casting Time":"3 rounds","Range":"Personal or touch","Target":"You or creature touched","Duration":"10 min./level","Saving Throw":"None or Will negates (harmless)","Spell Resistance":"No or Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_find_traps','Find Traps','Clr 2',2,'Divination','Personal','You',NULL,'1 min./level','V, S',ARRAY['cleric']::text[],'Divination

Level: Clr 2

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level

You gain intuitive insight into the workings of traps. You can use the Search skill to detect traps just as a rogue can. In addition, you gain an insight bonus equal to one-half your caster level (maximum +10) on Search checks made to find traps while the spell is in effect.

Note that find traps grants no ability to disable the traps that you may find.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_finger_of_death','Finger of Death','Drd 8, Sor/Wiz 7',7,'Necromancy [Death]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'Instantaneous','V, S',ARRAY['druid','sorcerer','wizard']::text[],'Necromancy \[Death\]

Level: Drd 8, Sor/Wiz 7

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: Instantaneous

Saving Throw: Fortitude partial

Spell Resistance: Yes

You can slay any one living creature within range. The target is entitled to a Fortitude saving throw to survive the attack. If the save is successful, the creature instead takes 3d6 points of damage +1 point per caster level (maximum +25).

The subject might die from damage even if it succeeds on its saving throw.','{"class_levels":{"druid":8,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Drd 8, Sor/Wiz 7","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"Instantaneous","Saving Throw":"Fortitude partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fire_seeds','Fire Seeds','Drd 6, Fire 6, Sun 6',6,'Conjuration (Creation) [Fire]','Touch',NULL,NULL,'10 min./level or until used','V, S, M',ARRAY['druid']::text[],'Conjuration (Creation) \[Fire\]

Level: Drd 6, Fire 6, Sun 6

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Targets: Up to four touched acorns or up to eight touched holly berries

Duration: 10 min./level or until used

Saving Throw: None or Reflex half; see text

Spell Resistance: No

Depending on the version of fire seeds you choose, you turn acorns into splash weapons that you or another character can throw, or you turn holly berries into bombs that you can detonate on command.

Acorn Grenades: As many as four acorns turn into special splash weapons that can be hurled as far as 100 feet. A ranged touch attack roll is required to strike the intended target. Together, the acorns are capable of dealing 1d6 points of fire damage per caster level (maximum 20d6), divided up among the acorns as you wish.

Each acorn explodes upon striking any hard surface. In addition to its regular fire damage, it deals 1 point of splash damage per die, and it ignites any combustible materials within 10 feet. A creature within this area that makes a successful Reflex saving throw takes only half damage; a creature struck directly is not allowed a saving throw.

Holly Berry Bombs: You turn as many as eight holly berries into special bombs. The holly berries are usually placed by hand, since they are too light to make effective thrown weapons (they can be tossed only 5 feet). If you are within 200 feet and speak a word of command, each berry instantly bursts into flame, causing 1d8 points of fire damage +1 point per caster level to every creature in a 5-foot radius burst and igniting any combustible materials within 5 feet. A creature in the area that makes a successful Reflex saving throw takes only half damage.

Material Component: The acorns or holly berries.','{"class_levels":{"druid":6},"source_field_values":{"Level":"Drd 6, Fire 6, Sun 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Targets":"Up to four touched acorns or up to eight touched holly berries","Duration":"10 min./level or until used","Saving Throw":"None or Reflex half; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fire_shield','Fire Shield','Fire 5, Sor/Wiz 4, Sun 4',4,'Evocation [Fire or Cold]','Personal','You',NULL,'1 round/level (D)','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire or Cold\]

Level: Fire 5, Sor/Wiz 4, Sun 4

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level (D)

This spell wreathes you in flame and causes damage to each creature that attacks you in melee. The flames also protect you from either cold-based or fire-based attacks (your choice).

Any creature striking you with its body or a handheld weapon deals normal damage, but at the same time the attacker takes 1d6 points of damage +1 point per caster level (maximum +15). This damage is either cold damage (if the shield protects against fire-based attacks) or fire damage (if the shield protects against cold-based attacks). If the attacker has spell resistance, it applies to this effect. Creatures wielding weapons with exceptional reach are not subject to this damage if they attack you.

When casting this spell, you appear to immolate yourself, but the flames are thin and wispy, giving off light equal to only half the illumination of a normal torch (10 feet). The color of the flames is determined randomly (50% chance of either color)—blue or green if the chill shield is cast, violet or blue if the warm shield is employed. The special powers of each version are as follows.

Warm Shield: The flames are warm to the touch. You take only half damage from cold-based attacks. If such an attack allows a Reflex save for half damage, you take no damage on a successful save.

Chill Shield: The flames are cool to the touch. You take only half damage from fire-based attacks. If such an attack allows a Reflex save for half damage, you take no damage on a successful save.

Arcane Material Component: A bit of phosphorus for the warm shield; a live firefly or glowworm or the tail portions of four dead ones for the chill shield.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Fire 5, Sor/Wiz 4, Sun 4","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fire_storm','Fire Storm','Clr 8, Drd 7, Fire 7',7,'Evocation [Fire]','Medium (100 ft. + 10 ft./level)',NULL,'Two 10-ft. cubes per level (S)','Instantaneous','V, S',ARRAY['cleric','druid']::text[],'Evocation \[Fire\]

Level: Clr 8, Drd 7, Fire 7

Components: V, S

Casting Time: 1 round

Range: Medium (100 ft. + 10 ft./level)

Area: Two 10-ft. cubes per level (S)

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

When a fire storm spell is cast, the whole area is shot through with sheets of roaring flame. The raging flames do not harm natural vegetation, ground cover, and any plant creatures in the area that you wish to exclude from damage. Any other creature within the area takes 1d6 points of fire damage per caster level (maximum 20d6).','{"class_levels":{"cleric":8,"druid":7},"source_field_values":{"Level":"Clr 8, Drd 7, Fire 7","Components":"V, S","Casting Time":"1 round","Range":"Medium (100 ft. + 10 ft./level)","Area":"Two 10-ft. cubes per level (S)","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fire_trap','Fire Trap','Drd 2, Sor/Wiz 4',2,'Abjuration [Fire]','Touch','Object touched',NULL,'Permanent until discharged (D)','V, S, M',ARRAY['druid','sorcerer','wizard']::text[],'Abjuration \[Fire\]

Level: Drd 2, Sor/Wiz 4

Components: V, S, M

Casting Time: 10 minutes

Range: Touch

Target: Object touched

Duration: Permanent until discharged (D)

Saving Throw: Reflex half; see text

Spell Resistance: Yes

Fire trap creates a fiery explosion when an intruder opens the item that the trap protects. A fire trap can ward any object that can be opened and closed.

When casting fire trap, you select a point on the object as the spell’s center. When someone other than you opens the object, a fiery explosion fills the area within a 5-foot radius around the spell’s center. The flames deal 1d4 points of fire damage +1 point per caster level (maximum +20). The item protected by the trap is not harmed by this explosion.

A fire trapped item cannot have a second closure or warding spell placed on it.

A knock spell does not bypass a fire trap. An unsuccessful dispel magic spell does not detonate the spell.

Underwater, this ward deals half damage and creates a large cloud of steam.

You can use the fire trapped object without discharging it, as can any individual to whom the object was specifically attuned when cast. Attuning a fire trapped object to an individual usually involves setting a password that you can share with friends.

Note: Magic traps such as fire trap are hard to detect and disable. A rogue (only) can use the Search skill to find a fire trap and Disable Device to thwart it. The DC in each case is 25 + spell level (DC 27 for a druid’s fire trap or DC 29 for the arcane version).

Material Component: A half-pound of gold dust (cost 25 gp) sprinkled on the warded object.','{"class_levels":{"druid":2,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Drd 2, Sor/Wiz 4","Components":"V, S, M","Casting Time":"10 minutes","Range":"Touch","Target":"Object touched","Duration":"Permanent until discharged (D)","Saving Throw":"Reflex half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fireball','Fireball','Sor/Wiz 3',3,'Evocation [Fire]','Long (400 ft. + 40 ft./level)',NULL,'20-ft.-radius spread','Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: 20-ft.-radius spread

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

A fireball spell is an explosion of flame that detonates with a low roar and deals 1d6 points of fire damage per caster level (maximum 10d6) to every creature within the area. Unattended objects also take this damage. The explosion creates almost no pressure.

You point your finger and determine the range (distance and height) at which the fireball is to burst. A glowing, pea-sized bead streaks from the pointing digit and, unless it impacts upon a material body or solid barrier prior to attaining the prescribed range, blossoms into the fireball at that point. (An early impact results in an early detonation.) If you attempt to send the bead through a narrow passage, such as through an arrow slit, you must “hit” the opening with a ranged touch attack, or else the bead strikes the barrier and detonates prematurely.

The fireball sets fire to combustibles and damages objects in the area. It can melt metals with low melting points, such as lead, gold, copper, silver, and bronze. If the damage caused to an interposing barrier shatters or breaks through it, the fireball may continue beyond the barrier if the area permits; otherwise it stops at the barrier just as any other spell effect does.

Material Component: A tiny ball of bat guano and sulfur.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"20-ft.-radius spread","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flame_arrow','Flame Arrow','Sor/Wiz 3',3,'Transmutation [Fire]','Close (25 ft. + 5 ft./2 levels)','Fifty projectiles, all of which must be in contact with each other at the time of casting',NULL,'10 min./level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation \[Fire\]

Level: Sor/Wiz 3

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: Fifty projectiles, all of which must be in contact with each other at the time of casting

Duration: 10 min./level

Saving Throw: None

Spell Resistance: No

You turn ammunition (such as arrows, bolts, shuriken, and stones) into fiery projectiles. Each piece of ammunition deals an extra 1d6 points of fire damage to any target it hits. A flaming projectile can easily ignite a flammable object or structure, but it won’t ignite a creature it strikes.

Material Component: A drop of oil and a small piece of flint.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Fifty projectiles, all of which must be in contact with each other at the time of casting","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flame_blade','Flame Blade','Drd 2',2,'Evocation [Fire]','0 ft.','Sword-like beam',NULL,'1 min./level (D)','V, S, DF',ARRAY['druid']::text[],'Evocation \[Fire\]

Level: Drd 2

Components: V, S, DF

Casting Time: 1 standard action

Range: 0 ft.

Effect: Sword-like beam

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: Yes

A 3-foot-long, blazing beam of red-hot fire springs forth from your hand. You wield this bladelike beam as if it were a scimitar. Attacks with the flame blade are melee touch attacks. The blade deals 1d8 points of fire damage +1 point per two caster levels (maximum +10). Since the blade is immaterial, your Strength modifier does not apply to the damage. A flame blade can ignite combustible materials such as parchment, straw, dry sticks, and cloth.

The spell does not function underwater.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"0 ft.","Effect":"Sword-like beam","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flame_strike','Flame Strike','Clr 5, Drd 4, Sun 5, War 5',4,'Evocation [Fire]','Medium (100 ft. + 10 ft./level)',NULL,'Cylinder (10-ft. radius, 40 ft. high)','Instantaneous','V, S, DF',ARRAY['cleric','druid']::text[],'Evocation \[Fire\]

Level: Clr 5, Drd 4, Sun 5, War 5

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Cylinder (10-ft. radius, 40 ft. high)

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

A flame strike produces a vertical column of divine fire roaring downward. The spell deals 1d6 points of damage per caster level (maximum 15d6). Half the damage is fire damage, but the other half results directly from divine power and is therefore not subject to being reduced by resistance to fire-based attacks.','{"class_levels":{"cleric":5,"druid":4},"source_field_values":{"Level":"Clr 5, Drd 4, Sun 5, War 5","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Cylinder (10-ft. radius, 40 ft. high)","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flaming_sphere','Flaming Sphere','Drd 2, Sor/Wiz 2',2,'Evocation [Fire]','Medium (100 ft. + 10 ft./level)','5-ft.-diameter sphere',NULL,'1 round/level','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Drd 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: 5-ft.-diameter sphere

Duration: 1 round/level

Saving Throw: Reflex negates

Spell Resistance: Yes

A burning globe of fire rolls in whichever direction you point and burns those it strikes. It moves 30 feet per round. As part of this movement, it can ascend or jump up to 30 feet to strike a target. If it enters a space with a creature, it stops moving for the round and deals 2d6 points of fire damage to that creature, though a successful Reflex save negates that damage. A flaming sphere rolls over barriers less than 4 feet tall. It ignites flammable substances it touches and illuminates the same area as a torch would.

The sphere moves as long as you actively direct it (a move action for you); otherwise, it merely stays at rest and burns. It can be extinguished by any means that would put out a normal fire of its size. The surface of the sphere has a spongy, yielding consistency and so does not cause damage except by its flame. It cannot push aside unwilling creatures or batter down large obstacles. A flaming sphere winks out if it exceeds the spell’s range.

Arcane Material Component: A bit of tallow, a pinch of brimstone, and a dusting of powdered iron.','{"class_levels":{"druid":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Drd 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"5-ft.-diameter sphere","Duration":"1 round/level","Saving Throw":"Reflex negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flare','Flare','Brd 0, Drd 0, Sor/Wiz 0',0,'Evocation [Light]','Close (25 ft. + 5 ft./2 levels)','Burst of light',NULL,'Instantaneous','V',ARRAY['bard','druid','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Brd 0, Drd 0, Sor/Wiz 0

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Burst of light

Duration: Instantaneous

Saving Throw: Fortitude negates

Spell Resistance: Yes

This cantrip creates a burst of light. If you cause the light to burst directly in front of a single creature, that creature is dazzled for 1 minute unless it makes a successful Fortitude save. Sightless creatures, as well as creatures already dazzled, are not affected by flare.','{"class_levels":{"bard":0,"druid":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Drd 0, Sor/Wiz 0","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Burst of light","Duration":"Instantaneous","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_flesh_to_stone','Flesh to Stone','Sor/Wiz 6',6,'Transmutation','Medium (100 ft. + 10 ft./level)','One creature',NULL,'Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One creature

Duration: Instantaneous

Saving Throw: Fortitude negates

Spell Resistance: Yes

The subject, along with all its carried gear, turns into a mindless, inert statue. If the statue resulting from this spell is broken or damaged, the subject (if ever returned to its original state) has similar damage or deformities. The creature is not dead, but it does not seem to be alive either when viewed with spells such as deathwatch.

Only creatures made of flesh are affected by this spell.

Material Component: Lime, water, and earth.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One creature","Duration":"Instantaneous","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fly','Fly','Sor/Wiz 3, Travel 3',3,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, F/DF',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Sor/Wiz 3, Travel 3

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject can fly at a speed of 60 feet (or 40 feet if it wears medium or heavy armor, or if it carries a medium or heavy load). It can ascend at half speed and descend at double speed, and its maneuverability is good. Using a fly spell requires only as much concentration as walking, so the subject can attack or cast spells normally. The subject of a fly spell can charge but not run, and it cannot carry aloft more weight than its maximum load, plus any armor it wears.

Should the spell duration expire while the subject is still aloft, the magic fails slowly. The subject floats downward 60 feet per round for 1d6 rounds. If it reaches the ground in that amount of time, it lands safely. If not, it falls the rest of the distance, taking 1d6 points of damage per 10 feet of fall. Since dispelling a spell effectively ends it, the subject also descends in this way if the fly spell is dispelled, but not if it is negated by an antimagic field.

Arcane Focus: A wing feather from any bird.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3, Travel 3","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_floating_disk','Floating Disk','Sor/Wiz 1',1,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)','3-ft.-diameter disk of force',NULL,'1 hour/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 1

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: 3-ft.-diameter disk of force

Duration: 1 hour/level

Saving Throw: None

Spell Resistance: No

You create a slightly concave, circular plane of force that follows you about and carries loads for you. The disk is 3 feet in diameter and 1 inch deep at its center. It can hold 100 pounds of weight per caster level. (If used to transport a liquid, its capacity is 2 gallons.) The disk floats approximately 3 feet above the ground at all times and remains level. It floats along horizontally within spell range and will accompany you at a rate of no more than your normal speed each round. If not otherwise directed, it maintains a constant interval of 5 feet between itself and you. The disk winks out of existence when the spell duration expires. The disk also winks out if you move beyond range or try to take the disk more than 3 feet away from the surface beneath it. When the disk winks out, whatever it was supporting falls to the surface beneath it.

Material Component: A drop of mercury.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"3-ft.-diameter disk of force","Duration":"1 hour/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fog_cloud','Fog Cloud','Drd 2, Sor/Wiz 2, Water 2',2,'Conjuration (Creation)','Medium (100 ft. + 10 ft. level)','Fog spreads in 20-ft. radius, 20 ft. high',NULL,'10 min./level','V, S',ARRAY['druid','sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Drd 2, Sor/Wiz 2, Water 2

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft. level)

Effect: Fog spreads in 20-ft. radius, 20 ft. high

Duration: 10 min./level

Saving Throw: None

Spell Resistance: No

A bank of fog billows out from the point you designate. The fog obscures all sight, including darkvision, beyond 5 feet. A creature within 5 feet has concealment (attacks have a 20% miss chance). Creatures farther away have total concealment (50% miss chance, and the attacker can’t use sight to locate the target).

A moderate wind (11+ mph) disperses the fog in 4 rounds; a strong wind (21+ mph) disperses the fog in 1 round.

The spell does not function underwater.','{"class_levels":{"druid":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Drd 2, Sor/Wiz 2, Water 2","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft. level)","Effect":"Fog spreads in 20-ft. radius, 20 ft. high","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_forbiddance','Forbiddance','Clr 6',6,'Abjuration','Medium (100 ft. + 10 ft./level)',NULL,'60-ft. cube/level (S)','Permanent','V, S, M, DF',ARRAY['cleric']::text[],'Abjuration

Level: Clr 6

Components: V, S, M, DF

Casting Time: 6 rounds

Range: Medium (100 ft. + 10 ft./level)

Area: 60-ft. cube/level (S)

Duration: Permanent

Saving Throw: See text

Spell Resistance: Yes

Forbiddance seals an area against all planar travel into or within it. This includes all teleportation spells (such as dimension door and teleport), plane shifting, astral travel, ethereal travel, and all summoning spells. Such effects simply fail automatically.

In addition, it damages entering creatures whose alignments are different from yours. The effect on those attempting to enter the warded area is based on their alignment relative to yours (see below). A creature inside the area when the spell is cast takes no damage unless it exits the area and attempts to reenter, at which time it is affected as normal.

Alignments identical: No effect. The creature may enter the area freely (although not by planar travel).

Alignments different with respect to either law/chaos or good/evil: The creature takes 6d6 points of damage. A successful Will save halves the damage, and spell resistance applies.

Alignments different with respect to both law/chaos and good/evil: The creature takes 12d6 points of damage. A successful Will save halves the damage, and spell resistance applies.

At your option, the abjuration can include a password, in which case creatures of alignments different from yours can avoid the damage by speaking the password as they enter the area. You must select this option (and the password) at the time of casting.

Dispel magic does not dispel a forbiddance effect unless the dispeller’s level is at least as high as your caster level.

You can’t have multiple overlapping forbiddance effects. In such a case, the more recent effect stops at the boundary of the older effect.

Material Component: A sprinkling of holy water and rare incenses worth at least 1,500 gp, plus 1,500 gp per 60-foot cube. If a password is desired, this requires the burning of additional rare incenses worth at least 1,000 gp, plus 1,000 gp per 60-foot cube.','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6","Components":"V, S, M, DF","Casting Time":"6 rounds","Range":"Medium (100 ft. + 10 ft./level)","Area":"60-ft. cube/level (S)","Duration":"Permanent","Saving Throw":"See text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_forcecage','Forcecage','Sor/Wiz 7',7,'Evocation [Force]','Close (25 ft. + 5 ft./2 levels)',NULL,'Barred cage (20-ft. cube) or windowless cell (10-ft. cube)','2 hours/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 7

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: Barred cage (20-ft. cube) or windowless cell (10-ft. cube)

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

This powerful spell brings into being an immobile, invisible cubical prison composed of either bars of force or solid walls of force (your choice).

Creatures within the area are caught and contained unless they are too big to fit inside, in which case the spell automatically fails. Teleportation and other forms of astral travel provide a means of escape, but the force walls or bars extend into the Ethereal Plane, blocking ethereal travel.

Like a wall of force spell, a forcecage resists dispel magic, but it is vulnerable to a disintegrate spell, and it can be destroyed by a sphere of annihilation or a rod of cancellation.

Barred Cage: This version of the spell produces a 20-foot cube made of bands of force (similar to a wall of force spell) for bars. The bands are a half-inch wide, with half-inch gaps between them. Any creature capable of passing through such a small space can escape; others are confined. You can’t attack a creature in a barred cage with a weapon unless the weapon can fit between the gaps. Even against such weapons (including arrows and similar ranged attacks), a creature in the barred cage has cover. All spells and breath weapons can pass through the gaps in the bars.

Windowless Cell: This version of the spell produces a 10-foot cube with no way in and no way out. Solid walls of force form its six sides.

Material Component: Ruby dust worth 1,500 gp, which is tossed into the air and disappears when you cast the spell.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"Barred cage (20-ft. cube) or windowless cell (10-ft. cube)","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_forceful_hand','Forceful Hand','Sor/Wiz 6',6,'Evocation [Force]',NULL,NULL,NULL,NULL,'V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 6

Components: V, S, F

This spell functions like interposing hand, except that the forceful hand pursues and pushes away the opponent that you designate. Treat this attack as a bull rush with a +14 bonus on the Strength check (+8 for Strength 27, +4 for being Large, and a +2 bonus for charging, which it always gets). The hand always moves with the opponent to push that target back the full distance allowed, and it has no speed limit. Directing the spell to a new target is a move action.

A very strong creature could not push the hand out of its way because the latter would instantly reposition itself between the creature and you, but an opponent could push the hand up against you by successfully bull rushing it.

Focus: A sturdy glove made of leather or heavy cloth.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, F"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_foresight','Foresight','Drd 9, Knowledge 9, Sor/Wiz 9',9,'Divination','Personal or touch','See text',NULL,'10 min./level','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Divination

Level: Drd 9, Knowledge 9, Sor/Wiz 9

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal or touch

Target: See text

Duration: 10 min./level

Saving Throw: None or Will negates (harmless)

Spell Resistance: No or Yes (harmless)

This spell grants you a powerful sixth sense in relation to yourself or another. Once foresight is cast, you receive instantaneous warnings of impending danger or harm to the subject of the spell. You are never surprised or flat-footed. In addition, the spell gives you a general idea of what action you might take to best protect yourself and gives you a +2 insight bonus to AC and Reflex saves. This insight bonus is lost whenever you would lose a Dexterity bonus to AC.

When another creature is the subject of the spell, you receive warnings about that creature. You must communicate what you learn to the other creature for the warning to be useful, and the creature can be caught unprepared in the absence of such a warning. Shouting a warning, yanking a person back, and even telepathically communicating (via an appropriate spell) can all be accomplished before some danger befalls the subject, provided you act on the warning without delay. The subject, however, does not gain the insight bonus to AC and Reflex saves.

Arcane Material Component: A hummingbird’s feather.','{"class_levels":{"druid":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Drd 9, Knowledge 9, Sor/Wiz 9","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal or touch","Target":"See text","Duration":"10 min./level","Saving Throw":"None or Will negates (harmless)","Spell Resistance":"No or Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fox_s_cunning','Fox’s Cunning','Brd 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 2, Sor/Wiz 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The transmuted creature becomes smarter. The spell grants a +4 enhancement bonus to Intelligence, adding the usual benefits to Intelligence-based skill checks and other uses of the Intelligence modifier. Wizards (and other spellcasters who rely on Intelligence) affected by this spell do not gain any additional bonus spells for the increased Intelligence, but the save DCs for spells they cast while under this spell’s effect do increase. This spell doesn’t grant extra skill points.

Arcane Material Component: A few hairs, or a pinch of dung, from a fox.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_fox_s_cunning_mass','Fox’s Cunning, Mass','Brd 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One creature/level, no two of which can be more than 30 ft. apart',NULL,NULL,NULL,ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like fox’s cunning, except that it affects multiple creatures.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_freedom','Freedom','Sor/Wiz 9',9,'Abjuration','Close (25 ft. + 5 ft./2 levels) or see text','One creature',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 9

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels) or see text

Target: One creature

Duration: Instantaneous

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The subject is freed from spells and effects that restrict its movement, including binding, entangle, grappling, imprisonment, maze, paralysis, petrification, pinning, sleep, slow, stunning, temporal stasis, and web. To free a creature from imprisonment or maze, you must know its name and background, and you must cast this spell at the spot where it was entombed or banished into the maze.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels) or see text","Target":"One creature","Duration":"Instantaneous","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_freedom_of_movement','Freedom of Movement','Brd 4, Clr 4, Drd 4, Luck 4, Rgr 4',4,'Abjuration','Personal or touch','You or creature touched',NULL,'10 min./level','V, S, M, DF',ARRAY['bard','cleric','druid','ranger']::text[],'Abjuration

Level: Brd 4, Clr 4, Drd 4, Luck 4, Rgr 4

Components: V, S, M, DF

Casting Time: 1 standard action

Range: Personal or touch

Target: You or creature touched

Duration: 10 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

This spell enables you or a creature you touch to move and attack normally for the duration of the spell, even under the influence of magic that usually impedes movement, such as paralysis, solid fog, slow, and web. The subject automatically succeeds on any grapple check made to resist a grapple attempt, as well as on grapple checks or Escape Artist checks made to escape a grapple or a pin.

The spell also allows the subject to move and attack normally while underwater, even with slashing weapons such as axes and swords or with bludgeoning weapons such as flails, hammers, and maces, provided that the weapon is wielded in the hand rather than hurled. The freedom of movement spell does not, however, allow water breathing.

Material Component: A leather thong, bound around the arm or a similar appendage.','{"class_levels":{"bard":4,"cleric":4,"druid":4,"ranger":4},"source_field_values":{"Level":"Brd 4, Clr 4, Drd 4, Luck 4, Rgr 4","Components":"V, S, M, DF","Casting Time":"1 standard action","Range":"Personal or touch","Target":"You or creature touched","Duration":"10 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_freezing_sphere','Freezing Sphere','Sor/Wiz 6',6,'Evocation [Cold]','Long (400 ft. + 40 ft./level)',NULL,NULL,'Instantaneous or 1 round/level; see text','V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Sor/Wiz 6

Components: V, S, F

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Target, Effect, or Area: See text

Duration: Instantaneous or 1 round/level; see text

Saving Throw: Reflex half; see text

Spell Resistance: Yes

Freezing sphere creates a frigid globe of cold energy that streaks from your fingertips to the location you select, where it explodes in a 10-foot-radius burst, dealing 1d6 points of cold damage per caster level (maximum 15d6) to each creature in the area. An elemental (water) creature instead takes 1d8 points of cold damage per caster level (maximum 15d8).

If the freezing sphere strikes a body of water or a liquid that is principally water (not including water-based creatures), it freezes the liquid to a depth of 6 inches over an area equal to 100 square feet (a 10- foot square) per caster level (maximum 1,500 square feet). This ice lasts for 1 round per caster level. Creatures that were swimming on the surface of frozen water become trapped in the ice. Attempting to break free is a full-round action. A trapped creature must make a DC 25 Strength check or a DC 25 Escape Artist check to do so.

You can refrain from firing the globe after completing the spell, if you wish. Treat this as a touch spell for which you are holding the charge. You can hold the charge for as long as 1 round per level, at the end of which time the freezing sphere bursts centered on you (and you receive no saving throw to resist its effect). Firing the globe in a later round is a standard action.

Focus: A small crystal sphere.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, F","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Target, Effect, or Area":"See text","Duration":"Instantaneous or 1 round/level; see text","Saving Throw":"Reflex half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_gaseous_form','Gaseous Form','Air 3, Brd 3, Sor/Wiz 3',3,'Transmutation','Touch','Willing corporeal creature touched',NULL,'2 min./level (D)','S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Air 3, Brd 3, Sor/Wiz 3

Components: S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Willing corporeal creature touched

Duration: 2 min./level (D)

Saving Throw: None

Spell Resistance: No

The subject and all its gear become insubstantial, misty, and translucent. Its material armor (including natural armor) becomes worthless, though its size, Dexterity, deflection bonuses, and armor bonuses from force effects still apply. The subject gains damage reduction 10/magic and becomes immune to poison and critical hits. It can’t attack or cast spells with verbal, somatic, material, or focus components while in gaseous form. (This does not rule out the use of certain spells that the subject may have prepared using the feats Silent Spell, Still Spell, and Eschew Materials.) The subject also loses supernatural abilities while in gaseous form. If it has a touch spell ready to use, that spell is discharged harmlessly when the gaseous form spell takes effect.

A gaseous creature can’t run, but it can fly at a speed of 10 feet (maneuverability perfect). It can pass through small holes or narrow openings, even mere cracks, with all it was wearing or holding in its hands, as long as the spell persists. The creature is subject to the effects of wind, and it can’t enter water or other liquid. It also can’t manipulate objects or activate items, even those carried along with its gaseous form. Continuously active items remain active, though in some cases their effects may be moot.

Arcane Material Component: A bit of gauze and a wisp of smoke.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Air 3, Brd 3, Sor/Wiz 3","Components":"S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Willing corporeal creature touched","Duration":"2 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_gate','Gate','Clr 9, Sor/Wiz 9',9,'Conjuration (Creation or Calling)','Medium (100 ft. + 10 ft./level)','See text',NULL,'Instantaneous or concentration (up to 1 round/level); see text','V, S, XP; see text',ARRAY['cleric','sorcerer','wizard']::text[],'Conjuration (Creation or Calling)

Level: Clr 9, Sor/Wiz 9

Components: V, S, XP; see text

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: See text

Duration: Instantaneous or concentration (up to 1 round/level); see text

Saving Throw: None

Spell Resistance: No

Casting a gate spell has two effects. First, it creates an interdimensional connection between your plane of existence and a plane you specify, allowing travel between those two planes in either direction.

Second, you may then call a particular individual or kind of being through the gate.

The gate itself is a circular hoop or disk from 5 to 20 feet in diameter (caster’s choice), oriented in the direction you desire when it comes into existence (typically vertical and facing you). It is a two-dimensional window looking into the plane you specified when casting the spell, and anyone or anything that moves through is shunted instantly to the other side.

A gate has a front and a back. Creatures moving through the gate from the front are transported to the other plane; creatures moving through it from the back are not.

Planar Travel: As a mode of planar travel, a gate spell functions much like a plane shift spell, except that the gate opens precisely at the point you desire (a creation effect). Deities and other beings who rule a planar realm can prevent a gate from opening in their presence or personal demesnes if they so desire. Travelers need not join hands with you—anyone who chooses to step through the portal is transported. A gate cannot be opened to another point on the same plane; the spell works only for interplanar travel.

You may hold the gate open only for a brief time (no more than 1 round per caster level), and you must concentrate on doing so, or else the interplanar connection is severed.

Calling Creatures: The second effect of the gate spell is to call an extraplanar creature to your aid (a calling effect). By naming a particular being or kind of being as you cast the spell, you cause the gate to open in the immediate vicinity of the desired creature and pull the subject through, willing or unwilling. Deities and unique beings are under no compulsion to come through the gate, although they may choose to do so of their own accord. This use of the spell creates a gate that remains open just long enough to transport the called creatures. This use of the spell has an XP cost (see below).

If you choose to call a kind of creature instead of a known individual you may call either a single creature (of any HD) or several creatures. You can call and control several creatures as long as their HD total does not exceed your caster level. In the case of a single creature, you can control it if its HD do not exceed twice your caster level. A single creature with more HD than twice your caster level can’t be controlled. Deities and unique beings cannot be controlled in any event. An uncontrolled being acts as it pleases, making the calling of such creatures rather dangerous. An uncontrolled being may return to its home plane at any time.

A controlled creature can be commanded to perform a service for you. Such services fall into two categories: immediate tasks and contractual service. Fighting for you in a single battle or taking any other actions that can be accomplished within 1 round per caster level counts as an immediate task; you need not make any agreement or pay any reward for the creature’s help. The creature departs at the end of the spell.

If you choose to exact a longer or more involved form of service from a called creature, you must offer some fair trade in return for that service. The service exacted must be reasonable with respect to the promised favor or reward; see the lesser planar ally spell for appropriate rewards. (Some creatures may want their payment in “livestock” rather than in coin, which could involve complications.) Immediately upon completion of the service, the being is transported to your vicinity, and you must then and there turn over the promised reward. After this is done, the creature is instantly freed to return to its own plane.

Failure to fulfill the promise to the letter results in your being subjected to service by the creature or by its liege and master, at the very least. At worst, the creature or its kin may attack you.

Note: When you use a calling spell such as gate to call an air, chaotic, earth, evil, fire, good, lawful, or water creature, it becomes a spell of that type.

XP Cost: 1,000 XP (only for the calling creatures function).','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 9, Sor/Wiz 9","Components":"V, S, XP; see text","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"See text","Duration":"Instantaneous or concentration (up to 1 round/level); see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_geas_quest','Geas/Quest','Brd 6, Clr 6, Sor/Wiz 6',6,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]',NULL,'One living creature',NULL,NULL,NULL,ARRAY['bard','cleric','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Brd 6, Clr 6, Sor/Wiz 6

Casting Time: 10 minutes

Target: One living creature

Saving Throw: None

This spell functions similarly to lesser geas, except that it affects a creature of any HD and allows no saving throw.

Instead of taking penalties to ability scores (as with lesser geas), the subject takes 3d6 points of damage each day it does not attempt to follow the geas/quest. Additionally, each day it must make a Fortitude saving throw or become sickened. These effects end 24 hours after the creature attempts to resume the geas/ quest.

A remove curse spell ends a geas/quest spell only if its caster level is at least two higher than your caster level. Break enchantment does not end a geas/quest, but limited wish, miracle, and wish do.

Bards, sorcerers, and wizards usually refer to this spell as geas, while clerics call the same spell quest.','{"class_levels":{"bard":6,"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Clr 6, Sor/Wiz 6","Casting Time":"10 minutes","Target":"One living creature","Saving Throw":"None"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_geas_lesser','Geas, Lesser','Brd 3, Sor/Wiz 4',3,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature with 7 HD or less',NULL,'One day/level or until discharged (D)','V',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Brd 3, Sor/Wiz 4

Components: V

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature with 7 HD or less

Duration: One day/level or until discharged (D)

Saving Throw: Will negates

Spell Resistance: Yes

A lesser geas places a magical command on a creature to carry out some service or to refrain from some action or course of activity, as desired by you. The creature must have 7 or fewer Hit Dice and be able to understand you. While a geas cannot compel a creature to kill itself or perform acts that would result in certain death, it can cause almost any other course of activity.

The geased creature must follow the given instructions until the geas is completed, no matter how long it takes.

If the instructions involve some open-ended task that the recipient cannot complete through his own actions the spell remains in effect for a maximum of one day per caster level. A clever recipient can subvert some instructions:

If the subject is prevented from obeying the lesser geas for 24 hours, it takes a –2 penalty to each of its ability scores. Each day, another –2 penalty accumulates, up to a total of –8. No ability score can be reduced to less than 1 by this effect. The ability score penalties are removed 24 hours after the subject resumes obeying the lesser geas.

A lesser geas (and all ability score penalties) can be ended by break enchantment, limited wish, remove curse, miracle, or wish. Dispel magic does not affect a lesser geas.','{"class_levels":{"bard":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Sor/Wiz 4","Components":"V","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature with 7 HD or less","Duration":"One day/level or until discharged (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_gentle_repose','Gentle Repose','Clr 2, Sor/Wiz 3',2,'Necromancy','Touch','Corpse touched',NULL,'One day/level','V, S, M/DF',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 2, Sor/Wiz 3

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Corpse touched

Duration: One day/level

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

You preserve the remains of a dead creature so that they do not decay. Doing so effectively extends the time limit on raising that creature from the dead (see raise dead). Days spent under the influence of this spell don’t count against the time limit. Additionally, this spell makes transporting a fallen comrade more pleasant.

The spell also works on severed body parts and the like.

Arcane Material Component: A pinch of salt, and a copper piece for each eye the corpse has (or had).','{"class_levels":{"cleric":2,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Clr 2, Sor/Wiz 3","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Corpse touched","Duration":"One day/level","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_ghost_sound','Ghost Sound','Brd 0, Sor/Wiz 0',0,'Illusion (Figment)','Close (25 ft. + 5 ft./2 levels)','Illusory sounds',NULL,'1 round/level (D)','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Figment)

Level: Brd 0, Sor/Wiz 0

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Illusory sounds

Duration: 1 round/level (D)

Saving Throw: Will disbelief (if interacted with)

Spell Resistance: No

Ghost sound allows you to create a volume of sound that rises, recedes, approaches, or remains at a fixed place. You choose what type of sound ghost sound creates when casting it and cannot thereafter change the sound’s basic character.

The volume of sound created depends on your level. You can produce as much noise as four normal humans per caster level (maximum twenty humans). Thus, talking, singing, shouting, walking, marching, or running sounds can be created. The noise a ghost sound spell produces can be virtually any type of sound within the volume limit. A horde of rats running and squeaking is about the same volume as eight humans running and shouting. A roaring lion is equal to the noise from sixteen humans, while a roaring dire tiger is equal to the noise from twenty humans.

Ghost sound can enhance the effectiveness of a silent image spell.

Ghost sound can be made permanent with a permanency spell.

Material Component: A bit of wool or a small lump of wax.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Illusory sounds","Duration":"1 round/level (D)","Saving Throw":"Will disbelief (if interacted with)","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_ghoul_touch','Ghoul Touch','Sor/Wiz 2',2,'Necromancy','Touch','Living humanoid touched',NULL,'1d6+2 rounds','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Living humanoid touched

Duration: 1d6+2 rounds

Saving Throw: Fortitude negates

Spell Resistance: Yes

Imbuing you with negative energy, this spell allows you to paralyze a single living humanoid for the duration of the spell with a successful melee touch attack.

Additionally, the paralyzed subject exudes a carrion stench that causes all living creatures (except you) in a 10-foot-radius spread to become sickened (Fortitude negates). A neutralize poison spell removes the effect from a sickened creature, and creatures immune to poison are unaffected by the stench.

Material Component: A small scrap of cloth taken from clothing worn by a ghoul, or a pinch of earth from a ghoul’s lair.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Living humanoid touched","Duration":"1d6+2 rounds","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md'),
('srd35_spell_giant_vermin','Giant Vermin','Clr 4, Drd 4',4,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 min./level','V, S, DF',ARRAY['cleric','druid']::text[],'Transmutation

Level: Clr 4, Drd 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to three vermin, no two of which can be more than 30 ft. apart

Duration: 1 min./level

Saving Throw: None

Spell Resistance: Yes

You turn three normal-sized centipedes, two normal-sized spiders, or a single normal-sized scorpion into larger forms. Only one type of vermin can be transmuted (so a single casting cannot affect both a centipede and a spider), and all must be grown to the same size. The size to which the vermin can be grown depends on your level; see the table below.

Any giant vermin created by this spell do not attempt to harm you, but your control of such creatures is limited to simple commands (“Attack,” “Defend,” “Stop,” and so forth). Orders to attack a certain creature when it appears or guard against a particular occurrence are too complex for the vermin to understand. Unless commanded to do otherwise, the giant vermin attack whoever or whatever is near them.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Caster Level</th><th>Vermin Size</th></tr><tr><td>9th or lower</td><td>Medium</td></tr><tr><td>10th–13th</td><td>Large</td></tr><tr><td>14th–17th</td><td>Huge</td></tr><tr><td>18th–19th</td><td>Gargantuan</td></tr><tr><td>20th or higher</td><td>Colossal</td></tr></tbody></table>','{"class_levels":{"cleric":4,"druid":4},"source_field_values":{"Level":"Clr 4, Drd 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to three vermin, no two of which can be more than 30 ft. apart","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-f-g.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
