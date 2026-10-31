-- SRD 3.5 Feats: Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md
insert into public.srd_feats(id,nome,descricao,requisitos,exige_parametro) values
('srd35_feat_greater_weapon_focus','Greater Weapon Focus','Choose one type of weapon for which you have already selected Weapon Focus. You can also choose unarmed strike or grapple as your weapon for purposes of this feat.

Prerequisites: Proficiency with selected weapon, Weapon Focus with selected weapon, fighter level 8th.

Benefit: You gain a +1 bonus on all attack rolls you make using the selected weapon. This bonus stacks with other bonuses on attack rolls, including the one from Weapon Focus (see below).

Special: You can gain Greater Weapon Focus multiple times. Its effects do not stack. Each time you take the feat, it applies to a new type of weapon.

A fighter must have Greater Weapon Focus with a given weapon to gain the Greater Weapon Specialization feat for that weapon.

A fighter may select Greater Weapon Focus as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_greater_weapon_specialization','Greater Weapon Specialization','Choose one type of weapon for which you have already selected Weapon Specialization. You can also choose unarmed strike or grapple as your weapon for purposes of this feat.

Prerequisites: Proficiency with selected weapon, Greater Weapon Focus with selected weapon, Weapon Focus with selected weapon, Weapon Specialization with selected weapon, fighter level 12th.

Benefit: You gain a +2 bonus on all damage rolls you make using the selected weapon. This bonus stacks with other bonuses on damage rolls, including the one from Weapon Specialization (see below).

Special: You can gain Greater Weapon Specialization multiple times. Its effects do not stack. Each time you take the feat, it applies to a new type of weapon.

A fighter may select Greater Weapon Specialization as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_heighten_spell','Heighten Spell','Benefit: A heightened spell has a higher spell level than normal (up to a maximum of 9th level). Unlike other metamagic feats, Heighten Spell actually increases the effective level of the spell that it modifies. All effects dependent on spell level (such as saving throw DCs and ability to penetrate a lesser globe of invulnerability) are calculated according to the heightened level. The heightened spell is as difficult to prepare and cast as a spell of its effective level.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_bull_rush','Improved Bull Rush','Prerequisites: Str 13, Power Attack.

Benefit: When you perform a bull rush you do not provoke an attack of opportunity from the defender. You also gain a +4 bonus on the opposed Strength check you make to push back the defender.

Special: A fighter may select Improved Bull Rush as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_counterspell','Improved Counterspell','Benefit: When counterspelling, you may use a spell of the same school that is one or more spell levels higher than the target spell.

Normal: Without this feat, you may counter a spell only with the same spell or with a spell specifically designated as countering the target spell.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_critical','Improved Critical','Choose one type of weapon.

Prerequisite: Proficient with weapon, base attack bonus +8.

Benefit: When using the weapon you selected, your threat range is doubled.

Special: You can gain Improved Critical multiple times. The effects do not stack. Each time you take the feat, it applies to a new type of weapon.

This effect doesn’t stack with any other effect that expands the threat range of a weapon.

A fighter may select Improved Critical as one of his fighter bonus feats.','{"type":"General","raw":"Proficient with weapon, base attack bonus +8.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_disarm','Improved Disarm','Prerequisites: Int 13, Combat Expertise.

Benefit: You do not provoke an attack of opportunity when you attempt to disarm an opponent, nor does the opponent have a chance to disarm you. You also gain a +4 bonus on the opposed attack roll you make to disarm your opponent.

Normal: See the normal disarm rules.

Special: A fighter may select Improved Disarm as one of his fighter bonus feats.

A monk may select Improved Disarm as a bonus feat at 6th level, even if she does not meet the prerequisites.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_familiar','Improved Familiar','This feat allows spellcasters to acquire a new familiar from a nonstandard list, but only when they could normally acquire a new familiar.

Prerequisites: Ability to acquire a new familiar, compatible alignment, sufficiently high level (see below).

Benefit: When choosing a familiar, the creatures listed below are also available to the spellcaster. The spellcaster may choose a familiar with an alignment up to one step away on each of the alignment axes (lawful through chaotic, good through evil).

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Familiar</th><th>Alignment</th><th>Arcane Spellcaster Level</th></tr><tr><td>Shocker lizard</td><td>Neutral</td><td>5th</td></tr><tr><td>Stirge</td><td>Neutral</td><td>5th</td></tr><tr><td>Formian worker</td><td>Lawful neutral</td><td>7th</td></tr><tr><td>Imp</td><td>Lawful evil</td><td>7th</td></tr><tr><td>Pseudodragon</td><td>Neutral good</td><td>7th</td></tr><tr><td>Quasit</td><td>Chaotic evil</td><td>7th</td></tr></tbody></table>

Improved familiars otherwise use the rules for regular familiars, with two exceptions: If the creature’s type is something other than animal, its type does not change; and improved familiars do not gain the ability to speak with other creatures of their kind (although many of them already have the ability to communicate).

The list in the table above presents only a few possible improved familiars. Almost any creature of the same general size and power as those on the list makes a suitable familiar. Nor is the master’s alignment the only possible categorization. For instance, improved familiars could be assigned by the master’s creature type or subtype, as shown below.

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th>Familiar</th><th>Type/Subtype</th><th>Arcane Spellcaster Level</th></tr><tr><td>Celestial hawk<sup>1</sup></td><td>Good</td><td>3rd</td></tr><tr><td>Fiendish Tiny viper snake<sup>2</sup></td><td>Evil</td><td>3rd</td></tr><tr><td>Air elemental, Small</td><td>Air</td><td>5th</td></tr><tr><td>Earth elemental, Small</td><td>Earth</td><td>5th</td></tr><tr><td>Fire elemental, Small</td><td>Fire</td><td>5th</td></tr><tr><td>Shocker lizard</td><td>Electricity</td><td>5th</td></tr><tr><td>Water elemental, Small</td><td>Water</td><td>5th</td></tr><tr><td>Homunculus<sup>3</sup></td><td>Undead</td><td>7th</td></tr><tr><td>Ice mephit</td><td>Cold</td><td>7th</td></tr><tr><td colspan="3">1 Or other celestial animal from the standard familiar list.</td></tr><tr><td colspan="3">2 Or other fiendish animal from the standard familiar list.</td></tr><tr><td colspan="3">3 The master must first create the homunculus, substituting ichor or another part of the master’s body for blood if necessary.</td></tr></tbody></table>','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_feint','Improved Feint','Prerequisites: Int 13, Combat Expertise.

Benefit: You can make a Bluff check to feint in combat as a move action.

Normal: Feinting in combat is a standard action.

A fighter may select Improved Feint as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_grapple','Improved Grapple','Prerequisites: Dex 13, Improved Unarmed Strike.

Benefit: You do not provoke an attack of opportunity when you make a touch attack to start a grapple. You also gain a +4 bonus on all grapple checks, regardless of whether you started the grapple.

Normal: Without this feat, you provoke an attack of opportunity when you make a touch attack to start a grapple.

Special: A fighter may select Improved Grapple as one of his fighter bonus feats.

A monk may select Improved Grapple as a bonus feat at 1st level, even if she does not meet the prerequisites.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('iniciativa_aprimorada','Iniciativa Aprimorada','Benefit: You get a +4 bonus on initiative checks.

Special: A fighter may select Improved Initiative as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_overrun','Improved Overrun','Prerequisites: Str 13, Power Attack.

Benefit: When you attempt to overrun an opponent, the target may not choose to avoid you. You also gain a +4 bonus on your Strength check to knock down your opponent.

Normal: Without this feat, the target of an overrun can choose to avoid you or to block you.

Special: A fighter may select Improved Overrun as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_precise_shot','Improved Precise Shot','Prerequisites: Dex 19, Point Blank Shot, Precise Shot, base attack bonus +11.

Benefit: Your ranged attacks ignore the AC bonus granted to targets by anything less than total cover, and the miss chance granted to targets by anything less than total concealment. Total cover and total concealment provide their normal benefits against your ranged attacks.

In addition, when you shoot or throw ranged weapons at a grappling opponent, you automatically strike at the opponent you have chosen.

Normal: See the normal rules on the effects of cover and concealment. Without this feat, a character who shoots or throws a ranged weapon at a target involved in a grapple must roll randomly to see which grappling combatant the attack strikes.

Special: A fighter may select Improved Precise Shot as one of his fighter bonus feats.

An 11th-level ranger who has chosen the archery combat style is treated as having Improved Precise Shot, even if he does not have the prerequisites for it, but only when he is wearing light or no armor.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_shield_bash','Improved Shield Bash','Prerequisite: Shield Proficiency.

Benefit: When you perform a shield bash, you may still apply the shield’s shield bonus to your AC.

Normal: Without this feat, a character who performs a shield bash loses the shield’s shield bonus to AC until his or her next turn.

Special: A fighter may select Improved Shield Bash as one of his fighter bonus feats.','{"type":"General","raw":"Shield Proficiency.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_sunder','Improved Sunder','Prerequisites: Str 13, Power Attack.

Benefit: When you strike at an object held or carried by an opponent (such as a weapon or shield), you do not provoke an attack of opportunity.

You also gain a +4 bonus on any attack roll made to attack an object held or carried by another character.

Normal: Without this feat, you provoke an attack of opportunity when you strike at an object held or carried by another character.

Special: A fighter may select Improved Sunder as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_trip','Improved Trip','Prerequisites: Int 13, Combat Expertise.

Benefit: You do not provoke an attack of opportunity when you attempt to trip an opponent while you are unarmed. You also gain a +4 bonus on your Strength check to trip your opponent.

If you trip an opponent in melee combat, you immediately get a melee attack against that opponent as if you hadn’t used your attack for the trip attempt.

Normal: Without this feat, you provoke an attack of opportunity when you attempt to trip an opponent while you are unarmed.

Special: At 6th level, a monk may select Improved Trip as a bonus feat, even if she does not have the prerequisites.

A fighter may select Improved Trip as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_turning','Improved Turning','Prerequisite: Ability to turn or rebuke creatures.

Benefit: You turn or rebuke creatures as if you were one level higher than you are in the class that grants you the ability.','{"type":"General","raw":"Ability to turn or rebuke creatures.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_two_weapon_fighting','Improved Two-Weapon Fighting','Prerequisites: Dex 17, Two-Weapon Fighting, base attack bonus +6.

Benefit: In addition to the standard single extra attack you get with an off-hand weapon, you get a second attack with it, albeit at a –5 penalty.

Normal: Without this feat, you can only get a single extra attack with an off-hand weapon.

Special: A fighter may select Improved Two-Weapon Fighting as one of his fighter bonus feats.

A 6th-level ranger who has chosen the two-weapon combat style is treated as having Improved Two-Weapon Fighting, even if he does not have the prerequisites for it, but only when he is wearing light or no armor.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_improved_unarmed_strike','Improved Unarmed Strike','Benefit: You are considered to be armed even when unarmed —that is, you do not provoke attacks or opportunity from armed opponents when you attack them while unarmed. However, you still get an attack of opportunity against any opponent who makes an unarmed attack on you.

In addition, your unarmed strikes can deal lethal or nonlethal damage, at your option.

Normal: Without this feat, you are considered unarmed when attacking with an unarmed strike, and you can deal only nonlethal damage with such an attack.

Special: A monk automatically gains Improved Unarmed Strike as a bonus feat at 1st level. She need not select it.

A fighter may select Improved Unarmed Strike as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_investigator','Investigator','Benefit: You get a +2 bonus on all Gather Information checks and Search checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_iron_will','Iron Will','Benefit: You get a +2 bonus on all Will saving throws.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_leadership','Leadership','Prerequisite: Character level 6th.

Benefits: Having this feat enables the character to attract loyal companions and devoted followers, subordinates who assist her. See the table below for what sort of cohort and how many followers the character can recruit.

Leadership Modifiers: Several factors can affect a character’s Leadership score, causing it to vary from the base score (character level + Cha modifier). A character’s reputation (from the point of view of the cohort or follower he is trying to attract) raises or lowers his Leadership score:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Leader’s Reputation</th><th>Modifier</th></tr><tr><td>Great renown</td><td>+2</td></tr><tr><td>Fairness and generosity</td><td>+1</td></tr><tr><td>Special power</td><td>+1</td></tr><tr><td>Failure</td><td>–1</td></tr><tr><td>Aloofness</td><td>–1</td></tr><tr><td>Cruelty</td><td>–2</td></tr></tbody></table>

Other modifiers may apply when the character tries to attract a cohort:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>The Leader . . .</th><th>Modifier</th></tr><tr><td>Has a familiar, special mount, or animal companion</td><td>–2</td></tr><tr><td>Recruits a cohort of a different alignment</td><td>–1</td></tr><tr><td>Caused the death of a cohort</td><td>–2*</td></tr><tr><td colspan="2">* Cumulative per cohort killed.</td></tr></tbody></table>

Followers have different priorities from cohorts. When the character tries to attract a new follower, use any of the following modifiers that apply.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>The Leader . . .</th><th>Modifier</th></tr><tr><td>Has a stronghold, base of operations, guildhouse, or the like</td><td>+2</td></tr><tr><td>Moves around a lot</td><td>–1</td></tr><tr><td>Caused the death of other followers</td><td>–1.</td></tr></tbody></table>

<table data-debug="no-caption" class="full-width-table"><tbody><tr><th rowspan="2">Leadership Score</th><th rowspan="2">Cohort Level</th><th colspan="6" class="middle-line">Number of Followers by Level</th></tr><tr><th>1st</th><th>2nd</th><th>3rd</th><th>4th</th><th>5th</th><th>6th</th></tr><tr><td>1 or lower</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>2</td><td>1st</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>3</td><td>2nd</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>4</td><td>3rd</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>5</td><td>3rd</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>6</td><td>4th</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>7</td><td>5th</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>8</td><td>5th</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>9</td><td>6th</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>10</td><td>7th</td><td>5</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>11</td><td>7th</td><td>6</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>12</td><td>8th</td><td>8</td><td>—</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>13</td><td>9th</td><td>10</td><td>1</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>14</td><td>10th</td><td>15</td><td>1</td><td>—</td><td>—</td><td>—</td><td>—</td></tr><tr><td>15</td><td>10th</td><td>20</td><td>2</td><td>1</td><td>—</td><td>—</td><td>—</td></tr><tr><td>16</td><td>11th</td><td>25</td><td>2</td><td>1</td><td>—</td><td>—</td><td>—</td></tr><tr><td>17</td><td>12th</td><td>30</td><td>3</td><td>1</td><td>1</td><td>—</td><td>—</td></tr><tr><td>18</td><td>12th</td><td>35</td><td>3</td><td>1</td><td>1</td><td>—</td><td>—</td></tr><tr><td>19</td><td>13th</td><td>40</td><td>4</td><td>2</td><td>1</td><td>1</td><td>—</td></tr><tr><td>20</td><td>14th</td><td>50</td><td>5</td><td>3</td><td>2</td><td>1</td><td>—</td></tr><tr><td>21</td><td>15th</td><td>60</td><td>6</td><td>3</td><td>2</td><td>1</td><td>1</td></tr><tr><td>22</td><td>15th</td><td>75</td><td>7</td><td>4</td><td>2</td><td>2</td><td>1</td></tr><tr><td>23</td><td>16th</td><td>90</td><td>9</td><td>5</td><td>3</td><td>2</td><td>1</td></tr><tr><td>24</td><td>17th</td><td>110</td><td>11</td><td>6</td><td>3</td><td>2</td><td>1</td></tr><tr><td>25 or higher</td><td>17th</td><td>135</td><td>13</td><td>7</td><td>4</td><td>2</td><td>2</td></tr></tbody></table>

Leadership Score: A character’s base Leadership score equals his level plus any Charisma modifier. In order to take into account negative Charisma modifiers, this table allows for very low Leadership scores, but the character must still be 6th level or higher in order to gain the Leadership feat. Outside factors can affect a character’s Leadership score, as detailed above.

Cohort Level: The character can attract a cohort of up to this level. Regardless of a character’s Leadership score, he can only recruit a cohort who is two or more levels lower than himself. The cohort should be equipped with gear appropriate for its level. A character can try to attract a cohort of a particular race, class, and alignment. The cohort’s alignment may not be opposed to the leader’s alignment on either the law-vs-chaos or good-vs-evil axis, and the leader takes a Leadership penalty if he recruits a cohort of an alignment different from his own.

Cohorts earn XP as follows:

The cohort does not count as a party member when determining the party’s XP.

Divide the cohort’s level by the level of the PC with whom he or she is associated (the character with the Leadership feat who attracted the cohort).

Multiply this result by the total XP awarded to the PC and add that number of experience points to the cohort’s total.

If a cohort gains enough XP to bring it to a level one lower than the associated PC’s character level, the cohort does not gain the new level—its new XP total is 1 less than the amount needed attain the next level.

Number of Followers by Level: The character can lead up to the indicated number of characters of each level. Followers are similar to cohorts, except they’re generally low-level NPCs. Because they’re generally five or more levels behind the character they follow, they’re rarely effective in combat.

Followers don’t earn experience and thus don’t gain levels. However, when a character with Leadership attains a new level, the player consults the table above to determine if she has acquired more followers, some of which may be higher level than the existing followers. (You don’t consult the table to see if your cohort gains levels, however, because cohorts earn experience on their own.)','{"type":"General","raw":"Character level 6th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_lightning_reflexes','Lightning Reflexes','Benefit: You get a +2 bonus on all Reflex saving throws.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_magical_aptitude','Magical Aptitude','Benefit: You get a +2 bonus on all Spellcraft checks and Use Magic Device checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_manyshot','Manyshot','Prerequisites: Dex 17, Point Blank Shot, Rapid Shot, base attack bonus +6

Benefit: As a standard action, you may fire two arrows at a single opponent within 30 feet. Both arrows use the same attack roll (with a –4 penalty) to determine success and deal damage normally (but see Special).

For every five points of base attack bonus you have above +6, you may add one additional arrow to this attack, to a maximum of four arrows at a base attack bonus of +16. However, each arrow after the second adds a cumulative –2 penalty on the attack roll (for a total penalty of –6 for three arrows and –8 for four).

Damage reduction and other resistances apply separately against each arrow fired.

Special: Regardless of the number of arrows you fire, you apply precision-based damage only once. If you score a critical hit, only the first arrow fired deals critical damage; all others deal regular damage.

A fighter may select Manyshot as one of his fighter bonus feats.

A 6th-level ranger who has chosen the archery combat style is treated as having Manyshot even if he does not have the prerequisites for it, but only when he is wearing light or no armor.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_martial_weapon_proficiency','Martial Weapon Proficiency','Choose a type of martial weapon. You understand how to use that type of martial weapon in combat.

Benefit: You make attack rolls with the selected weapon normally.

Normal: When using a weapon with which you are not proficient, you take a –4 penalty on attack rolls.

Special: Barbarians, fighters, paladins, and rangers are proficient with all martial weapons. They need not select this feat.

You can gain Martial Weapon Proficiency multiple times. Each time you take the feat, it applies to a new type of weapon.

A cleric who chooses the War domain automatically gains the Martial Weapon Proficiency feat related to his deity’s favored weapon as a bonus feat, if the weapon is a martial one. He need not select it.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_maximize_spell','Maximize Spell','Benefit: All variable, numeric effects of a spell modified by this feat are maximized. Saving throws and opposed rolls are not affected, nor are spells without random variables. A maximized spell uses up a spell slot three levels higher than the spell’s actual level.

An empowered, maximized spell gains the separate benefits of each feat: the maximum result plus one-half the normally rolled result.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_mobility','Mobility','Prerequisites: Dex 13, Dodge.

Benefit: You get a +4 dodge bonus to Armor Class against attacks of opportunity caused when you move out of or within a threatened area. A condition that makes you lose your Dexterity bonus to Armor Class (if any) also makes you lose dodge bonuses.

Dodge bonuses stack with each other, unlike most types of bonuses.

Special: A fighter may select Mobility as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_mounted_archery','Mounted Archery','Prerequisites: Ride 1 rank, Mounted Combat.

Benefit: The penalty you take when using a ranged weapon while mounted is halved: –2 instead of –4 if your mount is taking a double move, and –4 instead of –8 if your mount is running.

Special: A fighter may select Mounted Archery as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_mounted_combat','Mounted Combat','Prerequisite: Ride 1 rank.

Benefit: Once per round when your mount is hit in combat, you may attempt a Ride check (as a reaction) to negate the hit. The hit is negated if your Ride check result is greater than the opponent’s attack roll. (Essentially, the Ride check result becomes the mount’s Armor Class if it’s higher than the mount’s regular AC.)

Special: A fighter may select Mounted Combat as one of his fighter bonus feats.','{"type":"General","raw":"Ride 1 rank.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_natural_spell','Natural Spell','Prerequisites: Wis 13, wild shape ability.

Benefit: You can complete the verbal and somatic components of spells while in a wild shape. You substitute various noises and gestures for the normal verbal and somatic components of a spell.

You can also use any material components or focuses you possess, even if such items are melded within your current form. This feat does not permit the use of magic items while you are in a form that could not ordinarily use them, and you do not gain the ability to speak while in a wild shape.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_negotiator','Negotiator','Benefit: You get a +2 bonus on all Diplomacy checks and Sense Motive checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_nimble_fingers','Nimble Fingers','Benefit: You get a +2 bonus on all Disable Device checks and Open Lock checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_persuasive','Persuasive','Benefit: You get a +2 bonus on all Bluff checks and Intimidate checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_point_blank_shot','Point Blank Shot','Benefit: You get a +1 bonus on attack and damage rolls with ranged weapons at ranges of up to 30 feet.

Special: A fighter may select Point Blank Shot as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('ataque_poderoso','Ataque Poderoso','Prerequisite: Str 13.

Benefit: On your action, before making attack rolls for a round, you may choose to subtract a number from all melee attack rolls and add the same number to all melee damage rolls. This number may not exceed your base attack bonus. The penalty on attacks and bonus on damage apply until your next turn.

Special: If you attack with a two-handed weapon, or with a one-handed weapon wielded in two hands, instead add twice the number subtracted from your attack rolls. You can’t add the bonus from Power Attack to the damage dealt with a light weapon (except with unarmed strikes or natural weapon attacks), even though the penalty on attack rolls still applies. (Normally, you treat a double weapon as a one-handed weapon and a light weapon. If you choose to use a double weapon like a two-handed weapon, attacking with only one end of it in a round, you treat it as a two-handed weapon.)

A fighter may select Power Attack as one of his fighter bonus feats.','{"type":"General","raw":"Str 13.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_precise_shot','Precise Shot','Prerequisite: Point Blank Shot.

Benefit: You can shoot or throw ranged weapons at an opponent engaged in melee without taking the standard –4 penalty on your attack roll.

Special: A fighter may select Precise Shot as one of his fighter bonus feats.','{"type":"General","raw":"Point Blank Shot.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_quick_draw','Quick Draw','Prerequisite: Base attack bonus +1.

Benefit: You can draw a weapon as a free action instead of as a move action. You can draw a hidden weapon (see the Sleight of Hand skill) as a move action.

A character who has selected this feat may throw weapons at his full normal rate of attacks (much like a character with a bow).

Normal: Without this feat, you may draw a weapon as a move action, or (if your base attack bonus is +1 or higher) as a free action as part of movement. Without this feat, you can draw a hidden weapon as a standard action.

Special: A fighter may select Quick Draw as one of his fighter bonus feats.','{"type":"General","raw":"Base attack bonus +1.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_quicken_spell','Quicken Spell','Benefit: Casting a quickened spell is a free action. You can perform another action, even casting another spell, in the same round as you cast a quickened spell. You may cast only one quickened spell per round. A spell whose casting time is more than 1 full round action cannot be quickened. A quickened spell uses up a spell slot four levels higher than the spell’s actual level. Casting a quickened spell doesn’t provoke an attack of opportunity.

Special: This feat can’t be applied to any spell cast spontaneously (including sorcerer spells, bard spells, and cleric or druid spells cast spontaneously), since applying a metamagic feat to a spontaneously cast spell automatically increases the casting time to a full-round action.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_rapid_reload','Rapid Reload','Choose a type of crossbow (hand, light, or heavy).

Prerequisite: Weapon Proficiency (crossbow type chosen).

Benefit: The time required for you to reload your chosen type of crossbow is reduced to a free action (for a hand or light crossbow) or a move action (for a heavy crossbow). Reloading a crossbow still provokes an attack of opportunity.

If you have selected this feat for hand crossbow or light crossbow, you may fire that weapon as many times in a full attack action as you could attack if you were using a bow.

Normal: A character without this feat needs a move action to reload a hand or light crossbow, or a full-round action to reload a heavy crossbow.

Special: You can gain Rapid Reload multiple times. Each time you take the feat, it applies to a new type of crossbow.

A fighter may select Rapid Reload as one of his fighter bonus feats.','{"type":"General","raw":"Weapon Proficiency (crossbow type chosen).","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false)
on conflict(id) do update set nome=case when srd_feats.id like 'srd35_feat_%' then excluded.nome else srd_feats.nome end,descricao=excluded.descricao,requisitos=excluded.requisitos,exige_parametro=excluded.exige_parametro;
