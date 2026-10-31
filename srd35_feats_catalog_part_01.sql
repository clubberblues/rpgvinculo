-- SRD 3.5 Feats: Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md
insert into public.srd_feats(id,nome,descricao,requisitos,exige_parametro) values
('srd35_feat_acrobatic','Acrobatic','Benefit: You get a +2 bonus on all Jump checks and Tumble checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_agile','Agile','Benefit: You get a +2 bonus on all Balance checks and Escape Artist checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_alertness','Alertness','Benefit: You get a +2 bonus on all Listen checks and Spot checks.

Special: The master of a familiar gains the benefit of the Alertness feat whenever the familiar is within arm’s reach.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_animal_affinity','Animal Affinity','Benefit: You get a +2 bonus on all Handle Animal checks and Ride checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_armor_proficiency_heavy','Armor Proficiency (Heavy)','Prerequisites: Armor Proficiency (light), Armor Proficiency (medium).

Benefit: See Armor Proficiency (light).

Normal: See Armor Proficiency (light).

Special: Fighters, paladins, and clerics automatically have Armor Proficiency (heavy) as a bonus feat. They need not select it.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_armor_proficiency_light','Armor Proficiency (Light)','Benefit: When you wear a type of armor with which you are proficient, the armor check penalty for that armor applies only to Balance, Climb, Escape Artist, Hide, Jump, Move Silently, Sleight of Hand, and Tumble checks.

Normal: A character who is wearing armor with which she is not proficient applies its armor check penalty to attack rolls and to all skill checks that involve moving, including Ride.

Special: All characters except wizards, sorcerers, and monks automatically have Armor Proficiency (light) as a bonus feat. They need not select it.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_armor_proficiency_medium','Armor Proficiency (Medium)','Prerequisite: Armor Proficiency (light).

Benefit: See Armor Proficiency (light).

Normal: See Armor Proficiency (light).

Special: Fighters, barbarians, paladins, clerics, druids, and bards automatically have Armor Proficiency (medium) as a bonus feat. They need not select it.','{"type":"General","raw":"Armor Proficiency (light).","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_athletic','Athletic','Benefit: You get a +2 bonus on all Climb checks and Swim checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_augment_summoning','Augment Summoning','Prerequisite: Spell Focus (conjuration).

Benefit: Each creature you conjure with any summon spell gains a +4 enhancement bonus to Strength and Constitution for the duration of the spell that summoned it.','{"type":"General","raw":"Spell Focus (conjuration).","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_blind_fight','Blind-Fight','Benefit: In melee, every time you miss because of concealment, you can reroll your miss chance percentile roll one time to see if you actually hit.

An invisible attacker gets no advantages related to hitting you in melee. That is, you don’t lose your Dexterity bonus to Armor Class, and the attacker doesn’t get the usual +2 bonus for being invisible. The invisible attacker’s bonuses do still apply for ranged attacks, however.

You take only half the usual penalty to speed for being unable to see. Darkness and poor visibility in general reduces your speed to three-quarters normal, instead of one-half.

Normal: Regular attack roll modifiers for invisible attackers trying to hit you apply, and you lose your Dexterity bonus to AC. The speed reduction for darkness and poor visibility also applies.

Special: The Blind-Fight feat is of no use against a character who is the subject of a blink spell.

A fighter may select Blind-Fight as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_brew_potion','Brew Potion','Prerequisite: Caster level 3rd.

Benefit: You can create a potion of any 3rd-level or lower spell that you know and that targets one or more creatures. Brewing a potion takes one day. When you create a potion, you set the caster level, which must be sufficient to cast the spell in question and no higher than your own level. The base price of a potion is its spell level x its caster level x 50 gp. To brew a potion, you must spend 1/25 of this base price in XP and use up raw materials costing one half this base price.

When you create a potion, you make any choices that you would normally make when casting the spell. Whoever drinks the potion is the target of the spell.

Any potion that stores a spell with a costly material component or an XP cost also carries a commensurate cost. In addition to the costs derived from the base price, you must expend the material component or pay the XP when creating the potion.','{"type":"Item Creation","raw":"Caster level 3rd.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_cleave','Cleave','Prerequisites: Str 13, Power Attack.

Benefit: If you deal a creature enough damage to make it drop (typically by dropping it to below 0 hit points or killing it), you get an immediate, extra melee attack against another creature within reach. You cannot take a 5-foot step before making this extra attack. The extra attack is with the same weapon and at the same bonus as the attack that dropped the previous creature. You can use this ability once per round.

Special: A fighter may select Cleave as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_combat_casting','Combat Casting','Benefit: You get a +4 bonus on Concentration checks made to cast a spell or use a spell-like ability while on the defensive or while you are grappling or pinned.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_combat_expertise','Combat Expertise','Prerequisite: Int 13.

Benefit: When you use the attack action or the full attack action in melee, you can take a penalty of as much as –5 on your attack roll and add the same number (+5 or less) as a dodge bonus to your Armor Class. This number may not exceed your base attack bonus. The changes to attack rolls and Armor Class last until your next action.

Normal: A character without the Combat Expertise feat can fight defensively while using the attack or full attack action to take a –4 penalty on attack rolls and gain a +2 dodge bonus to Armor Class.

Special: A fighter may select Combat Expertise as one of his fighter bonus feats.','{"type":"General","raw":"Int 13.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('reflexos_de_combate','Reflexos de Combate','Benefit: You may make a number of additional attacks of opportunity equal to your Dexterity bonus.

With this feat, you may also make attacks of opportunity while flat-footed.

Normal: A character without this feat can make only one attack of opportunity per round and can’t make attacks of opportunity while flat-footed.

Special: The Combat Reflexes feat does not allow a rogue to use her opportunist ability more than once per round.

A fighter may select Combat Reflexes as one of his fighter bonus feats.

A monk may select Combat Reflexes as a bonus feat at 2nd level.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_craft_magic_arms_and_armor','Craft Magic Arms and Armor','Prerequisite: Caster level 5th.

Benefit: You can create any magic weapon, armor, or shield whose prerequisites you meet. Enhancing a weapon, suit of armor, or shield takes one day for each 1,000 gp in the price of its magical features. To enhance a weapon, suit of armor, or shield, you must spend 1/25 of its features’ total price in XP and use up raw materials costing one-half of this total price.

The weapon, armor, or shield to be enhanced must be a masterwork item that you provide. Its cost is not included in the above cost.

You can also mend a broken magic weapon, suit of armor, or shield if it is one that you could make. Doing so costs half the XP, half the raw materials, and half the time it would take to craft that item in the first place.','{"type":"Item Creation","raw":"Caster level 5th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_craft_rod','Craft Rod','Prerequisite: Caster level 9th.

Benefit: You can create any rod whose prerequisites you meet. Crafting a rod takes one day for each 1,000 gp in its base price. To craft a rod, you must spend 1/25 of its base price in XP and use up raw materials costing one-half of its base price.

Some rods incur extra costs in material components or XP, as noted in their descriptions. These costs are in addition to those derived from the rod’s base price.','{"type":"Item Creation","raw":"Caster level 9th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_craft_staff','Craft Staff','Prerequisite: Caster level 12th.

Benefit: You can create any staff whose prerequisites you meet.

Crafting a staff takes one day for each 1,000 gp in its base price. To craft a staff, you must spend 1/25 of its base price in XP and use up raw materials costing one-half of its base price. A newly created staff has 50 charges.

Some staffs incur extra costs in material components or XP, as noted in their descriptions. These costs are in addition to those derived from the staff ’s base price.','{"type":"Item Creation","raw":"Caster level 12th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_craft_wand','Craft Wand','Prerequisite: Caster level 5th.

Benefit: You can create a wand of any 4th-level or lower spell that you know. Crafting a wand takes one day for each 1,000 gp in its base price. The base price of a wand is its caster level x the spell level x 750 gp. To craft a wand, you must spend 1/25 of this base price in XP and use up raw materials costing one-half of this base price. A newly created wand has 50 charges.

Any wand that stores a spell with a costly material component or an XP cost also carries a commensurate cost. In addition to the cost derived from the base price, you must expend fifty copies of the material component or pay fifty times the XP cost.','{"type":"Item Creation","raw":"Caster level 5th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_craft_wondrous_item','Craft Wondrous Item','Prerequisite: Caster level 3rd.

Benefit: You can create any wondrous item whose prerequisites you meet. Enchanting a wondrous item takes one day for each 1,000 gp in its price. To enchant a wondrous item, you must spend 1/25 of the item’s price in XP and use up raw materials costing half of this price.

You can also mend a broken wondrous item if it is one that you could make. Doing so costs half the XP, half the raw materials, and half the time it would take to craft that item in the first place.

Some wondrous items incur extra costs in material components or XP, as noted in their descriptions. These costs are in addition to those derived from the item’s base price. You must pay such a cost to create an item or to mend a broken one.','{"type":"Item Creation","raw":"Caster level 3rd.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_deceitful','Deceitful','Benefit: You get a +2 bonus on all Disguise checks and Forgery checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_deflect_arrows','Deflect Arrows','Prerequisites: Dex 13, Improved Unarmed Strike.

Benefit: You must have at least one hand free (holding nothing) to use this feat. Once per round when you would normally be hit with a ranged weapon, you may deflect it so that you take no damage from it. You must be aware of the attack and not flatfooted.

Attempting to deflect a ranged weapon doesn’t count as an action. Unusually massive ranged weapons and ranged attacks generated by spell effects can’t be deflected.

Special: A monk may select Deflect Arrows as a bonus feat at 2nd level, even if she does not meet the prerequisites.

A fighter may select Deflect Arrows as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_deft_hands','Deft Hands','Benefit: You get a +2 bonus on all Sleight of Hand checks and Use Rope checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_diehard','Diehard','Prerequisite: Endurance.

Benefit: When reduced to between –1 and –9 hit points, you automatically become stable. You don’t have to roll d% to see if you lose 1 hit point each round.

When reduced to negative hit points, you may choose to act as if you were disabled, rather than dying. You must make this decision as soon as you are reduced to negative hit points (even if it isn’t your turn). If you do not choose to act as if you were disabled, you immediately fall unconscious.

When using this feat, you can take either a single move or standard action each turn, but not both, and you cannot take a full round action. You can take a move action without further injuring yourself, but if you perform any standard action (or any other action deemed as strenuous, including some free actions, such as casting a quickened spell) you take 1 point of damage after completing the act. If you reach –10 hit points, you immediately die.

Normal: A character without this feat who is reduced to between –1 and –9 hit points is unconscious and dying.','{"type":"General","raw":"Endurance.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_diligent','Diligent','Benefit: You get a +2 bonus on all Appraise checks and Decipher Script checks.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('esquiva','Esquiva','Prerequisite: Dex 13.

Benefit: During your action, you designate an opponent and receive a +1 dodge bonus to Armor Class against attacks from that opponent. You can select a new opponent on any action.

A condition that makes you lose your Dexterity bonus to Armor Class (if any) also makes you lose dodge bonuses. Also, dodge bonuses stack with each other, unlike most other types of bonuses.

Special: A fighter may select Dodge as one of his fighter bonus feats.','{"type":"General","raw":"Dex 13.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_empower_spell','Empower Spell','Benefit: All variable, numeric effects of an empowered spell are increased by one-half.

Saving throws and opposed rolls are not affected, nor are spells without random variables. An empowered spell uses up a spell slot two levels higher than the spell’s actual level.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_endurance','Endurance','Benefit: You gain a +4 bonus on the following checks and saves: Swim checks made to resist nonlethal damage, Constitution checks made to continue running, Constitution checks made to avoid nonlethal damage from a forced march, Constitution checks made to hold your breath, Constitution checks made to avoid nonlethal damage from starvation or thirst, Fortitude saves made to avoid nonlethal damage from hot or cold environments, and Fortitude saves made to resist damage from suffocation. Also, you may sleep in light or medium armor without becoming fatigued.

Normal: A character without this feat who sleeps in medium or heavier armor is automatically fatigued the next day.

Special: A ranger automatically gains Endurance as a bonus feat at 3rd level. He need not select it.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_enlarge_spell','Enlarge Spell','Benefit: You can alter a spell with a range of close, medium, or long to increase its range by 100%. An enlarged spell with a range of close now has a range of 50 ft. + 5 ft./level, while medium-range spells have a range of 200 ft. + 20 ft./level and long-range spells have a range of 800 ft. + 80 ft./level. An enlarged spell uses up a spell slot one level higher than the spell’s actual level.

Spells whose ranges are not defined by distance, as well as spells whose ranges are not close, medium, or long, do not have increased ranges.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_eschew_materials','Eschew Materials','Benefit: You can cast any spell that has a material component costing 1 gp or less without needing that component. (The casting of the spell still provokes attacks of opportunity as normal.) If the spell requires a material component that costs more than 1 gp, you must have the material component at hand to cast the spell, just as normal.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_exotic_weapon_proficiency','Exotic Weapon Proficiency','Choose a type of exotic weapon. You understand how to use that type of exotic weapon in combat.

Prerequisite: Base attack bonus +1 (plus Str 13 for bastard sword or dwarven waraxe).

Benefit: You make attack rolls with the weapon normally.

Normal: A character who uses a weapon with which he or she is not proficient takes a –4 penalty on attack rolls.

Special: You can gain Exotic Weapon Proficiency multiple times. Each time you take the feat, it applies to a new type of exotic weapon. Proficiency with the bastard sword or the dwarven waraxe has an additional prerequisite of Str 13.

A fighter may select Exotic Weapon Proficiency as one of his fighter bonus feats.','{"type":"General","raw":"Base attack bonus +1 (plus Str 13 for bastard sword or dwarven waraxe).","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_extend_spell','Extend Spell','Benefit: An extended spell lasts twice as long as normal. A spell with a duration of concentration, instantaneous, or permanent is not affected by this feat. An extended spell uses up a spell slot one level higher than the spell’s actual level.','{"type":"Metamagic","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_extra_turning','Extra Turning','Prerequisite: Ability to turn or rebuke creatures.

Benefit: Each time you take this feat, you can use your ability to turn or rebuke creatures four more times per day than normal.

If you have the ability to turn or rebuke more than one kind of creature each of your turning or rebuking abilities gains four additional uses per day.

Normal: Without this feat, a character can typically turn or rebuke undead (or other creatures) a number of times per day equal to 3 + his or her Charisma modifier.

Special: You can gain Extra Turning multiple times. Its effects stack. Each time you take the feat, you can use each of your turning or rebuking abilities four additional times per day.','{"type":"General","raw":"Ability to turn or rebuke creatures.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_far_shot','Far Shot','Prerequisite: Point Blank Shot.

Benefit: When you use a projectile weapon, such as a bow, its range increment increases by one-half (multiply by 1-1/2). When you use a thrown weapon, its range increment is doubled.

Special: A fighter may select Far Shot as one of his fighter bonus feats.','{"type":"General","raw":"Point Blank Shot.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_forge_ring','Forge Ring','Prerequisite: Caster level 12th.

Benefit: You can create any ring whose prerequisites you meet. Crafting a ring takes one day for each 1,000 gp in its base price. To craft a ring, you must spend 1/25 of its base price in XP and use up raw materials costing one-half of its base price.

You can also mend a broken ring if it is one that you could make. Doing so costs half the XP, half the raw materials, and half the time it would take to forge that ring in the first place.

Some magic rings incur extra costs in material components or XP, as noted in their descriptions. You must pay such a cost to forge such a ring or to mend a broken one.','{"type":"Item Creation","raw":"Caster level 12th.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_great_cleave','Great Cleave','Prerequisites: Str 13, Cleave, Power Attack, base attack bonus +4.

Benefit: This feat works like Cleave, except that there is no limit to the number of times you can use it per round.

Special: A fighter may select Great Cleave as one of his fighter bonus feats.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_great_fortitude','Great Fortitude','Benefit: You get a +2 bonus on all Fortitude saving throws.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_greater_spell_focus','Greater Spell Focus','Choose a school of magic to which you already have applied the Spell Focus feat.

Benefit: Add +1 to the Difficulty Class for all saving throws against spells from the school of magic you select. This bonus stacks with the bonus from Spell Focus.

Special: You can gain this feat multiple times. Its effects do not stack. Each time you take the feat, it applies to a new school of magic to which you already have applied the Spell Focus feat.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,true),
('srd35_feat_greater_spell_penetration','Greater Spell Penetration','Prerequisite: Spell Penetration.

Benefit: You get a +2 bonus on caster level checks (1d20 + caster level) made to overcome a creature’s spell resistance. This bonus stacks with the one from Spell Penetration.','{"type":"General","raw":"Spell Penetration.","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false),
('srd35_feat_greater_two_weapon_fighting','Greater Two-Weapon Fighting','Prerequisites: Dex 19, Improved Two-Weapon Fighting, Two-Weapon Fighting, base attack bonus +11.

Benefit: You get a third attack with your off-hand weapon, albeit at a –10 penalty.

Special: A fighter may select Greater Two-Weapon Fighting as one of his fighter bonus feats.

An 11th-level ranger who has chosen the two-weapon combat style is treated as having Greater Two-Weapon Fighting, even if he does not have the prerequisites for it, but only when he is wearing light or no armor.','{"type":"General","raw":"","source_url":"https://github.com/olimot/srd-v3.5-md/blob/main/basic-rules-and-legal/feats.md"}'::jsonb,false)
on conflict(id) do update set nome=case when srd_feats.id like 'srd35_feat_%' then excluded.nome else srd_feats.nome end,descricao=excluded.descricao,requisitos=excluded.requisitos,exige_parametro=excluded.exige_parametro;
