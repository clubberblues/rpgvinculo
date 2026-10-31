-- SRD 3.5 Feats: Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md
insert into public.srd_feats(id,nome,descricao,requisitos,exige_parametro) values
('srd35_feat_rapid_shot','Rapid Shot','Prerequisites: Dex 13, Point Blank Shot.

Benefit: You can get one extra attack per round with a ranged weapon. The attack is at your highest base attack bonus, but each attack you make in that round (the extra one and the normal ones) takes a –2 penalty. You must use the full attack action to use this feat.

Special: A fighter may select Rapid Shot as one of his fighter bonus feats.

A 2nd-level ranger who has chosen the archery combat style is treated as having Rapid Shot, even if he does not have the prerequisites for it, but only when he is wearing light or no armor.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_ride_by_attack','Ride-by Attack','Prerequisites: Ride 1 rank, Mounted Combat.

Benefit: When you are mounted and use the charge action, you may move and attack as if with a standard charge and then move again (continuing the straight line of the charge). Your total movement for the round can’t exceed double your mounted speed. You and your mount do not provoke an attack of opportunity from the opponent that you attack.

Special: A fighter may select Ride-By Attack as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_run','Run','Benefit: When running, you move five times your normal speed (if wearing medium, light, or no armor and carrying no more than a medium load) or four times your speed (if wearing heavy armor or carrying a heavy load). If you make a jump after a running start (see the Jump skill description), you gain a +4 bonus on your Jump check. While running, you retain your Dexterity bonus to AC.

Normal: You move four times your speed while running (if wearing medium, light, or no armor and carrying no more than a medium load) or three times your speed (if wearing heavy armor or carrying a heavy load), and you lose your Dexterity bonus to AC.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_scribe_scroll','Scribe Scroll','Prerequisite: Caster level 1st.

Benefit: You can create a scroll of any spell that you know. Scribing a scroll takes one day for each 1,000 gp in its base price. The base price of a scroll is its spell level x its caster level x 25 gp. To scribe a scroll, you must spend 1/25 of this base price in XP and use up raw materials costing one-half of this base price.

Any scroll that stores a spell with a costly material component or an XP cost also carries a commensurate cost. In addition to the costs derived from the base price, you must expend the material component or pay the XP when scribing the scroll.','{"type":"Item Creation","raw":"Caster level 1st.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_self_sufficient','Self-Sufficient','Benefit: You get a +2 bonus on all Heal checks and Survival checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_shield_proficiency','Shield Proficiency','Benefit: You can use a shield and take only the standard penalties.

Normal: When you are using a shield with which you are not proficient, you take the shield’s armor check penalty on attack rolls and on all skill checks that involve moving, including Ride checks.

Special: Barbarians, bards, clerics, druids, fighters, paladins, and rangers automatically have Shield Proficiency as a bonus feat. They need not select it.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_shot_on_the_run','Shot on the Run','Prerequisites: Dex 13, Dodge, Mobility, Point Blank Shot, base attack bonus +4.

Benefit: When using the attack action with a ranged weapon, you can move both before and after the attack, provided that your total distance moved is not greater than your speed.

Special: A fighter may select Shot on the Run as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_silent_spell','Silent Spell','Benefit: A silent spell can be cast with no verbal components. Spells without verbal components are not affected. A silent spell uses up a spell slot one level higher than the spell’s actual level.

Special: Bard spells cannot be enhanced by this metamagic feat.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_simple_weapon_proficiency','Simple Weapon Proficiency','Benefit: You make attack rolls with simple weapons normally.

Normal: When using a weapon with which you are not proficient, you take a –4 penalty on attack rolls.

Special: All characters except for druids, monks, and wizards are automatically proficient with all simple weapons. They need not select this feat.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_skill_focus','Skill Focus','Choose a skill.

Benefit: You get a +3 bonus on all checks involving that skill.

Special: You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new skill.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_snatch_arrows','Snatch Arrows','Prerequisites: Dex 15, Deflect Arrows, Improved Unarmed Strike.

Benefit: When using the Deflect Arrows feat you may catch the weapon instead of just deflecting it. Thrown weapons can immediately be thrown back at the original attacker (even though it isn’t your turn) or kept for later use.

You must have at least one hand free (holding nothing) to use this feat.

Special: A fighter may select Snatch Arrows as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_spell_focus','Spell Focus','Choose a school of magic.

Benefit: Add +1 to the Difficulty Class for all saving throws against spells from the school of magic you select.

Special: You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new school of magic.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_spell_mastery','Spell Mastery','Prerequisite: Wizard level 1st.

Benefit: Each time you take this feat, choose a number of spells equal to your Intelligence modifier that you already know. From that point on, you can prepare these spells without referring to a spellbook.

Normal: Without this feat, you must use a spellbook to prepare all your spells, except read magic.','{"type":"Special","raw":"Wizard level 1st.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_spell_penetration','Spell Penetration','Benefit: You get a +2 bonus on caster level checks (1d20 + caster level) made to overcome a creature’s spell resistance.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_spirited_charge','Spirited Charge','Prerequisites: Ride 1 rank, Mounted Combat, Ride-By Attack.

Benefit: When mounted and using the charge action, you deal double damage with a melee weapon (or triple damage with a lance).

Special: A fighter may select Spirited Charge as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_spring_attack','Spring Attack','Prerequisites: Dex 13, Dodge, Mobility, base attack bonus +4.

Benefit: When using the attack action with a melee weapon, you can move both before and after the attack, provided that your total distance moved is not greater than your speed. Moving in this way does not provoke an attack of opportunity from the defender you attack, though it might provoke attacks of opportunity from other creatures, if appropriate. You can’t use this feat if you are wearing heavy armor.

You must move at least 5 feet both before and after you make your attack in order to utilize the benefits of Spring Attack.

Special: A fighter may select Spring Attack as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_stealthy','Stealthy','Benefit: You get a +2 bonus on all Hide checks and Move Silently checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_still_spell','Still Spell','Benefit: A stilled spell can be cast with no somatic components.

Spells without somatic components are not affected. A stilled spell uses up a spell slot one level higher than the spell’s actual level.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_stunning_fist','Stunning Fist','Prerequisites: Dex 13, Wis 13, Improved Unarmed Strike, base attack bonus +8.

Benefit: You must declare that you are using this feat before you make your attack roll (thus, a failed attack roll ruins the attempt). Stunning Fist forces a foe damaged by your unarmed attack to make a Fortitude saving throw (DC 10 + 1/2 your character level + your Wis modifier), in addition to dealing damage normally. A defender who fails this saving throw is stunned for 1 round (until just before your next action). A stunned character can’t act, loses any Dexterity bonus to AC, and takes a –2 penalty to AC. You may attempt a stunning attack once per day for every four levels you have attained (but see Special), and no more than once per round. Constructs, oozes, plants, undead, incorporeal creatures, and creatures immune to critical hits cannot be stunned.

Special: A monk may select Stunning Fist as a bonus feat at 1st level, even if she does not meet the prerequisites. A monk who selects this feat may attempt a stunning attack a number of times per day equal to her monk level, plus one more time per day for every four levels she has in classes other than monk.

A fighter may select Stunning Fist as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('tenacidade','Tenacidade','Benefit: You gain +3 hit points.

Special: A character may gain this feat multiple times. Its effects stack.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_tower_shield_proficiency','Tower Shield Proficiency','Prerequisite: Shield Proficiency.

Benefit: You can use a tower shield and suffer only the standard penalties.

Normal: A character who is using a shield with which he or she is not proficient takes the shield’s armor check penalty on attack rolls and on all skill checks that involve moving, including Ride.

Special: Fighters automatically have Tower Shield Proficiency as a bonus feat. They need not select it.','{"type":"General","raw":"Shield Proficiency.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_track','Track','Benefit: To find tracks or to follow them for 1 mile requires a successful Survival check. You must make another Survival check every time the tracks become difficult to follow.

You move at half your normal speed (or at your normal speed with a –5 penalty on the check, or at up to twice your normal speed with a –20 penalty on the check). The DC depends on the surface and the prevailing conditions, as given on the table below:

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Surface</th><th>Survival DC</th><th>Surface Survival</th><th>DC</th></tr><tr><td>Very soft ground</td><td>5</td><td>Firm ground</td><td>15</td></tr><tr><td>Soft ground</td><td>10</td><td>Hard ground</td><td>20</td></tr></tbody></table>

Very Soft Ground: Any surface (fresh snow, thick dust, wet mud) that holds deep, clear impressions of footprints.

Soft Ground: Any surface soft enough to yield to pressure, but firmer than wet mud or fresh snow, in which a creature leaves frequent but shallow footprints.

Firm Ground: Most normal outdoor surfaces (such as lawns, fields, woods, and the like) or exceptionally soft or dirty indoor surfaces (thick rugs and very dirty or dusty floors). The creature might leave some traces (broken branches or tufts of hair), but it leaves only occasional or partial footprints.

Hard Ground: Any surface that doesn’t hold footprints at all, such as bare rock or an indoor floor. Most streambeds fall into this category, since any footprints left behind are obscured or washed away. The creature leaves only traces (scuff marks or displaced pebbles).

Several modifiers may apply to the Survival check, as given on the table below.

<table data-debug="no-caption" class="half-width-table"><tbody><tr><th>Condition</th><th>Survival DC Modifier</th></tr><tr><td>Every three creatures in the group being tracked</td><td>–1</td></tr><tr><td>Size of creature or creatures being tracked:<sup>1</sup></td><td></td></tr><tr><td>Fine</td><td>+8</td></tr><tr><td>Diminutive</td><td>+4</td></tr><tr><td>Tiny</td><td>+2</td></tr><tr><td>Small</td><td>+1</td></tr><tr><td>Medium</td><td>+0</td></tr><tr><td>Large</td><td>–1</td></tr><tr><td>Huge</td><td>–2</td></tr><tr><td>Gargantuan</td><td>–4</td></tr><tr><td>Colossal</td><td>–8</td></tr><tr><td>Every 24 hours since the trail was made</td><td>+1</td></tr><tr><td>Every hour of rain since the trail was made</td><td>+1</td></tr><tr><td>Fresh snow cover since the trail was made</td><td>+10</td></tr><tr><td>Poor visibility:<sup>2</sup></td><td></td></tr><tr><td>Overcast or moonless night</td><td>+6</td></tr><tr><td>Moonlight</td><td>+3</td></tr><tr><td>Fog or precipitation</td><td>+3</td></tr><tr><td>Tracked party hides trail (and moves at half speed)</td><td>+5</td></tr><tr><td colspan="2">1 For a group of mixed sizes, apply only the modifier for the largest size category.</td></tr><tr><td colspan="2">2 Apply only the largest modifier from this category.</td></tr></tbody></table>

If you fail a Survival check, you can retry after 1 hour (outdoors) or 10 minutes (indoors) of searching.

Normal: Without this feat, you can use the Survival skill to find tracks, but you can follow them only if the DC for the task is 10 or lower. Alternatively, you can use the Search skill to find a footprint or similar sign of a creature’s passage using the DCs given above, but you can’t use Search to follow tracks, even if someone else has already found them.

Special: A ranger automatically has Track as a bonus feat. He need not select it.

This feat does not allow you to find or follow the tracks made by a subject of a pass without trace spell.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_trample','Trample','Prerequisites: Ride 1 rank, Mounted Combat.

Benefit: When you attempt to overrun an opponent while mounted, your target may not choose to avoid you. Your mount may make one hoof attack against any target you knock down, gaining the standard +4 bonus on attack rolls against prone targets.

Special: A fighter may select Trample as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_two_weapon_defense','Two-Weapon Defense','Prerequisites: Dex 15, Two-Weapon Fighting.

Benefit: When wielding a double weapon or two weapons (not including natural weapons or unarmed strikes), you gain a +1 shield bonus to your AC.

When you are fighting defensively or using the total defense action, this shield bonus increases to +2.

Special: A fighter may select Two-Weapon Defense as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_two_weapon_fighting','Two-Weapon Fighting','You can fight with a weapon in each hand. You can make one extra attack each round with the second weapon.

Prerequisite: Dex 15.

Benefit: Your penalties on attack rolls for fighting with two weapons are reduced. The penalty for your primary hand lessens by 2 and the one for your off hand lessens by 6.

Normal: If you wield a second weapon in your off hand, you can get one extra attack per round with that weapon. When fighting in this way you suffer a –6 penalty with your regular attack or attacks with your primary hand and a –10 penalty to the attack with your off hand. If your off-hand weapon is light the penalties are reduced by 2 each. (An unarmed strike is always considered light.)

Special: A 2nd-level ranger who has chosen the two-weapon combat style is treated as having Two-Weapon Fighting, even if he does not have the prerequisite for it, but only when he is wearing light or no armor.

A fighter may select Two-Weapon Fighting as one of his fighter bonus feats.','{"type":"General","raw":"Dex 15.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_weapon_finesse','Weapon Finesse','Prerequisite: Base attack bonus +1.

Benefit: With a light weapon, rapier, whip, or spiked chain made for a creature of your size category, you may use your Dexterity modifier instead of your Strength modifier on attack rolls. If you carry a shield, its armor check penalty applies to your attack rolls.

Special: A fighter may select Weapon Finesse as one of his fighter bonus feats.

Natural weapons are always considered light weapons.','{"type":"General","raw":"Base attack bonus +1.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('foco_em_arma','Foco em Arma','Choose one type of weapon. You can also choose unarmed strike or grapple (or ray, if you are a spellcaster) as your weapon for purposes of this feat.

Prerequisites: Proficiency with selected weapon, base attack bonus +1.

Benefit: You gain a +1 bonus on all attack rolls you make using the selected weapon.

Special: You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new type of weapon.

A fighter may select Weapon Focus as one of his fighter bonus feats. He must have Weapon Focus with a weapon to gain the Weapon Specialization feat for that weapon.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_weapon_specialization','Weapon Specialization','Choose one type of weapon for which you have already selected the Weapon Focus feat. You can also choose unarmed strike or grapple as your weapon for purposes of this feat. You deal extra damage when using this weapon.

Prerequisites: Proficiency with selected weapon, Weapon Focus with selected weapon, fighter level 4th.

Benefit: You gain a +2 bonus on all damage rolls you make using the selected weapon.

Special: You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new type of weapon.

A fighter may select Weapon Specialization as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_whirlwind_attack','Whirlwind Attack','Prerequisites: Dex 13, Int 13, Combat Expertise, Dodge, Mobility, Spring Attack, base attack bonus +4.

Benefit: When you use the full attack action, you can give up your regular attacks and instead make one melee attack at your full base attack bonus against each opponent within reach.

When you use the Whirlwind Attack feat, you also forfeit any bonus or extra attacks granted by other feats, spells, or abilities.

Special: A fighter may select Whirlwind Attack as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_widen_spell','Widen Spell','Benefit: You can alter a burst, emanation, line, or spread shaped spell to increase its area. Any numeric measurements of the spell’s area increase by 100%.A widened spell uses up a spell slot three levels higher than the spell’s actual level.

Spells that do not have an area of one of these four sorts are not affected by this feat.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false)
on conflict(id) do update set nome=case when srd_feats.id like 'srd35_feat_%' then excluded.nome else srd_feats.nome end,descricao=excluded.descricao,requisitos=excluded.requisitos,exige_parametro=excluded.exige_parametro;
