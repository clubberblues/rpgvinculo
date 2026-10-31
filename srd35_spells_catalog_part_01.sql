-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_acid_arrow','Acid Arrow','Sor/Wiz 2',2,'Conjuration (Creation) [Acid]','Long (400 ft. + 40 ft./level)','One arrow of acid',NULL,'1 round + 1 round per three levels','V, S, M, F',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation) \[Acid\]

Level: Sor/Wiz 2

Components: V, S, M, F

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Effect: One arrow of acid

Duration: 1 round + 1 round per three levels

Saving Throw: None

Spell Resistance: No

A magical arrow of acid springs from your hand and speeds to its target. You must succeed on a ranged touch attack to hit your target. The arrow deals 2d4 points of acid damage with no splash damage. For every three caster levels (to a maximum of 18th), the acid, unless somehow neutralized, lasts for another round, dealing another 2d4 points of damage in that round.

Material Component: Powdered rhubarb leaf and an adder’s stomach.

Focus: A dart.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M, F","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Effect":"One arrow of acid","Duration":"1 round + 1 round per three levels","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_acid_fog','Acid Fog','Sor/Wiz 6, Water 7',6,'Conjuration (Creation) [Acid]','Medium (100 ft. + 10 ft./level)','Fog spreads in 20-ft. radius, 20 ft. high',NULL,'1 round/level','V, S, M/DF',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation) \[Acid\]

Level: Sor/Wiz 6, Water 7

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Fog spreads in 20-ft. radius, 20 ft. high

Duration: 1 round/level

Saving Throw: None

Spell Resistance: No

Acid fog creates a billowing mass of misty vapors similar to that produced by a solid fog spell. In addition to slowing creatures down and obscuring sight, this spell’s vapors are highly acidic. Each round on your turn, starting when you cast the spell, the fog deals 2d6 points of acid damage to each creature and object within it.

Arcane Material Component: A pinch of dried, powdered peas combined with powdered animal hoof.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6, Water 7","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Fog spreads in 20-ft. radius, 20 ft. high","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_acid_splash','Acid Splash','Sor/Wiz 0',0,'Conjuration (Creation) [Acid]','Close (25 ft. + 5 ft./2 levels)','One missile of acid',NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation) \[Acid\]

Level: Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Effect: One missile of acid

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

