update public.srd_feats
set mechanics = mechanics || jsonb_build_object(
  'schema_version', 1,
  'engine_status', 'ready',
  'activation', jsonb_build_object('mode','passive','action_type','no_action','trigger',null),
  'duration', jsonb_build_object('type','passive','value',null,'end_trigger',null),
  'resolution', jsonb_build_object(
    'attack', null,
    'saving_throw', null,
    'effects', jsonb_build_array(
      jsonb_build_object('kind','modifier','stat','attack_ranged','value',1,'bonus_type','untyped','conditions',jsonb_build_array(jsonb_build_object('type','target_distance_max_m','value',9))),
      jsonb_build_object('kind','modifier','stat','damage_ranged','value',1,'bonus_type','untyped','conditions',jsonb_build_array(jsonb_build_object('type','target_distance_max_m','value',9)))
    )
  ),
  'review_reason', 'Efeitos passivos condicionais estruturados; o resolvedor de ataques da mesa aplica +1 no ataque e no dano à distância quando o alvo está a até 9 m. Validação automatizada do cálculo e teste ponta a ponta ainda pendentes.'
)
where id='srd35_feat_point_blank_shot'
  and coalesce(mechanics->>'engine_status','')='needs_review';