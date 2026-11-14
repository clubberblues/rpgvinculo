-- Sound Burst: dano sônico integral, mas Atordoado somente em falha de Fortitude.
UPDATE public.srd_spell_effects
SET verification_status='verified_srd',
    parameters=jsonb_set(
      COALESCE(parameters,'{}'::jsonb),
      '{engine_rule}',
      '{
        "resolver":"damage",
        "effect_kind":"damage",
        "damage_expression":"1d8",
        "damage_type":"sonic",
        "save_type":"fortitude",
        "save_result":"damage_unaffected",
        "spell_resistance":true,
        "secondary_condition_id":"stunned",
        "duration_rounds":1
      }'::jsonb,
      true
    )
WHERE spell_id='srd35_spell_sound_burst' AND effect_index=1;

-- Shout: dano sônico metade em sucesso; Surdez por 2d6 rodadas somente em falha.
UPDATE public.srd_spell_effects
SET verification_status='verified_srd',
    parameters=jsonb_set(
      COALESCE(parameters,'{}'::jsonb),
      '{engine_rule}',
      '{
        "resolver":"damage",
        "effect_kind":"damage",
        "damage_expression":"5d6",
        "damage_type":"sonic",
        "save_type":"fortitude",
        "save_result":"half",
        "spell_resistance":true,
        "secondary_condition_id":"deafened",
        "extra_rolls":[{"key":"duration_rounds","expression":"2d6"}]
      }'::jsonb,
      true
    )
WHERE spell_id='srd35_spell_shout' AND effect_index=1;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(
  jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}','"partial_multi_target"'::jsonb,true),
  '{target_mode}','"multiple_targets_pending"'::jsonb,true
)
WHERE id IN ('srd35_spell_sound_burst','srd35_spell_shout');

UPDATE public.srd_conditions
SET mechanical_effects=COALESCE(mechanical_effects,'{}'::jsonb)||jsonb_build_object(
 'engine_status','partial',
 'implemented_features',CASE condition_id
   WHEN 'stunned' THEN jsonb_build_array('no_actions','ac_penalty','lose_dex_ac')
   ELSE jsonb_build_array('initiative_modifier')
 END,
 'pending_features',CASE condition_id
   WHEN 'stunned' THEN jsonb_build_array('drop_held_items')
   ELSE jsonb_build_array('listen_auto_fail','verbal_spell_failure_20','long_term_adaptation')
 END
)
WHERE condition_id IN ('stunned','deafened');