You fire a small orb of acid at the target. You must succeed on a ranged touch attack to hit your target. The orb deals 1d3 points of acid damage.','{"class_levels":{"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Effect":"One missile of acid","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_aid','Aid','Clr 2, Good 2, Luck 2',2,'Enchantment (Compulsion) [Mind-Affecting]','Touch','Living creature touched',NULL,'1 min./level','V, S, DF',ARRAY['cleric']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 2, Good 2, Luck 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 1 min./level

Saving Throw: None

Spell Resistance: Yes (harmless)

Aid grants the target a +1 morale bonus on attack rolls and saves against fear effects, plus temporary hit points equal to 1d8 + caster level (to a maximum of 1d8+10 temporary hit points at caster level 10th).','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2, Good 2, Luck 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_air_walk','Air Walk','Air 4, Clr 4, Drd 4',4,'Transmutation [Air]','Touch','Creature (Gargantuan or smaller) touched',NULL,'10 min./level','V, S, DF',ARRAY['cleric','druid']::text[],'Transmutation \[Air\]

Level: Air 4, Clr 4, Drd 4

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature (Gargantuan or smaller) touched

Duration: 10 min./level

Saving Throw: None

Spell Resistance: Yes (harmless)

The subject can tread on air as if walking on solid ground. Moving upward is similar to walking up a hill. The maximum upward or downward angle possible is 45 degrees, at a rate equal to one-half the air walker’s normal speed.

A strong wind (21+ mph) can push the subject along or hold it back. At the end of its turn each round, the wind blows the air walker 5 feet for each 5 miles per hour of wind speed. The creature may be subject to additional penalties in exceptionally strong or turbulent winds, such as loss of control over movement or physical damage from being buffeted about.

Should the spell duration expire while the subject is still aloft, the magic fails slowly. The subject floats downward 60 feet per round for 1d6 rounds. If it reaches the ground in that amount of time, it lands safely. If not, it falls the rest of the distance, taking 1d6 points of damage per 10 feet of fall. Since dispelling a spell effectively ends it, the subject also descends in this way if the air walk spell is dispelled, but not if it is negated by an antimagic field.

You can cast air walk on a specially trained mount so it can be ridden through the air. You can train a mount to move with the aid of air walk (counts as a trick; see Handle Animal skill) with one week of work and a DC 25 Handle Animal check.','{"class_levels":{"cleric":4,"druid":4},"source_field_values":{"Level":"Air 4, Clr 4, Drd 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature (Gargantuan or smaller) touched","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_alarm','Alarm','Brd 1, Rgr 1, Sor/Wiz 1',1,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,'20-ft.-radius emanation centered on a point in space','2 hours/level (D)','V, S, F/DF',ARRAY['bard','ranger','sorcerer','wizard']::text[],'Abjuration

Level: Brd 1, Rgr 1, Sor/Wiz 1

Components: V, S, F/DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 20-ft.-radius emanation centered on a point in space

Duration: 2 hours/level (D)

Saving Throw: None

Spell Resistance: No

Alarm sounds a mental or audible alarm each time a creature of Tiny or larger size enters the warded area or touches it. A creature that speaks the password (determined by you at the time of casting) does not set off the alarm. You decide at the time of casting whether the alarm will be mental or audible.

Mental Alarm: A mental alarm alerts you (and only you) so long as you remain within 1 mile of the warded area. You note a single mental “ping” that awakens you from normal sleep but does not otherwise disturb concentration. A silence spell has no effect on a mental alarm.

Audible Alarm: An audible alarm produces the sound of a hand bell, and anyone within 60 feet of the warded area can hear it clearly. Reduce the distance by 10 feet for each interposing closed door and by 20 feet for each substantial interposing wall.

In quiet conditions, the ringing can be heard faintly as far as 180 feet away. The sound lasts for 1 round. Creatures within a silence spell cannot hear the ringing.

Ethereal or astral creatures do not trigger the alarm.

Alarm can be made permanent with a permanency spell.

Arcane Focus: A tiny bell and a piece of very fine silver wire','{"class_levels":{"bard":1,"ranger":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Rgr 1, Sor/Wiz 1","Components":"V, S, F/DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"20-ft.-radius emanation centered on a point in space","Duration":"2 hours/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_align_weapon','Align Weapon','Clr 2',2,'Transmutation [see text]','Touch','Weapon touched or fifty projectiles (all of which must be in contact with each other at the time of casting)',NULL,'1 min./level','V, S, DF',ARRAY['cleric']::text[],'Transmutation \[see text\]

Level: Clr 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Weapon touched or fifty projectiles (all of which must be in contact with each other at the time of casting)

Duration: 1 min./level

Saving Throw: Will negates (harmless, object)

Spell Resistance: Yes (harmless, object)

Align weapon makes a weapon good, evil, lawful, or chaotic, as you choose. A weapon that is aligned can bypass the damage reduction of certain creatures. This spell has no effect on a weapon that already has an alignment.

You can’t cast this spell on a natural weapon, such as an unarmed strike.

When you make a weapon good, evil, lawful, or chaotic, align weapon is a good, evil, lawful, or chaotic spell, respectively.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Weapon touched or fifty projectiles (all of which must be in contact with each other at the time of casting)","Duration":"1 min./level","Saving Throw":"Will negates (harmless, object)","Spell Resistance":"Yes (harmless, object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_alter_self','Alter Self','Brd 2, Sor/Wiz 2',2,'Transmutation','Personal','You',NULL,'10 min./level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 2, Sor/Wiz 2

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 10 min./level (D)

You assume the form of a creature of the same type as your normal form. The new form must be within one size category of your normal size. The maximum HD of an assumed form is equal to your caster level, to a maximum of 5 HD at 5th level. You can change into a member of your own kind or even into yourself.

You retain your own ability scores. Your class and level, hit points, alignment, base attack bonus, and base save bonuses all remain the same. You retain all supernatural and spell-like special attacks and qualities of your normal form, except for those requiring a body part that the new form does not have (such as a mouth for a breath weapon or eyes for a gaze attack).

You keep all extraordinary special attacks and qualities derived from class levels, but you lose any from your normal form that are not derived from class levels.

If the new form is capable of speech, you can communicate normally. You retain any spellcasting ability you had in your original form, but the new form must be able to speak intelligibly (that is, speak a language) to use verbal components and must have limbs capable of fine manipulation to use somatic or material components.

You acquire the physical qualities of the new form while retaining your own mind. Physical qualities include natural size, mundane movement capabilities (such as burrowing, climbing, walking, swimming, and flight with wings, to a maximum speed of 120 feet for flying or 60 feet for nonflying movement), natural armor bonus, natural weapons (such as claws, bite, and so on), racial skill bonuses, racial bonus feats, and any gross physical qualities (presence or absence of wings, number of extremities, and so forth). A body with extra limbs does not allow you to make more attacks (or more advantageous two-weapon attacks) than normal.

You do not gain any extraordinary special attacks or special qualities not noted above under physical qualities, such as darkvision, low-light vision, blindsense, blindsight, fast healing, regeneration, scent, and so forth.

You do not gain any supernatural special attacks, special qualities, or spell-like abilities of the new form. Your creature type and subtype (if any) remain the same regardless of your new form. You cannot take the form of any creature with a template, even if that template doesn’t change the creature type or subtype.

You can freely designate the new form’s minor physical qualities (such as hair color, hair texture, and skin color) within the normal ranges for a creature of that kind. The new form’s significant physical qualities (such as height, weight, and gender) are also under your control, but they must fall within the norms for the new form’s kind. You are effectively disguised as an average member of the new form’s race. If you use this spell to create a disguise, you get a +10 bonus on your Disguise check.

When the change occurs, your equipment, if any, either remains worn or held by the new form (if it is capable of wearing or holding the item), or melds into the new form and becomes nonfunctional. When you revert to your true form, any objects previously melded into the new form reappear in the same location on your body they previously occupied and are once again functional. Any new items you wore in the assumed form and can’t wear in your normal form fall off and land at your feet; any that you could wear in either form or carry in a body part common to both forms at the time of reversion are still held in the same way. Any part of the body or piece of equipment that is separated from the whole reverts to its true form.','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Sor/Wiz 2","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"10 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_analyze_dweomer','Analyze Dweomer','Brd 6, Sor/Wiz 6',6,'Divination','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level (D)','V, S, F',ARRAY['bard','sorcerer','wizard']::text[],'Divination

Level: Brd 6, Sor/Wiz 6

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One object or creature per caster level

Duration: 1 round/level (D)

Saving Throw: None or Will negates; see text

Spell Resistance: No

You discern all spells and magical properties present in a number of creatures or objects. Each round, you may examine a single creature or object that you can see as a free action. In the case of a magic item, you learn its functions, how to activate its functions (if appropriate), and how many charges are left (if it uses charges). In the case of an object or creature with active spells cast upon it, you learn each spell, its effect, and its caster level.

An attended object may attempt a Will save to resist this effect if its holder so desires. If the save succeeds, you learn nothing about the object except what you can discern by looking at it. An object that makes its save cannot be affected by any other analyze dweomer spells for 24 hours.

Analyze dweomer does not function when used on an artifact.

Focus: A tiny lens of ruby or sapphire set in a small golden loop. The gemstone must be worth at least 1,500 gp.','{"class_levels":{"bard":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Sor/Wiz 6","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One object or creature per caster level","Duration":"1 round/level (D)","Saving Throw":"None or Will negates; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animal_growth','Animal Growth','Drd 5, Rgr 4, Sor/Wiz 5',4,'Transmutation','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 min./level','V, S',ARRAY['druid','ranger','sorcerer','wizard']::text[],'Transmutation

Level: Drd 5, Rgr 4, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: Up to one animal (Gargantuan or smaller) per two levels, no two of which can be more than 30 ft. apart

Duration: 1 min./level

Saving Throw: Fortitude negates

Spell Resistance: Yes

A number of animals grow to twice their normal size and eight times their normal weight. This alteration changes each animal’s size category to the next largest, grants it a +8 size bonus to Strength and a +4 size bonus to Constitution (and thus an extra 2 hit points per HD), and imposes a –2 size penalty to Dexterity. The creature’s existing natural armor bonus increases by 2. The size change also affects the animal’s modifier to AC and attack rolls and its base damage. The animal’s space and reach change as appropriate to the new size, but its speed does not change.

The spell also grants each subject damage reduction 10/magic and a +4 resistance bonus on saving throws. If insufficient room is available for the desired growth, the creature attains the maximum possible size and may make a Strength check (using its increased Strength) to burst any enclosures in the process. If it fails, it is constrained without harm by the materials enclosing it— the spell cannot be used to crush a creature by increasing its size.

All equipment worn or carried by an animal is similarly enlarged by the spell, though this change has no effect on the magical properties of any such equipment.

Any enlarged item that leaves the enlarged creature’s possession instantly returns to its normal size.

The spell gives no means of command or influence over the enlarged animals.

Multiple magical effects that increase size do not stack.','{"class_levels":{"druid":5,"ranger":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Drd 5, Rgr 4, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"Up to one animal (Gargantuan or smaller) per two levels, no two of which can be more than 30 ft. apart","Duration":"1 min./level","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animal_messenger','Animal Messenger','Brd 2, Drd 2, Rgr 1',1,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One Tiny animal',NULL,'One day/level','V, S, M',ARRAY['bard','druid','ranger']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Drd 2, Rgr 1

Components: V, S, M

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One Tiny animal

Duration: One day/level

Saving Throw: None; see text

Spell Resistance: Yes

You compel a Tiny animal to go to a spot you designate. The most common use for this spell is to get an animal to carry a message to your allies. The animal cannot be one tamed or trained by someone else, including such creatures as familiars and animal companions.

Using some type of food desirable to the animal as a lure, you call the animal to you. It advances and awaits your bidding. You can mentally impress on the animal a certain place well known to you or an obvious landmark. The directions must be simple, because the animal depends on your knowledge and can’t find a destination on its own. You can attach some small item or note to the messenger. The animal then goes to the designated location and waits there until the duration of the spell expires, whereupon it resumes its normal activities.

During this period of waiting, the messenger allows others to approach it and remove any scroll or token it carries. The intended recipient gains no special ability to communicate with the animal or read any attached message (if it’s written in a language he or she doesn’t know, for example).

Material Component: A morsel of food the animal likes.','{"class_levels":{"bard":2,"druid":2,"ranger":1},"source_field_values":{"Level":"Brd 2, Drd 2, Rgr 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One Tiny animal","Duration":"One day/level","Saving Throw":"None; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animal_shapes','Animal Shapes','Animal 7, Drd 8',8,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 hour/level (D)','V, S, DF',ARRAY['druid']::text[],'Transmutation

Level: Animal 7, Drd 8

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to one willing creature per level, all within 30 ft. of each other

Duration: 1 hour/level (D)

Saving Throw: None; see text

Spell Resistance: Yes (harmless)

As polymorph, except you polymorph up to one willing creature per caster level into an animal of your choice; the spell has no effect on unwilling creatures. All creatures must take the same kind of animal form. Recipients remain in the animal form until the spell expires or until you dismiss it for all recipients. In addition, an individual subject may choose to resume its normal form as a full-round action; doing so ends the spell for that subject alone. The maximum HD of an assumed form is equal to the subject’s HD or your caster level, whichever is lower, to a maximum of 20 HD at 20th level.','{"class_levels":{"druid":8},"source_field_values":{"Level":"Animal 7, Drd 8","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to one willing creature per level, all within 30 ft. of each other","Duration":"1 hour/level (D)","Saving Throw":"None; see text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animal_trance','Animal Trance','Brd 2, Drd 2',2,'Enchantment (Compulsion) [Mind-Affecting, Sonic]','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Concentration','V, S',ARRAY['bard','druid']::text[],'Enchantment (Compulsion) \[Mind-Affecting, Sonic\]

Level: Brd 2, Drd 2

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Animals or magical beasts with Intelligence 1 or 2

Duration: Concentration

Saving Throw: Will negates; see text

Spell Resistance: Yes

Your swaying motions and music (or singing, or chanting) compel animals and magical beasts to do nothing but watch you. Only a creature with an Intelligence score of 1 or 2 can be fascinated by this spell. Roll 2d6 to determine the total number of HD worth of creatures that you fascinate. The closest targets are selected first until no more targets within range can be affected.

A magical beast, a dire animal, or an animal trained to attack or guard is allowed a saving throw; an animal not trained to attack or guard is not.','{"class_levels":{"bard":2,"druid":2},"source_field_values":{"Level":"Brd 2, Drd 2","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Animals or magical beasts with Intelligence 1 or 2","Duration":"Concentration","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animate_dead','Animate Dead','Clr 3, Death 3, Sor/Wiz 4',3,'Necromancy [Evil]','Touch',NULL,NULL,'Instantaneous','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy \[Evil\]

Level: Clr 3, Death 3, Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Targets: One or more corpses touched

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

This spell turns the bones or bodies of dead creatures into undead skeletons or zombies that follow your spoken commands.

The undead can follow you, or they can remain in an area and attack any creature (or just a specific kind of creature) entering the place. They remain animated until they are destroyed. (A destroyed skeleton or zombie can’t be animated again.)

Regardless of the type of undead you create with this spell, you can’t create more HD of undead than twice your caster level with a single casting of animate dead. (The desecrate spell doubles this limit)

The undead you create remain under your control indefinitely. No matter how many times you use this spell, however, you can control only 4 HD worth of undead creatures per caster level. If you exceed this number, all the newly created creatures fall under your control, and any excess undead from previous castings become uncontrolled. (You choose which creatures are released.) If you are a cleric, any undead you might command by virtue of your power to command or rebuke undead do not count toward the limit.

Skeletons: A skeleton can be created only from a mostly intact corpse or skeleton. The corpse must have bones. If a skeleton is made from a corpse, the flesh falls off the bones.

Zombies: A zombie can be created only from a mostly intact corpse. The corpse must be that of a creature with a true anatomy.

Material Component: You must place a black onyx gem worth at least 25 gp per Hit Die of the undead into the mouth or eye socket of each corpse you intend to animate. The magic of the spell turns these gems into worthless, burned-out shells.','{"class_levels":{"cleric":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Clr 3, Death 3, Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Targets":"One or more corpses touched","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animate_objects','Animate Objects','Brd 6, Chaos 6, Clr 6',6,'Transmutation','Medium (100 ft. + 10 ft./level)',NULL,NULL,'1 round/level','V, S',ARRAY['bard','cleric']::text[],'Transmutation

Level: Brd 6, Chaos 6, Clr 6

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Targets: One Small object per caster level; see text

Duration: 1 round/level

Saving Throw: None

Spell Resistance: No

You imbue inanimate objects with mobility and a semblance of life. Each such animated object then immediately attacks whomever or whatever you initially designate.

An animated object can be of any nonmagical material. You may animate one Small or smaller object or an equivalent number of larger objects per caster level. A Medium object counts as two Small or smaller objects, a Large object as four, a Huge object as eight, a Gargantuan object as sixteen, and a Colossal object as thirty-two. You can change the designated target or targets as a move action, as if directing an active spell.

This spell cannot animate objects carried or worn by a creature.

Animate objects can be made permanent with a permanency spell.','{"class_levels":{"bard":6,"cleric":6},"source_field_values":{"Level":"Brd 6, Chaos 6, Clr 6","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Targets":"One Small object per caster level; see text","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animate_plants','Animate Plants','Drd 7, Plant 7',7,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 round/level or 1 hour/level; see text','V',ARRAY['druid']::text[],'Transmutation

Level: Drd 7, Plant 7

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One Large plant per three caster levels or all plants within range; see text

Duration: 1 round/level or 1 hour/level; see text

Saving Throw: None

Spell Resistance: No

You imbue inanimate plants with mobility and a semblance of life. Each animated plant then immediately attacks whomever or whatever you initially designate as though it were an animated object of the appropriate size category. You may animate one Large or smaller plant, or an equivalent number of larger plants, per three caster levels. A Huge plant counts as two Large or smaller plants, a Gargantuan plant as four, and a Colossal plant as eight. You can change the designated target or targets as a move action, as if directing an active spell.

Use the statistics for animated objects, except that plants smaller than Large usually don’t have hardness.

Animate plants cannot affect plant creatures, nor does it affect nonliving vegetable material.

Entangle: Alternatively, you may imbue all plants within range with a degree of mobility, which allows them to entwine around creatures in the area. This usage of the spell duplicates the effect of an entangle spell. Spell resistance does not keep creatures from being entangled. This effect lasts 1 hour per caster level.','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7, Plant 7","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One Large plant per three caster levels or all plants within range; see text","Duration":"1 round/level or 1 hour/level; see text","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_animate_rope','Animate Rope','Brd 1, Sor/Wiz 1',1,'Transmutation','Medium (100 ft. + 10 ft./level)','One ropelike object, length up to 50 ft. + 5 ft./level; see text',NULL,'1 round/level','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One ropelike object, length up to 50 ft. + 5 ft./level; see text

Duration: 1 round/level

Saving Throw: None

Spell Resistance: No

You can animate a nonliving ropelike object. The maximum length assumes a rope with a 1-inch diameter.

Reduce the maximum length by 50% for every additional inch of thickness, and increase it by 50% for each reduction of the rope’s diameter by half.

The possible commands are “coil” (form a neat, coiled stack), “coil and knot,” “loop,” “loop and knot,” “tie and knot,” and the opposites of all of the above (“uncoil,” and so forth). You can give one command each round as a move action, as if directing an active spell.

The rope can enwrap only a creature or an object within 1 foot of it—it does not snake outward—so it must be thrown near the intended target. Doing so requires a successful ranged touch attack roll (range increment 10 feet). A typical 1- inch-diameter hempen rope has 2 hit points, AC 10, and requires a DC 23 Strength check to burst it. The rope does not deal damage, but it can be used as a trip line or to cause a single opponent that fails a Reflex saving throw to become entangled. A creature capable of spellcasting that is bound by this spell must make a DC 15 Concentration check to cast a spell. An entangled creature can slip free with a DC 20 Escape Artist check.

The rope itself and any knots tied in it are not magical.

This spell grants a +2 bonus on any Use Rope checks you make when using the transmuted rope.

The spell cannot animate objects carried or worn by a creature.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One ropelike object, length up to 50 ft. + 5 ft./level; see text","Duration":"1 round/level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_antilife_shell','Antilife Shell','Animal 6, Clr 6, Drd 6',6,'Abjuration','10 ft.',NULL,'10-ft.-radius emanation, centered on you','10 min./level (D)','V, S, DF',ARRAY['cleric','druid']::text[],'Abjuration

Level: Animal 6, Clr 6, Drd 6

Components: V, S, DF

Casting Time: 1 round

Range: 10 ft.

Area: 10-ft.-radius emanation, centered on you

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: Yes

You bring into being a mobile, hemispherical energy field that prevents the entrance of most types of living creatures.

The effect hedges out animals, aberrations, dragons, fey, giants, humanoids, magical beasts, monstrous humanoids, oozes, plants, and vermin, but not constructs, elementals, outsiders, or undead.

This spell may be used only defensively, not aggressively. Forcing an abjuration barrier against creatures that the spell keeps at bay collapses the barrier.','{"class_levels":{"cleric":6,"druid":6},"source_field_values":{"Level":"Animal 6, Clr 6, Drd 6","Components":"V, S, DF","Casting Time":"1 round","Range":"10 ft.","Area":"10-ft.-radius emanation, centered on you","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_antimagic_field','Antimagic Field','Clr 8, Magic 6, Protection 6, Sor/Wiz 6',6,'Abjuration','10 ft.',NULL,'10-ft.-radius emanation, centered on you','10 min./level (D)','V, S, M/DF',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 8, Magic 6, Protection 6, Sor/Wiz 6

Components: V, S, M/DF

Casting Time: 1 standard action

Range: 10 ft.

Area: 10-ft.-radius emanation, centered on you

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: See text

An invisible barrier surrounds you and moves with you. The space within this barrier is impervious to most magical effects, including spells, spell-like abilities, and supernatural abilities. Likewise, it prevents the functioning of any magic items or spells within its confines.

An antimagic field suppresses any spell or magical effect used within, brought into, or cast into the area, but does not dispel it. Time spent within an antimagic field counts against the suppressed spell’s duration.

Summoned creatures of any type and incorporeal undead wink out if they enter an antimagic field. They reappear in the same spot once the field goes away. Time spent winked out counts normally against the duration of the conjuration that is maintaining the creature. If you cast antimagic field in an area occupied by a summoned creature that has spell resistance, you must make a caster level check (1d20 + caster level) against the creature’s spell resistance to make it wink out. (The effects of instantaneous conjurationsare not affected by an antimagic field because the conjuration itself is no longer in effect, only its result.)

A normal creature can enter the area, as can normal missiles. Furthermore, while a magic sword does not function magically within the area, it is still a sword (and a masterwork sword at that). The spell has no effect on golems and other constructs that are imbued with magic during their creation process and are thereafter self-supporting (unless they have been summoned, in which case they are treated like any other summoned creatures). Elementals, corporeal undead, and outsiders are likewise unaffected unless summoned. These creatures’ spell-like or supernatural abilities, however, may be temporarily nullified by the field. Dispel magic does not remove the field.

Two or more antimagic fields sharing any of the same space have no effect on each other. Certain spells, such as wall of force, prismatic sphere, and prismatic wall, remain unaffected by antimagic field (see the individual spell descriptions). Artifacts and deities are unaffected by mortal magic such as this.

Should a creature be larger than the area enclosed by the barrier, any part of it that lies outside the barrier is unaffected by the field.

Arcane Material Component: A pinch of powdered iron or iron filings.','{"class_levels":{"cleric":8,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 8, Magic 6, Protection 6, Sor/Wiz 6","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"10 ft.","Area":"10-ft.-radius emanation, centered on you","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"See text"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_antipathy','Antipathy','Drd 9, Sor/Wiz 8',8,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One location (up to a 10-ft. cube/level) or one object',NULL,'2 hours/level (D)','V, S, M/DF',ARRAY['druid','sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Drd 9, Sor/Wiz 8

Components: V, S, M/DF

Casting Time: 1 hour

Range: Close (25 ft. + 5 ft./2 levels)

Target: One location (up to a 10-ft. cube/level) or one object

Duration: 2 hours/level (D)

Saving Throw: Will partial

Spell Resistance: Yes

You cause an object or location to emanate magical vibrations that repel either a specific kind of intelligent creature or creatures of a particular alignment, as defined by you. The kind of creature to be affected must be named specifically. A creature subtype is not specific enough. Likewise, the specific alignment to be repelled must be named.

Creatures of the designated kind or alignment feel an overpowering urge to leave the area or to avoid the affected item.

A compulsion forces them to abandon the area or item, shunning it and never willingly returning to it while the spell is in effect. A creature that makes a successful saving throw can stay in the area or touch the item but feels uncomfortable doing so. This distracting discomfort reduces the creature’s Dexterity score by 4 points.

Antipathy counters and dispels sympathy.

Arcane Material Component: A lump of alum soaked in vinegar.','{"class_levels":{"druid":9,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Drd 9, Sor/Wiz 8","Components":"V, S, M/DF","Casting Time":"1 hour","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One location (up to a 10-ft. cube/level) or one object","Duration":"2 hours/level (D)","Saving Throw":"Will partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_antiplant_shell','Antiplant Shell','Drd 4',4,'Abjuration','10 ft.',NULL,'10-ft.-radius emanation, centered on you','10 min./level (D)','V, S, DF',ARRAY['druid']::text[],'Abjuration

Level: Drd 4

Components: V, S, DF

Casting Time: 1 standard action

Range: 10 ft.

Area: 10-ft.-radius emanation, centered on you

Duration: 10 min./level (D)

Saving Throw: None

Spell Resistance: Yes

The antiplant shell spell creates an invisible, mobile barrier that keeps all creatures within the shell protected from attacks by plant creatures or animated plants. As with many abjuration spells, forcing the barrier against creatures that the spell keeps at bay strains and collapses the field.','{"class_levels":{"druid":4},"source_field_values":{"Level":"Drd 4","Components":"V, S, DF","Casting Time":"1 standard action","Range":"10 ft.","Area":"10-ft.-radius emanation, centered on you","Duration":"10 min./level (D)","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_arcane_eye','Arcane Eye','Sor/Wiz 4',4,'Divination (Scrying)','Unlimited','Magical sensor',NULL,'1 min./level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Divination (Scrying)

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 10 minutes

Range: Unlimited

Effect: Magical sensor

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

You create an invisible magical sensor that sends you visual information. You can create the arcane eye at any point you can see, but it can then travel outside your line of sight without hindrance. An arcane eye travels at 30 feet per round (300 feet per minute) if viewing an area ahead as a human would (primarily looking at the floor) or 10 feet per round (100 feet per minute) if examining the ceiling and walls as well as the floor ahead. It sees exactly as you would see if you were there.

The eye can travel in any direction as long as the spell lasts. Solid barriers block its passage, but it can pass through a hole or space as small as 1 inch in diameter. The eye can’t enter another plane of existence, even through a gate or similar magical portal.

You must concentrate to use an arcane eye. If you do not concentrate, the eye is inert until you again concentrate.

Material Component: A bit of bat fur.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"10 minutes","Range":"Unlimited","Effect":"Magical sensor","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_arcane_lock','Arcane Lock','Sor/Wiz 2',2,'Abjuration','Touch','The door, chest, or portal touched, up to 30 sq. ft./level in size',NULL,'Permanent','V, S, M',ARRAY['sorcerer','wizard']::text[],'Abjuration

Level: Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: The door, chest, or portal touched, up to 30 sq. ft./level in size

Duration: Permanent

Saving Throw: None

Spell Resistance: No

An arcane lock spell cast upon a door, chest, or portal magically locks it. You can freely pass your own arcane lock without affecting it; otherwise, a door or object secured with this spell can be opened only by breaking in or with a successful dispel magic or knock spell. Add 10 to the normal DC to break open a door or portal affected by this spell. (A knock spell does not remove an arcane lock; it only suppresses the effect for 10 minutes.)

Material Component: Gold dust worth 25 gp.','{"class_levels":{"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"The door, chest, or portal touched, up to 30 sq. ft./level in size","Duration":"Permanent","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_arcane_mark','Arcane Mark','Sor/Wiz 0',0,'Universal','0 ft.','One personal rune or mark, all of which must fit within 1 sq. ft.',NULL,'Permanent','V, S',ARRAY['sorcerer','wizard']::text[],'Universal

Level: Sor/Wiz 0

Components: V, S

Casting Time: 1 standard action

Range: 0 ft.

Effect: One personal rune or mark, all of which must fit within 1 sq. ft.

Duration: Permanent

Saving Throw: None

Spell Resistance: No

This spell allows you to inscribe your personal rune or mark, which can consist of no more than six characters. The writing can be visible or invisible. An arcane mark spell enables you to etch the rune upon any substance without harm to the material upon which it is placed. If an invisible mark is made, a detect magic spell causes it to glow and be visible, though not necessarily understandable.

See invisibility, true seeing, a gem of seeing, or a robe of eyes likewise allows the user to see an invisible arcane mark. A read magic spell reveals the words, if any. The mark cannot be dispelled, but it can be removed by the caster or by an erase spell.

If an arcane mark is placed on a living being, normal wear gradually causes the effect to fade in about a month.

Arcane mark must be cast on an object prior to casting instant summons on the same object (see that spell description for details).','{"class_levels":{"sorcerer":0,"wizard":0},"source_field_values":{"Level":"Sor/Wiz 0","Components":"V, S","Casting Time":"1 standard action","Range":"0 ft.","Effect":"One personal rune or mark, all of which must fit within 1 sq. ft.","Duration":"Permanent","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_arcane_sight','Arcane Sight','Sor/Wiz 3',3,'Divination','Personal','You',NULL,'1 min./level (D)','V, S',ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 min./level (D)

This spell makes your eyes glow blue and allows you to see magical auras within 120 feet of you. The effect is similar to that of a detect magic spell, but arcane sight does not require concentration and discerns aura location and power more quickly.

You know the location and power of all magical auras within your sight. An aura’s power depends on a spell’s functioning level or an item’s caster level, as noted in the description of the detect magic spell. If the items or creatures bearing the auras are in line of sight, you can make Spellcraft skill checks to determine the school of magic involved in each. (Make one check per aura; DC 15 + spell level, or 15 + one-half caster level for a nonspell effect.)

If you concentrate on a specific creature within 120 feet of you as a standard action, you can determine whether it has any spellcasting or spell-like abilities, whether these are arcane or divine (spell-like abilities register as arcane), and the strength of the most powerful spell or spell-like ability the creature currently has available for use.

Arcane sight can be made permanent with a permanency spell.','{"class_levels":{"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 min./level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_arcane_sight_greater','Arcane Sight, Greater','Sor/Wiz 7',7,'Divination',NULL,NULL,NULL,NULL,NULL,ARRAY['sorcerer','wizard']::text[],'Divination

Level: Sor/Wiz 7

This spell functions like arcane sight, except that you automatically know which spells or magical effects are active upon any individual or object you see.

Greater arcane sight doesn’t let you identify magic items.

Unlike arcane sight, this spell cannot be made permanent with a permanency spell.','{"class_levels":{"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Sor/Wiz 7"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_astral_projection','Astral Projection','Clr 9, Sor/Wiz 9, Travel 9',9,'Necromancy','Touch',NULL,NULL,'See text','V, S, M',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 9, Sor/Wiz 9, Travel 9

Components: V, S, M

Casting Time: 30 minutes

Range: Touch

Targets: You plus one additional willing creature touched per two caster levels

Duration: See text

Saving Throw: None

Spell Resistance: Yes

By freeing your spirit from your physical body, this spell allows you to project an astral body onto another plane altogether.

You can bring the astral forms of other willing creatures with you, provided that these subjects are linked in a circle with you at the time of the casting. These fellow travelers are dependent upon you and must accompany you at all times. If something happens to you during the journey, your companions are stranded wherever you left them.

You project your astral self onto the Astral Plane, leaving your physical body behind on the Material Plane in a state of suspended animation. The spell projects an astral copy of you and all you wear or carry onto the Astral Plane. Since the Astral Plane touches upon other planes, you can travel astrally to any of these other planes as you will. To enter one, you leave the Astral Plane, forming a new physical body (and equipment) on the plane of existence you have chosen to enter.

While you are on the Astral Plane, your astral body is connected at all times to your physical body by a silvery cord. If the cord is broken, you are killed, astrally and physically. Luckily, very few things can destroy a silver cord. When a second body is formed on a different plane, the incorporeal silvery cord remains invisibly attached to the new body. If the second body or the astral form is slain, the cord simply returns to your body where it rests on the Material Plane, thereby reviving it from its state of suspended animation. Although astral projections are able to function on the Astral Plane, their actions affect only creatures existing on the Astral Plane; a physical body must be materialized on other planes.

You and your companions may travel through the Astral Plane indefinitely. Your bodies simply wait behind in a state of suspended animation until you choose to return your spirits to them. The spell lasts until you desire to end it, or until it is terminated by some outside means, such as dispel magic cast upon either the physical body or the astral form, the breaking of the silver cord, or the destruction of your body back on the Material Plane (which kills you).

Material Component: A jacinth worth at least 1,000 gp, plus a silver bar worth 5 gp for each person to be affected.','{"class_levels":{"cleric":9,"sorcerer":9,"wizard":9},"source_field_values":{"Level":"Clr 9, Sor/Wiz 9, Travel 9","Components":"V, S, M","Casting Time":"30 minutes","Range":"Touch","Targets":"You plus one additional willing creature touched per two caster levels","Duration":"See text","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_atonement','Atonement','Clr 5, Drd 5',5,'Abjuration','Touch','Living creature touched',NULL,'Instantaneous','V, S, M, F, DF, XP',ARRAY['cleric','druid']::text[],'Abjuration

Level: Clr 5, Drd 5

Components: V, S, M, F, DF, XP

Casting Time: 1 hour

Range: Touch

Target: Living creature touched

Duration: Instantaneous

Saving Throw: None

Spell Resistance: Yes

This spell removes the burden of evil acts or misdeeds from the subject. The creature seeking atonement must be truly repentant and desirous of setting right its misdeeds. If the atoning creature committed the evil act unwittingly or under some form of compulsion, atonement operates normally at no cost to you. However, in the case of a creature atoning for deliberate misdeeds and acts of a knowing and willful nature, you must intercede with your deity (requiring you to expend 500 XP) in order to expunge the subject’s burden. Many casters first assign a subject of this sort a quest (see geas/quest) or similar penance to determine whether the creature is truly contrite before casting the atonement spell on its behalf.

Atonement may be cast for one of several purposes, depending on the version selected.

Reverse Magical Alignment Change: If a creature has had its alignment magically changed, atonement returns its alignment to its original status at no cost in experience points.

Restore Class: A paladin who has lost her class features due to committing an evil act may have her paladinhood restored to her by this spell.

Restore Cleric or Druid Spell Powers: A cleric or druid who has lost the ability to cast spells by incurring the anger of his or her deity may regain that ability by seeking atonement from another cleric of the same deity or another druid. If the transgression was intentional, the casting cleric loses 500 XP for his intercession. If the transgression was unintentional, he does not lose XP.

Redemption or Temptation: You may cast this spell upon a creature of an opposing alignment in order to offer it a chance to change its alignment to match yours. The prospective subject must be present for the entire casting process. Upon completion of the spell, the subject freely chooses whether it retains its original alignment or acquiesces to your offer and changes to your alignment. No duress, compulsion, or magical influence can force the subject to take advantage of the opportunity offered if it is unwilling to abandon its old alignment. This use of the spell does not work on outsiders or any creature incapable of changing its alignment naturally.

Though the spell description refers to evil acts, atonement can also be used on any creature that has performed acts against its alignment, whether those acts are evil, good, chaotic, or lawful.

Note: Normally, changing alignment is up to the player. This use of atonement simply offers a believable way for a character to change his or her alignment drastically, suddenly, and definitively.

Material Component: Burning incense.

Focus: In addition to your holy symbol or normal divine focus, you need a set of prayer beads (or other prayer device, such as a prayer wheel or prayer book) worth at least 500 gp.

XP Cost: When cast for the benefit of a creature whose guilt was the result of deliberate acts, the cost to you is 500 XP per casting (see above).','{"class_levels":{"cleric":5,"druid":5},"source_field_values":{"Level":"Clr 5, Drd 5","Components":"V, S, M, F, DF, XP","Casting Time":"1 hour","Range":"Touch","Target":"Living creature touched","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_augury','Augury','Clr 2',2,'Divination','Personal','You',NULL,'Instantaneous','V, S, M, F',ARRAY['cleric']::text[],'Divination

Level: Clr 2

Components: V, S, M, F

Casting Time: 1 minute

Range: Personal

Target: You

Duration: Instantaneous

An augury can tell you whether a particular action will bring good or bad results for you in the immediate future.

The base chance for receiving a meaningful reply is 70% + 1% per caster level, to a maximum of 90%; this roll is made secretly. A question may be so straightforward that a successful result is automatic, or so vague as to have no chance of success. If the augury succeeds, you get one of four results:

- Weal (if the action will probably bring good results).
- Woe (for bad results).
- Weal and woe (for both).
- Nothing (for actions that don’t have especially good or bad results).

If the spell fails, you get the “nothing” result. A cleric who gets the “nothing” result has no way to tell whether it was the consequence of a failed or successful augury.

The augury can see into the future only about half an hour, so anything that might happen after that does not affect the result. Thus, the result might not take into account the long-term consequences of a contemplated action. All auguries cast by the same person about the same topic use the same dice result as the first casting.

Material Component: Incense worth at least 25 gp.

Focus: A set of marked sticks, bones, or similar tokens of at least 25 gp value.','{"class_levels":{"cleric":2},"source_field_values":{"Level":"Clr 2","Components":"V, S, M, F","Casting Time":"1 minute","Range":"Personal","Target":"You","Duration":"Instantaneous"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_awaken','Awaken','Drd 5',5,'Transmutation','Touch','Animal or tree touched',NULL,'Instantaneous','V, S, DF, XP',ARRAY['druid']::text[],'Transmutation

Level: Drd 5

Components: V, S, DF, XP

Casting Time: 24 hours

Range: Touch

Target: Animal or tree touched

Duration: Instantaneous

Saving Throw: Will negates

Spell Resistance: Yes

You awaken a tree or animal to humanlike sentience. To succeed, you must make a Will save (DC 10 + the animal’s current HD, or the HD the tree will have once awakened).

The awakened animal or tree is friendly toward you. You have no special empathy or connection with a creature you awaken, although it serves you in specific tasks or endeavors if you communicate your desires to it.

An awakened tree has characteristics as if it were an animated object, except that it gains the plant type and its Intelligence, Wisdom, and Charisma scores are each 3d6. An awakened plant gains the ability to move its limbs, roots, vines, creepers, and so forth, and it has senses similar to a human’s.

An awakened animal gets 3d6 Intelligence, +1d3 Charisma, and +2 HD. Its type becomes magical beast (augmented animal). An awakened animal can’t serve as an animal companion, familiar, or special mount.

An awakened tree or animal can speak one language that you know, plus one additional language that you know per point of Intelligence bonus (if any).

XP Cost: 250 XP.','{"class_levels":{"druid":5},"source_field_values":{"Level":"Drd 5","Components":"V, S, DF, XP","Casting Time":"24 hours","Range":"Touch","Target":"Animal or tree touched","Duration":"Instantaneous","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_baleful_polymorph','Baleful Polymorph','Drd 5, Sor/Wiz 5',5,'Transmutation','Close (25 ft. + 5 ft./2 levels)','One creature',NULL,'Permanent','V, S',ARRAY['druid','sorcerer','wizard']::text[],'Transmutation

Level: Drd 5, Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One creature

Duration: Permanent

Saving Throw: Fortitude negates, Will partial; see text

Spell Resistance: Yes

As polymorph, except that you change the subject into a Small or smaller animal of no more than 1 HD. If the new form would prove fatal to the creature the subject gets a +4 bonus on the save.

If the spell succeeds, the subject must also make a Will save. If this second save fails, the creature loses its extraordinary, supernatural, and spell-like abilities, loses its ability to cast spells (if it had the ability), and gains the alignment, special abilities, and Intelligence, Wisdom, and Charisma scores of its new form in place of its own. It still retains its class and level (or HD), as well as all benefits deriving therefrom (such as base attack bonus, base save bonuses, and hit points). It retains any class features (other than spellcasting) that aren’t extraordinary, supernatural, or spell-like abilities.

Incorporeal or gaseous creatures are immune to being polymorphed, and a creature with the shapechanger subtype can revert to its natural form as a standard action.','{"class_levels":{"druid":5,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Drd 5, Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One creature","Duration":"Permanent","Saving Throw":"Fortitude negates, Will partial; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bane','Bane','Clr 1',1,'Enchantment (Compulsion) [Fear, Mind-Affecting]','50 ft.',NULL,'All enemies within 50 ft.','1 min./level','V, S, DF',ARRAY['cleric']::text[],'Enchantment (Compulsion) \[Fear, Mind-Affecting\]

Level: Clr 1

Components: V, S, DF

Casting Time: 1 standard action

Range: 50 ft.

Area: All enemies within 50 ft.

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

Bane fills your enemies with fear and doubt. Each affected creature takes a –1 penalty on attack rolls and a –1 penalty on saving throws against fear effects.

Bane counters and dispels bless.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"50 ft.","Area":"All enemies within 50 ft.","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_banishment','Banishment','Clr 6, Sor/Wiz 7',6,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Instantaneous','V, S, F',ARRAY['cleric','sorcerer','wizard']::text[],'Abjuration

Level: Clr 6, Sor/Wiz 7

Components: V, S, F

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One or more extraplanar creatures, no two of which can be more than 30 ft. apart

Duration: Instantaneous

Saving Throw: Will negates

Spell Resistance: Yes

A banishment spell is a more powerful version of the dismissal spell. It enables you to force extraplanar creatures out of your home plane. As many as 2 Hit Dice of creatures per caster level can be banished.

You can improve the spell’s chance of success by presenting at least one object or substance that the target hates, fears, or otherwise opposes. For each such object or substance, you gain a +1 bonus on your caster level check to overcome the target’s spell resistance (if any), the saving throw DC increases by 2.

Certain rare items might work twice as well as a normal item for the purpose of the bonuses (each providing a +2 bonus on the caster level check against spell resistance and increasing the save DC by 4).

Arcane Focus: Any item that is distasteful to the subject (optional, see above).','{"class_levels":{"cleric":6,"sorcerer":7,"wizard":7},"source_field_values":{"Level":"Clr 6, Sor/Wiz 7","Components":"V, S, F","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One or more extraplanar creatures, no two of which can be more than 30 ft. apart","Duration":"Instantaneous","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_barkskin','Barkskin','Drd 2, Rgr 2, Plant 2',2,'Transmutation','Touch','Living creature touched',NULL,'10 min./level','V, S, DF',ARRAY['druid','ranger']::text[],'Transmutation

Level: Drd 2, Rgr 2, Plant 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Living creature touched

Duration: 10 min./level

Saving Throw: None

Spell Resistance: Yes (harmless)

Barkskin toughens a creature’s skin. The effect grants a +2 enhancement bonus to the creature’s existing natural armor bonus. This enhancement bonus increases by 1 for every three caster levels above 3rd, to a maximum of +5 at caster level 12th.

The enhancement bonus provided by barkskin stacks with the target’s natural armor bonus, but not with other enhancement bonuses to natural armor. A creature without natural armor has an effective natural armor bonus of +0.','{"class_levels":{"druid":2,"ranger":2},"source_field_values":{"Level":"Drd 2, Rgr 2, Plant 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Living creature touched","Duration":"10 min./level","Saving Throw":"None","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bear_s_endurance','Bear’s Endurance','Clr 2, Drd 2, Rgr 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, DF',ARRAY['cleric','druid','ranger','sorcerer','wizard']::text[],'Transmutation

Level: Clr 2, Drd 2, Rgr 2, Sor/Wiz 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The affected creature gains greater vitality and stamina. The spell grants the subject a +4 enhancement bonus to Constitution, which adds the usual benefits to hit points, Fortitude saves, Constitution checks, and so forth.

Hit points gained by a temporary increase in Constitution score are not temporary hit points. They go away when the subject’s Constitution drops back to normal. They are not lost first as temporary hit points are.','{"class_levels":{"cleric":2,"druid":2,"ranger":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Clr 2, Drd 2, Rgr 2, Sor/Wiz 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bear_s_endurance_mass','Bear’s Endurance, Mass','Clr 6, Drd 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,NULL,NULL,ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Clr 6, Drd 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

Mass bear ’s endurance works like bear ’s endurance, except that it affects multiple creatures.','{"class_levels":{"cleric":6,"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Drd 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bestow_curse','Bestow Curse','Clr 3, Sor/Wiz 4',3,'Necromancy','Touch','Creature touched',NULL,'Permanent','V, S',ARRAY['cleric','sorcerer','wizard']::text[],'Necromancy

Level: Clr 3, Sor/Wiz 4

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: Permanent

Saving Throw: Will negates

Spell Resistance: Yes

You place a curse on the subject. Choose one of the following three effects.

- –6 decrease to an ability score (minimum 1).
- –4 penalty on attack rolls, saves, ability checks, and skill checks.
- Each turn, the target has a 50% chance to act normally; otherwise, it takes no action.

You may also invent your own curse, but it should be no more powerful than those described above.

The curse bestowed by this spell cannot be dispelled, but it can be removed with a break enchantment, limited wish, miracle, remove curse, or wish spell.

Bestow curse counters remove curse.','{"class_levels":{"cleric":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Clr 3, Sor/Wiz 4","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"Permanent","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_binding','Binding','Sor/Wiz 8',8,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'See text (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Sor/Wiz 8

Components: V, S, M

Casting Time: One minute

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: See text (D)

Saving Throw: Will negates; see text

Spell Resistance: Yes

A binding spell creates a magical restraint to hold a creature. The target gets an initial saving throw only if its Hit Dice equal at least one-half your caster level.

You may have as many as six assistants help you with the spell. For each assistant who casts suggestion, your caster level for this casting of binding increases by 1. For each assistant who casts dominate animal, dominate person, or dominate monster, your caster level for this casting of binding increases by a number equal to one-third of that assistant’s level, provided that the spell’s target is appropriate for a binding spell. Since the assistants’ spells are cast simply to improve your caster level for the purpose of the binding spell, saving throws and spell resistance against the assistants’ spells are irrelevant. Your caster level determines whether the target gets an initial Will saving throw and how long the binding lasts. All binding spells are dismissible.

Regardless of the version of binding you cast, you can specify triggering conditions that end the spell and release the creature whenever they occur. These triggers can be as simple or elaborate as you desire, but the condition must be reasonable and have a likelihood of coming to pass. The conditions can be based on a creature’s name, identity, or alignment but otherwise must be based on observable actions or qualities. Intangibles such as level, class, Hit Dice, or hit points don’t qualify. Once the spell is cast, its triggering conditions cannot be changed. Setting a release condition increases the save DC (assuming a saving throw is allowed) by 2.

If you are casting any of the first three versions of binding (those with limited durations), you may cast additional binding spells to prolong the effect, since the durations overlap. If you do so, the target gets a saving throw at the end of the first spell’s duration, even if your caster level was high enough to disallow an initial saving throw. If the creature succeeds on this save, all the binding spells it has received are broken.

The binding spell has six versions. Choose one of the following versions when you cast the spell.

Chaining: The subject is confined by restraints that generate an antipathy spell affecting all creatures who approach the subject, except you. The duration is one year per caster level. The subject of this form of binding is confined to the spot it occupied when it received the spell.

Slumber: This version causes the subject to become comatose for as long as one year per caster level. The subject does not need to eat or drink while slumbering, nor does it age. This form of binding is more difficult to cast than chaining, making it slightly easier to resist. Reduce the spell’s save DC by 1.

Bound Slumber: This combination of chaining and slumber lasts for as long as one month per caster level. Reduce the save DC by 2.

Hedged Prison: The subject is transported to or otherwise brought within a confined area from which it cannot wander by any means. The effect is permanent. Reduce the save DC by 3.

Metamorphosis: The subject assumes gaseous form, except for its head or face. It is held harmless in a jar or other container, which may be transparent if you so choose. The creature remains aware of its surroundings and can speak, but it cannot leave the container, attack, or use any of its powers or abilities. The binding is permanent. The subject does not need to breathe, eat, or drink while metamorphosed, nor does it age. Reduce the save DC by 4.

Minimus Containment: The subject is shrunk to a height of 1 inch or even less and held within some gem, jar, or similar object. The binding is permanent. The subject does not need to breathe, eat, or drink while contained, nor does it age. Reduce the save DC by 4.

You can’t dispel a binding spell with dispel magic or a similar effect, though an antimagic field or Mage’s disjunction affects it normally. A bound extraplanar creature cannot be sent back to its home plane due to dismissal, banishment, or a similar effect.

Components: The components for a binding spell vary according to the version of the spell, but they always include a continuous chanting utterance read from the scroll or spellbook page containing the spell, somatic gestures, and materials appropriate to the form of binding used. These components can include such items as miniature chains of special metals, soporific herbs of the rarest sort (for slumber bindings), a bell jar of the finest crystal, and the like.

In addition to the specially made props suited to the specific type of binding (cost 500 gp), the spell requires opals worth at least 500 gp for each HD of the target and a vellum depiction or carved statuette of the subject to be captured.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M","Casting Time":"One minute","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"See text (D)","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_black_tentacles','Black Tentacles','Sor/Wiz 4',4,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)',NULL,'20-ft.-radius spread','1 round/level (D)','V, S, M',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 4

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: 20-ft.-radius spread

Duration: 1 round/level (D)

Saving Throw: None

Spell Resistance: No

This spell conjures a field of rubbery black tentacles, each 10 feet long. These waving members seem to spring forth from the earth, floor, or whatever surface is underfoot—including water. They grasp and entwine around creatures that enter the area, holding them fast and crushing them with great strength.

Every creature within the area of the spell must make a grapple check, opposed by the grapple check of the tentacles. Treat the tentacles attacking a particular target as a Large creature with a base attack bonus equal to your caster level and a Strength score of 19. Thus, its grapple check modifier is equal to your caster level +8. The tentacles are immune to all types of damage.

Once the tentacles grapple an opponent, they may make a grapple check each round on your turn to deal 1d6+4 points of bludgeoning damage. The tentacles continue to crush the opponent until the spell ends or the opponent escapes.

Any creature that enters the area of the spell is immediately attacked by the tentacles. Even creatures who aren’t grappling with the tentacles may move through the area at only half normal speed.

Material Component: A piece of tentacle from a giant octopus or a giant squid.','{"class_levels":{"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Sor/Wiz 4","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"20-ft.-radius spread","Duration":"1 round/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blade_barrier','Blade Barrier','Clr 6, Good 6, War 6',6,'Evocation [Force]','Medium (100 ft. + 10 ft./level)','Wall of whirling blades up to 20 ft. long/ level, or a ringed wall of whirling blades with a radius of up to 5 ft. per two levels; either form 20 ft. high',NULL,'1 min./level (D)','V, S',ARRAY['cleric']::text[],'Evocation \[Force\]

Level: Clr 6, Good 6, War 6

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Wall of whirling blades up to 20 ft. long/ level, or a ringed wall of whirling blades with a radius of up to 5 ft. per two levels; either form 20 ft. high

Duration: 1 min./level (D)

Saving Throw: Reflex half or Reflex negates; see text

Spell Resistance: Yes

An immobile, vertical curtain of whirling blades shaped of pure force springs into existence. Any creature passing through the wall takes 1d6 points of damage per caster level (maximum 15d6), with a Reflex save for half damage.

If you evoke the barrier so that it appears where creatures are, each creature takes damage as if passing through the wall. Each such creature can avoid the wall (ending up on the side of its choice) and thus take no damage by making a successful Reflex save.

A blade barrier provides cover (+4 bonus to AC, +2 bonus on Reflex saves) against attacks made through it.','{"class_levels":{"cleric":6},"source_field_values":{"Level":"Clr 6, Good 6, War 6","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Wall of whirling blades up to 20 ft. long/ level, or a ringed wall of whirling blades with a radius of up to 5 ft. per two levels; either form 20 ft. high","Duration":"1 min./level (D)","Saving Throw":"Reflex half or Reflex negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blasphemy','Blasphemy','Clr 7, Evil 7',7,'Evocation [Evil, Sonic]','40 ft.',NULL,'Nonevil creatures in a 40-ft.-radius spread centered on you','Instantaneous','V',ARRAY['cleric']::text[],'Evocation \[Evil, Sonic\]

Level: Clr 7, Evil 7

Components: V

Casting Time: 1 standard action

Range: 40 ft.

Area: Nonevil creatures in a 40-ft.-radius spread centered on you

Duration: Instantaneous

Saving Throw: None or Will negates; see text

Spell Resistance: Yes

Any nonevil creature within the area of a blasphemy spell suffers the following ill effects.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>HD</th><th>Effect</th></tr><tr><td>Equal to caster level</td><td>Dazed</td></tr><tr><td>Up to caster level –1</td><td>Weakened, dazed</td></tr><tr><td>Up to caster level –5</td><td>Paralyzed, weakened, dazed</td></tr><tr><td>Up to caster level –10</td><td>Killed, paralyzed, weakened, dazed</td></tr></tbody></table>

The effects are cumulative and concurrent.

No saving throw is allowed against these effects.

Dazed: The creature can take no actions for 1 round, though it defends itself normally.

Weakened: The creature’s Strength score decreases by 2d6 points for 2d4 rounds.

Paralyzed: The creature is paralyzed and helpless for 1d10 minutes.

Killed: Living creatures die. Undead creatures are destroyed.

Furthermore, if you are on your home plane when you cast this spell, nonevil extraplanar creatures within the area are instantly banished back to their home planes. Creatures so banished cannot return for at least 24 hours. This effect takes place regardless of whether the creatures hear the blasphemy. The banishment effect allows a Will save (at a –4 penalty) to negate.

Creatures whose Hit Dice exceed your caster level are unaffected by blasphemy.','{"class_levels":{"cleric":7},"source_field_values":{"Level":"Clr 7, Evil 7","Components":"V","Casting Time":"1 standard action","Range":"40 ft.","Area":"Nonevil creatures in a 40-ft.-radius spread centered on you","Duration":"Instantaneous","Saving Throw":"None or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_bless','Bless','Clr 1, Pal 1',1,'Enchantment (Compulsion) [Mind-Affecting]','50 ft.',NULL,'The caster and all allies within a 50-ft. burst, centered on the caster','1 min./level','V, S, DF',ARRAY['cleric','paladin']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 1, Pal 1

Components: V, S, DF

Casting Time: 1 standard action

Range: 50 ft.

Area: The caster and all allies within a 50-ft. burst, centered on the caster

Duration: 1 min./level

Saving Throw: None

Spell Resistance: Yes (harmless)

Bless fills your allies with courage. Each ally gains a +1 morale bonus on attack rolls and on saving throws against fear effects.

Bless counters and dispels bane.','{"class_levels":{"cleric":1,"paladin":1},"source_field_values":{"Level":"Clr 1, Pal 1","Components":"V, S, DF","Casting Time":"1 standard action","Range":"50 ft.","Area":"The caster and all allies within a 50-ft. burst, centered on the caster","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bless_water','Bless Water','Clr 1, Pal 1',1,'Transmutation [Good]','Touch','Flask of water touched',NULL,'Instantaneous','V, S, M',ARRAY['cleric','paladin']::text[],'Transmutation \[Good\]

Level: Clr 1, Pal 1

Components: V, S, M

Casting Time: 1 minute

Range: Touch

Target: Flask of water touched

Duration: Instantaneous

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

This transmutation imbues a flask (1 pint) of water with positive energy, turning it into holy water.

Material Component: 5 pounds of powdered silver (worth 25 gp).','{"class_levels":{"cleric":1,"paladin":1},"source_field_values":{"Level":"Clr 1, Pal 1","Components":"V, S, M","Casting Time":"1 minute","Range":"Touch","Target":"Flask of water touched","Duration":"Instantaneous","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bless_weapon','Bless Weapon','Pal 1',1,'Transmutation','Touch','Weapon touched',NULL,'1 min./level','V, S',ARRAY['paladin']::text[],'Transmutation

Level: Pal 1

Components: V, S

Casting Time: 1 standard action

Range: Touch

Target: Weapon touched

Duration: 1 min./level

Saving Throw: None

Spell Resistance: No

This transmutation makes a weapon strike true against evil foes. The weapon is treated as having a +1 enhancement bonus for the purpose of bypassing the damage reduction of evil creatures or striking evil incorporeal creatures (though the spell doesn’t grant an actual enhancement bonus). The weapon also becomes good, which means it can bypass the damage reduction of certain creatures. (This effect overrides and suppresses any other alignment the weapon might have.) Individual arrows or bolts can be transmuted, but affected projectile weapons (such as bows) don’t confer the benefit to the projectiles they shoot.

In addition, all critical hit rolls against evil foes are automatically successful, so every threat is a critical hit. This last effect does not apply to any weapon that already has a magical effect related to critical hits, such as a keen weapon or a vorpal sword.','{"class_levels":{"paladin":1},"source_field_values":{"Level":"Pal 1","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Target":"Weapon touched","Duration":"1 min./level","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blight','Blight','Drd 4, Sor/Wiz 5',4,'Necromancy','Touch',NULL,NULL,'Instantaneous','V, S, DF',ARRAY['druid','sorcerer','wizard']::text[],'Necromancy

Level: Drd 4, Sor/Wiz 5

Components: V, S, DF

Casting Time: 1 standard action

Range: Touch

Duration: Instantaneous

Saving Throw: Fortitude half; see text

Spell Resistance: Yes

This spell withers a single plant of any size. An affected plant creature takes 1d6 points of damage per level (maximum 15d6) and may attempt a Fortitude saving throw for half damage. A plant that isn’t a creature doesn’t receive a save and immediately withers and dies.

This spell has no effect on the soil or surrounding plant life.','{"class_levels":{"druid":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Drd 4, Sor/Wiz 5","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Touch","Duration":"Instantaneous","Saving Throw":"Fortitude half; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blindness_deafness','Blindness/Deafness','Brd 2, Clr 3, Sor/Wiz 2',2,'Necromancy','Medium (100 ft. + 10 ft./level)','One living creature',NULL,'Permanent (D)','V',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Necromancy

Level: Brd 2, Clr 3, Sor/Wiz 2

Components: V

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Target: One living creature

Duration: Permanent (D)

Saving Throw: Fortitude negates

Spell Resistance: Yes

You call upon the powers of unlife to render the subject blinded or deafened, as you choose.','{"class_levels":{"bard":2,"cleric":3,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Clr 3, Sor/Wiz 2","Components":"V","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Target":"One living creature","Duration":"Permanent (D)","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blink','Blink','Brd 3, Sor/Wiz 3',3,'Transmutation','Personal','You',NULL,'1 round/level (D)','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Transmutation

Level: Brd 3, Sor/Wiz 3

Components: V, S

Casting Time: 1 standard action

Range: Personal

Target: You

Duration: 1 round/level (D)

You “blink” back and forth between the Material Plane and the Ethereal Plane. You look as though you’re winking in and out of reality very quickly and at random.

Blinking has several effects, as follows.

Physical attacks against you have a 50% miss chance, and the Blind-Fight feat doesn’t help opponents, since you’re ethereal and not merely invisible. If the attack is capable of striking ethereal creatures, the miss chance is only 20% (for concealment).

If the attacker can see invisible creatures, the miss chance is also only 20%. (For an attacker who can both see and strike ethereal creatures, there is no miss chance.) Likewise, your own attacks have a 20% miss chance, since you sometimes go ethereal just as you are about to strike.

Any individually targeted spell has a 50% chance to fail against you while you’re blinking unless your attacker can target invisible, ethereal creatures. Your own spells have a 20% chance to activate just as you go ethereal, in which case they typically do not affect the Material Plane.

While blinking, you take only half damage from area attacks (but full damage from those that extend onto the Ethereal Plane). You strike as an invisible creature (with a +2 bonus on attack rolls), denying your target any Dexterity bonus to AC.

You take only half damage from falling, since you fall only while you are material.

While blinking, you can step through (but not see through) solid objects. For each 5 feet of solid material you walk through, there is a 50% chance that you become material. If this occurs, you are shunted off to the nearest open space and take 1d6 points of damage per 5 feet so traveled. You can move at only three-quarters speed (because movement on the Ethereal Plane is at half speed, and you spend about half your time there and half your time material.)

Since you spend about half your time on the Ethereal Plane, you can see and even attack ethereal creatures. You interact with ethereal creatures roughly the same way you interact with material ones.

An ethereal creature is invisible, incorporeal, and capable of moving in any direction, even up or down. As an incorporeal creature, you can move through solid objects, including living creatures.

An ethereal creature can see and hear the Material Plane, but everything looks gray and insubstantial. Sight and hearing on the Material Plane are limited to 60 feet.

Force effects and abjurations affect you normally. Their effects extend onto the Ethereal Plane from the Material Plane, but not vice versa. An ethereal creature can’t attack material creatures, and spells you cast while ethereal affect only other ethereal things. Certain material creatures or objects have attacks or effects that work on the Ethereal Plane. Treat other ethereal creatures and objects as material.','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Sor/Wiz 3","Components":"V, S","Casting Time":"1 standard action","Range":"Personal","Target":"You","Duration":"1 round/level (D)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_blur','Blur','Brd 2,Sor/Wiz 2',2,'Illusion (Glamer)','Touch','Creature touched',NULL,'1 min./level (D)','V',ARRAY['bard','sorcerer','wizard']::text[],'Illusion (Glamer)

Level: Brd 2,Sor/Wiz 2

Components: V

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level (D)

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject’s outline appears blurred, shifting and wavering. This distortion grants the subject concealment (20% miss chance).

A see invisibility spell does not counteract the blur effect, but a true seeing spell does.

Opponents that cannot see the subject ignore the spell’s effect (though fighting an unseen opponent carries penalties of its own).','{"class_levels":{"bard":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2,Sor/Wiz 2","Components":"V","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level (D)","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_break_enchantment','Break Enchantment','Brd 4, Clr 5, Luck 5, Pal 4, Sor/Wiz 5',4,'Abjuration','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'Instantaneous','V, S',ARRAY['bard','cleric','paladin','sorcerer','wizard']::text[],'Abjuration

Level: Brd 4, Clr 5, Luck 5, Pal 4, Sor/Wiz 5

Components: V, S

Casting Time: 1 minute

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Up to one creature per level, all within 30 ft. of each other

Duration: Instantaneous

Saving Throw: See text

Spell Resistance: No

This spell frees victims from enchantments, transmutations, and curses. Break enchantment can reverse even an instantaneous effect. For each such effect, you make a caster level check (1d20 + caster level, maximum +15) against a DC of 11 + caster level of the effect. Success means that the creature is free of the spell, curse, or effect. For a cursed magic item, the DC is 25.

If the spell is one that cannot be dispelled by dispel magic, break enchantment works only if that spell is 5th level or lower.

If the effect comes from some permanent magic item break enchantment does not remove the curse from the item, but it does frees the victim from the item’s effects.','{"class_levels":{"bard":4,"cleric":5,"paladin":4,"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Brd 4, Clr 5, Luck 5, Pal 4, Sor/Wiz 5","Components":"V, S","Casting Time":"1 minute","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Up to one creature per level, all within 30 ft. of each other","Duration":"Instantaneous","Saving Throw":"See text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bull_s_strength','Bull’s Strength','Clr 2, Drd 2, Pal 2, Sor/Wiz 2, Strength 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, M/DF',ARRAY['cleric','druid','paladin','sorcerer','wizard']::text[],'Transmutation

Level: Clr 2, Drd 2, Pal 2, Sor/Wiz 2, Strength 2

Components: V, S, M/DF

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes (harmless)

The subject becomes stronger. The spell grants a +4 enhancement bonus to Strength, adding the usual benefits to melee attack rolls, melee damage rolls, and other uses of the Strength modifier.

Arcane Material Component: A few hairs, or a pinch of dung, from a bull.','{"class_levels":{"cleric":2,"druid":2,"paladin":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Clr 2, Drd 2, Pal 2, Sor/Wiz 2, Strength 2","Components":"V, S, M/DF","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_bull_s_strength_mass','Bull’s Strength, Mass','Clr 6, Drd 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,NULL,NULL,ARRAY['cleric','druid','sorcerer','wizard']::text[],'Transmutation

Level: Clr 6, Drd 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like bull’s strength, except that it affects multiple creatures.','{"class_levels":{"cleric":6,"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Clr 6, Drd 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_burning_hands','Burning Hands','Fire 1, Sor/Wiz 1',1,'Evocation [Fire]','15 ft.',NULL,'Cone-shaped burst','Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Evocation \[Fire\]

Level: Fire 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: 15 ft.

Area: Cone-shaped burst

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

A cone of searing flame shoots from your fingertips. Any creature in the area of the flames takes 1d4 points of fire damage per caster level (maximum 5d4). Flammable materials burn if the flames touch them. A character can extinguish burning items as a full-round action.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Fire 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"15 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-a-b.md'),
('srd35_spell_call_lightning','Call Lightning','Drd 3',3,'Evocation [Electricity]','Medium (100 ft. + 10 ft./level)','One or more 30-ft.-long vertical lines of lightning',NULL,'1 min./level','V, S',ARRAY['druid']::text[],'Evocation \[Electricity\]

Level: Drd 3

Components: V, S

Casting Time: 1 round

Range: Medium (100 ft. + 10 ft./level)

Effect: One or more 30-ft.-long vertical lines of lightning

Duration: 1 min./level

Saving Throw: Reflex half

Spell Resistance: Yes

Immediately upon completion of the spell, and once per round thereafter, you may call down a 5-foot-wide, 30-foot-long, vertical bolt of lightning that deals 3d6 points of electricity damage. The bolt of lightning flashes down in a vertical stroke at whatever target point you choose within the spell’s range (measured from your position at the time). Any creature in the target square or in the path of the bolt is affected.

You need not call a bolt of lightning immediately; other actions, even spellcasting, can be performed. However, each round after the first you may use a standard action (concentrating on the spell) to call a bolt. You may call a total number of bolts equal to your caster level (maximum 10 bolts).

If you are outdoors and in a stormy area—a rain shower, clouds and wind, hot and cloudy conditions, or even a tornado (including a whirlwind formed by a djinni or an air elemental of at least Large size)—each bolt deals 3d10 points of electricity damage instead of 3d6.

This spell functions indoors or underground but not underwater.','{"class_levels":{"druid":3},"source_field_values":{"Level":"Drd 3","Components":"V, S","Casting Time":"1 round","Range":"Medium (100 ft. + 10 ft./level)","Effect":"One or more 30-ft.-long vertical lines of lightning","Duration":"1 min./level","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_call_lightning_storm','Call Lightning Storm','Drd 5',5,'Evocation [Electricity]','Long (400 ft. + 40 ft./level)',NULL,NULL,NULL,NULL,ARRAY['druid']::text[],'Evocation \[Electricity\]

Level: Drd 5

Range: Long (400 ft. + 40 ft./level)

This spell functions like call lightning, except that each bolt deals 5d6 points of electricity damage (or 5d10 if created outdoors in a stormy area), and you may call a maximum of 15 bolts.','{"class_levels":{"druid":5},"source_field_values":{"Level":"Drd 5","Range":"Long (400 ft. + 40 ft./level)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_calm_animals','Calm Animals','Animal 1, Drd 1, Rgr 1',1,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,'1 min./level','V, S',ARRAY['druid','ranger']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Animal 1, Drd 1, Rgr 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Targets: Animals within 30 ft. of each other

Duration: 1 min./level

Saving Throw: Will negates; see text

Spell Resistance: Yes

This spell soothes and quiets animals, rendering them docile and harmless. Only ordinary animals (those with Intelligence scores of 1 or 2) can be affected by this spell. All the subjects must be of the same kind, and no two may be more than 30 feet apart. The maximum number of Hit Dice of animals you can affect is equal to 2d4 + caster level. A dire animal or an animal trained to attack or guard is allowed a saving throw; other animals are not.

The affected creatures remain where they are and do not attack or flee. They are not helpless and defend themselves normally if attacked. Any threat breaks the spell on the threatened creatures.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Animal 1, Drd 1, Rgr 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"Animals within 30 ft. of each other","Duration":"1 min./level","Saving Throw":"Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_calm_emotions','Calm Emotions','Brd 2, Clr 2, Law 2',2,'Enchantment (Compulsion) [Mind-Affecting]','Medium (100 ft. + 10 ft./level)',NULL,'Creatures in a 20-ft.-radius spread','Concentration, up to 1 round/level (D)','V, S, DF',ARRAY['bard','cleric']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Brd 2, Clr 2, Law 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Creatures in a 20-ft.-radius spread

Duration: Concentration, up to 1 round/level (D)

Saving Throw: Will negates

Spell Resistance: Yes

This spell calms agitated creatures. You have no control over the affected creatures, but calm emotions can stop raging creatures from fighting or joyous ones from reveling. Creatures so affected cannot take violent actions (although they can defend themselves) or do anything destructive. Any aggressive action against or damage dealt to a calmed creature immediately breaks the spell on all calmed creatures.

This spell automatically suppresses (but does not dispel) any morale bonuses granted by spells such as bless, good hope, and rage, as well as negating a bard’s ability to inspire courage or a barbarian’s rage ability. It also suppresses any fear effects and removes the confused condition from all targets. While the spell lasts, a suppressed spell or effect has no effect. When the calm emotions spell ends, the original spell or effect takes hold of the creature again, provided that its duration has not expired in the meantime.','{"class_levels":{"bard":2,"cleric":2},"source_field_values":{"Level":"Brd 2, Clr 2, Law 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Creatures in a 20-ft.-radius spread","Duration":"Concentration, up to 1 round/level (D)","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cat_s_grace','Cat’s Grace','Brd 2, Drd 2, Rgr 2, Sor/Wiz 2',2,'Transmutation','Touch','Creature touched',NULL,'1 min./level','V, S, M',ARRAY['bard','druid','ranger','sorcerer','wizard']::text[],'Transmutation

Level: Brd 2, Drd 2, Rgr 2, Sor/Wiz 2

Components: V, S, M

Casting Time: 1 standard action

Range: Touch

Target: Creature touched

Duration: 1 min./level

Saving Throw: Will negates (harmless)

Spell Resistance: Yes

The transmuted creature becomes more graceful, agile, and coordinated. The spell grants a +4 enhancement bonus to Dexterity, adding the usual benefits to AC, Reflex saves, and other uses of the Dexterity modifier.

Material Component: A pinch of cat fur.','{"class_levels":{"bard":2,"druid":2,"ranger":2,"sorcerer":2,"wizard":2},"source_field_values":{"Level":"Brd 2, Drd 2, Rgr 2, Sor/Wiz 2","Components":"V, S, M","Casting Time":"1 standard action","Range":"Touch","Target":"Creature touched","Duration":"1 min./level","Saving Throw":"Will negates (harmless)","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cat_s_grace_mass','Cat’s Grace, Mass','Brd 6, Drd 6, Sor/Wiz 6',6,'Transmutation','Close (25 ft. + 5 ft./2 levels)',NULL,NULL,NULL,NULL,ARRAY['bard','druid','sorcerer','wizard']::text[],'Transmutation

Level: Brd 6, Drd 6, Sor/Wiz 6

Range: Close (25 ft. + 5 ft./2 levels)

Targets: One creature/level, no two of which can be more than 30 ft. apart

This spell functions like cat’s grace, except that it affects multiple creatures.','{"class_levels":{"bard":6,"druid":6,"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Brd 6, Drd 6, Sor/Wiz 6","Range":"Close (25 ft. + 5 ft./2 levels)","Targets":"One creature/level, no two of which can be more than 30 ft. apart"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cause_fear','Cause Fear','Brd 1, Clr 1, Death 1, Sor/Wiz 1',1,'Necromancy [Fear, Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature with 5 or fewer HD',NULL,'1d4 rounds or 1 round; see text','V, S',ARRAY['bard','cleric','sorcerer','wizard']::text[],'Necromancy \[Fear, Mind-Affecting\]

Level: Brd 1, Clr 1, Death 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature with 5 or fewer HD

Duration: 1d4 rounds or 1 round; see text

Saving Throw: Will partial

Spell Resistance: Yes

The affected creature becomes frightened. If the subject succeeds on a Will save, it is shaken for 1 round. Creatures with 6 or more Hit Dice are immune to this effect.

Cause fear counters and dispels remove fear.','{"class_levels":{"bard":1,"cleric":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Clr 1, Death 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature with 5 or fewer HD","Duration":"1d4 rounds or 1 round; see text","Saving Throw":"Will partial","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_chain_lightning','Chain Lightning','Air 6, Sor/Wiz 6',6,'Evocation [Electricity]','Long (400 ft. + 40 ft./level)',NULL,NULL,'Instantaneous','V, S, F',ARRAY['sorcerer','wizard']::text[],'Evocation \[Electricity\]

Level: Air 6, Sor/Wiz 6

Components: V, S, F

Casting Time: 1 standard action

Range: Long (400 ft. + 40 ft./level)

Targets: One primary target, plus one secondary target/level (each of which must be within 30 ft. of the primary target)

Duration: Instantaneous

Saving Throw: Reflex half

Spell Resistance: Yes

This spell creates an electrical discharge that begins as a single stroke commencing from your fingertips. Unlike lightning bolt, chain lightning strikes one object or creature initially, then arcs to other targets.

The bolt deals 1d6 points of electricity damage per caster level (maximum 20d6) to the primary target. After it strikes, lightning can arc to a number of secondary targets equal to your caster level (maximum 20). The secondary bolts each strike one target and deal half as much damage as the primary one did (rounded down).

Each target can attempt a Reflex saving throw for half damage. You choose secondary targets as you like, but they must all be within 30 feet of the primary target, and no target can be struck more than once. You can choose to affect fewer secondary targets than the maximum.

Focus: A bit of fur; a piece of amber, glass, or a crystal rod; plus one silver pin for each of your caster levels.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Air 6, Sor/Wiz 6","Components":"V, S, F","Casting Time":"1 standard action","Range":"Long (400 ft. + 40 ft./level)","Targets":"One primary target, plus one secondary target/level (each of which must be within 30 ft. of the primary target)","Duration":"Instantaneous","Saving Throw":"Reflex half","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_changestaff','Changestaff','Drd 7',7,'Transmutation','Touch','Your touched staff',NULL,'1 hour/level (D)','V, S, F',ARRAY['druid']::text[],'Transmutation

Level: Drd 7

Components: V, S, F

Casting Time: 1 round

Range: Touch

Target: Your touched staff

Duration: 1 hour/level (D)

Saving Throw: None

Spell Resistance: No

You change a specially prepared quarterstaff into a Huge treantlike creature, about 24 feet tall. When you plant the end of the staff in the ground and speak a special command to conclude the casting of the spell, your staff turns into a creature that looks and fights just like a treant. The staff-treant defends you and obeys any spoken commands. However, it is by no means a true treant; it cannot converse with actual treants or control trees. If the staff-treant is reduced to 0 or fewer hit points, it crumbles to powder and the staff is destroyed. Otherwise, the staff returns to its normal form when the spell duration expires (or when the spell is dismissed), and it can be used as the focus for another casting of the spell. The staff-treant is always at full strength when created, despite any wounds it may have incurred the last time it appeared.

Focus: The quarterstaff, which must be specially prepared. The staff must be a sound limb cut from an ash, oak, or yew, then cured, shaped, carved, and polished (a process requiring twenty-eight days).

You cannot adventure or engage in other strenuous activity during the shaping and carving of the staff.','{"class_levels":{"druid":7},"source_field_values":{"Level":"Drd 7","Components":"V, S, F","Casting Time":"1 round","Range":"Touch","Target":"Your touched staff","Duration":"1 hour/level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_charm_animal','Charm Animal','Drd 1, Rgr 1',1,'Enchantment (Charm) [Mind-Affecting]',NULL,'One animal',NULL,NULL,NULL,ARRAY['druid','ranger']::text[],'Enchantment (Charm) \[Mind-Affecting\]

Level: Drd 1, Rgr 1

Target: One animal

This spell functions like charm person, except that it affects a creature of the animal type.','{"class_levels":{"druid":1,"ranger":1},"source_field_values":{"Level":"Drd 1, Rgr 1","Target":"One animal"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_charm_monster','Charm Monster','Brd 3, Sor/Wiz 4',3,'Enchantment (Charm) [Mind-Affecting]',NULL,'One living creature',NULL,'One day/level',NULL,ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Charm) \[Mind-Affecting\]

Level: Brd 3, Sor/Wiz 4

Target: One living creature

Duration: One day/level

This spell functions like charm person, except that the effect is not restricted by creature type or size.','{"class_levels":{"bard":3,"sorcerer":4,"wizard":4},"source_field_values":{"Level":"Brd 3, Sor/Wiz 4","Target":"One living creature","Duration":"One day/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_charm_monster_mass','Charm Monster, Mass','Brd 6, Sor/Wiz 8',6,'Enchantment (Charm) [Mind-Affecting]',NULL,NULL,NULL,'One day/level','V',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Charm) \[Mind-Affecting\]

Level: Brd 6, Sor/Wiz 8

Components: V

Targets: One or more creatures, no two of which can be more than 30 ft. apart

Duration: One day/level

This spell functions like charm monster, except that mass charm monster affects a number of creatures whose combined HD do not exceed twice your level, or at least one creature regardless of HD. If there are more potential targets than you can affect, you choose them one at a time until you choose a creature with too many HD.','{"class_levels":{"bard":6,"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Brd 6, Sor/Wiz 8","Components":"V","Targets":"One or more creatures, no two of which can be more than 30 ft. apart","Duration":"One day/level"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_charm_person','Charm Person','Brd 1, Sor/Wiz 1',1,'Enchantment (Charm) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One humanoid creature',NULL,'1 hour/level','V, S',ARRAY['bard','sorcerer','wizard']::text[],'Enchantment (Charm) \[Mind-Affecting\]

Level: Brd 1, Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One humanoid creature

Duration: 1 hour/level

Saving Throw: Will negates

Spell Resistance: Yes

This charm makes a humanoid creature regard you as its trusted friend and ally (treat the target’s attitude as friendly). If the creature is currently being threatened or attacked by you or your allies, however, it receives a +5 bonus on its saving throw.

The spell does not enable you to control the charmed person as if it were an automaton, but it perceives your words and actions in the most favorable way. You can try to give the subject orders, but you must win an opposed Charisma check to convince it to do anything it wouldn’t ordinarily do. (Retries are not allowed.) An affected creature never obeys suicidal or obviously harmful orders, but it might be convinced that something very dangerous is worth doing. Any act by you or your apparent allies that threatens the charmed person breaks the spell. You must speak the person’s language to communicate your commands, or else be good at pantomiming.','{"class_levels":{"bard":1,"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Brd 1, Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One humanoid creature","Duration":"1 hour/level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_chill_metal','Chill Metal','Drd 2',2,'Transmutation [Cold]','Close (25 ft. + 5 ft./2 levels)','Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, none of which can be more than 30 ft. away from any of the rest',NULL,'7 rounds','V, S, DF',ARRAY['druid']::text[],'Transmutation \[Cold\]

Level: Drd 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, none of which can be more than 30 ft. away from any of the rest

Duration: 7 rounds

Saving Throw: Will negates (object)

Spell Resistance: Yes (object)

Chill metal makes metal extremely cold. Unattended, nonmagical metal gets no saving throw. Magical metal is allowed a saving throw against the spell. An item in a creature’s possession uses the creature’s saving throw bonus unless its own is higher.

A creature takes cold damage if its equipment is chilled. It takes full damage if its armor is affected or if it is holding, touching, wearing, or carrying metal weighing one-fifth of its weight. The creature takes minimum damage (1 point or 2 points; see the table) if it’s not wearing metal armor and the metal that it’s carrying weighs less than one-fifth of its weight.

On the first round of the spell, the metal becomes chilly and uncomfortable to touch but deals no damage. The same effect also occurs on the last round of the spell’s duration. During the second (and also the next-to-last) round, icy coldness causes pain and damage. In the third, fourth, and fifth rounds, the metal is freezing cold, causing more damage, as shown on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Round</th><th>Metal Temperature</th><th>Damage</th></tr><tr><td>1</td><td>Cold</td><td>None</td></tr><tr><td>2</td><td>Icy</td><td>1d4 points</td></tr><tr><td>3–5</td><td>Freezing</td><td>2d4 points</td></tr><tr><td>6</td><td>Icy</td><td>1d4 points</td></tr><tr><td>7</td><td>Cold</td><td>None</td></tr></tbody></table>

Any heat intense enough to damage the creature negates cold damage from the spell (and vice versa) on a point-for-point basis. Underwater, chill metal deals no damage, but ice immediately forms around the affected metal, making it more buoyant.

Chill metal counters and dispels heat metal.','{"class_levels":{"druid":2},"source_field_values":{"Level":"Drd 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"Metal equipment of one creature per two levels, no two of which can be more than 30 ft. apart; or 25 lb. of metal/level, none of which can be more than 30 ft. away from any of the rest","Duration":"7 rounds","Saving Throw":"Will negates (object)","Spell Resistance":"Yes (object)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_chill_touch','Chill Touch','Sor/Wiz 1',1,'Necromancy','Touch',NULL,NULL,'Instantaneous','V, S',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 1

Components: V, S

Casting Time: 1 standard action

Range: Touch

Targets: Creature or creatures touched (up to one/level)

Duration: Instantaneous

Saving Throw: Fortitude partial or Will negates; see text

Spell Resistance: Yes

A touch from your hand, which glows with blue energy, disrupts the life force of living creatures. Each touch channels negative energy that deals 1d6 points of damage. The touched creature also takes 1 point of Strength damage unless it makes a successful Fortitude saving throw. You can use this melee touch attack up to one time per level.

An undead creature you touch takes no damage of either sort, but it must make a successful Will saving throw or flee as if panicked for 1d4 rounds +1 round per caster level.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S","Casting Time":"1 standard action","Range":"Touch","Targets":"Creature or creatures touched (up to one/level)","Duration":"Instantaneous","Saving Throw":"Fortitude partial or Will negates; see text","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_circle_of_death','Circle of Death','Sor/Wiz 6',6,'Necromancy [Death]','Medium (100 ft. + 10 ft./level)',NULL,'Several living creatures within a 40-ft.-radius burst','Instantaneous','V, S, M',ARRAY['sorcerer','wizard']::text[],'Necromancy \[Death\]

Level: Sor/Wiz 6

Components: V, S, M

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Area: Several living creatures within a 40-ft.-radius burst

Duration: Instantaneous

Saving Throw: Fortitude negates

Spell Resistance: Yes

A circle of death snuffs out the life force of living creatures, killing them instantly.

The spell slays 1d4 HD worth of living creatures per caster level (maximum 20d4). Creatures with the fewest HD are affected first; among creatures with equal HD, those who are closest to the burst’s point of origin are affected first. No creature of 9 or more HD can be affected, and Hit Dice that are not sufficient to affect a creature are wasted.

Material Component: The powder of a crushed black pearl with a minimum value of 500 gp.','{"class_levels":{"sorcerer":6,"wizard":6},"source_field_values":{"Level":"Sor/Wiz 6","Components":"V, S, M","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Area":"Several living creatures within a 40-ft.-radius burst","Duration":"Instantaneous","Saving Throw":"Fortitude negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_clairaudience_clairvoyance','Clairaudience/Clairvoyance','Brd 3, Knowledge 3, Sor/Wiz 3',3,'Divination (Scrying)','Long (400 ft. + 40 ft./level)','Magical sensor',NULL,'1 min./level (D)','V, S, F/DF',ARRAY['bard','sorcerer','wizard']::text[],'Divination (Scrying)

Level: Brd 3, Knowledge 3, Sor/Wiz 3

Components: V, S, F/DF

Casting Time: 10 minutes

Range: Long (400 ft. + 40 ft./level)

Effect: Magical sensor

Duration: 1 min./level (D)

Saving Throw: None

Spell Resistance: No

Clairaudience/clairvoyance creates an invisible magical sensor at a specific location that enables you to hear or see (your choice) almost as if you were there. You don’t need line of sight or line of effect, but the locale must be known—a place familiar to you or an obvious one. Once you have selected the locale, the sensor doesn’t move, but you can rotate it in all directions to view the area as desired. Unlike other scrying spells, this spell does not allow magically or supernaturally enhanced senses to work through it. If the chosen locale is magically dark, you see nothing. If it is naturally pitch black, you can see in a 10- foot radius around the center of the spell’s effect. Clairaudience/clairvoyance functions only on the plane of existence you are currently occupying.

Arcane Focus: A small horn (for hearing) or a glass eye (for seeing).','{"class_levels":{"bard":3,"sorcerer":3,"wizard":3},"source_field_values":{"Level":"Brd 3, Knowledge 3, Sor/Wiz 3","Components":"V, S, F/DF","Casting Time":"10 minutes","Range":"Long (400 ft. + 40 ft./level)","Effect":"Magical sensor","Duration":"1 min./level (D)","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_clenched_fist','Clenched Fist','Sor/Wiz 8, Strength 8',8,'Evocation [Force]',NULL,NULL,NULL,NULL,'V, S, F/DF',ARRAY['sorcerer','wizard']::text[],'Evocation \[Force\]

Level: Sor/Wiz 8, Strength 8

Components: V, S, F/DF

This spell functions like interposing hand, except that the hand can interpose itself, push, or strike one opponent that you select. The floating hand can move as far as 60 feet and can attack in the same round. Since this hand is directed by you, its ability to notice or attack invisible or concealed creatures is no better than yours.

The hand attacks once per round, and its attack bonus equals your caster level + your Intelligence, Wisdom, or Charisma modifier (for a wizard, cleric, or sorcerer, respectively), +11 for the hand’s Strength score (33), –1 for being Large. The hand deals 1d8+11 points of damage on each attack, and any creature struck must make a Fortitude save (against this spell’s save DC) or be stunned for 1 round. Directing the spell to a new target is a move action.

The clenched fist can also interpose itself as interposing hand does, or it can bull rush an opponent as forceful hand does, but at a +15 bonus on the Strength check.

Clerics who cast this spell name it for their deities.

Arcane Focus: A leather glove.','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8, Strength 8","Components":"V, S, F/DF"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cloak_of_chaos','Cloak of Chaos','Chaos 8, Clr 8',8,'Abjuration [Chaotic]','20 ft.',NULL,NULL,'1 round/level (D)','V, S, F',ARRAY['cleric']::text[],'Abjuration \[Chaotic\]

Level: Chaos 8, Clr 8

Components: V, S, F

Casting Time: 1 standard action

Range: 20 ft.

Targets: One creature/level in a 20-ft.-radius burst centered on you

Duration: 1 round/level (D)

Saving Throw: See text

Spell Resistance: Yes (harmless)

A random pattern of color surrounds the subjects, protecting them from attacks, granting them resistance to spells cast by lawful creatures, and causing lawful creatures that strike the subjects to become confused. This abjuration has four effects.

First, each warded creature gains a +4 deflection bonus to AC and a +4 resistance bonus on saves. Unlike protection from law, the benefit of this spell applies against all attacks, not just against attacks by lawful creatures.

Second, each warded creature gains spell resistance 25 against lawful spells and spells cast by lawful creatures.

Third, the abjuration blocks possession and mental influence, just as protection from law does.

Finally, if a lawful creature succeeds on a melee attack against a warded creature, the offending attacker is confused for 1 round (Will save negates, as with the confusion spell, but against the save DC of cloak of chaos).

Focus: A tiny reliquary containing some sacred relic, such as a scrap of parchment from a chaotic text. The reliquary costs at least 500 gp.','{"class_levels":{"cleric":8},"source_field_values":{"Level":"Chaos 8, Clr 8","Components":"V, S, F","Casting Time":"1 standard action","Range":"20 ft.","Targets":"One creature/level in a 20-ft.-radius burst centered on you","Duration":"1 round/level (D)","Saving Throw":"See text","Spell Resistance":"Yes (harmless)"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_clone','Clone','Sor/Wiz 8',8,'Necromancy','0 ft.','One clone',NULL,'Instantaneous','V, S, M, F',ARRAY['sorcerer','wizard']::text[],'Necromancy

Level: Sor/Wiz 8

Components: V, S, M, F

Casting Time: 10 minutes

Range: 0 ft.

Effect: One clone

Duration: Instantaneous

Saving Throw: None

Spell Resistance: No

This spell makes an inert duplicate of a creature. If the original individual has been slain, its soul immediately transfers to the clone, creating a replacement (provided that the soul is free and willing to return). The original’s physical remains, should they still exist, become inert and cannot thereafter be restored to life. If the original creature has reached the end of its natural life span (that is, it has died of natural causes), any cloning attempt fails.

To create the duplicate, you must have a piece of flesh (not hair, nails, scales, or the like) with a volume of at least 1 cubic inch that was taken from the original creature’s living body. The piece of flesh need not be fresh, but it must be kept from rotting. Once the spell is cast, the duplicate must be grown in a laboratory for 2d4 months.

When the clone is completed, the original’s soul enters it immediately, if that creature is already dead. The clone is physically identical with the original and possesses the same personality and memories as the original. In other respects, treat the clone as if it were the original character raised from the dead, including the loss of one level or 2 points of Constitution (if the original was a 1st-level character). If this Constitution adjustment would give the clone a Constitution score of 0, the spell fails. If the original creature has lost levels since the flesh sample was taken and died at a lower level than the clone would otherwise be, the clone is one level below the level at which the original died.

The spell duplicates only the original’s body and mind, not its equipment.

A duplicate can be grown while the original still lives, or when the original soul is unavailable, but the resulting body is merely a soulless bit of inert flesh, which rots if not preserved.

Material Component: The piece of flesh and various laboratory supplies (cost 1,000 gp).

Focus: Special laboratory equipment (cost 500 gp).','{"class_levels":{"sorcerer":8,"wizard":8},"source_field_values":{"Level":"Sor/Wiz 8","Components":"V, S, M, F","Casting Time":"10 minutes","Range":"0 ft.","Effect":"One clone","Duration":"Instantaneous","Saving Throw":"None","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_cloudkill','Cloudkill','Sor/Wiz 5',5,'Conjuration (Creation)','Medium (100 ft. + 10 ft./level)','Cloud spreads in 20-ft. radius, 20 ft. high',NULL,'1 min./level','V, S',ARRAY['sorcerer','wizard']::text[],'Conjuration (Creation)

Level: Sor/Wiz 5

Components: V, S

Casting Time: 1 standard action

Range: Medium (100 ft. + 10 ft./level)

Effect: Cloud spreads in 20-ft. radius, 20 ft. high

Duration: 1 min./level

Saving Throw: Fortitude partial; see text

Spell Resistance: No

This spell generates a bank of fog, similar to a fog cloud, except that its vapors are yellowish green and poisonous. These vapors automatically kill any living creature with 3 or fewer HD (no save). A living creature with 4 to 6 HD is slain unless it succeeds on a Fortitude save (in which case it takes 1d4 points of Constitution damage on your turn each round while in the cloud).

A living creature with 6 or more HD takes 1d4 points of Constitution damage on your turn each round while in the cloud (a successful Fortitude save halves this damage). Holding one’s breath doesn’t help, but creatures immune to poison are unaffected by the spell.

Unlike a fog cloud, the cloudkill moves away from you at 10 feet per round, rolling along the surface of the ground.

Figure out the cloud’s new spread each round based on its new point of origin, which is 10 feet farther away from the point of origin where you cast the spell.

Because the vapors are heavier than air, they sink to the lowest level of the land, even pouring down den or sinkhole openings. It cannot penetrate liquids, nor can it be cast underwater.','{"class_levels":{"sorcerer":5,"wizard":5},"source_field_values":{"Level":"Sor/Wiz 5","Components":"V, S","Casting Time":"1 standard action","Range":"Medium (100 ft. + 10 ft./level)","Effect":"Cloud spreads in 20-ft. radius, 20 ft. high","Duration":"1 min./level","Saving Throw":"Fortitude partial; see text","Spell Resistance":"No"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_color_spray','Color Spray','Sor/Wiz 1',1,'Illusion (Pattern) [Mind-Affecting]','15 ft.',NULL,'Cone-shaped burst','Instantaneous; see text','V, S, M',ARRAY['sorcerer','wizard']::text[],'Illusion (Pattern) \[Mind-Affecting\]

Level: Sor/Wiz 1

Components: V, S, M

Casting Time: 1 standard action

Range: 15 ft.

Area: Cone-shaped burst

Duration: Instantaneous; see text

Saving Throw: Will negates

Spell Resistance: Yes

A vivid cone of clashing colors springs forth from your hand, causing creatures to become stunned, perhaps also blinded, and possibly knocking them unconscious.

Each creature within the cone is affected according to its Hit Dice.

2 HD or less: The creature is unconscious, blinded, and stunned for 2d4 rounds, then blinded and stunned for 1d4 rounds, and then stunned for 1 round. (Only living creatures are knocked unconscious.)

3 or 4 HD: The creature is blinded and stunned for 1d4 rounds, then stunned for 1 round.

5 or more HD: The creature is stunned for 1 round.

Sightless creatures are not affected by color spray.

Material Component: A pinch each of powder or sand that is colored red, yellow, and blue.','{"class_levels":{"sorcerer":1,"wizard":1},"source_field_values":{"Level":"Sor/Wiz 1","Components":"V, S, M","Casting Time":"1 standard action","Range":"15 ft.","Area":"Cone-shaped burst","Duration":"Instantaneous; see text","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md'),
('srd35_spell_command','Command','Clr 1',1,'Enchantment (Compulsion) [Language-Dependent, Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)','One living creature',NULL,'1 round','V',ARRAY['cleric']::text[],'Enchantment (Compulsion) \[Language-Dependent, Mind-Affecting\]

Level: Clr 1

Components: V

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Target: One living creature

Duration: 1 round

Saving Throw: Will negates

Spell Resistance: Yes

You give the subject a single command, which it obeys to the best of its ability at its earliest opportunity. You may select from the following options.

Approach: On its turn, the subject moves toward you as quickly and directly as possible for 1 round. The creature may do nothing but move during its turn, and it provokes attacks of opportunity for this movement as normal.

Drop: On its turn, the subject drops whatever it is holding. It can’t pick up any dropped item until its next turn.

Fall: On its turn, the subject falls to the ground and remains prone for 1 round. It may act normally while prone but takes any appropriate penalties.

Flee: On its turn, the subject moves away from you as quickly as possible for 1 round. It may do nothing but move during its turn, and it provokes attacks of opportunity for this movement as normal.

Halt: The subject stands in place for 1 round. It may not take any actions but is not considered helpless.

If the subject can’t carry out your command on its next turn, the spell automatically fails.','{"class_levels":{"cleric":1},"source_field_values":{"Level":"Clr 1","Components":"V","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Target":"One living creature","Duration":"1 round","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-c.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
