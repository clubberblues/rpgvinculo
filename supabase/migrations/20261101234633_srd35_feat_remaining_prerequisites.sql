with reqs(id, raw, extra) as (
  values
    ('srd35_feat_armor_proficiency_heavy','Proficiência com armadura leve e média.','{"feat_ids":["srd35_feat_armor_proficiency_light","srd35_feat_armor_proficiency_medium"]}'::jsonb),
    ('srd35_feat_cleave','FOR 13 e Ataque Poderoso.','{"for_min":13,"feat_ids":["ataque_poderoso"]}'::jsonb),
    ('srd35_feat_deflect_arrows','DES 13 e Ataque Desarmado Aprimorado.','{"des_min":13,"feat_ids":["srd35_feat_improved_unarmed_strike"]}'::jsonb),
    ('srd35_feat_great_cleave','FOR 13, Ataque Poderoso, Trespassar e BBA +4.','{"for_min":13,"bab_min":4,"feat_ids":["srd35_feat_cleave","ataque_poderoso"]}'::jsonb),
    ('srd35_feat_greater_two_weapon_fighting','DES 19, Combater com Duas Armas, Combater com Duas Armas Aprimorado e BBA +11.','{"des_min":19,"bab_min":11,"feat_ids":["srd35_feat_two_weapon_fighting","srd35_feat_improved_two_weapon_fighting"]}'::jsonb),
    ('srd35_feat_improved_bull_rush','FOR 13 e Ataque Poderoso.','{"for_min":13,"feat_ids":["ataque_poderoso"]}'::jsonb),
    ('srd35_feat_improved_disarm','INT 13 e Especialização em Combate.','{"int_min":13,"feat_ids":["srd35_feat_combat_expertise"]}'::jsonb),
    ('srd35_feat_improved_feint','INT 13 e Especialização em Combate.','{"int_min":13,"feat_ids":["srd35_feat_combat_expertise"]}'::jsonb),
    ('srd35_feat_improved_grapple','DES 13 e Ataque Desarmado Aprimorado.','{"des_min":13,"feat_ids":["srd35_feat_improved_unarmed_strike"]}'::jsonb),
    ('srd35_feat_improved_overrun','FOR 13 e Ataque Poderoso.','{"for_min":13,"feat_ids":["ataque_poderoso"]}'::jsonb),
    ('srd35_feat_improved_precise_shot','DES 19, Tiro Certeiro, Precisão e BBA +11.','{"des_min":19,"bab_min":11,"feat_ids":["srd35_feat_point_blank_shot","srd35_feat_precise_shot"]}'::jsonb),
    ('srd35_feat_improved_sunder','FOR 13 e Ataque Poderoso.','{"for_min":13,"feat_ids":["ataque_poderoso"]}'::jsonb),
    ('srd35_feat_improved_trip','INT 13 e Especialização em Combate.','{"int_min":13,"feat_ids":["srd35_feat_combat_expertise"]}'::jsonb),
    ('srd35_feat_improved_two_weapon_fighting','DES 17, Combater com Duas Armas e BBA +6.','{"des_min":17,"bab_min":6,"feat_ids":["srd35_feat_two_weapon_fighting"]}'::jsonb),
    ('srd35_feat_manyshot','DES 17, Tiro Certeiro, Tiro Rápido e BBA +6.','{"des_min":17,"bab_min":6,"feat_ids":["srd35_feat_point_blank_shot","srd35_feat_rapid_shot"]}'::jsonb),
    ('srd35_feat_mobility','DES 13 e Esquiva.','{"des_min":13,"feat_ids":["esquiva"]}'::jsonb),
    ('srd35_feat_mounted_archery','1 graduação em Cavalgar e Combate Montado.','{"skill_ranks":{"cavalgar":1},"feat_ids":["srd35_feat_mounted_combat"]}'::jsonb),
    ('srd35_feat_natural_spell','Habilidade de Forma Selvagem.','{"special_ability_required":"wild_shape"}'::jsonb),
    ('srd35_feat_rapid_shot','DES 13 e Tiro Certeiro.','{"des_min":13,"feat_ids":["srd35_feat_point_blank_shot"]}'::jsonb),
    ('srd35_feat_ride_by_attack','1 graduação em Cavalgar e Combate Montado.','{"skill_ranks":{"cavalgar":1},"feat_ids":["srd35_feat_mounted_combat"]}'::jsonb),
    ('srd35_feat_shot_on_the_run','DES 13, Esquiva, Mobilidade, Tiro Certeiro e BBA +4.','{"des_min":13,"bab_min":4,"feat_ids":["esquiva","srd35_feat_mobility","srd35_feat_point_blank_shot"]}'::jsonb),
    ('srd35_feat_snatch_arrows','DES 15, Desviar Objetos e Ataque Desarmado Aprimorado.','{"des_min":15,"feat_ids":["srd35_feat_deflect_arrows","srd35_feat_improved_unarmed_strike"]}'::jsonb),
    ('srd35_feat_spirited_charge','1 graduação em Cavalgar, Combate Montado e Investida Montada.','{"skill_ranks":{"cavalgar":1},"feat_ids":["srd35_feat_mounted_combat","srd35_feat_ride_by_attack"]}'::jsonb),
    ('srd35_feat_spring_attack','DES 13, Esquiva, Mobilidade e BBA +4.','{"des_min":13,"bab_min":4,"feat_ids":["esquiva","srd35_feat_mobility"]}'::jsonb),
    ('srd35_feat_stunning_fist','DES 13, SAB 13, Ataque Desarmado Aprimorado e BBA +8.','{"des_min":13,"sab_min":13,"bab_min":8,"feat_ids":["srd35_feat_improved_unarmed_strike"]}'::jsonb),
    ('srd35_feat_trample','1 graduação em Cavalgar e Combate Montado.','{"skill_ranks":{"cavalgar":1},"feat_ids":["srd35_feat_mounted_combat"]}'::jsonb),
    ('srd35_feat_two_weapon_defense','DES 15 e Combater com Duas Armas.','{"des_min":15,"feat_ids":["srd35_feat_two_weapon_fighting"]}'::jsonb),
    ('srd35_feat_whirlwind_attack','DES 13, INT 13, Especialização em Combate, Esquiva, Mobilidade, Ataque em Movimento e BBA +4.','{"des_min":13,"int_min":13,"bab_min":4,"feat_ids":["srd35_feat_combat_expertise","esquiva","srd35_feat_mobility","srd35_feat_spring_attack"]}'::jsonb),
    ('srd35_feat_extra_turning','Habilidade de expulsar ou fascinar mortos-vivos ou controlar/repreender criaturas.','{"special_ability_required":"turn_or_rebuke_creatures"}'::jsonb),
    ('srd35_feat_improved_turning','Habilidade de expulsar ou fascinar mortos-vivos ou controlar/repreender criaturas.','{"special_ability_required":"turn_or_rebuke_creatures"}'::jsonb),
    ('srd35_feat_improved_familiar','Habilidade de adquirir um familiar, alinhamento compatível e nível de conjurador arcano suficiente para o familiar escolhido.','{"parameter_type":"improved_familiar","special_ability_required":"familiar","dynamic_prerequisites":"O nível e o alinhamento dependem do familiar escolhido na tabela SRD; a ficha ainda não armazena alinhamento nem possui catálogo de familiares melhorados."}'::jsonb)
), updated as (
  update public.srd_feats f
  set requisitos = coalesce(f.requisitos,'{}'::jsonb)
       || reqs.extra
       || jsonb_build_object('raw',reqs.raw,'source_url_primary','https://www.d20srd.org/srd/feats.htm'),
      exige_parametro = coalesce(f.exige_parametro,false) or (reqs.extra ? 'parameter_type')
  from reqs
  where f.id=reqs.id and (coalesce(f.requisitos->>'raw','')='' or reqs.id in ('srd35_feat_extra_turning','srd35_feat_improved_turning','srd35_feat_improved_familiar'))
  returning f.id
)
select count(*) as updated_feats from updated;