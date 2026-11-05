-- Estrutura o efeito parametrizado de Foco em Perícia.
-- Cada instância aplica +3 à perícia escolhida; o talento é repetível para perícias distintas.
update public.srd_feats
set mechanics =
  jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(coalesce(mechanics,'{}'::jsonb),
          '{activation}', '{"mode":"passive","action_type":"no_action","trigger":null}'::jsonb, true),
        '{duration}', '{"type":"passive","value":null,"end_trigger":null}'::jsonb, true),
      '{resolution}',
      coalesce(mechanics->'resolution','{}'::jsonb) || jsonb_build_object(
        'attack',null,'saving_throw',null,
        'effects',jsonb_build_array(jsonb_build_object(
          'kind','modifier',
          'stat_template','skill:{parameter}',
          'parameter_source','feat_parameter',
          'value',3,
          'bonus_type','untyped'
        ))
      ), true),
    '{engine_status}', '"ready"'::jsonb, true
  ) || jsonb_build_object(
    'review_reason','Bônus passivo +3 na perícia escolhida, com parâmetro validado e repetibilidade por perícias distintas. Integração no cálculo de testes de perícia da mesa adicionada; teste ponta a ponta com ficha real ainda pendente.'
  )
where id='srd35_feat_skill_focus';
