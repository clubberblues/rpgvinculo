-- Spell Mastery continua com os requisitos de classe/nível. A lista de magias
-- escolhidas será ativada na ficha quando o servidor puder validar e persistir
-- essa seleção; não expõe um campo que a função atual não aceita.
BEGIN;

UPDATE public.srd_feats
SET requisitos = COALESCE(requisitos,'{}'::jsonb) - 'parameter_type' - 'spell_choice_count'
WHERE id='srd35_feat_spell_mastery';

COMMIT;

