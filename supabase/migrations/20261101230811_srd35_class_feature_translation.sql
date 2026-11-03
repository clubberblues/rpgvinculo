-- Traduções de rótulos residuais de características de classe no catálogo SRD 3.5.
BEGIN;

UPDATE public.srd_class_level_features
SET name=regexp_replace(
      regexp_replace(
        regexp_replace(
          regexp_replace(
            regexp_replace(
              regexp_replace(name,'magic','mágico','gi'),
              'lawful','leal','gi'),
            'adamantine','adamantina','gi'),
          'any distance','qualquer distância','gi'),
        'ft[.]','pés','gi'),
      'week','semana','gi'),
    summary=regexp_replace(
      regexp_replace(
        regexp_replace(
          regexp_replace(
            regexp_replace(
              regexp_replace(summary,'magic','mágico','gi'),
              'lawful','leal','gi'),
            'adamantine','adamantina','gi'),
          'any distance','qualquer distância','gi'),
        'ft[.]','pés','gi'),
      'week','semana','gi')
WHERE class_id IN ('monge','paladino')
  AND (name ~* '(magic|lawful|adamantine|any distance|ft[.]|week)'
       OR summary ~* '(magic|lawful|adamantine|any distance|ft[.]|week)');

COMMIT;