-- SRD 3.5 Open Game Content under OGL 1.0a.
-- Source: https://github.com/olimot/srd-v3.5-md/tree/main/spells
-- Per-class spell levels are stored in dados_tecnicos.class_levels.
insert into public.srd_spells (id,nome,nivel,circulo,escola,alcance,alvo,area,duracao,componentes,classes,descricao,dados_tecnicos,srd_source_url) values
('srd35_spell_zone_of_truth','Zone of Truth','Clr 2, Pal 2',2,'Enchantment (Compulsion) [Mind-Affecting]','Close (25 ft. + 5 ft./2 levels)',NULL,'20-ft.-radius emanation','1 min./level','V, S, DF',ARRAY['cleric','paladin']::text[],'Enchantment (Compulsion) \[Mind-Affecting\]

Level: Clr 2, Pal 2

Components: V, S, DF

Casting Time: 1 standard action

Range: Close (25 ft. + 5 ft./2 levels)

Area: 20-ft.-radius emanation

Duration: 1 min./level

Saving Throw: Will negates

Spell Resistance: Yes

Creatures within the emanation area (or those who enter it) can’t speak any deliberate and intentional lies. Each potentially affected creature is allowed a save to avoid the effects when the spell is cast or when the creature first enters the emanation area. Affected creatures are aware of this enchantment. Therefore, they may avoid answering questions to which they would normally respond with a lie, or they may be evasive as long as they remain within the boundaries of the truth. Creatures who leave the area are free to speak as they choose.','{"class_levels":{"cleric":2,"paladin":2},"source_field_values":{"Level":"Clr 2, Pal 2","Components":"V, S, DF","Casting Time":"1 standard action","Range":"Close (25 ft. + 5 ft./2 levels)","Area":"20-ft.-radius emanation","Duration":"1 min./level","Saving Throw":"Will negates","Spell Resistance":"Yes"},"open_game_content":true}'::jsonb,'https://github.com/olimot/srd-v3.5-md/blob/main/spells/spells-t-z.md')
on conflict (id) do update set nome=case when srd_spells.srd_source_url is null then srd_spells.nome else excluded.nome end,nivel=excluded.nivel,circulo=excluded.circulo,escola=excluded.escola,alcance=excluded.alcance,alvo=excluded.alvo,area=excluded.area,duracao=excluded.duracao,componentes=excluded.componentes,classes=excluded.classes,descricao=excluded.descricao,dados_tecnicos=excluded.dados_tecnicos,srd_source_url=excluded.srd_source_url,updated_at=now();
