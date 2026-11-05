-- Aptidão Mágica: bônus passivo em Identificar Magia e Usar Instrumento Mágico.
UPDATE public.srd_feats
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(
      COALESCE(mechanics,'{}'::jsonb),
      '{activation}',
      '{"mode":"passive","trigger":null,"action_type":"no_action"}'::jsonb,
      true
    ),
    '{resolution}',
    '{"effects":[{"kind":"modifier","stat":"skill:srd35_skill_spellcraft","value":2,"bonus_type":"untyped"},{"kind":"modifier","stat":"skill:usar_instrumento_magico","value":2,"bonus_type":"untyped"}]}'::jsonb,
    true
  ),
  '{engine_status}','"ready"'::jsonb,true
) || jsonb_build_object(
  'review_reason',
  'Bônus passivo +2 em Identificar Magia e Usar Instrumento Mágico conforme o SRD; ambos os IDs de perícia existem e a mesa já consome efeitos passivos de perícia estruturados.'
)
WHERE id='srd35_feat_magical_aptitude';
