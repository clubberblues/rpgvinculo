-- SRD 3.5 Skills: Open Game Content under OGL 1.0a.
-- Sources: https://github.com/olimot/srd-v3.5-md/tree/main/basic-rules-and-legal
insert into public.srd_skills(id,nome,atributo,treinada_apenas,penalidade_armadura,descricao,srd_source_url,dados_tecnicos) values
('avaliacao','Avaliação','INT',false,false,'Check: You can appraise common or well-known objects with a DC 12 Appraise check. Failure means that you estimate the value at 50% to 150% (2d6+3 times 10%,) of its actual value.

Appraising a rare or exotic item requires a successful check against DC 15, 20, or higher. If the check is successful, you estimate the value correctly; failure means you cannot estimate the item’s value.

A magnifying glass gives you a +2 circumstance bonus on Appraise checks involving any item that is small or highly detailed, such as a gem. A merchant’s scale gives you a +2 circumstance bonus on Appraise checks involving any items that are valued by weight, including anything made of precious metals.

These bonuses stack.

Action: Appraising an item takes 1 minute (ten consecutive full-round actions).

Try Again: No. You cannot try again on the same object, regardless of success.

Special: A dwarf gets a +2 racial bonus on Appraise checks that are related to stone or metal items because dwarves are familiar with valuable items of all kinds (especially those made of stone or metal).

The master of a raven familiar gains a +3 bonus on Appraise checks.

A character with the Diligent feat gets a +2 bonus on Appraise checks.

Synergy: If you have 5 ranks in any Craft skill, you gain a +2 bonus on Appraise checks related to items made with that Craft skill.

Untrained: For common items, failure on an untrained check means no estimate. For rare items, success means an estimate of 50% to 150% (2d6+3 times 10%).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Appraise","source_heading":"Int"}'::jsonb),
('srd35_skill_balance','Equilíbrio','DES',false,true,'Check: You can walk on a precarious surface. A successful check lets you move at half your speed along the surface for 1 round. A failure by 4 or less means you can’t move for 1 round. A failure by 5 or more means you fall. The difficulty varies with the surface, as follows:

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Narrow Surface</th><th>Balance DC<sup>1</sup></th><th>Difficult Surface</th><th>Balance DC<sup>1</sup></th></tr><tr><td>7–12 inches wide</td><td>10</td><td>Uneven flagstone</td><td>10<sup>2</sup></td></tr><tr><td>2–6 inches wide</td><td>15</td><td>Hewn stone floor</td><td>10<sup>2</sup></td></tr><tr><td>Less than 2 inches wide</td><td>20</td><td>Sloped or angled floor</td><td>10<sup>2</sup></td></tr><tr><td colspan="4">1 Add modifiers from Narrow Surface Modifiers, below, as appropriate.</td></tr><tr><td colspan="4">2 Only if running or charging. Failure by 4 or less means the character can’t run or charge, but may otherwise act normally.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Narrow Surface Modifiers</th><td></td></tr><tr><th>Surface</th><th>DC Modifier<sup>1</sup></th></tr><tr><td>Lightly obstructed</td><td>+2</td></tr><tr><td>Severely obstructed</td><td>+5</td></tr><tr><td>Lightly slippery</td><td>+2</td></tr><tr><td>Severely slippery</td><td>+5</td></tr><tr><td>Sloped or angled</td><td>+2</td></tr><tr><td colspan="2">1 Add the appropriate modifier to the Balance DC of a narrow surface.</td></tr><tr><td colspan="2">These modifiers stack.</td></tr></tbody></table>

Being Attacked while Balancing: You are considered flat-footed while balancing, since you can’t move to avoid a blow, and thus you lose your Dexterity bonus to AC (if any). If you have 5 or more ranks in Balance, you aren’t considered flat-footed while balancing. If you take damage while balancing, you must make another Balance check against the same DC to remain standing.

Accelerated Movement: You can try to walk across a precarious surface more quickly than normal. If you accept a –5 penalty, you can move your full speed as a move action. (Moving twice your speed in a round requires two Balance checks, one for each move action used.) You may also accept this penalty in order to charge across a precarious surface; charging requires one Balance check for each multiple of your speed (or fraction thereof ) that you charge.

Action: None. A Balance check doesn’t require an action; it is made as part of another action or as a reaction to a situation.

Special: If you have the Agile feat, you get a +2 bonus on Balance checks.

Synergy: If you have 5 or more ranks in Tumble, you get a +2 bonus on Balance checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Balance","source_heading":"Dex; Armor Check Penalty"}'::jsonb),
('blefe','Blefe','CAR',false,false,'Check: A Bluff check is opposed by the target’s Sense Motive check. See the accompanying table for examples of different kinds of bluffs and the modifier to the target’s Sense Motive check for each one.

Favorable and unfavorable circumstances weigh heavily on the outcome of a bluff. Two circumstances can weigh against you: The bluff is hard to believe, or the action that the target is asked to take goes against its self-interest, nature, personality, orders, or the like. If it’s important, you can distinguish between a bluff that fails because the target doesn’t believe it and one that fails because it just asks too much of the target. For instance, if the target gets a +10 bonus on its Sense Motive check because the bluff demands something risky, and the Sense Motive check succeeds by 10 or less, then the target didn’t so much see through the bluff as prove reluctant to go along with it. A target that succeeds by 11 or more has seen through the bluff.

A successful Bluff check indicates that the target reacts as you wish, at least for a short time (usually 1 round or less) or believes something that you want it to believe. Bluff, however, is not a suggestion spell.

A bluff requires interaction between you and the target. Creatures unaware of you cannot be bluffed.

Feinting in Combat: You can also use Bluff to mislead an opponent in melee combat (so that it can’t dodge your next attack effectively). To feint, make a Bluff check opposed by your target’s Sense Motive check, but in this case, the target may add its base attack bonus to the roll along with any other applicable modifiers.

If your Bluff check result exceeds this special Sense Motive check result, your target is denied its Dexterity bonus to AC (if any) for the next melee attack you make against it. This attack must be made on or before your next turn.

Feinting in this way against a nonhumanoid is difficult because it’s harder to read a strange creature’s body language; you take a –4 penalty on your Bluff check. Against a creature of animal Intelligence (1 or 2) it’s even harder; you take a –8 penalty. Against a nonintelligent creature, it’s impossible.

Feinting in combat does not provoke an attack of opportunity.

Creating a Diversion to Hide: You can use the Bluff skill to help you hide. A successful Bluff check gives you the momentary diversion you need to attempt a Hide check while people are aware of you. This usage does not provoke an attack of opportunity.

Delivering a Secret Message: You can use Bluff to get a message across to another character without others understanding it. The DC is 15 for simple messages, or 20 for complex messages, especially those that rely on getting across new information. Failure by 4 or less means you can’t get the message across. Failure by 5 or more means that some false information has been implied or inferred. Anyone listening to the exchange can make a Sense Motive check opposed by the Bluff check you made to transmit in order to intercept your message (see Sense Motive).

Action: Varies. A Bluff check made as part of general interaction always takes at least 1 round (and is at least a full-round action), but it can take much longer if you try something elaborate. A Bluff check made to feint in combat or create a diversion to hide is a standard action. A Bluff check made to deliver a secret message doesn’t take an action; it is part of normal communication.

Try Again: Varies. Generally, a failed Bluff check in social interaction makes the target too suspicious for you to try again in the same circumstances, but you may retry freely on Bluff checks made to feint in combat. Retries are also allowed when you are trying to send a message, but you may attempt such a retry only once per round.

Each retry carries the same chance of miscommunication.

Special: A ranger gains a bonus on Bluff checks when using this skill against a favored enemy.

The master of a snake familiar gains a +3 bonus on Bluff checks.

If you have the Persuasive feat, you get a +2 bonus on Bluff checks.

Synergy: If you have 5 or more ranks in Bluff, you get a +2 bonus on Diplomacy, Intimidate, and Sleight of Hand checks, as well as on Disguise checks made when you know you’re being observed and you try to act in character.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th colspan="2">Bluff Examples</th></tr><tr><th>Example Circumstances</th><th>Sense Motive Modifier</th></tr><tr><td>The target wants to believe you.</td><td>–5</td></tr><tr><td>The bluff is believable and doesn’t affect the target much.</td><td>+0</td></tr><tr><td>The bluff is a little hard to believe or puts the target at some risk.</td><td>+5</td></tr><tr><td>The bluff is hard to believe or puts the target at significant risk.</td><td>+10</td></tr><tr><td>The bluff is way out there, almost too incredible to consider.</td><td>+20</td></tr></tbody></table>','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Bluff","source_heading":"Cha"}'::jsonb),
('escalar','Escalar','FOR',false,true,'Check: With a successful Climb check, you can advance up, down, or across a slope, a wall, or some other steep incline (or even a ceiling with handholds) at one-quarter your normal speed. A slope is considered to be any incline at an angle measuring less than 60 degrees; a wall is any incline at an angle measuring 60 degrees or more.

A Climb check that fails by 4 or less means that you make no progress, and one that fails by 5 or more means that you fall from whatever height you have already attained.

A climber’s kit gives you a +2 circumstance bonus on Climb checks.

The DC of the check depends on the conditions of the climb. Compare the task with those on the following table to determine an appropriate DC.

<table class="full-width-table" data-debug="no-caption"><tbody><tr><th>Climb DC</th><th>Example Surface or Activity</th></tr><tr><td>0</td><td>A slope too steep to walk up, or a knotted rope with a wall to brace against.</td></tr><tr><td>5</td><td>A rope with a wall to brace against, or a knotted rope, or a rope affected by the <i>rope trick</i> spell.</td></tr><tr><td>10</td><td>A surface with ledges to hold on to and stand on, such as a very rough wall or a ship’s rigging.</td></tr><tr><td>15</td><td>Any surface with adequate handholds and footholds (natural or artificial), such as a very rough natural rock surface or a tree, or an unknotted rope, or pulling yourself up when dangling by your hands.</td></tr><tr><td>20</td><td>An uneven surface with some narrow handholds and footholds, such as a typical wall in a dungeon or ruins.</td></tr><tr><td>25</td><td>A rough surface, such as a natural rock wall or a brick wall.</td></tr><tr><td>25</td><td>An overhang or ceiling with handholds but no footholds.</td></tr><tr><td>—</td><td>A perfectly smooth, flat, vertical surface cannot be climbed.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Climb DC Modifier<sup>1</sup></th><th>Example Surface or Activity</th></tr><tr><td>–10</td><td>Climbing a chimney (artificial or natural) or other location where you can brace against two opposite walls (reduces DC by 10).</td></tr><tr><td>–5</td><td>Climbing a corner where you can brace against perpendicular walls (reduces DC by 5).</td></tr><tr><td>+5</td><td>Surface is slippery (increases DC by 5).</td></tr><tr><td colspan="2">1These modifiers are cumulative; use any that apply.</td></tr></tbody></table>

You need both hands free to climb, but you may cling to a wall with one hand while you cast a spell or take some other action that requires only one hand. While climbing, you can’t move to avoid a blow, so you lose your Dexterity bonus to AC (if any). You also can’t use a shield while climbing.

Any time you take damage while climbing, make a Climb check against the DC of the slope or wall. Failure means you fall from your current height and sustain the appropriate falling damage.

Accelerated Climbing: You try to climb more quickly than normal. By accepting a –5 penalty, you can move half your speed (instead of one-quarter your speed).

Making Your Own Handholds and Footholds: You can make your own handholds and footholds by pounding pitons into a wall. Doing so takes 1 minute per piton, and one piton is needed per 3 feet of distance. As with any surface that offers handholds and footholds, a wall with pitons in it has a DC of 15. In the same way, a climber with a handaxe or similar implement can cut handholds in an ice wall.

Catching Yourself When Falling: It’s practically impossible to catch yourself on a wall while falling. Make a Climb check (DC = wall’s DC + 20) to do so. It’s much easier to catch yourself on a slope (DC = slope’s DC + 10).

Catching a Falling Character While Climbing: If someone climbing above you or adjacent to you falls, you can attempt to catch the falling character if he or she is within your reach. Doing so requires a successful melee touch attack against the falling character (though he or she can voluntarily forego any Dexterity bonus to AC if desired). If you hit, you must immediately attempt a Climb check (DC = wall’s DC + 10). Success indicates that you catch the falling character, but his or her total weight, including equipment, cannot exceed your heavy load limit or you automatically fall. If you fail your Climb check by 4 or less, you fail to stop the character’s fall but don’t lose your grip on the wall. If you fail by 5 or more, you fail to stop the character’s fall and begin falling as well.

Action: Climbing is part of movement, so it’s generally part of a move action (and may be combined with other types of movement in a move action). Each move action that includes any climbing requires a separate Climb check. Catching yourself or another falling character doesn’t take an action.

Special: You can use a rope to haul a character upward (or lower a character) through sheer strength. You can lift double your maximum load in this manner.

A halfling has a +2 racial bonus on Climb checks because halflings are agile and surefooted.

The master of a lizard familiar gains a +3 bonus on Climb checks.

If you have the Athletic feat, you get a +2 bonus on Climb checks.

A creature with a climb speed has a +8 racial bonus on all Climb checks. The creature must make a Climb check to climb any wall or slope with a DC higher than 0, but it always can choose to take 10, even if rushed or threatened while climbing. If a creature with a climb speed chooses an accelerated climb (see above), it moves at double its climb speed (or at its land speed, whichever is slower) and makes a single Climb check at a –5 penalty. Such a creature retains its Dexterity bonus to Armor Class (if any) while climbing, and opponents get no special bonus to their attacks against it. It cannot, however, use the run action while climbing.

Synergy: If you have 5 or more ranks in Use Rope, you get a +2 bonus on Climb checks made to climb a rope, a knotted rope, or a rope-and-wall combination.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Climb","source_heading":"Str; Armor Check Penalty"}'::jsonb),
('concentracao','Concentração','CON',false,false,'Check: You must make a Concentration check whenever you might potentially be distracted (by taking damage, by harsh weather, and so on) while engaged in some action that requires your full attention. Such actions include casting a spell, concentrating on an active spell, directing a spell, using a spell-like ability, or using a skill that would provoke an attack of opportunity. In general, if an action wouldn’t normally provoke an attack of opportunity, you need not make a Concentration check to avoid being distracted.

If the Concentration check succeeds, you may continue with the action as normal. If the check fails, the action automatically fails and is wasted. If you were in the process of casting a spell, the spell is lost. If you were concentrating on an active spell, the spell ends as if you had ceased concentrating on it. If you were directing a spell, the direction fails but the spell remains active. If you were using a spell-like ability, that use of the ability is lost. A skill use also fails, and in some cases a failed skill check may have other ramifications as well.

The table below summarizes various types of distractions that cause you to make a Concentration check. If the distraction occurs while you are trying to cast a spell, you must add the level of the spell you are trying to cast to the appropriate Concentration DC. If more than one type of distraction is present, make a check for each one; any failed Concentration check indicates that the task is not completed.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Concentration DC<sup>1</sup></th><th>Distraction</th></tr><tr><td>10 + damage dealt</td><td>Damaged during the action.<sup>2</sup></td></tr><tr><td>10 + half of continuous</td><td>Taking continuous damage during the damage last dealt action.<sup>3</sup></td></tr><tr><td>Distracting spell’s save DC</td><td>Distracted by nondamaging spell.<sup>4</sup></td></tr><tr><td>10</td><td>Vigorous motion (on a moving mount, taking a bouncy wagon ride, in a small boat in rough water, belowdecks in a stormtossed ship).</td></tr><tr><td>15</td><td>Violent motion (on a galloping horse, taking a very rough wagon ride, in a small boat in rapids, on the deck of a storm-tossed ship).</td></tr><tr><td>20</td><td>Extraordinarily violent motion (earthquake).</td></tr><tr><td>15</td><td>Entangled.</td></tr><tr><td>20</td><td>Grappling or pinned. (You can cast only spells without somatic components for which you have any required material component in hand.)</td></tr><tr><td>5</td><td>Weather is a high wind carrying blinding rain or sleet.</td></tr><tr><td>10</td><td>Weather is wind-driven hail, dust, or debris.</td></tr><tr><td>Distracting spell’s save DC</td><td>Weather caused by a spell, such as <i>storm of vengeance.</i><sup>4</sup></td></tr><tr><td colspan="2">1 If you are trying to cast, concentrate on, or direct a spell when the distraction occurs, add the level of the spell to the indicated DC.</td></tr><tr><td colspan="2">2 Such as during the casting of a spell with a casting time of 1 round or more, or the execution of an activity that takes more than a single full-round action (such as Disable Device). Also, damage stemming from an attack of opportunity or readied attack made in response to the spell being cast (for spells with a casting time of 1 action) or the action being taken (for activities requiring no more than a full-round action).</td></tr><tr><td colspan="2">3 Such as from <i>acid arrow</i>.</td></tr><tr><td colspan="2">4 If the spell allows no save, use the save DC it would have if it did allow a save.</td></tr></tbody></table>

Action: None. Making a Concentration check doesn’t take an action; it is either a free action (when attempted reactively) or part of another action (when attempted actively).

Try Again: Yes, though a success doesn’t cancel the effect of a previous failure, such as the loss of a spell you were casting or the disruption of a spell you were concentrating on.

Special: You can use Concentration to cast a spell, use a spell-like ability, or use a skill defensively, so as to avoid attacks of opportunity altogether. This doesn’t apply to other actions that might provoke attacks of opportunity.

The DC of the check is 15 (plus the spell’s level, if casting a spell or using a spell-like ability defensively). If the Concentration check succeeds, you may attempt the action normally without provoking any attacks of opportunity. A successful Concentration check still doesn’t allow you to take 10 on another check if you are in a stressful situation; you must make the check normally. If the Concentration check fails, the related action also automatically fails (with any appropriate ramifications), and the action is wasted, just as if your concentration had been disrupted by a distraction.

A character with the Combat Casting feat gets a +4 bonus on Concentration checks made to cast a spell or use a spell-like ability while on the defensive or while grappling or pinned.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Concentration","source_heading":"Con"}'::jsonb),
('oficio','Ofício','INT',false,false,'Like Knowledge, Perform, and Profession, Craft is actually a number of separate skills. You could have several Craft skills, each with its own ranks, each purchased as a separate skill.

A Craft skill is specifically focused on creating something. If nothing is created by the endeavor, it probably falls under the heading of a Profession skill.

Check: You can practice your trade and make a decent living, earning about half your check result in gold pieces per week of dedicated work. You know how to use the tools of your trade, how to perform the craft’s daily tasks, how to supervise untrained helpers, and how to handle common problems. (Untrained laborers and assistants earn an average of 1 silver piece per day.)

The basic function of the Craft skill, however, is to allow you to make an item of the appropriate type. The DC depends on the complexity of the item to be created. The DC, your check results, and the price of the item determine how long it takes to make a particular item. The item’s finished price also determines the cost of raw materials.

In some cases, the fabricate spell can be used to achieve the results of a Craft check with no actual check involved. However, you must make an appropriate Craft check when using the spell to make articles requiring a high degree of craftsmanship.

A successful Craft check related to woodworking in conjunction with the casting of the ironwood spell enables you to make wooden items that have the strength of steel.

When casting the spell minor creation, you must succeed on an appropriate Craft check to make a complex item.

All crafts require artisan’s tools to give the best chance of success. If improvised tools are used, the check is made with a –2 circumstance penalty. On the other hand, masterwork artisan’s tools provide a +2 circumstance bonus on the check.

To determine how much time and money it takes to make an item, follow these steps.

1\. Find the item’s price. Put the price in silver pieces (1 gp = 10 sp).

2\. Find the DC from the table below.

3\. Pay one-third of the item’s price for the cost of raw materials.

4\. Make an appropriate Craft check representing one week’s work. If the check succeeds, multiply your check result by the DC. If the result × the DC equals the price of the item in sp, then you have completed the item. (If the result × the DC equals double or triple the price of the item in silver pieces, then you’ve completed the task in one-half or one-third of the time. Other multiples of the DC reduce the time in the same manner.) If the result × the DC doesn’t equal the price, then it represents the progress you’ve made this week. Record the result and make a new Craft check for the next week. Each week, you make more progress until your total reaches the price of the item in silver pieces.

If you fail a check by 4 or less, you make no progress this week.

If you fail by 5 or more, you ruin half the raw materials and have to pay half the original raw material cost again.

Progress by the Day: You can make checks by the day instead of by the week. In this case your progress (check result × DC) is in copper pieces instead of silver pieces.

Creating Masterwork Items: You can make a masterwork item—a weapon, suit of armor, shield, or tool that conveys a bonus on its use through its exceptional craftsmanship, not through being magical. To create a masterwork item, you create the masterwork component as if it were a separate item in addition to the standard item. The masterwork component has its own price (300 gp for a weapon or 150 gp for a suit of armor or a shield) and a Craft DC of 20. Once both the standard component and the masterwork component are completed, the masterwork item is finished. Note: The cost you pay for the masterwork component is one-third of the given amount, just as it is for the cost in raw materials.

Repairing Items: Generally, you can repair an item by making checks against the same DC that it took to make the item in the first place. The cost of repairing an item is one-fifth of the item’s price.

When you use the Craft skill to make a particular sort of item, the DC for checks involving the creation of that item are typically as given on the following table.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Item</th><th>Craft Skill</th><th>Craft DC</th></tr><tr><td>Acid</td><td>Alchemy<sup>1</sup></td><td>15</td></tr><tr><td>Alchemist’s fire, smokestick, or tindertwig</td><td>Alchemy<sup>1</sup></td><td>20</td></tr><tr><td>Antitoxin, sunrod, tanglefoot bag, or thunderstone</td><td>Alchemy<sup>1</sup></td><td>25</td></tr><tr><td>Armor or shield</td><td>Armorsmithing</td><td>10 + AC bonus</td></tr><tr><td>Longbow or shortbow</td><td>Bowmaking</td><td>12</td></tr><tr><td>Composite longbow or composite shortbow</td><td>Bowmaking</td><td>15</td></tr><tr><td>Composite longbow or composite shortbow with high strength rating</td><td>Bowmaking</td><td>15 + (2 × rating)</td></tr><tr><td>Crossbow</td><td>Weaponsmithing</td><td>15</td></tr><tr><td>Simple melee or thrown weapon</td><td>Weaponsmithing</td><td>12</td></tr><tr><td>Martial melee or thrown weapon</td><td>Weaponsmithing</td><td>15</td></tr><tr><td>Exotic melee or thrown weapon</td><td>Weaponsmithing</td><td>18</td></tr><tr><td>Mechanical trap</td><td>Trapmaking</td><td>Varies<sup>2</sup></td></tr><tr><td>Very simple item (wooden spoon)</td><td>Varies</td><td>5</td></tr><tr><td>Typical item (iron pot)</td><td>Varies</td><td>10</td></tr><tr><td>High-quality item (bell)</td><td>Varies</td><td>15</td></tr><tr><td>Complex or superior item (lock)</td><td>Varies</td><td>20</td></tr><tr><td colspan="3">1 You must be a spellcaster to craft any of these items.</td></tr><tr><td colspan="3">2 Traps have their own rules for construction.</td></tr></tbody></table>

Action: Does not apply. Craft checks are made by the day or week (see above).

Try Again: Yes, but each time you miss by 5 or more, you ruin half the raw materials and have to pay half the original raw material cost again.

Special: A dwarf has a +2 racial bonus on Craft checks that are related to stone or metal, because dwarves are especially capable with stonework and metalwork.

A gnome has a +2 racial bonus on Craft (alchemy) checks because gnomes have sensitive noses.

You may voluntarily add +10 to the indicated DC to craft an item. This allows you to create the item more quickly (since you’ll be multiplying this higher DC by your Craft check result to determine progress). You must decide whether to increase the DC before you make each weekly or daily check.

To make an item using Craft (alchemy), you must have alchemical equipment and be a spellcaster. If you are working in a city, you can buy what you need as part of the raw materials cost to make the item, but alchemical equipment is difficult or impossible to come by in some places. Purchasing and maintaining an alchemist’s lab grants a +2 circumstance bonus on Craft (alchemy) checks because you have the perfect tools for the job, but it does not affect the cost of any items made using the skill.

Synergy: If you have 5 ranks in a Craft skill, you get a +2 bonus on Appraise checks related to items made with that Craft skill.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Craft","source_heading":"Int"}'::jsonb),
('decifrar_escrita','Decifrar Escrita','INT',true,false,'Check: You can decipher writing in an unfamiliar language or a message written in an incomplete or archaic form. The base DC is 20 for the simplest messages, 25 for standard texts, and 30 or higher for intricate, exotic, or very old writing.

If the check succeeds, you understand the general content of a piece of writing about one page long (or the equivalent). If the check fails, make a DC 5 Wisdom check to see if you avoid drawing a false conclusion about the text. (Success means that you do not draw a false conclusion; failure means that you do.)

Both the Decipher Script check and (if necessary) the Wisdom check are made secretly, so that you can’t tell whether the conclusion you draw is true or false.

Action: Deciphering the equivalent of a single page of script takes 1 minute (ten consecutive full-round actions).

Try Again: No.

Special: A character with the Diligent feat gets a +2 bonus on Decipher Script checks.

Synergy: If you have 5 or more ranks in Decipher Script, you get a +2 bonus on Use Magic Device checks involving scrolls.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Decipher Script","source_heading":"Int; Trained Only"}'::jsonb),
('diplomacia','Diplomacia','CAR',false,false,'Check: You can change the attitudes of others (nonplayer characters) with a successful Diplomacy check; see the Influencing NPC Attitudes sidebar, below, for basic DCs. In negotiations, participants roll opposed Diplomacy checks, and the winner gains the advantage. Opposed checks also resolve situations when two advocates or diplomats plead opposite cases in a hearing before a third party.

Action: Changing others’ attitudes with Diplomacy generally takes at least 1 full minute (10 consecutive full-round actions). In some situations, this time requirement may greatly increase. A rushed Diplomacy check can be made as a full-round action, but you take a –10 penalty on the check.

Try Again: Optional, but not recommended because retries usually do not work. Even if the initial Diplomacy check succeeds, the other character can be persuaded only so far, and a retry may do more harm than good. If the initial check fails, the other character has probably become more firmly committed to his position, and a retry is futile.

Special: A half-elf has a +2 racial bonus on Diplomacy checks.

If you have the Negotiator feat, you get a +2 bonus on Diplomacy checks.

Synergy: If you have 5 or more ranks in Bluff, Knowledge (nobility and royalty), or Sense Motive, you get a +2 bonus on Diplomacy checks.

#### Influencing Npc Attitudes

Use the table below to determine the effectiveness of Diplomacy checks (or Charisma checks) made to influence the attitude of a nonplayer character, or wild empathy checks made to influence the attitude of an animal or magical beast.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Initial Attitude</th><th colspan="5" class="middle-line">New Attitude (DC to achieve)</th></tr><tr><td></td><th>Hostile</th><th>Unfriendly</th><th>Indifferent</th><th>Friendly</th><th>Helpful</th></tr><tr><td>Hostile</td><td>Less than 20</td><td>20</td><td>25</td><td>35</td><td>50</td></tr><tr><td>Unfriendly</td><td>Less than 5</td><td>5</td><td>15</td><td>25</td><td>40</td></tr><tr><td>Indifferent</td><td>—</td><td>Less than 1</td><td>1</td><td>15</td><td>30</td></tr><tr><td>Friendly</td><td>—</td><td>—</td><td>Less than 1</td><td>1</td><td>20</td></tr><tr><td>Helpful</td><td>—</td><td>—</td><td>—</td><td>Less than 1</td><td>1</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Attitude</th><th>Means</th><th>Possible Actions</th></tr><tr><td>Hostile</td><td>Will take risks to hurt you</td><td>Attack, interfere, berate, flee</td></tr><tr><td>Unfriendly</td><td>Wishes you ill</td><td>Mislead, gossip, avoid, watch suspiciously, insult</td></tr><tr><td>Indifferent</td><td>Doesn’t much care</td><td>Socially expected interaction</td></tr><tr><td>Friendly</td><td>Wishes you well</td><td>Chat, advise, offer limited help, advocate</td></tr><tr><td>Helpful</td><td>Will take risks to help you</td><td>Protect, back up, heal, aid</td></tr></tbody></table>','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Diplomacy","source_heading":"Cha"}'::jsonb),
('srd35_skill_disable_device','Operar Mecanismo','INT',true,false,'Check: The Disable Device check is made secretly, so that you don’t necessarily know whether you’ve succeeded.

The DC depends on how tricky the device is. Disabling (or rigging or jamming) a fairly simple device has a DC of 10; more intricate and complex devices have higher DCs.

If the check succeeds, you disable the device. If it fails by 4 or less, you have failed but can try again. If you fail by 5 or more, something goes wrong. If the device is a trap, you spring it. If you’re attempting some sort of sabotage, you think the device is disabled, but it still works normally.

You also can rig simple devices such as saddles or wagon wheels to work normally for a while and then fail or fall off some time later (usually after 1d4 rounds or minutes of use).

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Device</th><th>Time</th><th>Disable Device DC<sup>1</sup></th><th>Example</th></tr><tr><td>Simple</td><td>1 round</td><td>10</td><td>Jam a lock</td></tr><tr><td>Tricky</td><td>1d4 rounds</td><td>15</td><td>Sabotage a wagon wheel</td></tr><tr><td>Difficult</td><td>2d4 rounds</td><td>20</td><td>Disarm a trap, reset a trap</td></tr><tr><td>Wicked</td><td>2d4 rounds</td><td>25</td><td>Disarm a complex trap, cleverly sabotage a clockwork device</td></tr><tr><td colspan="4">1If you attempt to leave behind no trace of your tampering, add 5 to the DC.</td></tr></tbody></table>

Action: The amount of time needed to make a Disable Device check depends on the task, as noted above. Disabling a simple device takes 1 round and is a full-round action. An intricate or complex device requires 1d4 or 2d4 rounds.

Try Again: Varies. You can retry if you have missed the check by 4 or less, though you must be aware that you have failed in order to try again.

Special: If you have the Nimble Fingers feat, you get a +2 bonus on Disable Device checks.

A rogue who beats a trap’s DC by 10 or more can study the trap, figure out how it works, and bypass it (along with her companions) without disarming it.

Restriction: Rogues (and other characters with the trapfinding class feature) can disarm magic traps. A magic trap generally has a DC of 25 + the spell level of the magic used to create it.

The spells fire trap, glyph of warding, symbol, and teleportation circle also create traps that a rogue can disarm with a successful Disable Device check. Spike growth and spike stones, however, create magic traps against which Disable Device checks do not succeed. See the individual spell descriptions for details.

#### Other Ways to Beat a Trap

It’s possible to ruin many traps without making a Disable Device check.

Ranged Attack Traps: Once a trap’s location is known, the obvious way to ruin it is to smash the mechanism—assuming the mechanism can be accessed. Failing that, it’s possible to plug up the holes from which the projectiles emerge. Doing this prevents the trap from firing unless its ammunition does enough damage to break through the plugs.

Melee Attack Traps: These devices can be thwarted by smashing the mechanism or blocking the weapons, as noted above. Alternatively, if a character studies the trap as it triggers, he might be able to time his dodges just right to avoid damage. A character who is doing nothing but studying a trap when it first goes off gains a +4 dodge bonus against its attacks if it is triggered again within the next minute.

Pits: Disabling a pit trap generally ruins only the trapdoor, making it an uncovered pit. Filling in the pit or building a makeshift bridge across it is an application of manual labor, not the Disable Device skill. Characters could neutralize any spikes at the bottom of a pit by attacking them—they break just as daggers do.

Magic Traps: Dispel magic helps here. Someone who succeeds on a caster level check against the level of the trap’s creator suppresses the trap for 1d4 rounds. This works only with a targeted dispel magic, not the area version (see the spell description).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Disable Device","source_heading":"Int; Trained Only"}'::jsonb),
('disfarce','Disfarce','CAR',false,false,'Check: Your Disguise check result determines how good the disguise is, and it is opposed by others’ Spot check results. If you don’t draw any attention to yourself, others do not get to make Spot checks. If you come to the attention of people who are suspicious (such as a guard who is watching commoners walking through a city gate), it can be assumed that such observers are taking 10 on their Spot checks.

You get only one Disguise check per use of the skill, even if several people are making Spot checks against it. The Disguise check is made secretly, so that you can’t be sure how good the result is.

The effectiveness of your disguise depends in part on how much you’re attempting to change your appearance.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Disguise</th><th>Disguise Check Modifier</th></tr><tr><td>Minor details only</td><td>+5</td></tr><tr><td>Disguised as different gender<sup>1</sup></td><td>–2</td></tr><tr><td>Disguised as different race<sup>1</sup></td><td>–2</td></tr><tr><td>Disguised as different age category<sup>1</sup></td><td>–2<sup>2</sup></td></tr><tr><td colspan="2"><sup>1</sup>These modifiers are cumulative; use any that apply.</td></tr><tr><td colspan="2"><sup>2</sup>Per step of difference between your actual age category and your disguised age category. The steps are: young (younger than adulthood), adulthood, middle age, old, and venerable.</td></tr></tbody></table>

If you are impersonating a particular individual, those who know what that person looks like get a bonus on their Spot checks according to the table below. Furthermore, they are automatically considered to be suspicious of you, so opposed checks are always called for.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Familiarity</th><th>Viewer’s Spot Check Bonus</th></tr><tr><td>Recognizes on sight</td><td>+4</td></tr><tr><td>Friends or associates</td><td>+6</td></tr><tr><td>Close friends</td><td>+8</td></tr><tr><td>Intimate</td><td>+10</td></tr></tbody></table>

Usually, an individual makes a Spot check to see through your disguise immediately upon meeting you and each hour thereafter. If you casually meet many different creatures, each for a short time, check once per day or hour, using an average Spot modifier for the group.

Action: Creating a disguise requires 1d3×10 minutes of work.

Try Again: Yes. You may try to redo a failed disguise, but once others know that a disguise was attempted, they’ll be more suspicious.

Special: Magic that alters your form, such as alter self, disguise self, polymorph, or shapechange, grants you a +10 bonus on Disguise checks (see the individual spell descriptions). You must succeed on a Disguise check with a +10 bonus to duplicate the appearance of a specific individual using the veil spell. Divination magic that allows people to see through illusions (such as true seeing) does not penetrate a mundane disguise, but it can negate the magical component of a magically enhanced one.

You must make a Disguise check when you cast a simulacrum spell to determine how good the likeness is.

If you have the Deceitful feat, you get a +2 bonus on Disguise checks.

Synergy: If you have 5 or more ranks in Bluff, you get a +2 bonus on Disguise checks when you know that you’re being observed and you try to act in character.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Disguise","source_heading":"Cha"}'::jsonb),
('fuga','Arte da Fuga','DES',false,true,'Check: The table below gives the DCs to escape various forms of restraints.

Ropes: Your Escape Artist check is opposed by the binder’s Use Rope check. Since it’s easier to tie someone up than to escape from being tied up, the binder gets a +10 bonus on his or her check.

Manacles and Masterwork Manacles: The DC for manacles is set by their construction.

Tight Space: The DC noted on the table is for getting through a space where your head fits but your shoulders don’t. If the space is long you may need to make multiple checks. You can’t get through a space that your head does not fit through.

Grappler: You can make an Escape Artist check opposed by your enemy’s grapple check to get out of a grapple or out of a pinned condition (so that you’re only grappling).

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Restraint</th><th>Escape Artist DC</th></tr><tr><td>Ropes Binder’s</td><td>Use Rope check at +10</td></tr><tr><td>Net, <i>animate rope</i> spell, <i>command plants</i> spell, <i>control plants</i> spell, or <i>entangle</i> spell</td><td>20</td></tr><tr><td>Snare spell</td><td>23</td></tr><tr><td>Manacles</td><td>30</td></tr><tr><td>Tight space</td><td>30</td></tr><tr><td>Masterwork manacles</td><td>35</td></tr><tr><td>Grappler</td><td>Grappler’s grapple check result</td></tr></tbody></table>

Action: Making an Escape Artist check to escape from rope bindings, manacles, or other restraints (except a grappler) requires 1 minute of work. Escaping from a net or an animate rope, command plants, control plants, or entangle spell is a full-round action. Escaping from a grapple or pin is a standard action. Squeezing through a tight space takes at least 1 minute, maybe longer, depending on how long the space is.

Try Again: Varies. You can make another check after a failed check if you’re squeezing your way through a tight space, making multiple checks. If the situation permits, you can make additional checks, or even take 20, as long as you’re not being actively opposed.

Special: If you have the Agile feat, you get a +2 bonus on Escape Artist checks.

Synergy: If you have 5 or more ranks in Escape Artist, you get a +2 bonus on Use Rope checks to bind someone.

If you have 5 or more ranks in Use Rope, you get a +2 bonus on Escape Artist checks when escaping from rope bonds.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Escape Artist","source_heading":"Dex; Armor Check Penalty"}'::jsonb),
('srd35_skill_forgery','Falsificação','INT',false,false,'Check: Forgery requires writing materials appropriate to the document being forged, enough light or sufficient visual acuity to see the details of what you’re writing, wax for seals (if appropriate), and some time. To forge a document on which the handwriting is not specific to a person (military orders, a government decree, a business ledger, or the like), you need only to have seen a similar document before, and you gain a +8 bonus on your check. To forge a signature, you need an autograph of that person to copy, and you gain a +4 bonus on the check. To forge a longer document written in the hand of some particular person, a large sample of that person’s handwriting is needed.

The Forgery check is made secretly, so that you’re not sure how good your forgery is. As with Disguise, you don’t even need to make a check until someone examines the work. Your Forgery check is opposed by the Forgery check of the person who examines the document to check its authenticity. The examiner gains modifiers on his or her check if any of the conditions on the table below exist.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Condition</th><th>Reader’s Forgery Check Modifier</th></tr><tr><td>Type of document unknown to reader</td><td>–2</td></tr><tr><td>Type of document somewhat known to reader</td><td>+0</td></tr><tr><td>Type of document well known to reader</td><td>+2</td></tr><tr><td>Handwriting not known to reader</td><td>–2</td></tr><tr><td>Handwriting somewhat known to reader</td><td>+0</td></tr><tr><td>Handwriting intimately known to reader</td><td>+2</td></tr><tr><td>Reader only casually reviews the document</td><td>–2</td></tr></tbody></table>

A document that contradicts procedure, orders, or previous knowledge, or one that requires sacrifice on the part of the person checking the document can increase that character’s suspicion (and thus create favorable circumstances for the checker’s opposing Forgery check).

Action: Forging a very short and simple document takes about 1 minute. A longer or more complex document takes 1d4 minutes per page.

Try Again: Usually, no. A retry is never possible after a particular reader detects a particular forgery. But the document created by the forger might still fool someone else. The result of a Forgery check for a particular document must be used for every instance of a different reader examining the document. No reader can attempt to detect a particular forgery more than once; if that one opposed check goes in favor of the forger, then the reader can’t try using his own skill again, even if he’s suspicious about the document.

Special: If you have the Deceitful feat, you get a +2 bonus on Forgery checks.

Restriction: Forgery is language-dependent; thus, to forge documents and detect forgeries, you must be able to read and write the language in question. A barbarian can’t learn the Forgery skill unless he has learned to read and write.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Forgery","source_heading":"Int"}'::jsonb),
('srd35_skill_gather_information','Obter Informação','CAR',false,false,'Check: An evening’s time, a few gold pieces for buying drinks and making friends, and a DC 10 Gather Information check get you a general idea of a city’s major news items, assuming there are no obvious reasons why the information would be withheld. The higher your check result, the better the information.

If you want to find out about a specific rumor, or a specific item, or obtain a map, or do something else along those lines, the DC for the check is 15 to 25, or even higher.

Action: A typical Gather Information check takes 1d4+1 hours.

Try Again: Yes, but it takes time for each check. Furthermore, you may draw attention to yourself if you repeatedly pursue a certain type of information.

Special: A half-elf has a +2 racial bonus on Gather Information checks.

If you have the Investigator feat, you get a +2 bonus on Gather Information checks.

Synergy: If you have 5 or more ranks in Knowledge (local), you get a +2 bonus on Gather Information checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Gather Information","source_heading":"Cha"}'::jsonb),
('adestrar_animais','Adestrar Animais','CAR',true,false,'Check: The DC depends on what you are trying to do.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Task</th><th>Handle Animal DC</th></tr><tr><td>Handle an animal</td><td>10</td></tr><tr><td>“Push” an animal</td><td>25</td></tr><tr><td>Teach an animal a trick</td><td>15 or 20<sup>1</sup></td></tr><tr><td>Train an animal for a general purpose</td><td>15 or 20<sup>1</sup></td></tr><tr><td>Rear a wild animal</td><td>15 + HD of animal</td></tr><tr><td colspan="2"><sup>1</sup>See the specific trick or purpose below.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>General Purpose</th><th>DC</th><th>General Purpose</th><th>DC</th></tr><tr><td>Combat riding</td><td>20</td><td>Hunting</td><td>20</td></tr><tr><td>Fighting</td><td>20</td><td>Performance</td><td>15</td></tr><tr><td>Guarding</td><td>20</td><td>Riding</td><td>15</td></tr><tr><td>Heavy labor</td><td>15</td><td colspan="2"></td></tr></tbody></table>

Handle an Animal: This task involves commanding an animal to perform a task or trick that it knows. If the animal is wounded or has taken any nonlethal damage or ability score damage, the DC increases by 2. If your check succeeds, the animal performs the task or trick on its next action.

“Push” an Animal: To push an animal means to get it to perform a task or trick that it doesn’t know but is physically capable of performing. This category also covers making an animal perform a forced march or forcing it to hustle for more than 1 hour between sleep cycles. If the animal is wounded or has taken any nonlethal damage or ability score damage, the DC increases by 2. If your check succeeds, the animal performs the task or trick on its next action.

Teach an Animal a Trick: You can teach an animal a specific trick with one week of work and a successful Handle Animal check against the indicated DC. An animal with an Intelligence score of 1 can learn a maximum of three tricks, while an animal with an Intelligence score of 2 can learn a maximum of six tricks. Possible tricks (and their associated DCs) include, but are not necessarily limited to, the following.

Attack (DC 20): The animal attacks apparent enemies. You may point to a particular creature that you wish the animal to attack, and it will comply if able. Normally, an animal will attack only humanoids, monstrous humanoids, giants, or other animals. Teaching an animal to attack all creatures (including such unnatural creatures as undead and aberrations) counts as two tricks.

Come (DC 15): The animal comes to you, even if it normally would not do so.

Defend (DC 20): The animal defends you (or is ready to defend you if no threat is present), even without any command being given. Alternatively, you can command the animal to defend a specific other character.

Down (DC 15): The animal breaks off from combat or otherwise backs down. An animal that doesn’t know this trick continues to fight until it must flee (due to injury, a fear effect, or the like) or its opponent is defeated.

Fetch (DC 15): The animal goes and gets something. If you do not point out a specific item, the animal fetches some random object.

Guard (DC 20): The animal stays in place and prevents others from approaching.

Heel (DC 15): The animal follows you closely, even to places where it normally wouldn’t go.

Perform (DC 15): The animal performs a variety of simple tricks, such as sitting up, rolling over, roaring or barking, and so on.

Seek (DC 15): The animal moves into an area and looks around for anything that is obviously alive or animate.

Stay (DC 15): The animal stays in place, waiting for you to return. It does not challenge other creatures that come by, though it still defends itself if it needs to.

Track (DC 20): The animal tracks the scent presented to it. (This requires the animal to have the scent ability)

Work (DC 15): The animal pulls or pushes a medium or heavy load.

Train an Animal for a Purpose: Rather than teaching an animal individual tricks, you can simply train it for a general purpose. Essentially, an animal’s purpose represents a preselected set of known tricks that fit into a common scheme, such as guarding or heavy labor. The animal must meet all the normal prerequisites for all tricks included in the training package. If the package includes more than three tricks, the animal must have an Intelligence score of 2.

An animal can be trained for only one general purpose, though if the creature is capable of learning additional tricks (above and beyond those included in its general purpose), it may do so. Training an animal for a purpose requires fewer checks than teaching individual tricks does, but no less time.

Combat Riding (DC 20): An animal trained to bear a rider into combat knows the tricks attack, come, defend, down, guard, and heel. Training an animal for combat riding takes six weeks. You may also “upgrade” an animal trained for riding to one trained for combat riding by spending three weeks and making a successful DC 20 Handle Animal check. The new general purpose and tricks completely replace the animal’s previous purpose and any tricks it once knew. Warhorses and riding dogs are already trained to bear riders into combat, and they don’t require any additional training for this purpose.

Fighting (DC 20): An animal trained to engage in combat knows the tricks attack, down, and stay. Training an animal for fighting takes three weeks.

Guarding (DC 20): An animal trained to guard knows the tricks attack, defend, down, and guard. Training an animal for guarding takes four weeks.

Heavy Labor (DC 15): An animal trained for heavy labor knows the tricks come and work. Training an animal for heavy labor takes two weeks.

Hunting (DC 20): An animal trained for hunting knows the tricks attack, down, fetch, heel, seek, and track. Training an animal for hunting takes six weeks.

Performance (DC 15): An animal trained for performance knows the tricks come, fetch, heel, perform, and stay. Training an animal for performance takes five weeks.

Riding (DC 15): An animal trained to bear a rider knows the tricks come, heel, and stay. Training an animal for riding takes three weeks.

Rear a Wild Animal: To rear an animal means to raise a wild creature from infancy so that it becomes domesticated. A handler can rear as many as three creatures of the same kind at once.

A successfully domesticated animal can be taught tricks at the same time it’s being raised, or it can be taught as a domesticated animal later.

Action: Varies. Handling an animal is a move action, while pushing an animal is a full-round action. (A druid or ranger can handle her animal companion as a free action or push it as a move action.) For tasks with specific time frames noted above, you must spend half this time (at the rate of 3 hours per day per animal being handled) working toward completion of the task before you attempt the Handle Animal check. If the check fails, your attempt to teach, rear, or train the animal fails and you need not complete the teaching, rearing, or training time. If the check succeeds, you must invest the remainder of the time to complete the teaching, rearing, or training. If the time is interrupted or the task is not followed through to completion, the attempt to teach, rear, or train the animal automatically fails.

Try Again: Yes, except for rearing an animal.

Special: You can use this skill on a creature with an Intelligence score of 1 or 2 that is not an animal, but the DC of any such check increases by 5. Such creatures have the same limit on tricks known as animals do.

A druid or ranger gains a +4 circumstance bonus on Handle Animal checks involving her animal companion.

In addition, a druid’s or ranger’s animal companion knows one or more bonus tricks, which don’t count against the normal limit on tricks known and don’t require any training time or Handle Animal checks to teach.

If you have the Animal Affinity feat, you get a +2 bonus on Handle Animal checks.

Synergy: If you have 5 or more ranks in Handle Animal, you get a +2 bonus on Ride checks and wild empathy checks.

Untrained: If you have no ranks in Handle Animal, you can use a Charisma check to handle and push domestic animals, but you can’t teach, rear, or train animals. A druid or ranger with no ranks in Handle Animal can use a Charisma check to handle and push her animal companion, but she can’t teach, rear, or train other nondomestic animals.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-i.md','{"original_name":"Handle Animal","source_heading":"Cha; Trained Only"}'::jsonb),
('cura','Cura','SAB',false,false,'Check: The DC and effect depend on the task you attempt.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Task Heal</th><th>DC</th></tr><tr><td>First aid</td><td>15</td></tr><tr><td>Long-term care</td><td>15</td></tr><tr><td>Treat wound from caltrop, <i>spike growth,</i> or <i>spike stones</i></td><td>15</td></tr><tr><td>Treat poison</td><td>Poison’s save DC</td></tr><tr><td>Treat disease</td><td>Disease’s save DC</td></tr></tbody></table>

First Aid: You usually use first aid to save a dying character. If a character has negative hit points and is losing hit points (at the rate of 1 per round, 1 per hour, or 1 per day), you can make him or her stable. A stable character regains no hit points but stops losing them.

Long-Term Care: Providing long-term care means treating a wounded person for a day or more. If your Heal check is successful, the patient recovers hit points or ability score points (lost to ability damage) at twice the normal rate: 2 hit points per level for a full 8 hours of rest in a day, or 4 hit points per level for each full day of complete rest; 2 ability score points for a full 8 hours of rest in a day, or 4 ability score points for each full day of complete rest.

You can tend as many as six patients at a time. You need a few items and supplies (bandages, salves, and so on) that are easy to come by in settled lands. Giving long-term care counts as light activity for the healer. You cannot give long-term care to yourself.

Treat Wound from Caltrop, Spike Growth, or Spike Stones: A creature wounded by stepping on a caltrop moves at one-half normal speed. A successful Heal check removes this movement penalty.

A creature wounded by a spike growth or spike stones spell must succeed on a Reflex save or take injuries that reduce his speed by one-third. Another character can remove this penalty by taking 10 minutes to dress the victim’s injuries and succeeding on a Heal check against the spell’s save DC.

Treat Poison: To treat poison means to tend a single character who has been poisoned and who is going to take more damage from the poison (or suffer some other effect). Every time the poisoned character makes a saving throw against the poison, you make a Heal check. The poisoned character uses your check result or his or her saving throw, whichever is higher.

Treat Disease: To treat a disease means to tend a single diseased character. Every time he or she makes a saving throw against disease effects, you make a Heal check. The diseased character uses your check result or his or her saving throw, whichever is higher.

Action: Providing first aid, treating a wound, or treating poison is a standard action. Treating a disease or tending a creature wounded by a spike growth or spike stones spell takes 10 minutes of work. Providing long-term care requires 8 hours of light activity.

Try Again: Varies. Generally speaking, you can’t try a Heal check again without proof of the original check’s failure. You can always retry a check to provide first aid, assuming the target of the previous attempt is still alive.

Special: A character with the Self-Sufficient feat gets a +2 bonus on Heal checks.

A healer’s kit gives you a +2 circumstance bonus on Heal checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Heal","source_heading":"Wis"}'::jsonb),
('esconder_se','Esconder-se','DES',false,true,'Check: Your Hide check is opposed by the Spot check of anyone who might see you. You can move up to one-half your normal speed and hide at no penalty. When moving at a speed greater than one-half but less than your normal speed, you take a –5 penalty. It’s practically impossible (–20 penalty) to hide while attacking, running or charging.

A creature larger or smaller than Medium takes a size bonus or penalty on Hide checks depending on its size category: Fine +16, Diminutive +12, Tiny +8, Small +4, Large –4, Huge –8, Gargantuan –12, Colossal –16.

You need cover or concealment in order to attempt a Hide check. Total cover or total concealment usually (but not always; see Special, below) obviates the need for a Hide check, since nothing can see you anyway.

If people are observing you, even casually, you can’t hide. You can run around a corner or behind cover so that you’re out of sight and then hide, but the others then know at least where you went.

If your observers are momentarily distracted (such as by a Bluff check; see below), though, you can attempt to hide. While the others turn their attention from you, you can attempt a Hide check if you can get to a hiding place of some kind. (As a general guideline, the hiding place has to be within 1 foot per rank you have in Hide.) This check, however, is made at a –10 penalty because you have to move fast.

Sniping: If you’ve already successfully hidden at least 10 feet from your target, you can make one ranged attack, then immediately hide again. You take a –20 penalty on your Hide check to conceal yourself after the shot.

Creating a Diversion to Hide: You can use Bluff to help you hide. A successful Bluff check can give you the momentary diversion you need to attempt a Hide check while people are aware of you.

Action: Usually none. Normally, you make a Hide check as part of movement, so it doesn’t take a separate action. However, hiding immediately after a ranged attack (see Sniping, above) is a move action.

Special: If you are invisible, you gain a +40 bonus on Hide checks if you are immobile, or a +20 bonus on Hide checks if you’re moving.

If you have the Stealthy feat, you get a +2 bonus on Hide checks.

A 13th-level ranger can attempt a Hide check in any sort of natural terrain, even if it doesn’t grant cover or concealment. A 17thlevel ranger can do this even while being observed.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Hide","source_heading":"Dex; Armor Check Penalty"}'::jsonb),
('intimidacao','Intimidação','CAR',false,false,'Check: You can change another’s behavior with a successful check. Your Intimidate check is opposed by the target’s modified level check (1d20 + character level or Hit Dice + target’s Wisdom bonus \[if any\] + target’s modifiers on saves against fear). If you beat your target’s check result, you may treat the target as friendly, but only for the purpose of actions taken while it remains intimidated. (That is, the target retains its normal attitude, but will chat, advise, offer limited help, or advocate on your behalf while intimidated. See the Diplomacy skill, above, for additional details.) The effect lasts as long as the target remains in your presence, and for 1d6×10 minutes afterward. After this time, the target’s default attitude toward you shifts to unfriendly (or, if normally unfriendly, to hostile).

If you fail the check by 5 or more, the target provides you with incorrect or useless information, or otherwise frustrates your efforts.

Demoralize Opponent: You can also use Intimidate to weaken an opponent’s resolve in combat. To do so, make an Intimidate check opposed by the target’s modified level check (see above). If you win, the target becomes shaken for 1 round. A shaken character takes a –2 penalty on attack rolls, ability checks, and saving throws. You can intimidate only an opponent that you threaten in melee combat and that can see you.

Action: Varies. Changing another’s behavior requires 1 minute of interaction. Intimidating an opponent in combat is a standard action.

Try Again: Optional, but not recommended because retries usually do not work. Even if the initial check succeeds, the other character can be intimidated only so far, and a retry doesn’t help. If the initial check fails, the other character has probably become more firmly resolved to resist the intimidator, and a retry is futile.

Special: You gain a +4 bonus on your Intimidate check for every size category that you are larger than your target. Conversely, you take a –4 penalty on your Intimidate check for every size category that you are smaller than your target.

A character immune to fear can’t be intimidated, nor can nonintelligent creatures.

If you have the Persuasive feat, you get a +2 bonus on Intimidate checks.

Synergy: If you have 5 or more ranks in Bluff, you get a +2 bonus on Intimidate checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Intimidate","source_heading":"Cha"}'::jsonb),
('srd35_skill_jump','Saltar','FOR',false,true,'Check: The DC and the distance you can cover vary according to the type of jump you are attempting (see below).

Your Jump check is modified by your speed. If your speed is 30 feet then no modifier based on speed applies to the check. If your speed is less than 30 feet, you take a –6 penalty for every 10 feet of speed less than 30 feet. If your speed is greater than 30 feet, you gain a +4 bonus for every 10 feet beyond 30 feet.

All Jump DCs given here assume that you get a running start, which requires that you move at least 20 feet in a straight line before attempting the jump. If you do not get a running start, the DC for the jump is doubled.

Distance moved by jumping is counted against your normal maximum movement in a round.

If you have ranks in Jump and you succeed on a Jump check, you land on your feet (when appropriate). If you attempt a Jump check untrained, you land prone unless you beat the DC by 5 or more.

Long Jump: A long jump is a horizontal jump, made across a gap like a chasm or stream. At the midpoint of the jump, you attain a vertical height equal to one-quarter of the horizontal distance. The DC for the jump is equal to the distance jumped (in feet).

If your check succeeds, you land on your feet at the far end. If you fail the check by less than 5, you don’t clear the distance, but you can make a DC 15 Reflex save to grab the far edge of the gap. You end your movement grasping the far edge. If that leaves you dangling over a chasm or gap, getting up requires a move action and a DC 15 Climb check.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Long Jump Distance</th><th>Jump DC<sup>1</sup></th></tr><tr><td>5 feet</td><td>5</td></tr><tr><td>10 feet</td><td>10</td></tr><tr><td>15 feet</td><td>15</td></tr><tr><td>20 feet</td><td>20</td></tr><tr><td>25 feet</td><td>25</td></tr><tr><td>30 feet</td><td>30</td></tr><tr><td colspan="2">1 Requires a 20-foot running start. Without a running start, double the DC.</td></tr></tbody></table>

High Jump: A high jump is a vertical leap made to reach a ledge high above or to grasp something overhead. The DC is equal to 4 times the distance to be cleared.

If you jumped up to grab something, a successful check indicates that you reached the desired height. If you wish to pull yourself up, you can do so with a move action and a DC 15 Climb check. If you fail the Jump check, you do not reach the height, and you land on your feet in the same spot from which you jumped. As with a long jump, the DC is doubled if you do not get a running start of at least 20 feet.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>High Jump Distance<sup>1</sup></th><th>Jump DC<sup>2</sup></th></tr><tr><td>1 foot</td><td>4</td></tr><tr><td>2 feet</td><td>8</td></tr><tr><td>3 feet</td><td>12</td></tr><tr><td>4 feet</td><td>16</td></tr><tr><td>5 feet</td><td>20</td></tr><tr><td>6 feet</td><td>24</td></tr><tr><td>7 feet</td><td>28</td></tr><tr><td>8 feet</td><td>32</td></tr><tr><td colspan="2">1 Not including vertical reach; see below.</td></tr><tr><td colspan="2">2 Requires a 20-foot running start. Without a running start, double the DC.</td></tr></tbody></table>

Obviously, the difficulty of reaching a given height varies according to the size of the character or creature. The maximum vertical reach (height the creature can reach without jumping) for an average creature of a given size is shown on the table below. (As a Medium creature, a typical human can reach 8 feet without jumping.)

Quadrupedal creatures don’t have the same vertical reach as a bipedal creature; treat them as being one size category smaller.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Creature Size</th><th>Vertical Reach</th></tr><tr><td>Colossal</td><td>128 ft.</td></tr><tr><td>Gargantuan</td><td>64 ft.</td></tr><tr><td>Huge</td><td>32 ft.</td></tr><tr><td>Large</td><td>16 ft.</td></tr><tr><td>Medium</td><td>8 ft.</td></tr><tr><td>Small</td><td>4 ft.</td></tr><tr><td>Tiny</td><td>2 ft.</td></tr><tr><td>Diminutive</td><td>1 ft.</td></tr><tr><td>Fine</td><td>1/2 ft.</td></tr></tbody></table>

Hop Up: You can jump up onto an object as tall as your waist, such as a table or small boulder, with a DC 10 Jump check. Doing so counts as 10 feet of movement, so if your speed is 30 feet, you could move 20 feet, then hop up onto a counter. You do not need to get a running start to hop up, so the DC is not doubled if you do not get a running start.

Jumping Down: If you intentionally jump from a height, you take less damage than you would if you just fell. The DC to jump down from a height is 15. You do not have to get a running start to jump down, so the DC is not doubled if you do not get a running start.

If you succeed on the check, you take falling damage as if you had dropped 10 fewer feet than you actually did.

Action: None. A Jump check is included in your movement, so it is part of a move action. If you run out of movement mid-jump, your next action (either on this turn or, if necessary, on your next turn) must be a move action to complete the jump.

Special: Effects that increase your movement also increase your jumping distance, since your check is modified by your speed.

If you have the Run feat, you get a +4 bonus on Jump checks for any jumps made after a running start.

A halfling has a +2 racial bonus on Jump checks because halflings are agile and athletic.

If you have the Acrobatic feat, you get a +2 bonus on Jump checks.

Synergy: If you have 5 or more ranks in Tumble, you get a +2 bonus on Jump checks.

If you have 5 or more ranks in Jump, you get a +2 bonus on Tumble checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Jump","source_heading":"Str; Armor Check Penalty"}'::jsonb),
('srd35_skill_knowledge','Conhecimento','INT',true,false,'Like the Craft and Profession skills, Knowledge actually encompasses a number of unrelated skills. Knowledge represents a study of some body of lore, possibly an academic or even scientific discipline.

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

Untrained: An untrained Knowledge check is simply an Intelligence check. Without actual training, you know only common knowledge (DC 10 or lower).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Knowledge","source_heading":"Int; Trained Only"}'::jsonb),
('ouvir','Ouvir','SAB',false,false,'Check: Your Listen check is either made against a DC that reflects how quiet the noise is that you might hear, or it is opposed by your target’s Move Silently check.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Listen DC</th><th>Sound</th></tr><tr><td>–10</td><td>A battle</td></tr><tr><td>0</td><td>People talking<sup>1</sup></td></tr><tr><td>5</td><td>A person in medium armor walking at a slow pace (10 ft./round) trying not to make any noise.</td></tr><tr><td>10</td><td>An unarmored person walking at a slow pace (15 ft./round) trying not to make any noise</td></tr><tr><td>15</td><td>A 1st-level rogue using Move Silently to sneak past the listener</td></tr><tr><td>15</td><td>People whispering<sup>1</sup></td></tr><tr><td>19</td><td>A cat stalking</td></tr><tr><td>30</td><td>An owl gliding in for a kill</td></tr><tr><td colspan="2">1 If you beat the DC by 10 or more, you can make out what’s being said, assuming that you understand the language.</td></tr></tbody></table>

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Listen DC Modifier</th><th>Condition</th></tr><tr><td>+5</td><td>Through a door</td></tr><tr><td>+15</td><td>Through a stone wall</td></tr><tr><td>+1</td><td>Per 10 feet of distance</td></tr><tr><td>+5</td><td>Listener distracted</td></tr></tbody></table>

In the case of people trying to be quiet, the DCs given on the table could be replaced by Move Silently checks, in which case the indicated DC would be their average check result.

Action: Varies. Every time you have a chance to hear something in a reactive manner (such as when someone makes a noise or you move into a new area), you can make a Listen check without using an action. Trying to hear something you failed to hear previously is a move action.

Try Again: Yes. You can try to hear something that you failed to hear previously with no penalty.

Special: When several characters are listening to the same thing, a single 1d20 roll can be used for all the individuals’ Listen checks.

A fascinated creature takes a –4 penalty on Listen checks made as reactions.

If you have the Alertness feat, you get a +2 bonus on Listen checks.

A ranger gains a bonus on Listen checks when using this skill against a favored enemy.

An elf, gnome, or halfling has a +2 racial bonus on Listen checks.

A half-elf has a +1 racial bonus on Listen checks..

A sleeping character may make Listen checks at a –10 penalty. A successful check awakens the sleeper.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Listen","source_heading":"Wis"}'::jsonb),
('mover_silenciosamente','Mover-se em Silêncio','DES',false,true,'Check: Your Move Silently check is opposed by the Listen check of anyone who might hear you. You can move up to one-half your normal speed at no penalty. When moving at a speed greater than one-half but less than your full speed, you take a –5 penalty. It’s practically impossible (–20 penalty) to move silently while running or charging.

Noisy surfaces, such as bogs or undergrowth, are tough to move silently across. When you try to sneak across such a surface, you take a penalty on your Move Silently check as indicated below.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Surface</th><th>Check Modifier</th></tr><tr><td>Noisy (scree, shallow or deep bog, undergrowth, dense rubble)</td><td>–2</td></tr><tr><td>Very noisy (dense undergrowth, deep snow)</td><td>–5</td></tr></tbody></table>

Action: None. A Move Silently check is included in your movement or other activity, so it is part of another action.

Special: The master of a cat familiar gains a +3 bonus on Move Silently checks.

A halfling has a +2 racial bonus on Move Silently checks.

If you have the Stealthy feat, you get a +2 bonus on Move Silently checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Move Silently","source_heading":"Dex; Armor Check Penalty"}'::jsonb),
('srd35_skill_open_lock','Abrir Fechaduras','DES',true,false,'Attempting an Open Lock check without a set of thieves’ tools imposes a –2 circumstance penalty on the check, even if a simple tool is employed. If you use masterwork thieves’ tools, you gain a +2 circumstance bonus on the check.

Check: The DC for opening a lock varies from 20 to 40, depending on the quality of the lock, as given on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Lock</th><th>DC</th><th>Lock</th><th>DC</th></tr><tr><td>Very simple lock</td><td>20</td><td>Good lock</td><td>30</td></tr><tr><td>Average lock</td><td>25</td><td>Amazing lock</td><td>40</td></tr></tbody></table>

Action: Opening a lock is a full-round action.

Special: If you have the Nimble Fingers feat, you get a +2 bonus on Open Lock checks.

Untrained: You cannot pick locks untrained, but you might successfully force them open.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Open Lock","source_heading":"Dex; Trained Only"}'::jsonb),
('srd35_skill_perform','Atuação','CAR',false,false,'Like Craft, Knowledge, and Profession, Perform is actually a number of separate skills.

You could have several Perform skills, each with its own ranks, each purchased as a separate skill.

Each of the nine categories of the Perform skill includes a variety of methods, instruments, or techniques, a small list of which is provided for each category below.

- Act (comedy, drama, mime)
- Comedy (buffoonery, limericks, joke-telling)
- Dance (ballet, waltz, jig)
- Keyboard instruments (harpsichord, piano, pipe organ)
- Oratory (epic, ode, storytelling)
- Percussion instruments (bells, chimes, drums, gong)
- String instruments (fiddle, harp, lute, mandolin)
- Wind instruments (flute, pan pipes, recorder, shawm, trumpet)
- Sing (ballad, chant, melody)

Check: You can impress audiences with your talent and skill.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Perform DC</th><th>Performance</th></tr><tr><td>10</td><td>Routine performance. Trying to earn money by playing in public is essentially begging. You can earn 1d10 cp/day.</td></tr><tr><td>15</td><td>Enjoyable performance. In a prosperous city, you can earn 1d10 sp/day.</td></tr><tr><td>20</td><td>Great performance. In a prosperous city, you can earn 3d10 sp/day. In time, you may be invited to join a professional troupe and may develop a regional reputation.</td></tr><tr><td>25</td><td>Memorable performance. In a prosperous city, you can earn 1d6 gp/day. In time, you may come to the attention of noble patrons and develop a national reputation.</td></tr><tr><td>30</td><td>Extraordinary performance. In a prosperous city, you can earn 3d6 gp/day. In time, you may draw attention from distant potential patrons, or even from extraplanar beings.</td></tr></tbody></table>

A masterwork musical instrument gives you a +2 circumstance bonus on Perform checks that involve its use.

Action: Varies. Trying to earn money by playing in public requires anywhere from an evening’s work to a full day’s performance. The bard’s special Perform-based abilities are described in that class’s description.

Try Again: Yes. Retries are allowed, but they don’t negate previous failures, and an audience that has been unimpressed in the past is likely to be prejudiced against future performances. (Increase the DC by 2 for each previous failure.)

Special: A bard must have at least 3 ranks in a Perform skill to inspire courage in his allies, or to use his countersong or his fascinate ability. A bard needs 6 ranks in a Perform skill to inspire competence, 9 ranks to use his suggestion ability, 12 ranks to inspire greatness, 15 ranks to use his song of freedom ability, 18 ranks to inspire heroics, and 21 ranks to use his mass suggestion ability. See Bardic Music in the bard class description.

In addition to using the Perform skill, you can entertain people with sleight of hand, tumbling, tightrope walking, and spells (especially illusions).','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Perform","source_heading":"Cha"}'::jsonb),
('profissao','Profissão','SAB',true,false,'Like Craft, Knowledge, and Perform, Profession is actually a number of separate skills. You could have several Profession skills, each with its own ranks, each purchased as a separate skill. While a Craft skill represents ability in creating or making an item, a Profession skill represents an aptitude in a vocation requiring a broader range of less specific knowledge.

Check: You can practice your trade and make a decent living, earning about half your Profession check result in gold pieces per week of dedicated work. You know how to use the tools of your trade, how to perform the profession’s daily tasks, how to supervise helpers, and how to handle common problems.

Action: Not applicable. A single check generally represents a week of work.

Try Again: Varies. An attempt to use a Profession skill to earn an income cannot be retried. You are stuck with whatever weekly wage your check result brought you. Another check may be made after a week to determine a new income for the next period of time. An attempt to accomplish some specific task can usually be retried.

Untrained: Untrained laborers and assistants (that is, characters without any ranks in Profession) earn an average of 1 silver piece per day.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Profession","source_heading":"Wis; Trained Only"}'::jsonb),
('cavalgar','Cavalgar','DES',false,false,'If you attempt to ride a creature that is ill suited as a mount, you take a –5 penalty on your Ride checks.

Check: Typical riding actions don’t require checks. You can saddle, mount, ride, and dismount from a mount without a problem.

The following tasks do require checks.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Task</th><th>Ride DC</th><th>Task</th><th>Ride DC</th></tr><tr><td>Guide with knees</td><td>5</td><td>Leap</td><td>15</td></tr><tr><td>Stay in saddle</td><td>5</td><td>Spur mount</td><td>15</td></tr><tr><td>Fight with warhorse</td><td>10</td><td>Control mount in battle</td><td>20</td></tr><tr><td>Cover</td><td>15</td><td>Fast mount or dismount</td><td>20<sup>1</sup></td></tr><tr><td>Soft fall</td><td>15</td><td></td><td></td></tr><tr><td colspan="4">1 Armor check penalty applies.</td></tr></tbody></table>

Guide with Knees: You can react instantly to guide your mount with your knees so that you can use both hands in combat. Make your Ride check at the start of your turn. If you fail, you can use only one hand this round because you need to use the other to control your mount.

Stay in Saddle: You can react instantly to try to avoid falling when your mount rears or bolts unexpectedly or when you take damage. This usage does not take an action.

Fight with Warhorse: If you direct your war-trained mount to attack in battle, you can still make your own attack or attacks normally. This usage is a free action.

Cover: You can react instantly to drop down and hang alongside your mount, using it as cover. You can’t attack or cast spells while using your mount as cover. If you fail your Ride check, you don’t get the cover benefit. This usage does not take an action.

Soft Fall: You can react instantly to try to take no damage when you fall off a mount—when it is killed or when it falls, for example. If you fail your Ride check, you take 1d6 points of falling damage. This usage does not take an action.

Leap: You can get your mount to leap obstacles as part of its movement. Use your Ride modifier or the mount’s Jump modifier, whichever is lower, to see how far the creature can jump. If you fail your Ride check, you fall off the mount when it leaps and take the appropriate falling damage (at least 1d6 points). This usage does not take an action, but is part of the mount’s movement.

Spur Mount: You can spur your mount to greater speed with a move action. A successful Ride check increases the mount’s speed by 10 feet for 1 round but deals 1 point of damage to the creature. You can use this ability every round, but each consecutive round of additional speed deals twice as much damage to the mount as the previous round (2 points, 4 points, 8 points, and so on).

Control Mount in Battle: As a move action, you can attempt to control a light horse, pony, heavy horse, or other mount not trained for combat riding while in battle. If you fail the Ride check, you can do nothing else in that round. You do not need to roll for warhorses or warponies.

Fast Mount or Dismount: You can attempt to mount or dismount from a mount of up to one size category larger than yourself as a free action, provided that you still have a move action available that round. If you fail the Ride check, mounting or dismounting is a move action. You can’t use fast mount or dismount on a mount more than one size category larger than yourself.

Action: Varies. Mounting or dismounting normally is a move action. Other checks are a move action, a free action, or no action at all, as noted above.

Special: If you are riding bareback, you take a –5 penalty on Ride checks.

If your mount has a military saddle you get a +2 circumstance bonus on Ride checks related to staying in the saddle.

The Ride skill is a prerequisite for the feats Mounted Archery, Mounted Combat, Ride-By Attack, Spirited Charge,

Trample.

If you have the Animal Affinity feat, you get a +2 bonus on Ride checks.

Synergy: If you have 5 or more ranks in Handle Animal, you get a +2 bonus on Ride checks.','https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/skills-ii.md','{"original_name":"Ride","source_heading":"Dex"}'::jsonb)
on conflict(id) do update set nome=case when srd_skills.id like 'srd35_skill_%' then excluded.nome else srd_skills.nome end,atributo=excluded.atributo,treinada_apenas=excluded.treinada_apenas,penalidade_armadura=excluded.penalidade_armadura,descricao=excluded.descricao,srd_source_url=excluded.srd_source_url,dados_tecnicos=excluded.dados_tecnicos;
