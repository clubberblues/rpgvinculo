-- Estrutura os talentos de combate com duas armas sem liberar efeitos não integrados.
-- engine_status permanece needs_review até existir seleção persistente das mãos e resolução
-- ponta a ponta dos ataques secundários no motor da mesa.

update public.srd_feats
set mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        mechanics,
        '{activation}',
        '{"mode":"passive","action_type":"no_action","trigger":"when_wielding_two_weapons"}'::jsonb,
        true
      ),
      '{requirements}',
      coalesce(mechanics->'requirements','{}'::jsonb) || '{"conditions":[{"type":"equipment","value":"two_melee_weapons_equipped"}],"equipment":["primary_melee_weapon","off_hand_melee_weapon"]}'::jsonb,
      true
    ),
    '{resolution}',
    '{"attack":null,"saving_throw":null,"effects":[{"kind":"modifier","stat":"two_weapon_primary_attack_penalty_reduction","value":2,"bonus_type":"feat","conditions":[{"type":"wielding_two_melee_weapons"}]},{"kind":"modifier","stat":"two_weapon_offhand_attack_penalty_reduction","value":6,"bonus_type":"feat","conditions":[{"type":"wielding_two_melee_weapons"}]}]}'::jsonb,
    true
  ),
  '{engine_status}','"needs_review"'::jsonb,true
) || jsonb_build_object('review_reason','Estrutura SRD registrada. Ainda depende de identificação persistente das mãos/equipamentos e resolução da sequência de ataques secundários com penalidades corretas; não executar até integração e teste ponta a ponta.')
where id='srd35_feat_two_weapon_fighting';

update public.srd_feats
set mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        mechanics,
        '{activation}',
        '{"mode":"passive","action_type":"no_action","trigger":"full_attack_with_two_weapons"}'::jsonb,
        true
      ),
      '{requirements}',
      coalesce(mechanics->'requirements','{}'::jsonb) || '{"conditions":[{"type":"equipment","value":"two_melee_weapons_equipped"}],"equipment":["primary_melee_weapon","off_hand_melee_weapon"],"feat_ids":["srd35_feat_two_weapon_fighting"],"bab_min":6,"des_min":17}'::jsonb,
      true
    ),
    '{resolution}',
    '{"attack":null,"saving_throw":null,"effects":[{"kind":"extra_attack","quantity":1,"attack_penalty":-5,"trigger":"full_attack_offhand","weapon_hand":"off_hand","attack_bonus":"highest_base_attack_bonus"}]}'::jsonb,
    true
  ),
  '{engine_status}','"needs_review"'::jsonb,true
) || jsonb_build_object('review_reason','Estrutura SRD registrada. O ataque adicional secundário com penalidade -5 ainda não é executado: requer escolha/identificação das duas armas, sequência mista e teste de rolagem/dano por arma.')
where id='srd35_feat_improved_two_weapon_fighting';

update public.srd_feats
set mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(
      jsonb_set(
        mechanics,
        '{activation}',
        '{"mode":"passive","action_type":"no_action","trigger":"full_attack_with_two_weapons"}'::jsonb,
        true
      ),
      '{requirements}',
      coalesce(mechanics->'requirements','{}'::jsonb) || '{"conditions":[{"type":"equipment","value":"two_melee_weapons_equipped"}],"equipment":["primary_melee_weapon","off_hand_melee_weapon"],"feat_ids":["srd35_feat_two_weapon_fighting","srd35_feat_improved_two_weapon_fighting"],"bab_min":11,"des_min":19}'::jsonb,
      true
    ),
    '{resolution}',
    '{"attack":null,"saving_throw":null,"effects":[{"kind":"extra_attack","quantity":1,"attack_penalty":-10,"trigger":"full_attack_offhand","weapon_hand":"off_hand","attack_bonus":"highest_base_attack_bonus"}]}'::jsonb,
    true
  ),
  '{engine_status}','"needs_review"'::jsonb,true
) || jsonb_build_object('review_reason','Estrutura SRD registrada. O terceiro ataque secundário com penalidade -10 ainda não é executado: requer escolha/identificação das duas armas, sequência mista e teste de rolagem/dano por arma.')
where id='srd35_feat_greater_two_weapon_fighting';
