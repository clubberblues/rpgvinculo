UPDATE public.srd_feats
SET nome_pt = 'Iniciativa Aprimorada',
    descricao_pt = 'Benefício: Você recebe +4 de bônus nos testes de iniciativa.

Especial: Um guerreiro pode escolher Iniciativa Aprimorada como um de seus talentos adicionais de guerreiro.',
    mechanics = COALESCE(mechanics, '{}'::jsonb) || jsonb_build_object(
      'schema_version', 1,
      'engine_status', 'implemented',
      'activation', jsonb_build_object('mode', 'passive', 'action_type', 'no_action', 'trigger', NULL),
      'cost', jsonb_build_object('resource', NULL, 'amount', 0),
      'requirements', jsonb_build_object('conditions', '[]'::jsonb, 'equipment', '[]'::jsonb, 'minimum_level', NULL),
      'target', jsonb_build_object('type', 'self', 'count', 1, 'range', jsonb_build_object('value', 0, 'unit', 'm'), 'area', NULL),
      'duration', jsonb_build_object('type', 'passive', 'value', NULL, 'end_trigger', NULL),
      'usage', jsonb_build_object('limit', NULL, 'period', 'unlimited', 'cooldown_rounds', 0),
      'resolution', jsonb_build_object('attack', NULL, 'saving_throw', NULL, 'effects', jsonb_build_array(jsonb_build_object('kind', 'modifier', 'stat', 'initiative', 'value', 4, 'bonus_type', 'feat'))),
      'deactivation', jsonb_build_object('mode', 'never', 'cost', NULL),
      'engine_implementation', jsonb_build_object('paths', jsonb_build_array('public.registrar_iniciativa_d20', 'public.iniciar_iniciativa_com_dados'), 'verified_behavior', 'Adds +4 to initiative after the physical d20 and Dexterity modifier.', 'validation_note', 'Code-path verified; live campaign roll test remains pending.'),
      'review_reason', NULL
    )
WHERE id = 'iniciativa_aprimorada';
