-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_command_greater','Command, Greater','Clr 5',5,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]',NULL,NULL,NULL,'1 round/level',NULL,ARRAY['cleric']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Clr 5

Targets: One creature/level, no two of which can be more than 30 ft. apart

Duration: 1 round/level

This spell functions like command, except that up to one creature per level may be affected, and the activities continue beyond 1 round. At the start of each commanded creature’s action after the first, it gets another Will save to attempt to break free from the spell. Each creature must receive the same command.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5","Targets":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"1 round/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_command_plants','Command Plants','Drd 4, Plant 4, Rgr 3',3,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'One day/level','V',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 4, Plant 4, Rgr 3

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to 2 HD/level of plant creatures, no two of which can be more than 30 ft. apart

Duration: One day/level

Saving Throw: Will negates

Spell Resistance: Yes

This spell allows you some degree of control over one or more plant creatures. Affected plant creatures can understand you, and they perceive your words and actions in the most favorable way (treat their attitude as friendly). They will not attack you while the spell lasts. You can try to give a subject orders, but you must win an opposed Charisma check to convince it to do anything it wouldn’t ordinarily do. (Retries are not allowed.) A commanded plant never obeys suicidal or obviously harmful orders, but it might be convinced that something very dangerous is worth doing.

You can affect a number of plant creatures whose combined level or HD do not exceed twice your level.','{"class_levels":{"druid":4,"ranger":3},"source_field_values":{"Level":"Drd 4, Plant 4, Rgr 3","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to 2 HD/level of plant creatures, no two of which can be more than 30 ft. apart","Duration":"One day/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_command_undead','Command Undead','Sor/Wiz 2',2,'Necromancy','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'One day/level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One undead creature

Duration: One day/level

Saving Throw: Will negates; see text

Spell Resistance: Yes

This spell allows you some degree of control over an undead creature. Assuming the subject is intelligent, it perceives your words and actions in the most favorable way (treat its attitude as friendly). It will not attack you while the spell lasts. You can try to give the subject orders, but you must win an opposed Charisma check to convince it to do anything it wouldn’t ordinarily do. (Retries are not allowed.) An intelligent commanded undead never obeys suicidal or obviously harmful orders, but it might be convinced that something very dangerous is worth doing.

A nonintelligent undead creature gets no saving throw against this spell. When you control a mindless being, you can communicate only basic commands, such as “come here,” “go there,” “fight,” “stand still,” and so on. Nonintelligent undead won’t resist suicidal or obviously harmful orders.

Any act by you or your apparent allies that threatens the commanded undead (regardless of its Intelligence) breaks the spell.

Your commands are not telepathic. The undead creature must be able to hear you.

Material Component: A shred of raw meat and a splinter of bone.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One undead creature","Duration":"One day/level","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_commune','Commune','Clr 5',5,'Divination','Personal','You',NULL,'1 round/level','V, S, M, DF, XP',ARRAY['cleric']::text[],'Divination

Level: Clr 5

Components: V, S, M, DF, XP

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: 1 round/level

You contact your deity—or agents thereof —and ask questions that can be answered by a simple yes or no. (A cleric of no particular deity contacts a philosophically allied deity.) You are allowed one such question per caster level. The answers given are correct within the limits of the entity’s knowledge. “Unclear” is a legitimate answer, because powerful beings of the Outer Planes are not necessarily omniscient. In cases where a one-word answer would be misleading or contrary to the deity’s interests, a short phrase (five words or less) may be given as an answer instead.

The spell, at best, provides information to aid character decisions. The entities contacted structure their answers to further their own purposes. If you lag, discuss the answers, or go off to do anything else, the spell ends.

Material Component: Holy (or unholy) water and incense.

XP Cost: 100 XP.','{"class_levels":{"cleric":5},"source_field_values":{"Level":"Clr 5","Components":"V, S, M, DF, XP","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"1 round/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_commune_with_nature','Commune with Nature','Animal 5, Drd 5, Rgr 4',4,'Divination','Personal','You',NULL,'Instantaneous','V, S',ARRAY['druid','ranger']::text[],'Divination

Level: Animal 5, Drd 5, Rgr 4

Components: V, S

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: Instantaneous

You become one with nature, attaining knowledge of the surrounding territory. You instantly gain knowledge of as many as three facts from among the following subjects: the ground or terrain, plants, minerals, bodies of water, people, general animal population, presence of woodland creatures, presence of powerful unnatural creatures, or even the general state of the natural setting.

In outdoor settings, the spell operates in a radius of 1 mile per caster level. In natural underground settings—caves, caverns, and the like—the radius is limited to 100 feet per caster level. The spell does not function where nature has been replaced by construction or settlement, such as in dungeons and towns.','{"class_levels":{"druid":5,"ranger":4},"source_field_values":{"Level":"Animal 5, Drd 5, Rgr 4","Components":"V, S","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_comprehend_languages','Comprehend Languages','Brd 1, Clr 1, Sor/Wiz 1',1,'Divination','Personal','You',NULL,'10 min./level','V, S, M/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Divination

Level: Brd 1, Clr 1, Sor/Wiz 1

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level

You can understand the spoken words of creatures or read otherwise incomprehensible written messages. In either case, you must touch the creature or the writing. The ability to read does not necessarily impart insight into the material, merely its literal meaning. The spell enables you to understand or read an unknown language, not speak or write it.

Written material can be read at the rate of one page (250 words) per minute. Magical writing cannot be read, though the spell reveals that it is magical. This spell can be foiled by certain warding magic (such as the secret page and illusory script spells). It does not decipher codes or reveal messages concealed in otherwise normal text.

Comprehend languages can be made permanent with a permanency spell.

Arcane Material Component: A pinch of soot and a few grains of salt.','{"class_levels":{"bard":1,"cleric":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Clr 1, Sor/Wiz 1","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cone_of_cold','Cone of Cold','Sor/Wiz 5, Water 6',5,'Evocation [Cold]','60 ft.',NULL,'Cone-shaped burst','Instantaneous','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Evocation \[Cold\]

Level: Sor/Wiz 5, Water 6

Components: V, S, M/DF

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

Cone of cold creates an area of extreme cold, originating at your hand and extending outward in a cone. It drains heat, dealing 1d6 points of cold damage per caster level (maximum 15d6).

Arcane Material Component: A very small crystal or glass cone.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5, Water 6","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_confusion','Confusion','Brd 3, Sor/Wiz 4, Trickery 4',3,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 round/level','V, S, M/DF',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 3, Sor/Wiz 4, Trickery 4

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: All creatures in a 15-ft. radius burst

Duration: 1 round/level

Saving Throw: Will negates

Spell Resistance: Yes

This spell causes the targets to become confused, making them unable to independently determine what they will do.

Roll on the following table at the beginning of each subject’s turn each round to see what the subject does in that round.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>d%</th><th>Behavior</th></tr><tr><td>01–10</td><td>Attack caster with melee or ranged weapons (or close with caster if attack is not possible).</td></tr><tr><td>11–20</td><td>Act normally.</td></tr><tr><td>21–50</td><td>Do nothing but babble incoherently.</td></tr><tr><td>51–70</td><td>Flee away from caster at top possible speed.</td></tr><tr><td>71–100</td><td>Attack nearest creature (for this purpose, a familiar counts as part of the subject’s self).</td></tr></tbody></table>

A confused character who can’t carry out the indicated action does nothing but babble incoherently. Attackers are not at any special advantage when attacking a confused character. Any confused character who is attacked automatically attacks its attackers on its next turn, as long as it is still confused when its turn comes. Note that a confused character will not make attacks of opportunity against any creature that it is not already devoted to attacking (either because of its most recent action or because it has just been attacked).

Arcane Material Component: A set of three nut shells.','{"class_levels":{"bard":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Sor/Wiz 4, Trickery 4","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"All creatures in a 15-ft. radius burst","Duration":"1 round/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_confusion_lesser','Confusion, Lesser','Brd 1',1,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'1 round','V, S, DF',ARRAY['bard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 1

Components: V, S, DF

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: 1 round

This spell causes a single creature to become confused for 1 round. See the confusion spell, above, to determine the exact effect on the subject.','{"class_levels":{"bard":1},"source_field_values":{"Level":"Brd 1","Components":"V, S, DF","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"1 round"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_consecrate','Consecrate','Clr 2',2,'Evocation [Good]','Close (25 ft. + 5 ft./2 levels)',NULL,'20-ft.-radius emanation','2 hours/level','V, S, M, DF',ARRAY['cleric']::text[],'Evocation \[Good\]

Level: Clr 2

Components: V, S, M, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 20-ft.-radius emanation

Duration: 2 hours/level

Saving Throw: None

Spell Resistance: No

This spell blesses an area with positive energy. Each Charisma check made to turn undead within this area gains a +3 sacred bonus. Every undead creature entering a consecrated area suffers minor disruption, giving it a –1 penalty on attack rolls, damage rolls, and saves. Undead cannot be created within or summoned into a consecrated area.

If the consecrated area contains an altar, shrine, or other permanent fixture dedicated to your deity, pantheon, or aligned higher power, the modifiers given above are doubled (+6 sacred bonus on turning checks, –2 penalties for undead in the area). You cannot consecrate an area with a similar fixture of a deity other than your own patron.

If the area does contain an altar, shrine, or other permanent fixture of a deity, pantheon, or higher power other than your patron, the consecrate spell instead curses the area, cutting off its connection with the associated deity or power. This secondary function, if used, does not also grant the bonuses and penalties relating to undead, as given above.

Consecrate counters and dispels desecrate.

Material Component: A vial of holy water and 25 gp worth (5 pounds) of silver dust, all of which must be sprinkled around the area.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Components":"V, S, M, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"20-ft.-radius emanation","Duration":"2 hours/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_contact_other_plane','Contact Other Plane','Sor/Wiz 5',5,'Divination','Personal','You',NULL,'Concentration','V',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 5

Components: V

Casting Time: 10 minutes

Range: Personal

Target: You

Duration: Concentration

You send your mind to another plane of existence (an Elemental Plane or some plane farther removed) in order to receive advice and information from powers there. (See the accompanying table for possible consequences and results of the attempt.) The powers reply in a language you understand, but they resent such contact and give only brief answers to your questions. (All questions are answered with “yes,” “no,” “maybe,” “never,” “irrelevant,” or some other one-word answer.)

You must concentrate on maintaining the spell (a standard action) in order to ask questions at the rate of one per round. A question is answered by the power during the same round. For every two caster levels, you may ask one question.

Contact with minds far removed from your home plane increases the probability that you will incur a decrease to Intelligence and Charisma, but the chance of the power knowing the answer, as well as the probability of the entity answering correctly, are likewise increased by moving to distant planes.

Once the Outer Planes are reached, the power of the deity contacted determines the effects. (Random results obtained from the table are subject to the personalities of individual deities.)

On rare occasions, this divination may be blocked by an act of certain deities or forces.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Plane Contacted</th><th>Avoid Int/Cha Decrease</th><th>True Answer</th><th>Don’t Know</th><th>Lie</th><th>Random Answer</th></tr><tr><td>Elemental Plane</td><td>DC 7/1 week</td><td>01–34</td><td>35–62</td><td>63–83</td><td>84–100</td></tr><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;(appropriate)</td><td>(DC 7/1 week)</td><td>(01–68)</td><td>(69–75)</td><td>(76–98)</td><td>(99–100)</td></tr><tr><td>Positive/Negative Energy Plane</td><td>DC 8/1 week</td><td>01–39</td><td>40–65</td><td>66–86</td><td>87–100</td></tr><tr><td>Astral Plane</td><td>DC 9/1 week</td><td>01–44</td><td>45–67</td><td>68–88</td><td>89–100</td></tr><tr><td>Outer Plane, demideity</td><td>DC 10/2 weeks</td><td>01–49</td><td>50–70</td><td>71–91</td><td>92–100</td></tr><tr><td>Outer Plane, lesser deity</td><td>DC 12/3 weeks</td><td>01–60</td><td>61–75</td><td>76–95</td><td>96–100</td></tr><tr><td>Outer Plane, intermediate deity</td><td>DC 14/4 weeks</td><td>01–73</td><td>74–81</td><td>82–98</td><td>99–100</td></tr><tr><td>Outer Plane, greater deity</td><td>DC 16/5 weeks</td><td>01–88</td><td>89–90</td><td>91–99</td><td>100</td></tr></tbody></table>

Avoid Int/Cha Decrease: You must succeed on an Intelligence check against this DC to avoid a decrease in Intelligence and Charisma. If the check fails, your Intelligence and Charisma scores each fall to 8 for the stated duration, and you become unable to cast arcane spells. If you lose Intelligence and Charisma, the effect strikes as soon as the first question is asked, and no answer is received. (The entries in parentheses are for questions that pertain to the appropriate Elemental Plane.)

Results of a Successful Contact: d% is rolled for the result shown on the table:

True Answer: You get a true, one-word answer. Questions that cannot be answered in this way are answered randomly.

Don’t Know: The entity tells you that it doesn’t know.

Lie: The entity intentionally lies to you.

Random Answer: The entity tries to lie but doesn’t know the answer, so it makes one up.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V","Casting Time":"10 minutes","Range":"Personal","Target":"You","Duration":"Concentration","Results of a Successful Contact":"d% is rolled for the result shown on the table:"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_contagion','Contagion','Clr 3, Destruction 3, Drd 3, Sor/Wiz 4',3,'Necromancy [Evil]','Touch','Living creature touched',NULL,'Instantaneous','V, S',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Clr 3, Destruction 3, Drd 3, Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: Instantaneous

Saving Throw: Fortitude negates

Spell Resistance: Yes

The subject contracts a disease selected from the table below, which strikes immediately (no incubation period). The DC noted is for the subsequent saves (use contagion’s normal save DC for the initial saving throw).

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Disease</th><th>DC</th><th>Damage</th></tr><tr><td>Blinding sickness</td><td>16</td><td>1d4 Str<sup>1</sup></td></tr><tr><td>Cackle fever</td><td>16</td><td>1d6 Wis</td></tr><tr><td>Filth fever</td><td>12</td><td>1d3 Dex and 1d3 Con</td></tr><tr><td>Mindfire</td><td>12</td><td>1d4 Int</td></tr><tr><td>Red ache</td><td>15</td><td>1d6 Str</td></tr><tr><td>Shakes</td><td>13</td><td>1d8 Dex</td></tr><tr><td>Slimy doom</td><td>14</td><td>1d4 Con</td></tr><tr><td colspan="3">1 Each time a victim takes 2 or more points of Strength damage from blinding sickness, he or she must make another Fortitude save (using the disease’s save DC) or be permanently blinded.</td></tr></tbody></table>','{"class_levels":{"cleric":3,"druid":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Clr 3, Destruction 3, Drd 3, Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_contingency','Contingency','Sor/Wiz 6',6,'Evocation','Personal','You',NULL,'One day/level (D) or until discharged','V, S, M, F',ARRAY['sorcerer','wizard']::text[],'Evocation

Level: Sor/Wiz 6

Components: V, S, M, F

Casting Time: At least 10 minutes; see text

Range: Personal

Target: You

Duration: One day/level (D) or until discharged

You can place another spell upon your person so that it comes into effect under some condition you dictate when casting contingency. The contingency spell and the companion spell are cast at the same time. The 10-minute casting time is the minimum total for both castings; if the companion spell has a casting time longer than 10 minutes, use that instead.

The spell to be brought into effect by the contingency must be one that affects your person and be of a spell level no higher than one-third your caster level (rounded down, maximum 6th level).

The conditions needed to bring the spell into effect must be clear, although they can be general. In all cases, the contingency immediately brings into effect the companion spell, the latter being “cast” instantaneously when the prescribed circumstances occur. If complicated or convoluted conditions are prescribed, the whole spell combination (contingency and the companion magic) may fail when called on. The companion spell occurs based solely on the stated conditions, regardless of whether you want it to.

You can use only one contingency spell at a time; if a second is cast, the first one (if still active) is dispelled.

Material Component: That of the companion spell, plus quicksilver and an eyelash of an ogre mage, rakshasa, or similar spell-using creature.

Focus: A statuette of you carved from elephant ivory and decorated with gems (worth at least 1,500 gp). You must carry the focus for the contingency to work.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M, F","Casting Time":"At least 10 minutes; see text","Range":"Personal","Target":"You","Duration":"One day/level (D) or until discharged"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_continual_flame','Continual Flame','Clr 3, Sor/Wiz 2',2,'Evocation [Light]','Touch','Object touched',NULL,'Permanent','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Clr 3, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Effect: Magical, heatless flame

Duration: Permanent

Saving Throw: None

Spell Resistance: No

A flame, equivalent in brightness to a torch, springs forth from an object that you touch. The effect looks like a regular flame, but it creates no heat and doesn’t use oxygen. A continual flame can be covered and hidden but not smothered or quenched.

Light spells counter and dispel darkness spells of an equal or lower level.

Material Component: You sprinkle ruby dust (worth 50 gp) on the item that is to carry the flame.','{"class_levels":{"cleric":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Clr 3, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Effect":"Magical, heatless flame","Duration":"Permanent","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_control_plants','Control Plants','Drd 8, Plant 8',8,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 min./level','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Drd 8, Plant 8

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to 2 HD/level of plant creatures, no two of which can be more than 30 ft. apart

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: No

This spell enables you to control the actions of one or more plant creatures for a short period of time. You command the creatures by voice and they understand you, no matter what language you speak. Even if vocal communication is impossible the controlled plants do not attack you. At the end of the spell, the subjects revert to their normal behavior.

Suicidal or self-destructive commands are simply ignored.','{"class_levels":{"druid":8},"source_field_values":{"Level":"Drd 8, Plant 8","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to 2 HD/level of plant creatures, no two of which can be more than 30 ft. apart","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_control_undead','Control Undead','Sor/Wiz 7',7,'Necromancy','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 min./level','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 7

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to 2 HD/level of undead creatures, no two of which can be more than 30 ft. apart

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

This spell enables you to command undead creatures for a short period of time. You command them by voice and they understand you, no matter what language you speak. Even if vocal communication is impossible the controlled undead do not attack you. At the end of the spell, the subjects revert to their normal behavior.

Intelligent undead creatures remember that you controlled them.

Material Component: A small piece of bone and a small piece of raw meat.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to 2 HD/level of undead creatures, no two of which can be more than 30 ft. apart","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_control_water','Control Water','Clr 4, Drd 4, Sor/Wiz 6, Water 4',4,'Transmutation [Water]','Long (400 ft. + 40 ft./level)',NULL,'Water in a volume of 10 ft./level by 10 ft./level by 2 ft./level (S)','10 min./level (D)','V, S, M/DF',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation \[Water\]

Level: Clr 4, Drd 4, Sor/Wiz 6, Water 4

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Water in a volume of 10 ft./level by 10 ft./level by 2 ft./level (S)

Duration: 10 min./level (D)

Saving Throw: None; see text

Spell Resistance: No

Depending on the version you choose, the control water spell raises or lowers water.

Lower Water: This causes water or similar liquid to reduce its depth by as much as 2 feet per caster level (to a minimum depth of 1 inch). The water is lowered within a squarish depression whose sides are up to caster level x 10 feet long. In extremely large and deep bodies of water, such as a deep ocean, the spell creates a whirlpool that sweeps ships and similar craft downward, putting them at risk and rendering them unable to leave by normal movement for the duration of the spell. When cast on water elementals and other water-based creatures, this spell acts as a slow spell (Will negates). The spell has no effect on other creatures.

Raise Water: This causes water or similar liquid to rise in height, just as the lower water version causes it to lower. Boats raised in this way slide down the sides of the hump that the spell creates. If the area affected by the spell includes riverbanks, a beach, or other land nearby, the water can spill over onto dry land.

With either version, you may reduce one horizontal dimension by half and double the other horizontal dimension.

Arcane Material Component: A drop of water (for raise water) or a pinch of dust (for lower water).','{"class_levels":{"cleric":4,"druid":4,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 4, Drd 4, Sor/Wiz 6, Water 4","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Water in a volume of 10 ft./level by 10 ft./level by 2 ft./level (S)","Duration":"10 min./level (D)","Saving Throw":"None; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_control_weather','Control Weather','Air 7, Clr 7, Drd 7, Sor/Wiz 7',7,'Transmutation','2 miles',NULL,'2-mile-radius circle, centered on you; see text','4d12 hours; see text','V, S',ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Air 7, Clr 7, Drd 7, Sor/Wiz 7

Components: V, S

Casting Time: 10 minutes; see text

Range: 2 miles

Area: 2-mile-radius circle, centered on you; see text

Duration: 4d12 hours; see text

Saving Throw: None

Spell Resistance: No

You change the weather in the local area. It takes 10 minutes to cast the spell and an additional 10 minutes for the effects to manifest.You can call forth weather appropriate to the climate and season of the area you are in.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Season</th><th>Possible Weather</th></tr><tr><td>Spring</td><td>Tornado, thunderstorm, sleet storm, or hot weather</td></tr><tr><td>Summer</td><td>Torrential rain, heat wave, or hailstorm</td></tr><tr><td>Autumn</td><td>Hot or cold weather, fog, or sleet</td></tr><tr><td>Winter</td><td>Frigid cold, blizzard, or thaw</td></tr><tr><td>Late winter</td><td>Hurricane-force winds or early spring (coastal area)</td></tr></tbody></table>

You control the general tendencies of the weather, such as the direction and intensity of the wind. You cannot control specific applications of the weather—where lightning strikes, for example, or the exact path of a tornado. When you select a certain weather condition to occur, the weather assumes that condition 10 minutes later (changing gradually, not abruptly). The weather continues as you left it for the duration, or until you use a standard action to designate a new kind of weather (which fully manifests itself 10 minutes later). Contradictory conditions are not possible simultaneously.

Control weather can do away with atmospheric phenomena (naturally occurring or otherwise) as well as create them.

A druid casting this spell doubles the duration and affects a circle with a 3-mile radius.','{"class_levels":{"cleric":7,"druid":7,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Air 7, Clr 7, Drd 7, Sor/Wiz 7","Components":"V, S","Casting Time":"10 minutes; see text","Range":"2 miles","Area":"2-mile-radius circle, centered on you; see text","Duration":"4d12 hours; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_control_winds','Control Winds','Air 5, Drd 5',5,'Transmutation [Air]','40 ft./level',NULL,'40 ft./level radius cylinder 40 ft. high','10 min./level','V, S',ARRAY['druid']::text[],'Transmutation \[Air\]

Level: Air 5, Drd 5

Components: V, S

Casting Time: 1 standard action

Range: 40 ft./level

Area: 40 ft./level radius cylinder 40 ft. high

Duration: 10 min./level

Saving Throw: Fortitude negates

Spell Resistance: No

You alter wind force in the area surrounding you. You can make the wind blow in a certain direction or manner, increase its strength, or decrease its strength. The new wind direction and strength persist until the spell ends or until you choose to alter your handiwork, which requires concentration. You may create an “eye” of calm air up to 80 feet in diameter at the center of the area if you so desire, and you may choose to limit the area to any cylindrical area less than your full limit.

Wind Direction: You may choose one of four basic wind patterns to function over the spell’s area.

- A downdraft blows from the center outward in equal strength in all directions.
- An updraft blows from the outer edges in toward the center in equal strength from all directions, veering upward before impinging on the eye in the center.
- A rotation causes the winds to circle the center in clockwise or counterclockwise fashion.
- A blast simply causes the winds to blow in one direction across the entire area from one side to the other.

Wind Strength: For every three caster levels, you can increase or decrease wind strength by one level. Each round on your turn, a creature in the wind must make a Fortitude save or suffer the effect of being in the windy area.

Strong winds (21+ mph) make sailing difficult.

A severe wind (31+ mph) causes minor ship and building damage.

A windstorm (51+ mph) drives most flying creatures from the skies, uproots small trees, knocks down light wooden structures, tears off roofs, and endangers ships.

Hurricane force winds (75+ mph) destroy wooden buildings, sometimes uproot even large trees, and cause most ships to founder.

A tornado (175+ mph) destroys all nonfortified buildings and often uproots large trees.','{"class_levels":{"druid":5},"source_field_values":{"Level":"Air 5, Drd 5","Components":"V, S","Casting Time":"1 standard action","Range":"40 ft./level","Area":"40 ft./level radius cylinder 40 ft. high","Duration":"10 min./level","Saving Throw":"Fortitude negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_create_food_and_water','Create Food and Water','Clr 3',3,'Conjuration (Creation)','Close (25 ft. + 5 ft./2 levels)','Food and water to sustain three humans or one horse/level for 24 hours',NULL,'24 hours; see text','V, S',ARRAY['cleric']::text[],'Conjuration (Creation)

Level: Clr 3

Components: V, S

Casting Time: 10 minutes

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Food and water to sustain three humans or one horse/level for 24 hours

Duration: 24 hours; see text

Saving Throw: None

Spell Resistance: No

The food that this spell creates is simple fare of your choice—highly nourishing, if rather bland. Food so created decays and becomes inedible within 24 hours, although it can be kept fresh for another 24 hours by casting a purify food and water spell on it. The water created by this spell is just like clean rain water, and it doesn’t go bad as the food does.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Components":"V, S","Casting Time":"10 minutes","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Food and water to sustain three humans or one horse/level for 24 hours","Duration":"24 hours; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_create_greater_undead','Create Greater Undead','Clr 8, Death 8, Sor/Wiz 8',8,'Necromancy [Evil]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Clr 8, Death 8, Sor/Wiz 8

This spell functions like create undead, except that you can create more powerful and intelligent sorts of undead: shadows, wraiths, spectres, and devourers. The type or types of undead you can create is based on your caster level, as shown on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Caster Level</th><th>Undead Created</th></tr><tr><td>15th or lower</td><td>Shadow</td></tr><tr><td>16th–17th</td><td>Wraith</td></tr><tr><td>18th–19th</td><td>Spectre</td></tr><tr><td>20th or higher</td><td>Devourer</td></tr></tbody></table>','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Death 8, Sor/Wiz 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_create_undead','Create Undead','Clr 6, Death 6, Evil 6, Sor/Wiz 6',6,'Necromancy [Evil]','Close (25 ft. + 5 ft./2 levels)','One corpse',NULL,'Instantaneous','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Clr 6, Death 6, Evil 6, Sor/Wiz 6

Components: V, S, M

Casting Time: 1 hour

Range: Close (25 ft. + 5 ft./2 levels)

Target: One corpse

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

A much more potent spell than animate dead, this evil spell allows you to create more powerful sorts of undead: ghouls, ghasts, mummies, and mohrgs. The type or types of undead you can create is based on your caster level, as shown on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Caster Level</th><th>Undead Created</th></tr><tr><td>11th or lower</td><td>Ghoul</td></tr><tr><td>12th–14th</td><td>Ghast</td></tr><tr><td>15th–17th</td><td>Mummy</td></tr><tr><td>18th or higher</td><td>Mohrg</td></tr></tbody></table>

You may create less powerful undead than your level would allow if you choose. Created undead are not automatically under the control of their animator. If you are capable of commanding undead, you may attempt to command the undead creature as it forms.

This spell must be cast at night.

Material Component: A clay pot filled with grave dirt and another filled with brackish water. The spell must be cast on a dead body. You must place a black onyx gem worth at least 50 gp per HD of the undead to be created into the mouth or eye socket of each corpse. The magic of the spell turns these gems into worthless shells.','{"class_levels":{"cleric":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Death 6, Evil 6, Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 hour","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One corpse","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_create_water','Create Water','Clr 0, Drd 0, Pal 1',0,'Conjuration (Creation) [Water]','Close (25 ft. + 5 ft./2 levels)','Up to 2 gallons of water/level',NULL,'Instantaneous','V, S',ARRAY['cleric','druid','paladin']::text[],'Conjuration (Creation) \[Water\]

Level: Clr 0, Drd 0, Pal 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: Up to 2 gallons of water/level

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

This spell generates wholesome, drinkable water, just like clean rain water. Water can be created in an area as small as will actually contain the liquid, or in an area three times as large—possibly creating a downpour or filling many small receptacles.

Note: Conjuration spells can’t create substances or objects within a creature. Water weighs about 8 pounds per gallon. One cubic foot of water contains roughly 8 gallons and weighs about 60 pounds.','{"class_levels":{"cleric":0,"druid":0,"paladin":1},"source_field_values":{"Level":"Clr 0, Drd 0, Pal 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"Up to 2 gallons of water/level","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_creeping_doom','Creeping Doom','Drd 7',7,'Conjuration (Summoning)','Close (25 ft. + 5 ft./2 levels)/ 100 ft.; see text','One swarm of centipedes per two levels',NULL,'1 min./level','V, S',ARRAY['druid']::text[],'Conjuration (Summoning)

Level: Drd 7

Components: V, S

Casting Time: 1 round

Range: Close (25 ft. + 5 ft./2 levels)/ 100 ft.; see text

Effect: One swarm of centipedes per two levels

Duration: 1 min./level

Saving Throw: None

Spell Resistance: No

When you utter the spell of creeping doom, you call forth a mass of centipede swarms (one per two caster levels, to a maximum of ten swarms at 20th level), which need not appear adjacent to one another.

You may summon the centipede swarms so that they share the area of other creatures. The swarms remain stationary, attacking any creatures in their area, unless you command the creeping doom to move (a standard action). As a standard action, you can command any number of the swarms to move toward any prey within 100 feet of you. You cannot command any swarm to move more than 100 feet away from you, and if you move more than 100 feet from any swarm, that swarm remains stationary, attacking any creatures in its area (but it can be commanded again if you move within 100 feet).','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7","Components":"V, S","Casting Time":"1 round","Range":"Close (25 ft. + 5 ft./2 levels)/ 100 ft.; see text","Effect":"One swarm of centipedes per two levels","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_crushing_despair','Crushing Despair','Brd 3, Sor/Wiz 4',3,'Enchantment (Compulsion) [Mind-Affecting]','30 ft.',NULL,'Cone-shaped burst','1 min./level','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 3, Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: 30 ft.

Area: Cone-shaped burst

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

An invisible cone of despair causes great sadness in the subjects. Each affected creature takes a –2 penalty on attack rolls, saving throws, ability checks, skill checks, and weapon damage rolls.

Crushing despair counters and dispels good hope.

Material Component: A vial of tears.','{"class_levels":{"bard":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"30 ft.","Area":"Cone-shaped burst","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_crushing_hand','Crushing Hand','Sor/Wiz 9, Strength 9',9,'Evocation [Force]',NULL,NULL,NULL,NULL,'V, S, M, F/DF',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 9, Strength 9

Components: V, S, M, F/DF

This spell functions like interposing hand, except that the hand can interpose itself, push, or crush one opponent that you select.

The crushing hand can grapple an opponent like grasping hand does. Its grapple bonus equals your caster level + your Intelligence, Wisdom, or Charisma modifier (for a wizard, cleric, or sorcerer, respectively), +12 for the hand’s Strength score (35), +4 for being Large. The hand deals 2d6+12 points of damage (lethal, not nonlethal) on each successful grapple check against an opponent.

The crushing hand can also interpose itself as interposing hand does, or it can bull rush an opponent as forceful hand does, but at a +18 bonus.

Directing the spell to a new target is a move action.

Clerics who cast this spell name it for their deities.

Arcane Material Component: The shell of an egg.

Arcane Focus: A glove of snakeskin.','{"class_levels":{"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Sor/Wiz 9, Strength 9","Components":"V, S, M, F/DF"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_critical_wounds','Cure Critical Wounds','Brd 4, Clr 4, Drd 5, Healing 4',4,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['bard','cleric','druid']::text[],'Conjuration (Healing)

Level: Brd 4, Clr 4, Drd 5, Healing 4

This spell functions like cure light wounds, except that it cures 4d8 points of damage +1 point per caster level (maximum +20).','{"class_levels":{"bard":4,"cleric":4,"druid":5},"source_field_values":{"Level":"Brd 4, Clr 4, Drd 5, Healing 4"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_critical_wounds_mass','Cure Critical Wounds, Mass','Clr 8, Drd 9, Healing 8',8,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','druid']::text[],'Conjuration (Healing)

Level: Clr 8, Drd 9, Healing 8

This spell functions like mass cure light wounds, except that it cures 4d8 points of damage +1 point per caster level (maximum +40).','{"class_levels":{"cleric":8,"druid":9},"source_field_values":{"Level":"Clr 8, Drd 9, Healing 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_cure_light_wounds','Cure Light Wounds','Brd 1, Clr 1, Drd 1, Healing 1, Pal 1, Rgr 2',1,'Conjuration (Healing)','Touch','Creature touched',NULL,'Instantaneous','V, S',ARRAY['bard','cleric','druid','paladin','ranger']::text[],'Conjuration (Healing)

Level: Brd 1, Clr 1, Drd 1, Healing 1, Pal 1, Rgr 2

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Instantaneous

Saving Throw: Will half (harmless); see text

Spell Resistance: Yes (harmless); see text

When laying your hand upon a living creature, you channel positive energy that cures 1d8 points of damage +1 point per caster level (maximum +5).

Since undead are powered by negative energy, this spell deals damage to them instead of curing their wounds. An undead creature can apply spell resistance, and can attempt a Will save to take half damage.','{"class_levels":{"bard":1,"cleric":1,"druid":1,"paladin":1,"ranger":2},"source_field_values":{"Level":"Brd 1, Clr 1, Drd 1, Healing 1, Pal 1, Rgr 2","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Instantaneous","Saving Throw":"Will half (harmless); see text","Spell Resistance":"Yes (harmless); see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_light_wounds_mass','Cure Light Wounds, Mass','Brd 5, Clr 5, Drd 6, Healing 5',5,'Conjuration (Healing)','Close (25 ft. + 5 ft./2 levels)','One creature/level, no two of which can be more than 30 ft. apart',NULL,'Instantaneous','V, S',ARRAY['bard','cleric','druid']::text[],'Conjuration (Healing)

Level: Brd 5, Clr 5, Drd 6, Healing 5

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature/level, no two of which can be more than 30 ft. apart

Duration: Instantaneous

Saving Throw: Will half (harmless) or Will half; see text

Spell Resistance: Yes (harmless) or Yes; see text

You channel positive energy to cure 1d8 points of damage +1 point per caster level (maximum +25) in each selected creature.

Like other cure spells, mass cure light wounds deals damage to undead in its area rather than curing them. Each affected undead may attempt a Will save for half damage.','{"class_levels":{"bard":5,"cleric":5,"druid":6},"source_field_values":{"Level":"Brd 5, Clr 5, Drd 6, Healing 5","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"Instantaneous","Saving Throw":"Will half (harmless) or Will half; see text","Spell Resistance":"Yes (harmless) or Yes; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_cure_minor_wounds','Cure Minor Wounds','Clr 0, Drd 0',0,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','druid']::text[],'Conjuration (Healing)

Level: Clr 0, Drd 0

This spell functions like cure light wounds, except that it cures only 1 point of damage.','{"class_levels":{"cleric":0,"druid":0},"source_field_values":{"Level":"Clr 0, Drd 0"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_moderate_wounds','Cure Moderate Wounds','Brd 2, Clr 2, Drd 3, Healing 2, Pal 3, Rgr 3',2,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['bard','cleric','druid','paladin','ranger']::text[],'Conjuration (Healing)

Level: Brd 2, Clr 2, Drd 3, Healing 2, Pal 3, Rgr 3

This spell functions like cure light wounds, except that it cures 2d8 points of damage +1 point per caster level (maximum +10).','{"class_levels":{"bard":2,"cleric":2,"druid":3,"paladin":3,"ranger":3},"source_field_values":{"Level":"Brd 2, Clr 2, Drd 3, Healing 2, Pal 3, Rgr 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_moderate_wounds_mass','Cure Moderate Wounds, Mass','Brd 6, Clr 6, Drd 7',6,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['bard','cleric','druid']::text[],'Conjuration (Healing)

Level: Brd 6, Clr 6, Drd 7

This spell functions like mass cure light wounds, except that it cures 2d8 points of damage +1 point per caster level (maximum +30).','{"class_levels":{"bard":6,"cleric":6,"druid":7},"source_field_values":{"Level":"Brd 6, Clr 6, Drd 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_serious_wounds','Cure Serious Wounds','Brd 3, Clr 3, Drd 4, Pal 4, Rgr 4, Healing 3',3,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['bard','cleric','druid','paladin','ranger']::text[],'Conjuration (Healing)

Level: Brd 3, Clr 3, Drd 4, Pal 4, Rgr 4, Healing 3

This spell functions like cure light wounds, except that it cures 3d8 points of damage +1 point per caster level (maximum +15).','{"class_levels":{"bard":3,"cleric":3,"druid":4,"paladin":4,"ranger":4},"source_field_values":{"Level":"Brd 3, Clr 3, Drd 4, Pal 4, Rgr 4, Healing 3"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cure_serious_wounds_mass','Cure Serious Wounds, Mass','Clr 7, Drd 8',7,'Conjuration (Healing)',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','druid']::text[],'Conjuration (Healing)

Level: Clr 7, Drd 8

This spell functions like mass cure light wounds, except that it cures 3d8 points of damage +1 point per caster level (maximum +35).','{"class_levels":{"cleric":7,"druid":8},"source_field_values":{"Level":"Clr 7, Drd 8"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_curse_water','Curse Water','Clr 1',1,'Necromancy [Evil]','Touch','Flask of water touched',NULL,'Instantaneous','V, S, M',ARRAY['cleric']::text[],'Necromancy \[Evil\]

Level: Clr 1

Components: V, S, M

Casting Time: 1 minute

Range: Touch

Target: Flask of water touched

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This spell imbues a flask (1 pint) of water with negative energy, turning it into unholy water. Unholy water damages good outsiders the way holy water damages undead and evil outsiders.

Material Component: 5 pounds of powdered silver (worth 25 gp).','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, M","Casting Time":"1 minute","Range":"Touch","Target":"Flask of water touched","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_dancing_lights','Dancing Lights','Brd 0, Sor/Wiz 0',0,'Evocation [Light]','Medium (100 ft. + 10 ft./level)','Up to four lights, all within a 10- ft.-radius area',NULL,'1 minute (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Brd 0, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Up to four lights, all within a 10- ft.-radius area

Duration: 1 minute (D)

Saving Throw: None

Spell Resistance: No

Depending on the version selected, you create up to four lights that resemble lanterns or torches (and cast that amount of light), or up to four glowing spheres of light (which look like will-o’-wisps), or one faintly glowing, vaguely humanoid shape. The dancing lights must stay within a 10-foot-radius area in relation to each other but otherwise move as you desire (no concentration required): forward or back, up or down, straight or turning corners, or the like. The lights can move up to 100 feet per round. A light winks out if the distance between you and it exceeds the spell’s range.

Dancing lights can be made permanent with a permanency spell.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Up to four lights, all within a 10- ft.-radius area","Duration":"1 minute (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_darkness','Darkness','Brd 2, Clr 2, Sor/Wiz 2',2,'Evocation [Darkness]','Touch','Object touched',NULL,'10 min./level (D)','V, M/DF',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Evocation \[Darkness\]

Level: Brd 2, Clr 2, Sor/Wiz 2

Components: V, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

This spell causes an object to radiate shadowy illumination out to a 20-foot radius. All creatures in the area gain concealment (20% miss chance). Even creatures that can normally see in such conditions (such as with darkvision or low-light vision) have the miss chance in an area shrouded in magical darkness.

Normal lights (torches, candles, lanterns, and so forth) are incapable of brightening the area, as are light spells of lower level. Higher level light spells are not affected by darkness.

If darkness is cast on a small object that is then placed inside or under a lightproof covering, the spell’s effect is blocked until the covering is removed.

Darkness counters or dispels any light spell of equal or lower spell level.

Arcane Material Component: A bit of bat fur and either a drop of pitch or a piece of coal.','{"class_levels":{"bard":2,"cleric":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Clr 2, Sor/Wiz 2","Components":"V, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_darkvision','Darkvision','Rgr 3, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 hour/level','V, S, M',ARRAY['ranger','sorcerer','wizard']::text[],'Transmutation

Level: Rgr 3, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 hour/level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject gains the ability to see 60 feet even in total darkness. Darkvision is black and white only but otherwise like normal sight. Darkvision does not grant one the ability to see in magical darkness.

Darkvision can be made permanent with a permanency spell.

Material Component: Either a pinch of dried carrot or an agate.','{"class_levels":{"ranger":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Rgr 3, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 hour/level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_daylight','Daylight','Brd 3, Clr 3, Drd 3, Pal 3, Sor/Wiz 3',3,'Evocation [Light]','Touch','Object touched',NULL,'10 min./level (D)','V, S',ARRAY['bard','cleric','druid','paladin','sorcerer','wizard']::text[],'Evocation \[Light\]

Level: Brd 3, Clr 3, Drd 3, Pal 3, Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Object touched

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: No

The object touched sheds light as bright as full daylight in a 60-foot radius, and dim light for an additional 60 feet beyond that. Creatures that take penalties in bright light also take them while within the radius of this magical light. Despite its name, this spell is not the equivalent of daylight for the purposes of creatures that are damaged or destroyed by bright light.

If daylight is cast on a small object that is then placed inside or under a light- proof covering, the spell’s effects are blocked until the covering is removed.

Daylight brought into an area of magical darkness (or vice versa) is temporarily negated, so that the otherwise prevailing light conditions exist in the overlapping areas of effect.

Daylight counters or dispels any darkness spell of equal or lower level, such as darkness.','{"class_levels":{"bard":3,"cleric":3,"druid":3,"paladin":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Clr 3, Drd 3, Pal 3, Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Object touched","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_daze','Daze','Brd 0, Sor/Wiz 0',0,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One humanoid creature of 4 HD or less',NULL,'1 round','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 0, Sor/Wiz 0

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One humanoid creature of 4 HD or less

Duration: 1 round

Saving Throw: Will negates

Spell Resistance: Yes

This enchantment clouds the mind of a humanoid creature with 4 or fewer Hit Dice so that it takes no actions. Humanoids of 5 or more HD are not affected. A dazed subject is not stunned, so attackers get no special advantage against it.

Material Component: A pinch of wool or similar substance.','{"class_levels":{"bard":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Sor/Wiz 0","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One humanoid creature of 4 HD or less","Duration":"1 round","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_daze_monster','Daze Monster','Brd 2, Sor/Wiz 2',2,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)','One living creature of 6 HD or less',NULL,NULL,NULL,ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Sor/Wiz 2

Range: Medium (100 ft. + 10 ft./level)

Target: One living creature of 6 HD or less

This spell functions like daze, but daze monster can affect any one living creature of any type. Creatures of 7 or more HD are not affected.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Range":"Medium (100 ft. + 10 ft./level)","Target":"One living creature of 6 HD or less"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_death_knell','Death Knell','Clr 2, Death 2',2,'Necromancy [Death, Evil]','Touch','Living creature touched',NULL,'Instantaneous/10 minutes per HD of subject; see text','V, S',ARRAY['cleric']::text[],'Necromancy \[Death, Evil\]

Level: Clr 2, Death 2

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: Instantaneous/10 minutes per HD of subject; see text

Saving Throw: Will negates

Spell Resistance: Yes

You draw forth the ebbing life force of a creature and use it to fuel your own power. Upon casting this spell, you touch a living creature that has –1 or fewer hit points. If the subject fails its saving throw, it dies, and you gain 1d8 temporary hit points and a +2 bonus to Strength. Additionally, your effective caster level goes up by +1, improving spell effects dependent on caster level. (This increase in effective caster level does not grant you access to more spells.) These effects last for 10 minutes per HD of the subject creature.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2, Death 2","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous/10 minutes per HD of subject; see text","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_death_ward','Death Ward','Clr 4, Death 4, Drd 5, Pal 4',4,'Necromancy','Touch','Living creature touched',NULL,'1 min./level','V, S, DF',ARRAY['cleric','druid','paladin']::text[],'Necromancy

Level: Clr 4, Death 4, Drd 5, Pal 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject is immune to all death spells, magical death effects, energy drain, and any negative energy effects.

This spell doesn’t remove negative levels that the subject has already gained, nor does it affect the saving throw necessary 24 hours after gaining a negative level.

Death ward does not protect against other sorts of attacks even if those attacks might be lethal.','{"class_levels":{"cleric":4,"druid":5,"paladin":4},"source_field_values":{"Level":"Clr 4, Death 4, Drd 5, Pal 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_deathwatch','Deathwatch','Clr 1',1,'Necromancy [Evil]','30 ft.',NULL,'Cone-shaped emanation','10 min./level','V, S',ARRAY['cleric']::text[],'Necromancy \[Evil\]

Level: Clr 1

Components: V, S

Casting Time: 1 standard action

Range: 30 ft.

Area: Cone-shaped emanation

Duration: 10 min./level

Saving Throw: None

Spell Resistance: No

Using the foul sight granted by the powers of unlife, you can determine the condition of creatures near death within the spell’s range. You instantly know whether each creature within the area is dead, fragile (alive and wounded, with 3 or fewer hit points left), fighting off death (alive with 4 or more hit points), undead, or neither alive nor dead (such as a construct).

Deathwatch sees through any spell or ability that allows creatures to feign death.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S","Casting Time":"1 standard action","Range":"30 ft.","Area":"Cone-shaped emanation","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_deep_slumber','Deep Slumber','Brd 3, Sor/Wiz 3',3,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,NULL,NULL,ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 3, Sor/Wiz 3

Range: Close (25 ft. + 5 ft./2 levels)

This spell functions like sleep, except that it affects 10 HD of creatures.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Range":"Close (25 ft. + 5 ft./2 levels)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_deeper_darkness','Deeper Darkness','Clr 3',3,'Evocation [Darkness]',NULL,NULL,NULL,'One day/level (D)',NULL,ARRAY['cleric']::text[],'Evocation \[Darkness\]

Level: Clr 3

Duration: One day/level (D)

This spell functions like darkness, except that the object radiates shadowy illumination in a 60-foot radius and the darkness lasts longer.

Daylight brought into an area of deeper darkness (or vice versa) is temporarily negated, so that the otherwise prevailing light conditions exist in the overlapping areas of effect.

Deeper darkness counters and dispels any light spell of equal or lower level, including daylight and light.','{"class_levels":{"cleric":3},"source_field_values":{"Level":"Clr 3","Duration":"One day/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_delay_poison','Delay Poison','Brd 2, Clr 2, Drd 2, Pal 2, Rgr 1',1,'Conjuration (Healing)','Touch','Creature touched',NULL,'1 hour/level','V, S, DF',ARRAY['bard','cleric','druid','paladin','ranger']::text[],'Conjuration (Healing)

Level: Brd 2, Clr 2, Drd 2, Pal 2, Rgr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 hour/level

Saving Throw: Fortitude negates (harmless)

Spell Resistance: Yes (harmless)

The subject becomes temporarily immune to poison. Any poison in its system or any poison to which it is exposed during the spell’s duration does not affect the subject until the spell’s duration has expired. Delay poison does not cure any damage that poison may have already done.','{"class_levels":{"bard":2,"cleric":2,"druid":2,"paladin":2,"ranger":1},"source_field_values":{"Level":"Brd 2, Clr 2, Drd 2, Pal 2, Rgr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 hour/level","Saving Throw":"Fortitude negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_delayed_blast_fireball','Delayed Blast Fireball','Sor/Wiz 7',7,'Evocation [Fire]',NULL,NULL,NULL,'5 rounds or less; see text',NULL,ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Sor/Wiz 7

Duration: 5 rounds or less; see text

This spell functions like fireball, except that it is more powerful and can detonate up to 5 rounds after the spell is cast. The burst of flame deals 1d6 points of fire damage per caster level (maximum 20d6).

The glowing bead created by delayed blast fireball can detonate immediately if you desire, or you can choose to delay the burst for as many as 5 rounds. You select the amount of delay upon completing the spell, and that time cannot change once it has been set unless someone touches the bead (see below). If you choose a delay, the glowing bead sits at its destination until it detonates. A creature can pick up and hurl the bead as a thrown weapon (range increment 10 feet). If a creature handles and moves the bead within 1 round of its detonation, there is a 25% chance that the bead detonates while being handled.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7","Duration":"5 rounds or less; see text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_demand','Demand','Sor/Wiz 8',8,'Enchantment (Compulsion) [Mind-Affecting]',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 8

Saving Throw: Will partial

Spell Resistance: Yes

This spell functions like sending, but the message can also contain a suggestion (see the suggestion spell), which the subject does its best to carry out. A successful Will save negates the suggestion effect but not the contact itself. The demand, if received, is understood even if the subject’s Intelligence score is as low as 1. If the message is impossible or meaningless according to the circumstances that exist for the subject at the time the demand is issued, the message is understood but the suggestion is ineffective.

The demand’s message to the creature must be twenty-five words or less, including the suggestion. The creature can also give a short reply immediately.

Material Component: A short piece of copper wire and some small part of the subject—a hair, a bit of nail, or the like.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Saving Throw":"Will partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_desecrate','Desecrate','Clr 2, Evil 2',2,'Evocation [Evil]','Close (25 ft. + 5 ft./2 levels)',NULL,'20-ft.-radius emanation','2 hours/level','V, S, M, DF',ARRAY['cleric']::text[],'Evocation \[Evil\]

Level: Clr 2, Evil 2

Components: V, S, M, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 20-ft.-radius emanation

Duration: 2 hours/level

Saving Throw: None

Spell Resistance: Yes

This spell imbues an area with negative energy. Each Charisma check made to turn undead within this area takes a –3 profane penalty, and every undead creature entering a desecrated area gains a +1 profane bonus on attack rolls, damage rolls, and saving throws. An undead creature created within or summoned into such an area gains +1 hit points per HD.

If the desecrated area contains an altar, shrine, or other permanent fixture dedicated to your deity or aligned higher power, the modifiers given above are doubled (–6 profane penalty on turning checks, +2 profane bonus and +2 hit points per HD for undead in the area).

Furthermore, anyone who casts animate dead within this area may create as many as double the normal amount of undead (that is, 4 HD per caster level rather than 2 HD per caster level).

If the area contains an altar, shrine, or other permanent fixture of a deity, pantheon, or higher power other than your patron, the desecrate spell instead curses the area, cutting off its connection with the associated deity or power. This secondary function, if used, does not also grant the bonuses and penalties relating to undead, as given above.

Desecrate counters and dispels consecrate.

Material Component: A vial of unholy water and 25 gp worth (5 pounds) of silver dust, all of which must be sprinkled around the area.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2, Evil 2","Components":"V, S, M, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"20-ft.-radius emanation","Duration":"2 hours/level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_destruction','Destruction','Clr 7, Death 7',7,'Necromancy [Death]','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'Instantaneous','V, S, F',ARRAY['cleric']::text[],'Necromancy \[Death\]

Level: Clr 7, Death 7

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: Instantaneous

Saving Throw: Fortitude partial

Spell Resistance: Yes

This spell instantly slays the subject and consumes its remains (but not its equipment and possessions) utterly. If the target’s Fortitude saving throw succeeds, it instead takes 10d6 points of damage. The only way to restore life to a character who has failed to save against this spell is to use true resurrection, a carefully worded wish spell followed by resurrection, or miracle.

Focus: A special holy (or unholy) symbol of silver marked with verses of anathema (cost 500 gp).','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7, Death 7","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"Instantaneous","Saving Throw":"Fortitude partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_animals_or_plants','Detect Animals or Plants','Drd 1, Rgr 1',1,'Divination','Long (400 ft. + 40 ft./level)',NULL,'Cone-shaped emanation','Concentration, up to 10 min./level (D)','V, S',ARRAY['druid','ranger']::text[],'Divination

Level: Drd 1, Rgr 1

Components: V, S

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Area: Cone-shaped emanation

Duration: Concentration, up to 10 min./level (D)

Saving Throw: None

Spell Resistance: No

You can detect a particular kind of animal or plant in a cone emanating out from you in whatever direction you face. You must think of a kind of animal or plant when using the spell, but you can change the animal or plant kind each round. The amount of information revealed depends on how long you search a particular area or focus on a specific kind of animal or plant.

1st Round: Presence or absence of that kind of animal or plant in the area.

2nd Round: Number of individuals of the specified kind in the area, and the condition of the healthiest specimen.

3rd Round: The condition (see below) and location of each individual present. If an animal or plant is outside your line of sight, then you discern its direction but not its exact location.

Conditions: For purposes of this spell, the categories of condition are as follows:

Normal: Has at least 90% of full normal hit points, free of disease.

Fair: 30% to 90% of full normal hit points remaining.

Poor: Less than 30% of full normal hit points remaining, afflicted with a disease, or suffering from a debilitating injury.

Weak: 0 or fewer hit points remaining, afflicted with a disease in the terminal stage, or crippled.

If a creature falls into more than one category, the spell indicates the weaker of the two.

Each round you can turn to detect a kind of animal or plant in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"V, S","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Area":"Cone-shaped emanation","Duration":"Concentration, up to 10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_chaos','Detect Chaos','Clr 1',1,'Divination',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Divination

Level: Clr 1

This spell functions like detect evil, except that it detects the auras of chaotic creatures, clerics of chaotic deities, chaotic spells, and chaotic magic items, and you are vulnerable to an overwhelming chaotic aura if you are lawful.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_evil','Detect Evil','Clr 1',1,'Divination','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 10 min./ level (D)','V, S, DF',ARRAY['cleric']::text[],'Divination

Level: Clr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 10 min./ level (D)

Saving Throw: None

Spell Resistance: No

You can sense the presence of evil. The amount of information revealed depends on how long you study a particular area or subject.

1st Round: Presence or absence of evil.

2nd Round: Number of evil auras (creatures, objects, or spells) in the area and the power of the most potent evil aura present.

If you are of good alignment, and the strongest evil aura’s power is overwhelming (see below), and the HD or level of the aura’s source is at least twice your character level, you are stunned for 1 round and the spell ends.

3rd Round: The power and location of each aura. If an aura is outside your line of sight, then you discern its direction but not its exact location.

Aura Power: An evil aura’s power depends on the type of evil creature or object that you’re detecting and its HD, caster level, or (in the case of a cleric) class level; see the accompanying table. If an aura falls into more than one strength category, the spell indicates the stronger of the two.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><td></td><th colspan="4" class="middle-line">Aura Power</th></tr><tr><th>Creature/Object</th><th>Faint</th><th>Moderate</th><th>Strong</th><th>Overwhelming</th></tr><tr><td>Evil creature<sup>1</sup>(HD)</td><td>10 or lower</td><td>11–25</td><td>26–50</td><td>51 or higher</td></tr><tr><td>Undead (HD)</td><td>2 or lower</td><td>3–8</td><td>9–20</td><td>21 or higher</td></tr><tr><td>Evil outsider (HD)</td><td>1 or lower</td><td>2–4</td><td>5–10</td><td>11 or higher</td></tr><tr><td>Cleric of an evil deity <sup>2</sup>(class levels)</td><td>1</td><td>2–4</td><td>5–10</td><td>11 or higher</td></tr><tr><td>Evil magic item or spell (caster level)</td><td>2nd or lower</td><td>3rd–8th</td><td>9th–20th</td><td>21st or higher</td></tr><tr><td colspan="5">1 Except for undead and outsiders, which have their own entries on the table.</td></tr><tr><td colspan="5">2 Some characters who are not clerics may radiate an aura of equivalent power. The class description will indicate whether this applies.</td></tr></tbody></table>

Lingering Aura: An evil aura lingers after its original source dissipates (in the case of a spell) or is destroyed (in the case of a creature or magic item). If detect evil is cast and directed at such a location, the spell indicates an aura strength of dim (even weaker than a faint aura). How long the aura lingers at this dim level depends on its original power:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Original Strength</th><th>Duration of Lingering Aura</th></tr><tr><td>Faint</td><td>1d6 rounds</td></tr><tr><td>Moderate</td><td>1d6 minutes</td></tr><tr><td>Strong</td><td>1d6x10 minutes</td></tr><tr><td>Overwhelming</td><td>1d6 days</td></tr></tbody></table>

Animals, traps, poisons, and other potential perils are not evil, and as such this spell does not detect them.

Each round, you can turn to detect evil in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 10 min./ level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_good','Detect Good','Clr 1',1,'Divination',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Divination

Level: Clr 1

This spell functions like detect evil, except that it detects the auras of good creatures, clerics or paladins of good deities, good spells, and good magic items, and you are vulnerable to an overwhelming good aura if you are evil. Healing potions, antidotes, and similar beneficial items are not good.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_law','Detect Law','Clr 1',1,'Divination',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric']::text[],'Divination

Level: Clr 1

This spell functions like detect evil, except that it detects the auras of lawful creatures, clerics of lawful deities, lawful spells, and lawful magic items, and you are vulnerable to an overwhelming lawful aura if you are chaotic.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_detect_magic','Detect Magic','Brd 0, Clr 0, Drd 0, Sor/Wiz 0',0,'Divination','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 1 min./level (D)','V, S',ARRAY['bard','cleric','druid','sorcerer','wizard']::text[],'Divination

Level: Brd 0, Clr 0, Drd 0, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 1 min./level (D)

Saving Throw: None

Spell Resistance: No

You detect magical auras. The amount of information revealed depends on how long you study a particular area or subject.

1st Round: Presence or absence of magical auras.

2nd Round: Number of different magical auras and the power of the most potent aura.

3rd Round: The strength and location of each aura. If the items or creatures bearing the auras are in line of sight, you can make Spellcraft skill checks to determine the school of magic involved in each. (Make one check per aura; DC 15 + spell level, or 15 + half caster level for a nonspell effect.)

Magical areas, multiple types of magic, or strong local magical emanations may distort or conceal weaker auras.

Aura Strength: An aura’s power depends on a spell’s functioning spell level or an item’s caster level. If an aura falls into more than one category, detect magic indicates the stronger of the two.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><td></td><th colspan="4" class="middle-line">Aura Power</th></tr><tr><th>Spell or Object</th><th>Faint</th><th>Moderate</th><th>Strong</th><th>Overwhelming</th></tr><tr><td>Functioning spell (spell level)</td><td>3rd or lower</td><td>4th–6th</td><td>7th–9th</td><td>10th+ (deity-level)</td></tr><tr><td>Magic item (caster level)</td><td>5th or lower</td><td>6th–11th</td><td>12th–20th</td><td>21st+ (artifact)</td></tr></tbody></table>

Lingering Aura: A magical aura lingers after its original source dissipates (in the case of a spell) or is destroyed (in the case of a magic item). If detect magic is cast and directed at such a location, the spell indicates an aura strength of dim (even weaker than a faint aura). How long the aura lingers at this dim level depends on its original power:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Original Strength</th><th>Duration of Lingering Aura</th></tr><tr><td>Faint</td><td>1d6 rounds</td></tr><tr><td>Moderate</td><td>1d6 minutes</td></tr><tr><td>Strong</td><td>1d6x10 minutes</td></tr><tr><td>Overwhelming</td><td>1d6 days</td></tr></tbody></table>

Outsiders and elementals are not magical in themselves, but if they are summoned, the conjuration spell registers.

Each round, you can turn to detect magic in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.

Detect magic can be made permanent with a permanency spell.','{"class_levels":{"bard":0,"cleric":0,"druid":0,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Brd 0, Clr 0, Drd 0, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_poison','Detect Poison','Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0',0,'Divination','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Instantaneous','V, S',ARRAY['cleric','druid','paladin','ranger','sorcerer','wizard']::text[],'Divination

Level: Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target or Area: One creature, one object, or a 5-ft. cube

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

You determine whether a creature, object, or area has been poisoned or is poisonous. You can determine the exact type of poison with a DC 20 Wisdom check. A character with the Craft (alchemy) skill may try a DC 20 Craft (alchemy) check if the Wisdom check fails, or may try the Craft (alchemy) check prior to the Wisdom check.

The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.','{"class_levels":{"cleric":0,"druid":0,"paladin":1,"ranger":1,"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Clr 0, Drd 0, Pal 1, Rgr 1, Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target or Area":"One creature, one object, or a 5-ft. cube","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_scrying','Detect Scrying','Brd 4, Sor/Wiz 4',4,'Divination','40 ft.',NULL,'40-ft.-radius emanation centered on you','24 hours','V, S, M',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 4, Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: 40 ft.

Area: 40-ft.-radius emanation centered on you

Duration: 24 hours

Saving Throw: None

Spell Resistance: No

You immediately become aware of any attempt to observe you by means of a divination (scrying) spell or effect. The spell’s area radiates from you and moves as you move. You know the location of every magical sensor within the spell’s area.

If the scrying attempt originates within the area, you also know its location; otherwise, you and the scrier immediately make opposed caster level checks (1d20 + caster level). If you at least match the scrier’s result, you get a visual image of the scrier and an accurate sense of his or her direction and distance from you.

Material Component: A small piece of mirror and a miniature brass hearing trumpet.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"40 ft.","Area":"40-ft.-radius emanation centered on you","Duration":"24 hours","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_secret_doors','Detect Secret Doors','Brd 1, Knowledge 1, Sor/Wiz 1',1,'Divination','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 1 min./level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 1, Knowledge 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 1 min./level (D)

Saving Throw: None

Spell Resistance: No

You can detect secret doors, compartments, caches, and so forth. Only passages, doors, or openings that have been specifically constructed to escape detection are detected by this spell. The amount of information revealed depends on how long you study a particular area or subject.

1st Round: Presence or absence of secret doors.

2nd Round: Number of secret doors and the location of each. If an aura is outside your line of sight, then you discern its direction but not its exact location.

Each Additional Round: The mechanism or trigger for one particular secret portal closely examined by you. Each round, you can turn to detect secret doors in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Knowledge 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_snares_and_pits','Detect Snares and Pits','Drd 1, Rgr 1',1,'Divination','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 10 min./level (D)','V, S',ARRAY['druid','ranger']::text[],'Divination

Level: Drd 1, Rgr 1

Components: V, S

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 10 min./level (D)

Saving Throw: None

Spell Resistance: No

You can detect simple pits, deadfalls, and snares as well as mechanical traps constructed of natural materials. The spell does not detect complex traps, including trapdoor traps.

Detect snares and pits does detect certain natural hazards—quicksand (a snare), a sinkhole (a pit), or unsafe walls of natural rock (a deadfall). However, it does not reveal other potentially dangerous conditions. The spell does not detect magic traps (except those that operate by pit, deadfall, or snaring; see the spell snare), nor mechanically complex ones, nor those that have been rendered safe or inactive.

The amount of information revealed depends on how long you study a particular area.

1st Round: Presence or absence of hazards.

2nd Round: Number of hazards and the location of each. If a hazard is outside your line of sight, then you discern its direction but not its exact location.

Each Additional Round: The general type and trigger for one particular hazard closely examined by you.

Each round, you can turn to detect snares and pits in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Components":"V, S","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 10 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_thoughts','Detect Thoughts','Brd 2, Knowledge 2, Sor/Wiz 2',2,'Divination [Mind-Affecting]','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 1 min./level (D)','V, S, F/DF',ARRAY['bard','sorcerer','wizard']::text[],'Divination \[Mind-Affecting\]

Level: Brd 2, Knowledge 2, Sor/Wiz 2

Components: V, S, F/DF

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 1 min./level (D)

Saving Throw: Will negates; see text

Spell Resistance: No

You detect surface thoughts. The amount of information revealed depends on how long you study a particular area or subject.

1st Round: Presence or absence of thoughts (from conscious creatures with Intelligence scores of 1 or higher).

2nd Round: Number of thinking minds and the Intelligence score of each. If the highest Intelligence is 26 or higher (and at least 10 points higher than your own Intelligence score), you are stunned for 1 round and the spell ends. This spell does not let you determine the location of the thinking minds if you can’t see the creatures whose thoughts you are detecting.

3rd Round: Surface thoughts of any mind in the area. A target’s Will save prevents you from reading its thoughts, and you must cast detect thoughts again to have another chance. Creatures of animal intelligence (Int 1 or 2) have simple, instinctual thoughts that you can pick up.

Each round, you can turn to detect thoughts in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.

Arcane Focus: A copper piece.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Knowledge 2, Sor/Wiz 2","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 1 min./level (D)","Saving Throw":"Will negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_detect_undead','Detect Undead','Clr 1, Pal 1, Sor/Wiz 1',1,'Divination','60 ft.',NULL,'Cone-shaped emanation','Concentration, up to 1 minute/ level (D)','V, S, M/DF',ARRAY['cleric','paladin','sorcerer','wizard']::text[],'Divination

Level: Clr 1, Pal 1, Sor/Wiz 1

Components: V, S, M/DF

Casting Time: 1 standard action

Range: 60 ft.

Area: Cone-shaped emanation

Duration: Concentration, up to 1 minute/ level (D)

Saving Throw: None

Spell Resistance: No

You can detect the aura that surrounds undead creatures. The amount of information revealed depends on how long you study a particular area.

1st Round: Presence or absence of undead auras.

2nd Round: Number of undead auras in the area and the strength of the strongest undead aura present. If you are of good alignment, and the strongest undead aura’s strength is overwhelming (see below), and the creature has HD of at least twice your character level, you are stunned for 1 round and the spell ends.

3rd Round: The strength and location of each undead aura. If an aura is outside your line of sight, then you discern its direction but not its exact location.

Aura Strength: The strength of an undead aura is determined by the HD of the undead creature, as given on the following table:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Strength</th></tr><tr><td>1 or lower</td><td>Faint</td></tr><tr><td>2–4</td><td>Moderate</td></tr><tr><td>5–10</td><td>Strong</td></tr><tr><td>11 or higher</td><td>Overwhelming</td></tr></tbody></table>

Lingering Aura: An undead aura lingers after its original source is destroyed. If detect undead is cast and directed at such a location, the spell indicates an aura strength of dim (even weaker than a faint aura). How long the aura lingers at this dim level depends on its original power:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Original Strength</th><th>Duration of Lingering Aura</th></tr><tr><td>Faint</td><td>1d6 rounds</td></tr><tr><td>Moderate</td><td>1d6 minutes</td></tr><tr><td>Strong</td><td>1d6x10 minutes</td></tr><tr><td>Overwhelming</td><td>1d6 days</td></tr></tbody></table>

Each round, you can turn to detect undead in a new area. The spell can penetrate barriers, but 1 foot of stone, 1 inch of common metal, a thin sheet of lead, or 3 feet of wood or dirt blocks it.

Arcane Material Component: A bit of earth from a grave.','{"class_levels":{"cleric":1,"paladin":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Clr 1, Pal 1, Sor/Wiz 1","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"60 ft.","Area":"Cone-shaped emanation","Duration":"Concentration, up to 1 minute/ level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dictum','Dictum','Clr 7, Law 7',7,'Evocation [Lawful, Sonic]','40 ft.',NULL,'Nonlawful creatures in a 40-ft.-radius spread centered on you','Instantaneous','V',ARRAY['cleric']::text[],'Evocation \[Lawful, Sonic\]

Level: Clr 7, Law 7

Components: V

Casting Time: 1 standard action

Range: 40 ft.

Area: Nonlawful creatures in a 40-ft.-radius spread centered on you

Duration: Instantaneous

Saving Throw: None or Will negates; see text

Spell Resistance: Yes

Any nonlawful creature within the area of a dictum spell suffers the following ill effects.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Effect</th></tr><tr><td>Equal to caster level</td><td>Deafened</td></tr><tr><td>Up to caster level –1</td><td><i>Slowed,</i> deafened</td></tr><tr><td>Up to caster level –5</td><td>Paralyzed, <i>slowed,</i> deafened</td></tr><tr><td>Up to caster level –10</td><td>Killed, paralyzed, <i>slowed</i>, deafened</td></tr></tbody></table>

The effects are cumulative and concurrent. No saving throw is allowed against these effects.

Deafened: The creature is deafened for 1d4 rounds.

Slowed: The creature is slowed, as by the slow spell, for 2d4 rounds.

Paralyzed: The creature is paralyzed and helpless for 1d10 minutes.

Killed: Living creatures die. Undead creatures are destroyed.

Furthermore, if you are on your home plane when you cast this spell, nonlawful extraplanar creatures within the area are instantly banished back to their home planes. Creatures so banished cannot return for at least 24 hours. This effect takes place regardless of whether the creatures hear the dictum. The banishment effect allows a Will save (at a –4 penalty) to negate.

Creatures whose HD exceed your caster level are unaffected by dictum.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7, Law 7","Components":"V","Casting Time":"1 standard action","Range":"40 ft.","Area":"Nonlawful creatures in a 40-ft.-radius spread centered on you","Duration":"Instantaneous","Saving Throw":"None or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dimension_door','Dimension Door','Brd 4, Sor/Wiz 4, Travel 4',4,'Conjuration (Teleportation)','Long (400 ft. + 40 ft./level)','You and touched objects or other touched willing creatures',NULL,'Instantaneous','V',ARRAY['bard','sorcerer','wizard']::text[],'Conjuration (Teleportation)

Level: Brd 4, Sor/Wiz 4, Travel 4

Components: V

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Target: You and touched objects or other touched willing creatures

Duration: Instantaneous

Saving Throw: None and Will negates (object)

Spell Resistance: No and Yes (object)

You instantly transfer yourself from your current location to any other spot within range. You always arrive at exactly the spot desired—whether by simply visualizing the area or by stating direction. After using this spell, you can’t take any other actions until your next turn. You can bring along objects as long as their weight doesn’t exceed your maximum load. You may also bring one additional willing Medium or smaller creature (carrying gear or objects up to its maximum load) or its equivalent per three caster levels. A Large creature counts as two Medium creatures, a Huge creature counts as two Large creatures, and so forth. All creatures to be transported must be in contact with one another, and at least one of those creatures must be in contact with you.

If you arrive in a place that is already occupied by a solid body, you and each creature traveling with you take 1d6 points of damage and are shunted to a random open space on a suitable surface within 100 feet of the intended location.

If there is no free space within 100 feet, you and each creature traveling with you take an additional 2d6 points of damage and are shunted to a free space within 1,000 feet. If there is no free space within 1,000 feet, you and each creature travelling with you take an additional 4d6 points of damage and the spell simply fails.','{"class_levels":{"bard":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 4, Sor/Wiz 4, Travel 4","Components":"V","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Target":"You and touched objects or other touched willing creatures","Duration":"Instantaneous","Saving Throw":"None and Will negates (object)","Spell Resistance":"No and Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dimensional_anchor','Dimensional Anchor','Clr 4, Sor/Wiz 4',4,'Abjuration','Medium (100 ft. + 10 ft./level)','Ray',NULL,'1 min./level','V, S',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 4, Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Ray

Duration: 1 min./level

Saving Throw: None

Spell Resistance: Yes (object)

A green ray springs from your outstretched hand. You must make a ranged touch attack to hit the target. Any creature or object struck by the ray is covered with a shimmering emerald field that completely blocks extradimensional travel. Forms of movement barred by a dimensional anchor include astral projection, blink, dimension door, ethereal jaunt, etherealness, gate, maze, plane shift, shadow walk, teleport, and similar spell-like or psionic abilities. The spell also prevents the use of a gate or teleportation circle for the duration of the spell.

A dimensional anchor does not interfere with the movement of creatures already in ethereal or astral form when the spell is cast, nor does it block extradimensional perception or attack forms. Also, dimensional anchor does not prevent summoned creatures from disappearing at the end of a summoning spell.','{"class_levels":{"cleric":4,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Clr 4, Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Ray","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dimensional_lock','Dimensional Lock','Clr 8, Sor/Wiz 8',8,'Abjuration','Medium (100 ft. + 10 ft./level)',NULL,'20-ft.-radius emanation centered on a point in space','One day/level','V, S',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 8, Sor/Wiz 8

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: 20-ft.-radius emanation centered on a point in space

Duration: One day/level

Saving Throw: None

Spell Resistance: Yes

You create a shimmering emerald barrier that completely blocks extradimensional travel. Forms of movement barred include astral projection, blink, dimension door, ethereal jaunt, etherealness, gate, maze, plane shift, shadow walk, teleport, and similar spell-like or psionic abilities. Once dimensional lock is in place, extradimensional travel into or out of the area is not possible.

A dimensional lock does not interfere with the movement of creatures already in ethereal or astral form when the spell is cast, nor does it block extradimensional perception or attack forms. Also, the spell does not prevent summoned creatures from disappearing at the end of a summoning spell.','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Sor/Wiz 8","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"20-ft.-radius emanation centered on a point in space","Duration":"One day/level","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_diminish_plants','Diminish Plants','Drd 3, Rgr 3',3,'Transmutation','See text',NULL,NULL,'Instantaneous','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 3, Rgr 3

Components: V, S, DF

Casting Time: 1 standard action

Range: See text

Target or Area: See text

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

This spell has two versions.

Prune Growth: This version causes normal vegetation within long range (400 feet + 40 feet per level) to shrink to about one-third of their normal size, becoming untangled and less bushy. The affected vegetation appears to have been carefully pruned and trimmed.

At your option, the area can be a 100- foot-radius circle, a 150-foot-radius semicircle, or a 200-foot-radius quarter-circle.

You may also designate portions of the area that are not affected.

Stunt Growth: This version targets normal plants within a range of 1/2 mile, reducing their potential productivity over the course of the following year to one third below normal.

Diminish plants counters plant growth.

This spell has no effect on plant creatures.','{"class_levels":{"druid":3,"ranger":3},"source_field_values":{"Level":"Drd 3, Rgr 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"See text","Target or Area":"See text","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_discern_lies','Discern Lies','Clr 4, Pal 3',3,'Divination','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Concentration, up to 1 round/level','V, S, DF',ARRAY['cleric','paladin']::text[],'Divination

Level: Clr 4, Pal 3

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

Duration: Concentration, up to 1 round/level

Saving Throw: Will negates

Spell Resistance: No

Each round, you concentrate on one subject, who must be within range. You know if the subject deliberately and knowingly speaks a lie by discerning disturbances in its aura caused by lying. The spell does not reveal the truth, uncover unintentional inaccuracies, or necessarily reveal evasions.

Each round, you may concentrate on a different subject.','{"class_levels":{"cleric":4,"paladin":3},"source_field_values":{"Level":"Clr 4, Pal 3","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart","Duration":"Concentration, up to 1 round/level","Saving Throw":"Will negates","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_discern_location','Discern Location','Clr 8, Knowledge 8, Sor/Wiz 8',8,'Divination','Unlimited','One creature or object',NULL,'Instantaneous','V, S, DF',ARRAY['cleric','sorcerer','wizard']::text[],'Divination

Level: Clr 8, Knowledge 8, Sor/Wiz 8

Components: V, S, DF

Casting Time: 10 minutes

Range: Unlimited

Target: One creature or object

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

A discern location spell is among the most powerful means of locating creatures or objects. Nothing short of a mind blank spell or the direct intervention of a deity keeps you from learning the exact location of a single individual or object. Discern location circumvents normal means of protection from scrying or location. The spell reveals the name of the creature or object’s location (place, name, business name, building name, or the like), community, county (or similar political division), country, continent, and the plane of existence where the target lies.

To find a creature with the spell, you must have seen the creature or have some item that once belonged to it. To find an object, you must have touched it at least once.','{"class_levels":{"cleric":8,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Clr 8, Knowledge 8, Sor/Wiz 8","Components":"V, S, DF","Casting Time":"10 minutes","Range":"Unlimited","Target":"One creature or object","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_disguise_self','Disguise Self','Brd 1, Sor/Wiz 1, Trickery 1',1,'Illusion (Glamer)','Personal','You',NULL,'10 min./level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 1, Sor/Wiz 1, Trickery 1

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level (D)

You make yourself—including clothing, armor, weapons, and equipment—look different. You can seem 1 foot shorter or taller, thin, fat, or in between. You cannot change your body type. Otherwise, the extent of the apparent change is up to you. You could add or obscure a minor feature or look like an entirely different person.

The spell does not provide the abilities or mannerisms of the chosen form, nor does it alter the perceived tactile (touch) or audible (sound) properties of you or your equipment.

If you use this spell to create a disguise, you get a +10 bonus on the Disguise check.

A creature that interacts with the glamer gets a Will save to recognize it as an illusion.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1, Trickery 1","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_disintegrate','Disintegrate','Destruction 7, Sor/Wiz 6',6,'Transmutation','Medium (100 ft. + 10 ft./level)','Ray',NULL,'Instantaneous','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Transmutation

Level: Destruction 7, Sor/Wiz 6

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Ray

Duration: Instantaneous

Saving Throw: Fortitude partial (object)

Spell Resistance: Yes

A thin, green ray springs from your pointing finger. You must make a successful ranged touch attack to hit. Any creature struck by the ray takes 2d6 points of damage per caster level (to a maximum of 40d6). Any creature reduced to 0 or fewer hit points by this spell is entirely disintegrated, leaving behind only a trace of fine dust. A disintegrated creature’s equipment is unaffected.

When used against an object, the ray simply disintegrates as much as one 10- foot cube of nonliving matter. Thus, the spell disintegrates only part of any very large object or structure targeted. The ray affects even objects constructed entirely of force, such as forceful hand or a wall of force, but not magical effects such as a globe of invulnerability or an antimagic field.

A creature or object that makes a successful Fortitude save is partially affected, taking only 5d6 points of damage. If this damage reduces the creature or object to 0 or fewer hit points, it is entirely disintegrated.

Only the first creature or object struck can be affected; that is, the ray affects only one target per casting.

Arcane Material Component: A lodestone and a pinch of dust.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Destruction 7, Sor/Wiz 6","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Ray","Duration":"Instantaneous","Saving Throw":"Fortitude partial (object)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dismissal','Dismissal','Clr 4, Sor/Wiz 5',4,'Abjuration','Close (25 ft. + 5 ft./2 levels)','One extraplanar creature',NULL,'Instantaneous','V, S, DF',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 4, Sor/Wiz 5

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One extraplanar creature

Duration: Instantaneous

Saving Throw: Will negates; see text

Spell Resistance: Yes

This spell forces an extraplanar creature back to its proper plane if it fails a special Will save (DC = spell’s save DC – creature’s HD + your caster level). If the spell is successful, the creature is instantly whisked away, but there is a 20% chance of actually sending the subject to a plane other than its own.','{"class_levels":{"cleric":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Clr 4, Sor/Wiz 5","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One extraplanar creature","Duration":"Instantaneous","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md'),
('srd35_spell_dispel_chaos','Dispel Chaos','Clr 5, Law 5, Pal 4',4,'Abjuration [Lawful]',NULL,NULL,NULL,NULL,NULL,ARRAY['cleric','paladin']::text[],'Abjuration \[Lawful\]

Level: Clr 5, Law 5, Pal 4

This spell functions like dispel evil, except that you are surrounded by constant, blue, lawful energy, and the spell affects chaotic creatures and spells rather than evil ones.','{"class_levels":{"cleric":5,"paladin":4},"source_field_values":{"Level":"Clr 5, Law 5, Pal 4"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-d-e.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
