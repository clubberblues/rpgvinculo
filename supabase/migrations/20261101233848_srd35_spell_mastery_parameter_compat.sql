BEGIN;
UPDATE public.srd_feats
SET requisitos = COALESCE(requisitos,'{}'::jsonb) - 'parameter_type' - 'spell_choice_count',
    exige_parametro = false
WHERE id='srd35_feat_spell_mastery';
COMMIT;