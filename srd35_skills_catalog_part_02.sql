-- SRD 3.5 Skills: Open Game Content under OGL 1.0a.
-- Sources: https://github.com/olimot/srd-v3.5-md/tree/main/basic-rules-and-legal
insert into public.srd_skills(id,nome,atributo,treinada_apenas,penalidade_armadura,descricao,srd_source_url,dados_tecnicos) values
('procurar','Procurar','INT',false,false,'Check: You generally must be within 10 feet of the object or surface to be searched. The table below gives DCs for typical tasks involving the Search skill.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Task</th><th>Search DC</th></tr><tr><td>Ransack a chest full of junk to find a certain item</td><td>10</td></tr><tr><td>Notice a typical secret door or a simple trap</td><td>20</td></tr><tr><td>Find a difficult nonmagical trap (rogue only)<sup>1</sup></td><td>21 or higher</td></tr><tr><td>Find a magic trap (rogue only)<sup>1</sup></td><td>25 + level of spell used to create trap</td></tr><tr><td>Notice a well-hidden secret door</td><td>30</td></tr><tr><td>Find a footprint</td><td>Varies<sup>2</sup></td></tr><tr><td colspan="2">1 Dwarves (even if they are not rogues) can use Search to find traps built into or out of stone.</td></tr><tr><td colspan="2">2 A successful Search check can find a footprint or similar sign of a creature’s passage, but it won’t let you find or follow a trail. See the Track feat for the appropriate DC.</td></tr></tbody></table>

Action: It takes a full-round action to search a 5-foot-by-5-foot area or a volume of goods 5 feet on a side.

Special: An elf has a +2 racial bonus on Search checks, and a half-elf has a +1 racial bonus. An elf (but not a half-elf) who simply passes within 5 feet of a secret or concealed door can make a Search check to find that door.

If you have the Investigator feat, you get a +2 bonus on Search checks.

The spells explosive runes, fire trap, glyph of warding, symbol, and teleportation circle create magic traps that a rogue can find by making a successful Search check and then can attempt to disarm by using Disable Device. Identifying the location of a snare spell has a DC of 23. Spike growth and spike stones create magic traps that can be found using Search, but against which Disable Device checks do not succeed. See the individual spell descriptions for details.

Active abjuration spells within 10 feet of each other for 24 hours or more create barely visible energy fluctuations. These fluctuations give you a +4 bonus on Search checks to locate such abjuration spells.

Synergy: If you have 5 or more ranks in Search, you get a +2 bonus on Survival checks to find or follow tracks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks to find secret doors or hidden compartments.

Restriction: While anyone can use Search to find a trap whose DC is 20 or lower, only a rogue can use Search to locate traps with higher DCs. (Exception: The spell find traps temporarily enables a cleric to use the Search skill as if he were a rogue.)

A dwarf, even one who is not a rogue, can use the Search skill to find a difficult trap (one with a DC higher than 20) if the trap is built into or out of stone. He gains a +2 racial bonus on the Search check from his stonecunning ability.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Search","source_heading":"Int"}'::jsonb),
('sentir_motivacao','Sentir Motivação','SAB',false,false,'Check: A successful check lets you avoid being bluffed (see the Bluff skill). You can also use this skill to determine when “something is up” (that is, something odd is going on) or to assess someone’s trustworthiness.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Task</th><th>Sense Motive DC</th></tr><tr><td>Hunch</td><td>20</td></tr><tr><td>Sense enchantment</td><td>25 or 15</td></tr><tr><td>Discern secret message</td><td>Varies</td></tr></tbody></table>

Hunch: This use of the skill involves making a gut assessment of the social situation. You can get the feeling from another’s behavior that something is wrong, such as when you’re talking to an impostor. Alternatively, you can get the feeling that someone is trustworthy.

Sense Enchantment: You can tell that someone’s behavior is being influenced by an enchantment effect (by definition, a mind-affecting effect),even if that person isn’t aware of it. The usual DC is 25, but if the target is dominated (see dominate person), the DC is only 15 because of the limited range of the target’s activities.

Discern Secret Message: You may use Sense Motive to detect that a hidden message is being transmitted via the Bluff skill. In this case, your Sense Motive check is opposed by the Bluff check of the character transmitting the message. For each piece of information relating to the message that you are missing, you take a –2 penalty on your Sense Motive check. If you succeed by 4 or less, you know that something hidden is being communicated, but you can’t learn anything specific about its content. If you beat the DC by 5 or more, you intercept and understand the message. If you fail by 4 or less, you don’t detect any hidden communication. If you fail by 5 or more, you infer some false information.

Action: Trying to gain information with Sense Motive generally takes at least 1 minute, and you could spend a whole evening trying to get a sense of the people around you.

Try Again: No, though you may make a Sense Motive check for each Bluff check made against you.

Special: A ranger gains a bonus on Sense Motive checks when using this skill against a favored enemy.

If you have the Negotiator feat, you get a +2 bonus on Sense Motive checks.

Synergy: If you have 5 or more ranks in Sense Motive, you get a +2 bonus on Diplomacy checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Sense Motive","source_heading":"Wis"}'::jsonb),
('prestidigitacao','Prestidigitação','DES',true,true,'Check: A DC 10 Sleight of Hand check lets you palm a coin-sized, unattended object. Performing a minor feat of legerdemain, such as making a coin disappear, also has a DC of 10 unless an observer is determined to note where the item went.

When you use this skill under close observation, your skill check is opposed by the observer’s Spot check. The observer’s success doesn’t prevent you from performing the action, just from doing it unnoticed.

You can hide a small object (including a light weapon or an easily concealed ranged weapon, such as a dart, sling, or hand crossbow) on your body. Your Sleight of Hand check is opposed by the Spot check of anyone observing you or the Search check of anyone frisking you. In the latter case, the searcher gains a +4 bonus on the Search check, since it’s generally easier to find such an object than to hide it. A dagger is easier to hide than most light weapons, and grants you a +2 bonus on your Sleight of Hand check to conceal it. An extraordinarily small object, such as a coin, shuriken, or ring, grants you a +4 bonus on your Sleight of Hand check to conceal it, and heavy or baggy clothing (such as a cloak) grants you a +2 bonus on the check.

Drawing a hidden weapon is a standard action and doesn’t provoke an attack of opportunity.

If you try to take something from another creature, you must make a DC 20 Sleight of Hand check to obtain it. The opponent makes a Spot check to detect the attempt, opposed by the same Sleight of Hand check result you achieved when you tried to grab the item. An opponent who succeeds on this check notices the attempt, regardless of whether you got the item.

You can also use Sleight of Hand to entertain an audience as though you were using the Perform skill. In such a case, your “act” encompasses elements of legerdemain, juggling, and the like.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Sleight of Hand DC</th><th>Task</th></tr><tr><td>10</td><td>Palm a coin-sized object, make a coin disappear</td></tr><tr><td>20</td><td>Lift a small object from a person</td></tr></tbody></table>

Action: Any Sleight of Hand check normally is a standard action. However, you may perform a Sleight of Hand check as a free action by taking a –20 penalty on the check.

Try Again: Yes, but after an initial failure, a second Sleight of Hand attempt against the same target (or while you are being watched by the same observer who noticed your previous attempt) increases the DC for the task by 10.

Special: If you have the Deft Hands feat, you get a +2 bonus on Sleight of Hand checks.

Synergy: If you have 5 or more ranks in Bluff, you get a +2 bonus on Sleight of Hand checks.

Untrained: An untrained Sleight of Hand check is simply a Dexterity check. Without actual training, you can’t succeed on any Sleight of Hand check with a DC higher than 10, except for hiding an object on your body.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Sleight of Hand","source_heading":"Dex; Trained Only; Armor Check Penalty"}'::jsonb),
('srd35_skill_speak_language','Falar Idioma','INT',true,false,'<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="3">Common Languages and Their Alphabets</th></tr><tr><th>Language</th><th>Typical Speakers</th><th>Alphabet</th></tr><tr><td>Abyssal</td><td>Demons, chaotic evil outsiders</td><td>Infernal</td></tr><tr><td>Aquan</td><td>Water-based creatures</td><td>Elven</td></tr><tr><td>Auran</td><td>Air-based creatures</td><td>Draconic</td></tr><tr><td>Celestial</td><td>Good outsiders</td><td>Celestial</td></tr><tr><td>Common</td><td>Humans, halflings, half-elves, half-orcs</td><td>Common</td></tr><tr><td>Draconic</td><td>Kobolds, troglodytes, lizardfolk, dragons</td><td>Draconic</td></tr><tr><td>Druidic</td><td>Druids (only)</td><td>Druidic</td></tr><tr><td>Dwarven</td><td>Dwarves</td><td>Dwarven</td></tr><tr><td>Elven</td><td>Elves</td><td>Elven</td></tr><tr><td>Giant</td><td>Ogres, giants</td><td>Dwarven</td></tr><tr><td>Gnome</td><td>Gnomes</td><td>Dwarven</td></tr><tr><td>Goblin</td><td>Goblins, hobgoblins, bugbears</td><td>Dwarven</td></tr><tr><td>Gnoll</td><td>Gnolls</td><td>Common</td></tr><tr><td>Halfling</td><td>Halflings</td><td>Common</td></tr><tr><td>Ignan</td><td>Fire-based creatures</td><td>Draconic</td></tr><tr><td>Infernal</td><td>Devils, lawful evil outsiders</td><td>Infernal</td></tr><tr><td>Orc</td><td>Orcs</td><td>Dwarven</td></tr><tr><td>Sylvan</td><td>Dryads, brownies, leprechauns</td><td>Elven</td></tr><tr><td>Terran</td><td>Xorns and other earth-based creatures</td><td>Dwarven</td></tr><tr><td>Undercommon</td><td>Drow</td><td>Elven</td></tr></tbody></table>

Action: Not applicable.

Try Again: Not applicable. There are no Speak Language checks to fail.

The Speak Language skill doesn’t work like other skills. Languages work as follows.

- You start at 1st level knowing one or two languages (based on your race), plus an additional number of languages equal to your starting Intelligence bonus.
- You can purchase Speak Language just like any other skill, but instead of buying a rank in it, you choose a new language that you can speak.
- You don’t make Speak Language checks. You either know a language or you don’t.
- A literate character (anyone but a barbarian who has not spent skill points to become literate) can read and write any language she speaks. Each language has an alphabet, though sometimes several spoken languages share a single alphabet.

## Spellcraft (Int; Trained Only)

Use this skill to identify spells as they are cast or spells already in place.

<table class="full-width-table" data-debug="no-caption"><tbody><tr><th>Spellcraft DC</th><th>Task</th></tr><tr><td>13</td><td>When using <i>read magic,</i> identify a <i>glyph of warding.</i> No action required.</td></tr><tr><td>15 + spell level</td><td>Identify a spell being cast. (You must see or hear the spell’s verbal or somatic components.) No action required. No retry.</td></tr><tr><td>15 + spell level</td><td>Learn a spell from a spellbook or scroll (wizard only). No retry for that spell until you gain at least 1 rank in Spellcraft (even if you find another source to try to learn the spell from). Requires 8 hours.</td></tr><tr><td>15 + spell level</td><td>Prepare a spell from a borrowed spellbook (wizard only). One try per day. No extra time required.</td></tr><tr><td>15 + spell level</td><td>When casting <i>detect magic,</i> determine the school of magic involved in the aura of a single item or creature you can see. (If the aura is not a spell effect, the DC is 15 + one-half caster level.) No action required.</td></tr><tr><td>19</td><td>When using <i>read magic,</i> identify a <i>symbol.</i> No action required.</td></tr><tr><td>20 + spell level</td><td>Identify a spell that’s already in place and in effect. You must be able to see or detect the effects of the spell. No action required. No retry.</td></tr><tr><td>20 + spell level</td><td>Identify materials created or shaped by magic, such as noting that an iron wall is the result of a <i>wall of iron</i> spell. No action required. No retry.</td></tr><tr><td>20 + spell level</td><td>Decipher a written spell (such as a scroll) without using <i>read magic.</i> One try per day. Requires a full-round action.</td></tr><tr><td>25 + spell level</td><td>After rolling a saving throw against a spell targeted on you, determine what that spell was. No action required. No retry.</td></tr><tr><td>25</td><td>Identify a potion. Requires 1 minute. No retry.</td></tr><tr><td>20</td><td>Draw a diagram to allow <i>dimensional anchor</i> to be cast on a <i>magic circle</i> spell. Requires 10 minutes. No retry. This check is made secretly so you do not know the result.</td></tr><tr><td>30 or higher</td><td>Understand a strange or unique magical effect, such as the effects of a magic stream. Time required varies. No retry.</td></tr></tbody></table>

Check: You can identify spells and magic effects. The DCs for Spellcraft checks relating to various tasks are summarized on the table above.

Action: Varies, as noted above.

Try Again: See above.

Special: If you are a specialist wizard, you get a +2 bonus on Spellcraft checks when dealing with a spell or effect from your specialty school. You take a –5 penalty when dealing with a spell or effect from a prohibited school (and some tasks, such as learning a prohibited spell, are just impossible).

If you have the Magical Aptitude feat, you get a +2 bonus on Spellcraft checks.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Use Magic Device, you get a +2 bonus on Spellcraft checks to decipher spells on scrolls.

If you have 5 or more ranks in Spellcraft, you get a +2 bonus on Use Magic Device checks related to scrolls.

Additionally, certain spells allow you to gain information about magic, provided that you make a successful Spellcraft check as detailed in the spell description.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Speak Language","source_heading":"None; Trained Only"}'::jsonb),
('observar','Observar','SAB',false,false,'Check: The Spot skill is used primarily to detect characters or creatures who are hiding. Typically, your Spot check is opposed by the Hide check of the creature trying not to be seen. Sometimes a creature isn’t intentionally hiding but is still difficult to see, so a successful Spot check is necessary to notice it.

A Spot check result higher than 20 generally lets you become aware of an invisible creature near you, though you can’t actually see it.

Spot is also used to detect someone in disguise (see the Disguise skill), and to read lips when you can’t hear or understand what someone is saying.

Spot checks may be called for to determine the distance at which an encounter begins. A penalty applies on such checks, depending on the distance between the two individuals or groups, and an additional penalty may apply if the character making the Spot check is distracted (not concentrating on being observant).

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Condition</th><th>Penalty</th></tr><tr><td>Per 10 feet of distance</td><td>–1</td></tr><tr><td>Spotter distracted</td><td>–5</td></tr></tbody></table>

Read Lips: To understand what someone is saying by reading lips, you must be within 30 feet of the speaker, be able to see him or her speak, and understand the speaker’s language. (This use of the skill is language-dependent.) The base DC is 15, but it increases for complex speech or an inarticulate speaker. You must maintain a line of sight to the lips being read.

If your Spot check succeeds, you can understand the general content of a minute’s worth of speaking, but you usually still miss certain details. If the check fails by 4 or less, you can’t read the speaker’s lips. If the check fails by 5 or more, you draw some incorrect conclusion about the speech. The check is rolled secretly in this case, so that you don’t know whether you succeeded or missed by 5.

Action: Varies. Every time you have a chance to spot something in a reactive manner you can make a Spot check without using an action. Trying to spot something you failed to see previously is a move action. To read lips, you must concentrate for a full minute before making a Spot check, and you can’t perform any other action (other than moving at up to half speed) during this minute.

Try Again: Yes. You can try to spot something that you failed to see previously at no penalty. You can attempt to read lips once per minute.

Special: A fascinated creature takes a –4 penalty on Spot checks made as reactions.

If you have the Alertness feat, you get a +2 bonus on Spot checks.

A ranger gains a bonus on Spot checks when using this skill against a favored enemy.

An elf has a +2 racial bonus on Spot checks.

A half-elf has a +1 racial bonus on Spot checks.

The master of a hawk familiar gains a +3 bonus on Spot checks in daylight or other lighted areas.

The master of an owl familiar gains a +3 bonus on Spot checks in shadowy or other darkened areas.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Spot","source_heading":"Wis"}'::jsonb),
('sobrevivencia','Sobrevivência','SAB',false,false,'Check: You can keep yourself and others safe and fed in the wild. The table below gives the DCs for various tasks that require Survival checks.

Survival does not allow you to follow difficult tracks unless you are a ranger or have the Track feat (see the Restriction section below).

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Survival DC</th><th>Task</th></tr><tr><td>10</td><td>Get along in the wild. Move up to one-half your overland speed while hunting and foraging (no food or water supplies needed). You can provide food and water for one other person for every 2 points by which your check result exceeds 10.</td></tr><tr><td>15</td><td>Gain a +2 bonus on all Fortitude saves against severe weather while moving up to one-half your overland speed, or gain a +4 bonus if you remain stationary. You may grant the same bonus to one other character for every 1 point by which your Survival check result exceeds 15.</td></tr><tr><td>15</td><td>Keep from getting lost or avoid natural hazards, such as quicksand.</td></tr><tr><td>15</td><td>Predict the weather up to 24 hours in advance. For every 5 points by which your Survival check result exceeds 15, you can predict the weather for one additional day in advance.</td></tr><tr><td>Varies</td><td>Follow tracks (see the Track feat).</td></tr></tbody></table>

Action: Varies. A single Survival check may represent activity over the course of hours or a full day. A Survival check made to find tracks is at least a full-round action, and it may take even longer.

Try Again: Varies. For getting along in the wild or for gaining the Fortitude save bonus noted in the table above, you make a Survival check once every 24 hours. The result of that check applies until the next check is made. To avoid getting lost or avoid natural hazards, you make a Survival check whenever the situation calls for one. Retries to avoid getting lost in a specific situation or to avoid a specific natural hazard are not allowed. For finding tracks, you can retry a failed check after 1 hour (outdoors) or 10 minutes(indoors) of searching.

Restriction: While anyone can use Survival to find tracks (regardless of the DC), or to follow tracks when the DC for the task is 10 or lower, only a ranger (or a character with the Track feat) can use Survival to follow tracks when the task has a higher DC.

Special: If you have 5 or more ranks in Survival, you can automatically determine where true north lies in relation to yourself.

A ranger gains a bonus on Survival checks when using this skill to find or follow the tracks of a favored enemy.

If you have the Self-Sufficient feat, you get a +2 bonus on Survival checks.

Synergy: If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, and plains).

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Search, you get a +2 bonus on Survival checks to find or follow tracks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Survival","source_heading":"Wis"}'::jsonb),
('natacao','Natação','FOR',false,true,'Check: Make a Swim check once per round while you are in the water. Success means you may swim at up to one-half your speed (as a full-round action) or at one-quarter your speed (as a move action). If you fail by 4 or less, you make no progress through the water. If you fail by 5 or more, you go underwater.

If you are underwater, either because you failed a Swim check or because you are swimming underwater intentionally, you must hold your breath. You can hold your breath for a number of rounds equal to your Constitution score, but only if you do nothing other than take move actions or free actions. If you take a standard action or a full-round action (such as making an attack), the remainder of the duration for which you can hold your breath is reduced by 1 round. (Effectively, a character in combat can hold his or her breath only half as long as normal.) After that period of time, you must make a DC 10 Constitution check every round to continue holding your breath. Each round, the DC for that check increases by 1. If you fail the Constitution check, you begin to drown.

The DC for the Swim check depends on the water, as given on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Water</th><th>Swim DC</th></tr><tr><td>Calm water</td><td>10</td></tr><tr><td>Rough water</td><td>15</td></tr><tr><td>Stormy water</td><td>20<sup>1</sup></td></tr><tr><td colspan="2">1 You can’t take 10 on a Swim check in stormy water, even if you aren’t otherwise being threatened or distracted.</td></tr></tbody></table>

Each hour that you swim, you must make a DC 20 Swim check or take 1d6 points of nonlethal damage from fatigue.

Action: A successful Swim check allows you to swim one-quarter of your speed as a move action or one-half your speed as a full-round action.

Special: Swim checks are subject to double the normal armor check penalty and encumbrance penalty.

If you have the Athletic feat, you get a +2 bonus on Swim checks.

If you have the Endurance feat, you get a +4 bonus on Swim checks made to avoid taking nonlethal damage from fatigue.

A creature with a swim speed can move through water at its indicated speed without making Swim checks. It gains a +8 racial bonus on any Swim check to perform a special action or avoid a hazard. The creature always can choose to take 10 on a Swim check, even if distracted or endangered when swimming. Such a creature can use the run action while swimming, provided that it swims in a straight line.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Swim","source_heading":"Str; Armor Check Penalty"}'::jsonb),
('acrobacia','Acrobacia','DES',true,true,'You can’t use this skill if your speed has been reduced by armor, excess equipment, or loot.

Check: You can land softly when you fall or tumble past opponents. You can also tumble to entertain an audience (as though using the Perform skill). The DCs for various tasks involving the Tumble skill are given on the table below.

<table class="full-width-table" data-debug="no-caption"><tbody><tr><th>Tumble DC</th><th>Task</th></tr><tr><td>15</td><td>Treat a fall as if it were 10 feet shorter than it really is when determining damage.</td></tr><tr><td>15</td><td>Tumble at one-half speed as part of normal movement, provoking no attacks of opportunity while doing so. Failure means you provoke attacks of opportunity normally. Check separately for each opponent you move past, in the order in which you pass them (player’s choice of order in case of a tie).<br>Each additional enemy after the first adds +2 to the Tumble DC.</td></tr><tr><td>25</td><td>Tumble at one-half speed through an area occupied by an enemy (over, under, or around the opponent) as part of normal movement, provoking no attacks of opportunity while doing so. Failure means you stop before entering the enemy-occupied area and provoke an attack of opportunity from that enemy.<br>Check separately for each opponent. Each additional enemy after the first adds +2 to the Tumble DC.</td></tr></tbody></table>

Obstructed or otherwise treacherous surfaces, such as natural cavern floors or undergrowth, are tough to tumble through. The DC for any Tumble check made to tumble into such a square is modified as indicated below.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Surface Is . . .</th><th>DC Modifier</th></tr><tr><td>Lightly obstructed (scree, light rubble, shallow bog<sup>1</sup>, undergrowth)</td><td>+2</td></tr><tr><td>Severely obstructed (natural cavern floor, dense rubble, dense undergrowth)</td><td>+5</td></tr><tr><td>Lightly slippery (wet floor)</td><td>+2</td></tr><tr><td>Severely slippery (ice sheet)</td><td>+5</td></tr><tr><td>Sloped or angled</td><td>+2</td></tr><tr><td colspan="2">1 Tumbling is impossible in a deep bog.</td></tr></tbody></table>

Accelerated Tumbling: You try to tumble past or through enemies more quickly than normal. By accepting a –10 penalty on your Tumble checks, you can move at your full speed instead of one-half your speed.

Action: Not applicable. Tumbling is part of movement, so a Tumble check is part of a move action.

Try Again: Usually no. An audience, once it has judged a tumbler as an uninteresting performer, is not receptive to repeat performances.

You can try to reduce damage from a fall as an instant reaction only once per fall.

Special: If you have 5 or more ranks in Tumble, you gain a +3 dodge bonus to AC when fighting defensively instead of the usual +2 dodge bonus to AC.

If you have 5 or more ranks in Tumble, you gain a +6 dodge bonus to AC when executing the total defense standard action instead of the usual +4 dodge bonus to AC.

If you have the Acrobatic feat, you get a +2 bonus on Tumble checks.

Synergy: If you have 5 or more ranks in Tumble, you get a +2 bonus on Balance and Jump checks.

If you have 5 or more ranks in Jump, you get a +2 bonus on Tumble checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Tumble","source_heading":"Dex; Trained Only; Armor Check Penalty"}'::jsonb),
('usar_instrumento_magico','Usar Instrumento Mágico','CAR',true,false,'Use this skill to activate magic

Check: You can use this skill to read a spell or to activate a magic item. Use Magic Device lets you use a magic item as if you had the spell ability or class features of another class, as if you were a different race, or as if you were of a different alignment.

You make a Use Magic Device check each time you activate a device such as a wand. If you are using the check to emulate an alignment or some other quality in an ongoing manner, you need to make the relevant Use Magic Device check once per hour.

You must consciously choose which requirement to emulate. That is, you must know what you are trying to emulate when you make a Use Magic Device check for that purpose. The DCs for various tasks involving Use Magic Device checks are summarized on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Task</th><th>Use Magic Device DC</th></tr><tr><td>Activate blindly</td><td>25</td></tr><tr><td>Decipher a written spell</td><td>25 + spell level</td></tr><tr><td>Use a scroll</td><td>20 + caster level</td></tr><tr><td>Use a wand</td><td>20</td></tr><tr><td>Emulate a class feature</td><td>20</td></tr><tr><td>Emulate an ability score</td><td>See text</td></tr><tr><td>Emulate a race</td><td>25</td></tr><tr><td>Emulate an alignment</td><td>30</td></tr></tbody></table>

Activate Blindly: Some magic items are activated by special words, thoughts, or actions. You can activate such an item as if you were using the activation word, thought, or action, even when you’re not and even if you don’t know it. You do have to perform some equivalent activity in order to make the check. That is, you must speak, wave the item around, or otherwise attempt to get it to activate. You get a special +2 bonus on your Use Magic Device check if you’ve activated the item in question at least once before. If you fail by 9 or less, you can’t activate the device. If you fail by 10 or more, you suffer a mishap. A mishap means that magical energy gets released but it doesn’t do what you wanted it to do. The default mishaps are that the item affects the wrong target or that uncontrolled magical energy is released, dealing 2d6 points of damage to you. This mishap is in addition to the chance for a mishap that you normally run when you cast a spell from a scroll that you could not otherwise cast yourself.

Decipher a Written Spell: This usage works just like deciphering a written spell with the Spellcraft skill, except that the DC is 5 points higher. Deciphering a written spell requires 1 minute of concentration.

Emulate an Ability Score: To cast a spell from a scroll, you need a high score in the appropriate ability (Intelligence for wizard spells, Wisdom for divine spells, or Charisma for sorcerer or bard spells). Your effective ability score (appropriate to the class you’re emulating when you try to cast the spell from the scroll) is your Use Magic Device check result minus 15. If you already have a high enough score in the appropriate ability, you don’t need to make this check.

Emulate an Alignment: Some magic items have positive or negative effects based on the user’s alignment. Use Magic Device lets you use these items as if you were of an alignment of your choice. You can emulate only one alignment at a time.

Emulate a Class Feature: Sometimes you need to use a class feature to activate a magic item. In this case, your effective level in the emulated class equals your Use Magic Device check result minus 20. This skill does not let you actually use the class feature of another class. It just lets you activate items as if you had that class feature. If the class whose feature you are emulating has an alignment requirement, you must meet it, either honestly or by emulating an appropriate alignment with a separate Use Magic Device check (see above).

Emulate a Race: Some magic items work only for members of certain races, or work better for members of those races. You can use such an item as if you were a race of your choice. You can emulate only one race at a time.

Use a Scroll: If you are casting a spell from a scroll, you have to decipher it first. Normally, to cast a spell from a scroll, you must have the scroll’s spell on your class spell list. Use Magic Device allows you to use a scroll as if you had a particular spell on your class spell list. The DC is equal to 20 + the caster level of the spell you are trying to cast from the scroll. In addition, casting a spell from a scroll requires a minimum score (10 + spell level) in the appropriate ability. If you don’t have a sufficient score in that ability, you must emulate the ability score with a separate Use Magic Device check (see above).

This use of the skill also applies to other spell completion magic items.

Use a Wand: Normally, to use a wand, you must have the wand’s spell on your class spell list. This use of the skill allows you to use a wand as if you had a particular spell on your class spell list. This use of the skill also applies to other spell trigger magic items, such as staffs.

Action: None. The Use Magic Device check is made as part of the action (if any) required to activate the magic item.

Try Again: Yes, but if you ever roll a natural 1 while attempting to activate an item and you fail, then you can’t try to activate that item again for 24 hours.

Special: You cannot take 10 with this skill.

You can’t aid another on Use Magic Device checks. Only the user of the item may attempt such a check.

If you have the Magical Aptitude feat, you get a +2 bonus on Use Magic Device checks.

Synergy: If you have 5 or more ranks in Spellcraft, you get a +2 bonus on Use Magic Device checks related to scrolls.

If you have 5 or more ranks in Decipher Script, you get a +2 bonus on Use Magic Device checks related to scrolls.

If you have 5 or more ranks in Use Magic Device, you get a +2 bonus to Spellcraft checks made to decipher spells on scrolls.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Use Magic Device","source_heading":"Cha; Trained Only"}'::jsonb),
('srd35_skill_use_rope','Usar Cordas','DES',false,false,'Check: Most tasks with a rope are relatively simple. The DCs for various tasks utilizing this skill are summarized on the table below.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Use Rope DC</th><th>Task</th></tr><tr><td>10</td><td>Tie a firm knot</td></tr><tr><td>10<sup>1</sup></td><td>Secure a grappling hook</td></tr><tr><td>15</td><td>Tie a special knot, such as one that slips, slides slowly, or loosens with a tug</td></tr><tr><td>15</td><td>Tie a rope around yourself one-handed</td></tr><tr><td>15</td><td>Splice two ropes together</td></tr><tr><td>Varies</td><td>Bind a character</td></tr><tr><td colspan="2">1 Add 2 to the DC for every 10 feet the hook is thrown; see below.</td></tr></tbody></table>

Secure a Grappling Hook: Securing a grappling hook requires a Use Rope check (DC 10, +2 for every 10 feet of distance the grappling hook is thrown, to a maximum DC of 20 at 50 feet). Failure by 4 or less indicates that the hook fails to catch and falls, allowing you to try again. Failure by 5 or more indicates that the grappling hook initially holds, but comes loose after 1d4 rounds of supporting weight. This check is made secretly, so that you don’t know whether the rope will hold your weight.

Bind a Character: When you bind another character with a rope, any Escape Artist check that the bound character makes is opposed by your Use Rope check.

You get a +10 bonus on this check because it is easier to bind someone than to escape from bonds. You don’t even make your Use Rope check until someone tries to escape.

Action: Varies. Throwing a grappling hook is a standard action that provokes an attack of opportunity. Tying a knot, tying a special knot, or tying a rope around yourself one-handed is a full-round action that provokes an attack of opportunity. Splicing two ropes together takes 5 minutes. Binding a character takes 1 minute.

Special: A silk rope gives you a +2 circumstance bonus on Use Rope checks. If you cast an animate rope spell on a rope, you get a +2 circumstance bonus on any Use Rope checks you make when using that rope.

These bonuses stack.

If you have the Deft Hands feat, you get a +2 bonus on Use Rope checks.

Synergy: If you have 5 or more ranks in Use Rope, you get a +2 bonus on Climb checks made to climb a rope, a knotted rope, or a rope-and-wall combination.

If you have 5 or more ranks in Use Rope, you get a +2 bonus on Escape Artist checks when escaping from rope bonds.

If you have 5 or more ranks in Escape Artist, you get a +2 bonus on checks made to bind someone.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Use Rope","source_heading":"Dex"}'::jsonb),
('conhecimento_arcano','Conhecimento (Arcano)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Arcano)"}'::jsonb),
('conhecimento_arquitetura','Conhecimento (Arquitetura)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Arquitetura)"}'::jsonb),
('conhecimento_geografia','Conhecimento (Geografia)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Geografia)"}'::jsonb),
('conhecimento_historia','Conhecimento (História)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (História)"}'::jsonb),
('conhecimento_local','Conhecimento (Local)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Local)"}'::jsonb),
('conhecimento_masmorras','Conhecimento (Masmorras)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Masmorras)"}'::jsonb),
('conhecimento_natureza','Conhecimento (Natureza)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Natureza)"}'::jsonb),
('conhecimento_nobreza','Conhecimento (Nobreza)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Nobreza)"}'::jsonb),
('conhecimento_planos','Conhecimento (Planos)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Planos)"}'::jsonb),
('conhecimento_religiao','Conhecimento (Religião)','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

Below are listed typical fields of study.

- Arcana (ancient mysteries, magic traditions, arcane symbols, cryptic phrases, constructs, dragons, magical beasts)
- Architecture and engineering (buildings, aqueducts, bridges, fortifications)
- Dungeoneering (aberrations, caverns, oozes, spelunking)
- Geography (lands, terrain, climate, people)
- History (royalty, wars, colonies, migrations, founding of cities)
- Local (legends, personalities, inhabitants, laws, customs, traditions, humanoids)
- Nature (animals, fey, giants, monstrous humanoids, plants, seasons and cycles, weather, vermin)
- Nobility and royalty (lineages, heraldry, family trees, mottoes, personalities)
- Religion (gods and goddesses, mythic history, ecclesiastic tradition, holy symbols, undead)
- The planes (the Inner Planes, the Outer Planes, the Astral Plane, the Ethereal Plane, outsiders, elementals, magic related to the planes)

Check: Answering a question within your field of study has a DC of 10 (for really easy questions), 15 (for basic questions), or 20 to 30 (for really tough questions).

In many cases, you can use this skill to identify monsters and their special powers or vulnerabilities. In general, the DC of such a check equals 10 + the monster’s HD. A successful check allows you to remember a bit of useful information about that monster.

For every 5 points by which your check result exceeds the DC, you recall another piece of useful information.

Action: Usually none. In most cases, making a Knowledge check doesn’t take an action—you simply know the answer or you don’t.

Try Again: No. The check represents what you know, and thinking about a topic a second time doesn’t let you know something that you never learned in the first place.

Synergy: If you have 5 or more ranks in Knowledge (arcana), you get a +2 bonus on Spellcraft checks.

If you have 5 or more ranks in Knowledge (architecture and engineering), you get a +2 bonus on Search checks made to find secret doors or hidden compartments.

If you have 5 or more ranks in Knowledge (geography), you get a +2 bonus on Survival checks made to keep from getting lost or to avoid natural hazards.

If you have 5 or more ranks in Knowledge (history), you get a +2 bonus on bardic knowledge checks.

If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.

If you have 5 or more ranks in Knowledge (nature), you get a +2 bonus on Survival checks made in aboveground natural environments (aquatic, desert, forest, hill, marsh, mountains, or plains).

If you have 5 or more ranks in Knowledge (nobility and royalty), you get a +2 bonus on Diplomacy checks.

If you have 5 or more ranks in Knowledge (religion), you get a +2 bonus on turning checks against undead.

If you have 5 or more ranks in Knowledge (the planes), you get a +2 bonus on Survival checks made while on other planes.

If you have 5 or more ranks in Knowledge (dungeoneering), you get a +2 bonus on Survival checks made while underground.

If you have 5 or more ranks in Survival, you get a +2 bonus on Knowledge (nature) checks.

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only","specialization":"Conhecimento (Religião)"}'::jsonb)
on conflict(id) do update set nome=case when srd_skills.id like 'srd35_skill_%' then excluded.nome else srd_skills.nome end,atributo=excluded.atributo,treinada_apenas=excluded.treinada_apenas,penalidade_armadura=excluded.penalidade_armadura,descricao=excluded.descricao,srd_source_url=excluded.srd_source_url,dados_tecnicos=excluded.dados_tecnicos;
