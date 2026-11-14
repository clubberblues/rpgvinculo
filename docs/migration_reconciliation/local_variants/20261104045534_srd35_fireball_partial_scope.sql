-- O dano em criaturas selecionadas está automatizado; objetos e geometria da área continuam sob arbitragem do Mestre.
UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}','"partial_multi_target"'::jsonb,true)
WHERE id='srd35_spell_fireball';
