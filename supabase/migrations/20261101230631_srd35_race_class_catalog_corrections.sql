-- Correções após conferir a lista de perícias e proficiências no SRD 3.5.
BEGIN;

UPDATE public.srd_skills
SET source_status='source_attached',
    source_notes='Perícia válida do SRD D&D 3.5 (Escape Artist), traduzida como Arte da Fuga; não excluir da criação de fichas.'
WHERE id='fuga';

UPDATE public.srd_classes
SET dados_tecnicos=jsonb_set(
  coalesce(dados_tecnicos,'{}'::jsonb),
  '{proficiencias,armas}',
  '["Clava","Besta leve","Besta pesada","Adaga","Machadinha","Azagaia","Kama","Nunchaku","Bordão","Sai","Shuriken","Siangham","Funda"]'::jsonb,
  true
)
WHERE id='monge';

COMMIT;