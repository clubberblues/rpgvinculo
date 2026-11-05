update public.srd_feats
set mechanics = coalesce(mechanics, '{}'::jsonb)
  || jsonb_build_object(
    'schema_version', 1,
    'engine_status', 'needs_review',
    'activation', jsonb_build_object('mode','passive','action_type','special','trigger','full_attack'),
    'requirements', coalesce(mechanics->'requirements', '{}'::jsonb),
    'duration', jsonb_build_object('type','passive','value',null,'end_trigger',null),
    'usage', jsonb_build_object('limit',null,'period','turn','cooldown_rounds',0),
    'resolution', jsonb_build_object(
      'attack', null,
      'saving_throw', null,
      'effects', jsonb_build_array(jsonb_build_object(
        'kind','extra_attack',
        'quantity',1,
        'weapon_type','ranged',
        'trigger','full_attack',
        'attack_bonus','highest_base_attack_bonus',
        'attack_penalty',-2,
        'penalty_scope','all_attacks_in_sequence'
      ))
    ),
    'review_reason','Mecânica estruturada a partir do SRD: acrescenta um ataque à distância com o maior BBA e aplica –2 a todos os ataques da ação de ataque total. A sequência iterativa da mesa já está integrada para jogadores; a interpretação genérica deste efeito, validação dos pré-requisitos e teste ponta a ponta ainda estão pendentes.'
  )
where id='srd35_feat_rapid_shot';

update public.srd_feats
set mechanics = coalesce(mechanics, '{}'::jsonb)
  || jsonb_build_object(
    'schema_version', 1,
    'engine_status', 'needs_review',
    'activation', jsonb_build_object('mode','passive','action_type','no_action','trigger','ranged_attack_against_melee_engaged_target'),
    'requirements', coalesce(mechanics->'requirements', '{}'::jsonb),
    'duration', jsonb_build_object('type','passive','value',null,'end_trigger',null),
    'usage', jsonb_build_object('limit',null,'period','turn','cooldown_rounds',0),
    'resolution', jsonb_build_object(
      'attack', null,
      'saving_throw', null,
      'effects', jsonb_build_array(jsonb_build_object(
        'kind','modifier',
        'stat','ranged_attack_melee_engagement_penalty',
        'value',4,
        'bonus_type','untyped',
        'conditions',jsonb_build_array(jsonb_build_object('type','target_engaged_in_melee'))
      ))
    ),
    'review_reason','Mecânica estruturada a partir do SRD: concede +4 para neutralizar a penalidade padrão de –4 ao disparar contra alvo engajado em combate corpo a corpo. A mesa ainda não possui estado confiável de engajamento; proximidade entre tokens não é evidência suficiente. O efeito permanece inativo.'
  )
where id='srd35_feat_precise_shot';