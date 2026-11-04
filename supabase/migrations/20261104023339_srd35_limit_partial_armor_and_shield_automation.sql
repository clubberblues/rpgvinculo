UPDATE public.srd_spell_effects
SET verification_status='needs_review'
WHERE spell_id='srd35_mage_armor' AND effect_index=1;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('needs_implementation'::text),true)
WHERE id='srd35_mage_armor';

UPDATE public.srd_spell_effects
SET parameters=jsonb_set(parameters,'{engine_rule}',
  '{"resolver":"buff","effect_data":{"flags":{"negates_magic_missile":true},"stacking_key":"shield_spell","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"target_scope":"self_only","willing_target":true,"spell_resistance":false}'::jsonb,true),
  verification_status='verified_srd'
WHERE spell_id='srd35_shield' AND effect_index=1;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('partial_shield_magic_missile_only'::text),true)
WHERE id='srd35_shield';